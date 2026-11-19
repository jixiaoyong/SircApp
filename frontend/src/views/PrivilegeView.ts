import { SircBridge } from '../bridge/sircBridge';
import { Icons } from '../utils/icons';
import { i18n } from '../i18n';

export class PrivilegeView {
  // 二级页面：商旅权益列表与离线小票入口
  public static renderLevel2(onOpenReceiptSimulator: () => void): HTMLElement {
    const t = i18n.t;
    const container = document.createElement('div');
    container.className = 'sirc-view-container sirc-stagger';

    container.innerHTML = `
      <div class="sirc-callout is-warning">
        <span class="sirc-callout-icon">${Icons.crown(18)}</span>
        <div>
          <div class="sirc-callout-title">${t.privilegeCalloutTitle}</div>
          <div>${t.privilegeCalloutDesc}</div>
        </div>
      </div>

      <div class="sirc-section-label">
        <span>${t.privilegeSectionLabel}</span>
        <span class="sirc-section-meta">${t.privilegeSectionMeta}</span>
      </div>

      <div class="sirc-group">
        <div class="sirc-list-row" style="cursor: default;">
          <span class="sirc-icon-well privilege">${Icons.plane(18)}</span>
          <span class="sirc-row-body">
            <span class="sirc-row-title">${t.privilegeCipTitle}</span>
            <span class="sirc-row-desc">${t.privilegeCipDesc}</span>
          </span>
          <span class="sirc-row-trailing">
            <span class="sirc-pill sirc-pill-success" style="padding: 3px 8px;">${t.privilegeCipCount}</span>
          </span>
        </div>

        <div class="sirc-list-row" style="cursor: default;">
          <span class="sirc-icon-well currency">${Icons.lounge(18)}</span>
          <span class="sirc-row-body">
            <span class="sirc-row-title">${t.privilegeLoungeTitle}</span>
            <span class="sirc-row-desc">${t.privilegeLoungeDesc}</span>
          </span>
          <span class="sirc-row-trailing">
            <span class="sirc-pill" style="padding: 3px 8px;">${t.privilegeLoungeCount}</span>
          </span>
        </div>
      </div>

      <div class="sirc-panel" style="display: flex; flex-direction: column; gap: 12px;">
        <div style="display: flex; align-items: center; gap: 10px;">
          <span class="sirc-icon-well" style="width: 36px; height: 36px;">${Icons.receipt(18)}</span>
          <div>
            <div style="font-size: 15px; font-weight: 600; color: var(--sirc-ink);">${t.privilegeReceiptBannerTitle}</div>
            <div style="font-size: 12px; color: var(--sirc-muted);">${t.privilegeReceiptBannerSub}</div>
          </div>
        </div>
        <button id="btn-open-receipt" class="sirc-ink-key" type="button" style="width: 100%;">
          <span>${t.privilegeReceiptBannerBtn}</span>
          ${Icons.arrowRight(15)}
        </button>
      </div>
    `;

    container.querySelector('#btn-open-receipt')!.addEventListener('click', onOpenReceiptSimulator);

    return container;
  }

  // 三级页面：建筑感离线纸质消费签单
  public static renderLevel3(): HTMLElement {
    const t = i18n.t;
    const isEn = i18n.lang === 'en';
    const container = document.createElement('div');
    container.className = 'sirc-view-container sirc-stagger';

    const now = new Date();
    const pad = (n: number) => String(n).padStart(2, '0');
    const timestamp = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
    const voucherId = `OFFLINE-${Math.floor(100000 + Math.random() * 900000)}`;

    container.innerHTML = `
      <div class="sirc-receipt">
        <div class="sirc-receipt-watermark">SIRC OFFLINE</div>

        <div style="text-align: center;">
          <div style="font-family: var(--sirc-mono); font-size: 10.5px; letter-spacing: 0.08em; color: var(--sirc-light);">OFFLINE TRANSACTION SLIP</div>
          <div style="font-size: 17px; font-weight: 700; letter-spacing: -0.015em; color: var(--sirc-ink); margin-top: 4px;">${isEn ? 'SIRC Travel Purchase Voucher' : 'SIRC 离线商旅消费签单'}</div>
          <div class="mono" style="font-size: 11.5px; color: var(--sirc-muted); margin-top: 4px;">#${voucherId}</div>
        </div>

        <div class="sirc-receipt-perf"></div>

        <div class="sirc-ledger">
          <div class="sirc-ledger-row">
            <span class="sirc-ledger-key">${isEn ? 'Merchant' : '商户名称'}</span>
            <span class="sirc-ledger-val">${isEn ? 'In-Flight Duty Free Boutique' : '国际航线机上免税品中心'}</span>
          </div>
          <div class="sirc-ledger-row">
            <span class="sirc-ledger-key">${isEn ? 'Card Number' : '支付卡号'}</span>
            <span class="sirc-ledger-val mono">4929 •••• •••• 0042</span>
          </div>
          <div class="sirc-ledger-row">
            <span class="sirc-ledger-key">${isEn ? 'Date Time' : '交易时间'}</span>
            <span class="sirc-ledger-val mono">${timestamp}</span>
          </div>
          <div class="sirc-ledger-row">
            <span class="sirc-ledger-key">${isEn ? 'Status' : '授权状态'}</span>
            <span class="sirc-ledger-val" style="color: var(--sirc-success);">${isEn ? 'Pre-Auth (Local)' : '离线预授权 (Pre-Auth)'}</span>
          </div>
        </div>

        <div class="sirc-receipt-perf"></div>

        <div class="sirc-ledger-row" style="align-items: baseline;">
          <span style="font-size: 13.5px; font-weight: 600; color: var(--sirc-muted);">${isEn ? 'Amount' : '消费金额'}</span>
          <span class="tabular" style="font-size: 24px; font-weight: 700; letter-spacing: -0.025em; color: var(--sirc-ink);">$ 99.00 <span style="font-size: 12px; font-weight: 600; color: var(--sirc-muted);">USD</span></span>
        </div>

        <div class="sirc-barcode">
          <div class="sirc-barcode-bars" aria-hidden="true"></div>
          <span class="mono" style="font-size: 10px; letter-spacing: 0.14em; color: var(--sirc-light);">${voucherId} · VERIFIED</span>
        </div>
      </div>

      <!-- 原生多模态存根面板：拍照凭单与语音备忘 -->
      <div class="sirc-panel" style="display: flex; flex-direction: column; gap: 14px;">
        <div style="display: flex; align-items: center; justify-content: space-between;">
          <div style="font-size: 14.5px; font-weight: 600; color: var(--sirc-ink);">${isEn ? 'Archive Credentials' : '归档凭据 (调用原生设备)'}</div>
          <span class="sirc-pill sirc-pill-success" style="font-size: 11px;">
            <span class="sirc-status-dot"></span>
            <span>${isEn ? 'Channel Ready' : '原生通道就绪'}</span>
          </span>
        </div>

        <!-- 1. 拍照存单附件 -->
        <div style="display: flex; flex-direction: column; gap: 8px;">
          <div style="font-size: 12.5px; color: var(--sirc-muted);">${isEn ? 'Receipt Photo Memo (Camera / Gallery)' : '纸质签单照片留存 (相机 / 相册)'}</div>
          <div style="display: flex; gap: 8px;">
            <button id="btn-camera" class="sirc-key" type="button" style="flex: 1;">
              ${Icons.shield(15)}
              <span>${isEn ? 'Take Photo' : '拍摄纸质小票'}</span>
            </button>
            <button id="btn-gallery" class="sirc-key" type="button" style="flex: 1;">
              ${Icons.receipt(15)}
              <span>${isEn ? 'From Gallery' : '从相册选取'}</span>
            </button>
          </div>
          <div id="receipt-photo-preview" style="display: none; margin-top: 6px; position: relative;">
            <img id="receipt-photo-img" src="" alt="签单存根" style="width: 100%; max-height: 200px; object-fit: cover; border-radius: 8px; border: 1px solid var(--sirc-border);" />
            <button id="btn-remove-photo" type="button" style="position: absolute; top: 6px; right: 6px; background: rgba(0,0,0,0.6); color: #fff; border: none; border-radius: 12px; padding: 2px 8px; font-size: 11px; cursor: pointer;">${isEn ? 'Remove' : '移除照片'}</button>
          </div>
        </div>

        <!-- 2. 语音备忘附件 -->
        <div style="display: flex; flex-direction: column; gap: 8px; border-top: 1px dashed var(--sirc-border); padding-top: 12px;">
          <div style="font-size: 12.5px; color: var(--sirc-muted);">${isEn ? 'Voice Memo (Native Mic)' : '商户口头退税/权益语音备忘 (原生麦克风录音)'}</div>
          <div style="display: flex; gap: 8px; align-items: center;">
            <button id="btn-record-toggle" class="sirc-key" type="button" style="flex: 1;">
              <span id="record-icon" style="color: var(--sirc-error); display: inline-flex;">●</span>
              <span id="record-text">${isEn ? 'Start Recording' : '开始录音'}</span>
            </button>
            <button id="btn-play-audio" class="sirc-key" type="button" style="display: none; flex: 1;">
              <span>${isEn ? '▶ Play Voice' : '▶ 播放录音'}</span>
            </button>
          </div>
          <div id="audio-status" style="font-size: 11.5px; color: var(--sirc-muted); display: none;"></div>
        </div>
      </div>

      <div style="display: flex; gap: 10px;">
        <button id="btn-copy-voucher" class="sirc-ink-key" type="button" style="flex: 1;">
          ${Icons.copy(15)}
          <span>${isEn ? 'Copy Ref No' : '复制凭单编号'}</span>
        </button>
        <button id="btn-refresh-voucher" class="sirc-key" type="button" style="flex: 1;">
          ${Icons.refresh(15)}
          <span>${isEn ? 'Regenerate' : '重新生成'}</span>
        </button>
      </div>
    `;

    // 绑定原生照片获取
    const previewContainer = container.querySelector('#receipt-photo-preview') as HTMLElement;
    const previewImg = container.querySelector('#receipt-photo-img') as HTMLImageElement;
    const btnRemovePhoto = container.querySelector('#btn-remove-photo') as HTMLElement;

    const handlePick = async (source: 'camera' | 'gallery') => {
      try {
        await SircBridge.haptic('light');
        const dataUrl = await SircBridge.pickImage(source);
        if (dataUrl) {
          previewImg.src = dataUrl;
          previewContainer.style.display = 'block';
          SircBridge.showToast(source === 'camera' ? '拍照成功' : '已添加小票照片');
        }
      } catch (e: any) {
        if (!e.message?.includes('取消')) {
          SircBridge.showToast(`获取图片失败: ${e.message}`);
        }
      }
    };

    container.querySelector('#btn-camera')!.addEventListener('click', () => handlePick('camera'));
    container.querySelector('#btn-gallery')!.addEventListener('click', () => handlePick('gallery'));
    btnRemovePhoto.addEventListener('click', () => {
      previewImg.src = '';
      previewContainer.style.display = 'none';
      SircBridge.showToast('已移除签单照片');
    });

    // 绑定原生录音与播放
    let isRecording = false;
    let recordedAudio: { dataUrl: string; path: string } | null = null;
    let isPlaying = false;
    const btnRecordToggle = container.querySelector('#btn-record-toggle') as HTMLElement;
    const recordIcon = container.querySelector('#record-icon') as HTMLElement;
    const recordText = container.querySelector('#record-text') as HTMLElement;
    const btnPlayAudio = container.querySelector('#btn-play-audio') as HTMLElement;
    const audioStatus = container.querySelector('#audio-status') as HTMLElement;

    btnRecordToggle.addEventListener('click', async () => {
      if (!isRecording) {
        try {
          await SircBridge.haptic('medium');
          await SircBridge.startRecord();
          isRecording = true;
          recordIcon.textContent = '■';
          recordIcon.style.color = 'var(--sirc-error)';
          recordText.textContent = '停止录音并保存';
          btnPlayAudio.style.display = 'none';
          audioStatus.style.display = 'block';
          audioStatus.textContent = '● 正在录制原生音频...';
        } catch (e: any) {
          SircBridge.showToast(`录音失败: ${e.message}`);
        }
      } else {
        try {
          await SircBridge.haptic('light');
          const res = await SircBridge.stopRecord();
          isRecording = false;
          recordedAudio = res;
          recordIcon.textContent = '●';
          recordText.textContent = '重新录制';
          btnPlayAudio.style.display = 'inline-flex';
          audioStatus.style.display = 'block';
          audioStatus.textContent = '已保存语音备忘 (可点击播放)';
          SircBridge.showToast('录音保存完成');
        } catch (e: any) {
          isRecording = false;
          recordIcon.textContent = '●';
          recordText.textContent = '开始录音';
          SircBridge.showToast(`保存录音失败: ${e.message}`);
        }
      }
    });

    btnPlayAudio.addEventListener('click', async () => {
      if (!recordedAudio) return;
      if (!isPlaying) {
        try {
          await SircBridge.haptic('light');
          isPlaying = true;
          btnPlayAudio.querySelector('span')!.textContent = '■ 停止播放';
          audioStatus.textContent = '▶ 正在播放语音备忘...';
          await SircBridge.playAudio(recordedAudio);
        } catch (e: any) {
          isPlaying = false;
          btnPlayAudio.querySelector('span')!.textContent = '▶ 播放录音';
          SircBridge.showToast(`播放失败: ${e.message}`);
        }
      } else {
        await SircBridge.stopAudio();
        isPlaying = false;
        btnPlayAudio.querySelector('span')!.textContent = '▶ 播放录音';
        audioStatus.textContent = '已停止播放';
      }
    });

    container.querySelector('#btn-copy-voucher')!.addEventListener('click', () => {
      SircBridge.copyText(voucherId, '已复制凭单编号');
    });

    container.querySelector('#btn-refresh-voucher')!.addEventListener('click', () => {
      const parent = container.parentElement;
      if (parent) {
        parent.innerHTML = '';
        parent.appendChild(PrivilegeView.renderLevel3());
      }
      SircBridge.showToast('已刷新离线签单编号');
    });

    return container;
  }
}
