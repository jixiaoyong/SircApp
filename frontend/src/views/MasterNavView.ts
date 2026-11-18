import { Icons } from '../utils/icons';

export interface MasterNavItem {
  id: string;
  title: string;
  desc: string;
  tag: string;
  iconSvg: string;
  iconClass: string;
}

export const masterNavItems: MasterNavItem[] = [
  {
    id: 'emergency',
    title: '紧急卡片与全球救援',
    desc: '离线卡片凭据与 24 小时挂失专线',
    tag: '3 张卡',
    iconSvg: Icons.shieldAlert(19),
    iconClass: 'emergency',
  },
  {
    id: 'currency',
    title: '离线汇率与境外用卡',
    desc: '四大主流币种实时折算与 DCC 避坑',
    tag: '7.245',
    iconSvg: Icons.currency(19),
    iconClass: 'currency',
  },
  {
    id: 'privilege',
    title: '尊享权益与离线签单',
    desc: '全球机场 CIP 贵宾厅与交易凭单',
    tag: 'CIP',
    iconSvg: Icons.crown(19),
    iconClass: 'privilege',
  },
];

export class MasterNavView {
  public static render(
    activeId: string,
    onSelect: (item: MasterNavItem) => void
  ): HTMLElement {
    const list = document.createElement('div');
    list.className = 'sirc-master-pane sirc-stagger';

    // 1. 架构感 Hero 遥测概览卡（对齐 SircApp WalletPanel + vibedesign.tips 竖线指标栏）
    const hero = document.createElement('section');
    hero.className = 'sirc-hero-panel';
    hero.innerHTML = `
      <div class="sirc-hero-top">
        <span class="sirc-hero-eyebrow">SIRC COMPANION · <span id="sirc-version-badge">v1.0.0</span></span>
        <span class="sirc-pill sirc-pill-success">
          <span class="sirc-status-dot"></span>
          <span>离线就绪</span>
        </span>
      </div>
      <h1 class="sirc-hero-title">随行离线中心</h1>
      <p class="sirc-hero-desc">
        断网飞行或境外弱网状态下，银行卡应急挂失、基准汇率折算与商旅凭证均支持本地零延迟查验。
      </p>
      <div class="sirc-telemetry-row">
        <div class="sirc-telemetry-item">
          <span class="sirc-telemetry-val">03</span>
          <span class="sirc-telemetry-label">受保护卡片</span>
        </div>
        <div class="sirc-telemetry-item">
          <span class="sirc-telemetry-val">04</span>
          <span class="sirc-telemetry-label">离线基准币种</span>
        </div>
        <div class="sirc-telemetry-item">
          <span class="sirc-telemetry-val">24h</span>
          <span class="sirc-telemetry-label">全球紧急专线</span>
        </div>
      </div>
    `;
    list.appendChild(hero);

    // 2. 分组业务入口（对齐 SircApp MenuPage 分组列表样式）
    const serviceSection = document.createElement('section');
    serviceSection.style.display = 'flex';
    serviceSection.style.flexDirection = 'column';
    serviceSection.style.gap = '8px';

    const label = document.createElement('div');
    label.className = 'sirc-section-label';
    label.innerHTML = `
      <span>核心随行服务</span>
      <span class="sirc-section-meta">LOCAL VAULT</span>
    `;
    serviceSection.appendChild(label);

    const group = document.createElement('div');
    group.className = 'sirc-group';

    masterNavItems.forEach((item) => {
      const row = document.createElement('button');
      row.type = 'button';
      row.className = `sirc-list-row ${activeId === item.id ? 'active' : ''}`;
      row.innerHTML = `
        <span class="sirc-icon-well ${item.iconClass}">${item.iconSvg}</span>
        <span class="sirc-row-body">
          <span class="sirc-row-head">
            <span class="sirc-row-title">${item.title}</span>
          </span>
          <span class="sirc-row-desc">${item.desc}</span>
        </span>
        <span class="sirc-row-trailing">
          <span class="sirc-row-tag">${item.tag}</span>
          ${Icons.chevronRight(16)}
        </span>
      `;
      row.addEventListener('click', () => onSelect(item));
      group.appendChild(row);
    });

    serviceSection.appendChild(group);
    list.appendChild(serviceSection);

    // 3. 快捷双格离线速览卡
    const glanceSection = document.createElement('section');
    glanceSection.style.display = 'flex';
    glanceSection.style.flexDirection = 'column';
    glanceSection.style.gap = '8px';

    const glanceLabel = document.createElement('div');
    glanceLabel.className = 'sirc-section-label';
    glanceLabel.innerHTML = `
      <span>高频离线速览</span>
      <span class="sirc-section-meta">TAP TO OPEN</span>
    `;
    glanceSection.appendChild(glanceLabel);

    const grid = document.createElement('div');
    grid.className = 'sirc-glance-grid';

    const rateGlance = document.createElement('button');
    rateGlance.type = 'button';
    rateGlance.className = 'sirc-glance-card';
    rateGlance.innerHTML = `
      <div class="sirc-glance-head">
        <span>USD / CNY</span>
        <span style="color: var(--sirc-accent); display:inline-flex;">${Icons.currency(15)}</span>
      </div>
      <div class="sirc-glance-figure">7.245</div>
      <div class="sirc-glance-sub">打开汇率与 DCC 换算</div>
    `;
    rateGlance.addEventListener('click', () => onSelect(masterNavItems[1]));

    const emergencyGlance = document.createElement('button');
    emergencyGlance.type = 'button';
    emergencyGlance.className = 'sirc-glance-card';
    emergencyGlance.innerHTML = `
      <div class="sirc-glance-head">
        <span>挂失直拨</span>
        <span style="color: var(--sirc-error); display:inline-flex;">${Icons.phone(14)}</span>
      </div>
      <div class="sirc-glance-figure mono" style="font-size: 16px; padding-top: 3px;">400-820-0042</div>
      <div class="sirc-glance-sub">北辰信用社 · 尾号 0042</div>
    `;
    emergencyGlance.addEventListener('click', () => onSelect(masterNavItems[0]));

    grid.appendChild(rateGlance);
    grid.appendChild(emergencyGlance);
    glanceSection.appendChild(grid);
    list.appendChild(glanceSection);

    return list;
  }
}
