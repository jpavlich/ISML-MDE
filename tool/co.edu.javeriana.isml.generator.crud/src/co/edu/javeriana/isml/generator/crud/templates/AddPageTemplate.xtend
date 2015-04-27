package co.edu.javeriana.isml.generator.crud.templates

import co.edu.javeriana.isml.generator.common.SimpleTemplate
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.scoping.TypeExtension
import co.edu.javeriana.isml.validation.TypeChecker
import co.edu.javeriana.isml.validation.TypeFactory
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider

class AddPageTemplate extends SimpleTemplate<Entity> {
	@Inject extension IQualifiedNameProvider
	@Inject extension CommonTemplates
	@Inject extension TypeChecker
	@Inject extension TypeFactory
	@Inject extension TypeExtension

	override protected template(Entity e) '''
		package «e.eContainer?.fullyQualifiedName»
		
		page «e.createToAddPage»(Any container, Collection<«e.name»> collection, «e.name» «e.variable») controlledBy «e.controllerName»  {
			Form {
				«FOR a : e.allAttributes»
					«templateEdit(e,a,false)»
				«ENDFOR»
				
				Button("Save", true) -> «e.addAction»(container, collection, «e.variable»)
				Button("Cancel", false) -> DefaultPageDispatcher.edit(container)
			}
		}
	'''



}
