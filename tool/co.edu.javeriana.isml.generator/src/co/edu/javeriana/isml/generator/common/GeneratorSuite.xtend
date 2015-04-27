package co.edu.javeriana.isml.generator.common

import co.edu.javeriana.isml.generator.Activator
import com.google.common.collect.LinkedHashMultimap
import com.google.common.collect.Lists
import com.google.common.collect.Multimap
import java.lang.reflect.ParameterizedType
import java.util.ArrayList
import java.util.Collection
import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.generator.IFileSystemAccess

abstract class GeneratorSuite implements IGeneratorSuite {
	private var injector = Activator.injector

	private var Multimap<String, SimpleGenerator<?>> generatorsMap
	private var List<SimpleGenerator<?>> multiModelGenerators

	new() {
		init
	}

	def init() {
		val childrenList = generators
		generatorsMap = LinkedHashMultimap.create
		multiModelGenerators = new ArrayList

		for (generator : childrenList) {
			injector.injectMembers(generator)
			generator.setGeneratorSuite(this)
			val inputClass = generator.inputClass

			if(inputClass == ResourceSet) {
				// If the generator input type is a ResourceSet, it is
				// a multiModelGenerator
				multiModelGenerators.add(generator)
			} else if(EObject.isAssignableFrom(inputClass)) {
				// If the generator input type is an EObject, it is
				// a simple generator
				generatorsMap.put(inputClass.simpleName, generator)
			} else if(Collection.isAssignableFrom(inputClass)) {
				// If the generator input type is a Collection of elements, then 
				// this generator is a multiModelGenerator
				multiModelGenerators.add(generator)

			}
		}
	}

	override doGenerate(Resource resource, IFileSystemAccess fsa) {
		resource.allContents.forEach[_|_.generate(fsa)]
	}

	private def void generate(EObject element, IFileSystemAccess fsa) {
		val gens = element.generators
		gens.forEach[_|(_ as SimpleGenerator<EObject>).execute(element, fsa)]
	}

	override doGenerate(ResourceSet resourceSet, IFileSystemAccess fsa) {
		for (generator : multiModelGenerators) {
			val inputClass = generator.inputClass
			if(inputClass == ResourceSet) {

				// Invokes the generator, passing the entire ResourceSet as argument
				(generator as SimpleGenerator<ResourceSet>).execute(resourceSet, fsa)
			} else {
				if(Collection.isAssignableFrom(inputClass)) {

					// Retrieves the list of model elements that will be used as input to the generator
					val classToGenerate = (generator.inputType as ParameterizedType).actualTypeArguments.get(0) as Class<?>
					var itElementsToGenerate = (EcoreUtil.getAllContents(resourceSet, true).filter[_|classToGenerate.isAssignableFrom(_.class)])
					var elementsToGenerate = Lists.newArrayList(itElementsToGenerate)

					// Invokes the generator passing that list as argument
					(generator as SimpleGenerator<Collection<?>>).execute(elementsToGenerate, fsa)
				}
			}
		}
	}

	protected def disableGenerationFor(Class<? extends EObject> c) {
		new DisableGeneration(c)
	}

	/**
	 * Finds all of the Generators that can be applied to element. This includes
	 * generators explicitly defined for the element's class and also generators
	 * defined for any of the element's superclasses.
	 *  
	 */
	private def Collection<SimpleGenerator<?>> getGenerators(EObject element) {
		val c = element.eClass

		if(!c.name.equals("EObject")) {

			var generators = c.generators
			if(!generators.empty) {
				return generators
			}
			for (p : c.getEAllSuperTypes) {
				generators = p.generators
				if(!generators.empty) {
					return generators
				}
			}
		}
		return emptySet
	}

	/** Finds all of the generators for a given EClass
	 * 
	 */
	private def Collection<SimpleGenerator<?>> getGenerators(EClass c) {
		generatorsMap.get(c.name)
	}

	def Set<? extends SimpleGenerator<?>> getGenerators()

// FIXME Mejor hacer que todos sean SimpleGenerator, pero que los parámetros puedan ser:
// - EObject
// - ResourceSet
// - Collection<T extends EObject>
// En los dos últimos casos sería un multimodel generator. En el 3er caso obtendría automáticamente todas
// las instancias de T de todos los modelos en el ResourceSet
//	def Set<? extends SimpleGenerator<? extends EObject>> getMultiModelGenerators()
}
