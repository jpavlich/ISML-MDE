package co.edu.javeriana.generator;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.xtext.generator.IOutputConfigurationProvider;
import org.eclipse.xtext.generator.OutputConfiguration;

public class EmptyOutputConfigurationProvider implements IOutputConfigurationProvider {


	public Set<OutputConfiguration> getOutputConfigurations() {
		return new HashSet<OutputConfiguration>();
		
	}

}
