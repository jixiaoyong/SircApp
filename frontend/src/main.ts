import './styles/theme.css';
import './styles/layout.css';
import './styles/components.css';

import { SircBridge } from './bridge/sircBridge';
import { Icons } from './utils/icons';
import { MasterNavView, masterNavItems, MasterNavItem } from './views/MasterNavView';
import { EmergencyView, CardItem, sircCards } from './views/EmergencyView';
import { CurrencyView } from './views/CurrencyView';
import { PrivilegeView } from './views/PrivilegeView';

class SircCompanionApp {
  private activeCategory: string = 'emergency';
  private currentLevel: 1 | 2 | 3 = 1;
  private selectedCard: CardItem = sircCards[0];
  private selectedCurrencyCode: string = 'USD';
  private isStandalone: boolean = false;

  private appEl!: HTMLElement;
  private topBarEl: HTMLElement | null = null;
  private masterPaneEl!: HTMLElement;
  private detailPaneEl!: HTMLElement;

  constructor() {
    this.init();
  }

  private isWide(): boolean {
    return window.innerWidth >= 768;
  }

  private init() {
    this.appEl = document.getElementById('app')!;

    // 同步系统暗色偏好作为首屏默认值（宿主 sircPresentation 回调后精确覆盖）
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      document.body.classList.add('dark');
    }

    // 解析 URL 参数：是否为独立全屏子页面模式以及指定展示的 view
    const urlParams = new URLSearchParams(window.location.search);
    const hash = window.location.hash.replace(/^#\/?/, '');
    const mode = urlParams.get('mode');
    const viewParam = urlParams.get('view') || hash;

    if (mode === 'standalone' || (viewParam && viewParam !== 'root')) {
      this.isStandalone = true;
      if (viewParam && ['emergency', 'currency', 'privilege'].includes(viewParam)) {
        this.activeCategory = viewParam;
      }
      this.currentLevel = 2;
    } else if (this.isWide()) {
      this.currentLevel = 2;
    } else {
      this.currentLevel = 1;
    }

    // 初始化返回键协议与宿主桥接
    SircBridge.init(() => this.handleBack());

    window.addEventListener('resize', () => {
      this.render();
    });

    // vibedesign.tips 风格：仅在滚动离开顶部时浮现 1px 细分割线
    window.addEventListener(
      'scroll',
      () => {
        if (this.topBarEl) {
          this.topBarEl.classList.toggle('is-stuck', window.scrollY > 4);
        }
      },
      { passive: true }
    );

    this.render();
  }

  // 处理返回键协商 (__tryGoBack)
  public handleBack(): boolean {
    if (this.isStandalone) {
      if (this.currentLevel === 3) {
        this.currentLevel = 2;
        window.scrollTo({ top: 0 });
        this.render();
        return true;
      }
      return false;
    }

    if (this.isWide()) {
      if (this.currentLevel === 3) {
        this.currentLevel = 2;
        this.render();
        return true;
      }
      return false;
    } else {
      if (this.currentLevel === 3) {
        this.currentLevel = 2;
        window.scrollTo({ top: 0 });
        this.render();
        return true;
      }
      if (this.currentLevel === 2) {
        this.currentLevel = 1;
        window.scrollTo({ top: 0 });
        this.render();
        return true;
      }
      return false;
    }
  }

  // 导航切换
  private selectCategory(item: MasterNavItem) {
    this.activeCategory = item.id;

    // 窄屏且在 Tab 主面板中：通过 JSBridge 请求原生推入独立全屏子页面
    if (!this.isWide() && !this.isStandalone) {
      const opened = SircBridge.openPage(item.id, item.title);
      if (opened) {
        return;
      }
    }

    this.currentLevel = 2;
    window.scrollTo({ top: 0 });
    this.render();
  }

  private selectCardDetail(card: CardItem) {
    this.selectedCard = card;
    this.currentLevel = 3;
    window.scrollTo({ top: 0 });
    this.render();
  }

  private openCalculator(currencyCode?: string) {
    if (currencyCode) {
      this.selectedCurrencyCode = currencyCode;
    }
    this.currentLevel = 3;
    window.scrollTo({ top: 0 });
    this.render();
  }

  private openReceipt() {
    this.currentLevel = 3;
    window.scrollTo({ top: 0 });
    this.render();
  }

  private getLevel3Title(): string {
    if (this.activeCategory === 'emergency') {
      return `${this.selectedCard.bankName} · 紧急处置`;
    }
    if (this.activeCategory === 'currency') {
      return '离线汇率换算';
    }
    return '离线消费签单';
  }

  // 渲染整体界面
  private render() {
    this.appEl.innerHTML = '';
    this.topBarEl = null;

    const currentCatItem = masterNavItems.find((i) => i.id === this.activeCategory) || masterNavItems[0];

    // 1. 顶部 Header（窄屏 Tab 首页由原生 AppBar 承载，避免双重顶栏！）
    if (this.isStandalone) {
      const topBar = document.createElement('header');
      topBar.className = 'sirc-top-bar';
      const titleText = this.currentLevel === 3 ? this.getLevel3Title() : currentCatItem.title;

      topBar.innerHTML = `
        <div class="sirc-top-left">
          <button class="sirc-native-back-btn" id="sirc-standalone-nav-back" type="button" aria-label="返回">
            ${Icons.arrowBack(24)}
          </button>
          <div class="sirc-title-text" id="sirc-page-title" data-allow-host-title="false">${titleText}</div>
        </div>
        <span class="sirc-pill sirc-pill-success">
          <span class="sirc-status-dot"></span>
          <span>离线</span>
        </span>
      `;
      this.appEl.appendChild(topBar);
      this.topBarEl = topBar;

      const navBackBtn = topBar.querySelector('#sirc-standalone-nav-back');
      if (navBackBtn) {
        navBackBtn.addEventListener('click', () => {
          if (!this.handleBack()) {
            SircBridge.closePage();
          }
        });
      }
    } else if (this.isWide()) {
      const topBar = document.createElement('header');
      topBar.className = 'sirc-top-bar';
      topBar.innerHTML = `
        <div class="sirc-wide-brand">
          <span class="sirc-logo-mark">S</span>
          <span class="sirc-title-text" id="sirc-page-title" data-allow-host-title="false">Sirc 随行中心</span>
        </div>
        <span class="sirc-pill sirc-pill-success">
          <span class="sirc-status-dot"></span>
          <span>离线可用</span>
        </span>
      `;
      this.appEl.appendChild(topBar);
      this.topBarEl = topBar;
    }

    // 2. 容器
    const container = document.createElement('main');
    container.className = `sirc-container ${this.isStandalone ? 'is-standalone' : ''}`;

    // 3. 左侧 Master 面板
    this.masterPaneEl = MasterNavView.render(this.activeCategory, (item) => {
      this.selectCategory(item);
    });

    // 4. 右侧 Detail 面板
    this.detailPaneEl = document.createElement('div');
    this.detailPaneEl.className = 'sirc-detail-pane';
    this.renderDetailContent(this.detailPaneEl);

    // 显隐规则
    if (this.isStandalone) {
      this.masterPaneEl.style.display = 'none';
      this.detailPaneEl.style.display = 'flex';
    } else if (!this.isWide()) {
      if (this.currentLevel === 1) {
        this.masterPaneEl.style.display = 'flex';
        this.detailPaneEl.style.display = 'none';
      } else {
        this.masterPaneEl.style.display = 'none';
        this.detailPaneEl.style.display = 'flex';
      }
    } else {
      this.masterPaneEl.style.display = 'flex';
      this.detailPaneEl.style.display = 'flex';
    }

    container.appendChild(this.masterPaneEl);
    container.appendChild(this.detailPaneEl);
    this.appEl.appendChild(container);

    // 独立全屏模式下，实时同步是否可内部回退给原生宿主（驱动 iOS 原生跟手侧滑返回）
    if (this.isStandalone) {
      SircBridge.notifyNavigationState(this.currentLevel > 2);
    }
  }

  // 渲染详情区域内容（二级或三级）
  private renderDetailContent(pane: HTMLElement) {
    pane.innerHTML = '';

    const currentCatItem = masterNavItems.find((i) => i.id === this.activeCategory) || masterNavItems[0];

    // 轻量面包屑：仅在宽屏模式，或独立全屏三级页时展示，避免与二级顶栏重复
    const shouldShowTrail = this.isWide() || (this.isStandalone && this.currentLevel === 3) || (!this.isWide() && !this.isStandalone);
    if (shouldShowTrail) {
      const trail = document.createElement('nav');
      trail.className = 'sirc-breadcrumb-trail';

      let html = '';
      if (!this.isWide() && !this.isStandalone) {
        html += `<button class="sirc-key sirc-key-nav" id="sirc-header-back-btn" type="button" style="margin-right: 4px;">${Icons.chevronLeft(15)}<span>返回</span></button>`;
      }
      html += `<span class="sirc-bc-link" id="bc-home">随行中心</span>`;
      if (this.currentLevel >= 2) {
        html += `
          <span class="sirc-bc-sep">/</span>
          <span class="${this.currentLevel === 2 ? 'sirc-bc-current' : 'sirc-bc-link'}" id="bc-level2">${currentCatItem.title}</span>
        `;
      }
      if (this.currentLevel === 3) {
        html += `
          <span class="sirc-bc-sep">/</span>
          <span class="sirc-bc-current">${this.getLevel3Title()}</span>
        `;
      }
      trail.innerHTML = html;

      const backBtn = trail.querySelector('#sirc-header-back-btn');
      if (backBtn) {
        backBtn.addEventListener('click', () => {
          if (!this.handleBack()) SircBridge.closePage();
        });
      }

      const bcHome = trail.querySelector('#bc-home');
      if (bcHome) {
        bcHome.addEventListener('click', () => {
          if (this.isStandalone) {
            SircBridge.closePage();
          } else {
            this.currentLevel = 1;
            this.render();
          }
        });
      }

      const bcLevel2 = trail.querySelector('#bc-level2');
      if (bcLevel2 && this.currentLevel === 3) {
        bcLevel2.addEventListener('click', () => {
          this.currentLevel = 2;
          window.scrollTo({ top: 0 });
          this.render();
        });
      }

      pane.appendChild(trail);
    }

    // 详情业务内容
    const contentBox = document.createElement('div');
    if (this.activeCategory === 'emergency') {
      contentBox.appendChild(
        this.currentLevel === 2
          ? EmergencyView.renderLevel2((card) => this.selectCardDetail(card))
          : EmergencyView.renderLevel3(this.selectedCard)
      );
    } else if (this.activeCategory === 'currency') {
      contentBox.appendChild(
        this.currentLevel === 2
          ? CurrencyView.renderLevel2((code) => this.openCalculator(code))
          : CurrencyView.renderLevel3(this.selectedCurrencyCode)
      );
    } else if (this.activeCategory === 'privilege') {
      contentBox.appendChild(
        this.currentLevel === 2
          ? PrivilegeView.renderLevel2(() => this.openReceipt())
          : PrivilegeView.renderLevel3()
      );
    }

    pane.appendChild(contentBox);
  }
}

window.addEventListener('DOMContentLoaded', () => {
  new SircCompanionApp();
});
