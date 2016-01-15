package co.edu.javeriana.isml.generator.simple.generators

import co.edu.javeriana.isml.generator.common.SimpleGenerator
import co.edu.javeriana.isml.generator.simple.SimpleGeneratorSuite
import co.edu.javeriana.isml.generator.simple.templates.EntityTemplate
import co.edu.javeriana.isml.isml.Entity
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider

class EntityGenerator extends SimpleGenerator<Entity> {
	@Inject extension IQualifiedNameProvider

	override getFileName(Entity e) {
		return e.eContainer?.fullyQualifiedName.toString("/").toLowerCase + "/" + e.name + ".txt"
	}

	override getOutputConfigurationName() {
		SimpleGeneratorSuite.SIMPLE_OUTPUT
	}
	
	override getTemplate() {
		return new EntityTemplate

	}

}
