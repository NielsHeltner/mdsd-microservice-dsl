package dk.sdu.mdsd.micro_lang.generator

import java.io.File
import java.io.FileInputStream
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.FileLocator
import org.eclipse.jdt.core.JavaCore
import org.eclipse.xtext.generator.IFileSystemAccess2

import static org.eclipse.core.resources.IResource.FILE
import static org.eclipse.core.resources.IResource.FOLDER

class FileSystemAccessExtension {
	
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
	
	def generateFileIfAbsent(IFileSystemAccess2 fsa, String fileName, CharSequence contents) {
		if (!fsa.isFile(fileName)) {
			fsa.generateFile(fileName, contents)
		}
	}
	
	def void setFilesAsNotDerived(IFileSystemAccess2 fsa, String path) {
		val folder = ResourcesPlugin.workspace.root.findMember(fsa.getURI(path).toPlatformString(true)) as IFolder
		for (resource : folder.members) {
			switch resource.type {
				case FILE: resource.setDerived(false, null)
				case FOLDER: fsa.setFilesAsNotDerived(resource.projectRelativePath.toOSString)
			}
		}
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
