library di.key;

import 'dart:collection';


/**
 * Key to which an [Injector] binds a [Provider].  This is a pair consisting of
 * a [type] and an optional [annotation].
 */
class Key {
  // TODO: experiment with having a separate map for non-annotated types (perf)
  static Map<Type, Map<Type, Key>> _typeToAnnotationToKey = new Map.identity();
  static List<Key> _keys = new List();
  static int _numInstances = 0;
  /// The number of instances of [Key] created.
  static int get numInstances => _numInstances;

  final Type type;
  /// Optional.
  final Type annotation;
  /// Assigned via auto-increment.
  final int id;

  int _data;
  int get data => _data;
  set data(int d) {
    if (_data == null) {
      _data = d;
      return;
    }
    throw "Key($type).data has already been set to $_data.";
  }

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

  // TODO: consider deprecating factory constructor and move it here instead
  // Or delete this method.
  static Key getKeyFor(Type type, [Type annotation]) {
    return new Key(type, annotation);
  }

  Key._(this.type, this.annotation, this.id);

  String toString() {
    String asString = type.toString();
    if (annotation != null) {
      asString += ' annotated with: $annotation';
    }
    return asString;
  }
}
