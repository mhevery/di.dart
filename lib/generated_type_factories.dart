library di.generated_type_factories;

import 'di.dart';

TypeReflector getTypeReflector() => new GeneratedTypeFactories();

class GeneratedTypeFactories extends TypeReflector {
  static GeneratedTypeFactories _instance;

  Map<Type, Factory> _factories;
  Map<Type, List<Key>> _parameterKeys;

  GeneratedTypeFactories._(Map<Type, Factory> this._factories,
                           Map<Type, List<Key>>this._parameterKeys);

  factory GeneratedTypeFactories([f, p]) {
    if (_instance != null) {
      assert (f == null && p == null);
      return _instance;
    }
    if (f == null || p == null) {
      throw "GeneratedTypeFactories not initialized. "
      "Initialize by calling 'new GeneratedTypeFactories(factories, paramKeys)' "
      "passing in generated code before any modules are initialized.";
    }
    assert (f != null && p != null);
    return _instance = new GeneratedTypeFactories._(f, p);
  }

  Factory factoryFor(Type type) {
    var keys = _factories[type];
    if (keys != null) return keys;
    throw new NoProviderError(new Key(type));
  }

  List<Key> parameterKeysFor(Type type) {
    var keys = _parameterKeys[type];
    if (keys != null) return keys;
    throw new NoProviderError(new Key(type));
  }
}
