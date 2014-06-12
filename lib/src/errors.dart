part of di;

class InvalidBindingError extends ArgumentError {
  InvalidBindingError(message) : super(message);
}

class NoProviderError extends ArgumentError {
  NoProviderError(message) : super(message);
}

class CircularDependencyError extends Error {
  static const messagePrefix = "Cannot resolve a circular dependency! \n(";
  static const messageSuffix = ")";
  static const delimiter = " -> ";

  final Key key;
  final CircularDependencyError parent;
  String message;
  CircularDependencyError(this.key, [this.parent]) : super();

  String toString() {
    if (message != null) return message;
    StringBuffer buffer = new StringBuffer(messagePrefix);
    Set<Key> seenKeys = new Set<Key>();

    error = this;
    while (true) {
      buffer.write(error.key);
      error = error.parent;
      if (error == null || !seenKeys.add(error.key)) break;
      buffer.write(delimiter);
    }
    buffer.write(messageSuffix);
    return message = buffer.toString();
  }
}

class NoParentError extends ArgumentError {
  NoParentError(message) : super(message);
}
