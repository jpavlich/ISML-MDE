package co.edu.javeriana.isml.validation

import co.edu.javeriana.isml.isml.Controller
import co.edu.javeriana.isml.isml.Function
import co.edu.javeriana.isml.isml.GenericTypeSpecification
import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.isml.Parameter
import co.edu.javeriana.isml.isml.ParameterizedType
import co.edu.javeriana.isml.isml.Type
import java.util.LinkedList
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.QualifiedName

class SignatureExtension {

	def String getSignature(EObject obj) {

		switch (obj) {
			Controller: {
				return obj.fullyQualifiedID.toString
			}
			Function: {
				var sig = new StringBuilder(obj.fullyQualifiedID.toString)
				sig.append('''(«FOR param : obj.parameters SEPARATOR ","»«param.type.signature»«ENDFOR»)''')
				return sig.toString
			}
			Parameter: {
				val container = obj.eContainer
				if(container instanceof Function) {
					return container.signature + obj.name
				} else {
					return obj.fullyQualifiedID.toString
				}
			}
			ParameterizedType: {
				var sig = new StringBuilder(obj.typeSpecification.fullyQualifiedID.toString)
				sig.append('''<«FOR param : obj.typeParameters SEPARATOR ","»«param.signature»«ENDFOR»>''')
				return sig.toString
			}
			Type: {
				val typeSpec = obj.typeSpecification
				if(typeSpec instanceof GenericTypeSpecification) {
					return typeSpec.name
				}
				return typeSpec.fullyQualifiedID.toString
			}
			default:
				return obj.fullyQualifiedID.toString
		}

	}

	def QualifiedName getFullyQualifiedID(EObject obj) {

		var id = new LinkedList<String>
		id.add(obj.getStringID)

		var current = obj?.eContainer
		if(current != null) {
			while(!(current instanceof InformationSystem)) {
				id.add(0, current.stringID)
				current = current.eContainer
			}
		}
		return QualifiedName.create(id);
	}

	private def String getStringID(EObject obj) {
		val nameFeature = obj?.eClass?.getEStructuralFeature("name")
		if(nameFeature != null) {
			val name = obj.eGet(nameFeature) as String
			if(name != null) {
				return name
			}
		}
		return String.valueOf(obj)
	}
}
