package co.edu.javeriana.isml.validation

import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.isml.NamedElement
import co.edu.javeriana.isml.scoping.IsmlModelNavigation
import com.google.inject.Inject
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.validation.AbstractDeclarativeValidator
import org.eclipse.xtext.validation.CancelableDiagnostician
import org.eclipse.xtext.validation.Check

class NamesAreUniqueValidator extends AbstractDeclarativeValidator {
	@Inject
	var resourceServiceProviderRegistry = IResourceServiceProvider.Registry.INSTANCE;

	@Inject extension IsmlModelNavigation
	@Inject extension IQualifiedNameProvider
	@Inject extension SignatureExtension

	@Check
	def checkUniqueNamesInResourceOf(InformationSystem is) {
		if(context.containsKey(is.eResource)) {
			return;
		}
		context.put(is.eResource, this)
//		println("Checking unique names")
		val cancelIndicator = context.get(CancelableDiagnostician.CANCEL_INDICATOR) as CancelIndicator;
		val qualifiedNameIndex = new HashMap<String, EObject> // tracks duplicate EObjects
		// Adds named elements to qualifiedNameIndex
		for (obj : is.getDuplicatableNamedElements) {
			try {
				val signature = obj.signature
				qualifiedNameIndex.put(signature, obj)

			} catch(Throwable t) {
				t.printStackTrace
			}
		}
		val allInstances = is.eResource.resourceSet.allContents.filter(InformationSystem).toIterable
		for (infSys : allInstances) {
			val duplicatableNamedElements = infSys.getDuplicatableNamedElements
			for (obj : duplicatableNamedElements) {
				if (obj == null) {
					println(obj);
				}
				val signature = obj.signature
				val duplicate = qualifiedNameIndex.get(signature)
				if(qualifiedNameIndex.containsKey(signature) && obj != duplicate) {
//					println("error " + signature)
					error("Duplicate element " + signature, duplicate, duplicate.eClass.getEStructuralFeature("name"))
				}
				if(cancelIndicator != null && cancelIndicator.isCanceled())
					return;
			}
		}
	}

	/**
	 * Retrieves all NamedElements within an InformationSystem with non null name and that are not Packages or Generic Types
	 */
	def getDuplicatableNamedElements(InformationSystem is) {
		// Packages are not tracked, since they can be duplicated, i.e., two isml files may have the same declared pacakge
		// same with generic types
		is.eAllContents.toIterable.filter(NamedElement).filter[x|x.name != null && !x.isPackage && !x.isGenericType]
	}

	override def List<EPackage> getEPackages() {
		val result = new ArrayList<EPackage>();
		result.add(EPackage.Registry.INSTANCE.getEPackage("http://www.javeriana.edu.co/isml/Isml"));
		return result;
	}
}
