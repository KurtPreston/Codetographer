package codetographer.ecumene.modelcomponents 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.geom.ColorTransform;
	import codetographer.ecumene.Main;
	import caurina.transitions.*;
	import flash.utils.Timer;

	/**
	 * ...
	 * @author 
	 */
	public class AbstractModelComponent extends DynamicMovie
	
	{
		/************ Varables ***********/
		// Subcomponents
		protected var subComponents:Dictionary;
		
		// References
		protected var references:Dictionary;
		protected var firstSelection:Boolean;
		
		// Name
		protected var componentContext:String;	// Package for classes.  Package + class for methods.
		protected var componentName:String;	// Name, without full package hierarchy
		
		// Graphic
		protected var componentSize:Number;
		protected var title:TextField;
		protected var subComponentView:Sprite;
		protected var componentBox:Sprite;
		protected var componentBoxOutline:Sprite;
		protected var componentBoxOutlineSelected:Sprite;
		protected var boxColor:uint;
		protected var packageSelected:Boolean;
		protected var referenceView:Sprite;
		
		/************ Constants ***********/
		protected const outerBorderPadding:Number = 10;
		protected const innerBorderPadding:Number = 7;
		protected const titleHeight:Number = 20;
		protected const widthScale:Number = 12;
		protected const heightScale:Number = 9;
		protected const subComponentBrightnessMultiplier:Number = 1.2;
		protected const selectedBrightnessMultiplier:Number = 1.5;
		protected const subComponentSizeMultiplier:Number = 0.7;
		protected const zoomLevel:Number = 1.5;
		protected const zoomTimeSeconds:Number = 0.8;
		
		public function AbstractModelComponent() 
		{
			subComponents = new Dictionary();
			references = new Dictionary();
			packageSelected = false;
			firstSelection = true;
		}
		
		public function drawShape(shape:Shape):void
		{
			referenceView.addChild(shape);
		}
		
		protected function selectComponent(event:MouseEvent):void
		{
			if (!packageSelected)
			{
				Tweener.addTween(componentBoxOutline, { alpha:0, time:0.3, transition:"easeOutCubic" } );
				Tweener.addTween(componentBoxOutlineSelected, { alpha:1, time:0.3, transition:"easeOutCubic" } );
				Tweener.addTween(referenceView, { alpha:0.8, time:1.3, transition:"easeOutCubic" } );
				dispatchEvent(new ComponentSelectionEvent(ComponentSelectionEvent.COMPONENT_SELECTED, componentId(),firstSelection));
				packageSelected = true;
				firstSelection = false;
				printReferences();
			}	
			else
			{
				Tweener.addTween(componentBoxOutline, { alpha:1, time:0.3, transition:"easeOutCubic" } );
				Tweener.addTween(componentBoxOutlineSelected, { alpha:0, time:0.3, transition:"easeOutCubic" } );
				Tweener.addTween(referenceView, { alpha:0, time:0.3, transition:"easeOutCubic" } );
				dispatchEvent(new ComponentSelectionEvent(ComponentSelectionEvent.COMPONENT_DESELECTED,componentId()));
				packageSelected = false;
			}
		}
		
		protected function printReferences():void
		{
			var referencesList:String = "\nREFERENCES from " + componentId() + "\n";
			var numRefs:int = 0;
			for (var calleeId:String in references)
			{
				numRefs++;
				referencesList += "    " + calleeId + "\n";
			}
			referencesList += "    TOTAL NUMBER OF REFERENCES: " + numRefs + "\n";
			
			dispatchEvent(new PrintToConsoleEvent(PrintToConsoleEvent.PRINT_TO_CONSOLE, referencesList));
		}
		
		protected function reportComponentId(event:MouseEvent):void
		{
			var numOutgoingRefs:int = 0;
			for each(var outgoingRef:Object in references)
				numOutgoingRefs++;
				
			Main.setStatusText(this.componentId() + "(" + numOutgoingRefs + ")");
		}
		
		protected function addSubComponent(subComponent:AbstractModelComponent):void
		{
			subComponents[subComponent.componentName] = subComponent;
			subComponent.addEventListener(ComponentSelectionEvent.COMPONENT_SELECTED, bringToFront);
		}
		
		protected function bringToFront(e:ComponentSelectionEvent):void
		{
			var subComponent:AbstractModelComponent = getChildContainingSubComponent(e.componentId);
			trace("BRING TO FRONT: '" + componentId() + "' raising '" + subComponent.componentId() + "'");
			subComponentView.setChildIndex(subComponent, subComponentView.numChildren - 1);
		}
		
		public function componentId():String
		{
			if (componentContext.length == 0)
				return componentName;
			else
				return componentContext + "." + componentName;
		}
		
		public function printToTextField(textField:TextField):void
		{
			textField.appendText(componentId() + "\n");
			for each (var subComponent:AbstractModelComponent in subComponents)
			{
				subComponent.printToTextField(textField);
			}
			textField.scrollV = textField.maxScrollV;
		}
		
		public function render():void
		{
			recalculateSize();
			drawComponent();
			dispatchEvent(new RenderEvent(RenderEvent.RENDER_COMPLETE));
		}
		
		protected function drawComponent():void
		{
			initializeTitleText(); // This is done first to get the minimum width
			drawComponentBox();
			drawTitleText();
			drawSubComponentView();
			drawAllSubComponents();
			
			resizeSubComponentView();
			moveTitleText();
			colorizeSubComponents();
			resizeComponentBox();
			
			initializeReferenceView();
		}
		
		protected function initializeReferenceView():void
		{
			referenceView = new Sprite();
			referenceView.alpha = 0;
			addChild(referenceView);
			setChildIndex(referenceView, 0);
		}
		
		protected function drawComponentBox():void
		{
			var minimumWidth:Number = title.textWidth + outerBorderPadding * 2;
			
			var componentWidth:Number = Math.sqrt(componentSize) * widthScale;
			if (componentWidth < minimumWidth)
			{
				componentWidth = minimumWidth;
			}
			
			var componentHeight:Number = Math.sqrt(componentSize) * heightScale + titleHeight + innerBorderPadding;
			
			componentBox = new Sprite();
			componentBox.graphics.lineStyle(0,0,0); // No border
			componentBox.graphics.beginFill(boxColor);
			componentBox.graphics.drawRoundRect(-1*componentWidth/2,-1*componentHeight/2, componentWidth, componentHeight, 10, 10);
			componentBox.graphics.endFill();
			
			
			componentBoxOutline = new Sprite();
			componentBoxOutline.graphics.lineStyle(4, 0x000000);
			componentBoxOutline.graphics.drawRoundRect( -1 * componentWidth / 2, -1 * componentHeight / 2, componentWidth, componentHeight, 10, 10);
			
			componentBoxOutlineSelected = new Sprite();
			componentBoxOutlineSelected.graphics.lineStyle(4, 0xE6B81C);
			componentBoxOutlineSelected.graphics.drawRoundRect( -1 * componentWidth / 2, -1 * componentHeight / 2, componentWidth, componentHeight, 10, 10);
			componentBoxOutlineSelected.alpha = 0;
			
			this.addChild(componentBox);
			this.addChild(componentBoxOutline);
			this.addChild(componentBoxOutlineSelected);
			
			componentBox.addEventListener(MouseEvent.CLICK, selectComponent);
			componentBox.addEventListener(MouseEvent.MOUSE_OVER, reportComponentId);
		}
		
		protected function initializeTitleText():void
		{
			var titleFontFormat:TextFormat = new TextFormat();
			titleFontFormat.align = TextFormatAlign.CENTER;
			titleFontFormat.font = "Consolas";
			titleFontFormat.size = 14;
			titleFontFormat.bold = true;
			
			title = new TextField();
			title.setTextFormat(titleFontFormat);
			title.defaultTextFormat = titleFontFormat;
			title.text = componentName;
			title.textColor = 0xFFFFFF;
			title.mouseEnabled = false;
			title.tabEnabled = false;
		}
		
		protected function drawTitleText():void
		{
			title.width = componentBox.width;
			title.x = -1 * componentBox.width / 2;
			title.y = -1 * componentBox.height / 2;
			this.addChild(title);
		}
		
		protected function moveTitleText():void
		{
			title.y = -1 * componentBox.height / 2;
		}
		
		protected function drawSubComponentView():void
		{
			subComponentView = new Sprite();
			//var subComponentViewWidth:Number = componentBox.width - outerBorderPadding * 2;
			//var subComponentViewHeight:Number = componentBox.height - title.height - title.y - innerBorderPadding;
			//subComponentView.graphics.drawRect(-1 * subComponentViewWidth/2, -1 *subComponentViewHeight/2, subComponentViewWidth, subComponentViewHeight);
			subComponentView.y = innerBorderPadding + title.textHeight;
			this.addChild(subComponentView);
		}
		
		protected function resizeSubComponentView():void
		{
			var subComponentViewWidth:Number = subComponentView.width + outerBorderPadding * 2;
			var subComponentViewHeight:Number = subComponentView.height + outerBorderPadding + innerBorderPadding;
			subComponentView.graphics.drawRect(-1 * subComponentViewWidth/2, -1 *subComponentViewHeight/2, subComponentViewWidth, subComponentViewHeight);
		}
		
		public function getReferences():Dictionary
		{
			return references;
		}
		
		protected function drawAllSubComponents():void
		{
			var numSubComponents:int = 0;
			for each(var subComponentCounter:AbstractModelComponent in subComponents)
			{
				numSubComponents++;
			}
			
			var distanceFromCenter:Number;
			/*if (componentBox.height > subComponentView.width)
				distanceFromCenter = subComponentView.width / 2;
			else
				distanceFromCenter = subComponentView.height / 2;
				*/
			distanceFromCenter = 50;
			
			for each(var subComponent:AbstractModelComponent in subComponents)
			{
				subComponent.drawComponent();
				subComponentView.addChild(subComponent);
			}
			
			
			while (subComponentsIntersect())
			{
				trace("Intersecting subcomponents");
				
				if (distanceFromCenter > 2000)
					break;
				moveSubComponentsInCircle(distanceFromCenter);
				distanceFromCenter *= 1.3;
				shrinkAllSubComponents(0.7);
			}
				
			
			// Add all components in a ring
			/*
			var subComponentIndex:int = 0;
			for each(var subComponent:AbstractModelComponent in subComponents)
			{
				subComponent.drawComponent();
				if (numSubComponents > 1)
				{
					subComponent.x = Math.cos(2 * Math.PI * subComponentIndex / numSubComponents) * distanceFromCenter;
					subComponent.y = Math.sin(2 * Math.PI * subComponentIndex / numSubComponents) * distanceFromCenter;
				}
				subComponentView.addChild(subComponent);
				
				subComponentIndex++;
			}
			*/
			
			// Shrink all components until there is no overlap
			// shrinkAllSubComponents();
			/*
			var numShrinks:int = 0;
			while (subComponentsIntersect())
			{
				if (numShrinks > 4)
					break;
				shrinkAllSubComponents();
				numShrinks++;
			}
			*/
		}
		
		protected function moveSubComponentsInCircle(distanceFromCenter:Number):void
		{
			var numSubComponents:int = 0;
			for each(var subComponentCounter:AbstractModelComponent in subComponents)
			{
				numSubComponents++;
			}
			
			var subComponentIndex:int = 0;
			for each(var subComponent:AbstractModelComponent in subComponents)
			{
				if (numSubComponents > 1)
				{
					subComponent.x = Math.cos(2 * Math.PI * subComponentIndex / numSubComponents) * distanceFromCenter;
					subComponent.y = Math.sin(2 * Math.PI * subComponentIndex / numSubComponents) * distanceFromCenter;
				}
				subComponentIndex++;
			}
		}
		
		protected function colorizeSubComponents():void
		{
			for each(var subComponent:AbstractModelComponent in subComponents)
			{
				var subPackageColor:ColorTransform = subComponent.transform.colorTransform;
				subPackageColor.redMultiplier = subPackageColor.redMultiplier * subComponentBrightnessMultiplier;
				subPackageColor.greenMultiplier = subPackageColor.greenMultiplier * subComponentBrightnessMultiplier;
				subPackageColor.blueMultiplier = subPackageColor.blueMultiplier * subComponentBrightnessMultiplier;
				subComponent.transform.colorTransform = subPackageColor;
			}	
		}
		
		protected function resizeComponentBox():void
		{
			var minimumWidth:Number = subComponentView.width + innerBorderPadding * 2;
			var minimumHeight:Number = subComponentView.height + titleHeight + outerBorderPadding + innerBorderPadding * 2;
			
			if (componentBox.width < minimumWidth)
			{
				componentBox.width = minimumWidth;
				componentBoxOutline.width = minimumWidth;
				componentBoxOutlineSelected.width = minimumWidth;
			}
			
			if (componentBox.height < minimumHeight)
			{
				componentBox.height = minimumHeight;
				componentBoxOutline.height = minimumHeight;
				componentBoxOutlineSelected.height = minimumHeight;
			}
		}
		
		protected function subComponentsIntersect():Boolean
		{
			for each(var subComponentA:AbstractModelComponent in subComponents)
			{
				for each(var subComponentB:AbstractModelComponent in subComponents)
				{
					if (subComponentA != subComponentB)
					{
						if (subComponentA.componentBox.hitTestObject(subComponentB.componentBox))
						{
							trace(subComponentA.componentId() + " intersects " + subComponentB.componentId());
							return true;
						}
					}
				}
			}
			return false;
		}
		
		protected function shrinkAllSubComponents(scaleFactor:Number):void
		{
			for each(var subComponent:AbstractModelComponent in subComponents)
			{
				subComponent.scaleX *= scaleFactor;
				subComponent.scaleY *= scaleFactor;
			}
		}
		
		protected function recalculateSize():void
		{
			componentSize = 0;
			
			for each (var subComponent:AbstractModelComponent in subComponents)
			{
				subComponent.recalculateSize();
				componentSize += subComponent.componentSize;
			}
		}
		
		public function addReferencesToComponent(calleeId:String, numRefs:int):void
		{
			var calleeHierarchy:Array = calleeId.split('.');
			
			var calleeIdPart:String = "";
			
			for (var i:int = 0; i < calleeHierarchy.length ; i++)
			{
				
				if (i > 0)
				{
					calleeIdPart += ".";
				}
				
				calleeIdPart += calleeHierarchy[i];
				
				if (componentId().match(calleeIdPart) != null)
				{
					continue;
				}
				
				if (references.hasOwnProperty(calleeIdPart))
				{
					references[calleeIdPart] += numRefs;
				}
				else
				{
					references[calleeIdPart] = 0;
				}
				
				trace("ADDREFS: Adding reference in " + componentId() + " to " + calleeIdPart);
			}
		}
		
		protected function getSubComponent(subcomponentId:String):AbstractModelComponent
		{
			if (componentId() == subcomponentId)
			{
				return this;
			}
			
			// If class is in a lower package, defer subpackage
			var thisClassHierarchy:Array = componentId().split('.');
			var subcomponentHierarchy:Array = subcomponentId.split('.');
			var subcomponentNextLevelName:String;
			if (componentId() == "")
			{
				// In root
				subcomponentNextLevelName = subcomponentHierarchy[0];
			}
			else
			{
				subcomponentNextLevelName = subcomponentHierarchy[thisClassHierarchy.length];
			}
			
			// trace("Hierarchy Depth: " + thisClassHierarchy.length);
			// trace("In " + this.componentId() + "(" + thisClassHierarchy.length + ").  Deferring to subpackage '" + subcomponentNextLevelName + "' to retrieve '" + subcomponentId + "'");
			
			if (subComponents.hasOwnProperty(subcomponentNextLevelName))
			{
				return subComponents[subcomponentNextLevelName].getSubComponent(subcomponentId);
			}
			else
			{
				trace("ERROR: '" + componentId() + "' does not contain subcomponent '" + subcomponentNextLevelName + "'.");
				return null;
			}
		}
		
		protected function getChildContainingSubComponent(subComponentId:String):AbstractModelComponent
		{
			var thisClassHierarchy:Array = componentId().split('.');
			var subcomponentHierarchy:Array = subComponentId.split('.');
			var subcomponentNextLevelName:String;
			if (componentId() == "")
			{
				// In root
				subcomponentNextLevelName = subcomponentHierarchy[0];
			}
			else
			{
				subcomponentNextLevelName = subcomponentHierarchy[thisClassHierarchy.length];
			}
			return subComponents[subcomponentNextLevelName];
		}
	}
}