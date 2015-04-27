package co.edu.javeriana.isml

import org.eclipse.xtext.naming.IQualifiedNameConverter

class IsmlQualifiedNameConverter extends IQualifiedNameConverter.DefaultImpl {
	
	override def String getDelimiter	() {
		return ".";
	}

	
}
	