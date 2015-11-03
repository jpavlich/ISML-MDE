package co.edu.javeriana.isml.generator.crud.templates

import co.edu.javeriana.isml.isml.Attribute
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.isml.ParameterizedType
import co.edu.javeriana.isml.isml.Type
import co.edu.javeriana.isml.isml.TypeSpecification
import co.edu.javeriana.isml.scoping.IsmlModelNavigation
import co.edu.javeriana.isml.validation.TypeChecker
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider

class CommonTemplates {
	@Inject extension IQualifiedNameProvider
	@Inject extension IsmlModelNavigation
	@Inject extension TypeChecker

	// Misc
	def controllerName(TypeSpecification e) '''«e.name»Manager'''

	def variable(TypeSpecification e) '''«e.name.toFirstLower»'''

	def itVariable(TypeSpecification e) '''a«e.name»'''

	def collectionVariable(TypeSpecification e) '''«e.name.toFirstLower»List'''

	def idVariable(TypeSpecification e) '''id'''

	def idType(TypeSpecification e) '''Integer'''

	def arrayType(TypeSpecification e) '''Array<«e.name»>'''

	def collectionType(TypeSpecification e) '''Collection<«e.name»>'''

	// Pages
	def listPage(TypeSpecification e) '''«e.name»List'''

	def subListPage(TypeSpecification e) '''«e.name»SubList'''

	def createToAddPage(TypeSpecification e) '''Create«e.name»ToAdd'''

	def selectToAddPage(TypeSpecification e) '''Select«e.name»ToAdd'''

	def selectToAssignPage(TypeSpecification e) '''Select«e.name»ToAssign'''

	def viewPage(TypeSpecification e) '''View«e.name»'''

	def editPage(TypeSpecification e) '''Edit«e.name»'''

	// Actions
	def listAction(TypeSpecification e) '''list«e.name»'''

	def subListAction(TypeSpecification e) '''subList«e.name»'''

	def viewAction(TypeSpecification e) '''view«e.name»'''

	def createAction(TypeSpecification e) '''create«e.name»'''

	def addAction(TypeSpecification e) '''add«e.name»'''

	def cancelAddAction(TypeSpecification e) '''cancelAdd«e.name»'''

	def createToAddAction(TypeSpecification e) '''create«e.name»ToAdd'''

	def selectToAddAction(TypeSpecification e) '''select«e.name»ToAdd'''

	def selectToAssignAction(TypeSpecification e) '''select«e.name»ToAssign'''

	def assignAction(TypeSpecification e) '''assign«e.name»'''

	def editAction(TypeSpecification e) '''edit«e.name»'''

	def saveAction(TypeSpecification e) '''save«e.name»'''

	def deleteAction(TypeSpecification e) '''delete«e.name»'''

	def removeAction(TypeSpecification e) '''remove«e.name»'''

	// def dispatch iterator(VariableTypeElement v) '''«v.type.typeSpecification.name» it«v.type.typeSpecification.name»'''
	// def dispatch iterator(NamedElement e) '''«e.name» it«e.name»'''
	/**
	 * Converts a string in camel case to a human-readable format, i.e., putting spaces between case changes.
	 */
	def toLabel(String s) {
		return s.toFirstUpper.replaceAll("([a-z])([A-Z])", "$1 $2")
	}

	/**
	 * Converts a string in camel case to a human-readable format, i.e., putting spaces between case changes.
	 */
	def toLabel(CharSequence s) {
		return toLabel(s.toString)
	}

	def headerCell(Attribute attr) '''
	«IF attr.type.isCollection» 

	«ELSE»
		Label("«attr.name.toLabel»");
	«ENDIF»
	'''

	def cell(Entity e, Attribute a) ''' 
		«IF a.type.isCollection» 

		«ELSE»
			Label(«e.variable».«a.name»);
		«ENDIF»
	'''

	def String toText(Type t) {
		var name = ""

		name += t.typeSpecification?.name

		if(t instanceof ParameterizedType) {
			name += "<"
			for (typeParam : t.typeParameters) {
				name += typeParam.toText
			}
			name += ">"
		}
		return name
	}

	def templateEdit(Entity e, Attribute a, boolean deepEdit) {
		val attTypeSpec = a.type.typeSpecification
		switch (a.type.typeSpecification.name) {
			case "String":
				return '''Text("«a.name.toLabel»", «e.variable».«a.name», 25, 1);'''
			case "Date":
				return '''Calendar("«a.name.toLabel»", «e.variable».«a.name», null, "dd/MM/yyyy", true, "inline");'''
			case "Integer":
				return '''Text("«a.name.toLabel»", «e.variable».«a.name», 10, 1);'''
			case "Float":
				return '''Text("«a.name.toLabel»", «e.variable».«a.name», 10, 1);'''
			case "Boolean":
				return '''CheckBox("«a.name.toLabel»", «e.variable».«a.name»);'''
			case "Email":
				return '''Text("«a.name.toLabel»", «e.variable».«a.name», 25, 1);'''
			default: {
				val attrType = a.type
				if(deepEdit) {
					if(attrType instanceof ParameterizedType) {
						if(a.type.isCollection) {
							return templateEditList(e, a, attrType)
						}
					}
					val attrTypeSpec = attrType.typeSpecification
					if(attrTypeSpec instanceof Entity) {
						return '''
							Panel("«a.name.toLabel»") {
								«FOR attr : e.allAttributes»
									«templateView(e, attr, false)»
								«ENDFOR»
								Button("Change", false) -> «attTypeSpec.controllerName».«attTypeSpec.selectToAssignAction»(«e.variable», "«a.name»");
								Button("Remove", false) -> «attTypeSpec.controllerName».«attTypeSpec.assignAction»(«e.variable», "«a.name»", null);
							}
						'''
					}
				}

				return ''''''
			}
		}
	}

	def templateEditList(Entity e, Attribute a, ParameterizedType attrType) {
		val containedTypeSpec = a.type.
			containedTypeSpecification
		'''
			Panel("«a.name.toLabel»") {
				DataTable("«a.name.toLabel»", null) {
					header : {                    
					          «FOR attr : containedTypeSpec.allAttributes»
					          	«attr.headerCell»
					          «ENDFOR»
					          Label("Delete");
					}
					body : 
					for(«containedTypeSpec.name» «containedTypeSpec.itVariable» in «e.variable».«a.name») {
					      		«FOR attr : containedTypeSpec.allAttributes»
					      			Label(«containedTypeSpec.itVariable».«attr.name»);
					      		«ENDFOR»
					      		Button("Remove",false) -> «containedTypeSpec.controllerName».«containedTypeSpec.removeAction»(«e.variable», «e.variable».«a.name», «containedTypeSpec.
				itVariable»);
					}
				}
				Button("Add New «containedTypeSpec.name.toLabel»", false) -> «containedTypeSpec.controllerName».«containedTypeSpec.createToAddAction»(«e.variable», «e.
				variable».«a.name»);
				Button("Add Existing «containedTypeSpec.name.toLabel»", false) -> «containedTypeSpec.controllerName».«containedTypeSpec.selectToAddAction»(«e.
				variable», «e.variable».«a.name»);
			}
		'''
	}

	def templateView(Entity e, Attribute a, boolean deepView) {
		if(a.type.isCollection) {
			'''Button("«a.name.toLabel»", false) -> «a.type.containedTypeSpecification.controllerName».«a.type.containedTypeSpecification?.subListAction»(«e.variable», «e.
				variable».«a.name»);'''
		} else if(a.type.typeSpecification instanceof Entity && deepView) {
			'''Button("«a.name.toLabel»", false) -> «a.type.typeSpecification.controllerName».«a.type.typeSpecification.viewAction»(«e.variable».«a.name»);'''
		} else {
			'''
				Label("«a.name.toLabel»");
				Label(«e.variable».«a.name»);
			'''
		}
	}
}
