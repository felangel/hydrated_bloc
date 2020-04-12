import 'package:benchmark/settings.dart';
import 'package:flutter/material.dart';
import 'benchmark.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _theme(),
      home: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: _view(context),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _theme() {
    return ThemeData(
      brightness: Brightness.light,
      buttonTheme: ButtonThemeData(
        highlightColor: Colors.blue.withOpacity(0.2),
        splashColor: Colors.blue.withOpacity(0.5),
        // colorScheme:
      ),
      textTheme: TextTheme(
        button: TextStyle(fontSize: 18),
        title: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  var _running = false;
  final _results = <Result>[];
  Widget _benchmark(BuildContext context) {
    return OutlineButton(
      padding: EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      child: Text(
        "BENCHMARK",
      ),
      onPressed: _running
          ? null
          : () async {
              if (_running) return;
              _results.clear();
              setState(() => _running = true);
              print('RUNNING');
              const maa = {
                Mode.read: benchmarkRead,
                Mode.write: benchmarkWrite,
                Mode.wake: benchmarkWake,
                //  Mode.delete: benchmarkDelete,
              };
              const count = 150;
              final mm = settings.modes;
              await Stream.fromIterable(mm.keys.where((m) => mm[m]))
                  .asyncExpand((m) => maa[m](count))
                  .act((r) => setState(() => _results.add(r)))
                  .map((r) sync* {
                    yield '${r.runner.storageType}: int64 : ${r.intTime}ms';
                    yield '${r.runner.storageType}: string: ${r.stringTime}ms';
                  })
                  .act(print)
                  .drain();
              setState(() => _running = false);
              print('DONE');
              Future.delayed(const Duration(milliseconds: 100)).then(
                  (_) => setState(() {})); //controller.position.extentAfter
            },
    );
  }

  List<Widget> _list(BuildContext context) => [
        ..._results.map(
          (r) => Card(
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
            child: ListTile(
              dense: true,
              selected: true,
              subtitle: Text('i64 ${r.intTime}ms, str ${r.stringTime}ms'),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              leading: Container(
                child: Icon(Icons.blur_on, color: Colors.black, size: 30),
              ),
              title: Text(
                '${r.runner.storageType}: ${r.mode}',
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ),
        )
      ];

  final settings = BenchmarkSettings();
  // var controller = ScrollController(initialScrollOffset: 350);
  var controller = ScrollController(initialScrollOffset: 400);
  Widget _view(BuildContext context) {
    // final controller = ScrollController(initialScrollOffset: 600);
    //NestedScrollView
    return CustomScrollView(
      controller: controller,
      // primary: true,
      reverse: true,
      // anchor: 0.25,
      // shrinkWrap: true,
      // physics: BouncingScrollPhysics(),
      // physics: const AlwaysScrollableScrollPhysics(),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // BOTTOM
        SliverAppBar(
          // expandedHeight: 0,
          elevation: 0,
          // centerTitle: true,
          // title: Slider(
          //   value: 0.2,
          //   onChanged: (v) {},
          // ),
          // title: Text('build: 3.1.0', style: Theme.of(context).textTheme.title),
          // leading: Icon(Icons.developer_board, color: Colors.black),
          // title: Row(children: [
          //   Icon(
          //     Icons.verified_user, // (developer_board|verified_user)
          //     color: Colors.black,
          //   ),
          //   Text(
          //     "v1.0.0",
          //     style: Theme.of(context).textTheme.title,
          //   ),
          // ]),
          // actions: <Widget>[Icon(Icons.ac_unit, color: Colors.black)],
          // stretch: true, // ?
          // bottom: ,
          // title: _benchmark(context),
          // pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            // title: _benchmark(context),
            background: Container(
              padding: EdgeInsets.only(top: 24),
              // color: Colors.blue.withOpacity(0.2),
              // color: Color(0xffecf0f1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x00ffffff), Colors.blue.withOpacity(0.2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              // child: Column(
              //   mainAxisSize: MainAxisSize.max,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: <Widget>[
              //     _benchmark(context),
              //     _benchmark(context),
              //     _benchmark(context),
              //     _benchmark(context),
              //     _benchmark(context),
              //   ],
              // ),
              child: ListView(
                // itemExtent: 140,

                reverse: true,
                physics: const BouncingScrollPhysics(
                    // parent: AlwaysScrollableScrollPhysics(),
                    ),
                children: <Widget>[
                  // FlatButton(
                  //   child: Text("PRESS"),
                  //   onPressed: () {
                  //     // controller.positions.forEach(print);
                  //     controller.animateTo(
                  //       controller.position.maxScrollExtent,
                  //       duration: const Duration(seconds: 1),
                  //       curve: Curves.linear,
                  //     );
                  //   },
                  // ),
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_up),
                    // splashColor: Colors.blue.withOpacity(0.4),
                    // highlightColor: Colors.blue.withOpacity(0.2),
                    // onPressed: _results.isEmpty || _running
                    onPressed: _results.isEmpty ||
                            controller.position.maxScrollExtent <= 0
                        ? null
                        : () => controller.animateTo(
                              controller.position.maxScrollExtent -
                                  controller.position.viewportDimension +
                                  5,
                              duration: Duration(
                                  milliseconds: 200 + 50 * _results.length),
                              curve: Curves.easeInOut,
                            ),
                  ),
                  // _benchmark(context),
                  // _benchmark(context),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     FilterChip(
                  //         onSelected: (v) {},
                  //         selected: true,
                  //         label: Text('single')),
                  //     FilterChip(
                  //         avatar: CircleAvatar(
                  //           backgroundColor: Colors.grey.shade800,
                  //           child: Icon(Icons.polymer),
                  //         ),
                  //         onSelected: (v) {},
                  //         selected: true,
                  //         label: Text('multi')),
                  //     FilterChip(
                  //         onSelected: (v) {},
                  //         selected: false,
                  //         label: Text('temp')),
                  //   ],
                  // ),

                  // Chip(
                  //   avatar: CircleAvatar(
                  //     backgroundColor: Colors.grey.shade800,
                  //     child: Text('AB'),
                  //   ),
                  //   label: Text('Aaron Burr'),
                  // ),
                  // LinearProgressIndicator(
                  //   backgroundColor: Colors.transparent,
                  //   // valueColor: Animated,
                  // ),
                  // _benchmark(context),
                  // Slider(
                  //   value: 0.2,
                  //   onChanged: print,
                  // ),
                  // SETTINGS TOP
                  RangeSlider(
                    min: settings.stateSizeRange.start,
                    max: settings.stateSizeRange.end,
                    divisions: settings.stateSizeDivs,
                    labels: settings.stateSizeLabels,
                    values: settings.stateSize,
                    onChanged: (rv) => setState(() => settings.stateSize = rv),
                  ),
                  () {
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
                  }(),
                  Divider(),
                  Center(child: () {
                    const ss = [Storage.single, Storage.multi, Storage.ether];
                    const ll = {
                      Storage.single: 'Single file',
                      Storage.multi: 'Isolated files',
                      Storage.ether: 'Ethereal'
                    };
                    return ToggleButtons(
                      isSelected: ss.map((s) => settings.storages[s]).toList(),
                      onPressed: (i) =>
                          setState(() => settings.flipStorage(ss[i])),
                      constraints: const BoxConstraints(
                        minWidth: 100.0,
                        minHeight: 32.0,
                      ),
                      borderColor: Colors.grey.withOpacity(0.3),
                      selectedBorderColor: Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      children: ss.map((s) => Text(ll[s])).toList(),
                    );
                  }()),
                  SizedBox(height: 8),
                  () {
                    final cur = settings.storages.values.where((v) => v).length;
                    final tot = settings.storages.length;
                    final text = '$cur/$tot';
                    const title = 'STORAGES';
                    return TitleRow(text: text, title: title);
                  }(),
                  Divider(),
                  RangeSlider(
                    min: settings.blocCountRange.start,
                    max: settings.blocCountRange.end,
                    divisions: settings.blocCountDivs,
                    labels: settings.blocCountLabels,
                    values: settings.blocCount,
                    onChanged: (rv) => setState(() => settings.blocCount = rv),
                  ),
                  () {
                    final start = settings.blocCount.start.toInt();
                    final end = settings.blocCount.end.toInt();
                    final text =
                        start == end ? '$end' : '$start-$end'.padLeft(2);
                    const title = 'BLOC COUNT';
                    return TitleRow(text: text, title: title);
                  }(),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: () {
                      const mm = [
                        Mode.wake,
                        Mode.read,
                        Mode.write,
                        Mode.delete
                      ];
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
                              ? (b) => setState(() => settings.flipMode(m))
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
                  () {
                    final cur = settings.modes.values.where((v) => v).length;
                    final tot = settings.modes.length;
                    final text = '$cur/$tot';
                    const title = 'BENCH MODES';
                    return TitleRow(text: text, title: title);
                  }()
                ],
              ),
            ),
            collapseMode: CollapseMode.parallax,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          // floating: true,
          // pinned: true,
          // forceElevated: true,
          // floating: true,
          // tune
          // developer_board
          // leading: IconButton(
          //   icon: Icon(Icons.developer_board, color: Colors.black),
          //   onPressed: () {
          //     controller.animateTo(
          //       0,
          //       duration: const Duration(seconds: 1),
          //       curve: Curves.easeInOut,
          //     );
          //   },
          // ),
          leading: Icon(Icons.developer_board, color: Colors.black),
          actions: <Widget>[
            // Text('UI LOCK', style: TextStyle(color: Colors.black)),
            // Switch(value: true, onChanged: (v) {}),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Text('UI LOCK', style: TextStyle(color: Colors.black)),
                Text('UI LOCK', style: Theme.of(context).textTheme.title),
                // Icon(Icons.verified_user, color: Colors.black),
                Switch(
                  value: settings.uiLock,
                  onChanged: (b) => setState(() => settings.uiLock = b),
                ),
              ],
            ),
          ],
          // title: _benchmark(context),
          // title: Text('Logic tuning', style: Theme.of(context).textTheme.title),
          // title: Divider(
          //   thickness: 1,
          //   color: Colors.grey.withOpacity(0.3),
          // ),
          expandedHeight: 400,
          // bottom: PreferredSize(
          //   preferredSize: Size.fromHeight(50.0),
          //   // child: _benchmark(context),
          //   // child: Row(children: <Widget>[
          //   //   Icon(Icons.developer_board, color: Colors.black)
          //   // ]),
          // ),
          // pinned: true,
        ),
        // SliverFillRemaining(
        //     child: Container(color: Colors.blue.withOpacity(0.2))),
        // SliverFillViewport(
        //   viewportFraction: .2,
        //   delegate: SliverChildListDelegate([
        //     Container(color: Colors.blue.withOpacity(0.2)),
        //     Container(color: Colors.red.withOpacity(0.2)),
        //     Container(color: Colors.green.withOpacity(0.2)),
        //   ]),
        // ),
        // SliverLayoutBuilder
        // SliverPrototypeExtentList
        // SliverMultiBoxAdaptorElement
        // SliverOverlapInjector
        // MIDDLE
        SliverAppBar(
          // pinned: true,
          backgroundColor: Colors.transparent,
          expandedHeight: 120,
          elevation: 0,
          // title: Text('fire'),
          // leading: Icon(Icons.developer_board, color: Colors.black),
          // bubble_chart
          // verified_user
          // bug_report
          // build
          // developer_board
          // device_hub
          // fingerprint
          // linear_scale
          // polymer
          // select_all
          // tune
          // leading: Icon(Icons.select_all, color: Colors.black),
          // leading: Text('🤯'),
          // floating: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            // background: _benchmark(context),
            title: _benchmark(context),
            // title: Placeholder(),
            collapseMode: CollapseMode.none,
          ),
          // bottom: PreferredSize(
          //   preferredSize: Size.fromHeight(100.0),
          //   child: _benchmark(context),
          // ),
        ),
        SliverList(delegate: SliverChildListDelegate(_list(context))),
        // SliverFillRemaining(),
        // if (_results.isEmpty ||
        //     controller.position.extentAfter - controller.position.extentBefore <
        //         controller.position.maxScrollExtent)
        // if (_results.isEmpty ||
        //     controller.position.maxScrollExtent >
        //         2 * controller.position.viewportDimension)
        SliverFillViewport(
          // viewportFraction: 0.8,
          delegate: SliverChildListDelegate(
            [
              // Container(color: Colors.blue.withOpacity(0.2)),
              // Container(color: Colors.red.withOpacity(0.2)),
              // Container(color: Colors.green.withOpacity(0.2)),
              Column(
                verticalDirection: VerticalDirection.up,
                children: <Widget>[
                  SizedBox(height: 8),
                  Text('v3.1.0',
                      style: Theme.of(context).textTheme.title.copyWith(
                            color: Colors.grey.withOpacity(0.4),
                          )),
                  IconButton(
                    iconSize: 96,
                    // splashColor: Colors.blue,
                    icon: Icon(
                      Icons.select_all,
                      // size: 96,
                      color: Colors.blueGrey.withOpacity(0.4),
                    ),
                    onPressed: () {
                      controller.animateTo(
                        0,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  SizedBox(height: 120),
                  Text(
                    'Tap on little blue processor\nto see tuning options',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .copyWith(color: Colors.grey.withOpacity(0.4)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
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
  Stream<T> act(void action(T)) {
    return this.map((item) {
      action(item);
      return item;
    });
  }
}
