import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 跨平台风格隔离门面：将 Material 图标与 Cupertino 图标统一抽象，
/// 业务代码不再散乱 import cupertino 或直接硬编码平台图标，
/// 彻底解耦 Material 与 Cupertino 规范。
class AdaptiveIcons {
  AdaptiveIcons._();

  // 基础导航
  static const IconData back = Icons.arrow_back_ios_new;
  static const IconData forward = Icons.arrow_forward_ios;
  static const IconData close = Icons.close;
  static const IconData menu = Icons.menu;

  // 底部导航
  static const IconData home = Icons.home_outlined;
  static const IconData wallet = Icons.account_balance_wallet_outlined;
  static const IconData history = Icons.av_timer_outlined;
  static const IconData person = Icons.person_outline_outlined;

  // 功能与业务
  static const IconData add = Icons.add;
  static const IconData search = Icons.search;
  static const IconData settings = Icons.settings_outlined;
  static const IconData notifications = Icons.notifications_none;
  static const IconData lock = Icons.lock_outline;
  static const IconData visibility = Icons.visibility_outlined;
  static const IconData visibilityOff = Icons.visibility_off_outlined;
  static const IconData language = Icons.language;
  static const IconData info = Icons.info_outline;

  // 独立 Cupertino 图标出口（当需要纯 iOS 质感时统一由此调用）
  static const IconData cupertinoShare = CupertinoIcons.share;
  static const IconData cupertinoCreditCard = CupertinoIcons.creditcard;
  static const IconData cupertinoPerson = CupertinoIcons.person_crop_circle;
}
