package co.edu.javeriana.isml.generator.simple.templates

import co.edu.javeriana.isml.generator.common.SimpleTemplate
import co.edu.javeriana.isml.isml.Attribute
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.isml.Type
import co.edu.javeriana.isml.scoping.IsmlModelNavigation
import co.edu.javeriana.isml.validation.TypeChecker
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import co.edu.javeriana.isml.isml.ConstraintInstance

public class EntityTemplate extends SimpleTemplate<Entity> {
	@Inject extension TypeChecker
	@Inject extension IQualifiedNameProvider
	@Inject extension IsmlModelNavigation

	override preprocess(Entity e) {
	}

	override def CharSequence template(Entity e) '''
		Entity {
			name = «e.name»
			extends = «e.parentsToText»
			body = {
				«FOR attr : e.attributes»
				Attribute {
					name = «attr.name»
					type = «attr.type.toText»
					constraints = «attr.constraintsToText»
				}
				«ENDFOR»
			}
		}
	'''

	def toText(Type t) '''«t.typeSpecification.name»'''
	
	def parentsToText(Entity e) '''[«FOR p : e.parents SEPARATOR ','»«p.typeSpecification.name»«ENDFOR»]'''
	
	def constraintsToText(Attribute attr) '''[«FOR c : attr.constraints SEPARATOR ','»«c.toText»«ENDFOR»]'''

	def toText(ConstraintInstance c) '''«c.type.typeSpecification.name»'''
}
