part of di;

_DEFAULT_VALUE(_) => null;
typedef dynamic Factory(List<dynamic> parameters);

class Binding {
  Key key;
  List<Key> parameterKeys;
  Factory factory;
  Binding(this.key, this.parameterKeys, this.factory);
}

/**
 * Module contributes configuration information to an [Injector] by providing
 * a collection of type bindings that specify how each type is created.
 *
 * When an injector is created, it copies its configuration information from a
 * module. Defining additional type bindings after an injector is created have
 * no effect on that injector.
 */
class Module {
  static final TypeReflector DEFAULT_REFLECTOR = getTypeReflector();
  final TypeReflector reflector;

  Module(): reflector = DEFAULT_REFLECTOR;
  Module.withReflector(this.reflector);

  Map<Key, Binding> bindings = new Map<Key, Binding>();

  install(Module module) => module.bindings.forEach((key, binding) => bindings[key] = binding);

  /**
   * Registers a binding for a given [type].
   *
   * The default behavior is to simply instantiate the type.
   *
   * The following parameters can be specified:
   *
   * * [toImplementation]: The given type will be instantiated using the [new]
   *   operator and the resulting instance will be injected.
   * * [toFactory]: The result of the factory function is the value that will
   *   be injected.
   * * [toValue]: The given value will be injected.
   * * [withAnnotation]: Type decorated with additional annotation.
   *
   * Up to one (0 or 1) of the following parameters can be specified at the
   * same time: [toImplementation], [toFactory], [toValue].
   */
  void bind(Type type, {dynamic toValue: _DEFAULT_VALUE,
      Factory toFactory: _DEFAULT_VALUE, Type toImplementation,
      List inject: const [], Type withAnnotation}) {
    bindByKey(new Key(type, withAnnotation), toValue: toValue,
        toFactory: toFactory, toImplementation: toImplementation, inject: inject);
  }

  /**
   * Same as [bind] except it takes [Key] instead of
   * [Type] [withAnnotation] combination. Faster.
   */
  void bindByKey(Key key, {dynamic toValue: _DEFAULT_VALUE,
      Factory toFactory: _DEFAULT_VALUE, List inject: const [], Type toImplementation}) {
    if (inject.length == 1 && toFactory == _DEFAULT_VALUE) {
      toFactory = (p) => p[0];
    }

    _checkBindArgs(toValue, toFactory, toImplementation);

    List<Key> parameterKeys;
    Factory factory;

    if (!identical(toValue, _DEFAULT_VALUE)) {
      factory = (_) => toValue;
      parameterKeys = const [];
    } else if (!identical(toFactory, _DEFAULT_VALUE)) {
      factory = toFactory;
      parameterKeys = inject.map((t) {
        if (t is Key) return t;
        if (t is Type) return new Key(t);
        throw "inject must be Keys or Types. '$t' is not an instance of Key or Type.";
      }).toList(growable: false);
    } else {
      var implementationType = toImplementation == null ? key.type : toImplementation;
      parameterKeys = reflector.parameterKeysFor(implementationType);
      factory = reflector.factoryFor(implementationType);
    }
    bindings[key] = new Binding(key, parameterKeys, factory);
  }

  _checkBindArgs(toValue, toFactory, toImplementation) {
    int count = 0;
    if (!identical(toValue, _DEFAULT_VALUE)) count++;
    if (!identical(toFactory, _DEFAULT_VALUE)) count++;
    if (toImplementation != null) count++;
    if (count > 1) {
      throw 'Only one of following parameters can be specified: '
            'toValue, toFactory, toImplementation';
    }
    return true;
  }

  /**
   * Register a binding to a concrete value.
   *
   * The [value] is what actually will be injected.
   */
  @Deprecated("Use bind(type, toValue: value)")
  void value(Type id, value, {Type withAnnotation}) {
    bind(id, toValue: value, withAnnotation: withAnnotation);
  }

  /**
   * Registers a binding for a [Type].
   *
   * The default behavior is to simply instantiate the type.
   *
   * The following parameters can be specified:
   *
   * * [withAnnotation]: Type decorated with additional annotation.
   * * [implementedBy]: The type will be instantiated using the [new] operator
   *   and the resulting instance will be injected. If no type is provided,
   *   then it's implied that [type] should be instantiated.
   * * [visibility]: Function which determines fi the requesting injector can
   *   see the type in the current injector.
   */
  @Deprecated("Use bind(type, implementedBy: impl)")
  void type(Type type, {Type withAnnotation, Type implementedBy}) {
    bind(type, withAnnotation: withAnnotation,
        toImplementation: implementedBy);
  }

  @Deprecated("Use bindByKey(type, toFactory: factory)")
  void factoryByKey(Key key, Factory factoryFn) {
    bindByKey(key, toFactory: factoryFn);
  }
}
