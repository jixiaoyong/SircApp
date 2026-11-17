export interface MasterNavItem {
  id: string;
  title: string;
  desc: string;
  icon: string;
  iconClass: string;
}

export const masterNavItems: MasterNavItem[] = [
  {
    id: 'emergency',
    title: '紧急卡片与全球救援',
    desc: '3张离线安全卡片 · 全球24小时紧急挂失专线',
    icon: '🚨',
    iconClass: 'emergency',
  },
  {
    id: 'currency',
    title: '离线汇率与境外用卡',
    desc: '四大主流币种基准汇率 · DCC 刷卡避坑指南',
    icon: '📊',
    iconClass: 'currency',
  },
  {
    id: 'privilege',
    title: '尊享权益与离线小票',
    desc: '全球机场 CIP 贵宾厅 · 离线消费交易签单',
    icon: '👑',
    iconClass: 'privilege',
  },
];

export class MasterNavView {
  public static render(
    activeId: string,
    onSelect: (item: MasterNavItem) => void
  ): HTMLElement {
    const list = document.createElement('div');
    list.className = 'sirc-master-pane';

    // 状态概览卡片
    const banner = document.createElement('div');
    banner.className = 'sirc-card';
    banner.style.padding = '14px 16px';
    banner.innerHTML = `
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <span style="font-size: 13px; font-weight: 700; color: var(--sirc-ink);">随行离线防护模式</span>
        <span style="font-size: 11px; font-weight: 600; color: var(--sirc-success);">● 全功能就绪</span>
      </div>
      <div style="font-size: 11px; color: var(--sirc-muted); margin-top: 4px;">
        断网飞行或弱网环境下，均可本地流畅查验。
      </div>
    `;
    list.appendChild(banner);

    // 核心三大业务卡片
    masterNavItems.forEach((item) => {
      const card = document.createElement('div');
      card.className = `sirc-card sirc-nav-card ${activeId === item.id ? 'active' : ''}`;
      card.innerHTML = `
        <div class="sirc-nav-icon ${item.iconClass}">${item.icon}</div>
        <div class="sirc-nav-content">
          <div class="sirc-nav-title">${item.title}</div>
          <div class="sirc-nav-desc">${item.desc}</div>
        </div>
        <div class="sirc-nav-arrow">›</div>
      `;
      card.onclick = () => onSelect(item);
      list.appendChild(card);
    });

    return list;
  }
}
