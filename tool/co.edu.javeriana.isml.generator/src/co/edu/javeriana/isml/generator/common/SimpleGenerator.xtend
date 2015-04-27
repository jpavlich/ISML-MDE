package co.edu.javeriana.isml.generator.common

import co.edu.javeriana.isml.generator.Activator
import java.lang.reflect.ParameterizedType
import java.lang.reflect.Type
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.generator.IFileSystemAccess

abstract class SimpleGenerator<T> {
	private var injector = Activator.injector

	private var GeneratorSuite generatorSuite

	extension SimpleTemplate<T> template;

	new() {
		template = getTemplate
		if(template != null) {
			injector.injectMembers(template)
		}
	}

	public def execute(T element, IFileSystemAccess fsa) {
		if(active) {
			val elementT = element as T
			fsa.generateFile(elementT.fileName, fullOutputConfigurationName, elementT.toText)
			System.err.println("Generated " + element.class.name + " with " + getClass().simpleName)
		}
	}

	protected def getFullOutputConfigurationName() {
		getGeneratorSuite.class.name + "." + outputConfigurationName
	}

	protected def boolean isActive() {
		return true
	}

	def Class<?> getInputClass() {
		return inputType.findClass
	}
	
	def Class<?> findClass(Type inputType) {
		switch (inputType) {
			Class<?>: return inputType
			ParameterizedType: return inputType.rawType.findClass
		}
	}

	def Type getInputType() {
		val superType = this.class.genericSuperclass as ParameterizedType
		return superType.actualTypeArguments.get(0)
	}

	def GeneratorSuite getGeneratorSuite() {
		generatorSuite
	}

	def setGeneratorSuite(GeneratorSuite gs) {
		generatorSuite = gs
	}

	// Abstract methods
	protected def String getFileName(T e)

	protected def String getOutputConfigurationName()

	def SimpleTemplate<T> getTemplate()

}
