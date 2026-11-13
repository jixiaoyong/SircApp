import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/home_chart_data.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';
import 'package:sirc/widgets/line_graph.dart';
import 'package:sirc/widgets/title_text.dart';

/// Isolated period selection: never changes Wallet's filters or selected card.
class HomeTransactionChart extends ConsumerStatefulWidget {
  const HomeTransactionChart({super.key});
  @override
  ConsumerState<HomeTransactionChart> createState() =>
      _HomeTransactionChartState();
}

class _HomeTransactionChartState extends ConsumerState<HomeTransactionChart>
    with WidgetsBindingObserver {
  HomeChartPeriod period = HomeChartPeriod.week;
  Timer? midnight;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    scheduleMidnight();
  }

  void scheduleMidnight() {
    midnight?.cancel();
    final now = DateTime.now();
    midnight = Timer(
      DateTime(now.year, now.month, now.day + 1).difference(now),
      () {
        if (mounted) {
          setState(() {});
          scheduleMidnight();
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      scheduleMidnight();
    }
  }

  @override
  void dispose() {
    midnight?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final wallet = ref.watch(walletControllerProvider);
    final now = wallet.referenceDate ?? DateTime.now();
    final chart = HomeChartData.aggregate(
      wallet.allTransactions,
      period,
      now: now,
    );
    final lang = Languages.home;
    final months = [
      lang.january,
      lang.february,
      lang.march,
      lang.april,
      lang.may,
      lang.june,
      lang.july,
      lang.august,
      lang.september,
      lang.october,
      lang.november,
      lang.december,
    ];
    final weekdays = [
      lang.mon,
      lang.tues,
      lang.wed,
      lang.thur,
      lang.fri,
      lang.satu,
      lang.sun,
    ];
    final material = MaterialLocalizations.of(context);
    String date(DateTime value) => material.formatCompactDate(value);
    final monthly = period == HomeChartPeriod.month;
    final heading = monthly
        ? months[chart.days.first.date.month - 1]
        : lang.chartWeek;
    final range = monthly
        ? '${chart.days.first.date.year}'
        : '${date(chart.days.first.date)} – ${date(chart.days.last.date)}';
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final switcher = IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 144),
        child: NeutralSegments(
          labels: [lang.chartWeek, lang.chartMonth],
          selected: period.index,
          onSelected: (i) => setState(() => period = HomeChartPeriod.values[i]),
          keyPrefix: 'home-chart-period',
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
            if (constraints.maxWidth < 340 * scale) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleText(text: heading),
                  Align(alignment: Alignment.centerRight, child: switcher),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: TitleText(text: heading)),
                switcher,
              ],
            );
          },
        ),
        Text(range, style: TextStyle(color: muted, fontSize: 11)),
        const SizedBox(height: 6),
        Tooltip(
          message: lang.chartVolumeHint,
          child: Text(
            '${lang.chartVolume} (\$)',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ),
        if (wallet.isLoading)
          const LinearProgressIndicator(key: ValueKey('home-chart-loading')),
        if (wallet.errorMessage != null)
          Text(
            wallet.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (!wallet.isLoading && wallet.errorMessage == null) ...[
          SizedBox(
            height: 200 + (MediaQuery.textScalerOf(context).scale(12) - 12) * 3,
            width: double.infinity,
            child: LineGraph(
              key: ValueKey(period),
              monthly: monthly,
              axisLabel: lang.chartVolume,
              futureLabel: lang.chartFuture,
              data: [
                for (final day in chart.days)
                  ChartDataPoint(
                    monthly
                        ? '${day.date.day}'
                        : weekdays[day.date.weekday - 1],
                    '${date(day.date)} ${weekdays[day.date.weekday - 1]}${day.amount == null ? ' · ${lang.chartFuture}' : ''}',
                    day.amount,
                  ),
              ],
            ),
          ),
          if (chart.recordCount == 0)
            Text(
              lang.chartEmpty,
              key: const ValueKey('home-chart-empty'),
              style: TextStyle(color: muted, fontSize: 12),
            )
          else if (chart.days.every(
            (day) => day.amount == null || day.amount == 0,
          ))
            Text(lang.chartZero, style: TextStyle(color: muted, fontSize: 12)),
          if (chart.undatedCount > 0)
            Text(
              '${lang.chartUndated}: ${chart.undatedCount}',
              style: TextStyle(color: muted, fontSize: 11),
            ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}
