package co.edu.javeriana.isml.generator.common

import org.eclipse.emf.ecore.EObject

class DisableGeneration extends SimpleGenerator<EObject> {

	Class<? extends EObject> disabledClass
	
	new(Class<? extends EObject> c) {
		this.disabledClass = c
	}

	override protected getFileName(EObject e) {
		null
	}

	override protected getOutputConfigurationName() {
		null
	}

	override getTemplate() {
		null
	}

	override def boolean isActive() {
		return false
	}
	
	override Class<? extends EObject> getInputClass() {
		disabledClass
	}

}
