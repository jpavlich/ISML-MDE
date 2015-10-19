package co.edu.javeriana.isml.generator.crud.templates

import co.edu.javeriana.isml.generator.common.SimpleTemplate
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.scoping.IsmlModelNavigation
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider

class SelectToAssignPageTemplate extends SimpleTemplate<Entity> {
	@Inject extension IQualifiedNameProvider
	@Inject extension CommonTemplates
	@Inject extension IsmlModelNavigation

	override protected template(Entity e) '''
		package «e.eContainer?.fullyQualifiedName»
		
		page «e.selectToAssignPage»(«e.collectionType» «e.collectionVariable», Any container, String attribute) controlledBy «e.controllerName»  {
			Form {
			       Panel("«e.collectionType.toLabel»") {
			           DataTable("«e.collectionType.toLabel»", null) {
			               header: {                    
			                   «FOR attr : e.attributes»
			                   	«attr.headerCell»
			                   «ENDFOR»
			                   Label("Select «e.name» to Assign")
			               }
			               body:
			               for(«e.name» «e.variable» in «e.collectionVariable») {
			               		«FOR attr : e.attributes»
			               			«e.cell(attr)»
			               		«ENDFOR»
			               		Button("Select",false)-> «e.assignAction»(container, attribute, «e.variable»)
			               }
			           }
		               Button("Cancel", false) -> DefaultPageDispatcher.edit(container)
				}
			}
		}
	'''

}
