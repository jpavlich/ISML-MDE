/*
 * generated by Xtext
 */
package co.edu.javeriana.isml.formatting

import co.edu.javeriana.isml.services.IsmlGrammarAccess
import org.eclipse.xtext.GrammarUtil
import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter
import org.eclipse.xtext.formatting.impl.FormattingConfig

/**
 * This class contains custom formatting description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation.html#formatting
 * on how and when to use it 
 * 
 * Also see {@link org.eclipse.xtext.xtext.XtextFormattingTokenSerializer} as an example
 */
class IsmlFormatter extends AbstractDeclarativeFormatter {

	//	@Inject extension IsmlGrammarAccess
	override protected void configureFormatting(FormattingConfig c) {

		var grammar = getGrammarAccess() as IsmlGrammarAccess;
		c.setAutoLinewrap(120);

		for (pair : grammar.findKeywordPairs("{", "}")) {

			//			config.setSpace(" ").before(pair.getFirst());
			config.setIndentation(pair.getFirst(), pair.getSecond());
			config.setLinewrap(1).before(pair.getSecond());
		}

		c.setLinewrap(1, 2, 3).around(grammar.structInstanceRule)
		c.setLinewrap(1, 2, 3).around(grammar.namedViewBlockRule)
		c.setLinewrap(1, 2, 3).around(grammar.viewInstanceRule)
		c.setLinewrap(1, 2, 3).around(grammar.attributeRule)
		c.setLinewrap(1, 2, 3).around(grammar.variableRule)
		c.setLinewrap(1, 2, 3).around(grammar.forRule)
		c.setLinewrap(1, 2, 3).around(grammar.ifRule)
		c.setLinewrap(1, 2, 3).around(grammar.whileRule)
		c.setLinewrap(1, 2, 3).around(grammar.methodCallRule)
		c.setLinewrap(1, 2, 3).around(grammar.referenceStatementRule)
		c.setLinewrap(1, 2, 3).around(grammar.importRule)
		c.setLinewrap(1, 2, 3).around(grammar.entityRule)
		c.setLinewrap(1, 2, 3).around(grammar.controllerRule)
		c.setLinewrap(1, 2, 3).around(grammar.pageRule)
		c.setLinewrap(1, 2, 3).around(grammar.widgetRule)
		c.setLinewrap(1, 2, 3).around(grammar.primitiveRule)
		c.setLinewrap(1, 2, 3).around(grammar.resourceAssignmentRule)
		c.setLinewrap(1, 2, 3).around(grammar.constraintRule)
		c.setLinewrap(1, 2, 3).around(grammar.serviceRule)
		c.setLinewrap(1, 2, 3).around(grammar.actorRule)
		c.setLinewrap(1, 2, 3).around(grammar.ifViewRule)
		c.setLinewrap(1, 2, 3).around(grammar.viewStatementRule)
		c.setLinewrap(1, 2, 3).around(grammar.actionRule)
		c.setLinewrap(1, 2, 3).around(grammar.methodRule)
		c.setLinewrap(1, 2, 3).around(grammar.showRule)
		c.setLinewrap(1, 2, 3).around(grammar.resourceRule)
		c.setLinewrap(1, 2, 3).around(grammar.resourceBundleRule)

		c.setLinewrap(1, 2, 3).after(grammar.packageRule)

		c.setLinewrap(0, 1, 2).before(grammar.getSL_COMMENTRule());
		c.setLinewrap(0, 1, 2).before(grammar.getML_COMMENTRule());
		c.setLinewrap(0, 1, 1).after(grammar.getML_COMMENTRule());



		grammar.findKeywords('else').forEach[_|c.setSpace(" ").before(_)]
		grammar.findKeywords('before').forEach[_|c.setLinewrap(1, 2, 3).before(_)]
		grammar.findKeywords('after').forEach[_|c.setLinewrap(1, 2, 3).before(_)]
		grammar.findKeywords('resources').forEach[_|c.setLinewrap(1, 2, 3).before(_)]
		grammar.findKeywords('=').forEach[_|c.setSpace(" ").around(_)]

		for (comma : grammar.findKeywords(",")) {
			c.setNoSpace().before(comma);
		}

		for (dollar : grammar.findKeywords("$")) {
			c.setNoSpace().after(dollar);
		}

		for (dot : grammar.findKeywords(".")) {
			c.setNoSpace().before(dot);
			c.setNoSpace().after(dot);
		}

		for (dotdot : grammar.findKeywords("..")) {
			c.setNoSpace().before(dotdot);
			c.setNoSpace().after(dotdot);
		}

		for (bracket : grammar.findKeywords("[")) {
			c.setNoSpace().before(bracket);
			c.setNoSpace().after(bracket);
		}
		for (bracket : grammar.findKeywords("]")) {
			c.setNoSpace().before(bracket);
		}

		for (bracket : grammar.findKeywords("(")) {
			c.setNoSpace().before(bracket);
			c.setNoSpace().after(bracket);
		}
		for (bracket : grammar.findKeywords(")")) {
			c.setNoSpace().before(bracket);
		}
		for (wildcard : grammar.findKeywords(".*")) {
			c.setNoSpace().before(wildcard);
		}

	}
}
