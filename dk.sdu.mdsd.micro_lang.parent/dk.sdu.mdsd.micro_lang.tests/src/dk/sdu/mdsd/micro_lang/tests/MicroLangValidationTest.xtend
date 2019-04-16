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
	
	val epackage = MicroLangPackage.eINSTANCE
	
	@Test
	def testMicroserviceUsesSelf() {
		val model = '''
			microservice TEST_SERVICE @ "localhost":5000
				uses TEST_SERVICE
		'''.parse
		model.assertError(epackage.uses, MicroLangValidator.USES_SELF)
	}
	
	@Test
	def testCycleSelfInTemplates() {
		val model = '''
			template A
				implements A
				/path
					GET
		'''.parse
		model.assertError(epackage.implements, MicroLangValidator.IMPLEMENT_CYCLE)
	}
	
	@Test
	def testCycleSelfAndOtherInTemplates() {
		val model = '''
			template A
				implements A
				/path
					GET
			template B
				implements A
				/path
					POST
		'''.parse
		model.assertError(epackage.implements, MicroLangValidator.IMPLEMENT_CYCLE)
	}
	
	@Test
	def testCycleOtherInTemplates() {
		val model = '''
			template A
				implements B
				/path
					GET
			template B
				implements A
				/path
					POST
		'''.parse
		model.assertError(epackage.implements, MicroLangValidator.IMPLEMENT_CYCLE)
	}
	
	@Test
	def testUnreachableCode() {
		val model = '''
			microservice TEST_SERVICE @ "localhost":5000
				/path
					GET
						return int
						string username
		'''.parse
		model.assertError(epackage.statement, MicroLangValidator.UNREACHABLE_CODE)
	}
	
	@Test
	def testInvalidAmountArgs() {
		val model = '''
			template TEMP(a, b)
				/{a}
					GET
						return {b}
			microservice TEST_SERVICE @ "localhost":5000
				implements TEMP(a)
				/path
					GET
						return int
		'''.parse
		model.assertError(epackage.implements, MicroLangValidator.INVALID_AMOUNT_ARGS)
	}
	
	@Test
	def testParameterNotUsed() {
		val model = '''
			template TEST_TEMPLATE(param)
		'''.parse
		model.assertWarning(epackage.parameter, MicroLangValidator.PARAMETER_NOT_USED)
	}
	
	@Test
	def testMicroserviceNameLowerCase() {
		val model = '''
			microservice testService @ "localhost":5000
		'''.parse
		model.assertWarning(epackage.microservice, MicroLangValidator.INVALID_MICROSERVICE_NAME)
	}
	
	@Test
	def testEndpointPathUpperCase() {
		val model = '''
			microservice TEST_SERVICE @ "localhost":5000
				/LOgiN
					GET
		'''.parse
		model.assertWarning(epackage.pathPart, MicroLangValidator.INVALID_ENDPOINT_PATH_NAME)
	}
	
}