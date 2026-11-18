// SircApp 与 H5 双向通信和生命周期桥接
import { Icons } from '../utils/icons';

export interface SircPresentationData {
  title?: string;
  description?: string;
  version?: string;
  lang?: string;
  dark?: boolean;
}

declare global {
  interface Window {
    sircPresentation?: (data: SircPresentationData) => void;
    __tryGoBack?: () => boolean;
    SircNativeBridge?: {
      postMessage: (message: string) => void;
    };
    AppClose?: {
      postMessage: (message: string) => void;
    };
    AppToRoute?: {
      postMessage: (message: string) => void;
    };
  }
}

export class SircBridge {
  private static toastTimer: number | null = null;

  public static init(onBackRequested: () => boolean) {
    // 1. 注册宿主展示契约 (window.sircPresentation)
    window.sircPresentation = (data: SircPresentationData) => {
      if (typeof data.dark === 'boolean') {
        document.body.classList.toggle('dark', data.dark);
      }
      if (data.lang) {
        document.documentElement.lang = data.lang;
      }
      if (data.title) {
        const titleEl = document.getElementById('sirc-page-title');
        if (titleEl && titleEl.dataset.allowHostTitle === 'true') {
          titleEl.textContent = data.title;
        }
      }
      if (data.version) {
        const verEl = document.getElementById('sirc-version-badge');
        if (verEl) verEl.textContent = `v${data.version}`;
      }
    };

    // 2. 注册返回键双向协商协议 (window.__tryGoBack)
    window.__tryGoBack = () => {
      return onBackRequested();
    };
  }

  // 通知原生宿主打开独立全屏页面
  public static openPage(view: string, title: string): boolean {
    if (window.SircNativeBridge && typeof window.SircNativeBridge.postMessage === 'function') {
      try {
        window.SircNativeBridge.postMessage(
          JSON.stringify({
            action: 'openPage',
            view: view,
            title: title,
          })
        );
        return true;
      } catch (e) {
        console.warn('Failed to call SircNativeBridge.postMessage', e);
      }
    }
    if (window.AppToRoute && typeof window.AppToRoute.postMessage === 'function') {
      try {
        window.AppToRoute.postMessage(
          JSON.stringify({
            path: '/payload-detail',
            params: { view, title },
          })
        );
        return true;
      } catch (e) {
        console.warn('Failed to call AppToRoute.postMessage', e);
      }
    }
    return false;
  }

  // 通知原生宿主关闭当前全屏页面
  public static closePage(): void {
    if (window.AppClose && typeof window.AppClose.postMessage === 'function') {
      window.AppClose.postMessage('');
      return;
    }
    if (window.SircNativeBridge && typeof window.SircNativeBridge.postMessage === 'function') {
      window.SircNativeBridge.postMessage(JSON.stringify({ action: 'close' }));
      return;
    }
  }

  // 精工悬浮胶囊 Toast（vibedesign.tips 016）
  public static showToast(message: string) {
    let toast = document.getElementById('sirc-toast');
    if (!toast) {
      toast = document.createElement('div');
      toast.id = 'sirc-toast';
      toast.className = 'sirc-toast';
      document.body.appendChild(toast);
    }
    toast.innerHTML = `${Icons.check(15)}<span>${message}</span>`;
    toast.classList.add('show');

    if (this.toastTimer) {
      window.clearTimeout(this.toastTimer);
    }
    this.toastTimer = window.setTimeout(() => {
      toast?.classList.remove('show');
    }, 2000);
  }

  // 复制文本到剪贴板
  public static async copyText(text: string, label: string = '已复制到剪贴板') {
    try {
      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(text);
      } else {
        const textarea = document.createElement('textarea');
        textarea.value = text;
        textarea.style.position = 'fixed';
        textarea.style.opacity = '0';
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
      }
      this.showToast(label);
    } catch {
      this.showToast(`复制失败: ${text}`);
    }
  }
}
