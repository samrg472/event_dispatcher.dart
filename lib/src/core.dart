part of event_dispatcher;

/**
 * The controller through which all events communicate with each other.
 */
class EventDispatcher {
  
  final _map = new Map<Symbol, List<Function>>();
  
  /**
   * Unregisters a method from receiving events.
   * Returns whether the [method] was removed or not.
   */
  bool unregister(void method(dynamic)) {
    var name = _get_name(method: method);
    return _map[name].remove(method);
  }
  
  /**
   * Registers a method so that it can start receiving events.
   * Returns false if [method] is already registered, otherwise true.
   */
  bool register(void method(dynamic)) {
    var name = _get_name(method: method);    
    List methods = _map[name];
    
    if (methods == null) {
      methods = new List();
      _map[name] = methods;
    }
    
    if (methods.contains(method))
      return false;
    
    methods.add(method);
    return true;
    
  }
  
  /**
   * Fires an event to registered listeners. Any listeners that take the
   * specific type [obj] will be called.
   */
  void post(dynamic obj) {
    var name = _get_name(obj: obj);
        
    List methods = _map[name];
    if (methods == null)
      return;
    
    methods.forEach((m) => m(obj));
  }
  
  Symbol _get_name({void method(dynamic), dynamic obj}) {
    if (method != null) {
      var cm = reflect(method);
      return cm.function.parameters.first.type.qualifiedName;
    } else if (obj != null) {
      var cm = reflect(obj);
      return cm.type.qualifiedName;
    }
    return null;
  }
}
