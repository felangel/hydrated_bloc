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
                color: Colors.grey.withOpacity(0.8),
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
    //NestedScrollView
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          expandedHeight: 200,
          elevation: 0,
          // centerTitle: true,
          leading: Icon(Icons.developer_board, color: Colors.black),
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
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: _benchmark(context),
            collapseMode: CollapseMode.none,
          ),
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
