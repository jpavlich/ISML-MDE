package co.edu.javeriana.generator.configuration

import co.edu.javeriana.isml.generator.common.IGeneratorSuite
import com.google.gson.GsonBuilder
import java.io.File
import java.io.FileInputStream
import java.io.InputStreamReader
import java.util.HashMap
import org.eclipse.core.runtime.IConfigurationElement
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.URIConverter
import org.eclipse.emf.ecore.resource.impl.ExtensibleURIConverterImpl
import org.eclipse.xtext.builder.IXtextBuilderParticipant.IBuildContext
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.OutputConfiguration

class ConfigurationPersistence {

	static val gson = new GsonBuilder().create

	private static URIConverter conv = new ExtensibleURIConverterImpl

	def static loadGeneratorConfiguration(IBuildContext context) {
		try {
			val project = context.getBuiltProject();
			val File propFile = project.getLocation().append("conf").append("generation.conf.json").toFile();
			val reader = new InputStreamReader(new FileInputStream(propFile))
			return gson.fromJson(reader, GeneratorSuitesConfiguration)
		} catch(Exception e) {
			return null
		}
	}

	def static loadGeneratorConfiguration(Resource resource) {
		try {
			val fileURI = resource.getURI.projectURI.appendSegment("conf").appendSegment("generation.conf.json")
			val stream = conv.createInputStream(fileURI)
			val reader = new InputStreamReader(stream)
			return gson.fromJson(reader, GeneratorSuitesConfiguration)

		} catch(Exception e) {
			return null
		}

	}

	def static loadOutputConfigurations(IBuildContext context) {
		loadOutputConfigurations(ConfigurationPersistence.loadGeneratorConfiguration(context))
	}

	def static loadOutputConfigurations(Resource resource) {
		loadOutputConfigurations(ConfigurationPersistence.loadGeneratorConfiguration(resource))
	}

	
	private def static loadOutputConfigurations(GeneratorSuitesConfiguration configurations) {
		val processedConfigurations = new HashMap<String, OutputConfiguration>;
		if(configurations != null) {
			for (config : configurations.generatorSuiteConfigurations) {
				for (oc : config.outputConfigurations) {
		
					// Appends generator suite class name to output configuration name
					oc.setName(config.generatorClass + "." + oc.name)
		
					processedConfigurations.put(oc.name, oc)
				}
			}
		
			// Adds a default output configuration
			val defaultOutputConfiguration = new OutputConfiguration(IFileSystemAccess.DEFAULT_OUTPUT)
			defaultOutputConfiguration.setOutputDirectory("./src-gen")
			processedConfigurations.put(IFileSystemAccess.DEFAULT_OUTPUT, defaultOutputConfiguration)
		
		}
		return processedConfigurations
	}

	static def IGeneratorSuite loadGeneratorSuite(Resource input, Class<? extends IGeneratorSuite> generatorSuiteClass) {
		val configurations = ConfigurationPersistence.loadGeneratorConfiguration(input)
		if(configurations != null) {
			for (config : configurations.generatorSuiteConfigurations) {
				if(config.onDemand && config.generatorClass.equals(generatorSuiteClass.name)) {
					return ConfigurationPersistence.loadGeneratorSuite(config)
				}
			}
		}
		return null
	}

	static def IGeneratorSuite loadGeneratorSuite(GeneratorSuiteConfiguration config) {
		val IConfigurationElement[] generatorSuites = Platform.getExtensionRegistry().getConfigurationElementsFor("co.edu.javeriana.isml.generator")

		for (confElem : generatorSuites) {
			val o = confElem.createExecutableExtension("class")
			if(o instanceof IGeneratorSuite) {
				if(o.class.name.equals(config.generatorClass)) {
					return o
				} 
			}
		}
		System.err.println("Could not find generator named " + config.generatorClass)
		return null
	}

	def static getProjectURI(URI uri) {
		if(uri.platformResource) {
			return URI.createPlatformResourceURI(uri.segment(1), false)
		}

		return null
	}

}
