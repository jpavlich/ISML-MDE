package co.edu.javeriana.isml.tests

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Assert

class TestHelper {
	@Inject extension ValidationTestHelper
	def void assertErrors(EObject obj) {
		Assert.assertTrue("Errors were expected in the test code, but there are none", !obj.validate.empty)
	}
}