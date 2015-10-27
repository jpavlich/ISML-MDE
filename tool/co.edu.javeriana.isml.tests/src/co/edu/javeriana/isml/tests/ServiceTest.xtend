package co.edu.javeriana.isml.tests

import co.edu.javeriana.isml.IsmlInjectorProvider
import co.edu.javeriana.isml.isml.InformationSystem
import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(IsmlInjectorProvider))
class ServiceTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestHelper

	@Test
	def void uniqueInIfElse() {

		val result = '''
			package test;
			
			service Test {
				Void method1() {
					
				}
				
				Void method2() {
					String s;
					if (true) {
						String s;
					} else {
						String s;
					}
					
				}
			}
			
		'''.parse(rs)
		result.assertNoErrors
	}

	@Test
	def void correctVariableDeclaration1() {

		'''
			package test;
			
			service Test {
				Void method2() {
						String x;
						x = "a";
				}
			}
			
		'''.parse(rs).assertNoErrors
	}

	@Test
	def void correctVariableDeclaration2() {

		val result = '''
			package test;
			
			service Test {
				Void method2() {
					String x;
					if (true) {
						String y;
						y = "aaa";
					} else {
						x = "bbb";
					}
				}
			}
			
		'''.parse(rs)
		result.assertNoErrors
	}

	@Test
	def void correctVariableDeclaration3() {

		val result = '''
			package test;
			
			
			service Test {
				Void method2() {
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
		result.assertNoErrors
	}

	@Test
	def void incorrectVariableDeclaration1() {

		'''
			package test;
			
			service Test {
				Void method2() {
						x = 1;
						String x;
				}
			}
			
		'''.parse(rs).assertErrors
	}

	@Test
	def void incorrectVariableDeclaration2() {

		'''
			package test;
			
			
			service Test {
				Void method2() {
					if (true) {
						String x;
					} else {
						x = 1;
					}
				}
			}
			
		'''.parse(rs).assertErrors
	}

	@Test
	def void incorrectVariableDeclaration3() {

		'''
			package test;
			
			
			service Test {
				Void method2() {
					if (true) {
					} else {
						x = 1;
					}
					String x;
				}
			}
			
		'''.parse(rs).assertErrors
	}

	@Test
	def void parameterReference() {

		'''
			package test;
			
			
			service Test {
				Void method(String a, String b) {
					method2(a);
					method2(b);
				}
				
				Void method2(String c) {
					
				}
			}
			
		'''.parse(rs).assertNoErrors
	}

	@Test
	def void parameterReference2() {

		'''
			package test;
			
			
			service Test {
				
				
				Void method2(String c) {
					
				}
				Void method(String a, String b) {
					method2(a);
					method2(b);
				}
				
			}
			
		'''.parse(rs).assertNoErrors
	}

}
