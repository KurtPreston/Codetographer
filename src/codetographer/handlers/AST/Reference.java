package codetographer.handlers.AST;

public class Reference {

	private String[] caller = new String[3];
	private String[] callee = new String[3];
	
	public void setCaller(String[] p) {
		caller[0] = p[0];
		caller[1] = p[1];
		caller[2] = p[2];
	}
	
	public void setCallee(String[] p) {
		callee[0] = p[0];
		callee[1] = p[1];
		callee[2] = p[2];
	}
	
	public void print() {
		System.out.println(caller[0] + '.' + caller[1] + '.' + caller[2] + " calls "
							+ callee[0] + '.' + callee[1] + '.' + callee[2]);
	}
	
	public boolean belongsToPackage(String p) {
		if (caller[0].length() >= p.length() && callee[0].length() >= p.length() && caller[0].substring(0, p.length()).equals(p) && callee[0].substring(0, p.length()).equals(p)) {
			return true;
		} else {
			return false;
		}
	}
	
	public String getEcumeneMessage() {
		return "ADD_REFERENCE|" + caller[0] + '.' + caller[1] + '.' + caller[2] + '|' + callee[0] + '.' + callee[1] + '.' + callee[2];
	}
	
}
