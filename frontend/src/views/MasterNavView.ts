import { Icons } from '../utils/icons';
import { i18n } from '../i18n';

export interface MasterNavItem {
  id: string;
  title: string;
  desc: string;
  tag: string;
  iconSvg: string;
  iconClass: string;
}

export function getMasterNavItems(): MasterNavItem[] {
  const t = i18n.t;
  return [
    {
      id: 'emergency',
      title: t.navEmergencyTitle,
      desc: t.navEmergencyDesc,
      tag: t.navEmergencyTag,
      iconSvg: Icons.shieldAlert(19),
      iconClass: 'emergency',
    },
    {
      id: 'currency',
      title: t.navCurrencyTitle,
      desc: t.navCurrencyDesc,
      tag: t.navCurrencyTag,
      iconSvg: Icons.currency(19),
      iconClass: 'currency',
    },
    {
      id: 'privilege',
      title: t.navPrivilegeTitle,
      desc: t.navPrivilegeDesc,
      tag: t.navPrivilegeTag,
      iconSvg: Icons.crown(19),
      iconClass: 'privilege',
    },
  ];
}

export class MasterNavView {
  public static render(
    activeId: string,
    onSelect: (item: MasterNavItem) => void
  ): HTMLElement {
    const t = i18n.t;
    const items = getMasterNavItems();
    const list = document.createElement('div');
    list.className = 'sirc-master-pane sirc-stagger';

    // 1. 架构感 Hero 遥测概览卡（对齐 SircApp WalletPanel + vibedesign.tips 竖线指标栏）
    const hero = document.createElement('section');
    hero.className = 'sirc-hero-panel';
    hero.innerHTML = `
      <div class="sirc-hero-top">
        <span class="sirc-hero-eyebrow">${t.heroEyebrow}<span id="sirc-version-badge">v1.0.0</span></span>
      </div>
      <h1 class="sirc-hero-title">${t.heroTitle}</h1>
      <p class="sirc-hero-desc">
        ${t.heroDesc}
      </p>
      <div class="sirc-telemetry-row">
        <div class="sirc-telemetry-item">
          <span class="sirc-telemetry-val">03</span>
          <span class="sirc-telemetry-label">${t.telemetryCards}</span>
        </div>
        <div class="sirc-telemetry-item">
          <span class="sirc-telemetry-val">04</span>
          <span class="sirc-telemetry-label">${t.telemetryCurrencies}</span>
        </div>
        <div class="sirc-telemetry-item">
          <span class="sirc-telemetry-val">24h</span>
          <span class="sirc-telemetry-label">${t.telemetryHotline}</span>
        </div>
      </div>
    `;
    list.appendChild(hero);

    // 2. 分组业务入口
    const serviceSection = document.createElement('section');
    serviceSection.style.display = 'flex';
    serviceSection.style.flexDirection = 'column';
    serviceSection.style.gap = '8px';

    const label = document.createElement('div');
    label.className = 'sirc-section-label';
    label.innerHTML = `
      <span>${t.sectionServices}</span>
      <span class="sirc-section-meta">${t.sectionServicesMeta}</span>
    `;
    serviceSection.appendChild(label);

    const group = document.createElement('div');
    group.className = 'sirc-group';

    items.forEach((item) => {
      const row = document.createElement('button');
      row.type = 'button';
      row.className = `sirc-list-row ${activeId === item.id ? 'active' : ''}`;
      row.innerHTML = `
        <span class="sirc-icon-well ${item.iconClass}">${item.iconSvg}</span>
        <span class="sirc-row-body">
          <span class="sirc-row-head">
            <span class="sirc-row-title">${item.title}</span>
            <span class="sirc-row-tag">${item.tag}</span>
          </span>
          <span class="sirc-row-desc">${item.desc}</span>
        </span>
        <span class="sirc-row-trailing">
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
      <span>${t.sectionGlance}</span>
      <span class="sirc-section-meta">${t.sectionGlanceMeta}</span>
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
      <div class="sirc-glance-sub">${t.glanceCurrencySub}</div>
    `;
    rateGlance.addEventListener('click', () => onSelect(items[1]));

    const emergencyGlance = document.createElement('button');
    emergencyGlance.type = 'button';
    emergencyGlance.className = 'sirc-glance-card';
    emergencyGlance.innerHTML = `
      <div class="sirc-glance-head">
        <span>${t.glanceEmergencyHead}</span>
        <span style="color: var(--sirc-error); display:inline-flex;">${Icons.phone(14)}</span>
      </div>
      <div class="sirc-glance-figure mono" style="font-size: 16px; padding-top: 3px;">400-820-0042</div>
      <div class="sirc-glance-sub">${t.glanceEmergencySub}</div>
    `;
    emergencyGlance.addEventListener('click', () => {
      window.location.href = 'tel:4008200042';
    });

    grid.appendChild(rateGlance);
    grid.appendChild(emergencyGlance);
    glanceSection.appendChild(grid);
    list.appendChild(glanceSection);

    return list;
  }
}
