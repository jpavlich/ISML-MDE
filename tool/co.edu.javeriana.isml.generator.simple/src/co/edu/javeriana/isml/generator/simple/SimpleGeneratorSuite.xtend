package co.edu.javeriana.isml.generator.simple

import co.edu.javeriana.isml.generator.common.GeneratorSuite
import co.edu.javeriana.isml.generator.simple.generators.EntityGenerator
import co.edu.javeriana.isml.generator.common.OutputConfiguration

/**
 * Generates code from your model files on save.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class SimpleGeneratorSuite extends GeneratorSuite {
	@OutputConfiguration
	public static final String SIMPLE_OUTPUT = "SIMPLE_OUTPUT";
	
	override getGenerators() {
		#{
			new EntityGenerator
		}
	}

}
