package co.edu.javeriana.isml.generator.crud.templates

import co.edu.javeriana.isml.generator.common.SimpleTemplate
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.scoping.IsmlModelNavigation
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider

class SubListPageTemplate extends SimpleTemplate<Entity> {
	@Inject extension IQualifiedNameProvider
	@Inject extension CommonTemplates
	@Inject extension IsmlModelNavigation

	override protected template(Entity e) '''
		package �e.eContainer?.fullyQualifiedName�;
		
		page �e.subListPage�(Any container, Collection<�e.name�> collection) controlledBy �e.controllerName�  {
			Form {
			       Panel("�e.collectionType.toLabel�") {
			           DataTable("�e.collectionType.toLabel�", null) {
			               header : {                    
			                   �FOR attr : e.attributes�
			                   		�attr.headerCell�
			                   �ENDFOR�
			               }
			               body : 
			               for(�e.name� �e.variable� in collection) {
			               		�FOR attr : e.attributes�
			               			�e.cell(attr)�
			               		�ENDFOR�
			               }
			           }
					Button("Back", false) -> DefaultPageDispatcher.view(container);
				}
			} 
			
		}
	'''

}
