package dk.sdu.mdsd.micro_lang.ui.tests

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith
import org.eclipse.xtext.ui.testing.AbstractContentAssistTest

@RunWith(XtextRunner)
@InjectWith(MicroLangUiInjectorProvider)
class MicroLangContentAssistTest extends AbstractContentAssistTest {

	@Test
	def void testVariableReference() {
//		newBuilder.append("var i = 10 eval 1+").
//			assertText('!', '"Value"', '(', '+', '1', 'false', 'i', 'true')
	}

}