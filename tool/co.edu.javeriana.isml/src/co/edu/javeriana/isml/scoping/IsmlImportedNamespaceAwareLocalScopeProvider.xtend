package co.edu.javeriana.isml.scoping

import co.edu.javeriana.isml.isml.Import
import co.edu.javeriana.isml.isml.IsmlPackage
import co.edu.javeriana.isml.isml.Package
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider

class IsmlImportedNamespaceAwareLocalScopeProvider extends ImportedNamespaceAwareLocalScopeProvider {
	@Inject extension IQualifiedNameProvider

	protected override def internalGetImportedNamespaceResolvers(EObject context, boolean ignoreCase) {

		//		println("Importing from " + context)
		var result = super.internalGetImportedNamespaceResolvers(context, ignoreCase);
		switch (context) {
			Package: {
				// By default adds the current package as an implicit import
				// so that elements in packages with the same name in other modesl
				// can be used in the current model
				result.add(createImportedNamespaceResolver(context.fullyQualifiedName.toString + ".*", false))
				// Adds default imports
				result.add(createImportedNamespaceResolver("common.primitives.*", false))
				result.add(createImportedNamespaceResolver("common.widgets.*", false))
				result.add(createImportedNamespaceResolver("common.constraints.*", false))
				result.add(createImportedNamespaceResolver("common.services.*", false))
				result.add(createImportedNamespaceResolver("common.controllers.*", false))

			}
			default: {
			}
		}
		return result;
	}

	protected override String getImportedNamespace(EObject object) {
		if (object instanceof Import) {

			//			println("*** Finding import string for " + object)
			var imp = object as Import

			// Based in http://blog2.vorburger.ch/2013/05/xtext-dsl-with-epackage-namespace.html
			var nodes = NodeModelUtils.findNodesForFeature(imp, IsmlPackage.Literals.IMPORT__IMPORTED_PACKAGE);
			var node = nodes.get(0);
			var importString = NodeModelUtils.getTokenText(node) + ".*";

			//			println(object + "--> Imported: " + importString)
			return importString
		}

		return null

	}

}
