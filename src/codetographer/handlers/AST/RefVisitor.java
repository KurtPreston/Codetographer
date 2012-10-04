package codetographer.handlers.AST;

import java.util.Vector;

import org.eclipse.jdt.core.dom.ASTVisitor;
import org.eclipse.jdt.core.dom.CompilationUnit;
import org.eclipse.jdt.core.dom.Expression;
import org.eclipse.jdt.core.dom.MethodDeclaration;
import org.eclipse.jdt.core.dom.MethodInvocation;

import codetographer.views.EcumeneView;

public class RefVisitor extends ASTVisitor {
	
	private boolean debug = false;
	private boolean filter = false;
	private Vector<Reference> references = new Vector<Reference>();
	private String[] currentMethod = null;
	private String filterString;
	
	public boolean visit(MethodDeclaration method) {
		
		if (currentMethod == null)
			currentMethod = new String[3];
				
		currentMethod[0] = method.resolveBinding().getDeclaringClass().getPackage().getName();
		currentMethod[1] = method.resolveBinding().getDeclaringClass().getName();
		currentMethod[2] = method.getName().getIdentifier();
		
		if (currentMethod[0].split(".").length <= 0) {
			filterString = currentMethod[0];
		} else {
			filterString = currentMethod[0].split(".")[0];
		}
		
		if (debug) { System.out.println(); System.out.println("Analyzing a new method!"); System.out.println("p: " + currentMethod[0] + " c: " + currentMethod[1] + " m: " + currentMethod[2]); System.out.println("--------------------------------"); System.out.println(); }

		return true;
	}
	
	public boolean visit(MethodInvocation node) {
				
		// This will avoid the trouble encountered when items are initialized
		// in a class declaration and outside of a method.
		if (currentMethod == null)
			return false;
		
		if (debug) { System.out.println("Function call p: " + node.resolveMethodBinding().getDeclaringClass().getPackage().getName() + " c: " + node.resolveMethodBinding().getDeclaringClass().getName() + " m: " + node.getName().getIdentifier()); }	
		
		if (node.getExpression() != null && node.getExpression() instanceof MethodInvocation) {
			recurse((MethodInvocation)node.getExpression());
		} else {
			MethodInvocation m = (MethodInvocation) node;
			
			String[] callee = new String[3];
			callee[0] = m.resolveMethodBinding().getDeclaringClass().getPackage().getName();
			callee[1] = m.resolveMethodBinding().getDeclaringClass().getName();
			callee[2] = m.getName().getIdentifier();
			
			Reference r = new Reference();
			r.setCaller(currentMethod);
			r.setCallee(callee);
			if (!filter || (filter && r.belongsToPackage(filterString))) {
				references.add(r);
			}
		}
		
		if (debug) { System.out.println(); }
		
		return false;
	}
	
	private void recurse(Expression e) {
		
		if (e instanceof MethodInvocation) {
			
			MethodInvocation m = (MethodInvocation) e;
			recurse(m.getExpression());
			
			String[] callee = new String[3];
			callee[0] = m.resolveMethodBinding().getDeclaringClass().getPackage().getName();
			callee[1] = m.resolveMethodBinding().getDeclaringClass().getName();
			callee[2] = m.getName().getIdentifier();
			
			Reference r = new Reference();
			r.setCaller(currentMethod);
			r.setCallee(callee);
			if (!filter || (filter && r.belongsToPackage(filterString))) {
				references.add(r);
			}
			
		}
		
	}
		
	public void process(CompilationUnit unit) {
		unit.accept(this);
	}
	
	public void printAllReferences() {
		for (int i = 0; i < references.size(); i++) {
			System.out.println(references.get(i).getEcumeneMessage());
		}
	}
	
	public void sendAllReferences(EcumeneView view) {
		for (int i = 0; i < references.size(); i++) {
			view.sendMessageToEcumene(references.get(i).getEcumeneMessage());
		}		
	}
	
}
