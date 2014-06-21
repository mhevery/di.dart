part of di.transformer;

/**
 * Changes di.dart to import static version of TypeReflector
 */
class ImportTransformer extends Transformer with ResolverTransformer {
  final TransformOptions options;

  ImportTransformer(this.options, Resolvers resolvers) {
    this.resolvers = resolvers;
  }

  Future<bool> isPrimary(AssetId id) {
    var di = new AssetId.parse('di|lib/di.dart');
    if (di == id) {
      return new Future.value(true);
    }
    return new Future.value(false);
  }

  Future<bool> shouldApplyResolver(Asset asset) => new Future.value(true);

  applyResolver(Transform transform, Resolver resolver) {
    Asset asset = transform.primaryInput;
    AssetId id = asset.id;
    var lib = resolver.getLibrary(id);
    var unit = lib.definingCompilationUnit.node;
    var transaction = resolver.createTextEditTransaction(lib);

    var dir = unit.directives.where((d) =>
        d is ImportDirective && d.uriContent == 'dynamic_type_factories.dart').first;
    transaction.edit(dir.offset, dir.end, "import 'generated_type_factories.dart';");

    commitTransaction(transaction, transform);
  }
}
