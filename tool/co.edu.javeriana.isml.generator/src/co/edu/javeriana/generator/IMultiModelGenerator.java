package co.edu.javeriana.generator;

import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IGenerator;

public interface IMultiModelGenerator extends IGenerator {
	public void doGenerate(ResourceSet input, IFileSystemAccess fsa);

}
