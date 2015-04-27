package co.edu.javeriana.isml.validation

import co.edu.javeriana.isml.isml.IsmlFactory
import co.edu.javeriana.isml.isml.IsmlPackage
import co.edu.javeriana.isml.isml.ParameterizedType

import co.edu.javeriana.isml.isml.Type
import co.edu.javeriana.isml.isml.TypeSpecification
import co.edu.javeriana.isml.scoping.TypeExtension
import com.google.inject.Inject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.resource.Resource
import co.edu.javeriana.isml.isml.Primitive

class TypeFactory {

	@Inject extension TypeExtension

	def Type getPrimitiveType(Resource r, String name) {
		val primitive = getPrimitiveTypeSpecification(r, name)
		return primitive.createType
	}

	def ParameterizedType getPrimitiveType(Resource r, String name, Type... typeParameters) {
		val primitive = getPrimitiveTypeSpecification(r, name)
		return primitive.createType(typeParameters)
	}

	def getPrimitiveTypeSpecification(Resource r, String name) {
		val primitives = r.resourceSet.getAllInstances(Primitive)
		val primitive = primitives.findByName(name) as TypeSpecification
		primitive
	}

	def Type createType(TypeSpecification c) {
		if(c.genericTypeParameters.empty) {
			val type = IsmlFactory.eINSTANCE.createType
			type.setTypeSpecification(c)
			return type
		} else {
			val type = IsmlFactory.eINSTANCE.createParameterizedType
			for (genTypeSpec : c.genericTypeParameters) {
				type.typeParameters.add(genTypeSpec.createType)
			}
			return type
		
		}
	}

	def ParameterizedType createType(TypeSpecification c, Type... typeParameters) {
		val type = IsmlFactory.eINSTANCE.createParameterizedType
		type.setTypeSpecification(c)
		for (param : typeParameters) {
			type.typeParameters.add(EcoreUtil.copy(param))
		}
		return type
	}
}
