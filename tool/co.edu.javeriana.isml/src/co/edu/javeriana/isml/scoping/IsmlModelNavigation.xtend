package co.edu.javeriana.isml.scoping

import co.edu.javeriana.isml.isml.Action
import co.edu.javeriana.isml.isml.ActionCall
import co.edu.javeriana.isml.isml.Actor
import co.edu.javeriana.isml.isml.Assignment
import co.edu.javeriana.isml.isml.Attribute
import co.edu.javeriana.isml.isml.Caller
import co.edu.javeriana.isml.isml.CompositeElement
import co.edu.javeriana.isml.isml.CompositeMethodStatement
import co.edu.javeriana.isml.isml.CompositeTypeSpecification
import co.edu.javeriana.isml.isml.Controller
import co.edu.javeriana.isml.isml.Entity
import co.edu.javeriana.isml.isml.Expression
import co.edu.javeriana.isml.isml.Feature
import co.edu.javeriana.isml.isml.ForView
import co.edu.javeriana.isml.isml.Function
import co.edu.javeriana.isml.isml.GenericTypeSpecification
import co.edu.javeriana.isml.isml.InformationSystem
import co.edu.javeriana.isml.isml.Instance
import co.edu.javeriana.isml.isml.Interface
import co.edu.javeriana.isml.isml.LiteralValue
import co.edu.javeriana.isml.isml.Method
import co.edu.javeriana.isml.isml.MethodCall
import co.edu.javeriana.isml.isml.NamedElement
import co.edu.javeriana.isml.isml.NamedViewBlock
import co.edu.javeriana.isml.isml.Package
import co.edu.javeriana.isml.isml.Page
import co.edu.javeriana.isml.isml.Parameter
import co.edu.javeriana.isml.isml.ParameterizedType
import co.edu.javeriana.isml.isml.Primitive
import co.edu.javeriana.isml.isml.Reference
import co.edu.javeriana.isml.isml.Service
import co.edu.javeriana.isml.isml.Show
import co.edu.javeriana.isml.isml.Statement
import co.edu.javeriana.isml.isml.Struct
import co.edu.javeriana.isml.isml.Type
import co.edu.javeriana.isml.isml.TypeSpecification
import co.edu.javeriana.isml.isml.TypedElement
import co.edu.javeriana.isml.isml.Variable
import co.edu.javeriana.isml.isml.VariableReference
import co.edu.javeriana.isml.isml.View
import co.edu.javeriana.isml.isml.ViewInstance
import co.edu.javeriana.isml.isml.ViewStatement
import co.edu.javeriana.isml.validation.TypeChecker
import com.google.inject.Inject
import java.util.ArrayList
import java.util.Collection
import java.util.HashMap
import java.util.LinkedHashSet
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.mwe2.language.scoping.QualifiedNameProvider
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescriptions
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider
import org.eclipse.emf.ecore.EStructuralFeature

/**
 * Helper to navigate Isml models
 */
class IsmlModelNavigation {
	@Inject
	ResourceDescriptionsProvider resourceDescriptionsProvider;

	@Inject extension TypeChecker

	// @Inject
	// IContainer.Manager containerManager;
	@Inject extension QualifiedNameProvider

	def TypeSpecification getContainerTypeSpecification(Feature f) {
		val container = f.eContainer
		if (container instanceof TypeSpecification) {
			return container
		}
	}

	def TypeSpecification getContainerTypeSpecification(Caller c) {
		return c.containerType?.typeSpecification
	}

	def Type getContainerType(Caller c) {
		val container = c.eContainer
		if (container instanceof VariableReference) {
			val referenced = container.referencedElement
			return referenced.type
		}
	}

	def Iterable<Feature> getFeatures(TypeSpecification ts) {
		if (ts instanceof CompositeTypeSpecification<?>) {
			return ts.body.filter(Feature)
		} else {
			return emptyList
		}
	}

	def Iterable<Attribute> getAttributes(Struct c) {
		val body = c.body 
		return body?.filter(Attribute) 
	}

	def Iterable<Method> getMethods(Interface c) {
		return c.features?.filter(Method) 
	}

	def Iterable<Action> getActions(Controller c) {
		return c.body?.filter(Action) 
	}

	def Iterable<Attribute> getAllAttributes(TypeSpecification c) {
		val f = c.allFeatures
		return f?.filter(Attribute)
	}

	def Iterable<Method> getAllMethods(TypeSpecification c) {
		return c.allFeatures.filter(Method)
	}

	def Iterable<Action> getAllActions(TypeSpecification c) {
		return c.allFeatures.filter(Action)
	}

	def getEntity(Attribute attribute) {
		return attribute.eContainer as Entity
	}

	def getTypeSpecification(Type type) {
		return type.referencedElement
	}

	def setTypeSpecification(Type type, TypeSpecification ts) {
		type.referencedElement = ts
	}

	def <T extends EObject> T findByName(Iterable<T> elements, String name) {
		for (e : elements) {
			if (e instanceof NamedElement) {
				val ne = e as NamedElement
				if (name.equals(ne.name)) {
					return e
				}
			}
		}
		return null
	}

	def Method getMethod(MethodCall mc) {
		return mc.referencedElement as Method
	}

	def Action getAction(ActionCall ac) {
		return ac.referencedElement as Action
	}

	/**
	 * The "body" attribute of a view statement is no longer of type Block, but
	 * of type EList.
	 * Now the elements contained in a view statement must be accessed directly through the 
	 * "body" attribute.
	 */
	@Deprecated
	def Iterable<ViewStatement> parts(Object viewBlock) {
		throw new UnsupportedOperationException
	}

	// def dispatch Type getType(TypeSpecification c) {
	// val type = IsmlFactory.eINSTANCE.createType
	// type.setTypeSpecification(c)
	// return type
	// }
	//
	// def dispatch getType(TypedElement te) {
	// return te.type
	//
	// }
	//
	// def dispatch getType(NamedElement ne) {
	//
	// }
	def boolean instanceOf(Instance instance, Type type) {
		return instance.type.isSubtypeOf(type)
	}

	def dispatch boolean isSubtypeOf(ParameterizedType t1, ParameterizedType t2) {
		if (t1.typeSpecification.isSubtypeSpecificationOf(t2.typeSpecification)) {
			for (i : 0 ..< t1.typeParameters.size) {
				val typeParam1 = t1.typeParameters.get(i)
				val typeParam2 = t2.typeParameters.get(i)
				if (!typeParam1.isSubtypeOf(typeParam2)) {
					return false
				}
			}
			return true
		} else {
			return false
		}
	}

	def dispatch boolean isSubtypeOf(Type t1, Type t2) {
		if (EcoreUtil.equals(t1, t2)) {
			return true
		} else {
			for (superType : t1.typeSpecification.superTypes) {
				if (superType.isSubtypeOf(t2)) {
					return true
				}
			}
		}
		return false

	}

	def boolean isSubtypeSpecificationOf(TypeSpecification t1, TypeSpecification t2) {
		if (EcoreUtil.equals(t1, t2)) {
			return true
		} else {
			for (superType : t1.superTypeSpecifications) {
				if (superType.isSubtypeSpecificationOf(t2)) {
					return true
				}
			}
		}
		return false
	}

	def Iterable<TypeSpecification> getSuperTypeSpecifications(TypeSpecification typeSpec) {
		typeSpec.superTypes.map[_|_.typeSpecification]
	}

	// Get all features
	def dispatch Set<TypedElement> getAllFeatures(Controller c) {
		val features = new LinkedHashSet<TypedElement>
		features.addAll(c.allTypeSpecificationFeatures)
		c.unnamedServices.forEach[_|features.addAll(_.allFeatures)]

		return features
	}

	def dispatch Set<TypedElement> getAllFeatures(Primitive p) {
		emptySet
	}

	// def dispatch Set<TypedElement> getAllFeatures(Entity e) {
	// e.allTypeSpecificationFeatures
	// }
	//
	// def dispatch Set<TypedElement> getAllFeatures(View v) {
	// v.allTypeSpecificationFeatures
	// }
	//
	// def dispatch Set<TypedElement> getAllFeatures(Enum v) {
	// v.allTypeSpecificationFeatures
	// }
	//
	// def dispatch Set<TypedElement> getAllFeatures(Interface i) {
	// i.allTypeSpecificationFeatures
	// }
	def dispatch Set<TypedElement> getAllFeatures(CompositeTypeSpecification<?> ts) {
		ts.allTypeSpecificationFeatures
	}

	def dispatch Set<TypedElement> getAllFeatures(Type t) {
		t.typeSpecification.allFeatures
	}

	def Set<TypedElement> getAllTypeSpecificationFeatures(CompositeTypeSpecification<?> c) {
		val features = new LinkedHashSet<TypedElement>
		features.addAll(c.features)
		if (c instanceof TypeSpecification) {
			for (p : c.superTypes) {
				features.addAll(p.allFeatures)
			}
		}
		return features
	}

	@Deprecated
	def TypeSpecification getClassifier(Type type) {
		return type.typeSpecification
	}

	def Collection<Type> getParents(TypeSpecification typeSpec) {
		return typeSpec.superTypes
	}

	def dispatch View getView(ViewInstance obj) {
		return obj.type.typeSpecification as View
	}

	def dispatch View getView(Instance obj) {
		var container = obj.eContainer
		while (!(container instanceof View) || (container as View).controller == null) {
			container = container.eContainer
		}
		if (container != null && container instanceof View) {
			return container as View
		}
		return null
	}

	def <T extends EObject> Collection<T> getAllInstancesOfSameClass(T obj) {
		val resourceSet = obj.eResource().resourceSet
		val resourceDescriptions = resourceDescriptionsProvider.getResourceDescriptions(resourceSet);
		val instances = new LinkedHashSet<T>
		for (resourceDescription : resourceDescriptions.allResourceDescriptions) {
			val r = resourceSet.getResource(resourceDescription.getURI, true)
			for (o : r.allContents.filter(obj.class).toIterable) {
				if (o.eIsProxy) {
					val resolved = EcoreUtil2.resolve(o, obj.eResource.resourceSet) as T
					instances.add(resolved)
				} else {
					instances.add(o as T)
				}

			}

		}
		return instances
	}

	// def <T extends EObject> getAllInstances(Resource r, Class<T> c) {
	// val allContents = r.resourceSet.allContents
	// val controllers = (allContents.filter(c) as Iterator<T>).toList
	// return controllers
	// }
	def <T extends EObject> Collection<T> getAllInstances(ResourceSet resourceSet, Class<T> c) {

		val IResourceDescriptions resourceDescriptions = resourceDescriptionsProvider.
			getResourceDescriptions(resourceSet);

		val instances = new LinkedHashSet<T>

		for (resourceDescription : resourceDescriptions.allResourceDescriptions) {
			val res = resourceSet.getResource(resourceDescription.getURI, true)
			for (o : res.allContents.filter(c).toIterable) {
				if (o.eIsProxy) {
					val resolved = EcoreUtil2.resolve(o, resourceSet)
					instances.add(resolved as T)
				} else {
					instances.add(o)
				}

			}

		}
		return instances
	}

	def Iterable<IEObjectDescription> filterByClass(Iterable<IEObjectDescription> descriptions, Class<?> c) {
		return descriptions.filter [ _ |
			c.isInstance(_.getEObjectOrProxy)
		]
	}

	def View getContainerView(EObject vp) {
		var EObject current = vp
		while (current != null && !(current instanceof View)) {
			current = current.eContainer
		}
		return current as View
	}

	def Iterable<Feature> getServices(CompositeTypeSpecification<?> c) {
		return c.features.filter[_|_.type?.typeSpecification instanceof Service]
	}

	def Iterable<Feature> getServices(Reference r) {
		var EObject current = r.findAnyAncestor(Controller, View, Service)

		if (current instanceof View) {
			if (current.controller != null) {
				return current.controller.services
			}
		}
		if (current instanceof Controller) {
			return current.services
		}

		if (current instanceof Service) {
			return current.services
		}
		return emptySet
	}

	private def <T extends TypedElement> Iterable<T> filterUnnamed(Iterable<T> s) {
		return s.filter[_|_.name == null]
	}

	private def <T extends TypedElement> Iterable<T> filterNamed(Iterable<T> s) {
		return s.filter[_|_.name != null]
	}

	def Iterable<Service> getUnnamedServices(Reference r) {
		return r.services.filterUnnamed.map[_|_.type.typeSpecification].filter(Service)
	}

	def Iterable<Service> getUnnamedServices(Controller c) {
		return c.services.filterUnnamed.map[_|_.type.typeSpecification].filter(Service)
	}

	/** Finds ancestor of certain types. 
	 * @param obj the object from which ancestors are searched
	 * @param classes the classes of the ancestors that are going to be found
	 * @return the first ancestors that is instance of any class in classes
	 */
	def EObject findAnyAncestor(EObject obj, Class<? extends EObject>... classes) {
		var current = obj
		while (current != null) {
			for (c : classes) {
				if (c.isAssignableFrom(current.class)) {
					return current
				}
			}
			current = current.eContainer
		}
		return null

	}

	def <S extends EObject, T extends EObject> findAncestor(S obj, Class<T> c) {
		return obj.findAnyAncestor(c).cast(c)
	}

	def findContainingFeature(EObject object, EObject ancestor) {
		var current = object
		var EStructuralFeature currentFeature = null
		while (current != null && current != ancestor) {
			currentFeature = current.eContainingFeature
			current = current.eContainer
		}
		return currentFeature
	}

	/** Finds the ancestor whose parent is of certain types. 
	 * @param obj the object from which ancestors' child are searched
	 * @param classes the classes of the ancestors that are going to be found
	 * @return the child of the first ancestors that is instance of any class in classes
	 */
	def EObject findAncestorWithParentOfType(EObject obj, Class<? extends EObject>... classes) {
		var current = obj
		while (current != null) {
			val parent = current.eContainer
			if (parent != null) {
				for (c : classes) {
					if (c.isAssignableFrom(parent.class)) {
						return current
					}
				}
			}
			current = parent
		}
		return null
	}

	def EObject findDescendent(EObject obj, Class<? extends EObject>... classes) {
		for (child : obj.eAllContents.toIterable) {
			for (c : classes) {
				if (c.isAssignableFrom(child.class)) {
					return child
				}
			}
		}
		return null

	}

	def Collection<Method> getAllMethods(Interface i) {
		val methods = new LinkedHashSet<Method>
		methods.addAll(i.methods)
		for (superType : i.superTypes) {
			val typeSpecification = superType.typeSpecification
			if (typeSpecification instanceof Interface) {
				methods.addAll(typeSpecification.allMethods)
			}
		}
		return methods
	}

	def Collection<Method> getAllMethods(Controller c) {
		val methods = new LinkedHashSet<Method>
		c.unnamedServices.forEach(_|methods.addAll(_.allMethods))
		return methods
	}

	/**
	 * Obtiene el controlador que contiene a un elemento del modelo
	 */
	def Controller getContainerController(EObject e) {
		var current = e
		while (current != null && !(current instanceof Controller) && !(current instanceof Page)) {
			current = current.eContainer
		}
		if (current instanceof Page) {
			return current.controller
		} else if (current instanceof Controller) {
			return current
		} else {
			return null
		}
	}

	def Page getContainerPage(EObject e) {
		var current = e
		while (current != null && !(current instanceof Page)) {
			current = current.eContainer
		}

		return current as Page
	}

	def Attribute getProperty(Entity e, String propName) {
		for (p : e.attributes) {
			if (p.name.equals(propName)) {
				return p;
			}
		}
	}

	def Parameter getParameter(TypeSpecification t, String paramName) {
		for (p : t.parameters) {
			if (p.name.equals(paramName)) {
				return p;
			}
		}
	}

	def NamedViewBlock getTableBody(ViewInstance i) {
		return i.body.findByName("body") as NamedViewBlock
	}

	def NamedViewBlock getTableHeader(ViewInstance i) {
		return i.body.findByName("header") as NamedViewBlock
	}

	def <T extends NamedElement> findByName(EList<T> elements, String name) {
		elements.findFirst[_|_.name.equals(name)]
	}

	def ForView getForViewInBody(ViewInstance i) {
		return i.body.filter(ForView).head
	}

	def Expression getParameter(Instance i, String paramName) {
		var int pos = 0
		for (p : i.type.typeSpecification.parameters) {
			if (p.name.equals(paramName)) {
				return i.parameters.get(pos)
			}
			pos = pos + 1
		}
		return null
	}

	def Object getAttributeValue(EObject parent, String relativePath) {
		var pathElements = relativePath.split("\\.")
		var element = parent
		var i = 0
		while (i < pathElements.length - 1) {
			val attr = pathElements.get(i)
			var obj = element.getSimpleAttributeValue(attr)
			if (obj != null) {
				if (obj instanceof EObject) {
					element = obj as EObject
				}
			} else {
				return null
			}
			i = i + 1
		}
		return element.getSimpleAttributeValue(pathElements.get(i))
	}

	private def Object getSimpleAttributeValue(EObject element, String attr) {
		val feature = element.eClass.getEStructuralFeature(attr)
		if (feature != null) {
			var obj = element.eGet(feature)
			return obj
		} else {
			return null
		}
	}

	// def Value getParameterValue(Call c, String paramName) {
	// for (i : 0 ..< c.callee.parameters) {
	// if (p.name.equals(paramName)) {
	// return p;
	// }
	// }
	// }
	def setParametersValue(EList<Parameter> parameters, EList<Expression> parameterValues) {
		var EList<Expression> parametersValuesTmp = new BasicEList<Expression>();
		for (ex : parameterValues) {
			parametersValuesTmp.add(ex);
		}
		var EList<Parameter> parametersListReturn = new BasicEList<Parameter>();
		for (var int i = 0; i < parameters.size; i++) {
			var Parameter p = parameters.get(i);
			p.setValue(parametersValuesTmp.get(i));
			parametersListReturn.add(p);
		}
		return parametersListReturn;
	}

	def isCalledFromPage(ActionCall call) {
		return call.eContainer instanceof ViewInstance
	}

	/**Metodo que verifica si la entidad es una instancia de Entity*/
	def isParentEntity(EList<TypeSpecification> superTypes) {
		var boolean isEntity = false;
		for (c : superTypes) {
			if (c instanceof Entity) {
				isEntity = true;
			}
		}
		return isEntity;
	}

	/**Metodo que verifica si la entidad tiene padres
	 * @param entity: se refiere a la entidad
	 * @return isSon : si la entidad tiene padres 
	 * */
	def isSon(Entity entity) {
		var boolean isSon = false
		for (parent : entity.superTypes) {
			if (parent.typeSpecification instanceof Entity) {
				isSon = true
			}
		}
		return isSon
	}

	/**Metodo que verifica si en la lista de parametros existe 
	 * una instancia de Array definido en el lenguaje
	 * @param EList<Attribute>: lista de atributos
	 * @return isArrayPresent: si existe una instacia de Array
	 */
	def isArrayPresent(Iterable<Attribute> attributes) {
		for (a : attributes) {
			if (a.type.isCollection) {
				return true;
			}
		}
		return false;
	}

	def boolean isArray(Type t) {
		return "Array".equals(t.typeSpecification.name)
	}

	def isPackage(NamedElement elem) {
		elem instanceof Package
	}

	def isGenericType(EObject elem) {
		if (elem instanceof GenericTypeSpecification) {
			return true
		}
		if (elem instanceof Type) {
			return elem.typeSpecification instanceof GenericTypeSpecification
		}
		return false
	}

	/** Metodo que verifica si una entidad es padre 
	 * @param entity: parametro entidad
	 * @return isParent: retorna true si es una entidad padre
	 */
	def isParent(Entity entity) {
		var boolean isParent = false;
		var InformationSystem is = (entity.eContainer.eContainer as InformationSystem)
		var Set<Entity> allEntities = new LinkedHashSet
		allEntities.addAll(is.eResource.resourceSet.getAllInstances(Entity))
		allEntities.addAll(is.eResource.resourceSet.getAllInstances(Actor))

		for (anotherEntity : allEntities) {
			for (superType : anotherEntity.superTypes) {
				if (superType.typeSpecification.name.equals(entity.name)) {
					isParent = true
				}
			}
		}

		return isParent
	}

	def Entity getOppositeEntity(Attribute a) {
		val type = a.type
		findEntityTypeSpec(type)

	}

	def findEntityTypeSpec(Type type) {
		if (type.is(Entity)) {
			return type.typeSpecification as Entity
		} else if (type.isCollection) {
			val collectionType = type as ParameterizedType
			val containedTypeSpec = collectionType.typeParameters.get(0).typeSpecification
			if (containedTypeSpec instanceof Entity) {
				return containedTypeSpec
			}
		}
	}

	def boolean is(Type type, Class<? extends TypeSpecification> typeSpecClass) {
		return typeSpecClass.isAssignableFrom(type.typeSpecification.class)
	}

	def boolean getIsOppositeCollection(Attribute attribute) {
		val opposite = attribute.searchOpposite

		if (opposite != null) {
			return opposite.type.isCollection
		}
		return false
	}

	/**
	 * Método encargado de buscar el atributo opuesto de una relación, para el caso
	 * en el que el atributo no defina la sentencia <code><strong>opposite</strong></code>
	 * 
	 * @param a Es el atributo del cual se quiere saber el opuesto
	 * 
	 * @return El atributo opuesto de la relación
	 */
	def Attribute searchOpposite(Attribute a) {
		var Attribute opposite = null;
		if (a.type instanceof ParameterizedType) {
			for (feature : (a.type as ParameterizedType).typeParameters.get(0).typeSpecification.features) {
				if (feature instanceof Attribute) {
					if (feature.opposite != null && feature.opposite.name.equals(a.name)) {
						opposite = feature;
					}

				}
			}
		} else {
			for (feature : a.type.typeSpecification.features) {
				if (feature instanceof Attribute) {
					if (feature.opposite != null && feature.opposite.name.equals(a.name)) {
						opposite = feature;
					}

				}
			}
		}
		return opposite;
	}

	/**
	 * Este método obtiene los statements de tipo Show de un Block
	 */
	def getShowStatements(EObject statement) {
		return statement.eAllContents.filter(Show).toIterable
	}

	/**
	 * Este método obtiene las acciones que contienen acciones de tipo show invocadas en una página determinada
	 */
	def Iterable<Action> getShowActions(Page page) {

		// Obtiene la lista de todas las acciones referenciasdas por ViewInstances contenidas dentro del ViewBlock
		val showActions = new ArrayList<Action>
		val actions = page.eAllContents.filter(ViewInstance).filter[_|_.actionCall != null].map[_|_.actionCall.action].
			toIterable

		for (action : actions) {
			if (!action.eAllContents.filter(Show).empty) {
				showActions.add(action)
			}
		}

		return showActions
	}

	def EList<Page> getControlledPages(Controller controller) {
		var Set<Page> allPages
		var EList<Page> controlledPages = new BasicEList
		allPages = new LinkedHashSet
		allPages.addAll(
			(controller.eContainer.eContainer as InformationSystem).eResource.resourceSet.getAllInstances(Page))
		for (page : allPages) {
			if (page.controller != null) {
				if (page.controller.name.equals(controller.name)) {
					controlledPages.add(page)
				}
			}
		}
		return controlledPages
	}

	def String getCollectionString(Type type) {
		if (type.typeSpecification.name.equals("Array")) {
			return "List"
		} else {
			return type.typeSpecification.name
		}

	}

	def boolean evaluateCardinality(Attribute a) {
		var boolean flag = false
		if (a.type instanceof ParameterizedType) {
			flag = (a.type as ParameterizedType).typeParameters.get(0).typeSpecification instanceof Entity
		} else {
			flag = a.type.typeSpecification instanceof Entity
		}
		return flag
	}

	def CharSequence associationAnnotation(Attribute a) {
		if (a.evaluateCardinality) {
			if (a.type.isCollection) {
				if (a.opposite != null) {

					/*Se verifica el mapeo de la entidad
					 * para indicar atributo maestro
					 */
					if (a.opposite.type.isCollection) {
						return '''@ManyToMany(mappedBy = "«a.opposite.name»")'''
					} else {
						return '''@OneToMany(mappedBy = "«a.opposite.name»")'''
					}
				} else {
					val opposite = a.searchOpposite

					if (opposite != null)
						if (opposite.type.isCollection) {
							return '''@ManyToMany'''
						} else {
							return '''@OneToMany(mappedBy = "«a.searchOpposite.name»")'''
						}
				}
			} else {
				if (a.opposite != null) {
					if (a.opposite.type.isCollection) {
						return '''@ManyToOne'''
					} else {
						return '''@OneToOne(mappedBy="«a.opposite.name»")'''
					}
				} else {
					if (a.searchOpposite.type.isCollection) {
						return '''@ManyToOne'''
					} else {
						return '''@OneToOne'''
					}
				}
			}
		}

	}

	def String writeType(Type type, boolean complete) {
		var String typeString = ""

		if (!type.isCollection) {
			switch (type.typeSpecification.name) {
				case "Any": typeString = "Object"
				case "Type": typeString = type.classValue
				case "Void": typeString = "void"
				case "Null": typeString = "null"
				case "Integer": typeString = "Long"
				default: typeString = type.typeString
			}
		} else {
			typeString = getCollectionString(type)
			if (type instanceof ParameterizedType && complete == true) {
				if ((type as ParameterizedType).typeParameters.empty) {
					typeString += "<Object>"
				} else {
					typeString += "<" + (type as ParameterizedType).typeParameters.get(0).writeType(complete) + ">"
					if ((type as ParameterizedType).typeParameters.get(0).
						typeSpecification instanceof GenericTypeSpecification) {
						if (type.eContainer instanceof Function) {
							var ser = type.eContainer.findAnyAncestor(TypeSpecification) as TypeSpecification
							if (ser.genericTypeParameters.isEmpty) {
								typeString = "<" + (type as ParameterizedType).typeParameters.get(0).typeSpecification +
									">" + typeString
							}
						}
					}
				}
			} else {
				if (complete == true) {
					typeString += "<Object>"
				}
			}
		}

		return typeString;
	}

	def String getClassValue(Type type) {
		if (type instanceof Primitive) {
			if (type.genericTypeParameters.isEmpty) {
				return "Class<?>"
			} else {
				return "Class<T>"
			}
		}
	}

	def String getTypeString(Type t) {
		if (t.typeSpecification instanceof GenericTypeSpecification && !(t.eContainer instanceof ParameterizedType)) {
			var str = ""
			if (t.eContainer instanceof Function) {
				str = ""
				var ser = t.eContainer.findAnyAncestor(TypeSpecification) as TypeSpecification
				if (ser.genericTypeParameters.isEmpty) {
					str = "<" + t.typeSpecification.name + ">" + t.typeSpecification.name
				} else {
					str = t.typeSpecification.name
				}
			} else {
				str = t.typeSpecification.name
			}
			return str
		} else {
			return t.typeSpecification.name.toFirstUpper;
		}
	}

	// Methods to find attributes for controllers
	def Map<String, Object> getNeededAttributes(Controller controller) {
		var Map<String, Object> returnData = new HashMap
		var Map<String, Type> neededAttributes = new HashMap
		retrieveControllerEntity(controller, returnData)

		var EList<Page> controlledPages = getControlledPages(controller)
		for (page : controlledPages) {
			for (param : page.parameters) {
				if (!neededAttributes.containsKey(param.name)) {
					neededAttributes.put(param.name, param.type)
				}
			}
		}
		returnData.put("neededAttributes", neededAttributes)
		return returnData
	}

	def retrieveControllerEntity(Controller controller, Map<String, Object> returnData) {
		var EList<Entity> controllerEntities = new BasicEList
		var EList<Page> controlledPages = getControlledPages(controller)
		for (page : controlledPages) {
			for (param : page.parameters) {
				if (param.type?.typeSpecification instanceof Entity) {
					controllerEntities.add(param.type.typeSpecification as Entity)
				} else if (param.type instanceof ParameterizedType) {
					if ((param.type as ParameterizedType).typeParameters.get(0).typeSpecification instanceof Entity) {
						returnData.put("entityToList",
							(param.type as ParameterizedType).typeParameters.get(0).typeSpecification as Entity)
						returnData.put("selectedRegisters",(param.type as ParameterizedType))
					}
				}
			}
		}
		returnData.put("controllerEntities", controllerEntities);
	}

	// def Entry<String, Type> getArrayAttribute(){
	// var Entry<String, Type> arrayAttribute;
	//
	// for(attr:neededAttibutes.entrySet){
	// if(attr.value.isCollection){
	// arrayAttribute=attr;
	// }
	// }
	//
	// return arrayAttribute;
	// }
	def EList<Parameter> evaluateParameters(EList<Parameter> parameters, Map<String, Type> neededAttibutes) {
		var EList<Parameter> newList = new BasicEList
		for (param : parameters) {
			if (!neededAttibutes.containsKey(param.name)) {
				newList.add(param)
			}
		}
		return newList

	}

	def Map<QualifiedName, TypeSpecification> getNeededImportsInActions(Controller controller) {
		var Map<QualifiedName, TypeSpecification> imports = new HashMap
		for (action : controller.actions) {
			if (action.type != null &&
				!action.type.typeSpecification.eContainer.fullyQualifiedName.equals(
					controller.eContainer.fullyQualifiedName)) {
				if (!(action.type.typeSpecification instanceof Primitive)) {
					if (!imports.containsKey(action.type.typeSpecification.fullyQualifiedName)) {
						imports.put(action.type.typeSpecification.fullyQualifiedName, action.type.typeSpecification)
					}
				}
			}
			for (param : action.parameters) {
				if (!param.type.isCollection) {
					if (!param.type.typeSpecification.eContainer.fullyQualifiedName.equals(
						controller.eContainer.fullyQualifiedName)) {
						if (!(param.type.typeSpecification instanceof Primitive)) {
							if (!imports.containsKey(param.type.typeSpecification.fullyQualifiedName)) {
								imports.put(param.type.typeSpecification.fullyQualifiedName,
									param.type.typeSpecification)
							}
						}
					}
				} else {
					if (param.type instanceof ParameterizedType) {
						if (!(param.type as ParameterizedType).typeParameters.get(0).typeSpecification.eContainer.
							fullyQualifiedName.equals(controller.eContainer.fullyQualifiedName)) {
							if (!((param.type as ParameterizedType).typeParameters.get(0).
								typeSpecification instanceof Primitive)) {
								if (!imports.containsKey(
									(param.type as ParameterizedType).typeParameters.get(0).typeSpecification.
										fullyQualifiedName)) {
											imports.put(
												(param.type as ParameterizedType).typeParameters.get(0).
													typeSpecification.fullyQualifiedName,
												(param.type as ParameterizedType).typeParameters.get(0).
													typeSpecification as Entity)
										}
									}
								}
							}
						}
					}
					for (stmnt : action.body) {
						isNeededImportInBody(stmnt.eAllContents.toList, imports, controller)
					}
				}
				return imports
			}

			def void isNeededImportInBody(List<EObject> allContents, Map<QualifiedName, TypeSpecification> imports,
				TypeSpecification controller) {
				for (obj : allContents) {
					if ((obj instanceof TypedElement &&
						!((obj as TypedElement).type.typeSpecification instanceof Primitive))) {
						if (!(obj as TypedElement).type.typeSpecification.eContainer.fullyQualifiedName.equals(
							controller.eContainer.fullyQualifiedName)) {
							if (!imports.containsKey((obj as TypedElement).type.typeSpecification.fullyQualifiedName)) {
								imports.put((obj as TypedElement).type.typeSpecification.fullyQualifiedName,
									(obj as TypedElement).type.typeSpecification)
							}
						}
					} else if ((obj instanceof Reference &&
						(obj as Reference).referencedElement instanceof TypeSpecification &&
						!((obj as Reference).referencedElement instanceof Primitive))) {
						if (!((obj as Reference).referencedElement as TypeSpecification).eContainer.fullyQualifiedName.
							equals(controller.eContainer.fullyQualifiedName)) {
							if (!imports.containsKey(
								((obj as Reference).referencedElement as TypeSpecification).fullyQualifiedName)) {
								imports.put(((obj as Reference).referencedElement as TypeSpecification).eContainer.
									fullyQualifiedName, (obj as Reference).referencedElement as TypeSpecification)
							}

						}
					}
					isNeededImportInBody(obj.eAllContents.toList, imports, controller)
				}
			}

			def Controller getControllerIfExists(EObject actionCall) {
				var Controller c = null
				var EObject tmp = actionCall
				while (tmp != null && c == null) {
					if (tmp.eContainer != null && tmp.eContainer instanceof Controller) {
						c = tmp.eContainer as Controller
					}
					tmp = tmp.eContainer
				}
				return c
			}

			def EList<Expression> validateParameterForActionCall(ActionCall action) {
				var EList<Expression> finalList = new BasicEList
				var Controller c = getControllerIfExists(action.referencedElement)
				if (c != null) {
					var Map<String, Type> controllerAttributes = getNeededAttributes(c).get(
						"neededAttributes") as Map<String, Type>;
					for (parameter : action.parameters) {
						if (!(parameter instanceof VariableReference) ||
							(parameter instanceof VariableReference &&
								!controllerAttributes.containsKey(
									(parameter as VariableReference).referencedElement.name))) {
								finalList.add(parameter)
							}
						}
					}
					return finalList
				}

				def int getRows(ViewInstance viewInstance) {

					var rows = viewInstance.getParameter('rows')

					if (rows instanceof LiteralValue) {
						return rows.literal as Integer

					}

					return 0
				}

				def Type getTailType(Reference reference) {
					var Reference tmp = reference
					while (tmp.tail != null) {
						tmp = tmp.tail
					}
					return tmp.referencedElement.cast(TypedElement).type
				}

				def dispatch List<Object> evaluateToCast(Variable assignment) {
					var List<Object> returnData = new ArrayList
					var Boolean doCast = false
					var Type castTo = null
					if (assignment.value instanceof Reference) {
						var Reference value = assignment.value as Reference
						if (!getTailType(value).typeSpecification.name.equals(assignment.type.typeSpecification.name)) {
							doCast = true
							castTo = assignment.type
							returnData.add(doCast)
							returnData.add(castTo)
						}
					}
					return returnData
				}

				def dispatch List<Object> evaluateToCast(Assignment assignment) {
					var List<Object> returnData = new ArrayList
					var Boolean doCast = false
					var Type castTo = null
					if (assignment.right instanceof Reference && assignment.left instanceof Reference) {
						var Reference rightRef = assignment.right as Reference
						var Reference leftRef = assignment.left as Reference
						if (!getTailType(rightRef).typeSpecification.name.equals(
							getTailType(leftRef).typeSpecification.name)) {
							doCast = true
							castTo = getTailType(leftRef)
							returnData.add(doCast)
							returnData.add(castTo)
						}
					} else if (assignment.right instanceof Reference && assignment.left instanceof Variable) {
						var Reference rightRef = assignment.right as Reference
						var Variable leftRef = assignment.left as Variable
						if (!getTailType(rightRef).typeSpecification.name.equals(leftRef.type.typeSpecification.name)) {
							doCast = true
							castTo = leftRef.type
							returnData.add(doCast)
							returnData.add(castTo)
						}
					}
					return returnData
				}

				/**
				 * Este metodo obtiene recursivamente la acción a la cual pertenece un statement
				 */
				def Action getActionRecursivelly(EObject eContainer) {
					if (eContainer instanceof Action) {
						return eContainer
					} else {
						return getActionRecursivelly(eContainer.eContainer);
					}
				}

				def String getTypeSpecificationString(TypeSpecification specification) {
					if (specification instanceof Primitive && specification.name.equalsIgnoreCase("Integer")) {
						return "Long"
					} else if (specification instanceof Primitive &&
						specification.name.equalsIgnoreCase("BytesArray")) {
						return "byte[]"
					} else if (specification instanceof Primitive && specification.name.equalsIgnoreCase("Any")) {
						return "Object"
					} else {
						return specification.name
					}
				}

				def String getFullName(Type t) {
					var name = ""

					// if(t.typeSpecification instanceof GenericTypeSpecification && t.findAncestor(Parameter) != null) {
					// name += t.typeSpecification?.name
					// } else {
					name += t.typeSpecification?.fullyQualifiedName

					// }
					if (t instanceof ParameterizedType) {
						name += "<"
						for (typeParam : t.typeParameters) {
							name += typeParam.fullName
						}
						name += ">"
					}
					return name
				}

				def Type getReplacedType(TypeSpecification service, Type type) {
					if (type.typeSpecification instanceof GenericTypeSpecification) {
						if (service.genericTypeParameters.isEmpty) {
							if (service.superTypes.get(0).typeSpecification.genericTypeParameters.isEmpty) {
								return type
							} else {
								var i = 0
								for (param : service.superTypes.get(0).typeSpecification.genericTypeParameters) {
									if (param.name.equals(type.typeSpecification.name)) {
										if (service.superTypes.get(0) instanceof ParameterizedType) {
											if (!(service.superTypes.get(0) as ParameterizedType).typeParameters.
												isEmpty) {
												return (service.superTypes.get(0) as ParameterizedType).typeParameters.
													get(i)
											}
										}
									}
									i++
								}
								return type
							}
						}
					} else if (type.isCollection) {
						if (service.genericTypeParameters.isEmpty) {
							if (!service.superTypes.isEmpty) {
								if (service.superTypes.get(0).typeSpecification.genericTypeParameters.isEmpty) {
									return type
								} else {
									var i = 0
									for (param : service.superTypes.get(0).typeSpecification.genericTypeParameters) {
										if (param.name.equals(
											(type as ParameterizedType).typeParameters.get(0).typeSpecification.name)) {
											if (service.superTypes.get(0) instanceof ParameterizedType) {

												var typ = (type as ParameterizedType)
												if (!(service.superTypes.get(0) as ParameterizedType).typeParameters.
													isEmpty) {
													var EList<Type> l = new BasicEList
													l.addAll(
														(service.superTypes.get(0) as ParameterizedType).typeParameters)
													typ.typeParameters.get(i).typeSpecification = (service.superTypes.
														get(0) as ParameterizedType).typeParameters.get(i).
														typeSpecification
													return typ
												}
											}
										}
										i++
									}
									return type
								}
							}
						}
					}
					return type
				}

				def <S extends EObject, T extends S> cast(S obj, Class<T> c) {
					return obj as T
				}

				def getComponents(InformationSystem is) {
					return is.body
				}

				def getComponents(Package p) {
					return p.body
				}

				def isUniqueStatement(EObject obj) {
					val container = obj.eContainer
					val containingFeature = obj.eContainingFeature
					if (containingFeature.upperBound == 1) {
						return true
					} else {
						val list = container.eGet(containingFeature) as Collection<?>
						return list.size() == 1
					}
				}

			}
