package co.edu.javeriana.isml.scoping

import co.edu.javeriana.isml.isml.Block
import co.edu.javeriana.isml.isml.Function
import co.edu.javeriana.isml.isml.Iteration
import com.google.inject.Inject
import java.util.ArrayList
import org.eclipse.emf.ecore.EObject
import co.edu.javeriana.isml.isml.NamedElement
import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.isml.Variable
import co.edu.javeriana.isml.isml.Parameter

class ScopeExtension {

	@Inject extension TypeExtension

//	def Iterable<Parameter> getAllParametersInScope(EObject start) {
//		var parameters = new ArrayList<Parameter>
//		var current = start.findAncestor(Function) as Function
//		while(current != null) {
//			parameters.addAll(current.parameters)
//			current = current.eContainer?.findAncestor(Function) as Function
//		}
//
//		return parameters
//	}

	def Iterable<EObject> getAllElementsInScope(EObject obj) {
		var vars = new ArrayList<EObject>
		var current = obj
		while (current != null) {
			addAllStatementsInScope(current, current.eContainer, vars)
			current = current.eContainer
		}
		return vars
	}
	
	
	def addAllStatementsInScope(EObject current, EObject parent, ArrayList<EObject> vars) {
		switch (parent) {
			Block: vars.addAll(current.findAllPreviousOfType(Object))
			Iteration: vars.add(parent.variable)
			Function: vars.addAll(parent.parameters)
		}
	}

	
	
	
	
//	def <T extends EObject> getAllStatementsInIterations(EObject obj, Class<T> type, ArrayList<T> vars) {
//		var current = obj.eContainer?.findAncestorWithParentOfType(Iteration)
//		while(current != null) {
//			val iteration = current as Iteration
//			vars.add(iteration.variable as T)
//			current = current.eContainer?.findAncestorWithParentOfType(Block)
//		}
//	}
//	
//	def <T extends EObject> getAllStatementsInBlocks(EObject obj, Class<T> type, ArrayList<T> vars) {
//		var current = obj.eContainer?.findAncestorWithParentOfType(Block)
//		while(current != null) {
//			vars.addAll(current.findAllPreviousOfType(type))
//			current = current.eContainer?.findAncestorWithParentOfType(Block)
//		}
//	}



	/**
	 * Finds all of the instances of given classes that appear previously in the same block of a given object.
	 * This can be utilized to find variable declarations that must be before a variable reference
	 */
	def Iterable<EObject> findAllPreviousOfType(EObject obj, Class<?> type) {
		val previousList = new ArrayList<EObject>
		val block = obj.findAncestor(Block) as Block
		if(block != null) {
			for (child : block.statements) {
				if(child == obj) {
					return previousList
				}
				if(type.isAssignableFrom(child.class)) {
					previousList.add(child)
				}
			}
		}

		return previousList
	}
}
