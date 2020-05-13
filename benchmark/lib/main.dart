import 'dart:convert';

import 'package:benchmark/hooks.dart';
import 'package:benchmark/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'benchmark.dart';

// TODO(3) UI
// 2. lock ui screen

// TODO(4) Pkg
// 1. upgrade to v4.1.0

void main() async {
  await _hydrate();
  runApp(App());
}

Future<void> _hydrate() async {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = await HydratedBlocDelegate.build();
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _theme(),
      home: _bloc(Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: _view(context),
          ),
        ),
      )),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _theme() {
    return ThemeData(
      brightness: Brightness.light,
      buttonTheme: ButtonThemeData(
        highlightColor: Colors.blue.withOpacity(0.2),
        splashColor: Colors.blue.withOpacity(0.5),
      ),
      textTheme: TextTheme(
        button: TextStyle(fontSize: 18),
        headline6: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _bloc(Widget child) {
    return BlocProvider<SettingsBloc>(
      create: (_) => SettingsBloc(),
      child: child,
    );
  }

  Widget _view(BuildContext context) {
    return HookBuilder(
      builder: (context) {
        final controller = useScrollController(initialScrollOffset: 400);
        final results = useState(<Result>[]);
        final running = useState(false);
        return CustomScrollView(
          controller: controller,
          reverse: true,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // BOTTOM
            SliverAppBar(
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: _settings(context, results, controller),
                collapseMode: CollapseMode.parallax,
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              leading: Icon(Icons.developer_board, color: Colors.black),
              actions: [_uiLock(context)],
              expandedHeight: 400,
            ),
            // MIDDLE
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 120,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: _benchmark(context, results, running),
                collapseMode: CollapseMode.none,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                _results(context, results),
              ),
            ),
            // TOP
            SliverFillViewport(
              delegate: SliverChildListDelegate([
                _top(context, controller),
              ]),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _results(
    BuildContext context,
    ValueNotifier<List<Result>> results,
  ) {
    listTile(Result r) {
      return ListTile(
        dense: true,
        selected: true,
        subtitle: () {
          format(Duration d) => d.inSeconds >= 10
              ? '${d.inSeconds}s'
              : d.inMilliseconds > 0
                  ? '${d.inMilliseconds}ms'
                  : '${d.inMicroseconds}μs';
          final it = format(r.intTime);
          final st = format(r.stringTime);
          err(Duration de) {
            if (de == null) return '';
            return ' ± ${format(de)}';
          }

          final ite = err(r.intTimeErr);
          final ste = err(r.stringTimeErr);
          return Text('i64 $it$ite, str $st$ste');
        }(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 4.0,
        ),
        leading: Container(
          child: () {
            final icon = r.runner.aes ? Icons.fingerprint : Icons.blur_on;
            final compl = r.complete;
            return Stack(alignment: Alignment.center, children: [
              if (compl < 1)
                CircularProgressIndicator(
                  value: compl,
                  strokeWidth: 1,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.blue.withOpacity(.8),
                  ),
                ),
              Icon(icon, color: Colors.black, size: 30),
            ]);
          }(),
        ),
        title: Text(
          '${r.runner.storageType}: ${r.mode}',
          style: Theme.of(context).textTheme.headline6,
        ),
      );
    }

    card(Widget w) {
      return Card(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: w,
      );
    }

    return results.value.map(listTile).map(card).toList();
  }

  Widget _benchmark(
    BuildContext context,
    ValueNotifier<List<Result>> results,
    ValueNotifier<bool> running,
  ) {
    onPressed() async {
      if (running.value) return;
      results.value = <Result>[];
      running.value = true;
      print('RUNNING');
      final settings = context.bloc<SettingsBloc>().state;
      final bm = Benchmark(settings);
      await bm
          .run()
          .act((r) {
            final res = [...results.value];

            var flag = false;
            for (var i = 0; i < res.length; i++) {
              if (res[i].compare(r)) {
                res[i] = r;
                flag = true;
                break;
              }
            }
            if (!flag) res.add(r);

            return results.value = res;
          })
          .map((r) sync* {
            yield '${r.runner.storageType}: int64 : ${r.intTime}ms';
            yield '${r.runner.storageType}: string: ${r.stringTime}ms';
          })
          .act(print)
          .drain();
      running.value = false;
      print('DONE');
      Future.delayed(const Duration(milliseconds: 100))
          .then((_) => setState(() {})); //controller.position.extentAfter

      // Dumping JSON
      print("====== SETTINGS ======");
      final settingsJson = BenchmarkSettings.toJson(settings);
      print(json.encode(settingsJson));
      print("=== RESULTS ===");
      final resultsJson = results.value.map((x) => x.toJson()).toList();
      print(json.encode(resultsJson));
      print('TITLE');
      // 35_blocs 256_Bytes NoAES
      final titleJson = '${settingsJson["blocCount"]}_blocs'
          ' ${settings.stateSizeLabels.end.replaceAll(' ', '_')}'
          ' ${settingsJson["aes"] ? "AES" : "NoAES"}';
      print(titleJson);
      print('\n\nSENDING JSON');

      final composedJson = <String, dynamic>{
        'title': titleJson,
        'settings': settingsJson,
        'results': resultsJson
      };

      final composed = json.encode(composedJson);
      try {
        print('Sending composed');
        var resp = await post(
          'http://10.0.1.9:9091/dump',
          body: composed,
        );
        if (resp.statusCode == 200) {
          print('Done!');
          return;
        }
        throw null;
      } on dynamic catch (_) {
        throw Exception("Could not send json");
      }
    }

    return OutlineButton(
      padding: EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      child: Text("BENCHMARK"),
      onPressed: running.value ? null : onPressed,
    );
  }

  Widget _uiLock(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('UI LOCK', style: Theme.of(context).textTheme.headline6),
        BlocBuilder<SettingsBloc, BenchmarkSettings>(
          condition: (oldSettings, settings) =>
              oldSettings.uiLock != settings.uiLock,
          builder: (context, settings) => Switch(
            value: settings.uiLock,
            onChanged: (b) {
              context.bloc<SettingsBloc>().add(SettingsEvent.setUiLock(b));
            },
          ),
        ),
      ],
    );
  }

  Widget _settings(
    BuildContext context,
    ValueNotifier<List<Result>> results,
    ScrollController controller,
  ) {
    return Container(
      padding: EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x00ffffff), Colors.blue.withOpacity(0.2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView(
        reverse: true,
        physics: const BouncingScrollPhysics(),
        children: [
          _goUp(results, controller),
          ..._stateSize(context),
          Divider(),
          ..._storages(context),
          Divider(),
          ..._blocCount(context),
          Divider(),
          ..._benchModes(context),
        ],
      ),
    );
  }

  List<Widget> _benchModes(BuildContext context) {
    BlocBuilderCondition<BenchmarkSettings> condition =
        (oldSettings, settings) => oldSettings.modes != settings.modes;
    final slider = BlocBuilder<SettingsBloc, BenchmarkSettings>(
      condition: condition,
      builder: (context, settings) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: () {
          const mm = [Mode.wake, Mode.read, Mode.write, Mode.delete];
          const ll = {
            Mode.wake: 'WAKE',
            Mode.read: 'READ',
            Mode.write: 'WRITE',
            Mode.delete: 'DELETE',
          };
          const oss = {
            Mode.wake: true,
            Mode.read: true,
            Mode.write: true,
            Mode.delete: false,
          };
          final ss = settings.modes;
          return mm.map((m) => ChoiceChip(
              onSelected: oss[m]
                  ? (b) => context
                      .bloc<SettingsBloc>()
                      .add(SettingsEvent.flipMode(m))
                  : null,
              selected: ss[m],
              shape: StadiumBorder(
                side: BorderSide(
                  color: ss[m]
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              selectedColor: Colors.blue.withOpacity(0.15),
              shadowColor: Colors.grey.withOpacity(0.25),
              selectedShadowColor: Colors.blue.withOpacity(0.25),
              backgroundColor: Theme.of(context).canvasColor,
              padding: EdgeInsets.symmetric(horizontal: 8),
              label: Text(ll[m])));
        }() // insert gaps between chips
            .expand((w) sync* {
              yield const SizedBox(width: 8);
              yield w;
            })
            .skip(1)
            .toList(),
      ),
    );

    final text = BlocBuilder<SettingsBloc, BenchmarkSettings>(
      condition: condition,
      builder: (context, settings) {
        final cur = settings.modes.values.where((v) => v).length;
        final tot = settings.modes.length;
        final text = '$cur/$tot';
        const title = 'BENCH MODES';
        return TitleRow(text: text, title: title);
      },
    );

    return [slider, text];
  }

  List<Widget> _blocCount(BuildContext context) {
    BlocBuilderCondition<BenchmarkSettings> condition =
        (oldSettings, settings) => oldSettings.blocCount != settings.blocCount;
    final slider = BlocBuilder<SettingsBloc, BenchmarkSettings>(
      condition: condition,
      builder: (context, settings) => RangeSlider(
        min: settings.blocCountRange.start,
        max: settings.blocCountRange.end,
        divisions: settings.blocCountDivs,
        labels: settings.blocCountLabels,
        values: settings.blocCount,
        onChanged: (bc) {
          context.bloc<SettingsBloc>().add(SettingsEvent.setBlocCount(bc));
        },
      ),
    );
    final text = BlocBuilder<SettingsBloc, BenchmarkSettings>(
      condition: condition,
      builder: (context, settings) {
        final start = settings.blocCount.start.toInt();
        final end = settings.blocCount.end.toInt();
        final text = start == end ? '$end' : '$start-$end'.padLeft(2);
        const title = 'BLOC COUNT';
        return TitleRow(text: text, title: title);
      },
    );
    return [slider, text];
  }

  List<Widget> _storages(BuildContext context) {
    BlocBuilderCondition<BenchmarkSettings> condition =
        (oldSettings, settings) =>
            oldSettings.useAES != settings.useAES ||
            oldSettings.useB64 != settings.useB64 ||
            oldSettings.storages != settings.storages;
    final view = SizedBox(
      height: 48,
      child: HookBuilder(
        builder: (context) {
          final controller = useScrollController();
          return BlocBuilder<SettingsBloc, BenchmarkSettings>(
            condition: condition,
            builder: (context, settings) => CustomScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverFillRemaining(
                  child: _storagesMainPart(context, controller, settings),
                ),
                SliverToBoxAdapter(
                  child: _storagesSubPart(context, settings),
                ),
              ],
            ),
          );
        },
      ),
    );

    final text = BlocBuilder<SettingsBloc, BenchmarkSettings>(
        condition: condition,
        builder: (context, settings) {
          final cur = settings.storages.values.where((v) => v).length;
          final tot = settings.storages.length;
          final text = '$cur/$tot'
              '${settings.useAES ? " + aes" : ""}'
              '${settings.useAES && settings.useB64 ? "(b64)" : ""}';
          const title = 'STORAGES';
          return TitleRow(text: text, title: title);
        });

    return [
      view, // SizedBox(height: 8),
      text,
    ];
  }

  Widget _storagesMainPart(
    BuildContext context,
    ScrollController controller,
    BenchmarkSettings settings,
  ) {
    const ss = [Storage.single, Storage.multi, Storage.hive];
    const ll = {
      Storage.single: 'Single file',
      Storage.multi: 'Isolated files',
      Storage.hive: 'Hive water'
    };
    Widget bb = ToggleButtons(
      isSelected: ss.map((s) => settings.storages[s]).toList(),
      onPressed: (i) {
        context.bloc<SettingsBloc>().add(SettingsEvent.flipStorage(ss[i]));
      },
      children: ss.map((s) => Text(ll[s])).toList(),
      constraints: const BoxConstraints(
        minWidth: 100.0,
        minHeight: 32.0,
      ),
      borderColor: Colors.grey.withOpacity(0.3),
      selectedBorderColor: Colors.blue.withOpacity(0.3),
      borderRadius: BorderRadius.circular(8),
    );
    bb = Center(child: bb);
    final tap = Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: () {
          controller.animateTo(
            controller.position.extentBefore > 0
                ? controller.position.minScrollExtent
                : controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCirc,
          );
        },
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: Colors.blue.withOpacity(0.5),
        ),
      ),
    );
    return Stack(children: [bb, tap]);
  }

  Widget _storagesSubPart(
    BuildContext context,
    BenchmarkSettings settings,
  ) {
    return Container(
      padding: EdgeInsets.only(right: 12),
      alignment: Alignment.center,
      child: () {
        const ll = ['AES', 'Base64'];
        final ss = {
          'AES': settings.useAES,
          'Base64': settings.useB64,
        };
        final pp = {
          'AES': SettingsEvent.flipUseAES(),
          'Base64': SettingsEvent.flipUseB64(),
        };
        return ToggleButtons(
          isSelected: ll.map((l) => ss[l]).toList(),
          onPressed: (i) => context.bloc<SettingsBloc>().add(pp[ll[i]]),
          children: ll.map((l) => Text(l)).toList(),
          constraints: const BoxConstraints(
            minWidth: 80.0,
            minHeight: 32.0,
          ),
          borderColor: Colors.grey.withOpacity(0.3),
          selectedBorderColor: Colors.blue.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        );
      }(),
    );
  }

  List<Widget> _stateSize(BuildContext context) {
    BlocBuilderCondition<BenchmarkSettings> condition =
        (oldSettings, settings) => oldSettings.stateSize != settings.stateSize;
    final slider = BlocBuilder<SettingsBloc, BenchmarkSettings>(
      condition: condition,
      builder: (context, settings) => RangeSlider(
        min: settings.stateSizeRange.start,
        max: settings.stateSizeRange.end,
        divisions: settings.stateSizeDivs,
        labels: settings.stateSizeLabels,
        values: settings.stateSize,
        onChanged: (ss) {
          context.bloc<SettingsBloc>().add(SettingsEvent.setStateSize(ss));
        },
      ),
    );

    final text = BlocBuilder<SettingsBloc, BenchmarkSettings>(
      condition: condition,
      builder: (context, settings) {
        const px = '⩾';
        final cc = settings.stateSizeBytesMax ~/ 4;
        $(int cc) {
          if (cc < 1e3) {
            return '$cc';
          } else if (cc < 1e5) {
            cc ~/= 1e3;
            return '$px${cc}k';
          } else if (cc < 1e6) {
            cc ~/= 1e4;
            cc *= 10;
            return '$px${cc}k';
          } else {
            cc ~/= 1e6;
            return '$px${cc}M';
          }
        }

        final text = '${$(cc)} int64${cc > 1 ? 's' : ''}';
        const title = 'STATE SIZE';
        return TitleRow(
          text: text,
          title: title,
          decorator: (ww) => [
            TitleText(text: px, transparent: true),
            ...ww,
            TitleText(text: px, transparent: true),
          ],
        );
      },
    );

    return [slider, text];
  }

  _goUp(ValueNotifier<List<Result>> results, ScrollController controller) {
    onPressed() {
      controller.animateTo(
        controller.position.maxScrollExtent -
            controller.position.viewportDimension +
            5,
        duration: Duration(milliseconds: 200 + 50 * results.value.length),
        curve: Curves.easeInOut,
      );
    }

    return IconButton(
      icon: Icon(Icons.keyboard_arrow_up),
      onPressed:
          results.value.isEmpty || controller.position.maxScrollExtent <= 0
              ? null
              : onPressed,
    );
  }

  Widget _top(BuildContext context, ScrollController controller) {
    text() {
      return Text(
        'Tap on little blue processor\nto see tuning options',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headline6
            .copyWith(color: Colors.grey.withOpacity(0.4)),
      );
    }

    processor() {
      return IconButton(
        iconSize: 96,
        icon: Icon(
          Icons.select_all,
          color: Colors.blueGrey.withOpacity(0.4),
        ),
        onPressed: () {
          controller.animateTo(
            0,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
          );
        },
      );
    }

    version() {
      return Text(
        'v4.0.0',
        style: Theme.of(context).textTheme.headline6.copyWith(
              color: Colors.grey.withOpacity(0.4),
            ),
      );
    }

    return Column(verticalDirection: VerticalDirection.up, children: [
      SizedBox(height: 8),
      version(),
      processor(),
      SizedBox(height: 120),
      text(),
    ]);
  }
}

typedef TitleRowDecorator = List<Widget> Function(List<Widget>);

class TitleRow extends StatelessWidget {
  TitleRow({
    Key key,
    @required this.text,
    @required this.title,
    TitleRowDecorator decorator,
  })  : this.decorator = decorator ?? ((ww) => ww),
        super(key: key);

  final String text;
  final String title;
  final TitleRowDecorator decorator;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: decorator([
        TitleText(text: text, transparent: true),
        Text(title),
        SizedBox(width: 4),
        TitleText(text: text, transparent: false),
      ]),
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({
    Key key,
    @required this.text,
    @required this.transparent,
  }) : super(key: key);

  final String text;
  final bool transparent;

  @override
  Widget build(BuildContext context) {
    const tc = Colors.transparent;
    final cc = Colors.grey.withOpacity(.35);
    return Text(
      text,
      textScaleFactor: 0.825,
      style: TextStyle(color: transparent ? tc : cc),
    );
  }
}

extension Stream$<T> on Stream<T> {
  Stream<T> act(void action(T item)) {
    return this.map((item) {
      action(item);
      return item;
    });
  }
}
