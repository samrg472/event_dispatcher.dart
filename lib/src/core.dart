part of event_dispatcher;

/**
 * A function that handles events.
 */
typedef void EventHandlerFunction<T>(T event);

/**
 * An event filter that filters out events.
 *
 * If this function returns false, the function will be called, otherwise it will not be called.
 */
typedef bool EventFilter<T>(T event);

/**
 * The controller through which all events communicate with each other.
 */
class EventDispatcher {
  /**
   * Default Event Handler Priority
   */
  final int defaultPriority;
  final _map = new Map<Type, List<_EventHandler>>();

  /**
   * Creates a new Event Dispatcher.
   *
   * If [defaultPriority] is specified, it will be the priority
   * that is assigned to handlers when they do not specify one.
   */
  EventDispatcher({this.defaultPriority: 10});

  /**
   * Unregisters a [handler] from receiving events. If the specific [handler]
   * has a filter, it should be provided in order to properly unregister the
   * listener. If the specific [handler] has a priority, it should be provided as well.
   * Returns whether the [handler] was removed or not.
   */
  bool unregister(EventHandlerFunction handler, {EventFilter filter: _defaultFilter, int priority}) {
    if (priority == null) {
      priority = defaultPriority;
    }

    var name = _getName(handler);

    if (!_map.containsKey(name)) {
      return false;
    }

    var h = new _EventHandler(handler, filter, priority);
    _EventHandler fh;

    for (var mh in _map[name]) {
      if (mh == h) {
        fh = mh;
        break;
      }
    }

    if (fh != null) {
      _map[name].remove(fh);
      _map[name].sort((_EventHandler a, _EventHandler b) {
        return b.priority.compareTo(a.priority);
      });
      return true;
    } else {
      return false;
    }
  }

  /**
   * Registers a method so that it can start receiving events.
   *
   * A filter can be provided to determine when the [handler] will
   * be called. If the [filter] returns true then the [handler] will
   * not be called, otherwise it will be called. If no [filter] is
   * provided then the [handler] will always be called upon posting an
   * event.
   *
   * A [priority] can be provided which will specify in what order the handler will be called in.
   * The higher a priority is, the quicker it will be called in the handler list when an event is posted.
   *
   * Returns false if [method] is already registered, otherwise true.
   */
  bool register(EventHandlerFunction handler, {EventFilter filter: _defaultFilter, int priority}) {
    if (priority == null) {
      priority = defaultPriority;
    }

    var name = _getName(handler);
    var handlers = _map[name];
    if (handlers == null) {
      handlers = _map[name] = <_EventHandler>[];
    }

    var h = new _EventHandler(handler, filter, priority);
    if (handlers.any((it) => it == h)) {
      return false;
    }

    handlers.add(h);
    handlers.sort((_EventHandler a, _EventHandler b) => b.priority.compareTo(a.priority));
    return true;
  }

  /**
   * Fires an event to registered listeners. Any listeners that take the
   * specific type [event] will be called.
   */
  bool post(dynamic event) {
    var name = _getName(event);

    var handlers = _map[name];

    if (handlers == null) {
      return false;
    }
    
    var executed = false;
    for (var handler in handlers) {
      if (handler.apply(event)) {
        executed = true;
      }
    }
    return executed;
  }

  /**
   * Gets the type of the first parameter, used for posting.
   */
  Type _getName(dynamic input) {
    if (input is Function) {
      return (reflect(input) as ClosureMirror).function.parameters.first.type.reflectedType;
    } else if (input is Type) {
      return input;
    } else {
      return input.runtimeType;
    }
  }

  static bool _defaultFilter(dynamic obj) {
    return false;
  }
}

class _EventHandler {
  final Function function;
  final Function filter;
  final int priority;

  _EventHandler(this.function, this.filter, this.priority);

  bool apply(dynamic event) {
    if (!filter(event)) {
      function(event);
      return true;
    } else {
      return false;
    }
  }

  bool operator ==(other) => other is _EventHandler &&
    other.function == function && other.filter == filter &&
    other.priority == priority;
}
