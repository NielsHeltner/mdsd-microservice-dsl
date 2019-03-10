package dk.sdu.mdsd.micro_lang

import dk.sdu.mdsd.micro_lang.microLang.Endpoint
import dk.sdu.mdsd.micro_lang.microLang.Parameter
import dk.sdu.mdsd.micro_lang.microLang.Return

class MicroLangModelUtil {
	
	def parameters(Endpoint endpoint) {
		endpoint.statements.filter(Parameter)
	}
	
	def returnType(Endpoint endpoint) {
		endpoint.statements.filter(Return).head
	}
	
}