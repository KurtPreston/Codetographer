package codetographer.ecumene.modelcomponents 
{
	/**
	 * ...
	 * @author 
	 */
	public class ClassBox extends AbstractModelComponent
	{
		private var linesOfCode:int;
		
		public function ClassBox(packageContext:String, className:String, linesOfCode:int) 
		{
			super();
			this.componentContext = packageContext;
			this.componentName = className;
			this.linesOfCode = linesOfCode;
			this.boxColor = 0x33CC33;
		}
		
		override protected function recalculateSize():void
		{
			componentSize = linesOfCode;
		}
		
	}

}