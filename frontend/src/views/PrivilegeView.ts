import { SircBridge } from '../bridge/sircBridge';

export class PrivilegeView {
  // 渲染二级页面：权益概览与小票生成入口
  public static renderLevel2(onOpenReceiptSimulator: () => void): HTMLElement {
    const container = document.createElement('div');
    container.className = 'sirc-view-container';

    container.innerHTML = `
      <div class="sirc-card" style="margin-bottom: 14px; border-left: 4px solid var(--sirc-warning);">
        <h3 style="font-size: 16px; margin-bottom: 4px; color: var(--sirc-warning);">👑 尊享离线商旅权益</h3>
        <p style="font-size: 13px; color: var(--sirc-muted);">
          断网或飞行模式下，出示本随行凭据可向合作机场贵宾室或商户享受尊享权益。
        </p>
      </div>

      <div style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 16px;">
        <div class="sirc-card" style="display: flex; gap: 12px; align-items: center;">
          <div style="font-size: 28px;">🛫</div>
          <div>
            <div style="font-size: 14px; font-weight: 700; color: var(--sirc-ink);">全球机场 CIP 快速安检通道</div>
            <div style="font-size: 12px; color: var(--sirc-muted);">支持北辰信用社 Visa Signature 卡，全年 4 次离线核销</div>
          </div>
        </div>

        <div class="sirc-card" style="display: flex; gap: 12px; align-items: center;">
          <div style="font-size: 28px;">☕</div>
          <div>
            <div style="font-size: 14px; font-weight: 700; color: var(--sirc-ink);">国际机场贵宾候机室 LoungeKey</div>
            <div style="font-size: 12px; color: var(--sirc-muted);">出示港湾社区银行卡片与离线条码即可入座</div>
          </div>
        </div>
      </div>

      <div class="sirc-card" style="margin-bottom: 14px;">
        <h4 style="font-size: 15px; margin-bottom: 8px;">🧾 离线消费交易凭证记录器</h4>
        <p style="font-size: 13px; color: var(--sirc-muted); margin-bottom: 12px;">
          在飞机或无信号场所消费时，可模拟生成标准离线交易小票，用于后续账单核对与报销。
        </p>
        <button id="btn-open-receipt" class="sirc-btn sirc-btn-primary" style="width: 100%;">
          生成离线交易凭证小票 →
        </button>
      </div>
    `;

    container.querySelector('#btn-open-receipt')!.addEventListener('click', onOpenReceiptSimulator);

    return container;
  }

  // 渲染三级页面：离线消费凭证小票生成器与展示
  public static renderLevel3(): HTMLElement {
    const container = document.createElement('div');
    container.className = 'sirc-view-container';

    const timestamp = new Date().toISOString().replace('T', ' ').slice(0, 19);
    const voucherId = `OFFLINE-${Math.floor(100000 + Math.random() * 900000)}`;

    container.innerHTML = `
      <div class="sirc-voucher-receipt" style="margin-bottom: 16px;">
        <div class="sirc-voucher-watermark">SIRC OFFLINE</div>
        
        <div style="text-align: center; border-bottom: 1px dashed var(--sirc-border); padding-bottom: 12px; margin-bottom: 12px;">
          <div style="font-size: 18px; font-weight: 800; letter-spacing: 1px;">SIRC 离线商旅消费签单</div>
          <div style="font-size: 11px; color: var(--sirc-muted); margin-top: 4px;">凭单编号: <span id="voucher-code">${voucherId}</span></div>
        </div>

        <div style="display: flex; flex-direction: column; gap: 8px; font-size: 13px;">
          <div style="display: flex; justify-content: space-between;">
            <span style="color: var(--sirc-muted);">商户名称</span>
            <span style="font-weight: 600;">国际航线机上免税品中心</span>
          </div>
          <div style="display: flex; justify-content: space-between;">
            <span style="color: var(--sirc-muted);">支付卡号</span>
            <span style="font-weight: 600; font-family: monospace;">4929 •••• •••• 0042</span>
          </div>
          <div style="display: flex; justify-content: space-between;">
            <span style="color: var(--sirc-muted);">交易时间</span>
            <span style="font-weight: 600;">${timestamp}</span>
          </div>
          <div style="display: flex; justify-content: space-between;">
            <span style="color: var(--sirc-muted);">交易类型</span>
            <span style="font-weight: 600; color: var(--sirc-success);">离线预授权 (Pre-Auth)</span>
          </div>
          <div style="display: flex; justify-content: space-between; border-top: 1px dashed var(--sirc-border); padding-top: 10px; margin-top: 6px;">
            <span style="font-size: 14px; font-weight: 700;">消费金额</span>
            <span style="font-size: 18px; font-weight: 800; color: var(--sirc-accent);">$ 99.00 USD</span>
          </div>
        </div>
      </div>

      <div style="display: flex; gap: 10px;">
        <button id="btn-copy-voucher" class="sirc-btn sirc-btn-primary" style="flex: 1;">
          📋 复制凭单编号
        </button>
        <button id="btn-refresh-voucher" class="sirc-btn sirc-btn-secondary" style="flex: 1;">
          🔄 重新生成小票
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
      SircBridge.showToast('已生成新流水凭证');
    });

    return container;
  }
}
