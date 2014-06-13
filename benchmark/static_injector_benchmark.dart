import 'package:di/static_injector.dart';

import 'injector_benchmark_common.dart';

main() {
  new InjectorBenchmark('StaticInjectorBenchmark',
      new GeneratedTypeFactories(typeFactories, paramKeys)
  ).report();
}