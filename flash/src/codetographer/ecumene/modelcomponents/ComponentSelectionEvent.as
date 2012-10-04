package codetographer.ecumene.modelcomponents 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class ComponentSelectionEvent extends Event
	{
		public var componentId:String;
		public var firstTimeSelected:Boolean;
		
		public static const COMPONENT_SELECTED:String = "ComponentSelectionEvent.COMPONENT_DESELECTED";
		public static const COMPONENT_DESELECTED:String = "ComponentSelectionEvent.COMPONENT_DESELECTED";
		
		public function ComponentSelectionEvent(event:String,componentId:String,firstTime:Boolean = false) 
		{
			super(event, true, false);
			this.componentId = componentId;
			this.firstTimeSelected = firstTime;
		}
		
	}

}