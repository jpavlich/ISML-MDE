package co.edu.javeriana.isml.tests

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.junit.Before

class CommonTests {
	protected var ResourceSet rs

	/**
	 * Loads primitive data types, constraints, widgets, and services
	 */
	@Before
	def void initCommon() {
		rs = new ResourceSetImpl
		rs.createResource(URI.createURI("../co.edu.javeriana.isml.common/model/common/primitives/Primitives.isml")).load(emptyMap)
		rs.createResource(URI.createURI("../co.edu.javeriana.isml.common/model/common/primitives/Constraints.isml")).load(emptyMap)
		rs.createResource(URI.createURI("../co.edu.javeriana.isml.common/view/common/widgets/PrimitiveWidgets.isml")).load(emptyMap)

		rs.createResource(URI.createURI("../co.edu.javeriana.isml.common/services/common/services/Persistence.isml")).load(emptyMap)

	}
	
}