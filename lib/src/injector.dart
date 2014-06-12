part of di;

Key _INJECTOR_KEY = new Key(Injector);

class RootInjector implements Injector {
  Injector get parent => null;
  List<Object> get _instances => null;
  List<Binding> get _bindings => throw new NoParentError("No provider found!");
  const RootInjector();
}

//TODO: Injector is the interface, not the implementation
class Injector {

  static const rootInjector = const RootInjector();

  /**
   * The parent injector or null if root.
   */
  final Injector parent;
  List<Binding> _bindings;
  List<Object> _instances;

  Injector(List<Module> modules, [Injector parent])
      : parent = parent == null ? rootInjector : parent,
        _bindings = new List<Binding>(Key.numInstances + 1), // + 1 for injector itself
        _instances = new List<Object>(Key.numInstances + 1) {

    modules.forEach((module) {
      module.bindings.forEach((Key key, Binding binding)
          => _bindings[key.id] = binding);
    });
    _instances[_INJECTOR_KEY.id] = this;
  }

  Iterable<Type> _typesCache;

  Iterable<Type> get _types {
    if (_bindings == null) return [];

    if (_typesCache == null) {
      _typesCache = _bindings
          .where((p) => p != null)
          .map((p) => p.key.type);
    }
    return _typesCache;
  }

  Set<Type> get types {
    var types = new Set<Type>();
    for (var node = this; node.parent != null; node = node.parent) {
      types.addAll(node._types);
    }
    return types;
  }

  /**
   * Returns the instance associated with the given key (i.e. [type] and
   * [annotation]) according to the following rules.
   *
   * Let I be the nearest ancestor injector (possibly this one) that both
   *
   * - binds some [Provider] P to [key] and
   * - P's visibility declares that I is visible to this injector.
   *
   * If there is no such I, then throw
   *   [NoProviderError].
   *
   * Once I and P are found, if I already created an instance for the key,
   * it is returned.  Otherwise, P is used to create an instance, using I
   * as an [ObjectFactory] to resolve the necessary dependencies.
   */
  dynamic get(Type type, [Type annotation])
      => getByKey(new Key(type, annotation));

  /**
   * Faster version of [get].
   */
  dynamic getByKey(Key key, {int depth: 0}){
    var instance;
    if (key.id < _instances.length) {
      instance = _instances[key.id];
    }
    if (instance != null) return instance;

    var injector = this;
    Binding binding = key.id < _bindings.length ?
        _bindings[key.id] : null;

    while (binding == null) {
      try {
        injector = injector.parent;
        binding = key.id < injector._bindings.length ?
            injector._bindings[key.id] : null;
      } on NoParentError catch (e) {
        throw new NoProviderError("No provider found for $key!");
      }
    }

    if (depth > 50)
      throw new CircularDependencyError(key);
    var params;
    try {
      params = binding.parameterKeys.map((Key paramKey) =>
          getByKey(paramKey, depth: depth + 1)).toList();
    } on CircularDependencyError catch (e) {
      throw new CircularDependencyError(key, e);
    }

    return _instances[key.id] = binding.factory(params);
  }

  /**
   * Creates a child injector.
   *
   * [modules] overrides bindings of the parent.
   */
  @deprecated
  Injector createChild(List<Module> modules) {
    return new Injector(modules, this);
  }
}
