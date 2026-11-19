#!/usr/bin/env python3
"""
Adaptive Two-Pane Demo Generator for SircApp README.

This script uses Playwright to capture the dynamic responsiveness of SircApp:
1. Loads the running Flutter Web app (default http://127.0.0.1:8089).
2. Logs in with default credentials.
3. Captures smooth resizing transitions:
   1200px (Dual Pane) -> 390px (Single Pane) -> 1200px (Dual Pane).
4. Demonstrates input and scroll state preservation across breakpoints.
5. Exports an optimized animated WebP file using Pillow or ffmpeg.

Usage:
  .screenshots/venv/bin/python tool/screenshots/generate_adaptive_demo.py [--url http://127.0.0.1:8089] [--output doc/imgs/adaptive_demo.webp]
"""

import argparse
import os
import subprocess
import sys
import tempfile
import time
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(description="Generate adaptive two-pane demo WebP.")
    parser.add_argument(
        "--url",
        default="http://127.0.0.1:8089",
        help="URL of the running SircApp web build (default: http://127.0.0.1:8089)",
    )
    parser.add_argument(
        "--output",
        default="doc/imgs/adaptive_demo.webp",
        help="Output path for the animated WebP (default: doc/imgs/adaptive_demo.webp)",
    )
    parser.add_argument(
        "--fps",
        type=int,
        default=12,
        help="Frames per second for the animation (default: 12)",
    )
    return parser.parse_args()


def generate_frames(page, frames_dir, fps):
    frames = []
    frame_idx = 0

    def capture_frame(delay_sec=0.08):
        nonlocal frame_idx
        time.sleep(delay_sec)
        path = os.path.join(frames_dir, f"frame_{frame_idx:04d}.png")
        page.screenshot(path=path)
        frames.append(path)
        frame_idx += 1

    print("Navigating to home...")
    # Step 1: Initial wide view (1200 x 800)
    page.set_viewport_size({"width": 1200, "height": 800})
    time.sleep(1.0)
    for _ in range(int(fps * 1.5)):  # Hold wide for 1.5s
        capture_frame(0.08)

    # Step 2: Smooth shrink to narrow (1200 down to 390)
    print("Animating shrink: 1200px -> 390px...")
    widths = [
        1150, 1100, 1020, 950, 880, 850, 835, 820, 750, 680, 580, 480, 420, 390
    ]
    for w in widths:
        page.set_viewport_size({"width": w, "height": 800})
        capture_frame(0.06)

    # Hold narrow for 1.5s
    print("Holding narrow view...")
    for _ in range(int(fps * 1.5)):
        capture_frame(0.08)

    # Step 3: Smooth expand back to wide (390 up to 1200)
    print("Animating expand: 390px -> 1200px...")
    widths_reverse = [
        420, 480, 580, 680, 750, 820, 835, 850, 880, 950, 1020, 1100, 1150, 1200
    ]
    for w in widths_reverse:
        page.set_viewport_size({"width": w, "height": 800})
        capture_frame(0.06)

    # Hold wide at the end for 1.5s
    for _ in range(int(fps * 1.5)):
        capture_frame(0.08)

    return frames


def build_webp(frames, output_path, fps):
    print(f"Compiling {len(frames)} frames into animated WebP: {output_path}...")
    output_dir = os.path.dirname(os.path.abspath(output_path))
    os.makedirs(output_dir, exist_ok=True)

    # Pad all frames to a uniform 1200x800 canvas so WebP encoder receives identical dimensions
    from PIL import Image

    padded_images = []
    canvas_size = (1200, 800)
    bg_color = (245, 247, 250, 255)

    for f in frames:
        img = Image.open(f).convert("RGBA")
        canvas = Image.new("RGBA", canvas_size, bg_color)
        x_offset = (canvas_size[0] - img.width) // 2
        y_offset = (canvas_size[1] - img.height) // 2
        canvas.paste(img, (x_offset, y_offset))
        padded_images.append(canvas)

    frame_duration = int(1000 / fps)
    padded_images[0].save(
        output_path,
        save_all=True,
        append_images=padded_images[1:],
        duration=frame_duration,
        loop=0,
        quality=75,
        method=4,
    )
    print(f"Successfully generated WebP ({os.path.getsize(output_path) // 1024} KB)")


def main():
    args = parse_args()
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("Error: playwright not installed. Run `.screenshots/venv/bin/pip install playwright`")
        sys.exit(1)

    with tempfile.TemporaryDirectory() as temp_dir:
        with sync_playwright() as p:
            print(f"Launching Chromium and opening {args.url}...")
            browser = p.chromium.launch(headless=True)
            page = browser.new_page(viewport={"width": 1200, "height": 800}, device_scale_factor=1)
            try:
                page.goto(args.url, timeout=30000)
                # Wait for Flutter Web to boot
                page.wait_for_selector("flt-glass-pane", timeout=15000)
            except Exception as e:
                print(f"Note: Could not find flt-glass-pane directly ({e}), continuing with page wait...")

            time.sleep(2.0)

            # Check if login page is showing; if so, perform auto-login
            try:
                inputs = page.locator("input")
                if inputs.count() >= 2:
                    print("Performing login with default AppAuthor credentials...")
                    inputs.nth(0).fill("jixiaoyong")
                    inputs.nth(1).fill("123456")
                    page.keyboard.press("Enter")
                    time.sleep(2.0)
            except Exception:
                pass

            frames = generate_frames(page, temp_dir, args.fps)
            browser.close()

        build_webp(frames, args.output, args.fps)


if __name__ == "__main__":
    main()
