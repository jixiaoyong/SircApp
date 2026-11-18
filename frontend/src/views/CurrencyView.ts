import { Icons } from '../utils/icons';

export interface CurrencyRate {
  code: string;
  name: string;
  symbol: string;
  unitLabel: string;
  rateToCny: number;
  unitDivisor: number;
}

export const defaultRates: CurrencyRate[] = [
  { code: 'USD', name: '美元', symbol: '$', unitLabel: '1 USD', rateToCny: 7.245, unitDivisor: 1 },
  { code: 'EUR', name: '欧元', symbol: '€', unitLabel: '1 EUR', rateToCny: 7.825, unitDivisor: 1 },
  { code: 'JPY', name: '日元', symbol: '¥', unitLabel: '100 JPY', rateToCny: 4.82, unitDivisor: 100 },
  { code: 'HKD', name: '港币', symbol: 'HK$', unitLabel: '1 HKD', rateToCny: 0.928, unitDivisor: 1 },
];

export class CurrencyView {
  // 二级页面：离线基准汇率总览与避坑指引
  public static renderLevel2(onOpenCalculator: (currencyCode?: string) => void): HTMLElement {
    const container = document.createElement('div');
    container.className = 'sirc-view-container sirc-stagger';

    container.innerHTML = `
      <div class="sirc-section-label">
        <span>离线基准汇率</span>
        <span class="sirc-section-meta">BASE CNY · TAP TO CONVERT</span>
      </div>

      <div class="sirc-rate-grid" id="rate-grid">
        ${defaultRates
          .map(
            (r) => `
          <button type="button" class="sirc-rate-tile" data-code="${r.code}">
            <div class="sirc-rate-tile-top">
              <span class="sirc-currency-code">${r.code}</span>
              <span class="sirc-currency-name">${r.name}</span>
            </div>
            <div class="sirc-rate-value">${r.rateToCny.toFixed(3)}</div>
            <div class="sirc-rate-sub">${r.unitLabel} ≈ ${r.rateToCny} CNY</div>
          </button>
        `
          )
          .join('')}
      </div>

      <div class="sirc-panel" style="display: flex; flex-direction: column; gap: 12px;">
        <div style="display: flex; align-items: center; justify-content: space-between; gap: 10px;">
          <div style="display: flex; align-items: center; gap: 10px;">
            <span class="sirc-icon-well currency" style="width: 36px; height: 36px;">${Icons.calculator(18)}</span>
            <div>
              <div style="font-size: 15px; font-weight: 600; color: var(--sirc-ink);">交互式随身汇率换算</div>
              <div style="font-size: 12px; color: var(--sirc-muted);">快速折算人民币并测算 DCC 隐形溢价</div>
            </div>
          </div>
        </div>
        <button id="btn-open-calc" class="sirc-ink-key" type="button" style="width: 100%;">
          <span>进入离线汇率换算器</span>
          ${Icons.arrowRight(15)}
        </button>
      </div>

      <div class="sirc-callout is-warning">
        <span class="sirc-callout-icon">${Icons.alert(18)}</span>
        <div>
          <div class="sirc-callout-title">境外刷卡 DCC 避坑守则</div>
          <div>境外 POS 机提示选择币种时，<strong>务必选择当地货币（如 USD / EUR / JPY）结算</strong>。若误选人民币结算（DCC 动态货币转换），商户通常加收 3%–8% 的隐形汇兑溢价。</div>
        </div>
      </div>
    `;

    container.querySelector('#btn-open-calc')!.addEventListener('click', () => onOpenCalculator());
    container.querySelectorAll<HTMLButtonElement>('.sirc-rate-tile').forEach((btn) => {
      btn.addEventListener('click', () => onOpenCalculator(btn.dataset.code));
    });

    return container;
  }

  // 三级页面：交互式离线换算器（物理分段键 + 零溢出凹槽输入框）
  public static renderLevel3(initialCode = 'USD'): HTMLElement {
    const container = document.createElement('div');
    container.className = 'sirc-view-container sirc-stagger';

    let currentCurrency = defaultRates.find((r) => r.code === initialCode) || defaultRates[0];
    let amount = currentCurrency.code === 'JPY' ? 10000 : 100;

    container.innerHTML = `
      <div class="sirc-panel" style="display: flex; flex-direction: column; gap: 14px;">
        <div style="display: flex; align-items: center; justify-content: space-between;">
          <span style="font-size: 15px; font-weight: 600; color: var(--sirc-ink);">离线实时换算</span>
          <span id="calc-unit-rate" class="sirc-pill mono" style="font-size: 11px;"></span>
        </div>

        <div class="sirc-seg-tray" id="currency-seg-tray" role="tablist" aria-label="选择外币">
          ${defaultRates
            .map(
              (r) => `
            <button type="button" class="sirc-seg-btn ${r.code === currentCurrency.code ? 'is-active' : ''}" data-code="${r.code}">
              ${r.code}
            </button>
          `
            )
            .join('')}
        </div>

        <div class="sirc-well">
          <div class="sirc-well-label">
            <span id="well-src-code" class="sirc-well-code">${currentCurrency.code}</span>
            <span id="well-src-name" class="sirc-well-sub">${currentCurrency.name} (${currentCurrency.symbol})</span>
          </div>
          <input id="input-foreign" class="sirc-exchange-input" type="number" inputmode="decimal" value="${amount}" />
        </div>

        <div class="sirc-preset-row" id="preset-row">
          <button type="button" class="sirc-preset-chip" data-amt="100">100</button>
          <button type="button" class="sirc-preset-chip" data-amt="500">500</button>
          <button type="button" class="sirc-preset-chip" data-amt="1000">1,000</button>
          <button type="button" class="sirc-preset-chip" data-amt="5000">5,000</button>
        </div>

        <div style="display: flex; align-items: center; justify-content: center; gap: 8px; color: var(--sirc-light); font-size: 11px;">
          <span style="flex: 1; height: 1px; background: var(--sirc-border-subtle);"></span>
          <span style="display: inline-flex; padding: 4px 8px; border-radius: 999px; background: var(--sirc-field); color: var(--sirc-muted);">
            ${Icons.swap(13)}
          </span>
          <span style="flex: 1; height: 1px; background: var(--sirc-border-subtle);"></span>
        </div>

        <div class="sirc-well is-result">
          <div class="sirc-well-label">
            <span class="sirc-well-code" style="color: var(--sirc-accent);">CNY</span>
            <span class="sirc-well-sub">人民币折算</span>
          </div>
          <div id="output-cny" class="sirc-exchange-input" style="color: var(--sirc-accent);">¥ 724.50</div>
        </div>
      </div>

      <div class="sirc-callout is-danger">
        <span class="sirc-callout-icon">${Icons.alert(18)}</span>
        <div>
          <div class="sirc-callout-title">DCC 汇率溢价测算（3% – 5%）</div>
          <div id="dcc-loss-text"></div>
        </div>
      </div>
    `;

    const segButtons = container.querySelectorAll<HTMLButtonElement>('.sirc-seg-btn');
    const inputEl = container.querySelector('#input-foreign') as HTMLInputElement;
    const srcCodeEl = container.querySelector('#well-src-code') as HTMLElement;
    const srcNameEl = container.querySelector('#well-src-name') as HTMLElement;
    const unitRateEl = container.querySelector('#calc-unit-rate') as HTMLElement;
    const outputEl = container.querySelector('#output-cny') as HTMLElement;
    const lossEl = container.querySelector('#dcc-loss-text') as HTMLElement;

    const updateCalc = () => {
      amount = Math.max(0, parseFloat(inputEl.value) || 0);
      const cny = (amount / currentCurrency.unitDivisor) * currentCurrency.rateToCny;

      srcCodeEl.textContent = currentCurrency.code;
      srcNameEl.textContent = `${currentCurrency.name} (${currentCurrency.symbol})`;
      unitRateEl.textContent = `${currentCurrency.unitLabel} = ¥${currentCurrency.rateToCny}`;
      outputEl.textContent = `¥ ${cny.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

      const minLoss = (cny * 0.03).toFixed(2);
      const maxLoss = (cny * 0.05).toFixed(2);
      lossEl.innerHTML = `若在刷卡机误选人民币计价，本笔消费预计多付 <strong class="tabular" style="color: var(--sirc-error);">¥${minLoss} – ¥${maxLoss}</strong> 隐形汇差。结账时请明确告知收银员 <strong>Local Currency Only</strong>。`;
    };

    segButtons.forEach((btn) => {
      btn.addEventListener('click', () => {
        const found = defaultRates.find((r) => r.code === btn.dataset.code);
        if (!found) return;
        currentCurrency = found;
        segButtons.forEach((b) => b.classList.toggle('is-active', b === btn));
        updateCalc();
      });
    });

    container.querySelectorAll<HTMLButtonElement>('.sirc-preset-chip').forEach((chip) => {
      chip.addEventListener('click', () => {
        inputEl.value = chip.dataset.amt || '100';
        updateCalc();
      });
    });

    inputEl.addEventListener('input', updateCalc);
    updateCalc();

    return container;
  }
}
