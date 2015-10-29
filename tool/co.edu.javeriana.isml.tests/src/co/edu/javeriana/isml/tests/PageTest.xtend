package co.edu.javeriana.isml.tests

import co.edu.javeriana.isml.IsmlInjectorProvider
import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.isml.IsmlPackage
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(IsmlInjectorProvider))
class PageTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestHelper

	@Test
	def void actionCall() {

		'''
			package test;
			
			
			controller Controller {
				action1() {
					
				}
				
				action2() {
					
				}
			}
			
			page Page controlledBy Controller{
				Button("", true) -> action1();
			}
			
		'''.parse(rs).assertNoErrors
	}

	@Test
	def void actionCall2() {

		'''
			package test;
			
			
			
			controller Controller {
				action1() {
					
				}
				
				action2() {
					
				}
			}
			
			controller Controller2 {
				
			}
			
			page Page controlledBy Controller2{
				Button("", true) -> Controller.action1();
			}
			
		'''.parse(rs).assertNoErrors
	}

	@Test
	def void actionCallMultipleResources() {
		'''
			package test;
			
			
			page Page controlledBy Controller1 {
				Button("", true) -> Controller2.action2();
				Button("", true) -> action1();
				Button("", true) -> Controller1.action1();
			}
			
		'''.parse(rs)
		'''
			package test;
			
			
			controller Controller1 {
				action1() {
				}
			}
			
		'''.parse(rs)
		'''
			package test;
			
			
			controller Controller2 {
				action2() {
				}
			}
			
		'''.parse(rs)
		rs.resources.forEach[_|_.contents.get(0).assertNoErrors]
	}

	@Test
	def void incorrectActionCall() {

		val obj = '''
			package test;
			
			
			
			controller Controller {
				action1() {
					
				}
				
				action2() {
					
				}
			}
			
			controller Controller2 {
				action3() {
				}
			}
			
			page Page controlledBy Controller{
				Button("", true) -> action3();
			}
			
		'''.parse(rs)
		obj.assertErrors
		obj.assertNoSyntaxErrors
	}

	@Test
	def void forVarReference() {

		'''
			package test;
			
			
			
			
			controller Controller {
				action1() {
					
				}
				
				action2() {
					
				}
			}
			
			
			page Page(Array<String> list) controlledBy Controller{
				for (String str in list) {
					Button(str, true);
				}
			}
			
		'''.parse(rs).assertNoErrors
	}

	@Test
	def void forVarReference2() {

		'''
			package test;
			
			
			entity Entity {
				String name;
				
			}
			
			
			controller Controller {
				action1() {
					
				}
				
				action2() {
					
				}
			}
			
			
			page Page(Array<Entity> list) controlledBy Controller{
				for (Entity ent in list) {
					Button(ent.name, true);
				}
			}
			
		'''.parse(rs).assertNoErrors
	}

	@Test
	def void wodgetHasBodyAndInstanceAlsoHasBody() {
		'''
			package test;
			widget TestText;
			widget TestForm {
				
			}
			controller Controller {
				action1() {
					
				}
				
				action2() {
					
				}
			}
			
			
			page Page controlledBy Controller{
				TestForm {
					
				}
			}
			
		'''.parse(rs).assertNoErrors
	}

	@Test
	def void instanceShouldHaveBody() {
		val obj = '''
			package test;
			widget TestText;
			widget TestForm {
				
			}
			
			controller Controller {
				action1() {
					
				}
				
				action2() {
					
				}
			}
			
			page Page controlledBy Controller{
				TestForm;
			}
			
		'''.parse(rs)
		obj.assertErrors
		obj.assertNoSyntaxErrors
	}

	@Test
	def void correctBlock3() {
		'''
			package test;
			widget TestText;
			widget TestForm {
				
			}
			controller Controller {
				action1() {
					
				}
				
				action2() {
					
				}
			}
			
			
			page Page controlledBy Controller{
				TestForm {
					
				}
			}
			
		'''.parse(rs).assertNoErrors
	}

	@Test
	def void missingAndIncorrectBlockParameters() {
		val obj = '''
			package test;
			
			widget TestDataTable {
				header: {
				}
				body: {
				}
			}
			
			widget TestText;
			
			controller Controller;
			
			page Page controlledBy Controller{
				TestDataTable {
					TestText;
				}
			}
			
		'''.parse(rs)
		obj.assertErrors
		obj.assertNoSyntaxErrors
	}

	@Test
	def void incorrectBlockParameter() {
		val obj = '''
			package test;
			
			widget TestDataTable {
				header: {
				}
				body: {
				}
				
			}
			
			widget TestText;
			
			controller Controller;
			
			page Page controlledBy Controller{
				TestDataTable {
					header: {
					}
					incorrectParameter: {
					}
				}
			}
			
		'''.parse(rs)
		obj.assertErrors
		obj.assertNoSyntaxErrors
	}

	@Test
	def void missingBlockParameter() {
		val obj = '''
			package test;
			
			widget TestDataTable {
				header: {
					subheader: {
						
					}
				}
				body: {
				}
			}
			
			widget TestText;
			
			controller Controller;
			
			page Page controlledBy Controller{
				TestDataTable {
					header: {
					}
					body: {
					}
				}
			}
			
		'''.parse(rs)
		obj.assertErrors
		obj.assertNoSyntaxErrors
	}
	
	@Test
	def void correctNestedBlockParameters() {
		val obj = '''
			package test;
			
			widget TestDataTable {
						header: {
							subheader: {
								subsubheader: {
									
								}
							}
						}
						body: {
						}
					}

			widget TestText;
			
			controller Controller {
				action1() {
					
				}
				
				action2() {
					
				}
			}
			
			page Page controlledBy Controller{
				TestDataTable {
					header: {
						subheader: {
							subsubheader: {
							
							}
						}
					}
					body: {
						TestText;
					}
				}
			}
			
		'''.parse(rs)
		obj.assertNoErrors
	}
	
		@Test
	def void incorrectNestedBlockParameters() {
		val obj = '''
			package test;
			
			widget TestDataTable {
						header: {
							subheader: {
								subsubheader: {
									
								}
							}
						}
						body: {
						}
					}

			widget TestText;
			
			controller Controller {
				action1() {
					
				}
				
				action2() {
					
				}
			}
			
			page Page controlledBy Controller{
				TestDataTable {
					header: {
						subheader: {
							TestText;
						}
					}
					body: {
						TestText;
					}
				}
			}
			
		'''.parse(rs)
		obj.assertErrors
		obj.assertNoSyntaxErrors
	}

	@Test
	def void correctViewInstance() {
		'''
			package test;
			
			controller Controller ;
			widget TestWidget;
			page Page controlledBy Controller {
				Form {
					TestWidget;
				}
			}
						
		'''.parse(rs).assertNoErrors
	}

	@Test def void correctCollectionReference() {
		'''
			package test ;
			
			
			controller Controller ;
			widget TestWidget;
			
			entity Company {
				Array<Person> persons;
			}
			
			entity Person {
				String name;
				
			}
			
			page Page(Company company) controlledBy Controller {
				for(Person aPerson in company.persons) {
				 		Label(aPerson.name);
				}
						
			}
		'''.parse(rs).assertNoErrors
	}

}
