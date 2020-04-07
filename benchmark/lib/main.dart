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
              _results.clear();
              setState(() => _running = true);
              print('RUNNING');
              await benchmarkWrite(100)
                  .doo((r) => setState(() => _results.add(r)))
                  .map((r) => '${r.runner.name}: ${r.stringTime}ms')
                  .doo(print)
                  .drain();
              setState(() => _running = false);
              print('DONE');
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
              subtitle: Text('${r.stringTime}ms'),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              leading: Container(
                child: Icon(Icons.blur_on, color: Colors.black, size: 30),
              ),
              title: Text(
                '${r.runner.name}',
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ),
        )
      ];

  Widget _view(BuildContext context) {
    // final controller = ScrollController(initialScrollOffset: 600);
    //NestedScrollView
    return CustomScrollView(
      // controller: controller,
      primary: true,
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
                reverse: true,
                physics: const BouncingScrollPhysics(
                    // parent: AlwaysScrollableScrollPhysics(),
                    ),
                children: <Widget>[
                  _benchmark(context),
                  _benchmark(context),
                  _benchmark(context),
                  // Slider(
                  //   value: 0.2,
                  //   onChanged: print,
                  // ),
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
          leading: Icon(Icons.developer_board, color: Colors.black),
          // title: _benchmark(context),
          title: Text('Logic tuning', style: Theme.of(context).textTheme.title),
          // title: Divider(
          //   thickness: 1,
          //   color: Colors.grey.withOpacity(0.3),
          // ),
          expandedHeight: 200,
          // bottom: PreferredSize(
          //   preferredSize: Size.fromHeight(50.0),
          //   // child: _benchmark(context),
          //   // child: Row(children: <Widget>[
          //   //   Icon(Icons.developer_board, color: Colors.black)
          //   // ]),
          // ),
          // pinned: true,
        ),
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
          // leading: Icon(Icons.bubble_chart, color: Colors.black),
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
      ],
    );
  }
}

extension Stream$<T> on Stream<T> {
  Stream<T> doo(void action(T)) {
    return this.map((item) {
      action(item);
      return item;
    });
  }
}
