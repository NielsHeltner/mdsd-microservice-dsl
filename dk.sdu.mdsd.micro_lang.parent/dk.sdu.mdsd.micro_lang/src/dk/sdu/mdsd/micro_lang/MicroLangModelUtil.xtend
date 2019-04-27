package dk.sdu.mdsd.micro_lang

import dk.sdu.mdsd.micro_lang.microLang.Element
import dk.sdu.mdsd.micro_lang.microLang.Endpoint
import dk.sdu.mdsd.micro_lang.microLang.Implements
import dk.sdu.mdsd.micro_lang.microLang.Microservice
import dk.sdu.mdsd.micro_lang.microLang.Model
import dk.sdu.mdsd.micro_lang.microLang.NormalPath
import dk.sdu.mdsd.micro_lang.microLang.Operation
import dk.sdu.mdsd.micro_lang.microLang.ParameterPath
import dk.sdu.mdsd.micro_lang.microLang.Return
import dk.sdu.mdsd.micro_lang.microLang.Template
import dk.sdu.mdsd.micro_lang.microLang.TypedParameter
import dk.sdu.mdsd.micro_lang.microLang.Uses
import org.eclipse.emf.ecore.EObject

/**
 * Extension utility methods for the various classes of the meta-model.
 */
class MicroLangModelUtil {
	
	def microservices(Model model) {
		model.elements.filter(Microservice)
	}
	
	def templates(Model model) {
		model.elements.filter(Template)
	}
	
	def uses(Element element) {
		element.declarations.filter(Uses).map[target]
	}
	
	def getImplements(Element element) {
		element.declarations.filter(Implements)
	}
	
	def endpoints(Element element) {
		element.declarations.filter(Endpoint)
	}
	
	/**
	 * Provides an Iterable of the endpoints this 'implements' provides, 
	 * consisting of the endpoints declared in its target template, as well as 
	 * any template the target might implement.
	 */
	def Iterable<Endpoint> inheritedEndpoints(Implements implement) {
		implement.target.endpoints + implement.target.implements.flatMap[inheritedEndpoints]
	}
	
	def parameters(Operation operation) {
		operation.statements.filter(TypedParameter)
	}
	
	def parameters(Endpoint endpoint, Operation operation) {
		endpoint.parameterPaths.map[parameter] + operation.parameters
	}
	
	def returnTypes(Operation operation) {
		operation.statements.filter(Return)
	}
	
	def returnType(Operation operation) {
		operation.returnTypes.head
	}
	
	def hasReturn(Operation operation) {
		operation.returnType !== null
	}
	
	def normalPaths(Endpoint endpoint) {
		endpoint.pathParts.filter(NormalPath)
	}
	
	def parameterPaths(Endpoint endpoint) {
		endpoint.pathParts.filter(ParameterPath)
	}
	
	def mapPaths(Endpoint endpoint, (NormalPath) => CharSequence computeNormalPaths, (ParameterPath) => CharSequence computeParameterPaths, String prefixAndJoin) {
		prefixAndJoin + endpoint.pathParts.map[
			switch it {
				NormalPath: computeNormalPaths.apply(it)
				ParameterPath: computeParameterPaths.apply(it)
			}
		].join(prefixAndJoin)
	}
	
	def path(Endpoint endpoint) {
		endpoint.mapPaths([name ?: ""], ['{' + parameter.type.name + '}'], '/')
	}
	
	def toSimpleModelName(Class<? extends EObject> clazz) {
		clazz.interfaces.head.simpleName
	}
	
}