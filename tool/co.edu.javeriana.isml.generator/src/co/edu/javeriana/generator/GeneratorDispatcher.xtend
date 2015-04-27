package co.edu.javeriana.generator

import co.edu.javeriana.generator.configuration.ConfigurationPersistence
import co.edu.javeriana.generator.configuration.GeneratorSuiteConfiguration
import co.edu.javeriana.isml.generator.common.IGeneratorSuite
import org.eclipse.core.runtime.IConfigurationElement
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.emf.ecore.resource.ResourceSet

class GeneratorDispatcher implements IGenerator, IMultiModelGenerator {

	override doGenerate(Resource input, IFileSystemAccess fsa) {
		val configurations = ConfigurationPersistence.loadGeneratorConfiguration(input)
		if(configurations != null) {
			System.err.println("***** GENERATOR RUNNING ******")
			for (config : configurations.generatorSuiteConfigurations) {
				if(!config.onDemand) {
					val generatorSuite = ConfigurationPersistence.loadGeneratorSuite(config)
					if(generatorSuite == null) {
						System.err.println("Could not load generator " + config.generatorClass)
					} else {
						System.err.println("Using " + config.generatorClass + " to generate from " + input.URI)
						generatorSuite.doGenerate(input, fsa)
					}
				}
			}
		} else {
			System.err.println("No generator configuration file found for " + input.URI)
		}
	}

	override doGenerate(ResourceSet input, IFileSystemAccess fsa) {
		if(!input.resources.empty) {
			val configurations = ConfigurationPersistence.loadGeneratorConfiguration(input.resources.get(0))
			if(configurations != null) {
				System.err.println("***** MULTIGENERATOR RUNNING ******")
				for (config : configurations.generatorSuiteConfigurations) {
					if(!config.onDemand) {
						val generatorSuite = ConfigurationPersistence.loadGeneratorSuite(config)
						if(generatorSuite == null) {
							System.err.println("Could not load generator " + config.generatorClass)
						} else {
							System.err.println("Using " + config.generatorClass + " to generate from all input files")
							generatorSuite.doGenerate(input, fsa)
						}
					}
				}
			} else {
				System.err.println("No generator configuration file found for " + input.resources.get(0).URI)
			}
		}
	}

}
