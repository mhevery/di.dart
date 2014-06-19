import 'package:analyzer/src/generated/element.dart';

typedef String IdentifierResolver(InterfaceType type);
/**
 * Takes classes and writes to StringBuffers the corresponding keys, factories,
 * and paramLists needed for static injection.
 *
 * resolveClassIdentifier is a function passed in to be called to resolve imports
 */
void process_classes(Iterable<ClassElement> classes, StringBuffer keys,
                     StringBuffer factories, StringBuffer paramLists,
                     IdentifierResolver resolveClassIdentifier) {

  Map<String, String> toBeAdded = new Map<String, String>();
  Set<String> addedKeys = new Set();
  classes.forEach((ClassElement clazz) {
    StringBuffer factory = new StringBuffer();
    StringBuffer paramList = new StringBuffer();
    List<String> factoryKeys = new List<String>();
    bool skip = false;
    if (addedKeys.add(clazz.type.name)){
      toBeAdded[clazz.type.name]=
      'final Key _KEY_${clazz.type.name} = new Key(${resolveClassIdentifier(clazz.type)});\n';
    }
    factoryKeys.add('${clazz.type.name}');

    ConstructorElement constr =
    clazz.constructors.firstWhere((c) => c.name.isEmpty,
    orElse: () {
      throw 'Unable to find default constructor for '
      '$clazz in ${clazz.source}';
    });
    factory.write('${resolveClassIdentifier(clazz.type)}: (p) => new ${resolveClassIdentifier(clazz.type)}(');
    factory.write(new List.generate(constr.parameters.length, (i) => 'p[$i]').join(', '));
    factory.write('),\n');

    paramList.write('${resolveClassIdentifier(clazz.type)}: ');
    if (constr.parameters.isEmpty){
      paramList.write('const [');
    } else {
      paramList.write('[');
      paramList.write(constr.parameters.map((param) {
        if (param.type.element is! ClassElement) {
          throw 'Unable to resolve type for constructor parameter '
          '"${param.name}" for type "$clazz" in ${clazz.source}';
        }
        if (_isParameterized(param)) {
          print('WARNING: parameterized types are not supported: '
          '$param in $clazz in ${clazz.source}. Skipping!');
          skip = true;
        }
        var annotations = [];
        if (param.metadata.isNotEmpty) {
          annotations = param.metadata.map(
                  (item) => item.element.returnType.name);
        }
        String key_name = annotations.isNotEmpty ?
        '${param.type.name}_${annotations.first}' : param.type.name;
        String output = '_KEY_${key_name}';
        if (addedKeys.add(key_name)){
          var annotationParam = "";
          if (param.metadata.isNotEmpty) {
            annotationParam = ", ${resolveClassIdentifier(param.metadata.first.element.returnType)}";
          }
          toBeAdded['$key_name']='final Key _KEY_${key_name} = '+
          'new Key(${resolveClassIdentifier(param.type)}$annotationParam);\n';
        }
        return output;
      }).join(', '));
    }
    paramList.write('],\n');
    if (!skip) {
      factoryKeys.forEach((key) {
        var keyString = toBeAdded.remove(key);
        keys.write(keyString);
      });
      factories.write(factory);
      paramLists.write(paramList);
    }
  });
  keys.writeAll(toBeAdded.values);
  toBeAdded.clear();
}

_isParameterized(ParameterElement param) {
  String typeName = param.type.toString();

  if (typeName.indexOf('<') > -1) {
    String parameters =
    typeName.substring(typeName.indexOf('<') + 1, typeName.length - 1);
    return parameters.split(', ').any((p) => p != 'dynamic');
  }
  return false;
}
