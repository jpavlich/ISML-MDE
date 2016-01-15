package co.edu.javeriana.isml.generator.simple.tests;

import co.edu.javeriana.isml.IsmlInjectorProvider;
import co.edu.javeriana.isml.generator.test.TestGeneratorHelper;
import co.edu.javeriana.isml.isml.InformationSystem;
import co.edu.javeriana.isml.scoping.IsmlModelNavigation;
import co.edu.javeriana.isml.tests.CommonTests;
import com.google.inject.Inject;
import org.eclipse.xtext.junit4.InjectWith;
import org.eclipse.xtext.junit4.XtextRunner;
import org.eclipse.xtext.junit4.util.ParseHelper;
import org.eclipse.xtext.junit4.validation.ValidationTestHelper;
import org.eclipse.xtext.xbase.lib.Extension;
import org.junit.Test;
import org.junit.runner.RunWith;

@InjectWith(IsmlInjectorProvider.class)
@RunWith(XtextRunner.class)
@SuppressWarnings("all")
public class EntityGeneratorTest extends CommonTests {
  @Inject
  @Extension
  private ParseHelper<InformationSystem> _parseHelper;
  
  @Inject
  @Extension
  private ValidationTestHelper _validationTestHelper;
  
  @Inject
  @Extension
  private TestGeneratorHelper _testGeneratorHelper;
  
  @Inject
  @Extension
  private IsmlModelNavigation _ismlModelNavigation;
  
  @Inject
  private /* EntityTemplate */Object template;
  
  @Test
  public Object entityGeneration() {
    throw new Error("Unresolved compilation problems:"
      + "\nassertGenerates cannot be resolved");
  }
}
