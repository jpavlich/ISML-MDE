package co.edu.javeriana.isml.generator;

import org.eclipse.xtext.ui.shared.SharedStateModule;
import org.eclipse.xtext.util.Modules2;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

import co.edu.javeriana.isml.IsmlRuntimeModule;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class Activator implements BundleActivator {

	private static BundleContext context;

	private static Activator INSTANCE;

	private static Injector injector;

	static BundleContext getContext() {
		return context;
	}

	public static Activator getINSTANCE() {
		return INSTANCE;
	}

	public static Injector getInjector() {
		if (injector == null) {
			createInjector();
		}
		return injector;
	}

	private static void createInjector() {
		injector = Guice.createInjector(Modules2.mixin(new IsmlRuntimeModule(), new SharedStateModule()));
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.osgi.framework.BundleActivator#start(org.osgi.framework.BundleContext
	 * )
	 */
	public void start(BundleContext bundleContext) throws Exception {
		Activator.context = bundleContext;
		INSTANCE = this;
		createInjector();
	}


	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.osgi.framework.BundleActivator#stop(org.osgi.framework.BundleContext)
	 */
	public void stop(BundleContext bundleContext) throws Exception {
		Activator.context = null;
	}

}
