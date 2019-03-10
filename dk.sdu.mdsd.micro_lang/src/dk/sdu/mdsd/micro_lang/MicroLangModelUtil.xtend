package dk.sdu.mdsd.micro_lang

import dk.sdu.mdsd.micro_lang.microLang.Endpoint
import dk.sdu.mdsd.micro_lang.microLang.Parameter
import dk.sdu.mdsd.micro_lang.microLang.Return
import dk.sdu.mdsd.micro_lang.microLang.NormalPath

class MicroLangModelUtil {
	
	def parameters(Endpoint endpoint) {
		endpoint.statements.filter(Parameter)
	}
	
	def returnType(Endpoint endpoint) {
		endpoint.statements.filter(Return).head
	}
	
	def path(Endpoint endpoint) {
		endpoint.pathParts.join
	}
	
	def pathPartsString(Endpoint endpoint) {
		endpoint.pathParts.map[path]
	}
	
	def normalPathParts(Endpoint endpoint) {
		endpoint.pathParts.filter(NormalPath)
	}
	
}