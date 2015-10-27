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
class UniqueTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestHelper

	@Test
	def void duplicateAction() {

		val result = '''
			package test;
			
			
			controller Test {
				action1() {
					
				}
				
				action1() {
					
					
				}
			}
			
		'''.parse(rs)
		result.assertErrors
	}

	@Test
	def void duplicateAction2() {

		val result = '''
			package test;
			

			controller Test {
				action1(String a, Integer b) {
					
				}
				
				action1(String a, Integer b) {
					
					
				}
			}
			
		'''.parse(rs)
		result.assertErrors
	}

	@Test
	def void overloadedAction() {

		val result = '''
			package test;
			

			
			controller Test {
				action1() {
					
				}
				
				action1(String a) {
					
					
				}
			}
			
		'''.parse(rs)
		result.assertNoErrors
	}

	@Test
	def void overloadedActionCall() {

		'''
			package test;
			
			primitive String;
			primitive Integer;
			
			controller Test {
				action(String a) {
				}
				
				action(Integer a) {
				}
								
				action2(String c) {
					->action(1);
					->action("aa");
				}
			}
			
		'''.parse.assertNoErrors
	}

	@Test
	def void duplicateMethod() {

		val result = '''
			package test;
			
			primitive String;
			
			service Test {
				method() {
					
				}
				
				method() {
					
					
				}
			}
			
		'''.parse
		result.assertErrors
	}

	@Test
	def void duplicateMethod2() {

		val result = '''
			package test;
			
			primitive String;
			primitive Integer;
			service Test {
				method(String a, Integer b) {
					
				}
				
				method(String a, Integer b) {
					
					
				}
			}
			
		'''.parse
		result.assertErrors
	}

	@Test
	def void overloadedMethod() {

		val result = '''
			package test;
			
			primitive String;
			
			service Test {
				String method() {
					
				}
			
				String method(String a) {
				
				
				}
			}
			
		'''.parse
		result.assertNoErrors
	}

	@Test
	def void overloadedMethodCall() {

		val result = '''
			package test;
			
			primitive String;
			
			service Test {
				String method() {
					
				}
			
				String method(String a) {
				
				
				}
			}
			
			controller Controller {
				has Test test;
				
				action() {
					test.method();
					test.method("a");
				}
			}
			
		'''.parse
		result.assertNoErrors
	}

	@Test
	def void duplicateController() {

		'''
			package test;
			
			primitive String;
			
			controller Test {
			}
			
			controller Test {
				
			}
			
		'''.parse.assertErrors
	}

	@Test
	def void duplicateParameter() {

		'''
			package test;
			
			primitive String;
			
			controller Test {
				action(String a, String a) {
				}
			}
			
			
			
		'''.parse.assertErrors
	}

	@Test
	def void nonDuplicateParameter() {

		'''
			package test;
			
			primitive String;
			
			controller Test {
				action(String a, String b) {
				}
			}
			
			
			
		'''.parse.assertNoErrors
	}

	@Test 
	def void duplicatePackages() {
		'''
			package test;
			
			primitive String;
			
			package test;
			primitive Integer;
			
			
			
		'''.parse.assertNoErrors
	}
}
