import { SircBridge } from '../bridge/sircBridge';

export interface CardItem {
  id: string;
  bankName: string;
  cardNumber: string;
  cardType: string;
  themeClass: string;
  hotline: string;
  owner: string;
}

export const sircCards: CardItem[] = [
  {
    id: 'card-001',
    bankName: '北辰信用社 (Northstar)',
    cardNumber: '4929 •••• •••• 0042',
    cardType: 'Visa Signature',
    themeClass: 'northstar',
    hotline: '400-820-0042',
    owner: 'ALEX MORGAN',
  },
  {
    id: 'card-002',
    bankName: '港湾社区银行 (Harbor)',
    cardNumber: '5264 •••• •••• 0187',
    cardType: 'Mastercard World',
    themeClass: 'harbor',
    hotline: '400-888-0187',
    owner: 'ALEX MORGAN',
  },
  {
    id: 'card-003',
    bankName: '雪松数字银行 (Cedar)',
    cardNumber: '4532 •••• •••• 2305',
    cardType: 'Visa Platinum',
    themeClass: 'cedar',
    hotline: '400-666-2305',
    owner: 'ALEX MORGAN',
  },
];

export class EmergencyView {
  // 渲染二级页面：卡片选择列表与离线救援指引
  public static renderLevel2(onSelectCard: (card: CardItem) => void): HTMLElement {
    const container = document.createElement('div');
    container.className = 'sirc-view-container';

    container.innerHTML = `
      <div class="sirc-card" style="margin-bottom: 14px; border-left: 4px solid var(--sirc-error);">
        <h3 style="font-size: 16px; margin-bottom: 4px; color: var(--sirc-error);">🚨 离线紧急卡片保护</h3>
        <p style="font-size: 13px; color: var(--sirc-muted);">
          手机处于无网络或境外断网状态时，可通过以下离线卡片凭证直接致电银行全球紧急挂失专线进行临时止付。
        </p>
      </div>
      <div style="font-size: 13px; font-weight: 700; color: var(--sirc-muted); margin-bottom: 10px;">
        已绑定离线安全保护卡片 (点击查看挂失详情与操作)
      </div>
      <div id="card-list-container" style="display: flex; flex-direction: column; gap: 12px;"></div>
    `;

    const listEl = container.querySelector('#card-list-container')!;
    sircCards.forEach((card) => {
      const cardEl = document.createElement('div');
      cardEl.className = `sirc-bank-card ${card.themeClass}`;
      cardEl.innerHTML = `
        <div class="sirc-card-header">
          <span class="sirc-card-bank-name">${card.bankName}</span>
          <span class="sirc-card-type-chip">${card.cardType}</span>
        </div>
        <div class="sirc-card-number">${card.cardNumber}</div>
        <div class="sirc-card-footer">
          <span>持卡人: ${card.owner}</span>
          <span>挂失专线: ${card.hotline}</span>
        </div>
      `;
      cardEl.onclick = () => onSelectCard(card);
      listEl.appendChild(cardEl);
    });

    return container;
  }

  // 渲染三级页面：具体某张卡的紧急挂失与终端操作
  public static renderLevel3(card: CardItem): HTMLElement {
    const container = document.createElement('div');
    container.className = 'sirc-view-container';

    container.innerHTML = `
      <div class="sirc-bank-card ${card.themeClass}" style="margin-bottom: 16px;">
        <div class="sirc-card-header">
          <span class="sirc-card-bank-name">${card.bankName}</span>
          <span class="sirc-card-type-chip">${card.cardType}</span>
        </div>
        <div class="sirc-card-number">${card.cardNumber}</div>
        <div class="sirc-card-footer">
          <span>持卡人: ${card.owner}</span>
          <span>卡片状态: 正常激活 (离线受控)</span>
        </div>
      </div>

      <div class="sirc-card" style="margin-bottom: 14px;">
        <h4 style="font-size: 15px; margin-bottom: 8px;">拨打离线紧急求助热线</h4>
        <p style="font-size: 13px; color: var(--sirc-muted); margin-bottom: 12px;">
          此银行 24 小时全球反欺诈及紧急止付中心，支持境外接听与主叫：
        </p>
        <div style="display: flex; gap: 10px; align-items: center;">
          <a href="tel:${card.hotline}" class="sirc-btn sirc-btn-danger" style="text-decoration:none; flex: 1;">
            📞 呼叫紧急专线 (${card.hotline})
          </a>
          <button id="btn-copy-hotline" class="sirc-btn sirc-btn-secondary" type="button">
            复制电话
          </button>
        </div>
      </div>

      <div class="sirc-card" style="margin-bottom: 14px;">
        <h4 style="font-size: 15px; margin-bottom: 8px;">一键复制应急报案模版</h4>
        <p style="font-size: 12px; color: var(--sirc-muted); margin-bottom: 10px;">
          如信号微弱无法通话，可复制下方信息发送短信至发卡行应急短信中心：
        </p>
        <pre style="background: var(--sirc-surface-hover); padding: 10px; border-radius: 8px; font-size: 12px; margin-bottom: 10px; overflow-x: auto; color: var(--sirc-ink);">
【紧急挂失】本人 ${card.owner}，卡号 ${card.cardNumber}，遭遇离线紧急情况申请临时止付，请立即协助核实！</pre>
        <button id="btn-copy-template" class="sirc-btn sirc-btn-primary" style="width: 100%;">
          📋 复制报案短信模版
        </button>
      </div>

      <div class="sirc-card">
        <h4 style="font-size: 14px; margin-bottom: 6px; color: var(--sirc-warning);">💡 境外离线安全小贴士</h4>
        <ul style="font-size: 12px; color: var(--sirc-muted); padding-left: 18px; line-height: 1.8;">
          <li>若在境外 POS 刷卡失败提示密码错误，境外 Visa/Mastercard 大多仅需签名或 4 位 PIN。</li>
          <li>切勿让卡片离开视线，谨防盗刷设备记录磁条与 CVV。</li>
        </ul>
      </div>
    `;

    container.querySelector('#btn-copy-hotline')!.addEventListener('click', () => {
      SircBridge.copyText(card.hotline, '已复制客服专线');
    });

    container.querySelector('#btn-copy-template')!.addEventListener('click', () => {
      const template = `【紧急挂失】本人 ${card.owner}，卡号 ${card.cardNumber}，遭遇离线紧急情况申请临时止付，请立即协助核实！`;
      SircBridge.copyText(template, '已复制应急报案短信模版');
    });

    return container;
  }
}
