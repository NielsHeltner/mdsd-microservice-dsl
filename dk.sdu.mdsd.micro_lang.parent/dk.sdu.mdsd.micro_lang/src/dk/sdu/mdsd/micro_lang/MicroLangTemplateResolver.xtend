package dk.sdu.mdsd.micro_lang

import com.google.inject.Inject
import dk.sdu.mdsd.micro_lang.microLang.Argument
import dk.sdu.mdsd.micro_lang.microLang.Implements
import dk.sdu.mdsd.micro_lang.microLang.Method
import dk.sdu.mdsd.micro_lang.microLang.NormalPath
import dk.sdu.mdsd.micro_lang.microLang.Type
import dk.sdu.mdsd.micro_lang.microLang.TypedParameter

import static org.eclipse.emf.ecore.util.EcoreUtil.UsageCrossReferencer.find

class MicroLangTemplateResolver {
	
	@Inject
	extension MicroLangModelUtil
	
	def void resolve(Implements implement) {
		val args = implement.arguments.map[name]
		implement.target.parameters.forEach[parameter, index | 
			find(parameter, parameter.eContainer).forEach[it.EObject.resolve(args.get(index))]
		]
		implement.target.implements.forEach[resolve]
	}
	
	def dispatch resolve(Argument argument, String arg) {
		argument.name = arg
	}
	
	def dispatch resolve(NormalPath path, String arg) {
		path.name = arg
	}
	
	def dispatch resolve(Method method, String arg) {
		method.name = arg
	}
	
	def dispatch resolve(TypedParameter parameter, String arg) {
		parameter.name = arg
	}
	
	def dispatch resolve(Type type, String arg) {
		type.name = arg
	}
	
}