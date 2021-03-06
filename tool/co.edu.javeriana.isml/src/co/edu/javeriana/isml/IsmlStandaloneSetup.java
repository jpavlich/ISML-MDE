/*
 * generated by Xtext
 */
package co.edu.javeriana.isml;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceFactory;
import org.eclipse.xtext.resource.XtextResourceSet;

import co.edu.javeriana.isml.isml.impl.IsmlPackageImpl;

import com.google.inject.Injector;

/**
 * Initialization support for running Xtext languages without equinox extension
 * registry
 */
public class IsmlStandaloneSetup extends IsmlStandaloneSetupGenerated {

	@Override
	public Injector createInjectorAndDoEMFRegistration() {
		IsmlPackageImpl.init(); // see
								// http://www.eclipse.org/forums/index.php/t/198335/
		org.eclipse.xtext.common.TerminalsStandaloneSetup.doSetup();

		Injector injector = createInjector();

//		Resource.Factory.Registry reg = Resource.Factory.Registry.INSTANCE;
//		Map<String, Object> m = reg.getExtensionToFactoryMap();
//		m.put("isml", injector.getInstance(XtextResourceFactory.class));
//
//		try {
//			XtextResourceSet resourceSet = injector.getInstance(XtextResourceSet.class);
//			resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, true);
//			String basePath = "/co.edu.javeriana.isml.common/model/";
//			loadResource(resourceSet, basePath + "common/constraints/Constraints.isml");
//			loadResource(resourceSet, basePath + "common/primitives/Primitives.isml");
//			loadResource(resourceSet, basePath + "common/widgets/PrimitiveWidgets.isml");
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
		register(injector);
		return injector;
	}

	public static void doSetup() {
		new IsmlStandaloneSetup().createInjectorAndDoEMFRegistration();

	}

	private void loadResource(XtextResourceSet resourceSet, String path) throws IOException, FileNotFoundException {

		Resource res = resourceSet.createResource(URI.createPlatformResourceURI(path, false));
		File f = new File("../" + path);
		 System.out.println(f.getAbsolutePath());
		res.load(new FileInputStream(f), new HashMap<Object, Object>());
	}
}
