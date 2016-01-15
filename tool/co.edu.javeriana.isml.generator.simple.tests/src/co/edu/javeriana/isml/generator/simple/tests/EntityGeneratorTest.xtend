package co.edu.javeriana.isml.generator.simple.tests

import co.edu.javeriana.isml.IsmlInjectorProvider
import co.edu.javeriana.isml.generator.simple.templates.EntityTemplate
import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.isml.Package
import co.edu.javeriana.isml.scoping.IsmlModelNavigation
import co.edu.javeriana.isml.tests.CommonTests
import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.generator.test.TestGeneratorHelper

@InjectWith(IsmlInjectorProvider)
@RunWith(XtextRunner)
class EntityGeneratorTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestGeneratorHelper
	@Inject extension IsmlModelNavigation
	@Inject EntityTemplate template
	
	@Test
	def entityGeneration() {
		val informationSystem = '''
			package test;
			entity Person extends Animal, Sentient {
				String name must be Size(1,10);
				Integer age;
			}
			
			entity Animal {
				
			}
			
			entity Sentient {
				
			}
		'''.parse(rs)
		informationSystem.assertNoErrors
		val pkg = informationSystem.body.head as Package
		val entity = pkg.body.head as Entity
		
		assertGenerates(template, entity, 
		'''
			Entity {
				name = Person
				extends = [Animal, Sentient]
				body = {
					Attribute {
						name = name
						type = String
						constraints = [Size]
					}
					Attribute {
						name = age
						type = Integer
						constraints = [];
					}
				}
			}
		'''
		)
		
		
	}
}