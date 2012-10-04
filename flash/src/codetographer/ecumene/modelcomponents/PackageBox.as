package codetographer.ecumene.modelcomponents 
{
	/**
	 * ...
	 * @author 
	 */
	public class PackageBox extends AbstractModelComponent
	{
		
		public function PackageBox(packageContext:String,packageName:String) 
		{
			super();
			this.componentContext = packageContext;
			this.componentName = packageName;
			this.boxColor = 0x3377FF;
		}
		
		public function addClass(classId:String, linesOfCode:int):void
		{
			var newClassHierarchy:Array = classId.split('.');
			var currentHierarchy:Array = componentId().split('.');
			
			trace("CURRENT LOCATION: " + componentId() + " NewClassHierarchy (" + newClassHierarchy.length + ") currentHierarchy (" + currentHierarchy.length + ") newClassId (" + classId + ")");
			
			// If class is in this package, add it here
			if (currentHierarchy.length == newClassHierarchy.length - 1)
			{
				var newClassName:String = newClassHierarchy[newClassHierarchy.length - 1];
				var newClassBox:ClassBox = new ClassBox(componentId(), newClassName, linesOfCode);
				trace("ADDING CLASS: " + newClassName + " to " + componentId());
				addSubComponent(newClassBox);
				return;
			}
			
			// If class is in a lower package, defer to that subpackage
			for (var i:int = 0; i < newClassHierarchy.length ; i++)
			{
				if (i > currentHierarchy.length)
				{	
					var subPackageName:String = newClassHierarchy[i-1];
					
					// If subpackage does not yet exist, create it
					if (subComponents[subPackageName] == null)
					{
						var newPackageBox:PackageBox = new PackageBox(componentId(), subPackageName);
						trace("ADDING PACKAGE: " + subPackageName + " to " + componentId());
						addSubComponent(newPackageBox);
					}
					
					trace("ENTERING PACKAGE " + subPackageName);
					subComponents[subPackageName].addClass(classId, linesOfCode);
					return;
				}
			}
		}
		
	}

}