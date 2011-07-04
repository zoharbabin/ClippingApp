package com.blogpspot.visualscripts {
/*
author Matyas Forian Szabo
License: none, but i'd be happy if you drop me a link if you use it somewhere. 
*/
import flash.events.Event;
import flash.events.MouseEvent;
import mx.core.UIComponent;
import mx.events.FlexEvent;

import spark.components.supportClasses.SkinnableComponent;

/**
 *  Dispatched when the value of thumb1Value or Thumb2Value
 *  change as a result of user interaction.
 *
 *  @eventType flash.events.Event.CHANGE
 */
[Event(name="change", type="flash.events.Event")]
/**
 *  Dispatched when the value of pendingT1Val or pendingT2Val changes.
 *
 *  @eventType mx.events.PropertyChangeEvent.PROPERTY_CHANGE
 */
[Event(name="propertyChange", type="mx.events.PropertyChangeEvent")]
/**
 * Skinnable Slider with 2 thumbs. Thumbs are named
 <code>thumb1</code> and <code>thumb2</code>.<br>
 * Has and optional <code>middleTrack</code> component for a draggable
 middle track.<br>
 * <b>Own Properties:</b><br><code>
 * minimum, maximum, liveDragging, snapInterval, thumb1Value,
 thumb2Value, pendingT1Val,
 * pendingT2Val, middleIsFixedLength
 * </code><br>
 * <b>Events:</b><br>
 * <code>change:</code> dispatched if any of the slider values change due to user intercation<br>
 * <code>propertyChange:</code> dispatched, if <code>pendingT1Val</code> or <code>pendingT1Val</code> changes
 * (thumb1 or thumb2 moves)<br>
 * <code>valueCommit:</code> dispatched, if <code>thumb1value</code> or <code>thumb2value</code> changes<br>
 * <b>Bugs:</b><br>
 * - When right thumb is at the right end it gets resized badly(flex bug)
 * -> workaround: track, thumbs includeinlayout=false(this causes another bug)
 * -> thumbs,middletrack sizes must be set.<br>
 * - if <code>snapInterval</code> is set the values for the thumbs are sometimes a bit off.(flex bug)
 */
public class IntervalSlider extends SkinnableComponent{
	
	[SkinPart(required="true")]
	/**
	 * First thumb<br>
	 * To work correctly it must be in the root of the skin, and the root
	 of the skin must have absolute layout.
	 * Width+height must be set<br>
	 * x position,includeinlayout=false gets set by the component, dont
	 set it in the skin.
	 */
	public var thumb1:UIComponent;
	
	[SkinPart(required="true")]
	/**
	 * Second thumb<br>
	 * To work correctly it must be in the root of the skin, and the root
	 of the skin must have absolute layout.
	 * Width+height must be set<br>
	 * x position,includeinlayout=false gets set by the component, dont
	 set it in the skin.
	 */
	public var thumb2:UIComponent;
	
	[SkinPart(required="false")]
	/**
	 * Middle track<br>
	 * To work correctly it must be in the root of the skin, and the skin
	 root must have absolute layout.<br>
	 * x,width properties must be set on the skin to look as intended.
	 */
	public var middleTrack:UIComponent;
	
	private var min:Number = 0;
	/**
	 * Sets the minimum amount to diplay by the slider. Default is 0.
	 */
	public function set minimum(val:Number):void{ min =val;invalidateProperties();}
	public function get minimum():Number{ return min; }
	
	private var max:Number = 1;
	/**
	 * Sets the maximum amount to diplay by the slider. Default is 1
	 */
	public function set maximum(val:Number):void{max = val;invalidateProperties();}
	public function get maximum():Number{ return max; }
	
	/**
	 * Controls the behaviour if the user drags the middle track and one
	 thumb reaches min or max value.<br>
	 * If set to <code>true</code> the 2 thumbs will be always the same
	 distance from eachother.<br>
	 * If set to <code>false</code> the distance will shrink if one value
	 reaches the limit.<br>
	 * Default is <code>true</code>
	 */
	public var middleIsFixedLength:Boolean = true;
	/**
	 * If true changes to thumb1Value and thumb2Value are changed
	 immediately if the user makes interaction.
	 * If false changes are only dispatched after the user has finished
	 dragging.<br>
	 * Default is <code>false</code>
	 */
	public var liveDragging:Boolean = false;
	
	[Bindable]
	/**
	 * Stores the thumb value regadless of liveDragging.<br>
	 * It can be used to pass the thumb value to the skin.<br>
	 * Do not change the value.
	 */
	public var pendingT2Val:Number;
	
	[Bindable]
	/**
	 * Stores the thumb value regadless of liveDragging.<br>
	 * It can be used to pass the thumb value to the skin.<br>
	 * Do not change the value.
	 */
	public var pendingT1Val:Number
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////snapInterval
	private var _snapInterval:Number = 0;
	/**
	 * Sets the interval for snapping the thumbs.
	 * Default is 0 which means no snapping
	 */
	public function get snapInterval():Number { return _snapInterval; }
	
	public function set snapInterval(value:Number):void {
		_snapInterval = value;
		invalidateDisplayList()
	}
	
	private var oldMouseX:Number = 0;
	private var thumb2x:Number; // store the thumb pos for snapInterval
	private var thumb1x:Number; // store the thumb pos for snapInterval
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////init
	public function IntervalSlider(){
		super();
		this.setStyle("skinClass",IntervalSliderSkin);
	}
	override public function initialize():void{
		super.initialize();
		if ( !thumb1val ) thumb1Value = min;
		if ( !thumb2val ) thumb2Value = max;
	}
	/////////////////////////////////////////////////////////////////////////////////////////// set/get thumb value
	private var thumb1val:Number=NaN;
	private var thumb1ValueChanged:Boolean = false;
	[Bindable(event="valueCommit")]
	/**
	 * Sets the value of the first thumb.
	 * It must be lower to the value of thumb2.
	 * Dispatches "valueCommit" event on change
	 */
	public function set thumb1Value(val:Number):void{
		if ( val == thumb1val ) return;
		thumb1ValueChanged = true;
		thumb1val = pendingT1Val = val;
		invalidateProperties();
	}
	public function get thumb1Value():Number{ return thumb1val; }
	
	private var thumb2val:Number=NaN;
	private var thumb2ValueChanged:Boolean = false;
	[Bindable(event="valueCommit")]
	/**
	 * Sets the value of the second thumb.
	 * It must be higher or equal to the value of thumb1.
	 * Dispatches "valueCommit" event on change.
	 */
	public function set thumb2Value( val:Number ):void{
		if ( val == thumb2val ) return;
		thumb2val = pendingT2Val = val;
		invalidateProperties()
	}
	public function get thumb2Value():Number{ return thumb2val; }
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////drag thumb1, thumb2
	
	private function startDragThumb1( e:MouseEvent ):void{
		stage.addEventListener( MouseEvent.MOUSE_MOVE, dragThumb1 );
		stage.addEventListener( MouseEvent.MOUSE_UP,stopDragThumb1 );
		oldMouseX = stage.mouseX;
		thumb1x = thumb1.x;
	}
	
	private function dragThumb1( e:MouseEvent ):void{
		thumb1x = thumb1x+stage.mouseX-oldMouseX;
		var newT1val:Number = nearestValidValue(thumb1x*(max-min)/(width-thumb1.width-thumb2.width)+min,snapInterval,min,pendingT2Val );
		if ( pendingT1Val != newT1val ) {
			pendingT1Val = newT1val;
			if ( liveDragging == true && thumb1Value != pendingT1Val) {
				dispatchEvent( new Event(Event.CHANGE) );
				thumb1Value = pendingT1Val;
			} else invalidateDisplayList()
		}
		oldMouseX = stage.mouseX;
	}
	
	private function stopDragThumb1 ( e:MouseEvent ):void{
		stage.removeEventListener( MouseEvent.MOUSE_MOVE, dragThumb1 );
		stage.removeEventListener( MouseEvent.MOUSE_UP,stopDragThumb1 );
		if ( thumb1Value != pendingT1Val ){
			thumb1Value = pendingT1Val;
			dispatchEvent( new Event(Event.CHANGE) );
		}
	}
	
	private function startDragThumb2( e:MouseEvent ):void{
		stage.addEventListener( MouseEvent.MOUSE_MOVE, dragThumb2 );
		stage.addEventListener( MouseEvent.MOUSE_UP,stopDragThumb2 );
		oldMouseX = stage.mouseX;
		thumb2x = thumb2.x;
	}
	
	private function dragThumb2( e:MouseEvent ):void{
		thumb2x = thumb2x+stage.mouseX-oldMouseX;
		var newT2val:Number = nearestValidValue( (thumb2x-thumb2.width)*(max-min)/(width-thumb1.width-thumb2.width)+min,snapInterval,pendingT1Val,max);
		if ( pendingT2Val != newT2val ){
			pendingT2Val = newT2val;
			if ( liveDragging == true && thumb2Value != pendingT2Val){
				thumb2Value = pendingT2Val;
				dispatchEvent( new Event(Event.CHANGE) );
			} else invalidateDisplayList()	
		} 
		
		oldMouseX = stage.mouseX;
	}
	
	private function stopDragThumb2 ( e:MouseEvent ):void{
		stage.removeEventListener( MouseEvent.MOUSE_MOVE, dragThumb2 );
		stage.removeEventListener( MouseEvent.MOUSE_UP,stopDragThumb2 );
		if ( thumb2Value != pendingT2Val ){
			thumb2Value = pendingT2Val;
			dispatchEvent( new Event(Event.CHANGE) );
		}
	}
	
	/**
	 * buggy flex function stolen from Range.as
	 */
	private function nearestValidValue(value:Number,interval:Number,_min:Number,_max:Number):Number{
		if (interval == 0)
			return Math.max(_min, Math.min(_max, value));
		
		var maxValue:Number = _max - _min;
		var scale:Number = 1;
		
		value -= _min;
		
		// If interval isn't an integer, there's a possibility that the floating point
		// approximation of value or value/interval will be slightly larger or smaller
		// than the real value.  This can lead to errors in calculations like
		// floor(value/interval)*interval, which one might expect to just equal value,
		// when value is an exact multiple of interval.  Not so if value=0.58 and
		// interval=0.01, in that case the calculation yields 0.57!  To avoid problems,
		// we scale by the implicit precision of the interval and then round.  For
		// example if interval=0.01, then we scale by 100.
		
		if (interval != Math.round(interval))
		{
			const parts:Array = (new String(1 + interval)).split(".");
			scale = Math.pow(10, parts[1].length);
			maxValue *= scale;
			value = Math.round(value * scale);
			interval = Math.round(interval * scale);
		}
		
		var lower:Number = Math.max(0, Math.floor(value / interval) * interval);
		var upper:Number = Math.min(maxValue, Math.floor((value + interval)/ interval) * interval);
		var validValue:Number = ((value - lower) >= ((upper - lower) / 2)) ? upper : lower;
		
		return (validValue / scale) + _min;
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////drag middle
	private var valDiff:Number
	private function startDragMiddle( e:MouseEvent ):void{
		stage.addEventListener( MouseEvent.MOUSE_MOVE, dragMiddle );
		stage.addEventListener( MouseEvent.MOUSE_UP,stopDragMiddle );
		oldMouseX = stage.mouseX;
		thumb1x = thumb1.x;
		thumb2x = thumb2.x;
		if ( middleIsFixedLength ) valDiff = thumb2Value-thumb1Value;
		else valDiff = 0;
	}
	private function dragMiddle( e:MouseEvent ):void{
		thumb1x = thumb1x + stage.mouseX-oldMouseX;
		var onePixeltoRange:Number = (max-min)/(width-thumb1.width-thumb2.width)
		pendingT1Val = nearestValidValue( thumb1x*onePixeltoRange+min,snapInterval, minimum, pendingT2Val-valDiff );
		thumb2x = thumb2x + stage.mouseX-oldMouseX;
		pendingT2Val = nearestValidValue((thumb2x-thumb2.width)*onePixeltoRange+min, snapInterval,pendingT1Val+valDiff, maximum );
		
		if ( liveDragging == true && ( thumb1Value != pendingT1Val || thumb2Value != pendingT2Val ) ){
			thumb1Value = pendingT1Val;
			thumb2Value = pendingT2Val;
			dispatchEvent( new Event(Event.CHANGE) );
		} else invalidateDisplayList()
		oldMouseX = stage.mouseX;
	}
	private function stopDragMiddle( e:MouseEvent ):void{
		stage.removeEventListener( MouseEvent.MOUSE_MOVE, dragMiddle );
		stage.removeEventListener( MouseEvent.MOUSE_UP,stopDragMiddle );
		if ( thumb1Value != pendingT1Val || thumb2Value != pendingT2Val ){
			thumb1Value = pendingT1Val;
			thumb2Value = pendingT2Val;
			dispatchEvent( new Event(Event.CHANGE) );
		}
		
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////// update
	override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		var valueinPixels:Number = (width-thumb1.width-thumb2.width)/(max-min);
		thumb1.x = (pendingT1Val-min)*valueinPixels;
		thumb2.x = (pendingT2Val-min)*valueinPixels+thumb1.width;
	}
	override protected function commitProperties():void{
		super.commitProperties();
		if ( min > max ) min = max;
		if ( max < min ) max = min;
		// if min or max is set, make sure that thumb2 dont take not allowed values
		if ( thumb1Value < minimum ) {
			thumb1ValueChanged = true;
			thumb1val = pendingT1Val = minimum;
		} else if ( thumb1Value > thumb2Value) {
			thumb1ValueChanged = true;
			thumb1val = pendingT1Val = thumb2Value;
		}
		if ( thumb1Value > maximum ){
			thumb1ValueChanged = true;
			thumb1val = pendingT1Val = maximum;
		}
		if ( thumb2Value > maximum ) {
			thumb2ValueChanged = true;
			thumb2val = pendingT2Val = maximum;
		} else if ( thumb2Value < thumb1Value ) {
			thumb2ValueChanged = true;
			thumb2val = pendingT2Val = thumb1Value;
		}
		if ( thumb1ValueChanged == true ){
			thumb1ValueChanged = false;
			dispatchEvent( new FlexEvent(FlexEvent.VALUE_COMMIT ) );
		}
		if ( thumb2ValueChanged == true ){
			thumb2ValueChanged = false;
			dispatchEvent( new FlexEvent(FlexEvent.VALUE_COMMIT ) );
		}
		updateDisplayList(unscaledWidth,unscaledHeight);
	}
	/////////////////////////////////////////////////////////////////////////////////////// skin stuff
	override protected function partAdded(partName:String, instance:Object):void{
		super.partAdded(partName, instance);
		switch (instance){
			case thumb1:
				thumb1.addEventListener(MouseEvent.MOUSE_DOWN,startDragThumb1,false,0,true );
				thumb1.includeInLayout = false;
				break;
			case thumb2:
				thumb2.addEventListener(MouseEvent.MOUSE_DOWN,startDragThumb2,false,0,true );
				thumb2.includeInLayout = false;
				break;
			case middleTrack:
				middleTrack.addEventListener(MouseEvent.MOUSE_DOWN,startDragMiddle,false,0,true );
				middleTrack.includeInLayout = false;
				break;
		}
	}
	
}
}