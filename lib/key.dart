library di.key;

import 'dart:collection';

/**
 * Key to which an [Injector] binds a [Provider].  This is a pair consisting of
 * a [type] and an optional [annotation].
 */
class Key {
  static Map<Type, Map<Type, Key>> _typeToAnnotationToKey = new Map.identity();
  static List<Key> _keys = new List();
  static int _numInstances = 0;
  /// The number of instances of [Key] created.
  static int get numInstances => _numInstances;

  // TODO: write tests for this
  static Key getByID(int id) {
    if (id < _keys.length) {
      var key = _keys[id];
      if (key != null) {
        return key;
      }
    }
    throw "Key.getByID: No key cached for id $id.";
  }

  final Type type;
  /// Optional.
  final Type annotation;
  /// Assigned via auto-increment.
  final int id;

  int get hashCode => id;

  /**
   * Creates a new key or returns one from a cache if given the same inputs that
   * a previous call had.  E.g. `identical(new Key(t, a), new Key(t, a))` holds.
   */
  factory Key(Type type, [Type annotation]) {
    // Don't use Map.putIfAbsent -- too slow!
    var annotationToKey = _typeToAnnotationToKey[type];
    if (annotationToKey == null) {
      _typeToAnnotationToKey[type] = annotationToKey = new Map();
    }
    Key key = annotationToKey[annotation];
    if (key == null) {
      annotationToKey[annotation] =
          key = new Key._(type, annotation, _numInstances++);
      _keys.add(key);
    }
    assert(_keys.length == _numInstances);
    return key;
  }

  Key._(this.type, this.annotation, this.id);

  // TODO: Write tests for this
  factory Key.withID(int id, Type type, [Type annotation]) {
    if (id < _numInstances) {
      var key = _keys[id];
      if (key.type == type && key.annotation == annotation){
        return key;
      } else {
        throw "Key.withID: Key id '$id' is already taken by ${key.type}" +
            key.annotation == null ? "." : " with annotation ${key.annotation}.";
      }
    }
    assert(id - _numInstances < 64); //wastes memory with blank space in each injector
    var annotationToKey = _typeToAnnotationToKey[type];
    if (annotationToKey != null) {
      var key = annotationToKey[annotation];
      if (key != null) {
        throw "Key.withID: type '$type' " +
            key.annotation == null ? "" : "with annotation ${key.annotation} " +
            "already has a key with id '${key.id}'.";
      }
    }
    _keys.length = id + 1;
    _numInstances = id + 1;
    return _keys[id + 1] = new Key._(type, annotation, id);
  }

  String toString() {
    String asString = type.toString();
    if (annotation != null) {
      asString += ' annotated with: $annotation';
    }
    return asString;
  }
}
