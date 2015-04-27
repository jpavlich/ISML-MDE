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
import org.eclipse.xtext.xbase.lib.util.ReflectExtensions
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(IsmlInjectorProvider))
class ControllerTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestHelper
	@Inject extension ReflectExtensions

	@Test
	def void uniqueInIfElse() {

		val result = '''
			package test
			
			controller Test {
				action1() {
					
				}
				
				action2() {
					String s
					if (true) {
						String s	
					} else {
						String s
					}
					
				}
			}
			
		'''.parse(rs)
		
		result.assertNoErrors
	}

	@Test
	def void correctVariableDeclaration1() {

		val result = '''
					package test
					
					controller Test {
						action2() {
								String x
								
								x = "a"
						}
					}
					
				'''.parse(rs)
		println(result.validate)
		result.assertNoErrors
	}

	@Test
	def void correctVariableDeclaration2() {

		val result = '''
			package test
			
			
			controller Test {
				action2() {
					String x
					if (true) {
						String y
						y = "a"
					} else {
						x = "bggg"
					}
				}
			}
			
		'''.parse(rs)
		result.assertNoErrors
	}

	@Test
	def void correctVariableDeclaration3() {

		val result = '''
			package test
			

			
			controller Test {
				action2() {
					if (true) {
						String x
						x = "aa"
					} else {
						String x
						x = "bb"
					}
				}
			}
			
		'''.parse(rs)
		result.assertNoErrors
	}

	@Test
	def void incorrectVariableDeclaration1() {

		'''
			package test
			
			
			controller Test {
				action2() {
						x = 1
						String x
				}
			}
			
		'''.parse(rs).assertErrors
	}

	@Test
	def void incorrectVariableDeclaration2() {

		'''
			package test
			
			
			controller Test {
				action2() {
					if (true) {
						String x
					} else {
						x = 1
					}
				}
			}
			
		'''.parse(rs).assertErrors
	}

	@Test
	def void incorrectVariableDeclaration3() {

		'''
			package test
			
			
			controller Test {
				action2() {
					if (true) {
					} else {
						x = 1
					}
					String x
				}
			}
			
		'''.parse(rs).assertErrors
	}

	@Test
	def void parameterReference() {

		'''
			package test
			

			
			controller Test {
				action(String a, String b) {
					-> action2(a)
					-> action2(b)
				}
				
				action2(String c) {
					
				}
			}
			
		'''.parse(rs).assertNoErrors
	}

	@Test
	def void otherControllerActionCall() {

		'''
			package test
			
			
			controller Test {
				action(String a, String b) {
					-> Test2.action3()
				}
				
				action2(String c) {
					
				}
			}
			
			controller Test2 {
				action3() {
				}
			}
			
		'''.parse(rs).assertNoErrors
	}
	
		@Test
	def void otherControllerActionCallMultipleResources() {
		'''
			package test
			
			
			controller Test {
				action(String a, String b) {
					-> Test2.action3()
				}
				
				action2(String c) {
					
				}
			}
			
		'''.parse(rs)
		'''
			package test
			
			
			controller Test2 {
				action3() {
				}
			}
			
		'''.parse(rs)
		rs.resources.forEach[_ | _.contents.get(0).assertNoErrors]
	}
	
	@Test
	def void nullParameterCall() {

		'''
			package test
			
			
			controller Test {
				action() {
					-> action2(null)
				}
				
				action2(String c) {
					
				}
			}
			
			
		'''.parse(rs).assertNoErrors
	}
	
	
	@Test
	def void callWithinCall() {
		
	}
}
