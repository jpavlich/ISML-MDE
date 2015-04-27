package co.edu.javeriana.isml

import org.eclipse.xtext.linking.lazy.LazyLinker
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.diagnostics.IDiagnosticConsumer

class IsmlLinker extends LazyLinker {
	override def afterModelLinked(EObject obj, IDiagnosticConsumer diagnosticsConsumer) {
//		println("Linking " +  obj)
	}
}