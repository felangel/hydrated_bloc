import 'package:hydrated_bloc/hydrated_bloc.dart';

class MockBloc extends HydratedBloc<int, int> {
  @override
  int get initialState => super.initialState ?? 0;

  @override
  int fromJson(Map<String, dynamic> json) {
    return json['state'];
  }

  @override
  Stream<int> mapEventToState(int event) async* {
    yield event;
  }

  @override
  Map<String, dynamic> toJson(state) {
    return {
      'state': state,
    };
  }
}
