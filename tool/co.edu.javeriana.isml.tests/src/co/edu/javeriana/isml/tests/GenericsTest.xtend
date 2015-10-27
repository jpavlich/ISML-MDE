package co.edu.javeriana.isml.tests

import co.edu.javeriana.isml.IsmlInjectorProvider
import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.isml.Package
import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith
import co.edu.javeriana.isml.isml.Service
import co.edu.javeriana.isml.isml.Method
import co.edu.javeriana.isml.validation.SignatureExtension
import org.junit.Assert
import co.edu.javeriana.isml.scoping.IsmlModelNavigation

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(IsmlInjectorProvider))
class GenericsTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestHelper
	@Inject extension SignatureExtension
	@Inject extension IsmlModelNavigation

	@Test def void overloadedMethodSignatureTest() {
		val is = '''package test;
		
					
					service Persistence {
						native <T> T delete(Type<T> type, Integer id);
						native <T> T delete(T obj);
					}
				'''.parse(rs)
		val pkg = is.components.get(0) as Package
		val serv = pkg.components.get(0) as Service
		val met1 = serv.body.get(0) as Method
		val met2 = serv.body.get(1) as Method
		
		println(met1.signature)
		Assert.assertEquals("test.Persistence.delete(common.primitives.Type<T>,common.primitives.Integer)", met1.signature)
		println(met2.signature)
		Assert.assertEquals("test.Persistence.delete(T)", met2.signature)
	}
	
	
	@Test def void genericsAndInheritance() {
		
		'''
		package test;
		
		entity Team {
			
		}
		'''.parse(rs)
		'''
		package test;
		
		page TeamList(Array <Team> teams, Team selectedTeam, String queryCountry) controlledBy TeamListManager {
			
		}
		'''.parse(rs)
		
		'''
		package test;
		
		controller TeamListManager {
			has TeamPersistence teamPersistence;
			action() {
				show TeamList(teamPersistence.findAll(),null,null);
			}
		}
		'''.parse(rs)
		
		'''
		package test;
		
		service TeamPersistence extends Persistence<Team> {
			
		}
		'''.parse(rs)
		
		rs.resources.forEach[_ | _.contents.get(0).assertNoErrors]
	}
	
	@Test def void genericsInstantiation() {
		
		'''
		package test;
		
		entity Team {
			
		}
		'''.parse(rs)
		'''
		package test;
		
		page TeamList(Array <Team> teams, Team selectedTeam, String queryCountry) controlledBy TeamListManager {
			
		}
		'''.parse(rs)
		
		'''
		package test;
		
		controller TeamListManager {
			has Persistence<Team> teamPersistence;
			action() {
				show TeamList(teamPersistence.findAll(),null,null);
			}
		}
		'''.parse(rs)
		
		
		rs.resources.forEach[_ | _.contents.get(0).assertNoErrors]
	}
	
	@Test def void wrongNumOfTypeParameters() {
		
		'''
		package test;
		
		service Test<T> {
			
		}
		'''.parse(rs)
		
		'''
		package test;
		
		service Test2 extends Test<Integer,Integer> {
			
		}
		'''.parse(rs).assertErrors
		
		
	}
	
}
