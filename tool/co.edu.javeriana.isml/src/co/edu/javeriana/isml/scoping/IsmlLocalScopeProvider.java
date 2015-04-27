package co.edu.javeriana.isml.scoping;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.xtext.naming.QualifiedName;
import org.eclipse.xtext.scoping.impl.ImportNormalizer;
import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider;

public class IsmlLocalScopeProvider extends
		ImportedNamespaceAwareLocalScopeProvider {

	@Override
	protected List<ImportNormalizer> getImplicitImports(boolean ignoreCase) {
		List<ImportNormalizer> imports = new ArrayList<ImportNormalizer>();
		// imports.add(new ImportNormalizer(QualifiedName.create("builtin",
		// "types",
		// "namespace"), true, ignoreCase));
		imports.add(new ImportNormalizer(QualifiedName.create("common", "primitives"), true, ignoreCase));
		imports.add(new ImportNormalizer(QualifiedName.create("common", "widgets"), true, ignoreCase));
		imports.add(new ImportNormalizer(QualifiedName.create("common", "constraints"), true, ignoreCase));
		return imports;
	}

}
