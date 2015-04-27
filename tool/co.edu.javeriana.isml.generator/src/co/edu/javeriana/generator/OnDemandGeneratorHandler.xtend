package co.edu.javeriana.generator

import co.edu.javeriana.generator.configuration.ConfigurationPersistence
import co.edu.javeriana.isml.generator.Activator
import co.edu.javeriana.isml.generator.common.IGeneratorSuite
import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.ui.handlers.HandlerUtil
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2

abstract class OnDemandGeneratorHandler extends AbstractHandler {
	@Inject
	private Provider<EclipseResourceFileSystemAccess2> fileAccessProvider;

	@Inject
	Provider <ResourceSet> resourceSetProvider;

	new() {
		try {
			Activator.getInjector.injectMembers(this)

		} catch(Throwable t) {
			t.printStackTrace
		}
	}

	def Class<? extends IGeneratorSuite> getGeneratorClass()

	override execute(ExecutionEvent event) throws ExecutionException {
		try {
			System.err.println("starting on demand generator")
			val selection = HandlerUtil.getCurrentSelection(event);
			if(selection instanceof IStructuredSelection) {
				for (elem : selection.iterator.toIterable) {
					if(elem instanceof IFile) {
						val project = elem.getProject();

						val uri = URI.createPlatformResourceURI(elem.getFullPath().toString(), true);
						val rs = resourceSetProvider.get();
						val r = rs.getResource(uri, true);
						val fsa = fileAccessProvider.get()
						fsa.project = project
						fsa.outputConfigurations = ConfigurationPersistence.loadOutputConfigurations(r)
						fsa.monitor = new NullProgressMonitor;

						doGenerate(r, fsa);
					}
				}
			}

		} catch(Throwable t) {
			t.printStackTrace
		}
		return null

	}

	private def doGenerate(Resource input, EclipseResourceFileSystemAccess2 fsa) {
		System.err.println("***** ON DEMAND GENERATOR RUNNING ****** " + generatorClass)
		val generatorSuite = ConfigurationPersistence.loadGeneratorSuite(input, generatorClass)
		if(generatorSuite == null) {
			System.err.println("Could not load generator " + generatorClass)
		} else {
			System.err.println("Using " + generatorClass + " to generate from " + input.URI)
			
			generatorSuite.doGenerate(input, fsa)
		}
	}

}
