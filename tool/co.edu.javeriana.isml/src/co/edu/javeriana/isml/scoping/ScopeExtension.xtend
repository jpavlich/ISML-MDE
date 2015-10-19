package co.edu.javeriana.isml.scoping

import co.edu.javeriana.isml.isml.CompositeElement
import co.edu.javeriana.isml.isml.CompositeMethodStatement
import co.edu.javeriana.isml.isml.Function
import co.edu.javeriana.isml.isml.Iteration
import co.edu.javeriana.isml.isml.Statement
import co.edu.javeriana.isml.isml.ViewStatement
import com.google.inject.Inject
import java.util.ArrayList
import org.eclipse.emf.ecore.EObject

class ScopeExtension {

	@Inject extension IsmlModelNavigation


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
			CompositeElement: if (parent instanceof Statement) vars.addAll(current.findAllPreviousOfType(Object))
			Iteration: vars.add(parent.variable)
			Function: vars.addAll(parent.parameters)
		}
	}

	
	


	/**
	 * Finds all of the instances of given classes that appear previously in the same block of a given object.
	 * This can be utilized to find variable declarations that must be before a variable reference
	 */
	def Iterable<EObject> findAllPreviousOfType(EObject obj, Class<?> type) {
		val previousList = new ArrayList<EObject>
		val CompositeElement<Statement> compStatement = obj.findAncestor(CompositeElement)
		if(compStatement != null) {
			for (child : compStatement.body) {
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
