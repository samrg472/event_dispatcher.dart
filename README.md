# Event Dispatcher

An elegant event system.

By using an event system methods can subscribe to a controller to
listen to events. Events allow for handling many different parts of
the codebase without needing to directly call them. The event dispatcher
does all the calling once an event is posted.

### Example
```dart
import 'package:event_dispatcher/event_dispatcher.dart';

void main() {
  
  void generic(GenericEvent e) {
    print("Generic event called");
  }
  
  void specific(Event e) {
    print("Specific event called");
  }

  var ed = new EventDispatcher();
  ed.register(generic);
  ed.register(specific);
  
  ed.post(new GenericEvent());
  ed.post(new Event());
  
  print("");
  
  ed.unregister(generic);
  
  ed.post(new GenericEvent());
  ed.post(new Event());
}

class GenericEvent {}

class Event extends GenericEvent {}
```
