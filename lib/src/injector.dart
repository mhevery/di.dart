part of di;

Key _INJECTOR_KEY = new Key(Injector);

abstract class Injector {

  /**
   * The parent injector.
   */
  final Injector parent;

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
  dynamic getByKey(Key key, {int depth});

  /**
   * Creates a child injector.
   *
   * [modules] overrides bindings of the parent.
   */
  @deprecated
  Injector createChild(List<Module> modules);
}


class RootInjector implements Injector {
  Injector get parent => null;
  List<Object> get _instances => null;
  dynamic getByKey(key) => throw new NoProviderError(key);
  const RootInjector();
}

class ModuleInjector extends Injector {

  static const rootInjector = const RootInjector();
  final Injector parent;

  List<Binding> _bindings;
  List<Object> _instances;

  ModuleInjector(List<Module> modules, [Injector parent])
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
    types.add(Injector);
    return types;
  }

  dynamic getByKey(Key key, {int depth: 0}){
    var instance;
    if (key.id < _instances.length) {
      instance = _instances[key.id];
    }
    if (instance != null) return instance;

    Binding binding = key.id < _bindings.length ?
        _bindings[key.id] : null;

    if (binding == null) {
      return _instances[key.id] = parent.getByKey(key);
    }

    if (depth > 50)
      throw new CircularDependencyError(key);
    var params;
    try {
      //TODO: do we need a new list here for params or can we reuse?
      // seems reusable unless this function gets called during binding.factory(params)
      params = binding.parameterKeys.map((Key paramKey) =>
          getByKey(paramKey, depth: depth + 1)).toList();
    } on CircularDependencyError catch (e) {
      throw new CircularDependencyError(key, e);
    } on NoProviderError catch (e) {
      throw new NoProviderError(key, e);
    }

    return _instances[key.id] = binding.factory(params);
  }

  @deprecated
  Injector createChild(List<Module> modules) {
    return new ModuleInjector(modules, this);
  }
}
