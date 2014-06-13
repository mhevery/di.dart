part of di;

abstract class BaseError extends Error {
  final String message;
  String toString() => message;
  BaseError(this.message);
}

class InvalidBindingError extends BaseError {
  InvalidBindingError(message) : super(message);
}

abstract class ResolvingError extends Error {

  final Object node;
  final ResolvingError parent;

  ResolvingError(this.node, [this.parent]);

  String get resolveChain {
    StringBuffer buffer = new StringBuffer();
    buffer.write("(resolving ");
    Set seenNodes = new Set();

    ResolvingError error = this;
    while (true) {
      buffer.write(error.node);
      error = error.parent;
      if (error == null || !seenNodes.add(error.node)) break;
      buffer.write(" -> ");
    }
    buffer.write(")");
    return buffer.toString();
  }

  String toString() => resolveChain;
}

class NoProviderError extends ResolvingError {
  static final List<Key> _PRIMITIVE_TYPES = <Key>[
      new Key(num), new Key(int), new Key(double), new Key(String),
      new Key(bool)
  ];
  final NoProviderError parent;

  // To throw different error if lack of provider is due to injecting primitive type
  Key rootPrimitiveType() {
    if (parent == null) {
      return _PRIMITIVE_TYPES.contains(node) ? node : null;
    }
    return parent.rootPrimitiveType();
  }

  String toString(){
    var primitive = rootPrimitiveType();
    if (primitive != null) {
      return 'Cannot inject a primitive type of $primitive! $resolveChain';
    }
    return "No provider found for $node! $resolveChain";
  }
  NoProviderError(key, [this.parent]): super(key);
}

class CircularDependencyError extends ResolvingError {
  String toString() => "Cannot resolve a circular dependency! $resolveChain";
  CircularDependencyError(key, [parent]) : super(key, parent);
}

class NoParentError extends BaseError {
  NoParentError(message) : super(message);
}
