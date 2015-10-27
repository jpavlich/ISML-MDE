package co.edu.javeriana.isml.tests

import co.edu.javeriana.isml.IsmlInjectorProvider
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.isml.Package
import co.edu.javeriana.isml.scoping.IsmlModelNavigation
import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*
import co.edu.javeriana.isml.isml.Attribute

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(IsmlInjectorProvider))
class EntityTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestHelper
	@Inject extension IsmlModelNavigation

	@Test
	def void entityStructure() {

		val is = '''
			package test;
			entity Parent {
				
			}
			
			entity Parent2;
			
			entity MyEntity extends Parent, Parent2 {
				String name;
				Integer num;
			}
			
		'''.parse(rs)
		
		is.assertNoErrors
		val pkg = is.components.head.cast(Package)
		assertEquals("test", pkg.name);
		assertArrayEquals(#["Parent", "Parent2", "MyEntity"], pkg.components.map[_|_.name])
		val entity = pkg.components.get(2).cast(Entity)
		assertArrayEquals(#["name", "num"], entity.body.filter(Attribute).map[_|_.name])
		assertArrayEquals(#["String", "Integer"], entity.body.filter(Attribute).map[_|_.type.typeSpecification.name])
		assertArrayEquals(#["Parent", "Parent2"], entity.superTypes.map[_|_.typeSpecification.name])
	}

}
