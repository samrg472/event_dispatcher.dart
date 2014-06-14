import 'package:event_dispatcher/event_dispatcher.dart';

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
  ed.register(g2);
  ed.register(s1);
  ed.register(s2);
  
  ed.post(new GenericEvent());
  ed.post(new Event());
  
  print("");
  
  ed.unregister(g2);
  ed.unregister(s2);
  
  ed.post(new GenericEvent());
  ed.post(new Event());
}

class GenericEvent {

}

class Event {

}
