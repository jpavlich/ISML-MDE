package co.edu.javeriana.generator;

import co.edu.javeriana.generator.configuration.ConfigurationPersistence
import com.google.inject.Inject
import java.util.HashMap
import java.util.Map
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.xtext.builder.BuilderParticipant
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2
import org.eclipse.xtext.builder.IXtextBuilderParticipant
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.OutputConfiguration
import org.eclipse.xtext.resource.IContainer
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.IResourceDescription.Delta
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider

public class IsmlBuilderParticipant extends BuilderParticipant implements IXtextBuilderParticipant {
	protected ThreadLocal<Boolean> buildSemaphor = new ThreadLocal<Boolean>();

	@Inject
	private ResourceDescriptionsProvider resourceDescriptionsProvider;

	@Inject
	private IContainer.Manager containerManager;

	@Inject
	IMultiModelGenerator multiGenerator;

	protected override Map<String, OutputConfiguration> getOutputConfigurations(IBuildContext context) {
		return ConfigurationPersistence.loadOutputConfigurations(context)

	}

	override build(IBuildContext context, IProgressMonitor monitor) throws CoreException {
		buildSemaphor.set(false);
		super.build(context, monitor);
	}

	override handleChangedContents(Delta delta, IBuildContext context, EclipseResourceFileSystemAccess2 fileSystemAccess) {
		if(!buildSemaphor.get() && generator != null) {
			invokeGenerator(delta, context, fileSystemAccess);
		}
		super.handleChangedContents(delta, context, fileSystemAccess);
	}

	private def invokeGenerator(Delta delta, IBuildContext context, IFileSystemAccess fileSystemAccess) {
		buildSemaphor.set(true);
		var resource = context.getResourceSet().getResource(delta.getUri(), true);
		if(shouldGenerate(resource, context)) {
			var index = resourceDescriptionsProvider.createResourceDescriptions();
			var resDesc = index.getResourceDescription(resource.getURI());
			var visibleContainers = containerManager.getVisibleContainers(resDesc, index);
			for (IContainer c : visibleContainers) {
				for (IResourceDescription rd : c.getResourceDescriptions()) {
					context.getResourceSet().getResource(rd.getURI(), true);
				}
			}

			multiGenerator.doGenerate(context.getResourceSet(), fileSystemAccess);
		}
	}

}
