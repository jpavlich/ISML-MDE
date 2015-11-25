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
		val uri = URI.createURI(basePath + "ISML-MDE/tool/co.edu.javeriana.isml.common/model/common/primitives/Primitives.isml".translatePath)
		val resource = rs.createResource(uri)
		(resource).load(emptyMap)
		rs.createResource(URI.createURI(basePath + "ISML-MDE/tool/co.edu.javeriana.isml.common/model/common/primitives/Constraints.isml".translatePath)).load(emptyMap)
		rs.createResource(URI.createURI(basePath + "ISML-MDE/tool/co.edu.javeriana.isml.common/view/common/widgets/PrimitiveWidgets.isml".translatePath)).load(emptyMap)

		rs.createResource(URI.createURI(basePath + "ISML-MDE/tool/co.edu.javeriana.isml.common/services/common/services/Persistence.isml".translatePath)).load(emptyMap)

	}
	
	
	// FIXME This depends that the projects are stored in a git repo.
	def getBasePath() {
		return "file:///"+ System.getProperty("user.home") + "/git/".translatePath
	}
	
	def String translatePath(String path) {
		val sep = System.getProperty("file.separator")
		return path.replace('/', sep)
	}
	
}