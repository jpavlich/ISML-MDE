package co.edu.javeriana.generator.configuration

import java.util.List
import org.eclipse.xtext.generator.OutputConfiguration

class GeneratorSuiteConfiguration {
	static class __OutputConfiguration extends OutputConfiguration {

		/** Default constructor. It is necessary to ensure Gson deserialization 
		 * properly initializes all of the OutputConfiguration fields 
		 */
		new() {
			super("")
		}

		new(String name) {
			super(name)
		}

		def setName(String name) {
			// Uses java.lang.reflect api to change name
			val nameField = this.class.superclass.getDeclaredField("name")
			nameField.setAccessible(true)
			nameField.set(this, name)
		}

	}

	private var String generatorClass
	private var boolean active
	private var boolean onDemand = false
	private var List<__OutputConfiguration> outputConfigurations

	def getGeneratorClass() {
		generatorClass
	}

	def isActive() {
		active
	}
	
	def isOnDemand() {
		onDemand
	}

	def getOutputConfigurations() {
		outputConfigurations
	}

}
