import "package:event_dispatcher/event_dispatcher.dart";

void main() {
  var dispatcher = new EventDispatcher();
  var objA = new TestObjectA();
  var objB = new TestObjectB();

  dispatcher.registerHandlers(objA);
  dispatcher.post(new MessageEvent("Hello World"));
  dispatcher.unregisterHandlers(objA);
  dispatcher.registerHandlers(objB);
  dispatcher.post(new MessageEvent("Hello World"));
  dispatcher.post(new NothingEvent("This is a nothing event."));
  dispatcher.unregisterHandlers(objB);
}

class TestObjectA {
  @Subscribe()
  void onMessageEvent(MessageEvent event) {
    print("A: ${event.message}");
  }
}

class TestObjectB {
  @Subscribe(priority: 50)
  void onMessageEvent(MessageEvent event) {
    print("B: ${event.message}");
    event.cancel();
  }

  @Subscribe(priority: 0, always: true)
  void onMessageEventDone(MessageEvent event) {
    print("B Done: ${event.message}");
  }

  @Subscribe()
  void onDeadEvent(DeadEvent event) {
    print("Dead Event Captured: ${event.event}");
  }
}

class MessageEvent extends Cancelable {
  final String message;

  MessageEvent(this.message);
}

class NothingEvent {
  final String message;

  NothingEvent(this.message);

  @override
  String toString() => message;
}
