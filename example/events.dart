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

class GenericEvent {

}

class Event extends GenericEvent {

}
