package co.edu.javeriana.isml.tests

import co.edu.javeriana.isml.IsmlInjectorProvider
import co.edu.javeriana.isml.isml.Action
import co.edu.javeriana.isml.isml.Controller
import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.isml.Package
import co.edu.javeriana.isml.isml.Variable
import co.edu.javeriana.isml.validation.TypeChecker
import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(IsmlInjectorProvider))
class TypeCheckerTest extends CommonTests {
	@Inject extension ParseHelper<InformationSystem>
	@Inject extension ValidationTestHelper
	@Inject extension TestHelper
	@Inject extension TypeChecker

	private val code = '''
		package test
			
			controller Controller {
				action() {
					Integer i = 10
				}
			}
	'''


	@Test
	def void getCorrectType() {
		val is = code.parse(rs)
		val pkg = is.components.get(0) as Package
		val controller = pkg.components.get(0) as Controller
		val action = controller.parameters.get(0) as Action
		val variable = action.body.statements.get(0) as Variable

		val varType = variable.type.typeSpecification.name
		Assert.assertEquals("Integer", varType)
	}

	@Test
	def void getCorrectType2() {
		val is = code.parse(rs)
		val pkg = is.components.get(0) as Package
		val controller = pkg.components.get(0) as Controller
		val action = controller.parameters.get(0) as Action
		val variable = action.body.statements.get(0) as Variable
		val value = variable.value
		val valueType = value.type.typeSpecification.name
		Assert.assertEquals("Integer", valueType)
	}

}
