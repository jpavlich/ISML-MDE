package co.edu.javeriana.isml.generator.crud.templates

import co.edu.javeriana.isml.generator.common.SimpleTemplate
import co.edu.javeriana.isml.isml.Attribute
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.isml.ParameterizedType
import co.edu.javeriana.isml.validation.TypeChecker
import co.edu.javeriana.isml.validation.TypeFactory
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import co.edu.javeriana.isml.scoping.TypeExtension

class EditPageTemplate extends SimpleTemplate<Entity> {
	@Inject extension IQualifiedNameProvider
	@Inject extension CommonTemplates
	@Inject extension TypeChecker
	@Inject extension TypeFactory
	@Inject extension TypeExtension

	override protected template(Entity e) '''
		package «e.eContainer?.fullyQualifiedName»
		
		page «e.editPage»(«e.name» «e.variable») controlledBy «e.controllerName»  {
			Form {
				«FOR a : e.allAttributes»
					«templateEdit(e,a,true)»
				«ENDFOR»
				
				Button("Save", true) -> «e.saveAction»(«e.variable»)
				Button("Cancel", false) -> listAll()
			}
		}
	'''



}
