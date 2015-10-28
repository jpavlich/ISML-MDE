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
import co.edu.javeriana.isml.isml.Type
import co.edu.javeriana.isml.isml.Variable
import co.edu.javeriana.isml.isml.ViewInstance
import co.edu.javeriana.isml.isml.Widget
import co.edu.javeriana.isml.scoping.IsmlModelNavigation
import com.google.inject.Inject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.validation.Check
import org.eclipse.xtext.validation.ComposedChecks
import co.edu.javeriana.isml.isml.NamedElement

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
		checkParameters(instance, typeSpecification, IsmlPackage.Literals.INSTANCE__TYPE)
		if(typeSpecification instanceof Widget) {
			checkBlockParameters(instance as ViewInstance, typeSpecification);
		}

	}

	@Check
	def functionCallParametersMustMatchFunctionArguments(Reference<?> caller) {
		val callee = caller.referencedElement
		if(caller instanceof ParameterizedReference<?> && callee instanceof Function) {
			checkParameters(caller as Caller, callee as Function, caller.eClass.getEStructuralFeature("referencedElement"))

		}

	}

	def checkBlockParameters(ViewInstance instance, Widget widget) {
		if(widget.hasBody != instance.hasBody) {
			error("This widget must have a body", instance, IsmlPackage.Literals.TYPED_ELEMENT__TYPE)
			return
		}

		if(widget.body.size > 0 && widget.body.size != instance.body.size) {
			error("Incorrect body parameters", instance, IsmlPackage.Literals.COMPOSITE_ELEMENT__BODY);
		}
		// Checks specific arguments only if the widget body has some elements in it
		if(widget.body.size > 0) {

			for (i : 1 ..< widget.body.size) {
				try {
					val instanceElem = instance.body.get(i)
					val widgetElem = widget.body.get(i)
					if(instanceElem.type.typeSpecification != widgetElem.type.typeSpecification)
					{
						error("Incorrect body parameters", instance, IsmlPackage.Literals.COMPOSITE_ELEMENT__BODY);
					}
					if (instanceElem instanceof NamedElement) {
						if (widgetElem instanceof NamedElement) {
							if (!instanceElem.name.equals(widgetElem.name)) {
								error("Incorrect body parameters", instance, IsmlPackage.Literals.COMPOSITE_ELEMENT__BODY);
							}
							
						}
					}

				} catch(Exception e) {
					e.printStackTrace
				}
			}
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
					errorString +=
						"Parameter " + (i + 1) + " of type " + realType?.typeSpecification?.name + " must be of type " +
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
						"Cannot assign value of type " + rightType.fullName + " to variable " + (a.left as Reference<?>).referencedElement.name + " of type " +
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
					if(genericTypeParamSize > 0) {
						error = true
					}
				}
				if(error) {
					error(
						"Wrong number of parameters. Type " + type.typeSpecification.name + " must be extended with" + genericTypeParamSize + " parameters",
						type,
						IsmlPackage.Literals.REFERENCE__REFERENCED_ELEMENT
					)
				}
			}

		}
