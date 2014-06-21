import 'package:di/di.dart';
import 'package:di/generated_type_factories.dart';
import 'injector_benchmark_common.dart';

main() {
  new InjectorBenchmark('StaticInjectorBenchmark',
      new GeneratedTypeFactories(typeFactories, paramKeys)
  ).report();
}
