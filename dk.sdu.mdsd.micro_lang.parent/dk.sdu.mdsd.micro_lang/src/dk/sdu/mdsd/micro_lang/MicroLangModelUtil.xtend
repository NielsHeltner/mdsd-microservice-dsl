package dk.sdu.mdsd.micro_lang

import dk.sdu.mdsd.micro_lang.microLang.Endpoint
import dk.sdu.mdsd.micro_lang.microLang.Implements
import dk.sdu.mdsd.micro_lang.microLang.Microservice
import dk.sdu.mdsd.micro_lang.microLang.Model
import dk.sdu.mdsd.micro_lang.microLang.NormalPath
import dk.sdu.mdsd.micro_lang.microLang.Operation
import dk.sdu.mdsd.micro_lang.microLang.ParameterPath
import dk.sdu.mdsd.micro_lang.microLang.Return
import dk.sdu.mdsd.micro_lang.microLang.Template
import dk.sdu.mdsd.micro_lang.microLang.Type
import dk.sdu.mdsd.micro_lang.microLang.TypedParameter
import dk.sdu.mdsd.micro_lang.microLang.Uses

/**
 * Extension utility methods for the various classes of the meta model.
 */
class MicroLangModelUtil {
	
	def microservices(Model model) {
		model.elements.filter(Microservice)
	}
	
	def templates(Model model) {
		model.elements.filter(Template)
	}
	
	def uses(Microservice microservice) {
		microservice.declarations.filter(Uses).map[target].toList
	}
	
	def getImplements(Microservice microservice) {
		microservice.declarations.filter(Implements).map[target].toList
	}
	
	def endpoints(Microservice microservice) {
		microservice.declarations.filter(Endpoint).toList
	}
	
	def parameters(Operation operation) {
		operation.statements.filter(TypedParameter).toList
	}
	
	def returnTypes(Operation operation) {
		operation.statements.filter(Return)
	}
	
	def returnType(Operation operation) {
		operation.returnTypes.head
	}
	
	def path(Endpoint endpoint) {
		endpoint.pathParts.map[
			switch it {
				NormalPath: name
				ParameterPath: parameter.asString
			}
				
		].join('/')
	}
	
	def normalPathParts(Endpoint endpoint) {
		endpoint.pathParts.filter(NormalPath).toList
	}
	
	def asString(TypedParameter typedParameter) {
		typedParameter.type.asString + ' ' + typedParameter.name
	}
	
	def asString(Type type) {
		type.name + type.arrays.join
	}
	
}