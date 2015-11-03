package co.edu.javeriana.isml.generator.crud.templates

import co.edu.javeriana.isml.generator.common.SimpleTemplate
import co.edu.javeriana.isml.isml.Entity
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider

class ControllerTemplate extends SimpleTemplate<Entity> {
	@Inject extension IQualifiedNameProvider
	@Inject extension CommonTemplates

	override protected template(Entity e) '''
		package «e.eContainer?.fullyQualifiedName»;
		
		controller «e.controllerName» {
			has Persistence<«e.name»> persistence;
			
			/**
			* Lists all instances of «e.name».
			*/
			default listAll() {
				show «e.listPage»(persistence.findAll());
			}
		
			/**
			* Lists instances of «e.name».
			* @param «e.collectionVariable» The list of instances of «e.name» to show.
			*/
			«e.listAction»(«e.collectionType» «e.collectionVariable») {
				show «e.listPage»(«e.collectionVariable»);
			}
			
			/**
			* Lists instances of «e.name» that are in a collection.
			* @param «e.collectionVariable» The list of instances of «e.name» to show.
			*/
			«e.subListAction»(Any container, Collection<«e.name»> collection) {
				show «e.subListPage»(container, collection);
			}
		
			/** Creates a new instance of «e.name» and opens a form to 
			* edit that instance and add it to collection.
			* @param container The entity that contains collection
			* @param collection The collection to which the new instance will be added
			*/
			«e.createToAddAction»(Any container, Collection<«e.name»> collection) {
				show «e.createToAddPage»(container, collection, new «e.name»);
			}
		
			/** Opens a page to select an instance to add it to collection.
			* @param container The entity that contains collection
			* @param collection The collection to which the selected instance will be added
			*/
			«e.selectToAddAction»(Any container, Collection<«e.name»> collection) {
				Collection<«e.name»> selectableElements = persistence.findAllExcept(collection);
				show «e.selectToAddPage»(selectableElements, container, collection);
			}
		
			/** Adds an instance of «e.name» to a collection
			* @param container The entity that contains collection
			* @param collection The collection to which the new instance will be added
			* @param «e.variable» The instance that will be added to collection
			*/
			«e.addAction»(Any container, Collection<«e.name»> collection, «e.name» instance) {
				persistence.addToCollection(container, collection, instance);
				-> DefaultPageDispatcher.edit(container);
			}
			
			
			
			/** Removes an instance of «e.name» from a collection
			* @param container The entity that contains collection
			* @param collection The collection to which the new instance will be added
			* @param «e.variable» The instance that will be removed from collection
			*/
			«e.removeAction»(Any container, Collection<«e.name»> collection, «e.name» instance) {
				persistence.removeFromCollection(container, collection, instance);
				-> DefaultPageDispatcher.edit(container);
			}
			
			/** Opens a page to select an instance to assign it to an entity's attribute.
			* @param container The entity that has the attribute
			* @param attribute The attribute name to which the selected instance will be assigned
			*/
			«e.selectToAssignAction»(Any container, String attribute) {
				Collection<«e.name»> elements = persistence.findAll();
				show «e.selectToAssignPage»(elements, container, attribute);
			}
			
			/** Assigns an object to an entity's attribute.
			* @param container The entity that has the attribute
			* @param attribute The attribute name that will be assigned
			* @param instance The object that will be assigned to attribute
			*/
			«e.assignAction»(Any container, String attribute, «e.name» instance) {
				persistence.assignToAttribute(container, attribute, instance);
				-> DefaultPageDispatcher.edit(container);
			}
			
			/**
			* Views an instance of «e.name».
			* @param «e.idVariable» the ID of the «e.name».
			*/
			«e.viewAction»(«e.idType» «e.idVariable») {
				show «e.viewPage»(persistence.find(«e.idVariable»));
			}
		
			/**
			* Views an instance of «e.name».
			* @param «e.variable» the «e.name» to open.
			*/		
			«e.viewAction»(«e.name» «e.variable») {
				show «e.viewPage»(«e.variable»);
			}
		
		
			/**
			* Edits an existing instance of «e.name».
			* @param «e.variable» the «e.name» to open.
			*/			
			«e.editAction»(«e.name» «e.variable») {
				show «e.editPage»(«e.variable»);
			}
		
			/**
			* Creates a a new instance of «e.name».
			*/			
			«e.createAction»() {
				show «e.editPage»(new «e.name»);
			}
		
		
			/**
			* Saves an instance of «e.name».
			* @param «e.variable» the «e.name» to save.
			*/			
			«e.saveAction»(«e.name» «e.variable») {
			if(persistence.isPersistent(«e.variable»)){
				persistence.edit(«e.variable»);
			} else {
				persistence.create(«e.variable»);
			}
			-> listAll();
			}
		
		
			/**
			* Deletes an instance of «e.name».
			* @param «e.variable» the «e.name» to delete.
			*/		
			«e.deleteAction»(«e.name» «e.variable») {
				persistence.remove(«e.variable»);
				-> listAll();
			}
		
			/**
			* Deletes an instance of «e.name».
			* @param «e.idVariable» the ID of the «e.name» to delete.
			*/		
			«e.deleteAction»(«e.idType» «e.idVariable») {
				persistence.remove(«e.idVariable»);
				-> listAll();
			}
		}
	'''

}