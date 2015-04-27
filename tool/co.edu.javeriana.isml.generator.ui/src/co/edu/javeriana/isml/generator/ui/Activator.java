package co.edu.javeriana.isml.generator.ui;

import org.apache.log4j.Logger;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.ui.shared.SharedStateModule;
import org.eclipse.xtext.util.Modules2;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

import co.edu.javeriana.generator.GeneratorDispatcherModule;
import co.edu.javeriana.isml.IsmlRuntimeModule;
import co.edu.javeriana.isml.ui.IsmlUiModule;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class Activator extends AbstractUIPlugin implements BundleActivator {
	private Injector injector;
	private static Activator INSTANCE;

	public Injector getInjector() {
		return injector;
	}

	@Override
	public void start(BundleContext context) throws Exception {
		super.start(context);
		INSTANCE = this;
		try {
			injector = Guice.createInjector(Modules2.mixin(
					new IsmlRuntimeModule(), 
					new SharedStateModule(),
					new IsmlUiModule(this), 
					new GeneratorDispatcherModule(), 
					new IsmlGeneratorUIModule(this)));
		} catch (Exception e) {
			Logger.getLogger(getClass()).error(e.getMessage(), e);
			throw e;
		}
	}

	@Override
	public void stop(BundleContext context) throws Exception {
		injector = null;
		super.stop(context);
	}

	public static Activator getInstance() {
		return INSTANCE;
	}

}
