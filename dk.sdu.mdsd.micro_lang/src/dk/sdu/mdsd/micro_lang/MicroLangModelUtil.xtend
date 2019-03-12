package dk.sdu.mdsd.micro_lang

import dk.sdu.mdsd.micro_lang.microLang.Endpoint
import dk.sdu.mdsd.micro_lang.microLang.Parameter
import dk.sdu.mdsd.micro_lang.microLang.Return
import dk.sdu.mdsd.micro_lang.microLang.NormalPath
import dk.sdu.mdsd.micro_lang.microLang.Uses
import dk.sdu.mdsd.micro_lang.microLang.Microservice

class MicroLangModelUtil {
	
	def uses(Microservice microservice) {
		microservice.declarations.filter(Uses).map[target].toList
	}
	
	def endpoints(Microservice microservice) {
		microservice.declarations.filter(Endpoint).toList
	}
	
	def parameters(Endpoint endpoint) {
		endpoint.statements.filter(Parameter).toList
	}
	
	def returnTypes(Endpoint endpoint) {
		endpoint.statements.filter(Return)
	}
	
	def returnType(Endpoint endpoint) {
		endpoint.returnTypes.head
	}
	
	def path(Endpoint endpoint) {
		endpoint.pathParts.join
	}
	
	def pathPartsString(Endpoint endpoint) {
		endpoint.pathParts.map[path]
	}
	
	def normalPathParts(Endpoint endpoint) {
		endpoint.pathParts.filter(NormalPath).toList
	}
	
}