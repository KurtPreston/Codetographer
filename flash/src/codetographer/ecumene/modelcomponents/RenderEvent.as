package codetographer.ecumene.modelcomponents 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class RenderEvent extends Event
	{
		public static const RENDER_START:String = "RenderEvent.RENDER_START";
		public static const RENDER_COMPLETE:String = "RenderEvent.RENDER_COMPLETE";
		
		public function RenderEvent(event:String) 
		{
			super(event, true, false);
		}
		
	}

}