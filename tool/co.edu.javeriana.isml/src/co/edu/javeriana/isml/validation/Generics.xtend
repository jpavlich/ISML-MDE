package co.edu.javeriana.isml.validation

import co.edu.javeriana.isml.isml.Caller
import co.edu.javeriana.isml.isml.Expression
import co.edu.javeriana.isml.isml.Feature
import co.edu.javeriana.isml.isml.Function
import co.edu.javeriana.isml.isml.GenericTypeSpecification
import co.edu.javeriana.isml.isml.Parameter
import co.edu.javeriana.isml.isml.ParameterizedType
import co.edu.javeriana.isml.isml.Type
import com.google.inject.Inject
import java.util.ArrayList
import java.util.Comparator
import java.util.List
import java.util.Map
import java.util.TreeMap
import org.eclipse.emf.ecore.util.EcoreUtil
import co.edu.javeriana.isml.scoping.IsmlModelNavigation

class Generics {
	@Inject extension TypeChecker
	@Inject extension IsmlModelNavigation
	@Inject extension TypeFactory

	def Map<Type, Type> getTypeSubstitutions(Function callee, Caller caller) {
		val substitutions = new TreeMap<Type, Type>(new Comparator<Type>() {
			
			override compare(Type t1, Type t2) {
				return t1.fullName.compareTo(t2.fullName)
			}
			
		})
		
		// Add generic class substitutions
		
		
		if (callee instanceof Feature) {
			substitutions.addTypeSubstitutions(caller.containerType)
			val calleeTypeSpec = callee.containerTypeSpecification
			val callerTypeSpec = caller.containerTypeSpecification
			
			var currentTypeSpec = callerTypeSpec
			while ( currentTypeSpec != null && currentTypeSpec != calleeTypeSpec ) {
				// FIXME support for multiple inheritance
				val parent =  currentTypeSpec.superTypes.head
				substitutions.addTypeSubstitutions(parent)
				currentTypeSpec = parent.typeSpecification
			}
		}
		
		val size = callee.parameters.size
		for (i : 0 ..< size) {
			substitutions.addTypeSubstitutions(callee.parameters.get(i), caller.parameters.get(i))
		}

		return substitutions
	}
	
	def addTypeSubstitutions(Map<Type, Type> substitutions, Type type) {
		if (type instanceof ParameterizedType) {
			val size = type.typeParameters.size
			// FIXME Add a @Check to verify that type parameters in a subclass coincide with type parameters of superclass
			for (i : 0 ..< size) {
				substitutions.addTypeSubstitutions(type.typeSpecification.createType, type)
			}
		}
	}

	def void addTypeSubstitutions(Map<Type, Type> substitutions, Parameter formalParam, Expression realParam) { // Fix order of arguments
		val realParamType = realParam.type
		val formalParamType = formalParam.type
		substitutions.addTypeSubstitutions(formalParamType, realParamType)

	}
	
	
	def void addTypeSubstitutions(Map<Type, Type> substitutions, Type originType, Type destinationType) {
		val originTypeSpec = originType.typeSpecification

		if(originType instanceof ParameterizedType && destinationType instanceof ParameterizedType) {
			substitutions.addTypeSubstitutions(originType as ParameterizedType, destinationType as ParameterizedType)
		} else if(originTypeSpec instanceof GenericTypeSpecification) {
			substitutions.addTypeSubstitution(originType, destinationType)
		} else { // It is a simple type (non parameterized and non generic)
			// do nothing?
		}
	}

	def void addTypeSubstitutions(Map<Type, Type> substitutions, ParameterizedType originType, ParameterizedType destinationType) {
		val size = originType.typeParameters.size
		for (i : 0 ..< size) {
			substitutions.addTypeSubstitutions(originType.typeParameters.get(i), destinationType.typeParameters.get(i))
		}
	}


	def void addTypeSubstitution(Map<Type, Type> substitutions, Type originType, Type destinationType) {
		if(!substitutions.containsKey(originType)) {
			substitutions.put(originType, destinationType)
		}
	}

	def List<Parameter> instantiateGenericParameters(Function function, Caller caller) {
		val typeSubstitutions = getTypeSubstitutions(function, caller)
		val instantiatedParams = new ArrayList<Parameter>
		val parameters = function.parameters
		for (p : parameters) {
			val param = EcoreUtil.copy(p)
			param.type = param.type.instantiate(typeSubstitutions)
			instantiatedParams.add(param)
		}
		return instantiatedParams
		
	}
	
	def Type instantiate(Type type, Map<Type, Type> substitutions) {
		var substType = substitutions.get(type)
		if (substType == null) {
			substType = type
		}
		val instantiatedType = EcoreUtil.copy(substType)
		if (instantiatedType instanceof ParameterizedType) {
			for (i : 0..< instantiatedType.typeParameters.size) {
				val typeParam = instantiatedType.typeParameters.get(i)
				instantiatedType.typeParameters.set(i, typeParam.instantiate(substitutions))
			}
		}
		return instantiatedType
	}

	
}
