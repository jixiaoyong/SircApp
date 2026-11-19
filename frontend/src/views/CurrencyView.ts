import { Icons } from '../utils/icons';
import { i18n } from '../i18n';

export interface CurrencyRate {
  code: string;
  name: string;
  symbol: string;
  unitLabel: string;
  rateToCny: number;
  unitDivisor: number;
}

export function getDefaultRates(): CurrencyRate[] {
  const isEn = i18n.lang === 'en';
  return [
    { code: 'USD', name: isEn ? 'US Dollar' : '美元', symbol: '$', unitLabel: '1 USD', rateToCny: 7.245, unitDivisor: 1 },
    { code: 'EUR', name: isEn ? 'Euro' : '欧元', symbol: '€', unitLabel: '1 EUR', rateToCny: 7.825, unitDivisor: 1 },
    { code: 'JPY', name: isEn ? 'Japanese Yen' : '日元', symbol: '¥', unitLabel: '100 JPY', rateToCny: 4.82, unitDivisor: 100 },
    { code: 'HKD', name: isEn ? 'HK Dollar' : '港币', symbol: 'HK$', unitLabel: '1 HKD', rateToCny: 0.928, unitDivisor: 1 },
  ];
}

export const defaultRates: CurrencyRate[] = getDefaultRates();

export class CurrencyView {
  // 二级页面：离线基准汇率总览与避坑指引
  public static renderLevel2(onOpenCalculator: (currencyCode?: string) => void): HTMLElement {
    const t = i18n.t;
    const rates = getDefaultRates();
    const container = document.createElement('div');
    container.className = 'sirc-view-container sirc-stagger';

    container.innerHTML = `
      <div class="sirc-section-label">
        <span>${t.currencySectionLabel}</span>
        <span class="sirc-section-meta">${t.currencySectionMeta}</span>
      </div>

      <div class="sirc-rate-grid" id="rate-grid">
        ${rates
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
              <div style="font-size: 15px; font-weight: 600; color: var(--sirc-ink);">${t.currencyCalculatorTitle}</div>
              <div style="font-size: 12px; color: var(--sirc-muted);">${t.currencyCalculatorSub}</div>
            </div>
          </div>
        </div>
        <button id="btn-open-calc" class="sirc-ink-key" type="button" style="width: 100%;">
          <span>${t.currencyCalculatorBtn}</span>
          ${Icons.arrowRight(15)}
        </button>
      </div>

      <div class="sirc-callout is-warning">
        <span class="sirc-callout-icon">${Icons.alert(18)}</span>
        <div>
          <div class="sirc-callout-title">${t.currencyDccTitle}</div>
          <div>${t.currencyDccDesc} <strong>${t.currencyDccItem1}</strong> ${t.currencyDccItem2}</div>
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
    const t = i18n.t;
    const rates = getDefaultRates();
    const container = document.createElement('div');
    container.className = 'sirc-view-container sirc-stagger';

    let currentCurrency = rates.find((r) => r.code === initialCode) || rates[0];
    let amount = currentCurrency.code === 'JPY' ? 10000 : 100;

    container.innerHTML = `
      <div class="sirc-panel" style="display: flex; flex-direction: column; gap: 14px;">
        <div style="display: flex; align-items: center; justify-content: space-between;">
          <span style="font-size: 15px; font-weight: 600; color: var(--sirc-ink);">${t.currencyCalcTitle}</span>
          <span id="calc-unit-rate" class="sirc-pill mono" style="font-size: 11px;"></span>
        </div>

        <div class="sirc-seg-tray" id="currency-seg-tray" role="tablist" aria-label="选择外币">
          ${rates
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
          <button type="button" class="sirc-preset-chip" data-amt="100">${t.currencyPreset100}</button>
          <button type="button" class="sirc-preset-chip" data-amt="500">${t.currencyPreset500}</button>
          <button type="button" class="sirc-preset-chip" data-amt="1000">${t.currencyPreset1000}</button>
          <button type="button" class="sirc-preset-chip" data-amt="5000">${t.currencyPreset2000}</button>
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
            <span class="sirc-well-sub">${t.currencyCalcUnit}</span>
          </div>
          <div id="output-cny" class="sirc-exchange-input" style="color: var(--sirc-accent);">¥ 724.50</div>
        </div>
      </div>

      <div class="sirc-callout is-danger">
        <span class="sirc-callout-icon">${Icons.alert(18)}</span>
        <div>
          <div class="sirc-callout-title">${t.currencyDccTitle}</div>
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
      lossEl.innerHTML = t.currencyDccLossText(minLoss, maxLoss);
    };

    segButtons.forEach((btn) => {
      btn.addEventListener('click', () => {
        const found = rates.find((r) => r.code === btn.dataset.code);
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
