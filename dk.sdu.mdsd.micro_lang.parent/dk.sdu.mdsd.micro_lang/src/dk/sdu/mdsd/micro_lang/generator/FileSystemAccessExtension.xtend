package dk.sdu.mdsd.micro_lang.generator

import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.core.runtime.FileLocator
import java.io.File
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jdt.core.JavaCore
import java.io.FileInputStream

class FileSystemAccessExtension {
	
	public static val SRC_DIR = "../src/"
	
	/**
	 * Recursively copies every file in the directory.
	 */
	def void generateFilesFromDir(IFileSystemAccess2 fsa, String dirName) {
		fsa.generateFilesFromBaseDir(dirName, dirName)
	}
	
	def private void generateFilesFromBaseDir(IFileSystemAccess2 fsa, String dirName, String baseDir) {
		val dirPath = FileLocator.resolve(class.classLoader.getResource(dirName)).path
		val relativePathStartIndex = dirPath.indexOf(dirName)
		val genDirStartIndex = relativePathStartIndex + baseDir.length
		val dir = new File(dirPath)
		for (resource : dir.listFiles) {
			val path = resource.toURI.path
			switch resource {
				case resource.isFile: fsa.generateFileFromResource(path.substring(genDirStartIndex), path)
				case resource.isDirectory: fsa.generateFilesFromBaseDir(path.substring(relativePathStartIndex), baseDir)
			}
		}
	}
	
	def generateFileFromResource(IFileSystemAccess2 fsa, String fileName, String resource) {
		val inputStream = new FileInputStream(resource)
		fsa.generateFile(fileName, inputStream)
	}
	
	def generateFileInSrc(IFileSystemAccess2 fsa, String fileName, CharSequence contents) {
		
		fsa.generateFile(SRC_DIR + fileName, contents)
	}
	
	def addSrcGenToClassPath(IFileSystemAccess2 fsa) {
		val project = ResourcesPlugin.workspace.root.findMember(fsa.getURI('').toPlatformString(true)).project
		JavaCore.create(project) => [
			val srcGenEntry = JavaCore.newSourceEntry(path.append("src-gen"), null)
			val classPathEntries = newArrayList(rawClasspath)
			if (!classPathEntries.contains(srcGenEntry)) {
				classPathEntries.add(srcGenEntry)
				setRawClasspath(classPathEntries, null)
			}
		]
	}
	
}