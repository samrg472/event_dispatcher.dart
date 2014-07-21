part of event_dispatcher;

/**
 * The controller through which all events communicate with each other.
 */
class EventDispatcher {

  final _map = new Map<Symbol, List<List>>();

  /**
   * Unregisters a [method] from receiving events. If the specific [method]
   * had a filter, it should be provided in order to properly unregister the
   * listener.
   * Returns whether the [method] was removed or not.
   */
  bool unregister(void method(dynamic), {bool filter(dynamic)}) {
    var name = _get_name(method: method);

    if (filter == null)
      filter = _default_filter;

    List funcs = _find_functions(method, filter);
    if (funcs == null)
      return false;
    return _map[name].remove(funcs);
  }

  /**
   * Registers a method so that it can start receiving events.
   *
   * A filter can be provided to determined when the [method] will
   * be called. If the [filter] returns true then the [method] will
   * not be called, otherwise it will be called. If no [filter] is
   * provided the [method] will always be called upon posting an
   * event. [once] is a one time registration. When the [filter] and/or
   * the [method] gets called, then the [method] will be automatically
   * unregistered.
   *
   * Returns false if [method] is already registered, otherwise true.
   */
  bool register(void method(dynamic), {bool filter(dynamic), bool once : false}) {
    var name = _get_name(method: method);
    List methods = _map[name];

    if (methods == null) {
      methods = new List();
      _map[name] = methods;
    }

    if (filter == null)
      filter = _default_filter;

    List func = new List(3);
    if (_find_functions(method, filter) != null)
      return false;

    func[0] = method;
    func[1] = filter;
    func[2] = once;

    methods.add(func);
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

    var removal = [];
    methods.forEach((List funcs) {
      if (!funcs[1](obj)) funcs[0](obj);
      if (funcs[2]) removal.add(funcs);
    });
    removal.forEach((var funcs) => methods.remove(funcs));
  }

  /**
   * Gets the type of the first parameter, used for posting
   */
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

  List<Function> _find_functions(void method(dynamic), void filter(dynamic)) {
    var name = _get_name(method: method);
    if (_map[name] == null)
      return null;

    return _map[name].firstWhere((List<Function> f) {
      return (f[0] == method) && (f[1] == filter);
    }, orElse: () { return null; });
  }

  bool _default_filter(dynamic obj) {
    return false;
  }
}
