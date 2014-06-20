library di.transformer.type_reflector_transformer;

import 'dart:async';
import 'package:analyzer/src/generated/ast.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:di/transformer/options.dart';
import 'package:di/transformer/refactor.dart';
import 'package:path/path.dart' as path;

/**
 * Changes di.dart to import static version of TypeReflector
 */
class ImportTransformer extends Transformer with ResolverTransformer {
  final TransformOptions options;

  ImportTransformer(this.options, Resolvers resolvers) {
    this.resolvers = resolvers;
  }

  Future<bool> shouldApplyResolver(Asset asset) {
    var di = new AssetId.parse('di|lib/di.dart');
    print("> ${asset.id}");
    return new Future.value(di == asset.id);
  }

  applyResolver(Transform transform, Resolver resolver) {
    Asset asset = transform.primaryInput;
    AssetId id = asset.id;
    var lib = resolver.getLibrary(id);
    var unit = lib.definingCompilationUnit.node;
    var transaction = resolver.createTextEditTransaction(lib);

    var dir = unit.directives.where((d) =>
        d is ImportDirective && d.uriContent == 'dynamic_type_factories.dart').first;
    transaction.edit(dir.offest, dir.end, "import 'generated_type_factories.dart';");

    commitTransaction(transaction, transform);
  }
}
