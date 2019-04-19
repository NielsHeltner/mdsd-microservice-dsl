package dk.sdu.mdsd.micro_lang.generator

import org.eclipse.xtend.lib.annotations.Data

@Data class NameAndPackage {
	
	String name
	String pkg
	
	def static operator_mappedTo(String e1, String e2) {
		new NameAndPackage(e1, e2)
	}
	
}
