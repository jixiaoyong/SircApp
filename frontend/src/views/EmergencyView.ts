import { SircBridge } from '../bridge/sircBridge';
import { Icons } from '../utils/icons';
import { i18n } from '../i18n';

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

export function getSircCards(): CardItem[] {
  const isEn = i18n.lang === 'en';
  return [
    {
      id: 'card-001',
      bankName: isEn ? 'North Star CU' : '北辰信用社',
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
      bankName: isEn ? 'Harbor Community Bank' : '港湾社区银行',
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
      bankName: isEn ? 'Cedar Digital Bank' : '雪松数字银行',
      cardNumber: '4532  ****  ****  2305',
      tail: '2305',
      cardType: 'Visa Platinum',
      themeClass: 'cedar',
      hotline: '400-666-2305',
      owner: 'Alex Morgan',
      expire: '05/31',
    },
  ];
}

export const sircCards: CardItem[] = getSircCards();

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
    const t = i18n.t;
    const cards = getSircCards();
    const container = document.createElement('div');
    container.className = 'sirc-view-container sirc-stagger';

    container.innerHTML = `
      <div class="sirc-callout is-danger">
        <span class="sirc-callout-icon">${Icons.shieldAlert(19)}</span>
        <div>
          <div class="sirc-callout-title">${t.emergencyCalloutTitle}</div>
          <div>${t.emergencyCalloutDesc}</div>
        </div>
      </div>

      <div class="sirc-section-label">
        <span>${t.emergencySectionCards}</span>
        <span class="sirc-section-meta">${t.emergencySectionCardsMeta}</span>
      </div>

      <div id="card-list-container" style="display: flex; flex-direction: column; gap: 12px;"></div>
    `;

    const listEl = container.querySelector('#card-list-container')!;
    cards.forEach((card) => {
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
    const t = i18n.t;
    const container = document.createElement('div');
    container.className = 'sirc-view-container sirc-stagger';

    const smsTemplate = t.emergencySmsTemplate(card.owner, card.cardNumber.replace(/\s+/g, ' '));

    container.innerHTML = `
      <div class="sirc-bank-card ${card.themeClass}">
        ${renderCardMarkup(card, false)}
      </div>

      <div class="sirc-panel" style="display: flex; flex-direction: column; gap: 12px;">
        <div>
          <div style="font-size: 15px; font-weight: 600; color: var(--sirc-ink);">${t.emergencyHotlineTitle}</div>
          <div style="font-size: 12.5px; color: var(--sirc-muted); margin-top: 2px;">${t.emergencyHotlineSub}</div>
        </div>

        <div style="display: flex; gap: 10px;">
          <a href="tel:${card.hotline}" class="sirc-danger-key" style="flex: 1;">
            ${Icons.phone(16)}
            <span class="mono">${card.hotline}</span>
          </a>
          <button id="btn-copy-hotline" class="sirc-key" type="button" style="flex-shrink: 0;">
            ${Icons.copy(15)}
            <span>${t.copy}</span>
          </button>
        </div>
      </div>

      <div class="sirc-panel" style="display: flex; flex-direction: column; gap: 10px;">
        <div style="font-size: 15px; font-weight: 600; color: var(--sirc-ink);">${t.emergencySmsTitle}</div>
        <div style="font-size: 12.5px; color: var(--sirc-muted);">${t.emergencySmsSub}</div>
        <div class="sirc-sms-box">${smsTemplate}</div>
        <button id="btn-copy-template" class="sirc-ink-key" type="button" style="width: 100%;">
          ${Icons.copy(15)}
          <span>${t.emergencySmsCopyBtn}</span>
        </button>
      </div>

      <div class="sirc-panel" style="display: flex; flex-direction: column; gap: 10px;">
        <div style="font-size: 13.5px; font-weight: 600; color: var(--sirc-ink);">${t.emergencyTipsTitle}</div>
        <div class="sirc-tip-list">
          <div class="sirc-tip-item">
            <span class="sirc-tip-index">01</span>
            <span>${t.emergencyTip1}</span>
          </div>
          <div class="sirc-tip-item">
            <span class="sirc-tip-index">02</span>
            <span>${t.emergencyTip2}</span>
          </div>
        </div>
      </div>
    `;

    const copyPhoneBtn = container.querySelector('#btn-copy-hotline') as HTMLButtonElement;
    copyPhoneBtn.addEventListener('click', () => {
      SircBridge.copyText(card.hotline, t.emergencyPhoneCopiedToast);
      copyPhoneBtn.innerHTML = `${Icons.check(15)}<span>${t.copied}</span>`;
      window.setTimeout(() => {
        copyPhoneBtn.innerHTML = `${Icons.copy(15)}<span>${t.copy}</span>`;
      }, 1500);
    });

    const copyTplBtn = container.querySelector('#btn-copy-template') as HTMLButtonElement;
    copyTplBtn.addEventListener('click', () => {
      SircBridge.copyText(smsTemplate, t.emergencySmsCopiedToast);
      copyTplBtn.innerHTML = `${Icons.check(15)}<span>${t.copied}</span>`;
      window.setTimeout(() => {
        copyTplBtn.innerHTML = `${Icons.copy(15)}<span>${t.emergencySmsCopyBtn}</span>`;
      }, 1500);
    });

    return container;
  }
}
