package co.edu.javeriana.isml.generator.crud.generators

import co.edu.javeriana.isml.generator.common.SimpleGenerator
import co.edu.javeriana.isml.generator.crud.CRUDGenerator
import co.edu.javeriana.isml.generator.crud.templates.CommonTemplates
import co.edu.javeriana.isml.isml.Entity
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import co.edu.javeriana.isml.generator.crud.templates.AddPageTemplate

class AddPageGenerator extends SimpleGenerator<Entity> {
	@Inject extension IQualifiedNameProvider
	@Inject extension CommonTemplates

	override protected getFileName(Entity e) {
		e.eContainer?.fullyQualifiedName.toString("/").toLowerCase + "/" + e.createToAddPage + ".isml"
	}

	override protected getOutputConfigurationName() {
		CRUDGenerator.PAGES
	}

	override getTemplate() {
		new AddPageTemplate
	}

}
