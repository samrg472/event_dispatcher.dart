part of event_dispatcher;

/**
 * The controller through which all events communicate with each other.
 */
class EventDispatcher {
  
  final _map = new Map<String, List>();
  
  /**
   * Unregisters a method from receiving events.
   * Returns whether the [method] was removed or not.
   */
  bool unregister(void method(obj)) {
    var name = _get_name(method: method);
    return _map[name].remove(method);
  }
  
  /**
   * Registers a method so that it can start receiving events.
   * Returns false if [method] is already registered, otherwise true.
   */
  bool register(void method(obj)) {
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
  void post(var obj) {
    var name = _get_name(obj: obj);
        
    List methods = _map[name];
    if (methods == null)
      return;
    
    methods.forEach((m) => m(obj));
  }
  
  String _get_name({void method(T), var obj}) {
    if (method != null) {
      var cm = reflect(method);
      return MirrorSystem.getName(cm.function.parameters.first.type.qualifiedName);
    } else if (obj != null) {
      var cm = reflect(obj);
      return MirrorSystem.getName(cm.type.qualifiedName);
    }
    return null;
  }
}
