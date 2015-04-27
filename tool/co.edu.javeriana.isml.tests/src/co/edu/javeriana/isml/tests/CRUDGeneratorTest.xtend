package co.edu.javeriana.isml.tests

import co.edu.javeriana.isml.IsmlInjectorProvider
import co.edu.javeriana.isml.isml.InformationSystem
import com.google.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipse.xtext.xbase.compiler.CompilationTestHelper
import org.eclipse.xtext.xbase.lib.util.ReflectExtensions
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.eclipse.core.resources.ResourcesPlugin

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(IsmlInjectorProvider))
class CRUDGeneratorTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestHelper
	@Inject extension ReflectExtensions
	@Inject extension CompilationTestHelper

	
	@Test
	def void test() {
		'''
			package test
			
			entity Ent {
				String name
				Integer num
			}
		'''.parse(rs)
		rs.resources.forEach[_ | _.contents.head.assertNoErrors]
	}
}
