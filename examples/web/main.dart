import 'package:di/di.dart';
import 'dart:html';

@Injectable()
class Application {
  run() {
    window.alert("WORKS");
  }
}

main() {
  Module module = new Module();
  module.bind(Application);
  new ModuleInjector([module]).get(Application).run();
}
