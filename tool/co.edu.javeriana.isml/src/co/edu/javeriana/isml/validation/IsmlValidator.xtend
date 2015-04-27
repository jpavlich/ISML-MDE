package co.edu.javeriana.isml.validation

import co.edu.javeriana.isml.isml.Assignment
import co.edu.javeriana.isml.isml.Caller
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.isml.Function
import co.edu.javeriana.isml.isml.Instance
import co.edu.javeriana.isml.isml.IsmlPackage
import co.edu.javeriana.isml.isml.ParameterizedReference
import co.edu.javeriana.isml.isml.ParameterizedType
import co.edu.javeriana.isml.isml.Reference
import co.edu.javeriana.isml.isml.TypeSpecification
import co.edu.javeriana.isml.isml.Variable
import co.edu.javeriana.isml.scoping.TypeExtension
import com.google.inject.Inject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.validation.Check
import org.eclipse.xtext.validation.ComposedChecks
import co.edu.javeriana.isml.isml.Type

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
@ComposedChecks(validators=#[NamesAreUniqueValidator])
class IsmlValidator extends AbstractIsmlValidator {

	@Inject extension TypeChecker typeChecker
	@Inject extension TypeExtension
	@Inject extension Generics

	@Check
	def instanceParametersMustMatchTypeArguments(Instance instance) {
		checkParameters(instance, instance.type.typeSpecification, IsmlPackage.Literals.INSTANCE__TYPE)
	}

	@Check
	def functionCallParametersMustMatchFunctionArguments(Reference call) {
		val callee = call.referencedElement
		if(call instanceof ParameterizedReference && callee instanceof Function) {
			checkParameters(call as Caller, callee as Function, call.eClass.getEStructuralFeature("referencedElement"))
		}
	}

	def checkParameters(Caller caller, Function callee, EStructuralFeature f) {
		if(callee instanceof Entity && caller.parameters.empty) {

			// Entity instantiation without parameters is allowed
			return
		}
		val calleeName = callee.name

		val realParameters = caller.parameters
		val realSize = realParameters.size
		var errorString = ""
		var hasErrors = false
		if(realSize != callee.parameters.size) {
			error("Wrong number of parameters " + calleeName + " requires " + callee.parameters.size() + " arguments", caller, f)
			return
		}

		val formalParameters = callee.instantiateGenericParameters(caller)

		for (var i = 0; i < realSize; i++) {
			val realParam = realParameters.get(i)
			val formalParam = formalParameters.get(i)

			try {
				val realType = realParam.type
				val formalType = formalParam.type
				if(!formalType.isAssignableFrom(realType) && realType != null) {
					errorString += "Parameter " + (i + 1) + " of type " + realType?.typeSpecification?.name + " must be of type " +
						formalType.typeSpecification.name + "\n"
					hasErrors = true
				}

			} catch(Throwable t2) {
				t2.printStackTrace
			}
		}

		if(hasErrors) {
			error("Incorrect parameters: \n" + errorString, caller, f)
		}
	}

	@Check
	def validAssignment(Assignment a) {
		val leftType = a.left.type
		val rightType = a.right.type
		if(!leftType.isAssignableFrom(rightType)) {
			error(
				"Cannot assign value of type " + rightType.fullName + " to variable " + (a.left as Reference).referencedElement.name + " of type " +
					leftType.fullName, a, IsmlPackage.Literals.BINARY_OPERATOR__RIGHT)
		}
	}

	@Check
	def validVarDecl(Variable v) {
		val leftType = v.type
		val value = v.value
		if(value != null) {
			val rightType = value.type

			if(!leftType.isAssignableFrom(rightType)) {
				error("Cannot assign value of type " + rightType.fullName + " to variable " + v.name + " of type " + leftType.fullName, v,
					IsmlPackage.Literals.VARIABLE_TYPE_ELEMENT__VALUE)
			}
		}
	}

	@Check
	def validGenericTypeInstantiation(Type type) {
		var error = false
		val genericTypeParamSize = type.typeSpecification.genericTypeParameters.size
		if(type instanceof ParameterizedType) {
			if(type.typeParameters.size != genericTypeParamSize) {
				error = true
			}
		} else {
			if (genericTypeParamSize > 0) {
				error = true
			}
		}
		if(error) {
			error(
				"Wrong number of parameters. Type " + type.typeSpecification.name + " must be extended with" + genericTypeParamSize + " parameters",
				type,
				IsmlPackage.Literals.TYPE__TYPE_SPECIFICATION
			)
		}
	}

}
