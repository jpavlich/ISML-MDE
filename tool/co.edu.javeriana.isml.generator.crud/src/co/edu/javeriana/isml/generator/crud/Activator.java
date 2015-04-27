package co.edu.javeriana.isml.generator.crud;

import org.apache.log4j.Logger;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.ui.shared.SharedStateModule;
import org.eclipse.xtext.util.Modules2;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

import co.edu.javeriana.generator.GeneratorDispatcherModule;
import co.edu.javeriana.isml.IsmlRuntimeModule;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class Activator extends AbstractUIPlugin implements BundleActivator {

	private static BundleContext context;

	private static Activator INSTANCE;

	private static Injector injector;

	static BundleContext getContext() {
		return context;
	}

	public static Activator getInstance() {
		return INSTANCE;
	}

	public Injector getInjector() {
		return injector;
	}

	public void start(BundleContext bundleContext) throws Exception {

		Activator.context = bundleContext;
		INSTANCE = this;
		try {
			injector = Guice.createInjector(Modules2.mixin(
					new IsmlRuntimeModule(), 
					new SharedStateModule(),
					new GeneratorDispatcherModule()));
		} catch (Exception e) {
			Logger.getLogger(getClass()).error(e.getMessage(), e);
			throw e;
		}
	}


	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.osgi.framework.BundleActivator#stop(org.osgi.framework.BundleContext)
	 */
	public void stop(BundleContext bundleContext) throws Exception {
		Activator.context = null;
		injector = null;
		super.stop(context);
	}

}