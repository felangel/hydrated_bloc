import 'benchmark.dart';

void main() async {
  final rr = await benchmarkWrite(100);
  rr.map((r) => '${r.runner.name}: ${r.stringTime}μs').forEach(print);
} // dart main.dart
