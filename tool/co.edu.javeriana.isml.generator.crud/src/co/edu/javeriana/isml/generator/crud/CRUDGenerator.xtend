package co.edu.javeriana.isml.generator.crud

import co.edu.javeriana.isml.generator.common.GeneratorSuite
import co.edu.javeriana.isml.generator.common.OutputConfiguration
import co.edu.javeriana.isml.generator.crud.generators.SelectToAddPageGenerator
import co.edu.javeriana.isml.generator.crud.generators.SubListPageGenerator
import co.edu.javeriana.isml.generator.crud.generators.ViewPageGenerator
import co.edu.javeriana.isml.generator.crud.generators.AddPageGenerator
import co.edu.javeriana.isml.generator.crud.generators.ControllerGenerator
import co.edu.javeriana.isml.generator.crud.generators.EditPageGenerator
import co.edu.javeriana.isml.generator.crud.generators.ListPageGenerator
import co.edu.javeriana.isml.generator.crud.generators.SelectToAssignPageGenerator

/**
 * Generates code from your model files on save.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class CRUDGenerator extends GeneratorSuite {
	@OutputConfiguration
	public static final String CONTROLLERS = "controllers";
	public static final String PAGES = "pages";

	override getGenerators() {
		#{
			new ControllerGenerator,
			new EditPageGenerator,
			new ListPageGenerator,
			new ViewPageGenerator,
			new AddPageGenerator,
			new SelectToAddPageGenerator,
			new SelectToAssignPageGenerator,
			new SubListPageGenerator
			
		}
	}

}
