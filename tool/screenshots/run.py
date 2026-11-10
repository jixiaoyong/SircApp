#!/usr/bin/env python3
"""python tool/screenshots/run.py --output .screenshots/run-001
Requires requirements.txt and `python -m playwright install chromium`.
Never writes doc/imgs; final/ appears atomically only after all checks succeed.
"""
import argparse
import functools
import hashlib
import http.server
import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import threading
import tempfile
import traceback
import urllib.request

from PIL import Image, ImageDraw
from playwright.sync_api import sync_playwright, expect

ROOT = Path(__file__).resolve().parents[2]
NAMES = ('home-diagonal.webp', 'wallet-diagonal.webp', 'home-light-en-narrow.webp',
         'wallet-dark-zh-narrow.webp', 'settings-appearance-wide.webp')
FONT_URL = ('https://raw.githubusercontent.com/notofonts/noto-cjk/'
            'Sans2.004/Sans/OTF/SimplifiedChinese/NotoSansCJKsc-Regular.otf')


def compose(left, right, reverse=False):
    assert left.size == right.size
    w, h = left.size
    mask = Image.new('L', (w, h), 0)
    top, bottom = (w // 3, 2 * w // 3) if reverse else (2 * w // 3, w // 3)
    ImageDraw.Draw(mask).polygon([(0, 0), (top, 0), (bottom, h - 1), (0, h - 1)], fill=255)
    result = Image.composite(left, right, mask)
    # Complementary masks, identical origin, no crop/scale/translation.
    for x, y in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        assert result.getpixel((x, y)) == (left if x == 0 else right).getpixel((x, y))
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    out = args.output.resolve()
    if out.exists():
        raise RuntimeError('Output must be new; refusing to replace an earlier run')
    out.mkdir(parents=True)
    raw = out / 'raw'
    raw.mkdir()
    stage = out / 'staging'
    stage.mkdir()
    metadata = {'working_tree_diff_sha256': hashlib.sha256(subprocess.check_output(['git', 'diff', 'HEAD', '--', 'lib', 'web', 'assets', 'pubspec.yaml', 'pubspec.lock'], cwd=ROOT)).hexdigest(),
                'source_sha': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                'css_wide': [1440, 1000], 'css_narrow': [390, 844], 'dpr': 2,
                'webp': {'quality': 90, 'method': 6}, 'captures': [], 'status': 'running'}
    server = None
    # Python fixture files are outside lib and copied only into the temp tree.
    try:
        # Never patch the working tree. Copy tracked inputs (including local edits)
        # to an isolated build directory; strict git-apply fails on drift.
        with tempfile.TemporaryDirectory(prefix='sirc-screenshots-') as temp:
            build = Path(temp)
            tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0')
            for name in filter(None, tracked):
                source = ROOT / name
                if source.is_file():
                    dest = build / name
                    dest.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(source, dest)
            patch = ROOT / 'tool/screenshots/fixture.patch'
            subprocess.run(['git', 'apply', '--check', str(patch)], cwd=build, check=True)
            subprocess.run(['git', 'apply', str(patch)], cwd=build, check=True)
            metadata['fixture_patch_sha256'] = hashlib.sha256(patch.read_bytes()).hexdigest()
            shutil.copy2(ROOT / 'tool/screenshots/screenshot_mode.dart.txt', build / 'lib/core/screenshot_mode.dart')
            shutil.copy2(ROOT / 'tool/screenshots/screenshot_wallet_repository.dart.txt',
                         build / 'lib/features/wallet/data/screenshot_wallet_repository.dart')
            font = build / 'assets/screenshot-font.otf'
            urllib.request.urlretrieve(FONT_URL, font)
            metadata['font_sha256'] = hashlib.sha256(font.read_bytes()).hexdigest()
            assert metadata['font_sha256'] == '2c76254f6fc379fddfce0a7e84fb5385bb135d3e399294f6eeb6680d0365b74b', 'Font checksum mismatch'
            with (out / 'build.log').open('w') as log:
                subprocess.run(['flutter', 'pub', 'get', '--enforce-lockfile'], cwd=build,
                               stdout=log, stderr=subprocess.STDOUT, check=True)
                subprocess.run(['flutter', 'build', 'web', '--release', '--no-web-resources-cdn',
                                '--dart-define=SCREENSHOT_MODE=true'], cwd=build, stdout=log,
                               stderr=subprocess.STDOUT, check=True)
            shutil.copytree(build / 'build/web', out / 'web')
        class LoggedHandler(http.server.SimpleHTTPRequestHandler):
            def log_message(self, fmt, *args):
                with (out / 'server.log').open('a') as log:
                    log.write((fmt % args) + '\n')

        handler = functools.partial(LoggedHandler, directory=str(out / 'web'))
        server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), handler)
        threading.Thread(target=server.serve_forever, daemon=True).start()
        url = f'http://127.0.0.1:{server.server_port}'
        metadata['server'] = url
        with sync_playwright() as p:
            browser = p.chromium.launch()
            metadata['browser'] = browser.version
            context = browser.new_context(viewport={'width': 1440, 'height': 1000},
                                          device_scale_factor=2, locale='en-US', timezone_id='UTC',
                                          color_scheme='light', reduced_motion='reduce')
            page = context.new_page()
            errors = []
            page.on('pageerror', lambda error: errors.append(str(error)))
            def log_console(msg):
                with (out / 'console.log').open('a') as log:
                    log.write(f'{msg.type}: {msg.text}\n')
            page.on('console', log_console)
            context.tracing.start(screenshots=True, snapshots=True, sources=True)
            # No external requests: local CanvasKit/font/assets only.
            page.route('**/*', lambda route: route.continue_() if route.request.url.startswith(url) else route.abort())
            try:
                page.goto(url + '/#/sign_in')
                page.get_by_role('textbox').first.wait_for(timeout=120000)
                page.get_by_role('textbox').nth(0).fill('shot_demo')
                page.get_by_role('textbox').nth(1).fill('demo-2026')
                page.get_by_role('button', name='Login', exact=True).click()
                page.wait_for_url('**/#/main')

                def click(text):
                    page.get_by_text(re.compile(r'^' + re.escape(text) + r'(?:\n|$)')).last.click()

                def route(tab, path):
                    page.get_by_role('button', name=re.compile(r'^' + re.escape(tab) + r'(?:\s|$)')).first.click()
                    page.wait_for_url(re.compile(r'.*/#' + re.escape(path) + (r'(?:/.*)?$' if path == '/menu' else r'$')))

                def appearance(dark=False, zh=False):
                    route('菜单' if zh else 'Menu', '/menu')
                    if page.viewport_size['width'] < 840 and page.url.endswith('/menu/languages'):
                        page.get_by_role('button', name='返回' if zh else 'Back', exact=True).click()
                    if not page.url.endswith('/menu/appearance'):
                        click('外观主题' if zh else 'Appearance')
                    page.wait_for_url('**/#/menu/appearance')
                    click(('暗色' if dark else '亮色') if zh else ('Dark' if dark else 'Light'))

                def chinese():
                    if page.viewport_size['width'] < 840:
                        page.get_by_role('button', name='Back', exact=True).click()
                    click('Language')
                    click('中文')

                def capture(name, lang, theme, path, narrow=False):
                    page.wait_for_url('**/#' + path)
                    ready = page.locator('[flt-semantics-identifier="screenshot-ready"]')
                    expect(ready).to_have_attribute('aria-label', f'screenshot:{lang}:{theme}:ready')
                    # Let theme transitions, font rasterization and two frames settle.
                    page.wait_for_timeout(1000)
                    size = (780, 1688) if narrow else (2880, 2000)
                    file = raw / (name + '.png')
                    page.screenshot(path=str(file), animations='disabled')
                    image = Image.open(file).convert('RGB')
                    assert image.size == size, (name, image.size)
                    metadata['captures'].append({'name': name, 'language': lang, 'theme': theme,
                                                 'path': path, 'size': size})
                    return image

                # English/light sources; all navigation/settings use actual UI.
                home_en = capture('home-light-en', 'en', 'light', '/main')
                route('Wallet', '/wallet')
                wallet_en = capture('wallet-light-en', 'en', 'light', '/wallet')
                appearance()
                settings_en = capture('settings-light-en', 'en', 'light', '/menu/appearance')
                appearance(dark=True)
                route('Home', '/main')
                home_dark_en = capture('home-dark-en', 'en', 'dark', '/main')
                appearance(dark=True)
                chinese()
                # Chinese menu label is verified against ready state below.
                appearance(dark=True, zh=True)
                settings_zh = capture('settings-dark-zh', 'zh', 'dark', '/menu/appearance')
                route('钱包', '/wallet')
                wallet_zh = capture('wallet-dark-zh', 'zh', 'dark', '/wallet')
                appearance(zh=True)
                route('首页', '/main')
                home_zh = capture('home-light-zh', 'zh', 'light', '/main')
                appearance(zh=True)
                click('语言')
                click('English')
                route('Home', '/main')
                page.set_viewport_size({'width': 390, 'height': 844})
                narrow_home = capture('home-light-en-narrow', 'en', 'light', '/main', True)
                appearance(dark=True)
                chinese()
                route('钱包', '/wallet')
                narrow_wallet = capture('wallet-dark-zh-narrow', 'zh', 'dark', '/wallet', True)
                images = [compose(home_zh, home_dark_en), compose(wallet_en, wallet_zh),
                          narrow_home, narrow_wallet, compose(settings_en, settings_zh, True)]
                for name, image in zip(NAMES, images):
                    image.save(stage / name, 'WEBP', quality=90, method=6)
                if errors:
                    raise RuntimeError(errors)
            except Exception:
                page.screenshot(path=str(out / 'failure.png'))
                (out / 'failure.html').write_text(page.content())
                raise
            finally:
                context.tracing.stop(path=str(out / 'trace.zip'))
                browser.close()
        assert set(p.name for p in stage.iterdir()) == set(NAMES)
        for name in NAMES:
            with Image.open(stage / name) as image:
                image.verify()
        stage.rename(out / 'final')
        metadata['status'] = 'passed'
    except Exception:
        metadata['status'] = 'failed'
        (out / 'failure.txt').write_text(traceback.format_exc())
        raise
    finally:
        if server:
            server.shutdown()
            server.server_close()
        (out / 'metadata.json').write_text(json.dumps(metadata, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
