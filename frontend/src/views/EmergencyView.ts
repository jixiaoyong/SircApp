import { SircBridge } from '../bridge/sircBridge';
import { Icons } from '../utils/icons';

export interface CardItem {
  id: string;
  bankName: string;
  cardNumber: string;
  tail: string;
  cardType: string;
  themeClass: string;
  hotline: string;
  owner: string;
  expire: string;
}

export const sircCards: CardItem[] = [
  {
    id: 'card-001',
    bankName: '北辰信用社',
    cardNumber: '4929  ****  ****  0042',
    tail: '0042',
    cardType: 'Visa Signature',
    themeClass: 'northstar',
    hotline: '400-820-0042',
    owner: 'Alex Morgan',
    expire: '12/30',
  },
  {
    id: 'card-002',
    bankName: '港湾社区银行',
    cardNumber: '5264  ****  ****  0187',
    tail: '0187',
    cardType: 'Mastercard World',
    themeClass: 'harbor',
    hotline: '400-888-0187',
    owner: 'Alex Morgan',
    expire: '08/29',
  },
  {
    id: 'card-003',
    bankName: '雪松数字银行',
    cardNumber: '4532  ****  ****  2305',
    tail: '2305',
    cardType: 'Visa Platinum',
    themeClass: 'cedar',
    hotline: '400-666-2305',
    owner: 'Alex Morgan',
    expire: '05/31',
  },
];

function renderCardMarkup(card: CardItem, interactive: boolean): string {
  return `
    <div class="sirc-card-top">
      <span class="sirc-card-bank-name">${card.bankName}</span>
      <span class="sirc-card-tail">•• ${card.tail}</span>
    </div>
    <div class="sirc-card-mid">
      <div class="sirc-card-number">${card.cardNumber}</div>
      <div class="sirc-emv-chip" aria-hidden="true"></div>
    </div>
    <div class="sirc-card-divider"></div>
    <div class="sirc-card-bottom">
      <div class="sirc-card-field">
        <div class="sirc-card-field-label">持卡人</div>
        <div class="sirc-card-field-val">${card.owner}</div>
      </div>
      <div class="sirc-card-field">
        <div class="sirc-card-field-label">${interactive ? '24h 挂失专线' : '有效期'}</div>
        <div class="sirc-card-field-val mono">${interactive ? card.hotline : card.expire}</div>
      </div>
      <div class="sirc-card-brand">${card.cardType}</div>
    </div>
  `;
}

export class EmergencyView {
  // 二级页面：离线银行卡安全列表
  public static renderLevel2(onSelectCard: (card: CardItem) => void): HTMLElement {
    const container = document.createElement('div');
    container.className = 'sirc-view-container sirc-stagger';

    container.innerHTML = `
      <div class="sirc-callout is-danger">
        <span class="sirc-callout-icon">${Icons.shieldAlert(19)}</span>
        <div>
          <div class="sirc-callout-title">离线紧急止付保护</div>
          <div>无网络或境外断网环境下，点击下方已加密缓存的银行卡即可直接拨打 24 小时挂失专线或复制应急报案短信。</div>
        </div>
      </div>

      <div class="sirc-section-label">
        <span>已保护卡片</span>
        <span class="sirc-section-meta">3 CARDS · TAP FOR ACTION</span>
      </div>

      <div id="card-list-container" style="display: flex; flex-direction: column; gap: 12px;"></div>
    `;

    const listEl = container.querySelector('#card-list-container')!;
    sircCards.forEach((card) => {
      const cardEl = document.createElement('div');
      cardEl.className = `sirc-bank-card is-interactive ${card.themeClass}`;
      cardEl.innerHTML = renderCardMarkup(card, true);
      cardEl.addEventListener('click', () => onSelectCard(card));
      listEl.appendChild(cardEl);
    });

    return container;
  }

  // 三级页面：单卡紧急挂失操作终端
  public static renderLevel3(card: CardItem): HTMLElement {
    const container = document.createElement('div');
    container.className = 'sirc-view-container sirc-stagger';

    const smsTemplate = `【紧急挂失】本人 ${card.owner}，卡号 ${card.cardNumber.replace(/\s+/g, ' ')}，遭遇离线紧急情况申请临时止付，请立即协助核实。`;

    container.innerHTML = `
      <div class="sirc-bank-card ${card.themeClass}">
        ${renderCardMarkup(card, false)}
      </div>

      <div class="sirc-panel" style="display: flex; flex-direction: column; gap: 12px;">
        <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px;">
          <div>
            <div style="font-size: 15px; font-weight: 600; color: var(--sirc-ink);">24 小时紧急止付专线</div>
            <div style="font-size: 12.5px; color: var(--sirc-muted); margin-top: 2px;">支持境外主叫与全球反欺诈人工接听</div>
          </div>
          <span class="sirc-pill sirc-pill-success">
            <span class="sirc-status-dot"></span>
            <span>离线受控</span>
          </span>
        </div>

        <div style="display: flex; gap: 10px;">
          <a href="tel:${card.hotline}" class="sirc-danger-key" style="flex: 1;">
            ${Icons.phone(16)}
            <span class="mono">${card.hotline}</span>
          </a>
          <button id="btn-copy-hotline" class="sirc-key" type="button" style="flex-shrink: 0;">
            ${Icons.copy(15)}
            <span>复制</span>
          </button>
        </div>
      </div>

      <div class="sirc-panel" style="display: flex; flex-direction: column; gap: 10px;">
        <div style="font-size: 15px; font-weight: 600; color: var(--sirc-ink);">弱网短信报案模版</div>
        <div style="font-size: 12.5px; color: var(--sirc-muted);">信号微弱无法通话时，可一键复制并发送至发卡行应急短信中心。</div>
        <div class="sirc-sms-box">${smsTemplate}</div>
        <button id="btn-copy-template" class="sirc-ink-key" type="button" style="width: 100%;">
          ${Icons.copy(15)}
          <span>复制应急报案短信</span>
        </button>
      </div>

      <div class="sirc-panel" style="display: flex; flex-direction: column; gap: 10px;">
        <div style="font-size: 13.5px; font-weight: 600; color: var(--sirc-ink);">境外用卡安全提示</div>
        <div class="sirc-tip-list">
          <div class="sirc-tip-item">
            <span class="sirc-tip-index">01</span>
            <span>境外 POS 刷卡提示输入密码时，国际卡组织卡片通常仅需签名或 4 位 PIN，请勿重复尝试触发风控锁卡。</span>
          </div>
          <div class="sirc-tip-item">
            <span class="sirc-tip-index">02</span>
            <span>结账时请确保卡片始终在视线范围内，谨防非法读卡器侧录磁条信息与背面安全码。</span>
          </div>
        </div>
      </div>
    `;

    const copyPhoneBtn = container.querySelector('#btn-copy-hotline') as HTMLButtonElement;
    copyPhoneBtn.addEventListener('click', () => {
      SircBridge.copyText(card.hotline, '已复制挂失专线号码');
      copyPhoneBtn.innerHTML = `${Icons.check(15)}<span>已复制</span>`;
      window.setTimeout(() => {
        copyPhoneBtn.innerHTML = `${Icons.copy(15)}<span>复制</span>`;
      }, 1500);
    });

    const copyTplBtn = container.querySelector('#btn-copy-template') as HTMLButtonElement;
    copyTplBtn.addEventListener('click', () => {
      SircBridge.copyText(smsTemplate, '已复制应急报案短信模版');
      copyTplBtn.innerHTML = `${Icons.check(15)}<span>已复制到剪贴板</span>`;
      window.setTimeout(() => {
        copyTplBtn.innerHTML = `${Icons.copy(15)}<span>复制应急报案短信</span>`;
      }, 1500);
    });

    return container;
  }
}
