/*
 * generated by Xtext 2.16.0
 */
package dk.sdu.mdsd.micro_lang.tests

import com.google.inject.Inject
import dk.sdu.mdsd.micro_lang.MicroLangModelUtil
import dk.sdu.mdsd.micro_lang.microLang.Model
import dk.sdu.mdsd.micro_lang.microLang.NormalPath
import dk.sdu.mdsd.micro_lang.microLang.ParameterPath
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static org.junit.Assert.assertNull
import static org.junit.Assert.assertTrue

import static extension org.junit.Assert.assertEquals
import static extension org.junit.Assert.assertSame

@ExtendWith(InjectionExtension)
@InjectWith(MicroLangInjectorProvider)
class MicroLangParsingTest {
	
	@Inject
	extension ParseHelper<Model>
	
	@Inject
	extension ValidationTestHelper
	
	@Inject
	extension MicroLangModelUtil
	
	//TODO: add tests for template
	
	@Test
	def testMicroserviceNoEndpoints() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000
		'''.parse
		model.assertNoErrors
		val microservice = model.microservices.head
		
		'TEST_SERVICE'.assertEquals(microservice.name)
		'localhost'.assertEquals(microservice.location.host)
		5000.assertEquals(microservice.location.port)
		assertTrue(microservice.endpoints.empty)
	}
	
	@Test
	def testEndpointNoParametersOrReturn() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000
				/login
					GET
		'''.parse
		model.assertNoErrors
		val microservice = model.microservices.head
		
		1.assertEquals(microservice.endpoints.size)
		
		val endpoint = microservice.endpoints.head
		
		'/login'.assertEquals(endpoint.path)
		
		val operation = endpoint.operations.head
		
		'GET'.assertEquals(operation.method.name)
		
		assertTrue(operation.parameters.empty)
		assertNull(operation.returnType)
	}
	
	@Test
	def testEndpointNoPath() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000
				/
					GET
		'''.parse
		model.assertNoErrors
		val microservice = model.microservices.head
		val endpoint = microservice.endpoints.head
		
		'/'.assertEquals(endpoint.path)
		
		val operation = endpoint.operations.head
		
		'GET'.assertEquals(operation.method.name)
		assertTrue(operation.parameters.empty)
		assertNull(operation.returnType)
	}
	
	@Test
	def testMicroserviceMultipleEndpoints() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000
				/login
					GET
				/user
					POST
				/user
					DELETE
		'''.parse
		model.assertNoErrors
		val microservice = model.microservices.head
		
		3.assertEquals(microservice.endpoints.size)
		
		val endpoints = microservice.endpoints
		
		'/login'.assertEquals(endpoints.get(0).path)
		'GET'.assertEquals(endpoints.get(0).operations.head.method.name)
		'/user'.assertEquals(endpoints.get(1).path)
		'POST'.assertEquals(endpoints.get(1).operations.head.method.name)
		'/user'.assertEquals(endpoints.get(2).path)
		'DELETE'.assertEquals(endpoints.get(2).operations.head.method.name)
	}
	
	@Test
	def testEndpointPathParameter() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000
				/login/{int userId}
					GET
		'''.parse
		model.assertNoErrors
		val microservice = model.microservices.head
		val endpoint = microservice.endpoints.head
		
		2.assertEquals(endpoint.pathParts.size)
		
		'login'.assertEquals((endpoint.pathParts.head as NormalPath).name)
		
		val parameterInPath = (endpoint.pathParts.last as ParameterPath).parameter
		
		'int'.assertEquals(parameterInPath.type.name)
		'userId'.assertEquals(parameterInPath.name)
		
		'GET'.assertEquals(endpoint.operations.head.method.name)
	}
	
	@Test
	def testEndpointParametersNoReturn() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000
				/login
					GET
						string username
						string password
		'''.parse
		model.assertNoErrors
		val microservice = model.microservices.head
		val operation = microservice.endpoints.head.operations.head
		
		2.assertEquals(operation.parameters.size)
		
		'string'.assertEquals(operation.parameters.head.type.name)
		'username'.assertEquals(operation.parameters.head.name)
		'string'.assertEquals(operation.parameters.last.type.name)
		'password'.assertEquals(operation.parameters.last.name)
		assertNull(operation.returnType)
	}
	
	@Test
	def testEndpointReturnTypeNoParameters() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000
				/login
					GET
						return bool
		'''.parse
		model.assertNoErrors
		val microservice = model.microservices.head
		val operation = microservice.endpoints.head.operations.head
		
		assertTrue(operation.parameters.empty)
		'bool'.assertEquals(operation.returnType.type.name)
	}
	
	@Test
	def testEndpointParametersAndReturnType() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000
				/average
					GET
						int numbers
						
						return double
		'''.parse
		model.assertNoErrors
		val microservice = model.microservices.head
		val operation = microservice.endpoints.head.operations.head
		
		2.assertEquals(operation.statements.size)
		1.assertEquals(operation.parameters.size)
		1.assertEquals(operation.returnTypes.size)
		
		'int'.assertEquals(operation.parameters.head.type.name)
		'numbers'.assertEquals(operation.parameters.head.name)
		'double'.assertEquals(operation.returnType.type.name)
	}
	
	@Test
	def testEndpointParametersAndReturnTypeAnyOrder() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000
				/average
					GET
						return int
						
						int numbers
						
						return double
						
						int number
		'''.parse
		val microservice = model.microservices.head
		val operation = microservice.endpoints.head.operations.head
		
		4.assertEquals(operation.statements.size)
		2.assertEquals(operation.parameters.size)
		2.assertEquals(operation.returnTypes.size)
		
		'int'.assertEquals(operation.returnTypes.head.type.name)
		'int'.assertEquals(operation.parameters.head.type.name)
		'numbers'.assertEquals(operation.parameters.head.name)
		'double'.assertEquals(operation.returnTypes.last.type.name)
		'int'.assertEquals(operation.parameters.last.type.name)
		'number'.assertEquals(operation.parameters.last.name)
	}
	
	@Test
	def testMultipleMicroservicesMultipleEndpoints() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000
				/average
					GET
						int numbers
						
						return double
				/{int id}/data
					POST
						string password
			
			microservice SECOND_SERVICE @ localhost:5001
				/login
					GET
				/user
					POST
						return bool
				/user
					DELETE
			
			microservice MOVIE_SERVICE @ localhost:5002
				/movies
					PUT
						string name
						string description
				/movies/{int id}
					DELETE
						return bool
		'''.parse
		model.assertNoErrors
		3.assertEquals(model.microservices.size)
		val firstMicroservice = model.microservices.get(0)
		val secondMicroservice = model.microservices.get(1)
		val thirdMicroservice = model.microservices.get(2)
		
		2.assertEquals(firstMicroservice.endpoints.size)
		3.assertEquals(secondMicroservice.endpoints.size)
		2.assertEquals(thirdMicroservice.endpoints.size)
	}
	
	@Test
	def testUsesOtherMicroservice() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000
			
			microservice SECOND_SERVICE @ localhost:5001
			
			microservice MOVIE_SERVICE @ localhost:5002
				uses TEST_SERVICE
				uses SECOND_SERVICE
		'''.parse
		model.assertNoErrors
		val microservices = model.microservices
		val uses = microservices.last.uses
		
		2.assertEquals(uses.size)
		microservices.get(0).assertSame(uses.get(0))
		microservices.get(1).assertSame(uses.get(1))
	}
	
	@Test
	def testUsesOtherMicroserviceAndEndpointsAnyOrder() {
		val model = '''
			microservice TEST_SERVICE @ localhost:5000
			
			microservice SECOND_SERVICE @ localhost:5001
			
			microservice MOVIE_SERVICE @ localhost:5002
				/login/{int id}
					GET
				uses TEST_SERVICE
				/user/test
					POST
						return bool
				uses SECOND_SERVICE
		'''.parse
		model.assertNoErrors
		val microservices = model.microservices
		val microservice = microservices.last
		val uses = microservice.uses
		
		4.assertEquals(microservice.declarations.size)
		2.assertEquals(microservice.endpoints.size)
		2.assertEquals(microservice.uses.size)
		
		'/login/{int}'.assertEquals(microservice.endpoints.head.path)
		microservices.get(0).assertSame(uses.get(0))
		'/user/test'.assertEquals(microservice.endpoints.last.path)
		microservices.get(1).assertSame(uses.get(1))
	}
	
}
