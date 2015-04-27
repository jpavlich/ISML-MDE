package co.edu.javeriana.generator;

import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.service.AbstractGenericModule;

public class GeneratorDispatcherModule extends AbstractGenericModule {
	public Class<? extends IGenerator> bindIGenerator() {
        return GeneratorDispatcher.class;
    }
	
	public Class<? extends IMultiModelGenerator> bindIMultiModelGenerator() {
        return GeneratorDispatcher.class;
    }
}
