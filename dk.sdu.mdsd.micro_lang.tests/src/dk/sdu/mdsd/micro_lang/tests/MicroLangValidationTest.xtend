package dk.sdu.mdsd.micro_lang.tests

import com.google.inject.Inject
import dk.sdu.mdsd.micro_lang.microLang.MicroLangPackage
import dk.sdu.mdsd.micro_lang.microLang.Model
import dk.sdu.mdsd.micro_lang.validation.MicroLangValidator
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

@ExtendWith(InjectionExtension)
@InjectWith(MicroLangInjectorProvider)
class MicroLangValidationTest {
	
	@Inject
	extension ParseHelper<Model>
	
	@Inject
	extension ValidationTestHelper
	
	@Test
	def testMicroserviceUsesItself() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000 {
				uses TEST_SERVICE
			}
		'''.parse
		model.assertError(MicroLangPackage.eINSTANCE.microservice, MicroLangValidator.USES_SELF)
	}
	
	@Test
	def testMicroserviceNameLowerCase() {
		val model = '''
			microservice testService @ localhost:5000 {
			}
		'''.parse
		model.assertWarning(MicroLangPackage.eINSTANCE.microservice, MicroLangValidator.INVALID_MICROSERVICE_NAME)
	}
	
	@Test
	def testEndpointPathUpperCase() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000 {
				GET /LOgiN
			}
		'''.parse
		model.assertWarning(MicroLangPackage.eINSTANCE.endpoint, MicroLangValidator.INVALID_ENDPOINT_PATH_NAME)
	}
	
}