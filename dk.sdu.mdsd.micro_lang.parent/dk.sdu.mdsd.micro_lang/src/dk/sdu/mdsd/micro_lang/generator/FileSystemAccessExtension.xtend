package dk.sdu.mdsd.micro_lang.generator

import java.io.File
import java.io.FileInputStream
import java.util.List
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import org.eclipse.jdt.core.IClasspathEntry
import org.eclipse.jdt.core.JavaCore
import org.eclipse.xtext.generator.IFileSystemAccess2

import static org.eclipse.core.resources.IResource.FILE
import static org.eclipse.core.resources.IResource.FOLDER

import static extension org.eclipse.jdt.core.IClasspathEntry.*

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
	
	def generateFileInSrcIfAbsent(IFileSystemAccess2 fsa, String fileName, CharSequence contents) {
		if (!fsa.isFile(fileName)) {
			fsa.generateFile(SRC_DIR + fileName, contents)
		}
	}
	
	def void setFilesInSrcAsNotDerived(IFileSystemAccess2 fsa, String path) {
		val folder = ResourcesPlugin.workspace.root.findMember(fsa.getURI(SRC_DIR + path).toPlatformString(true)) as IFolder
		for (resource : folder.members) {
			switch resource.type {
				case FILE: resource.setDerived(false, null)
				case FOLDER: fsa.setFilesInSrcAsNotDerived(resource.projectRelativePath.toOSString)
			}
		}
	}
	
	def changeClassPath(IFileSystemAccess2 fsa, (IPath, List<IClasspathEntry>) => IClasspathEntry entrySupplier) {
		val project = ResourcesPlugin.workspace.root.findMember(fsa.getURI('').toPlatformString(true)).project
		JavaCore.create(project) => [
			val classPathEntries = newArrayList(rawClasspath)
			
			val newEntry = entrySupplier.apply(path, classPathEntries)
			
			if (!classPathEntries.contains(newEntry)) {
				classPathEntries.add(newEntry)
				setRawClasspath(classPathEntries, null)
			}
		]
	}
	
	def fixJreInClassPath(IFileSystemAccess2 fsa) {
		fsa.changeClassPath[path, classPathEntries | 
			classPathEntries.remove(classPathEntries.findFirst[entryKind == it.CPE_CONTAINER])
			JavaCore.newContainerEntry(new Path("org.eclipse.jdt.launching.JRE_CONTAINER"))
		]
	}
	
	def addSrcGenToClassPath(IFileSystemAccess2 fsa) {
		fsa.changeClassPath[path, classPathEntries | 
			JavaCore.newSourceEntry(path.append("src-gen"), null)
		]
	}
	
}
