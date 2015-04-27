package co.edu.javeriana.isml.generator.crud.templates

import co.edu.javeriana.isml.generator.common.SimpleTemplate
import co.edu.javeriana.isml.isml.Attribute
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.scoping.TypeExtension
import co.edu.javeriana.isml.validation.TypeChecker
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider

class ViewPageTemplate extends SimpleTemplate<Entity> {
	@Inject extension IQualifiedNameProvider
	@Inject extension CommonTemplates
	@Inject extension TypeExtension
	@Inject extension TypeChecker

	override protected template(Entity e) '''
		package «e.eContainer?.fullyQualifiedName»
		
		page «e.viewPage»(«e.name» «e.variable») controlledBy «e.controllerName» {
			Panel("«e.name.toLabel»") {
				«FOR attr : e.allAttributes»
					«templateView(e, attr, true)»
				«ENDFOR»

				Button("Ok", false) -> listAll()
			}
		}
	'''


}
