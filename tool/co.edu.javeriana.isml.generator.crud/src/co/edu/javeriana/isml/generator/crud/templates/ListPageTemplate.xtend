package co.edu.javeriana.isml.generator.crud.templates

import co.edu.javeriana.isml.generator.common.SimpleTemplate
import co.edu.javeriana.isml.isml.Entity
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import co.edu.javeriana.isml.scoping.TypeExtension
import co.edu.javeriana.isml.isml.Attribute

class ListPageTemplate extends SimpleTemplate<Entity> {
	@Inject extension IQualifiedNameProvider
	@Inject extension CommonTemplates
	@Inject extension TypeExtension

	override protected template(Entity e) '''
		package «e.eContainer?.fullyQualifiedName»
		
		page «e.listPage»(«e.collectionType» «e.collectionVariable») controlledBy «e.controllerName»  {
			Form {
			       Panel("«e.collectionType.toLabel»") {
			           DataTable("«e.collectionType.toLabel»", null) {
			               header : {                    
			                   «FOR attr : e.attributes»
			                   		«attr.headerCell»
			                   «ENDFOR»
			                   Label("View")
			                   Label("Edit")
			                   Label("Delete")
			               }
			               body : 
			               for(«e.name» «e.variable» in «e.collectionVariable») {
			               		«FOR attr : e.attributes»
			               			«e.cell(attr)»
			               		«ENDFOR»
			                   	Button("View",false)-> «e.viewAction»(«e.variable»)
			                   	Button("Edit",false) -> «e.editAction»(«e.variable»)
			                   	Button("Delete",false) -> «e.deleteAction»(«e.variable»)
			               }

			           }
			        	
				}
			} 
			
		}
	'''

}
