library di.transformer.type_reflector_transformer;

import 'dart:async';
import 'package:analyzer/src/generated/ast.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:di/transformer/options.dart';
import 'package:path/path.dart' as path;

/**
 * Adds the line in main() that instantiates a GeneratedTypeFactories instance
 * with statically generated maps of factories and paramKeys.
 */
class InitializerTransformer extends Transformer with ResolverTransformer {
  final TransformOptions options;

  InitializerTransformer(this.options, Resolvers resolvers) {
    this.resolvers = resolvers;
  }

  applyResolver(Transform transform, Resolver resolver) {
    Asset asset = transform.primaryInput;
    var id = asset.id;
    var lib = resolver.getLibrary(id);
    var unit = lib.definingCompilationUnit;
    var transaction = resolver.createTextEditTransaction(lib);

    var last = unit.directives.where((d) => d is ImportDirective).last;
    transaction.edit(last.end, last.end, '\nimport '
        '${path.url.basenameWithoutExtension(id.path)}'
        '_generated_type_factory_maps.dart');

    var printer = transaction.commit();
    var url = id.path.startsWith('lib/')
        ? 'package:${id.package}/${id.path.substring(4)}' : id.path;
    printer.build(url);
    transform.addOutput(new Asset.fromString(id, printer.text));
  }
}
