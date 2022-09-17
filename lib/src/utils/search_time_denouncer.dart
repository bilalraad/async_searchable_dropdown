// ignore: depend_on_referenced_packages
import 'package:async/async.dart';

class TimeDeBouncer {
  /// use for search operation and task that make many request
  ///
  /// cancel the previous timer and start another one to preform operation
  final int milliseconds;
  CancelableOperation? _denouncer;

  TimeDeBouncer({required this.milliseconds});

  Future<void> run<T>() async {
    if (_denouncer != null) {
      _denouncer?.cancel();
    }
    _denouncer = CancelableOperation.fromFuture(
        Future.delayed(Duration(milliseconds: milliseconds)));
    await _denouncer?.value;
  }
}
