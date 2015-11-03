package co.edu.javeriana.isml.scoping

import co.edu.javeriana.isml.isml.CompositeElement
import co.edu.javeriana.isml.isml.Element
import co.edu.javeriana.isml.isml.Function
import co.edu.javeriana.isml.isml.Iteration
import co.edu.javeriana.isml.isml.TypedElement
import com.google.inject.Inject
import java.util.ArrayList
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject

class ScopeExtension {

	@Inject extension IsmlModelNavigation

	def Iterable<EObject> getAllElementsInScope(EObject obj) {
		var vars = new ArrayList<EObject>
		var current = obj
		while(current != null) {
			addAllStatementsInScope(current, vars)
			current = current.eContainer
		}
		return vars
	}

	def addAllStatementsInScope(EObject obj, ArrayList<EObject> vars) {
		val EObject container = obj.eContainer
		if(container instanceof CompositeElement<?>) {
			vars.addAll(obj.findAllPreviousInstancesOfType(TypedElement))
		}

		if(container instanceof Iteration) {
			vars.add(container.variable)
		}
		if(container instanceof Function) {
			vars.addAll(container.parameters)
		}

	}

	/**
	 * Finds all the instances of a given type that appear previously in the same block of a given object.
	 * This can be utilized to find variable declarations that should be located before a variable reference
	 */
	def Iterable<EObject> findAllPreviousInstancesOfType(EObject obj, Class<?>... types) {
		val previousInstances = new ArrayList<EObject>
		var container = obj.eContainer
		val containingFeature = obj.eContainingFeature
		if(container != null) {
			val body = container.eGet(containingFeature)
			if(body instanceof EList<?>) {
				for (ch : body) {
					val child = ch as EObject
					if(child == obj) {
						return previousInstances
					}
					for (type : types) {
						if(type.isAssignableFrom(child.class)) {
							previousInstances.add(child)
						}
					}
				}

			}
		}

		return previousInstances
	}

}
