package co.edu.javeriana.isml.tests

import co.edu.javeriana.isml.IsmlInjectorProvider
import co.edu.javeriana.isml.isml.Action
import co.edu.javeriana.isml.isml.Block
import co.edu.javeriana.isml.isml.Controller
import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.isml.Package
import co.edu.javeriana.isml.isml.Type
import co.edu.javeriana.isml.isml.TypeSpecification
import co.edu.javeriana.isml.isml.Variable
import co.edu.javeriana.isml.scoping.IsmlModelNavigation
import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(IsmlInjectorProvider))
class ControllerTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestHelper
	@Inject extension IsmlModelNavigation

	@Test
	def void uniqueInIfElse() {

		val is = '''
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

		is.assertNoErrors
		is.assertEqualsElement(
			InformationSystem -> #[
				"components" -> #[
					Package -> #[
						"name" -> "test",
						"components" -> #[
							Controller -> #[
								"name" -> "Test",
								"parameters" -> #[
									Action -> #[],
									Action -> #[
										"body" -> (Block -> #[
											"statements" -> #[
												Variable -> #[
													"name" -> "s",
													"type" -> (Type -> #[
														"typeSpecification" -> (TypeSpecification -> #[
															"name" -> "String"			
														])
													]) 
												]
											]
										])
									]
								]
							]
						]
					]
				]
			]
		)
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
		rs.resources.forEach[_|_.contents.get(0).assertNoErrors]
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
