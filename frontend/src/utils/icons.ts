// 统一 1.65px 线宽几何矢量图标集（替代杂乱 Emoji，对齐 SircApp 与 vibedesign.tips 极简精工风格）

const svg = (paths: string, size = 20) =>
  `<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.65" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${paths}</svg>`;

export const Icons = {
  shield: (size = 20) =>
    svg('<path d="M12 3l7 3v5c0 5-3.2 8.7-7 10-3.8-1.3-7-5-7-10V6l7-3z"/><path d="M9.5 12.2l1.8 1.8 3.6-3.8"/>', size),
  shieldAlert: (size = 20) =>
    svg('<path d="M12 3l7 3v5c0 5-3.2 8.7-7 10-3.8-1.3-7-5-7-10V6l7-3z"/><path d="M12 8.5v4"/><circle cx="12" cy="15.8" r="0.6" fill="currentColor"/>', size),
  currency: (size = 20) =>
    svg('<circle cx="12" cy="12" r="9"/><path d="M9.5 9.5c0-1.2 1.1-2 2.5-2s2.5.8 2.5 2-1.1 2-2.5 2.3c-1.4.3-2.5 1-2.5 2.2s1.1 2 2.5 2 2.5-.8 2.5-2"/><path d="M12 6v1.5M12 16.5V18"/>', size),
  crown: (size = 20) =>
    svg('<path d="M4 17l1.5-9 4.5 4 2-6 2 6 4.5-4L20 17H4z"/><path d="M5 20h14"/>', size),
  chevronLeft: (size = 18) =>
    svg('<path d="M15 18l-6-6 6-6"/>', size),
  chevronRight: (size = 16) =>
    svg('<path d="M9 6l6 6-6 6"/>', size),
  arrowRight: (size = 16) =>
    svg('<path d="M5 12h14"/><path d="M13 6l6 6-6 6"/>', size),
  phone: (size = 17) =>
    svg('<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.8 19.8 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.8 19.8 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.36 1.9.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.91.34 1.85.57 2.81.7A2 2 0 0 1 22 16.92z"/>', size),
  copy: (size = 16) =>
    svg('<rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>', size),
  check: (size = 16) =>
    svg('<path d="M5 12.5l4.5 4.5L19 7.5"/>', size),
  plane: (size = 20) =>
    svg('<path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 0 0-3 0V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1 3.5 1v-1.5L13 19v-5.5l8 2.5z"/>', size),
  lounge: (size = 20) =>
    svg('<path d="M17 8h1a4 4 0 0 1 0 8h-1"/><path d="M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4V8z"/><path d="M6 2v3M10 2v3M14 2v3"/>', size),
  receipt: (size = 20) =>
    svg('<path d="M5 3v18l2.5-1.5L10 21l2-1.5L14 21l2.5-1.5L19 21V3l-2.5 1.5L14 3l-2 1.5L10 3 7.5 4.5 5 3z"/><path d="M8.5 9h7M8.5 13h5"/>', size),
  refresh: (size = 16) =>
    svg('<path d="M20 12a8 8 0 1 1-2.34-5.66L20 8.5"/><path d="M20 4v4.5h-4.5"/>', size),
  swap: (size = 16) =>
    svg('<path d="M7 16V4m0 0L3.5 7.5M7 4l3.5 3.5"/><path d="M17 8v12m0 0l3.5-3.5M17 20l-3.5-3.5"/>', size),
  alert: (size = 18) =>
    svg('<path d="M10.3 3.9L1.8 18.5A2 2 0 0 0 3.5 21.5h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/><path d="M12 9.5v4.5"/><circle cx="12" cy="17.2" r="0.6" fill="currentColor"/>', size),
  calculator: (size = 20) =>
    svg('<rect x="4" y="2.5" width="16" height="19" rx="3"/><path d="M8 7h8"/><path d="M8 12h.01M12 12h.01M16 12h.01M8 16h.01M12 16h.01M16 16h.01"/>', size),
  offline: (size = 16) =>
    svg('<path d="M2 8.82a15 15 0 0 1 20 0"/><path d="M5 12.86a10 10 0 0 1 14 0"/><path d="M8.5 16.43a5 5 0 0 1 7 0"/><circle cx="12" cy="20" r="1" fill="currentColor"/>', size),
};
