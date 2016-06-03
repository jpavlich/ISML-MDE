package templateGenerator

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl
import org.eclipse.emf.ecore.EAttribute
import java.io.PrintWriter
import java.util.Set
import java.util.HashSet
import org.eclipse.emf.ecore.ENamedElement
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EClassifier

class TemplateGenerator {

	var PrintWriter mainWriter
	var Set<String> rootClasses
	var String basePackage

	String metamodelBasePackage

	def static void main(String[] args) {
		new TemplateGenerator().generate(
			"/home/jpavlich/git/ISML-MDE/tool/co.edu.javeriana.isml/model/Isml.ecore",
			"co.edu.javeriana.isml.generator.sample",
			"co.edu.javeriana.isml.generator",
			"Entity",
			"Controller",
			"Page",
			"Service",
			"Resource",
			"DTO"
		)
	}

	def registerFactories() {
		Resource.Factory.Registry.INSTANCE.extensionToFactoryMap.put("ecore", new EcoreResourceFactoryImpl);
	}

	def generate(String modelURI, String basePackage, String metamodelBasePackage, String... rootClasses) {
		registerFactories
		mainWriter = new PrintWriter("templates/common.xtend", "UTF-8")
		mainWriter.println(commonTemplateHeader)
		this.rootClasses = new HashSet<String>
		this.rootClasses.addAll(rootClasses)
		this.basePackage = basePackage
		this.metamodelBasePackage = metamodelBasePackage
		val rs = new ResourceSetImpl
		val resource = rs.getResource(URI.createURI(modelURI), true)
		for (obj : resource.allContents.toIterable) {
			process(obj)
		}
		mainWriter.println(commonTemplateFooter)
	}

	def template(EClass c) '''
		package «basePackage»
		import «metamodelBasePackage».*
		import com.google.inject.Inject
		import org.eclipse.xtext.naming.IQualifiedNameProvider
		
		public class «c.name»Template extends SimpleTemplate<«c.name»> {
			@Inject extension IQualifiedNameProvider
			
			override preprocess(«c.name» «c.name.toFirstLower») {
		
			}
		
			override CharSequence template(«c.name» obj) « "'''"»
				«c.name»: « "«" »«c.name.toFirstLower».name« "«" »
				«FOR f : c.EAllStructuralFeatures»
					«f.toText(c)»
				«ENDFOR»
			« "'''"»
		} 
	'''
	
	def commonTemplateHeader() '''
		package «basePackage»
		import «metamodelBasePackage».*
		import com.google.inject.Inject
		import org.eclipse.xtext.naming.IQualifiedNameProvider
		
		public class CommonTemplate 
			@Inject extension IQualifiedNameProvider
			
	'''
	
	def commonTemplateFooter() '''
		}
	'''

	def indent(int ind) {
		for (i : 0 ..< ind) {
			print(' ')
		}
	}

	def void process(EObject obj) {
		if (obj instanceof EClass) {
			if (!obj.abstract) {
				if (rootClasses.contains(obj.name)) {
					val writer = new PrintWriter(obj.name + "Template.xtend", "UTF-8")
					writer.println(template(obj))
				} else {
					mainWriter.println(obj.toText)
				}
			}
		}

	}

	def toText(EClass c) '''
	
		def dispatch toText(«c.name» «c.name.toFirstLower») « "'''"»
			«FOR f : c.EAllStructuralFeatures»
			«f.toText(c)»
			«ENDFOR»
		« "'''"»
	'''

	def dispatch toText(EReference r, EClass container) '''
		«IF r.many»
			«IF r.containment»
				« "«" »FOR «r.name.iteratorName» : «container.name.toFirstLower».«r.name»« "»" »
				« "«" »«r.name.iteratorName».toText« "»" »
				« "«" »ENDFOR« "»" »
			«ELSE»
				« "«" »FOR «r.name.iteratorName» : «container.name.toFirstLower».«r.name»« "»" »
				« "«" »«r.name.iteratorName».toSimpleText« "»" »
				« "«" »ENDFOR« "»" »
			«ENDIF»
		«ELSE»
			«IF r.containment»
				« "«" »«container.name.toFirstLower».«r.name».toText« "»" »
			«ELSE»
				« "«" »«container.name.toFirstLower».«r.name».toSimpleText« "»" »
			«ENDIF»
		«ENDIF»
	'''
	
	

	def dispatch toText(EAttribute a, EClass container) '''
		«a.name»: « "«" »«container.name.toFirstLower».name»«a.name»« "»" »
	'''


	def dispatch toText(EObject object, EClass container) ''''''
	
	def getClassifierName(EStructuralFeature f) {
		val c = f.eContainer as EClassifier
		return c.name
	}
	
	def getIteratorName(String s) {
		val lastChar = s.charAt(s.length-1)
		if (lastChar == 's' || lastChar == 'S') {
			return s.substring(0, s.length - 1)
		} else {
			return "element"
		}
	}
	

}
