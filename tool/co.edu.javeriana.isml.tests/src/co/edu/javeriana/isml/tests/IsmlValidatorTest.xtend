package co.edu.javeriana.isml.tests

import co.edu.javeriana.isml.IsmlInjectorProvider
import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.validation.TypeChecker
import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(IsmlInjectorProvider))
class IsmlValidatorTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestHelper
	@Inject extension TypeChecker

	@Test
	def void incorrectAssignment() {
		println("incorrectAssignment")
		val is = '''
			package test
				controller Controller {
					action() {
						Integer i = "a"
					}
				}
		'''.parse(rs)
		println(is.validate) // prints errors
		is.assertErrors
	}

	@Test
	def void incorrectAssignmentGenericArray() {
		println("incorrectAssignmentGenericArray")
		val is = '''
			package test
			
			
			entity Course {
			
			}
			
			service Persistence {
				native Any load(Type t,Integer id)
				native <T> Collection<T> findAll(Type<T> t)
			}
			
			controller Controller {
				has Persistence persistence
				action() {
					Course course = persistence.findAll(Course)
				}
			}
			
		'''.parse(rs)
		println(is.validate) // prints errors
		is.assertErrors
	}

	@Test
	def void incorrectAssignmentArrayContent() {
		println("incorrectAssignmentArrayContent")
		val is = '''
			package test
			
			
			entity Course {
				
			}
			
			service Persistence {
				native Any load(Type t,Integer id)
				native <T> Collection<T> findAll(Type<T> t)
			}
			
			controller Controller {
				has Persistence persistence
				action() {
					Collection<Course> course = persistence.findAll(String)
				}
			}
			
		'''.parse(rs)
		println(is.validate) // prints errors
		is.assertErrors
	}

	@Test
	def void correctAssignmentGenericsWithTypes() {
		println("correctAssignmentGenericsWithTypes")
		'''
			package test
			
			
			entity Course {
				
			}
			
			service Test {
				native <T> T load(Type<T> t,Integer id)
				native <T> Collection<T> findAll(Type<T> t)
			}
			
			controller Controller {
				has Test test
				action() {
					Course course = test.load(Course, 1)
				}
			}
			
		'''.parse(rs).assertNoErrors
	}

	@Test
	def void parameterizedType4() {

		'''
			package test
			
			
			entity Course {
				
			}
			
			service Persistence {
				native Any load(Type t,Integer id)
				native <T> Collection<T> findAll(Type<T> t)
			}
			
			controller Controller {
				has Persistence persistence
				action() {
					Course course = persistence.load(String, 1)
				}
			}
			
		'''.parse(rs).assertErrors
	}

	@Test
	def void callToGenericMethod() {
		println("callToGenericMethod")
		val is = '''
					package test
					
					
					
					entity Course {
						
					}
					
					service Persistence {
						native <T> T load(Type<T> type,Integer id)
						native <T> Collection<T> findAll(Type<T> type)
						native <T> T delete(Type<T> type, Integer id)
						native <T> T delete(T obj)
					}
					
					controller Controller {
						has Persistence persistence
						action() {
							Course course
							persistence.delete(course)
						}
					}
					
				'''.parse(rs)
		println(is.validate)
		is.assertNoErrors
	}
}
