package codetographer.ecumene
{
	import codetographer.ecumene.modelcomponents.AbstractModelComponent;
	import codetographer.ecumene.modelcomponents.ComponentSelectionEvent;
	import codetographer.ecumene.modelcomponents.ModelDiagram;
	import codetographer.ecumene.modelcomponents.PrintToConsoleEvent;
	import codetographer.ecumene.modelcomponents.RenderEvent;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import caurina.transitions.*
	import com.dncompute.graphics.GraphicsUtil;
	import com.dncompute.graphics.ArrowStyle;

	
	/**
	 * ...
	 * @author 
	 */
	public class Main extends MovieClip
	{
		private static var diagram:ModelDiagram;
		private static var console:TextField;
		private static var statusText:TextField;
		
		private const panelWidth:Number = 800;
		private const panelHeight:Number = 600 - 150;
		
		public function Main():void 
		{
			diagram = new ModelDiagram();
			addChild(diagram);
			
			initializeConsole();
			initializeStatusText();
			initializeExternalInterface();
			initializeZoomControl();
			diagram.addEventListener(RenderEvent.RENDER_COMPLETE, initializeSelectionListener);

			// testModel();
        }
		
		private function resetDiagram():void
		{
			removeChild(diagram);
			diagram = new ModelDiagram();
			addChild(diagram);
			setChildIndex(diagram, 0);
			diagram.addEventListener(RenderEvent.RENDER_COMPLETE, initializeSelectionListener);
			diagram.addEventListener(PrintToConsoleEvent.PRINT_TO_CONSOLE, printToConsole);
		}
		
		private function testModel():void
		{
			diagram.addClass("codetographer.Activator", 62);
			diagram.addClass("codetographer.handlers.PackageStruI roctureSync", 115);
			diagram.addClass("codetographer.views.EcumeneView", 263);
			diagram.addClass("codetographer.views.widgets.EcumeneBrowser", 121);
			diagram.addClass("testpackage.newClass", 234);
			diagram.addClass("rootclass",14);
			diagram.addClass("rootclass2", 15);
			
			diagram.addReference("codetographer.Activator.initialize.submethod", "rootclass.submethod", 14);
			diagram.addReference("codetographer.views.EcumeneView.submethod", "codetographer.views.widgets.EcumeneBrowser", 2);
			diagram.addReference("testpackage.newClass.submethod", "rootclass.submethod", 4);
			diagram.addReference("rootclass2.submethod", "rootclass.submethod", 6);
			diagram.addReference("codetographer.views.widgets.EcumeneBrowser", "codetographer.views.widgets.EcumeneBrowser",25);
			
			diagram.printToTextField(console);
			diagram.addEventListener(RenderEvent.RENDER_COMPLETE, initializeSelectionListener);
			diagram.render();
			zoomTo(diagram);
		}
		
		private function initializeSelectionListener(e:RenderEvent):void
		{
			diagram.addEventListener(ComponentSelectionEvent.COMPONENT_SELECTED, drawSelectionReferences);
		}
		
		private function drawSelectionReferences(e:ComponentSelectionEvent):void
		{
			if (e.firstTimeSelected)
			{
				drawoutgoingReferences(e.componentId);
			}
		}
		
		private function initializeConsole():void
		{
			console = new TextField;
			console.height = 100;
			// console.y = stage.stageHeight - console.height;
            // console.width = stage.stageWidth;
			console.y = 490;
			console.width = 750;
            console.multiline = true;
            console.wordWrap = true;
            console.border = true;
            console.text = "Initializing...\n";
            addChild(console);
		}
		
		private function printToConsole(e:PrintToConsoleEvent):void
		{
			console.text = e.message;
			console.scrollV = console.maxScrollV;
		}
		
		private function initializeStatusText():void
		{
			var statusTextFormat:TextFormat = new TextFormat();
			statusTextFormat.align = TextFormatAlign.CENTER;
			statusTextFormat.font = "Consolas";
			statusTextFormat.size = 18;
			statusTextFormat.bold = true;
			
			statusText = new TextField();
			statusText.width = 750;
			statusText.setTextFormat(statusTextFormat);
			statusText.defaultTextFormat = statusTextFormat;
			statusText.text = "Test";
			statusText.mouseEnabled = false;
			statusText.tabEnabled = false;
			this.addChild(statusText);
		}
		
		public static function setStatusText(text:String):void
		{
			statusText.text = text;
		}
		
		private function initializeExternalInterface():void
		{
			if (ExternalInterface.available) {
                try {
                    console.appendText("Adding callback...\n");
                    ExternalInterface.addCallback("sendToActionScript", executeRemoteCommand);
                    if (checkJavaScriptReady()) {
                        console.appendText("JavaScript is ready.\n");
                    } else {
                        console.appendText("JavaScript is not ready, creating timer.\n");
                        var readyTimer:Timer = new Timer(100, 0);
                        readyTimer.addEventListener(TimerEvent.TIMER, timerHandler);
                        readyTimer.start();
                    }
                } catch (error:SecurityError) {
                    console.appendText("A SecurityError occurred: " + error.message + "\n");
                } catch (error:Error) {
                    console.appendText("An Error occurred: " + error.message + "\n");
                }
            } else {
                console.appendText("External interface is not available for this container.");
            }
		}
		
		private function initializeZoomControl():void
		{
			this.addEventListener(MouseEvent.MOUSE_WHEEL, scrollZoom);
		}
		
		private function scrollZoom(event:MouseEvent):void
		{	
			var zoomAmount:Number = 1 + event.delta/6;
			if(zoomAmount < 0.5)
				zoomAmount = 0.5;
			if(zoomAmount > 2)
				zoomAmount = 2;

			zoom(zoomAmount);
		}
		
		private function zoom(zoomFactor:Number):void
		{
			var newX:Number;
			var newY:Number;
			if (zoomFactor > 1)
			{
				newX = diagram.x - diagram.mouseX;
				newY = diagram.y - diagram.mouseY;
			}
			else
			{
				newX = diagram.x + diagram.mouseX;
				newY = diagram.y + diagram.mouseY;
			}

			var newScaleX:Number = diagram.scaleX * zoomFactor;
			var newScaleY:Number = diagram.scaleY * zoomFactor;
			diagram.setRegistration(diagram.mouseX, diagram.mouseY);
			Tweener.addTween(diagram, {scaleX2:newScaleX,scaleY2:newScaleY, time:0.5, transition:"easeOutSine"});
		}
		
        private function executeRemoteCommand(value:String):void {
            console.appendText("JavaScript says: " + value + "\n");
			console.scrollV = console.maxScrollV;
			
			var commandParts:Array = value.split('|');
			var command:String = commandParts[0];
			
			switch(command)
			{
				case "RESET":
					resetDiagram();
					break;
				
				case "ADD_CLASS":
					// Add class (and any relevant packages) to diagram
					diagram.addClass(commandParts[1], commandParts[2]);
					break;
					
				case "ADD_REFERENCE":
					// Add a reference from one diagram component to another
					var caller:String = commandParts[1];
					var callee:String = commandParts[2];
					var numRefs:int = commandParts[3];
					console.appendText("COMMAND: Adding " + numRefs + " references from: '" + caller + "' to '" + callee + "'.");
					diagram.addReference(caller,callee,10);
					break;
				
				case "RENDER":
					// render diagram
					// diagram.printToTextField(console);
					diagram.render();
					zoomTo(diagram);
					break;
			}
			console.scrollV = console.maxScrollV;
        }
		
		private function checkJavaScriptReady():Boolean {
            var isReady:Boolean = ExternalInterface.call("isReady");
            return isReady;
        }
		
        private function timerHandler(event:TimerEvent):void {
			console.appendText("Checking JavaScript status...\n");
            var isReady:Boolean = checkJavaScriptReady();
            if (isReady) {
                console.appendText("JavaScript is ready.\n");
                Timer(event.target).stop();
            }
        }
		
		private function zoomTo(diagramElement:MovieClip):void
		{
			var xScale:Number = panelWidth / diagramElement.width;
			var yScale:Number = panelHeight / diagramElement.height;
			var scaleAmount:Number;
			if (xScale > yScale)
				scaleAmount = yScale;
			else
				scaleAmount = xScale;
			
			diagram.scaleX *= scaleAmount;
			diagram.scaleY *= scaleAmount;
			diagram.x = panelWidth / 2 ;
			diagram.y = panelHeight / 2 + statusText.textHeight + 10;
		}
		
		public function drawoutgoingReferences(callerId:String):void
		{
			// trace("DRAWREFS: Drawing references from " + callerId);
			var caller:AbstractModelComponent = diagram.getComponentById(callerId);
			var references:Dictionary = caller.getReferences();
			
			var numOutgoingRefs:int = 0;
			for (var dictionaryIndex:String in references)
			{
				numOutgoingRefs++;
			}
			
			// console.appendText("DRAWREFS: " + caller.componentId() + " contains " + references.toString() + " references.");
			
			for (var calleeId:String in references)
			{
				trace("DRAWREFS: Drawing reference from '" + callerId + "' to '" + calleeId + "'.");
				
				var callee:AbstractModelComponent = diagram.getComponentById(calleeId);
				if (callee == null)
				{
					// Ignore.  Reference made to non-existent component
					continue;
				}
				// trace("DRAWREFS: Callee '" + callee.componentId() + "' retrieved.");
				
				var numRefs:int = references[calleeId];
				
				// trace("DRAWREFS: NumRefs: " + numRefs);
				
				var arrowStart:Point = new Point(caller.x, caller.y);
				var arrowEnd:Point = caller.globalToLocal(callee.localToGlobal(new Point(callee.x, callee.y)));
				
				// trace("DRAWREFS: Line from " + arrowStart.toString() + " to " + arrowEnd.toString());
				
				/*var shape:Shape = new Shape();
				shape.graphics.lineStyle(5,0x999999);
				shape.graphics.beginFill(0x000000);
				shape.graphics.moveTo(arrowStart.x, arrowStart.x);
				shape.graphics.lineTo(arrowEnd.x, arrowEnd.y);
				shape.graphics.endFill();
				caller.addChild(shape);
				*/
				
				// numRefs = 3;
				
				drawConnector(caller,callee,numRefs);
			}
		}
		
		private function drawConnector(origin:AbstractModelComponent,destination:AbstractModelComponent,thickness:Number):void
		{
			var arrowColor:int = 0x333333;
			
			// var arrowStart:Point = new Point(origin.x, origin.y);
			var arrowStart:Point = new Point(0, 0);
			var arrowEnd:Point = origin.globalToLocal(destination.localToGlobal(new Point(0,0)));
			
			//Create a display object to draw into and set the colors
			var connector:Shape = new Shape();
			connector.graphics.lineStyle(thickness,arrowColor);
			connector.graphics.beginFill(arrowColor);
			
			//Set the arrow style
			var style:ArrowStyle = new ArrowStyle();

			//Draw an arrow
			GraphicsUtil.drawArrow(connector.graphics, arrowStart, arrowEnd);
			
			origin.drawShape(connector);
		}
	}
	
}