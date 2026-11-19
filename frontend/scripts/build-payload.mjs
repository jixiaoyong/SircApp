import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { fileURLToPath } from 'url';
import archiver from 'archiver';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 路径定义
const frontendRoot = path.resolve(__dirname, '..');
const distCompanionDir = path.resolve(frontendRoot, 'dist/companion');
const sircAppRoot = path.resolve(frontendRoot, '..');
const sircAssetsPayloadDir = path.resolve(sircAppRoot, 'assets/web_payload');
const sircBuiltinCompanionDir = path.resolve(sircAssetsPayloadDir, 'companion');
const releaseDir = path.resolve(sircAppRoot, 'build/payload_releases');
const mockServerDistDir = path.resolve(sircAppRoot, '../21.21-web_payload_manager/tool/dist');

// 参数解析
const args = process.argv.slice(2);
const versionArg = args.find((a) => a.startsWith('--version='))?.split('=')[1];
const targetArg = args.find((a) => a.startsWith('--target='))?.split('=')[1] || 'all';
const baseUrlArg = args.find((a) => a.startsWith('--base-url='))?.split('=')[1] || 'https://jixiaoyong.github.io/SircApp/payload';

// 版本与构建时间
const now = new Date();
const pad = (n) => String(n).padStart(2, '0');
const buildLabel = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;

// 内置底包默认固定为 1.0.0 基线版本；发布热更新包默认采用当前毫秒时间戳递增
const builtinVersion = versionArg || '1.0.0';
const releaseVersion = versionArg ? (isNaN(Number(versionArg)) ? versionArg : Number(versionArg)) : Date.now();

console.log('🚀 [Build-Payload] 开始处理离线包资源与清单...');
console.log(`   📦 内置基线版本: ${builtinVersion} | 远端热更新版本: ${releaseVersion} (${buildLabel})`);
console.log(`   📂 产物输入目录: ${distCompanionDir}`);

if (!fs.existsSync(distCompanionDir)) {
  console.error(`❌ 错误: 未找到 dist 编译产物，请先运行 vite build!`);
  process.exit(1);
}

// 递归扫描文件
function getAllFiles(dir, base = '') {
  let results = [];
  const list = fs.readdirSync(dir);
  for (const item of list) {
    const fullPath = path.join(dir, item);
    const relPath = base ? `${base}/${item}` : item;
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      results = results.concat(getAllFiles(fullPath, relPath));
    } else {
      results.push({ fullPath, relPath });
    }
  }
  return results;
}

const rawFiles = getAllFiles(distCompanionDir);
console.log(`   📄 发现产物文件数: ${rawFiles.length}`);

// 逐一计算 MD5
const fileManifestEntries = rawFiles.map(({ fullPath, relPath }) => {
  const fileBytes = fs.readFileSync(fullPath);
  const md5 = crypto.createHash('md5').update(fileBytes).digest('hex');
  return {
    path: `companion/${relPath}`,
    md5: md5,
    size: fileBytes.length,
  };
});

// 组装标准 version.json 工具函数
function createVersionJson(ver) {
  return {
    version: ver,
    buildLabel: buildLabel,
    modules: [
      {
        key: 'companion',
        name: 'Sirc 随行',
        entryHtml: 'companion/index.html',
        version: ver,
        description: 'Sirc 全球随行金融中心（离线应急卡片、全球救援专线、离线汇率与防盗刷指南）',
      },
    ],
    fileInfo: {
      total_files: fileManifestEntries.length,
      files: fileManifestEntries,
    },
  };
}

const builtinVersionJsonString = JSON.stringify(createVersionJson(builtinVersion), null, 2);
const releaseVersionJsonString = JSON.stringify(createVersionJson(releaseVersion), null, 2);

// 目标 1: 同步至 SircApp 内置底包 assets/web_payload/
if (targetArg === 'all' || targetArg === 'builtin') {
  console.log('\n📥 [1/2] 正在同步内置底包至 SircApp assets/web_payload/ ...');
  if (fs.existsSync(sircBuiltinCompanionDir)) {
    fs.rmSync(sircBuiltinCompanionDir, { recursive: true, force: true });
  }
  fs.mkdirSync(sircBuiltinCompanionDir, { recursive: true });

  // 复制所有 companion 文件
  fs.cpSync(distCompanionDir, sircBuiltinCompanionDir, { recursive: true });

  // 写入 version.json
  const sircVersionJsonPath = path.join(sircAssetsPayloadDir, 'version.json');
  fs.writeFileSync(sircVersionJsonPath, builtinVersionJsonString, 'utf-8');
  console.log(`   ✅ 已更新内置底包清单 (v${builtinVersion}): ${sircVersionJsonPath}`);
  console.log(`   ✅ 已同步文件至: ${sircBuiltinCompanionDir}`);
}

// 目标 2: 生成热更新 ZIP 与 server_manifest.json
if (targetArg === 'all' || targetArg === 'release') {
  console.log('\n📦 [2/2] 正在生成发布离线包 ZIP 与更新清单...');
  fs.mkdirSync(releaseDir, { recursive: true });

  const zipFileName = `payload_v${releaseVersion}.zip`;
  const releaseZipPath = path.join(releaseDir, zipFileName);

  const output = fs.createWriteStream(releaseZipPath);
  const archive = archiver('zip', { zlib: { level: 9 } });

  output.on('close', () => {
    const zipBytes = fs.readFileSync(releaseZipPath);
    const zipMd5 = crypto.createHash('md5').update(zipBytes).digest('hex');
    const zipSize = zipBytes.length;

    console.log(`   ✅ 已打包 ZIP: ${releaseZipPath} (${zipSize} bytes)`);
    console.log(`   🔑 ZIP MD5: ${zipMd5}`);

    const downloadUrl = `${baseUrlArg.replace(/\/+$/, '')}/${zipFileName}`;
    const serverManifest = {
      version: releaseVersion,
      versionStr: String(releaseVersion),
      downloadUrl: downloadUrl,
      zipUrl: downloadUrl,
      md5: zipMd5,
      zipMd5: zipMd5,
      fileSize: zipSize,
      zipSize: zipSize,
      zipFilename: zipFileName,
      timestamp: typeof releaseVersion === 'number' ? releaseVersion : Date.now(),
      buildLabel: buildLabel,
      minAppVersion: '1.0.0',
      description: `Sirc Companion v${releaseVersion} (${buildLabel})`,
    };

    const manifestStr = JSON.stringify(serverManifest, null, 2);
    const manifestPath = path.join(releaseDir, 'server_manifest.json');
    fs.writeFileSync(manifestPath, manifestStr, 'utf-8');
    console.log(`   ✅ 已生成更新清单: ${manifestPath}`);

    // 如果本地 mock 服务目录存在，同步拷一份供即时热更新测试
    if (fs.existsSync(mockServerDistDir)) {
      const mockZipPath = path.join(mockServerDistDir, zipFileName);
      const mockManifestPath = path.join(mockServerDistDir, 'server_manifest.json');
      fs.copyFileSync(releaseZipPath, mockZipPath);
      fs.writeFileSync(mockManifestPath, manifestStr, 'utf-8');
      console.log(`   🌐 已同步至 Mock 更新服务目录: ${mockServerDistDir}`);
    }

    console.log('\n🎉 [Success] 离线包构建与双向分发全部完成！\n');
  });

  archive.on('error', (err) => {
    throw err;
  });

  archive.pipe(output);

  // 1. 将 version.json 添加至根目录
  archive.append(releaseVersionJsonString, { name: 'version.json' });

  // 2. 将 companion 目录添加至 ZIP
  archive.directory(distCompanionDir, 'companion');

  archive.finalize();
}
