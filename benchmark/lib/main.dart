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
            child: Column(
              children: <Widget>[
                _benchmark(context),
                Expanded(child: _log(context)),
              ],
            ),
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
  var _results = <Result>[];
  Widget _benchmark(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24),
      alignment: Alignment.topCenter,
      child: OutlineButton(
        // borderSide: BorderSide(width: 1, color: Colors.transparent),
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
                setState(() => _running = true);
                final rr = await benchmarkWrite(100);
                setState(() {
                  _results = rr;
                  _running = false;
                });
                rr
                    .map((r) => '${r.runner.name}: ${r.stringTime}ms')
                    .forEach(print);
              },
      ),
    );
  }

  Widget _log(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
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
              subtitle: Text('time ${r.stringTime}ms'),
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
      ],
    );
  }
}
