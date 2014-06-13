part of di;

// TODO: clean up errors
// TODO: pull reflection code to a different import
// TODO: The caches should work on Types not on Keys,
//       since there is 1to1 relationship between type and factory, There is many to 1 relationship
//       between key and type.
// TODO: add toClosure in addition to toFactory
// TODO: write a verifier that toClosure signature matches inject attribute!

abstract class TypeReflector {
  Factory factoryFor(Key key);
  List<Key> parameterKeysFor(Key key);
}

class GeneratedTypeFactories extends TypeReflector {
  static GeneratedTypeFactories _instance;

  Map<Key, Factory> _factories;
  Map<Key, List<Key>> _parameterKeys;

  GeneratedTypeFactories._(Map<Key, Factory> this._factories,
                           Map<Key, List<Key>>this._parameterKeys);

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

  Factory factoryFor(Key key) {
    var keys = _factories[key];
    if (keys != null) return keys;
    throw new NoProviderError(key);
  }

  List<Key> parameterKeysFor(Key key) {
    var keys = _parameterKeys[key];
    if (keys != null) return keys;
    throw new NoProviderError(key);
  }
}

class DynamicTypeFactories extends TypeReflector {
  final List<Factory> _factories = new List<Factory>();
  final List<List<Key>> _parameterKeys = new List<List<Key>>();

  Factory factoryFor(Key key) {
    _resize(key.id);
    Factory factory = _factories[key.id];
    if (factory == null) {
      factory = _factories[key.id] = _generateFactory(key.type);
    }
    return factory;
  }


  List<Key> parameterKeysFor(Key key) {
    _resize(key.id);
    List<Key> parameterKeys = _parameterKeys[key.id];
    if (parameterKeys == null) {
      parameterKeys = _parameterKeys[key.id] = _generateParameterKeys(key.type);
    }
    return parameterKeys;
  }

  _resize(maxId) {
    if (_factories.length <= maxId) {
      _factories.length = maxId + 1;
      _parameterKeys.length = maxId + 1;
    }
  }

  Factory _generateFactory(Type type) {
    TypeMirror classMirror = _reflectClass(type);
    MethodMirror ctor = classMirror.declarations[classMirror.simpleName];
    return (List args) => classMirror.newInstance(ctor.constructorName, args).reflectee;
  }

  List<Key> _generateParameterKeys(Type type) {
    TypeMirror classMirror = _reflectClass(type);
    MethodMirror ctor = classMirror.declarations[classMirror.simpleName];

    return new List.generate(ctor.parameters.length, (int pos) {
      ParameterMirror p = ctor.parameters[pos];
      if (p.type.qualifiedName == #dynamic) {
        var name = MirrorSystem.getName(p.simpleName);
        throw new ArgumentError("Error getting params for '$type': The '$name' parameter must be typed");
      }
      if (p.type is TypedefMirror) {
        throw new ArgumentError(
            "Typedef '${p.type}' in constructor '${classMirror.simpleName}' is not supported.");
      }
      if (p.metadata.length > 1) {
        throw new ArgumentError(
            "Constructor '${classMirror.simpleName}' parameter $pos of type '${p.type}' "
            "can have only zero on one annotation, but it has '${p.metadata}'.");
      }
      var pType = (p.type as ClassMirror).reflectedType;
      var annotationType = p.metadata.isNotEmpty ? p.metadata.first.type.reflectedType : null;
      return new Key(pType, annotationType);
    }, growable:false);
  }

  TypeMirror _reflectClass(Type type) {
    // TODO: cache this
    TypeMirror classMirror = reflectType(type);
    if (classMirror is TypedefMirror) {
      throw new NoProviderError(
          'No implementation provided for ${getSymbolName(classMirror.qualifiedName)} typedef!');
    }

    MethodMirror ctor = classMirror.declarations[classMirror.simpleName];

    if (ctor == null) {
      throw new NoProviderError('Unable to find default constructor for $type. '
      'Make sure class has a default constructor.' + (1.0 is int ?
      'Make sure you have correctly configured @MirrorsUsed.' : ''));
    }
    return classMirror;
  }
}

