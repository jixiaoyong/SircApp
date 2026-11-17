import './styles/theme.css';
import './styles/layout.css';
import './styles/components.css';

import { SircBridge } from './bridge/sircBridge';
import { MasterNavView, masterNavItems, MasterNavItem } from './views/MasterNavView';
import { EmergencyView, CardItem, sircCards } from './views/EmergencyView';
import { CurrencyView } from './views/CurrencyView';
import { PrivilegeView } from './views/PrivilegeView';

class SircCompanionApp {
  private activeCategory: string = 'emergency';
  private currentLevel: 1 | 2 | 3 = 1;
  private selectedCard: CardItem = sircCards[0];
  private isStandalone: boolean = false;

  private appEl!: HTMLElement;
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
      // 默认在宽屏模式下一并展示二级详情
      this.currentLevel = 2;
    } else {
      this.currentLevel = 1;
    }

    // 初始化返回键协议与宿主桥接
    SircBridge.init(() => this.handleBack());

    window.addEventListener('resize', () => {
      this.render();
    });

    this.render();
  }

  // 处理返回键协商 (__tryGoBack)
  public handleBack(): boolean {
    if (this.isStandalone) {
      // 全屏独立页面模式下：三级退回二级；二级退到底通知原生关闭页面
      if (this.currentLevel === 3) {
        this.currentLevel = 2;
        this.render();
        return true;
      }
      // 已在二级根部，返回 false 交由原生 Navigator.pop() 关闭全屏
      return false;
    }

    if (this.isWide()) {
      // 宽屏模式下：若右侧处于三级详情，后退至二级详情
      if (this.currentLevel === 3) {
        this.currentLevel = 2;
        this.render();
        return true;
      }
      // 右侧已在二级根部，允许 Flutter 退出
      return false;
    } else {
      // 窄屏模式下：逐级出栈
      if (this.currentLevel === 3) {
        this.currentLevel = 2;
        this.render();
        return true;
      }
      if (this.currentLevel === 2) {
        this.currentLevel = 1;
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
    this.render();
  }

  private selectCardDetail(card: CardItem) {
    this.selectedCard = card;
    this.currentLevel = 3;
    this.render();
  }

  private openCalculator() {
    this.currentLevel = 3;
    this.render();
  }

  private openReceipt() {
    this.currentLevel = 3;
    this.render();
  }

  // 渲染整体界面
  private render() {
    this.appEl.innerHTML = '';

    // 1. 顶部 Header
    if (this.isStandalone) {
      // 独立全屏模式：展示原生风格的沉浸式子页面顶栏，包含返回按键与当前模块标题
      const currentCatItem = masterNavItems.find((i) => i.id === this.activeCategory) || masterNavItems[0];
      const topBar = document.createElement('header');
      topBar.className = 'sirc-top-bar';
      topBar.innerHTML = `
        <div class="sirc-brand">
          <button class="sirc-back-btn" id="sirc-standalone-nav-back" style="margin-right: 8px;">
            ‹ 返回
          </button>
          <div class="sirc-title-text" id="sirc-page-title">${currentCatItem.title}</div>
          <span class="sirc-status-badge">
            <span class="sirc-status-dot"></span>
            <span>离线随行</span>
          </span>
        </div>
      `;
      this.appEl.appendChild(topBar);

      const navBackBtn = topBar.querySelector('#sirc-standalone-nav-back');
      if (navBackBtn) {
        navBackBtn.addEventListener('click', () => {
          if (!this.handleBack()) {
            SircBridge.closePage();
          }
        });
      }
    } else {
      const topBar = document.createElement('header');
      topBar.className = 'sirc-top-bar';
      topBar.innerHTML = `
        <div class="sirc-brand">
          <div class="sirc-logo-icon">S</div>
          <div class="sirc-title-text" id="sirc-page-title">Sirc 随行</div>
          <span class="sirc-status-badge">
            <span class="sirc-status-dot"></span>
            <span>离线可用</span>
          </span>
        </div>
        <div style="font-size: 12px; color: var(--sirc-light); font-weight: 600;" id="sirc-version-badge">
          v1.0.0
        </div>
      `;
      this.appEl.appendChild(topBar);
    }

    // 2. 容器
    const container = document.createElement('main');
    container.className = 'sirc-container';

    // 3. 左侧 Master 面板
    this.masterPaneEl = MasterNavView.render(this.activeCategory, (item) => {
      this.selectCategory(item);
    });

    // 4. 右侧 Detail 面板 (或窄屏推栈视图)
    this.detailPaneEl = document.createElement('div');
    this.detailPaneEl.className = 'sirc-detail-pane';
    this.renderDetailContent(this.detailPaneEl);

    // 独立全屏模式 / 窄屏与宽屏显隐规则
    if (this.isStandalone) {
      container.style.display = 'block';
      this.masterPaneEl.style.display = 'none';
      this.detailPaneEl.style.display = 'flex';
      this.detailPaneEl.style.width = '100%';
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
  }

  // 渲染详情区域内容（二级或三级）
  private renderDetailContent(pane: HTMLElement) {
    pane.innerHTML = '';

    // 面包屑 / 返回导航栏
    const breadcrumb = document.createElement('div');
    breadcrumb.className = 'sirc-breadcrumb-bar';

    const currentCatItem = masterNavItems.find((i) => i.id === this.activeCategory) || masterNavItems[0];

    let breadcrumbHtml = '';
    if (!this.isWide() && !this.isStandalone) {
      breadcrumbHtml += `
        <button class="sirc-back-btn" id="sirc-header-back-btn">
          ‹ 返回
        </button>
      `;
    }

    breadcrumbHtml += `<span class="sirc-breadcrumb-item" id="bc-home">随行中心</span>`;

    if (this.currentLevel >= 2) {
      breadcrumbHtml += `
        <span class="sirc-breadcrumb-separator">/</span>
        <span class="sirc-breadcrumb-item ${this.currentLevel === 2 ? 'sirc-breadcrumb-current' : ''}" id="bc-level2">
          ${currentCatItem.title}
        </span>
      `;
    }

    if (this.currentLevel === 3) {
      let subTitle = '详情操作';
      if (this.activeCategory === 'emergency') {
        subTitle = `${this.selectedCard.bankName} 紧急处置`;
      } else if (this.activeCategory === 'currency') {
        subTitle = '实时汇率换算';
      } else if (this.activeCategory === 'privilege') {
        subTitle = '离线交易签单';
      }
      breadcrumbHtml += `
        <span class="sirc-breadcrumb-separator">/</span>
        <span class="sirc-breadcrumb-current">${subTitle}</span>
      `;
    }

    breadcrumb.innerHTML = breadcrumbHtml;

    // 绑定返回与面包屑点击事件
    const backBtn = breadcrumb.querySelector('#sirc-header-back-btn');
    if (backBtn) {
      backBtn.addEventListener('click', () => {
        if (!this.handleBack()) {
          SircBridge.closePage();
        }
      });
    }

    const bcHome = breadcrumb.querySelector('#bc-home');
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

    const bcLevel2 = breadcrumb.querySelector('#bc-level2');
    if (bcLevel2 && this.currentLevel === 3) {
      bcLevel2.addEventListener('click', () => {
        this.currentLevel = 2;
        this.render();
      });
    }

    pane.appendChild(breadcrumb);

    // 详情内容窗格
    const contentBox = document.createElement('div');
    contentBox.style.display = 'flex';
    contentBox.style.flexDirection = 'column';
    contentBox.style.gap = '12px';

    if (this.activeCategory === 'emergency') {
      if (this.currentLevel === 2) {
        contentBox.appendChild(
          EmergencyView.renderLevel2((card) => this.selectCardDetail(card))
        );
      } else {
        contentBox.appendChild(EmergencyView.renderLevel3(this.selectedCard));
      }
    } else if (this.activeCategory === 'currency') {
      if (this.currentLevel === 2) {
        contentBox.appendChild(
          CurrencyView.renderLevel2(() => this.openCalculator())
        );
      } else {
        contentBox.appendChild(CurrencyView.renderLevel3());
      }
    } else if (this.activeCategory === 'privilege') {
      if (this.currentLevel === 2) {
        contentBox.appendChild(
          PrivilegeView.renderLevel2(() => this.openReceipt())
        );
      } else {
        contentBox.appendChild(PrivilegeView.renderLevel3());
      }
    }

    pane.appendChild(contentBox);
  }
}

// 页面加载即启动应用
window.addEventListener('DOMContentLoaded', () => {
  new SircCompanionApp();
});
