package codetographer.handlers;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jdt.core.ICompilationUnit;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IMethod;
import org.eclipse.jdt.core.IPackageFragment;
import org.eclipse.jdt.core.IPackageFragmentRoot;
import org.eclipse.jdt.core.IType;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.core.JavaModelException;
import org.eclipse.jdt.core.dom.AST;
import org.eclipse.jdt.core.dom.ASTParser;
import org.eclipse.jdt.core.dom.CompilationUnit;
import org.eclipse.jface.text.Document;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.internal.Workbench;

import codetographer.handlers.AST.RefVisitor;
import codetographer.views.EcumeneView;

public class PackageStructureSync extends AbstractHandler {
	
	private enum TraversalType {ClassAdd, ReferenceAdd}
	
	public Object execute(ExecutionEvent event) throws ExecutionException {

		String viewId = "codetographer.views.EcumeneView";
		
		IWorkbenchPage page = 
		Workbench.getInstance().getActiveWorkbenchWindow().getActivePage();
		EcumeneView webView = (EcumeneView) page.findViewReference(viewId).getView(false);
		
		webView.sendMessageToEcumene("RESET");
		traverseWorkspace(webView,TraversalType.ClassAdd);
		traverseWorkspace(webView,TraversalType.ReferenceAdd);
		
		webView.sendMessageToEcumene("RENDER");
		
		return null;
	}
	
	private void traverseWorkspace(EcumeneView webView,TraversalType traversalType) {
		// Get the root of the workspace
		IWorkspace workspace = ResourcesPlugin.getWorkspace();
		IWorkspaceRoot root = workspace.getRoot();
		// Get all projects in the workspace
		IProject[] projects = root.getProjects();
		// Loop over all projects
		for (IProject project : projects) {
			try {
				printProjectInfo(project,webView,traversalType);
			} catch (CoreException e) {
				e.printStackTrace();
			}
		}
		return;
	}

	private void printProjectInfo(IProject project,EcumeneView webView,TraversalType traversalType) throws CoreException,
			JavaModelException {
		System.out.println("Working in project " + project.getName());
		// Check if we have a Java project
		if (project.isNatureEnabled("org.eclipse.jdt.core.javanature")) {
			IJavaProject javaProject = JavaCore.create(project);
			printPackageInfos(javaProject,webView,traversalType);
		}
	}

	private void printPackageInfos(IJavaProject javaProject,EcumeneView webView,TraversalType traversalType)
			throws JavaModelException {
		IPackageFragment[] packages = javaProject.getPackageFragments();
		for (IPackageFragment mypackage : packages) {
			// Package fragments include all packages in the
			// classpath
			// We will only look at the package from the source
			// folder
			// K_BINARY would include also included JARS, e.g.
			// rt.jar
			if (mypackage.getKind() == IPackageFragmentRoot.K_SOURCE) {
				System.out.println("Package " + mypackage.getElementName());
				printICompilationUnitInfo(mypackage,webView,traversalType);

			}

		}
	}

	private void printICompilationUnitInfo(IPackageFragment mypackage,EcumeneView webView,TraversalType traversalType)
			throws JavaModelException {
		for (ICompilationUnit unit : mypackage.getCompilationUnits()) {
			System.out.println("Source file " + unit.getElementName());
			
			if(traversalType == TraversalType.ReferenceAdd)
			{
				printReferences(unit, webView);
			}
			
			Document doc = new Document(unit.getSource());
			System.out
					.println("Has number of lines: " + doc.getNumberOfLines());
			printIMethods(unit,webView);
			
			if(traversalType == TraversalType.ClassAdd)
			{
				webView.sendMessageToEcumene("ADD_CLASS|" + mypackage.getElementName() + "."
					+ unit.getElementName().replace(".java","") + "|" + doc.getNumberOfLines());
			}
					
		}
	}

	private void printIMethods(ICompilationUnit unit,EcumeneView webView) throws JavaModelException {
		IType[] allTypes = unit.getAllTypes();
		for (IType type : allTypes) {
			IMethod[] methods = type.getMethods();
			for (IMethod method : methods) {

				System.out.println("Method name " + method.getElementName());
				System.out.println("Signature " + method.getSignature());
				System.out.println("Return Type " + method.getReturnType());

			}
		}
	}
		
	private void printReferences(ICompilationUnit unit, EcumeneView view) {
		try {
									
			ASTParser parser = ASTParser.newParser(AST.JLS3);
			parser.setKind(ASTParser.K_COMPILATION_UNIT);
			parser.setSource(unit); 
			parser.setResolveBindings(true);
			
			CompilationUnit compUnit = (CompilationUnit) parser.createAST(null);
			
			RefVisitor rV = new RefVisitor();
			rV.process(compUnit);
			rV.sendAllReferences(view);	// uncomment me when ready to send messages
			// rV.printAllReferences();
				
		} catch (Exception e) {
			System.err.println("Caught exception: " + e.getMessage());
		}
	}
}
