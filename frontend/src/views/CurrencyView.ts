export interface CurrencyRate {
  code: string;
  name: string;
  symbol: string;
  rateToCny: number;
}

export const defaultRates: CurrencyRate[] = [
  { code: 'USD', name: '美元', symbol: '$', rateToCny: 7.245 },
  { code: 'EUR', name: '欧元', symbol: '€', rateToCny: 7.825 },
  { code: 'JPY', name: '日元 (100)', symbol: '¥', rateToCny: 4.82 },
  { code: 'HKD', name: '港币', symbol: 'HK$', rateToCny: 0.928 },
];

export class CurrencyView {
  // 渲染二级页面：汇率牌价总览与避坑指引
  public static renderLevel2(onOpenCalculator: () => void): HTMLElement {
    const container = document.createElement('div');
    container.className = 'sirc-view-container';

    container.innerHTML = `
      <div class="sirc-card" style="margin-bottom: 14px; border-left: 4px solid var(--sirc-accent);">
        <h3 style="font-size: 16px; margin-bottom: 4px; color: var(--sirc-accent);">📊 离线基准汇率参考</h3>
        <p style="font-size: 13px; color: var(--sirc-muted);">
          基于离线包同步时间缓存的基准外汇参考汇率，断网环境下依然可快速估算交易成本。
        </p>
      </div>

      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 10px; margin-bottom: 16px;">
        ${defaultRates
          .map(
            (r) => `
          <div class="sirc-card" style="padding: 12px; text-align: center;">
            <div style="font-size: 12px; color: var(--sirc-muted); font-weight: 600;">${r.name} (${r.code})</div>
            <div style="font-size: 18px; font-weight: 800; color: var(--sirc-ink); margin: 4px 0;">${r.rateToCny.toFixed(3)}</div>
            <div style="font-size: 11px; color: var(--sirc-success);">1 ${r.code} ≈ ${r.rateToCny} CNY</div>
          </div>
        `
          )
          .join('')}
      </div>

      <div class="sirc-card" style="margin-bottom: 16px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
          <h4 style="font-size: 15px; font-weight: 700;">🧮 交互式随身汇率换算</h4>
          <span style="font-size: 12px; color: var(--sirc-accent); font-weight: 600;">支持实时换算</span>
        </div>
        <p style="font-size: 13px; color: var(--sirc-muted); margin-bottom: 12px;">
          快速输入商品当地标价，实时折算人民币，并检测是否包含 DCC 汇率溢价。
        </p>
        <button id="btn-open-calc" class="sirc-btn sirc-btn-primary" style="width: 100%;">
          进入离线汇率换算器 →
        </button>
      </div>

      <div class="sirc-card" style="border-left: 4px solid var(--sirc-warning);">
        <h4 style="font-size: 14px; margin-bottom: 6px; color: var(--sirc-warning);">⚠️ 境外刷卡 DCC 避坑核心守则</h4>
        <p style="font-size: 12px; color: var(--sirc-muted); line-height: 1.7;">
          在境外 POS 机刷卡提示选择币种时，<strong>务必选择消费地当地货币（如美元/欧元/日元）结算</strong>！
          若选择人民币结算（DCC 动态货币转换），商户将按极差汇率加收 3%~8% 的二次转换手续费。
        </p>
      </div>
    `;

    container.querySelector('#btn-open-calc')!.addEventListener('click', onOpenCalculator);

    return container;
  }

  // 渲染三级页面：交互式离线换算器
  public static renderLevel3(): HTMLElement {
    const container = document.createElement('div');
    container.className = 'sirc-view-container';

    let currentCurrency = defaultRates[0];
    let amount = 100;

    container.innerHTML = `
      <div class="sirc-card sirc-exchange-card" style="margin-bottom: 16px;">
        <h3 style="font-size: 16px; font-weight: 700;">离线实时汇率换算</h3>
        
        <div class="sirc-exchange-row">
          <select id="select-currency" style="background:transparent; border:none; font-size:15px; font-weight:700; color:var(--sirc-ink); outline:none;">
            ${defaultRates.map((r) => `<option value="${r.code}">${r.name} (${r.code})</option>`).join('')}
          </select>
          <input id="input-foreign" class="sirc-exchange-input" type="number" value="100" />
        </div>

        <div style="text-align: center; color: var(--sirc-light); font-size: 18px;">⇅</div>

        <div class="sirc-exchange-row" style="background: var(--sirc-accent-soft);">
          <span class="sirc-exchange-currency" style="color: var(--sirc-accent);">人民币 (CNY)</span>
          <span id="output-cny" class="sirc-exchange-input" style="color: var(--sirc-accent);">¥ 724.50</span>
        </div>
      </div>

      <div class="sirc-card" id="dcc-warning-box" style="margin-bottom: 16px;">
        <div style="font-size: 14px; font-weight: 700; color: var(--sirc-error); margin-bottom: 6px;">
          🚨 DCC 汇率溢价预警
        </div>
        <div id="dcc-loss-text" style="font-size: 13px; color: var(--sirc-muted); line-height: 1.6;">
          若在刷卡机上误选了人民币计价，预计将被多扣除约 <strong>¥21.74 ~ ¥36.23</strong> 的隐形手续费！
        </div>
      </div>
    `;

    const selectEl = container.querySelector('#select-currency') as HTMLSelectElement;
    const inputEl = container.querySelector('#input-foreign') as HTMLInputElement;
    const outputEl = container.querySelector('#output-cny') as HTMLElement;
    const lossEl = container.querySelector('#dcc-loss-text') as HTMLElement;

    const updateCalc = () => {
      const selectedCode = selectEl.value;
      currentCurrency = defaultRates.find((r) => r.code === selectedCode) || defaultRates[0];
      const val = parseFloat(inputEl.value) || 0;
      amount = val;

      let cny = 0;
      if (currentCurrency.code === 'JPY') {
        cny = (amount / 100) * currentCurrency.rateToCny;
      } else {
        cny = amount * currentCurrency.rateToCny;
      }

      outputEl.textContent = `¥ ${cny.toFixed(2)}`;
      const minLoss = (cny * 0.03).toFixed(2);
      const maxLoss = (cny * 0.05).toFixed(2);
      lossEl.innerHTML = `若在刷卡机上误选了人民币计价，预计将被多扣除约 <strong>¥${minLoss} ~ ¥${maxLoss}</strong> (3%~5%) 的隐形手续费！建议明确告知收银员“Local Currency Only”。`;
    };

    selectEl.addEventListener('change', updateCalc);
    inputEl.addEventListener('input', updateCalc);

    return container;
  }
}
