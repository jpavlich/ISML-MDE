ISML Syntax
===========

- [Basic Syntax](#basic-syntax)
- [Primitive Data Types](#primitive-data-types)
- [Collections](#collections)
- [Complex Data Types](#comples-data-types)
    + [Entities](#entities)
    + [Pages](#pages)
        * [Widgets](#widgets)
    + [Controllers](#controllers)
    + [Services](#services)
- [Other Constructs](#other-constructs)


# Basic Syntax

ISML's syntax is heavily inspired in Java. Blocks are represented with curly brackets `{ }` and lines of code are separated by semicolons `;`.

The rest of this document assumes that the reader has some basic knowledge of Java or a language with similar syntax.

ISML models are stored in several files with the extension `.isml`. Each file begins with a package declaration, followed by the elements declared within that package. The following is an example of an ISML file that contains an entity:

```
package com.example.entities;

entity Person {
    String name;
    Data dob;
    Integer taxID;
}
```

The following sections provide more details about the above syntax.

# Primitive Data Types
Primitive types are very similar to Java. ISML provides the following data types:

- `Integer`
- `String`
- `Float`
- `Double`
- `Date`
- `Boolean`
- `Any`
- `Null`
- `Void`

__TODO: Document primitives__

# Collections
ISML provides the following collection data types:

- `Array`: An array of elements that can be accessed by their index in the array
- `Set`: A collection of unique elements, where the position in the collection is not relevant

# Complex Data Types

ISML is based on the [Model-View-Controller (MVC) pattern][MVC]. This pattern provides three components for applications: __models__ that represent the underlying information the system manages, __views__ that display this information to users, and __controllers__ that determine the way users interact with views and models.

ISML specifies __models__ with the keyword `entity`, __views__ with the keyword `page`, and __controllers__ with the keyword `controller`.

In addition, ISML provides __services__ to denote elements in the system that provide an interface with operations that can be invoked from __controllers__. __Services__ are denoted with the keyword `service`.

## Entities

An entity in ISML denotes a persistent data structure in the system. It is very similar to a class. An __entity__ can have attributes and inherit from other entities, but it does not support methods or visibility labels.

The following is an example of an entity:

```
entity Person {
    String name;
    Date dob;
    Integer taxID;
}
```

All entities begin with the keyword `entity`

An entity can also inherit attributes from another entity:

```
entity Employee extends Person {

}
```

Associations between entities are represented with the keyword `opposite`. The keyword `opposite` indicates the name of the attribute in the opposite class that is part of the association.

```
entity Company {
    String name;
    Integer taxID;
    Array<Employee> employees opposite company;
}
```

In this example, `Company` has an association with `Employee`. One end of the association is the attribute `employees` of `Company`. The other end of the association is the attribute `company` of `Employee`, which is necessary to add to the `Employee` entity:

```
entity Employee {
    Company company;
}
```

## Pages

Pages describe the way to visualize information from entities. Pages receive entities as arguments and specify several widgets to visualize the entities attributes.

The following is an example of a page:

```
page ViewCompany(Company company) controlledBy CompanyManager {
    Panel("Company") {
        Label("Name") 
        Label(company.name);
        Label("Tax ID") 
        Label(company.taxID);

        Button("Ok", false) -> listAll();
    }
}
```

Each page is declared through the `page` keyword. A page receives one or more entities as arguments (in this example, `ViewCompany` receives an instance of `Company` as argument). The keyword `controlledBy` indicates the [controller](#controller) that will manage the events of the `ViewCompany` page (in this case it is the `CompanyManager` controller). 

The main body of the page is declared within curly brackets `{ }` and contains all the widgets that will depict the entity attributes. In the example above, the name and tax ID of the company are represented as a `Label` widget.

Some widgets can trigger controller actions. Action triggering is denoted with the `->` operator. In this example, when the `Button` widget is clicked, it triggers the the action `listAll` contained in the `CompanyManager` controller.

### Widgets
Widget support varies from one code generator to another. The widgets provided by ISML are the following

- `Button`
- `Label`
- `Image`
- `Link`
- `Text`
- `OutputText`
- `Password`
- `CheckBox`
- `ListChooser`
- `ComboChooser`
- `RadioChooser`
- `Spinner`
- `PickList`
- `Calendar`
- `GMap`
- `Menu`

__TODO: Document widgets__

## Controllers
Controllers specify the actions a user can perform over a system and the pages that will be shown after each action is executed. The following is an example of a controller:

```
controller CompanyManager {
    has Persistence<Company> persistence;
    
    /**
    * Lists all instances of Company.
    */
    listAll() {
        Array<Company> allCompanies = persistence.findAll();
        show CompanyList(allCompanies);
    }

    /**
    * Saves an instance of Company.
    * @param company the Company to save.
    */          
    saveCompany(Company company) {
        if(persistence.isPersistent(company)){
            persistence.save(company);
        } else {
            persistence.create(company);
        }
        -> listAll()
    }
}
```

Controllers are denoted with the keyword `controller` and have two main components: __declared services__ and __actions__.

__Declared services__ are all of the [services](#services) to which the controller has access. Declared services begin with the keyword `has`. In the example above, `CompanyManager` has access to the `Persistence` service.

__Actions__ are represented as an identifier followed by parenthesis and curly brackets. In this example there two actions: `listAll` and `saveCompany`.

An __action__ is similar to a class method in an object oriented language. An action receives parameters and has a body with a sequence of commands. However, an Action does not has a return type, because it never returns in the way as a regular method or function does. Instead, the action execution may end in two ways:

1. By showing a `page`
2. By calling another action

The first case is depicted the `listAll` action. The line

```
show CompanyList(allCompanies);
```

Ends the execution of `listAll` and displays the page `CompanyList` to the user.

The second case is depicted in the `saveCompany` action. The line 
```
-> listAll()
```

Means that the execution flow continues at the `listAll` action.

## Services
Services are interfaces with sets of methods that can be called from controllers. Structurally they are very similar to Java classes or interfaces. Conceptually they represent existing or new services provided by the system.

The following is an example of a service:

```
service Persistence <T> {
    native Void create(T obj);
    native Array<T> findAll();
    native Void save(T obj);
}
```

A service is declared with the keyword `service`, followed by the service name and (optionally), a list of generic parameters. The service body contains method declarations utilizing a syntax very similar to Java.

In the example above, each method is preceded by the keywork `native`. This means that the method is no implemented in ISML, but in the target language of the code generation. __Although the ISML interpreter supports the explicit definition of method bodies (instead of declaring them as `native`), this feature is not yet supported in the code generators.__

# Other Constructs

__TODO: Complete this section__
[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller