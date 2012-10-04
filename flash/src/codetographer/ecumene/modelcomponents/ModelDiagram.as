package codetographer.ecumene.modelcomponents
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class ModelDiagram extends AbstractModelComponent
	{
		
		public function ModelDiagram() 
		{
			this.componentContext = "";
			this.componentName = "(root)";
			this.boxColor = 0xEEEEEE;
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		public function addClass(classId:String, linesOfCode:int):void
		{
			var newClassHierarchy:Array = classId.split('.');
			
			if (newClassHierarchy.length == 1)
			{
				var newClassName:String = newClassHierarchy[newClassHierarchy.length - 1];	
				var newClassBox:ClassBox = new ClassBox(componentId(), newClassName, linesOfCode);
				trace("ADDING CLASS: " + newClassName + " to root");
				addSubComponent(newClassBox);
				return;
			}
			
			var subPackageName:String = newClassHierarchy[0];
			if (subComponents[subPackageName] == null)
			{
				var newPackageBox:PackageBox = new PackageBox(componentId(), subPackageName);
				trace("ADDING PACKAGE: " + subPackageName + " to root");
				addSubComponent(newPackageBox);
			}
					
			subComponents[subPackageName].addClass(classId, linesOfCode);
		}
		
		public function addReference(callerId:String, calleeId:String, numRefs:int):void
		{
			var callerHierarchy:Array = callerId.split('.');
			
			var callerIdPart:String = "";
			for (var i:int = 0; i < callerHierarchy.length ; i++)
			{
				if (i > 0)
				{
					callerIdPart += "." ;
				}
				callerIdPart += callerHierarchy[i];
				
				var subComponent:AbstractModelComponent = getSubComponent(callerIdPart);
				if (subComponent == null)
				{
					trace("ERROR: Subcomponent '" + callerIdPart + "' not found.");
				}
				else
				{
					subComponent.addReferencesToComponent(calleeId, numRefs);
				}
				
			}
		}
		
		override public function componentId():String
		{
			return "";
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			this.startDrag();
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			this.stopDrag();
		}
		
		public function getComponentById(componentId:String):AbstractModelComponent
		{
			return getSubComponent(componentId);
		}
		
	}

}