package co.edu.javeriana.isml.generator.test

import co.edu.javeriana.isml.generator.common.SimpleTemplate
import org.eclipse.emf.ecore.EObject

import static org.junit.Assert.*

class TestGeneratorHelper {

	def <T extends EObject> void assertGenerates(SimpleTemplate<T> template, T input, CharSequence expectedOutput) {
		val inputText = template.toText(input).trimUnwantedChars
		val trimmedExpectedOutput = expectedOutput.trimUnwantedChars
		if (!inputText.equals(trimmedExpectedOutput)) {
			printCallingMethod()
			println("\nExpected output:\n\"" + trimmedExpectedOutput + "\"")
			println("Generated code: \n\"" + inputText + "\"")
			fail("Incorrect generated text. Expected: \n" + expectedOutput + "\n\nbut got:\n" + inputText)
		}
	}
	
	def printCallingMethod() {
		println(Thread.currentThread.stackTrace.get(2).methodName)
	}
	
	def trimUnwantedChars(CharSequence seq) {
		return String.valueOf(seq)
				.replaceAll("[,;|\\.]", "$0 ")
				.replaceAll("\\s+", " ")
				
	}
	
}