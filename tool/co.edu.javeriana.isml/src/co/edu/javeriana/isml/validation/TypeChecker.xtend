package co.edu.javeriana.isml.validation

import co.edu.javeriana.isml.isml.BinaryOperator
import co.edu.javeriana.isml.isml.BoolValue
import co.edu.javeriana.isml.isml.Caller
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.isml.EnumItem
import co.edu.javeriana.isml.isml.FloatValue
import co.edu.javeriana.isml.isml.Function
import co.edu.javeriana.isml.isml.Instance
import co.edu.javeriana.isml.isml.IntValue
import co.edu.javeriana.isml.isml.Method
import co.edu.javeriana.isml.isml.MethodCall
import co.edu.javeriana.isml.isml.NullValue
import co.edu.javeriana.isml.isml.Page
import co.edu.javeriana.isml.isml.ParameterizedType
import co.edu.javeriana.isml.isml.Primitive
import co.edu.javeriana.isml.isml.Reference
import co.edu.javeriana.isml.isml.Resource
import co.edu.javeriana.isml.isml.StringValue
import co.edu.javeriana.isml.isml.Type
import co.edu.javeriana.isml.isml.TypeSpecification
import co.edu.javeriana.isml.isml.TypedElement
import co.edu.javeriana.isml.isml.UnaryOperator
import co.edu.javeriana.isml.scoping.IsmlModelNavigation
import com.google.inject.Inject
import org.eclipse.xtext.EcoreUtil2
import co.edu.javeriana.isml.isml.NamedViewBlock

class TypeChecker {
	@Inject extension IsmlModelNavigation
	@Inject extension Generics
	@Inject extension TypeFactory

	def boolean isCongruentWith(Function callee, Caller caller) {
		val realParameters = caller.parameters
		val realSize = realParameters.size
		val formalParameters = callee.parameters
		val formalSize = formalParameters.size
		if(realSize != formalSize) {
			return false
		}

		val typeSubstitutions = callee.getTypeSubstitutions(caller)

		for (var i = 0; i < realSize; i++) {
			val realParam = realParameters.get(i)
			val formalParam = formalParameters.get(i)

			try {
				val realType = realParam.type
				val formalType = formalParam.type //EcoreUtil.resolve(formalParam.type, instance) as Type
				val instantiatedType = formalType.instantiate(typeSubstitutions)
				if(instantiatedType != null && !instantiatedType.isAssignableFrom(realType)) {
					return false
				}

			} catch(Throwable t2) {
				t2.printStackTrace
			}
		}
		return true
	}
	
	def filterCongruent(Iterable<? extends Function> callees, Caller caller) {
		if (caller.parameters.empty) {
			return callees
		} else {
			return callees.filter[f | f.isCongruentWith(caller)]
		}
	}

	def boolean isCollection(Type type) {
		type.typeSpecification.isSubtypeSpecificationOf(type.eResource.getPrimitiveTypeSpecification("Collection"))
	}

	def boolean isMapModel(Type type) {
		type.typeSpecification.isSubtypeSpecificationOf(type.eResource.getPrimitiveTypeSpecification("MapModel"))
	}
	// TODO Check cardinality
	def boolean isAssignableFrom(Type t1, Type t2) {
		if(t1 == null || t2 == null) {
			//			println("Error")
			return false
		}
		if(t1.typeSpecification != null && t2.typeSpecification != null) {
			return (t1.typeSpecification).isParentOf(t2.typeSpecification) && typeParametersAreAssignable(t1,t2)
		} else {
			return EcoreUtil2.equals(t1, t2)
		}
	}
	
	def typeParametersAreAssignable(Type type1, Type type2) {
		if (type1 instanceof ParameterizedType) {
			if (type2 instanceof ParameterizedType) {
				for (i : 0..< type1.typeParameters.size) {
					val typeParam1 = type1.typeParameters.get(0)
					val typeParam2 = type2.typeParameters.get(0)
					if (!typeParam1.isAssignableFrom(typeParam2)) {
						return false
					}  
				}
			}
		}
		return true
	}

	def boolean isParentOf(TypeSpecification c1, TypeSpecification c2) {
		if(c1 == null || c2 == null) {
			return false
		}
		if(c1 instanceof Entity || c1 instanceof Primitive) {
			if("Any".equals(c1.name) || "Null".equals(c2.name)) {
				return true
			}
		}
		if(c1 instanceof Page) {
			if("AnyPage".equals(c1.name)) {
				return true
			}
		}
		return findIsParentOf(c1, c2)
	}

	private def boolean findIsParentOf(TypeSpecification c1, TypeSpecification c2) {
		if(c2 != null) {
			if(EcoreUtil2.equals(c1, c2)) {
				return true
			} else {
				for (superType : c2.superTypes) {
					if(c1.findIsParentOf(superType.typeSpecification)) {
						return true
					}
				}
			}
		}
		return false
	}

	def Type maxType(Type type, Type type2) {

		// TODO Complete
		return type
	}

	// Operator types
	def dispatch Type getType(UnaryOperator exp) {
		exp.expression.type
	}

	def dispatch Type getType(NullValue exp) {

		// FIXME Add null to primitives
		return exp.eResource.getPrimitiveType("Null")
	}

	def dispatch Type getType(BinaryOperator exp) {
		switch (exp.symbol) {
			case "as": exp.right as Type
			case "is": exp.eResource.getPrimitiveType("Boolean")
			default: maxType(exp.left.type, exp.right.type)
		}
	}

	// References	
	def dispatch Type getType(Reference r) {
		var current = r
		while(current.tail != null) {
			current = current.tail
		}

		//		val element = EcoreUtil.resolve(current.referencedElement, r.eResource.resourceSet) as TypedElement
		val element = current.referencedElement
		EcoreUtil2.resolve(element, r.eResource.resourceSet)

		if(element instanceof Resource) {
			return element.eResource.getPrimitiveType("String")
		} else if(current instanceof Type) {
			return current.eResource.getPrimitiveType("Type")
		} else if(current instanceof MethodCall) {
			return current.type
		} else {
			return element.type
		}
	}

	// Constant types
	def dispatch Type getType(BoolValue exp) {
		exp.eResource.getPrimitiveType("Boolean")
	}

	def dispatch Type getType(StringValue exp) {
		exp.eResource.getPrimitiveType("String")
	}

	def dispatch Type getType(IntValue exp) {
		exp.eResource.getPrimitiveType("Integer")
	}

	def dispatch Type getType(FloatValue exp) {
		exp.eResource.getPrimitiveType("Float")
	}

	def dispatch Type getType(Instance exp) {
		exp.type
	}

	def dispatch Type getType(Type exp) {
		exp.eResource.getPrimitiveType("Type", exp)
	}

	def dispatch Type getType(NamedViewBlock exp) {
		exp.eResource.getPrimitiveType("Block")
	}

	def dispatch Type getType(MethodCall caller) {
		val callee = caller.referencedElement as Method
		val typeSubstitutions = callee.getTypeSubstitutions(caller)
		return callee.type.instantiate(typeSubstitutions)
	}

	def dispatch Type getType(EnumItem exp) {
		exp.eContainer.type
	}

	def dispatch getType(TypedElement te) {
		return te.type

	}

	/**
	 * If a's type is a ParameterizedType, obtains the first type parameter of the type of a.
	 * Otherwise it returns null
	 */
	def containedTypeSpecification(Type type) {
		if(type instanceof ParameterizedType) {
			return type.typeParameters.head?.typeSpecification
		}
	}

}
