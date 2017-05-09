package co.edu.javeriana.isml.tests

import com.google.inject.Inject
import java.util.ArrayList
import java.util.List
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipse.xtext.xbase.lib.Functions.Function1

import static org.junit.Assert.*

class TestHelper {
	@Inject extension ValidationTestHelper

	def void assertErrors(EObject obj) {
		assertTrue("Errors were expected in the test code, but there are none", !obj.validate.empty)
	}
	
	def void assertNoSyntaxErrors(EObject obj) {
		val errors = obj.validate
		val syntaxErrors = errors.filter[x | x.isSyntaxError]
		if (syntaxErrors.size > 0) {
			fail("Found syntax errors: " + syntaxErrors)			
		}
		
	}

	def <T extends EObject, R> Iterable<T> assertArrayEquals(Iterable<T> real, Iterable<R> expected, Function1<T, R> transformation) {
		assertArrayEquals(expected, real.map(transformation))
		return real;
	}

	def operator_mappedTo(Class<?> type, List<Pair<String, Object>> attributes) {
		return new Element(type, attributes)
	}

	def void assertEqualsElement(EObject obj, Element e) {
		assertTrue("Type " + e.type.name + " is not congruent with " + obj.class.simpleName, e.type.isAssignableFrom(obj.class))
		for (attr : e.attributes) {
			val feature = obj.eClass.getEStructuralFeature(attr.key)
			val value = obj.eGet(feature)
			switch (feature) {
				EAttribute:
					assertEquals("Feature " + obj.eClass.name + "." + feature.name + " is not equal to " + attr.value, value, attr.value)
				EReference:
					if(feature.upperBound == 1) {
						assertEqualsElement(value as EObject, attr.value as Element)
					} else if(feature.upperBound == -1) {
						val list = value as List<EObject>
						try {
							val elemList = attr.value as List<Element>
							elemList.forEach [ child, i |
								assertEqualsElement(list.get(i), child)
							]

						} catch(ClassCastException ex) {
							fail("Feature " + obj.eClass.name + "." + feature.name + " is a list, but is being compared against a single element")
						}
					}
			}

		}
	}

	static class Element {
		public Class<?> type = Object;
		public List<Pair<String, Object>> attributes = new ArrayList;

		public new(Class<?> type, List<Pair<String, Object>> attributes) {
			this.type = type
			this.attributes = attributes
			validateAttributes();
		}

		private def validateAttributes() {
			for (attr : attributes) {
				try {
					type.getMethod("get" + attr.key.toFirstUpper);
				} catch(NoSuchMethodException e) {
					fail("Class " + type.name + " does not have attribute " + attr.key);
				}
			}
		}

	}

}