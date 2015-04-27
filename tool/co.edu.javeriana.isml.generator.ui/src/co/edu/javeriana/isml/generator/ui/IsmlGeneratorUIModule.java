package co.edu.javeriana.isml.generator.ui;

import org.eclipse.jface.dialogs.IDialogSettings;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.builder.IXtextBuilderParticipant;
import org.eclipse.xtext.generator.IOutputConfigurationProvider;
import org.eclipse.xtext.service.AbstractGenericModule;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;
import org.eclipse.xtext.ui.resource.XtextResourceSetProvider;

import co.edu.javeriana.generator.EmptyOutputConfigurationProvider;
import co.edu.javeriana.generator.IsmlBuilderParticipant;

import com.google.inject.Binder;
import com.google.inject.Singleton;

public class IsmlGeneratorUIModule extends AbstractGenericModule {
	private AbstractUIPlugin plugin;

	public IsmlGeneratorUIModule(AbstractUIPlugin plugin) {
		this.plugin = plugin;
	}

	@Override
	public void configure(Binder binder) {
		super.configure(binder);
		binder.bind(AbstractUIPlugin.class).toInstance(plugin);
		binder.bind(IDialogSettings.class).toInstance(plugin.getDialogSettings());
		binder.bind(IOutputConfigurationProvider.class).to(EmptyOutputConfigurationProvider.class).in(Singleton.class);
	}

	public Class<? extends IXtextBuilderParticipant> bindIXtextBuilderParticipant() {
		return IsmlBuilderParticipant.class;
	}

}
