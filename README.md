# Event Dispatcher

An elegant event system.

By using an event system methods can subscribe to a controller to
listen to events. Events allow for handling many different parts of
the codebase without needing to directly call them. The event dispatcher
does all the calling once an event is posted.

## Annotation-Based Example

```dart
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
```

## Function Registration Example

```dart
import "package:event_dispatcher/event_dispatcher.dart";

void main() {
  void g1(GenericEvent e) {
    print("Generic event called");
  }

  void g2(GenericEvent e) {
    print("Generic event 2 called");
  }

  void s1(Event e) {
    print("Specific event called");
  }

  void s2(Event e) {
    print("Specific event 2 called");
  }

  var ed = new EventDispatcher();
  ed.register(g1);
  if (!ed.register(g1)) {
    print("g1 was already registered");
  }
  var g2filter = (GenericEvent e) => false;
  ed.register(g2, filter: g2filter);
  ed.register(s1);
  ed.register(s2);

  ed.post(new GenericEvent());
  ed.post(new Event());

  print("");

  ed.unregister(g2); // Nothing to unregister!
  ed.unregister(s2); // Unregisters

  ed.post(new GenericEvent());
  ed.post(new Event());
  ed.unregister(g2, filter: g2filter);
  ed.unregister(s1);
  ed.unregister(s2);
  ed.unregister(g1);

  void h1(GenericEvent event) {
    print("h1 called!");
  }

  void h2(GenericEvent event) {
    print("h2 called!");
  }

  ed.register(h1, priority: 20);
  ed.register(h2, priority: 21);

  ed.post(new GenericEvent());
}

class GenericEvent {}

class Event extends GenericEvent {}
```
