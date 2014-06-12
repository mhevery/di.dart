part of di;

abstract class TypeReflector {
  Factory factoryFor(Key key);
  List<Key> parameterKeysFor(Key key);
}

class GeneratedTypeFactories extends TypeReflector {
  static GeneratedTypeFactories _instance;

  final List<Factory> _factories;
  final List<List<Key>> _parameterKeys;
  GeneratedTypeFactories._(List<Factory> this._factories, List<List<Key>> this._parameterKeys);

  factory GeneratedTypeFactories([f, p]){
    if (_instance != null) {
      assert (f == null && p == null);
      return _instance;
    }
    assert (f != null && p != null);
    return _instance = new GeneratedTypeFactories._(f, p);
  }

  Factory factoryFor(Key key) {
    assert (_factories[key.id] != null);
    return _factories[key.id];
  }

  List<Key> parameterKeysFor(Key key) {
    assert (_parameterKeys[key.id] != null);
    return _parameterKeys[key.id];
  }
}

class MirrorReflector {

}

