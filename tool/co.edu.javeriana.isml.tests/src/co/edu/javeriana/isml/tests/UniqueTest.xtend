package co.edu.javeriana.isml.tests

import co.edu.javeriana.isml.IsmlInjectorProvider
import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.isml.IsmlPackage
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(IsmlInjectorProvider))
class UniqueTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestHelper

	@Test
	def void duplicateAction() {

		val obj = '''
			package test;
			
			
			controller Test {
				action1() {
					
				}
				
				action1() {
					
					
				}
			}
			
		'''.parse(rs)
		obj.assertErrors
		obj.assertNoSyntaxErrors
	}

	@Test
	def void duplicateAction2() {

		val obj = '''
			package test;
			

			controller Test {
				action1(String a, Integer b) {
					
				}
				
				action1(String a, Integer b) {
					
					
				}
			}
			
		'''.parse(rs)
		obj.assertErrors
		obj.assertNoSyntaxErrors
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

		val obj = '''
			package test;
			
			primitive String;
			
			service Test {
				Void method() {
					
				}
				
				Void method() {
					
					
				}
			}
			
		'''.parse
		obj.assertErrors
		obj.assertNoSyntaxErrors
	}

	@Test
	def void duplicateMethod2() {

		val obj = '''
			package test;
			
			primitive String;
			primitive Integer;
			service Test {
				Void method(String a, Integer b) {
					
				}
				
				Void method(String a, Integer b) {
					
					
				}
			}
			
		'''.parse
		obj.assertErrors
		obj.assertNoSyntaxErrors
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

		val obj = '''
					package test;
					
					primitive String;
					
					controller Test {
					}
					
					controller Test {
						
					}
					
				'''.parse
		obj.assertErrors
		obj.assertNoSyntaxErrors
	}

	@Test
	def void duplicateParameter() {

		val obj = '''
					package test;
					
					primitive String;
					
					controller Test {
						action(String a, String a) {
						}
					}
					
					
					
				'''.parse
		obj.assertErrors
		obj.assertNoSyntaxErrors
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
