/*
 * generated by Xtext 2.16.0
 */
package dk.sdu.mdsd.micro_lang.generator

import com.google.common.base.CaseFormat
import com.google.inject.Inject
import dk.sdu.mdsd.micro_lang.MicroLangModelUtil
import dk.sdu.mdsd.micro_lang.microLang.Endpoint
import dk.sdu.mdsd.micro_lang.microLang.Implements
import dk.sdu.mdsd.micro_lang.microLang.Method
import dk.sdu.mdsd.micro_lang.microLang.Microservice
import dk.sdu.mdsd.micro_lang.microLang.NormalPath
import dk.sdu.mdsd.micro_lang.microLang.Operation
import dk.sdu.mdsd.micro_lang.microLang.ParameterPath
import dk.sdu.mdsd.micro_lang.microLang.Return
import dk.sdu.mdsd.micro_lang.microLang.Type
import dk.sdu.mdsd.micro_lang.microLang.TypedParameter
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

import static org.eclipse.emf.ecore.util.EcoreUtil.UsageCrossReferencer.find

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class MicroLangGenerator extends AbstractGenerator {
	
	@Inject
	extension MicroLangModelUtil
	
	@Inject
	extension FileSystemAccessExtension
	
	public static val GEN_FILE_EXT = ".java"
	
	public static val GEN_INTERFACE_DIR = "microservices/"
	public static val GEN_ABSTRACT_DIR = GEN_INTERFACE_DIR + "abstr/"
	public static val SRC_DIR = "../src/"
	public static val GEN_STUB_DIR = "impl/"
	
	public static val RES_LIB_DIR = 'src/resources/generator/'

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		resource.allContents.filter(Microservice).forEach[generateMicroservice(fsa)]
		
		fsa.generateFilesFromDir(RES_LIB_DIR)
		
		fsa.addSrcGenToClassPath
		fsa.fixJreInClassPath
	}
	
	def generateMicroservice(Microservice microservice, IFileSystemAccess2 fsa) {
		val interfaceName = microservice.name.toFileName
		val interfaceDir = GEN_INTERFACE_DIR
		val interfacePkg = interfaceDir.replaceAll("/", ".").substring(0, interfaceDir.length - 1)
		fsa.generateFile(interfaceDir + interfaceName + GEN_FILE_EXT, microservice.generateInterface(interfacePkg, interfaceName))
		
		val abstractName = "Abstract" + interfaceName
		val abstractDir = GEN_ABSTRACT_DIR
		val abstractPkg = abstractDir.replaceAll("/", ".").substring(0, abstractDir.length - 1)
		fsa.generateFile(abstractDir + abstractName + GEN_FILE_EXT, microservice.generateAbstractClass(abstractPkg, abstractName, interfacePkg, interfaceName))
		
		val className = interfaceName + "Impl"
		val classDir = SRC_DIR + GEN_STUB_DIR
		val classPkg = GEN_STUB_DIR.replaceAll("/", ".").substring(0, GEN_STUB_DIR.length - 1)
		fsa.generateFileIfAbsent(classDir + className + GEN_FILE_EXT, microservice.generateStubClass(classPkg, className, abstractPkg, abstractName))
		fsa.setFilesAsNotDerived(classDir)
	}
	
	def generateInterface(Microservice microservice, String pkg, String name)'''
		�generateHeader�
		package �pkg�;
		
		public interface �name� {
			
			String HOST = "�microservice.location.host�";
			int PORT = �microservice.location.port�;
			
			�microservice.generateMethods[endpoint, operation | endpoint.generateMethodSignature(operation) + ';']�
		}
	'''
	
	def generateAbstractClass(Microservice microservice, String pkg, String name, String interfacePkg, String interfaceName)'''
		�generateHeader�
		package �pkg�;
		
		import �interfacePkg�.�interfaceName�;
		�FOR uses : microservice.uses�
		import �interfacePkg�.�uses.name.toFileName�;
		�ENDFOR�
		import lib.HttpUtil;
		import java.util.Map;
		import java.io.IOException;
		import java.net.InetSocketAddress;
		import com.sun.net.httpserver.HttpServer;
		
		public abstract class �name� implements �interfaceName�, Runnable {
			
			protected HttpUtil util = new HttpUtil();
			�FOR uses : microservice.uses�
			protected �uses.name.toFileName� �uses.name.toAttributeName�;
			�ENDFOR�
			
			@Override
			public final void run() {
				try {
					HttpServer server = HttpServer.create(new InetSocketAddress(PORT), 0);
					server.createContext("/", exchange -> {
						String path = exchange.getRequestURI().getPath();
						String method = exchange.getRequestMethod();
						System.out.println(method + " " + path);
						String body = util.getBody(exchange.getRequestBody());
						System.out.println("body: " + body);
						Map<String, Object> parameters = util.toMap(body);
						System.out.println("parameters: " + parameters);
						�microservice.generateMethods[endpoint, operation | endpoint.generateServerMethod]�
						else {
							util.sendResponse(exchange, 404, path + " could not be found");
						}
					});
					server.start();
				}
				catch (IOException e) {
					e.printStackTrace();
				}
			}
		
		}
	'''
	
	def generateStubClass(Microservice microservice, String pkg, String name, String abstractPkg, String abstractName)'''
		�generateHeader�
		package �pkg�;
		
		import �abstractPkg�.�abstractName�;
		
		public class �name� extends �abstractName� {
			
			�microservice.generateMethods[endpoint, operation | endpoint.generateStubMethod(operation)]�
			public static void main(String[] args) {
				new �name�().run();
			}
		
		}
	'''
	
	def generateMethods(Microservice microservice, (Endpoint, Operation) => CharSequence generator)'''
		�FOR implement : microservice.implements�
			�implement.resolve�
			�FOR inheritedEndpoint : implement.inheritedEndpoints�
				�FOR operation : inheritedEndpoint.operations�
					�generator.apply(inheritedEndpoint, operation)�
					
				�ENDFOR�
			�ENDFOR�
		�ENDFOR�
		�FOR endpoint : microservice.endpoints�
			�FOR operation : endpoint.operations�
				�generator.apply(endpoint, operation)�
				
			�ENDFOR�
		�ENDFOR�
	'''
	
	def generateServerMethod(Endpoint endpoint)'''
		if (path.matches("�endpoint.generateRegex�")) {
			System.out.println("�endpoint.path� was hit");
			switch (method) {
				�FOR operation : endpoint.operations�
					case "�operation.method.name�": {
						�endpoint.generateMethodCall(operation)�
						util.sendResponse(exchange, 200, "Hello from �endpoint.path�");
						return;
					}
				�ENDFOR�
				default:
					util.sendResponse(exchange, 405, method + " is not implemented on " + path);
			}
		}
	'''
	
	def generateRegex(Endpoint endpoint) {
		'\\\\/' + endpoint.pathParts.map[
			switch it {
				NormalPath: name
				ParameterPath: parameter.type.generateRegex
			}
		].join('\\\\/')
	}
	
	def generateRegex(Type type) {
		switch type.name {
			case "bool": '''(true|false)'''
			case "string": '''(?!(true|false)\\b)\\b\\w+'''
			case "int": '''\\d+'''
			case "double": '''[0-9]+(\\.[0-9]+)'''
		}
	}
	
	def generateMethodCall(Endpoint endpoint, Operation operation) {
		val paramToIndex = endpoint.pathParts.filter(ParameterPath).toMap([parameter], [endpoint.pathParts.indexOf(it) + 1])
		'''
			�FOR entry : paramToIndex.entrySet�
				�entry.key.type.generateType� �entry.key.name� = �entry.key.type.generateBoxedType�.valueOf(path.split("/")[�entry.value�]);
			�ENDFOR�
			�FOR param : operation.parameters�
				�param.type.generateType� �param.name� = �param.type.generateBoxedType�.valueOf(parameters.get("�param.name�"));
			�ENDFOR�
			�endpoint.toMethodName(operation)��(paramToIndex.keySet + operation.parameters).generateArguments�;
		'''
	}
	
	def generateMethodSignature(Endpoint endpoint, Operation operation)
		'''�operation.returnType.generateReturn� �endpoint.toMethodName(operation)��endpoint.parameters(operation).generateParameters�'''
	
	def generateParameters(Iterable<TypedParameter> params)
		'''(�FOR param : params SEPARATOR ', '��param.type.generateType� _�param.name��ENDFOR�)'''
	
	def generateArguments(Iterable<TypedParameter> params)
		'''(�FOR param : params SEPARATOR ', '��param.name��ENDFOR�)'''
	
	def generateReturn(Return returnType) {
		if (returnType === null) {
			return '''void'''
		}
		'''�returnType.type.generateType�'''
	}
	
	def generateType(Type type) {
		val name = switch type.name {
			case "string": "String"
			case "bool": "boolean"
			default: type.name
		}
		name + type.arrays.join
	}
	
	def generateBoxedType(Type type) {
		val name = switch type.name {
			case "int": "Integer"
			case "bool": "Boolean"
			default: type.name
		}
		name.toFirstUpper
	}
	
	def generateStubMethod(Endpoint endpoint, Operation operation)'''
		@Override
		public �endpoint.generateMethodSignature(operation)� {
			//TODO: implement endpoint logic here
			�operation.returnType.generateStubReturn�
		}
	'''
	
	def generateStubReturn(Return returnType) {
		if (returnType === null) {
			return ''''''
		}
		if (!returnType.type.arrays.empty) {
			return '''return null;'''
		}
		switch returnType.type.name {
			case "bool": '''return false;'''
			case "double", 
			case "int": '''return 0;'''
			default: '''return null;'''
		}
	}
	
	def toFileName(String name) {
		CaseFormat.UPPER_UNDERSCORE.to(CaseFormat.UPPER_CAMEL, name)
	}
	
	def toAttributeName(String name) {
		CaseFormat.UPPER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, name)
	}
	
	def toMethodName(Endpoint endpoint, Operation operation) {
		var pathName = endpoint.pathParts.filter(NormalPath).map[name].join("_")
		val operationName = operation.method.name.toLowerCase
		pathName = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.UPPER_CAMEL, pathName)
		operationName + pathName
	}
	
	def void resolve(Implements implement) {
		val args = implement.arguments
		implement.target.parameters.forEach[parameter, index | 
			find(parameter, parameter.eContainer).forEach[EObject.resolve(args.get(index))]
		]
		implement.target.implements.forEach[resolve]
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
	
	def generateHeader()'''
		/**
		 * Generated by MicroLang
		 */
 	'''
	
}
