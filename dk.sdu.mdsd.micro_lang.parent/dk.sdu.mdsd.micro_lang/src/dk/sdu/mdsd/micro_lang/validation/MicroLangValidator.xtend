/*
 * generated by Xtext 2.16.0
 */
package dk.sdu.mdsd.micro_lang.validation

import com.google.inject.Inject
import dk.sdu.mdsd.micro_lang.MicroLangModelUtil
import dk.sdu.mdsd.micro_lang.microLang.Argument
import dk.sdu.mdsd.micro_lang.microLang.Implements
import dk.sdu.mdsd.micro_lang.microLang.Method
import dk.sdu.mdsd.micro_lang.microLang.MethodArgument
import dk.sdu.mdsd.micro_lang.microLang.MicroLangPackage
import dk.sdu.mdsd.micro_lang.microLang.Microservice
import dk.sdu.mdsd.micro_lang.microLang.NameArgument
import dk.sdu.mdsd.micro_lang.microLang.NormalPath
import dk.sdu.mdsd.micro_lang.microLang.Operation
import dk.sdu.mdsd.micro_lang.microLang.Parameter
import dk.sdu.mdsd.micro_lang.microLang.Return
import dk.sdu.mdsd.micro_lang.microLang.Type
import dk.sdu.mdsd.micro_lang.microLang.TypeArgument
import dk.sdu.mdsd.micro_lang.microLang.TypedParameter
import dk.sdu.mdsd.micro_lang.microLang.Uses
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil.UsageCrossReferencer
import org.eclipse.xtext.validation.Check

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class MicroLangValidator extends AbstractMicroLangValidator {
	
	protected static val ISSUE_CODE_PREFIX = 'dk.sdu.mdsd.micro_lang.'
	
	public static val USES_SELF = ISSUE_CODE_PREFIX + 'UsesSelf'
	
	public static val IMPLEMENT_CYCLE = ISSUE_CODE_PREFIX + 'ImplementCycle'
	
	public static val UNREACHABLE_CODE = ISSUE_CODE_PREFIX + 'UnreachableCode'
	
	public static val INVALID_AMOUNT_ARGS = ISSUE_CODE_PREFIX + 'InvalidAmountArgs'
	
	public static val PARAMETER_TYPE_MISMATCH = ISSUE_CODE_PREFIX + 'ParameterTypeMismatch'
	
	public static val ARGUMENT_TYPE_MISMATCH = ISSUE_CODE_PREFIX + 'ArgumentTypeMismatch'
	
	public static val PARAMETER_NOT_USED = ISSUE_CODE_PREFIX + 'ParameterNotUsed'
	
	public static val INVALID_MICROSERVICE_NAME = ISSUE_CODE_PREFIX + 'InvalidMicroserviceName'
	
	public static val INVALID_ENDPOINT_PATH_NAME = ISSUE_CODE_PREFIX + 'InvalidEndpointPathName'
	
	val epackage = MicroLangPackage.eINSTANCE
	
	@Inject
	extension MicroLangModelUtil
	
	@Check
	def checkSelfNotInUses(Uses uses) {
		val container = uses.eContainer as Microservice
		if (uses.target === container) {
			error('Microservice "' + container.name + '" references itself', 
				uses, 
				epackage.uses_Target, 
				USES_SELF, 
				uses.target.name)
		}
	}
	
	@Check
	def void checkNoCycleInImplements(Implements implement) {
		val visited = newHashSet(implement.eContainer)
		implement.checkNoCycleInImplements(visited)
	}
	
	def private void checkNoCycleInImplements(Implements implement, Set<EObject> visited) {
		if (visited.contains(implement.target)) {
			error('Cycle in hierarchy of template "' + implement.target.name + '"', 
				implement, 
				epackage.implements_Target, 
				IMPLEMENT_CYCLE, 
				implement.target.name)
			return
		}
		visited.add(implement.target)
		implement.target.implements.forEach[checkNoCycleInImplements(newHashSet(visited))]
	}
	
	@Check
	def checkUnreachableCode(Operation operation) {
		val statements = operation.statements
		for (i : 0 ..< statements.size - 1) {
			if (statements.get(i) instanceof Return) {
				error('Unreachable code', 
					statements.get(i + 1), 
					null, 
					UNREACHABLE_CODE)
				return
			}
		}
	}
	
	@Check
	def checkImplementCorrectAmountArgs(Implements implement) {
		val template = implement.target
		val expected = template.parameters.size
		val actual = implement.arguments.size
		if (actual != expected) {
			error('Invalid number of arguments. Expected ' + expected + ' but received ' + actual, 
					implement, 
					null, 
					INVALID_AMOUNT_ARGS)
		}
	}
	
	@Check
	def checkParameterType(Implements implement) {
		implement.target.parameters.forEach[parameter | 
			val inferredType = parameter.inferType
			parameter.references.filter[!inferredType.class.isInstance(it.EObject)].filter[!(it.EObject instanceof Argument)].forEach[
				error('Type mismatch: expected parameter of type ' + it.EObject.toSimpleModelName + ' but received parameter of type ' + inferredType.toSimpleModelName,  
					it.EObject, 
					it.EStructuralFeature, 
					PARAMETER_TYPE_MISMATCH)
			]
		]
	}
	
	// for a path in template (and in general): need to check that path variables to not have the same name as POST typedParams etc
	// also need to resolve params to check this
	
	@Check
	def checkMethodArgumentUsage(MethodArgument argument) {
		argument.isArgumentWellTyped(Method)
	}
	
	@Check
	def checkTypeArgumentUsage(TypeArgument argument) {
		argument.isArgumentWellTyped(Type)
	}
	
	@Check
	def checkNameArgumentUsage(NameArgument argument) {
		if (argument.target === null) {
			argument.isArgumentWellTyped(TypedParameter, NormalPath)
		}
		else {
			val expectedInferredType = argument.correspondingParameter.inferType
			val actualInferredType = argument.target.inferType
			if (!expectedInferredType.class.isInstance(actualInferredType)) {
				error('Type mismatch: expected argument of type ' + expectedInferredType.toSimpleModelName + ' but received argument of type ' + actualInferredType.toSimpleModelName, 
					argument, 
					null, 
					ARGUMENT_TYPE_MISMATCH)
			}
		}
	}
	
	def isArgumentWellTyped(Argument argument, Class<?>... types) {
		val parameter = argument.correspondingParameter
		val inferredType = parameter.inferType
		if (!types.exists[type | type.isInstance(inferredType)]) {
			error('Type mismatch: expected argument of type ' + inferredType.toSimpleModelName + ' but received argument of type ' + argument.toSimpleModelName, 
					argument, 
					null, 
					ARGUMENT_TYPE_MISMATCH)
		}
	}
	
	def EObject inferType(Parameter parameter) {
		val references = parameter.references.map[it.EObject]
		if (references.filter(Argument).nullOrEmpty) { //param not used as arg in this container, type is thus the first usage
			return references.head
		}
		else { //param IS used as arg in this container, recursively follow it until we hit container where it isn't
			val inferredTypeCandidates = references.filter(Argument).map[it.correspondingParameter.inferType].filterNull
			if (inferredTypeCandidates.nullOrEmpty) { // if all candidates are null, it's because the param is never used in the "deepest" layer we could find by following arguments
				return references.findFirst[!(it instanceof Argument)] // so we try to get the type from the first usage in the current container (the usage that isn't an argument, since that argument only leads to a null)
			}
			else {
				return inferredTypeCandidates.head // if there is a candidate that isn't null, pick it!
			}
		}
	}
	
	def getReferences(EObject object) {
		UsageCrossReferencer.find(object, object.eContainer)
	}
	
	def getCorrespondingParameter(Argument argument) {
		val container = argument.eContainer as Implements
		val index = container.arguments.indexOf(argument)
		container.target.parameters.get(index)
	}
	
	@Check
	def checkParameterIsUsed(Parameter parameter) {
		val references = parameter.references
		if (references.empty) {
			warning('The parameter "' + parameter.name + '" is not used', 
				parameter, 
				null, 
				PARAMETER_NOT_USED)
		}
	}
	
	@Check
	def checkMicroserviceNameIsUpperCase(Microservice microservice) {
		val name = microservice.name
		if (name != name.toUpperCase) {
			warning('Microservice name should be written in upper case', 
				microservice, 
				epackage.element_Name, 
				INVALID_MICROSERVICE_NAME, 
				name)
		}
	}
	
	@Check
	def checkNormalPathIsLowerCase(NormalPath path) {
		val name = path.name
		if (name === null) {
			return
		}
		if(name != name.toLowerCase) {
			warning('Endpoint path should be written in lower case', 
					path,
					epackage.normalPath_Name,  
					INVALID_ENDPOINT_PATH_NAME, 
					name)
		}
	}
	
}
