import 'dart:async';

import 'package:flutter/material.dart';
import 'package:clock_app/app/data/data.dart';
import 'package:clock_app/app/data/enums.dart';
import 'package:clock_app/app/data/models/menu_info.dart';
import 'package:clock_app/app/data/theme_data.dart';
import 'package:clock_app/app/modules/views/alarm_page.dart';
import 'package:clock_app/app/modules/views/clock_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const countDownDuration = Duration(minutes: 10);
  bool isCountdown = true;
  Duration duration = const Duration();
  Timer? timer;
  @override
  void initState() {
    super.initState();

    reset();
  }

  void reset() {
    if (isCountdown) {
      setState(() => duration = countDownDuration);
    }
    setState(() => duration = const Duration());
  }

  void addTime() {
    final addSeconds = isCountdown ? -1 : 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;

      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  void startTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    setState(() => timer?.cancel());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: menuItems
                .map((currentMenuInfo) => buildMenuButton(currentMenuInfo))
                .toList(),
          ),
          VerticalDivider(
            color: CustomColors.dividerColor,
            width: 1,
          ),
          Expanded(
            child: Consumer<MenuInfo>(
              builder: (BuildContext context, MenuInfo value, Widget? child) {
                if (value.menuType == MenuType.clock) {
                  return const ClockPage();
                } else if (value.menuType == MenuType.alarm) {
                  return const AlarmPage();
                } else {
                  return buildTime();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTimeCard(time: hours, header: 'HOUR'),
            const SizedBox(
              width: 8,
            ),
            buildTimeCard(time: minutes, header: 'MINUTES'),
            const SizedBox(
              width: 8,
            ),
            buildTimeCard(time: seconds, header: 'SECONDS'),
          ],
        ),
        buildButton()
      ],
    );
  }

  Widget buildButton() {
    final isRunning = timer == null ? false : timer!.isActive;
    final isCompleted = duration.inSeconds == 0;
    if (isRunning || !isCompleted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              if (isRunning) {
                stopTimer(resets: false);
              } else {
                startTimer(resets: false);
              }
            },
            child: FittedBox(child: Text(isRunning ? "Stop" : "Resume")),
          ),
          const SizedBox(
            width: 12,
          ),
          ElevatedButton(
            onPressed: stopTimer,
            child: const FittedBox(
              child: Text('CANCEL'),
            ),
          ),
        ],
      );
    } else {
      return ElevatedButton(
          onPressed: () {
            startTimer();
          },
          child: const FittedBox(
            child: Text('Start Timer!'),
          ));
    }
  }

  Widget buildTimeCard({required String time, required String header}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFF242634),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                time,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 72),
              )),
          const SizedBox(
            height: 24,
          ),
          Text(header)
        ],
      );

  Widget buildMenuButton(MenuInfo currentMenuInfo) {
    return Consumer<MenuInfo>(
      builder: (BuildContext context, MenuInfo value, Widget? child) {
        return MaterialButton(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topRight: Radius.circular(32))),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
          color: currentMenuInfo.menuType == value.menuType
              ? CustomColors.menuBackgroundColor
              : CustomColors.pageBackgroundColor,
          onPressed: () {
            var menuInfo = Provider.of<MenuInfo>(context, listen: false);
            menuInfo.updateMenu(currentMenuInfo);
          },
          child: Column(
            children: <Widget>[
              Image.asset(
                currentMenuInfo.imageSource!,
                scale: 1.5,
              ),
              const SizedBox(height: 16),
              Text(
                currentMenuInfo.title ?? '',
                style: TextStyle(
                    fontFamily: 'avenir',
                    color: CustomColors.primaryTextColor,
                    fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}
