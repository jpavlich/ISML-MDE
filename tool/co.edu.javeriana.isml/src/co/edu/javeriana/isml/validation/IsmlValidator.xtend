package co.edu.javeriana.isml.validation

import co.edu.javeriana.isml.isml.Assignment
import co.edu.javeriana.isml.isml.Caller
import co.edu.javeriana.isml.isml.CompositeElement
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.isml.Function
import co.edu.javeriana.isml.isml.Instance
import co.edu.javeriana.isml.isml.IsmlPackage
import co.edu.javeriana.isml.isml.NamedElement
import co.edu.javeriana.isml.isml.ParameterizedReference
import co.edu.javeriana.isml.isml.ParameterizedType
import co.edu.javeriana.isml.isml.Reference
import co.edu.javeriana.isml.isml.Type
import co.edu.javeriana.isml.isml.Variable
import co.edu.javeriana.isml.isml.ViewStatement
import co.edu.javeriana.isml.isml.Widget
import co.edu.javeriana.isml.scoping.IsmlModelNavigation
import com.google.inject.Inject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.validation.Check
import org.eclipse.xtext.validation.ComposedChecks

/**
 * Custom validation rules. 
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
@ComposedChecks(validators=#[NamesAreUniqueValidator])
class IsmlValidator extends AbstractIsmlValidator {

	@Inject extension TypeChecker typeChecker
	@Inject extension IsmlModelNavigation
	@Inject extension Generics

	@Check
	def instanceParametersMustMatchTypeArguments(Instance instance) {
		val typeSpecification = instance.type.typeSpecification
		checkParameters(instance, typeSpecification, IsmlPackage.Literals.TYPED_ELEMENT__TYPE)
		if (typeSpecification instanceof Widget) {
			checkBlockParameters(instance as CompositeElement<ViewStatement>,
				typeSpecification as CompositeElement<ViewStatement>);
		}

	}

	@Check
	def functionCallParametersMustMatchFunctionArguments(Reference<?> caller) {
		val callee = caller.referencedElement
		if (caller instanceof ParameterizedReference<?> && callee instanceof Function) {
			checkParameters(caller as Caller, callee as Function,
				caller.eClass.getEStructuralFeature("referencedElement"))
		}

	}

	def void checkBlockParameters(CompositeElement<ViewStatement> instance, CompositeElement<ViewStatement> widget) {
		try {
			if (widget.hasBody != instance.hasBody) {
				error("This widget must have a body", instance, IsmlPackage.Literals.TYPED_ELEMENT__TYPE)
				return
			}
			val widgetBodySize = widget.body?.size
			val instanceBodySize = instance.body?.size
			if (widgetBodySize > 0) {
				if (widgetBodySize != instanceBodySize) {
					error("Incorrect body parameters", instance, IsmlPackage.Literals.COMPOSITE_ELEMENT__BODY);
				} else {
					// Checks specific arguments only if the widget body has some elements in it
					for (i : 0 ..< widgetBodySize) {
						val instanceElem = instance.body.get(i)
						val widgetElem = widget.body.get(i)
						if (instanceElem.type.typeSpecification != widgetElem.type.typeSpecification) {
							error("Incorrect body parameters", instance, IsmlPackage.Literals.COMPOSITE_ELEMENT__BODY);
						}
						if (instanceElem instanceof NamedElement) {
							if (widgetElem instanceof NamedElement) {
								val instanceElemName = instanceElem?.name ?: ""
								val widgetElemName = widgetElem?.name ?: ""
								if (!instanceElemName.equals(widgetElemName)) {
									error("Incorrect body parameters", instance,
										IsmlPackage.Literals.COMPOSITE_ELEMENT__BODY);
								}

							}
						}
						if (widgetElem instanceof CompositeElement<?>) {
							if (instanceElem instanceof CompositeElement<?>) {
								checkBlockParameters(instanceElem as CompositeElement<ViewStatement>,
									widgetElem as CompositeElement<ViewStatement>)
							}
						}

					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace
		}

	}

	def checkParameters(Caller caller, Function callee, EStructuralFeature f) {
		if (callee instanceof Entity && caller.parameters.empty) {
			// Entity instantiation without parameters is allowed
			return
		}
		val calleeName = callee.name

		val realParameters = caller.parameters
		val realSize = realParameters.size
		var errorString = ""
		var hasErrors = false
		if (realSize != callee.parameters.size) {
			error("Wrong number of parameters " + calleeName + " requires " + callee.parameters.size() + " arguments",
				caller, f)
			return
		}

		val formalParameters = callee.instantiateGenericParameters(caller)

		for (var i = 0; i < realSize; i++) {
			val realParam = realParameters.get(i)
			val formalParam = formalParameters.get(i)

			try {
				val realType = realParam.type
				val formalType = formalParam.type
				if (!formalType.isAssignableFrom(realType) && realType != null) {
					errorString +=
						"Parameter " + (i + 1) + " of type " + realType?.typeSpecification?.name + " must be of type " +
							formalType.typeSpecification.name + "\n"
					hasErrors = true
				}

			} catch (Throwable t2) {
				t2.printStackTrace
			}
		}

		if (hasErrors) {
			error("Incorrect parameters: \n" + errorString, caller, f)
		}
	}

	@Check
	def validAssignment(Assignment a) {
		val leftType = a.left.type
		val rightType = a.right.type
		if (!leftType.isAssignableFrom(rightType)) {
			error(
				"Cannot assign value of type " + rightType.fullName + " to variable " +
					(a.left as Reference<?>).referencedElement.name + " of type " + leftType.fullName, a,
				IsmlPackage.Literals.BINARY_OPERATOR__RIGHT)
		}
	}

	@Check
	def validVarDecl(Variable v) {
		val leftType = v.type
		val value = v.value
		if (value != null) {
			val rightType = value.type

			if (!leftType.isAssignableFrom(rightType)) {
				error("Cannot assign value of type " + rightType.fullName + " to variable " + v.name + " of type " +
					leftType.fullName, v, IsmlPackage.Literals.VARIABLE_TYPE_ELEMENT__VALUE)
			}
		}
	}

	@Check
	def validGenericTypeInstantiation(Type type) {
		var error = false
		val genericTypeParamSize = type.typeSpecification.genericTypeParameters.size
		if (type instanceof ParameterizedType) {
			if (type.typeParameters.size != genericTypeParamSize) {
				error = true
			}
		} else {
			if (genericTypeParamSize > 0) {
				error = true
			}
		}
		if (error) {
			error(
				"Wrong number of parameters. Type " + type.typeSpecification.name + " must be extended with" +
					genericTypeParamSize + " parameters",
				type,
				IsmlPackage.Literals.REFERENCE__REFERENCED_ELEMENT
			)
		}
	}

}
