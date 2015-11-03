package co.edu.javeriana.isml.tests

import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.InjectWith
import co.edu.javeriana.isml.IsmlInjectorProvider
import org.eclipse.xtext.junit4.util.ParseHelper
import co.edu.javeriana.isml.isml.InformationSystem
import com.google.inject.Inject
import org.junit.Test
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import co.edu.javeriana.isml.isml.IsmlPackage
import org.junit.Assert
import org.eclipse.emf.ecore.EObject

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(IsmlInjectorProvider))
class DTOTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestHelper

	@Test
	def void accessDTOAttrs() {

		val is = '''
			package test;
			
			controller Cont {
				
			}
			
			dto MyDTO {
				String name;
				Integer num;
			}
			
			page Test(MyDTO myDto) controlledBy Cont {
				Button(myDto.name, true);
			}
			
		'''.parse(rs)
		is.assertNoErrors

	}

	@Test
	def void accessDTOAttrs2() {

		val is = '''
			package test;
			
			dto MyDTO {
				String name;
				Integer num;
			}			
			
			controller Cont {
				action(MyDTO adto) {
					String n = adto.name;
				}
			}
			

		'''.parse(rs)
		is.assertNoErrors

	}
	
	@Test
	def void accessDTOAttrs3() {

		val is = '''
			package test;
			
			controller Cont {
				action(MyDTO adto) {
					String n = adto.name;
				}
			}
			
			dto MyDTO {
				String name;
				Integer num;
			}
		'''.parse(rs)
		is.assertNoErrors

	}	

}
