package co.edu.javeriana.isml.generator.common

interface Template<T> {
	def void preprocess(T e)

	def CharSequence toText(T e)

	def String getId()
}
