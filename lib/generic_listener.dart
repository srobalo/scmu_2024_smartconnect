import 'dart:async';

class GenericListener {
  final StreamController<dynamic> _controller = StreamController<dynamic>.broadcast();

  // Function to bind a listener
  void bind(Function function) {
    _controller.stream.listen((data) {
      function(data);
    });
  }

  // Function to notify listeners
  void notify(dynamic data) {
    _controller.sink.add(data);
  }

  // Dispose the controller when done
  void dispose() {
    _controller.close();
  }
}