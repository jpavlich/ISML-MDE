package co.edu.javeriana.isml.tests

import co.edu.javeriana.isml.IsmlInjectorProvider
import co.edu.javeriana.isml.isml.Action
import co.edu.javeriana.isml.isml.ActionCall
import co.edu.javeriana.isml.isml.Assignment
import co.edu.javeriana.isml.isml.Controller
import co.edu.javeriana.isml.isml.If
import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.isml.Package
import co.edu.javeriana.isml.isml.Reference
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

import static org.junit.Assert.*

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
			package test;
			
			controller Test {
				action1() {
					
				}
				
				action2() {
					String s;
					if (true) {
						String s;
					} else {
						String s;
					}
					
				}
			}
			
		'''.parse(rs)

		is.assertNoErrors
		is.assertEqualsElement(
			InformationSystem -> #[
				"body" -> #[
					Package -> #[
						"name" -> "test",
						"body" -> #[
							Controller -> #[
								"name" -> "Test",
								"body" -> #[
									Action -> #[],
									Action -> #[
										"body" -> #[
											Variable -> #[
												"name" -> "s",
												"type" -> (Type -> #[
													"referencedElement" -> (TypeSpecification -> #[
														"name" -> "String"
													])
												])
											]
										]
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

		val is = '''
			package test;
			
			controller Test {
				action2() {
						String x;
						
						x = "a";
				}
			}
			
		'''.parse(rs)
		println(is.validate)
		is.assertNoErrors

		val action2 = is.components.head.cast(Package).components.head.cast(Controller).body.head.cast(Action)
		val v = action2.body.head.cast(Variable)
		val assignment = action2.body.get(1).cast(Assignment)
		val assignedVar = assignment.left.cast(Reference).referencedElement
		assertSame(v, assignedVar);
	}

	@Test
	def void correctVariableDeclaration2() {

		val is = '''
			package test;
			
			
			controller Test {
				action2() {
					String x;
					if (true) {
						String y;
						y = "a";
					} else {
						x = "bggg";
					}
				}
			}
			
		'''.parse(rs)
		is.assertNoErrors

		val action2 = is.components.head.cast(Package).components.head.cast(Controller).body.head.cast(Action)
		val x = action2.body.head.cast(Variable)
		val y = action2.body.get(1).cast(If).body.head.cast(Variable)
		val xAssignment = action2.body.get(1).cast(If).elseBody.head.cast(Assignment)
		val yAssignment = action2.body.get(1).cast(If).body.get(1).cast(Assignment)

		// Verifies that the assignment x="bggg" corresponds to the variable x
		assertSame(x, xAssignment.left.cast(Reference).referencedElement)
		// Verifies that the assignment y="a" corresponds to the variable y
		assertSame(y, yAssignment.left.cast(Reference).referencedElement)

	}

	@Test
	def void correctVariableDeclaration3() {

		val is = '''
			package test;
			
			
			
			controller Test {
				action2() {
					if (true) {
						String x;
						x = "aa";
					} else {
						String x;
						x = "bb";
					}
				}
			}
			
		'''.parse(rs)
		is.assertNoErrors

		val action2 = is.components.head.cast(Package).components.head.cast(Controller).body.head.cast(Action)
		val x = action2.body.head.cast(If).body.head.cast(Variable)
		val x2 = action2.body.head.cast(If).elseBody.head.cast(Variable)
		val xAssignment = action2.body.head.cast(If).body.get(1).cast(Assignment)
		val x2Assignment = action2.body.head.cast(If).elseBody.get(1).cast(Assignment)

		assertSame(x, xAssignment.left.cast(Reference).referencedElement)
		assertSame(x2, x2Assignment.left.cast(Reference).referencedElement)
	}

	@Test
	def void incorrectVariableDeclaration1() {

		val is = '''
					package test;
					
					
					controller Test {
						action2() {
								x = 1;
								String x;
						}
					}
					
				'''.parse(rs)
		is.assertErrors
		is.assertNoSyntaxErrors
		
	}

	@Test
	def void incorrectVariableDeclaration2() {

		val obj = '''
					package test;
					
					
					controller Test {
						action2() {
							if (true) {
								String x;
							} else {
								x = 1;
							}
						}
					}
					
				'''.parse(rs)
		obj.assertErrors
		obj.assertNoSyntaxErrors
	}

	@Test
	def void incorrectVariableDeclaration3() {

		val obj = '''
					package test;
					
					
					controller Test {
						action2() {
							if (true) {
							} else {
								x = 1;
							}
							String x;
						}
					}
					
				'''.parse(rs)
		obj.assertErrors
		obj.assertNoSyntaxErrors
	}

	@Test
	def void parameterReference() {

		val is = '''
			package test;
			
			
			
			controller Test {
				action(String a, String b) {
					-> action2(a);
					-> action(a,b);
					-> action2(b);
					-> action(b,a);
				}
				
				action2(String c) {
					
				}
			}
			
		'''.parse(rs)
		is.assertNoErrors
		val action = is.components.head.cast(Package).components.head.cast(Controller).body.head.cast(Action)
		val action2 = is.components.head.cast(Package).components.head.cast(Controller).body.get(1).cast(Action)
		val action2Call1 = action.body.head.cast(ActionCall)
		val action1Call1 = action.body.get(1).cast(ActionCall)
		val action2Call2 = action.body.get(2).cast(ActionCall)
		val action1Call2 = action.body.get(3).cast(ActionCall)

		assertSame(action, action1Call1.referencedElement)
		assertSame(action, action1Call2.referencedElement)
		assertSame(action2, action2Call1.referencedElement)
		assertSame(action2, action2Call2.referencedElement)

	}

	@Test
	def void parameterReference2() {

		val is = '''
			package test;
			
			
			
			controller Test {
				action(String a, String b) {
					a = "aa";
				}
				
				action2(String c) {
					
				}
			}
			
		'''.parse(rs)
		is.assertNoErrors

	}

	@Test
	def void otherControllerActionCall() {

		val is = '''
			package test;
			
			
			controller Test {
				action(String a, String b) {
					-> Test2.action3();
				}
				
				action2(String c) {
					
				}
			}
			
			controller Test2 {
				action3() {
				}
			}
			
		'''.parse(rs)
		is.assertNoErrors

		val action = is.components.head.cast(Package).components.head.cast(Controller).body.head.cast(Action)
		val action3 = is.components.head.cast(Package).components.get(1).cast(Controller).body.head.cast(Action)

		val action3Call = action.body.head.cast(ActionCall)

		assertSame(action3, action3Call.referencedElement)
	}

	@Test
	def void otherControllerActionCallMultipleResources() {
		val is = '''
			package test;
			
			
			controller Test {
				action(String a, String b) {
					-> Test2.action3();
				}
				
				action2(String c) {
					
				}
			}
			
		'''.parse(rs)
		val is2 = '''
			package test;
			
			
			controller Test2 {
				action3() {
				}
			}
			
		'''.parse(rs)
		rs.resources.forEach[_|_.contents.get(0).assertNoErrors]

		val action = is.components.head.cast(Package).components.head.cast(Controller).body.head.cast(Action)
		val action3 = is2.components.head.cast(Package).components.head.cast(Controller).body.head.cast(Action)

		val action3Call = action.body.head.cast(ActionCall)

		assertSame(action3, action3Call.referencedElement)
	}

	@Test
	def void nullParameterCall() {

		val is = '''
			package test;
			
			
			controller Test {
				action() {
					-> action2(null);
				}
				
				action2(String c) {
					
				}
			}
			
			
		'''.parse(rs)
		is.assertNoErrors
		val action = is.components.head.cast(Package).components.head.cast(Controller).body.head.cast(Action)
		val action2 = is.components.head.cast(Package).components.head.cast(Controller).body.get(1).cast(Action)

		val action2Call = action.body.head.cast(ActionCall)
		assertSame(action2, action2Call.referencedElement)

	}

	@Test
	def void callWithinCall() {
		val is = '''
			package test;
			
			
			controller Test {
				action() {
					-> action();
				}
				
				action2(String c) {
					
				}
			}
			
			
		'''.parse(rs)
		is.assertNoErrors
	}

}
