import { SircBridge } from '../bridge/sircBridge';
import { Icons } from '../utils/icons';

export class PrivilegeView {
  // 二级页面：商旅权益列表与离线小票入口
  public static renderLevel2(onOpenReceiptSimulator: () => void): HTMLElement {
    const container = document.createElement('div');
    container.className = 'sirc-view-container sirc-stagger';

    container.innerHTML = `
      <div class="sirc-callout is-warning">
        <span class="sirc-callout-icon">${Icons.crown(18)}</span>
        <div>
          <div class="sirc-callout-title">离线商旅尊享凭据</div>
          <div>断网或飞行模式下，向合作机场贵宾室或免税商户出示本离线卡片权益凭证即可核销。</div>
        </div>
      </div>

      <div class="sirc-section-label">
        <span>已生效权益</span>
        <span class="sirc-section-meta">2 ACTIVE BENEFITS</span>
      </div>

      <div class="sirc-group">
        <div class="sirc-list-row" style="cursor: default;">
          <span class="sirc-icon-well privilege">${Icons.plane(18)}</span>
          <span class="sirc-row-body">
            <span class="sirc-row-title">全球机场 CIP 快速安检通道</span>
            <span class="sirc-row-desc">北辰信用社 Visa Signature · 支持离线核销</span>
          </span>
          <span class="sirc-row-trailing">
            <span class="sirc-pill sirc-pill-success" style="padding: 3px 8px;">余 4 次</span>
          </span>
        </div>

        <div class="sirc-list-row" style="cursor: default;">
          <span class="sirc-icon-well currency">${Icons.lounge(18)}</span>
          <span class="sirc-row-body">
            <span class="sirc-row-title">国际机场贵宾室 LoungeKey</span>
            <span class="sirc-row-desc">港湾社区银行卡片 · 出示离线条码入座</span>
          </span>
          <span class="sirc-row-trailing">
            <span class="sirc-pill" style="padding: 3px 8px;">无限次</span>
          </span>
        </div>
      </div>

      <div class="sirc-panel" style="display: flex; flex-direction: column; gap: 12px;">
        <div style="display: flex; align-items: center; gap: 10px;">
          <span class="sirc-icon-well" style="width: 36px; height: 36px;">${Icons.receipt(18)}</span>
          <div>
            <div style="font-size: 15px; font-weight: 600; color: var(--sirc-ink);">离线消费交易签单</div>
            <div style="font-size: 12px; color: var(--sirc-muted);">机上或无网场所生成标准离线对账凭单</div>
          </div>
        </div>
        <button id="btn-open-receipt" class="sirc-ink-key" type="button" style="width: 100%;">
          <span>生成离线交易凭证小票</span>
          ${Icons.arrowRight(15)}
        </button>
      </div>
    `;

    container.querySelector('#btn-open-receipt')!.addEventListener('click', onOpenReceiptSimulator);

    return container;
  }

  // 三级页面：建筑感离线纸质消费签单
  public static renderLevel3(): HTMLElement {
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
          <div style="font-size: 17px; font-weight: 700; letter-spacing: -0.015em; color: var(--sirc-ink); margin-top: 4px;">SIRC 离线商旅消费签单</div>
          <div class="mono" style="font-size: 11.5px; color: var(--sirc-muted); margin-top: 4px;">#${voucherId}</div>
        </div>

        <div class="sirc-receipt-perf"></div>

        <div class="sirc-ledger">
          <div class="sirc-ledger-row">
            <span class="sirc-ledger-key">商户名称</span>
            <span class="sirc-ledger-val">国际航线机上免税品中心</span>
          </div>
          <div class="sirc-ledger-row">
            <span class="sirc-ledger-key">支付卡号</span>
            <span class="sirc-ledger-val mono">4929 •••• •••• 0042</span>
          </div>
          <div class="sirc-ledger-row">
            <span class="sirc-ledger-key">交易时间</span>
            <span class="sirc-ledger-val mono">${timestamp}</span>
          </div>
          <div class="sirc-ledger-row">
            <span class="sirc-ledger-key">授权状态</span>
            <span class="sirc-ledger-val" style="color: var(--sirc-success);">离线预授权 (Pre-Auth)</span>
          </div>
        </div>

        <div class="sirc-receipt-perf"></div>

        <div class="sirc-ledger-row" style="align-items: baseline;">
          <span style="font-size: 13.5px; font-weight: 600; color: var(--sirc-muted);">消费金额</span>
          <span class="tabular" style="font-size: 24px; font-weight: 700; letter-spacing: -0.025em; color: var(--sirc-ink);">$ 99.00 <span style="font-size: 12px; font-weight: 600; color: var(--sirc-muted);">USD</span></span>
        </div>

        <div class="sirc-barcode">
          <div class="sirc-barcode-bars" aria-hidden="true"></div>
          <span class="mono" style="font-size: 10px; letter-spacing: 0.14em; color: var(--sirc-light);">${voucherId} · VERIFIED</span>
        </div>
      </div>

      <div style="display: flex; gap: 10px;">
        <button id="btn-copy-voucher" class="sirc-ink-key" type="button" style="flex: 1;">
          ${Icons.copy(15)}
          <span>复制凭单编号</span>
        </button>
        <button id="btn-refresh-voucher" class="sirc-key" type="button" style="flex: 1;">
          ${Icons.refresh(15)}
          <span>重新生成</span>
        </button>
      </div>
    `;

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
