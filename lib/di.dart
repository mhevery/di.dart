library di;

import 'key.dart';

// The ImportTransformer replaces the following line with
// import 'generated_type_factories.dart';
import 'dynamic_type_factories.dart';

export 'key.dart' show Key, key;
export 'annotations.dart';

part 'src/injector.dart';
part 'src/module.dart';
part 'src/errors.dart';
part 'src/reflector.dart';
