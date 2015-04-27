package co.edu.javeriana.isml.generator.crud

import co.edu.javeriana.generator.OnDemandGeneratorHandler
import co.edu.javeriana.isml.generator.crud.CRUDGenerator

class CRUDGeneratorHandler extends OnDemandGeneratorHandler {
	
	override getGeneratorClass() {
		CRUDGenerator
	}
	
}