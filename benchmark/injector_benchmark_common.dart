library di.injector_benchmark_common;

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:di/di.dart';

int count = 0;

class InjectorBenchmark extends BenchmarkBase {
  var module;
  var typeReflector;

  InjectorBenchmark(name, this.typeReflector) : super(name);

  void run() {
    Injector injector = new ModuleInjector([module]);
    injector.get(A);
    injector.get(B);

    var childInjector = injector.createChild([module]);
    childInjector.get(A);
    childInjector.get(B);
  }

  setup() {
    module = new Module.withReflector(typeReflector)
      ..type(A)
      ..type(B)
      ..type(C)
      ..type(C) // TODO: , withAnnotation: AnnOne, implementedBy: COne )
      ..type(D)
      ..type(E)
      ..type(E); // TODO: , withAnnotation: AnnTwo, implementedBy: ETwo )
//      ..type(F)
//      ..type(G);
  }

  teardown() {
    print(count);
  }
}

class AnnOne {
  const AnnOne();
}

class AnnTwo {
  const AnnTwo();
}

class A {
  A(B b, C c) {
    count++;
  }
}

class B {
  B(D b, E c) {
    count++;
  }
}

class C {
  C() {
    count++;
  }
}

class COne {
  COne() {
    count++;
  }
}

class D {
  D() {
    count++;
  }
}

class E {
  E() {
    count++;
  }
}

class ETwo {
  ETwo() {
    count++;
  }
}

class F {
  F(@AnnOne() C c, D d) {
    count++;
  }
}

class G {
  G(@AnnTwo() E e) {
    count++;
  }
}

var typeFactories = {
    new Key(A): (p) => new A(p[0], p[1]),
    new Key(B): (p) => new B(p[0], p[1]),
    new Key(C): (p) => new C(),
    new Key(D): (p) => new D(),
    new Key(E): (p) => new E(),
};

var paramKeys = {
    new Key(A): [new Key(B), new Key(C)],
    new Key(B): [new Key(D), new Key(E)],
    new Key(C): const [],
    new Key(D): const [],
    new Key(E): const [],
};
