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
    sircNativeBridgeCallback?: (res: {
      callbackId: string;
      success: boolean;
      data?: any;
      error?: string;
    }) => void;
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
  private static callbackSeq: number = 0;
  private static pendingCallbacks = new Map<
    string,
    { resolve: (val: any) => void; reject: (err: any) => void }
  >();

  public static init(onBackRequested: () => boolean) {
    // 0. 注册原生 RPC 异步回调接收器
    window.sircNativeBridgeCallback = (res) => {
      const handler = this.pendingCallbacks.get(res.callbackId);
      if (handler) {
        this.pendingCallbacks.delete(res.callbackId);
        if (res.success) {
          handler.resolve(res.data);
        } else {
          handler.reject(new Error(res.error || 'Native bridge call failed'));
        }
      }
    };
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

  // 实时同步 H5 内部是否可继续回退，供原生动态切换 iOS 侧滑返回 (PopScope.canPop)
  public static notifyNavigationState(canGoBack: boolean): void {
    if (window.SircNativeBridge && typeof window.SircNativeBridge.postMessage === 'function') {
      try {
        window.SircNativeBridge.postMessage(
          JSON.stringify({
            action: 'navigationState',
            canGoBack,
          })
        );
      } catch (e) {
        console.warn('Failed to notify navigationState', e);
      }
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

  // 通用原生 RPC 调用通道
  public static callNative<T = any>(action: string, payload: Record<string, any> = {}): Promise<T> {
    return new Promise((resolve, reject) => {
      if (!window.SircNativeBridge || typeof window.SircNativeBridge.postMessage !== 'function') {
        reject(new Error('当前环境不支持 SircNativeBridge 原生通信'));
        return;
      }
      const callbackId = `cb_${Date.now()}_${++this.callbackSeq}`;
      this.pendingCallbacks.set(callbackId, { resolve, reject });

      // 设置 30 秒超时清理
      window.setTimeout(() => {
        if (this.pendingCallbacks.has(callbackId)) {
          this.pendingCallbacks.delete(callbackId);
          reject(new Error('原生调用超时'));
        }
      }, 30000);

      try {
        window.SircNativeBridge.postMessage(
          JSON.stringify({
            action,
            callbackId,
            ...payload,
          })
        );
      } catch (e) {
        this.pendingCallbacks.delete(callbackId);
        reject(e);
      }
    });
  }

  // 拍照或相册选图
  public static async pickImage(source: 'camera' | 'gallery'): Promise<string> {
    const res = await this.callNative<{ dataUrl: string }>('pickImage', { source });
    return res.dataUrl;
  }

  // 开始录音
  public static async startRecord(): Promise<void> {
    await this.callNative('startRecord');
  }

  // 结束录音
  public static async stopRecord(): Promise<{ dataUrl: string; path: string }> {
    return await this.callNative<{ dataUrl: string; path: string }>('stopRecord');
  }

  // 播放音频
  public static async playAudio(params: { dataUrl?: string; path?: string }): Promise<void> {
    await this.callNative('playAudio', params);
  }

  // 停止播放音频
  public static async stopAudio(): Promise<void> {
    await this.callNative('stopAudio');
  }

  // 触发原生触觉震动
  public static async haptic(type: 'light' | 'medium' | 'heavy' = 'light'): Promise<void> {
    try {
      await this.callNative('haptic', { type });
    } catch (_) {
      // 容错降级
    }
  }
}
