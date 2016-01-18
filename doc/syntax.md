ISML Syntax
===========

- [Basic Syntax](#basic-syntax)
- [Primitive Data Types](#primitive-data-types)
- [Collections](#collections)
- [Entities](#entities)
- [Pages](#pages)
- [Controllers](#controllers)
- [Services](#services)
- [Other Constructs](#other-constructs)


# Basic Syntax

ISML's syntax is heavily inspired in Java. Blocks are represented with curly brackets `{ }` and lines of code are separated by semicolons `;`.

ISML models are stored in several files with the extension `.isml`. Each file begins with a package declaration, followed by the elements declared within that package. The following is an example of an ISML file that contains an entity:

```
package com.example.entities;

entity Person {
    String name;
    Data dob;
    Integer age;
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

# Collections
ISML provides the following collection data types:

- `Array`: An array of elements that can be accessed by their index in the array
- `Set`: A collection of unique elements, where the position in the collection is not relevant

# Complex Data Types

ISML is based on the [Model-View-Controller (MVC) pattern][MVC]. This pattern provides three components for applications: __models__ that represent the underlying information the system manages, __views__ that display this information to users, and __controllers__ that determine the way users interact with views and models.

ISML specifies __models__ with the keyword `entity`, __views__ with the keyword `page`, and __controllers__ with the keyword `controller`.

In addition, ISML provides __services__ to denote elements in the system that provide an interface with operations that can be invoked from __controllers__. __Services__ are denoted with the keyword `service`.

## Entities

An __entity__ in ISML denotes a persistent data structure in the system. It is very similar to a class. An __entity__ can have attributes and inherit from other entities, but it does not support methods or visibility labels.

The following is an example of an entity:

```
entity Person {
    String name;
    Date dob;
    Integer age;
}

```

All entities begin with the keyword `entity`

An entity can also inherit attributes from another entity:

```
entity Employee extends Person {

}
```

Associations between entities are represented with the keyword `opposite`

```
entity Company {
    String name;
    Array<E
}
```

## Pages

## Controllers

## Services

# Other Constructs

[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller