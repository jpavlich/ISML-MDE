package co.edu.javeriana.isml.generator.common

abstract class SimpleTemplate<T> implements Template<T> {
	var GeneratorSuite generatorSuite
	
	
	def GeneratorSuite getDispatcher() {
		generatorSuite
	}
	
	def setDispatcher(GeneratorSuite gs) {
		generatorSuite = gs
	}
	

	final override toText(T e) {
		preprocess(e)
		return template(e)
	}

	/**
	 * Gets a string that uniquely identifies this template among all of the 
	 * SimpleTemplate that belong to a composite template.
	 * In this case, the Id is obtained from the simple name of the class,
	 * removing the "Template" suffix (if exists).
	 */
	final override String getId() {
		var name = this.class.simpleName
		val suffixPos = name.lastIndexOf("Template")
		if (suffixPos != -1) {
			name = name.substring(0, suffixPos)
		}
		return name
	}
	
	// Overridable methods
	
	protected def CharSequence template(T e)

	override preprocess(T e) {
		
	}

}
