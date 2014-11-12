// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.video {
	
	import flash.accessibility.Accessibility;
	import flash.accessibility.AccessibilityImplementation;
	import flash.accessibility.AccessibilityProperties;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.display.Sprite;
	import fl.video.FLVPlayback;
	import fl.video.VideoEvent;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import flash.utils.Timer;

	/**
	 * 
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */ 
	public class SeekBarAccImpl extends AccessibilityImplementation {
		use namespace flvplayback_internal;
		
		//--------------------------------------------------------------------------
		//  Class constants
		//--------------------------------------------------------------------------
	
		/**
		 *  @private
		 *  Default state for all the components.
		 */
		private static const STATE_SYSTEM_NORMAL:uint = 0x00000000;
	
		/**
		 *  @private
		 */
		private static const STATE_SYSTEM_FOCUSABLE:uint = 0x00100000;
	
		/**
		 *  @private
		 */
		private static const STATE_SYSTEM_FOCUSED:uint = 0x00000004;
		
		/**
		 *  @private
		 */
		private static const STATE_SYSTEM_SELECTABLE:uint = 0x00200000;
	
		/**
		 *  @private
		 */
		private static const STATE_SYSTEM_SELECTED:uint = 0x00000002;
	
		/**
		 *  @private
		 */
		private static const STATE_SYSTEM_UNAVAILABLE:uint = 0x00000001;
	
		/**
		 *  @private
		 */
		private static const EVENT_OBJECT_FOCUS:uint = 0x8005;
	
		/**
		 *  @private
		 */
		private static const EVENT_OBJECT_VALUECHANGE:uint = 0x800E;
		
		/**
		 *  @private
		 */
		private static const EVENT_OBJECT_SELECTION:uint = 0x8006;
		
		/**
		 *  @private
		 */
		private static const EVENT_OBJECT_LOCATIONCHANGE:uint = 0x800B;
		
		/**
		 *  @private
		 */
		private static const ROLE_SLIDER:uint = 0x33;
		
		/**
		 *  @private
		 */
		private static const ROLE_SYSTEM_INDICATOR:uint = 0x27;
		
		/**
		 *  @private
		 */
		private static const ROLE_SYSTEM_PUSHBUTTON:uint = 0x2b;

		//--------------------------------------------------------------------------
		//  Variables
		//--------------------------------------------------------------------------
	
		/**
         *  @private (protected)
		 *  A reference to the MovieClip instance that this AccImpl instance
         *  is making accessible.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var master:Sprite;
		
		/**
		 *  @private (protected)
		 *  Accessibility Role of the MovieClip being made accessible.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var role:uint;
		
		private var _vc:FLVPlayback;
		private var _cachedPercentage:Number;
		private var _timer:Timer;


		//--------------------------------------------------------------------------
		//  Properties
		//--------------------------------------------------------------------------
	
		/**
         *  @private (protected)
         *  All subclasses must override this property by returning an array
         *  of strings that contains the events for which to listen.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function get eventsToHandle():Array {
			return [];
		}


		//--------------------------------------------------------------------------
		//  Class methods
		//--------------------------------------------------------------------------
	
		/**
		 *  @private
		 *  All subclasses must implement this function.
		 * 
		 *  @param sprite The Sprite instance that this AccImpl instance
         *  is making accessible.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */	
		public static function createAccessibilityImplementation(sprite:Sprite):void {
			sprite.accessibilityImplementation = new SeekBarAccImpl(sprite);
		}
	
		/**
         * Enables accessibility for a component.
		 * This method is required for the compiler to activate
		 * the accessibility classes for a component.
		 * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function enableAccessibility():void {
		}	
	
		//--------------------------------------------------------------------------
		//  Constructor
		//--------------------------------------------------------------------------
	
        /**
         * @private
         *
         *  Creates a new Accessibility Implementation instance for the specified MovieClip.
		 *
		 *  @param sprite The Sprite instance that this AccImpl instance
         *  makes accessible.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function SeekBarAccImpl(sprite:Sprite) {
			super();
			stub = false;
			master = sprite;

			if(!master.accessibilityProperties){
				master.accessibilityProperties = new AccessibilityProperties();
			}
			master.accessibilityProperties.forceSimple = true;
			// Hookup events to listen for
			var events:Array = eventsToHandle;
			if (events) {
				var n:int = events.length;
				for (var i:int = 0; i < n; i++) {
					master.addEventListener(events[i], eventHandler);
				}
			}
			master.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			try{
				_vc = Object(master).uiMgr._vc;
				_vc.addEventListener(VideoEvent.PLAYHEAD_UPDATE, eventHandler);
			} catch(e:Error){
			}
			
			role = SeekBarAccImpl.ROLE_SLIDER;
		}

		
		//--------------------------------------------------------------------------
		//  Overridden methods: AccessibilityImplementation
		//--------------------------------------------------------------------------
	
		/**
		 *  @private
		 *  Returns the system role for the MovieClip.
		 *
		 *  @param childID The child id.
		 *
         *  @return Role associated with the MovieClip.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get_accRole(childID:uint):uint {
			if(childID==0){
				return role;
			} else if(childID == 2){
				return ROLE_SYSTEM_INDICATOR;
			} else {
				return ROLE_SYSTEM_PUSHBUTTON;
			}
		}

		/**
		 *  @private
		 *  IAccessible method for returning the value of the slider
		 *  (which would be the value of the item selected).
		 *  The slider should return the value of the current thumb as the value.
		 *
		 *  @param childID uint
		 *
		 *  @return Value String
		 *  @review
		 */
		override public function get_accValue(childID:uint):String
		{
			/*
			var playheadTime:Number = _vc.playheadTime;
			var timecode:String = secondsToTime(playheadTime);
			return timecode;
			*/
			if(childID==0){
				return (Math.round(_vc.playheadPercentage)).toString()+"%";
			}
			return null;
			
		}

		//--------------------------------------------------------------------------
		//  Methods
		//--------------------------------------------------------------------------
	
		/**
		 *  @private
		 *  Returns the name of the component.
		 *
		 *  @param childID uint.
		 *
		 *  @return Name of the component.
		 *
		 *  @tiptext Returns the name of the component
		 *  @helpid 3000
		 */
		override public function get_accName(childID:uint):String
		{
			var accName:String = "";	

			if (childID == 0 && master.accessibilityProperties 
				&& master.accessibilityProperties.name 
					&& master.accessibilityProperties.name != "")
				accName += master.accessibilityProperties.name + " ";

			accName += getName(childID) + getStatusName();

			return (accName != null && accName != "") ? accName : null;
		}
		
		/**
		 *  @private
		 *  method for returning the name of the slider
		 *  should return the value
		 *
		 *  @param childID uint
		 *
		 *  @return Name String
		 *  @review
		 */
		protected function getName(childID:uint):String
		{
			var accName:String = "";
			switch(childID){
				case 1:
					accName = "Page Left";
					break;
				case 2:
					accName = "Position"; 
					break;
				case 3:
					accName = "Page Right";
					break;
				case 0:
					accName = "";
					break;
			}
			return accName;
		}
		
		/**
		 *  @private
		 *  Method to return an array of childIDs.
		 *
         *  @return Array child ids
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function getChildIDArray():Array {
			var childIDs:Array = [];
			for(var i:uint = 0; i<3; i++){
				childIDs[i]=i+1;
			}
			return childIDs;
		}
		
		/**
		 *  @private
		 *  IAccessible method for returning the bounding box of the component or its child element.
		 *
		 *  @param childID:uint
		 *
		 *  @return Location:Object
		 */
		override public function accLocation(childID:uint):*
		{
			var location:Object = master;
			var uiMgr:UIManager = _vc.uiMgr as UIManager;
			var ctrl:DisplayObject = uiMgr.controls[UIManager.SEEK_BAR] as DisplayObject;
			var ctrlDataDict:Dictionary= UIManager(uiMgr).ctrlDataDict as Dictionary;
			var ctrlData:ControlData = ctrlDataDict[ctrl];
			
			switch (childID)
			{
				case 0:
				{
					if(ctrlData.hit_mc){
						location = ctrlData.hit_mc;
					}
					break;
				}
				
				case 1:
				case 3:
				{
					if(ctrlData.progress_mc){
						location = ctrlData.progress_mc;
					}
					break;
				}
				
				default:
				{
					break;
				}
			}

			return location;
		}
		
		/**
		 *  @private
		 *  IAccessible method for returning the state of the Button.
		 *  States are predefined for all the components in MSAA.
		 *  Values are assigned to each state.
		 *
		 *  @param childID uint
		 *
		 *  @return State uint
		 */		
		override public function get_accState(childID:uint):uint
		{
			var accState:uint = getState(childID);
			return accState;
		} 


		/**
		 *  Utility method determines state of the accessible component.
		 */
		protected function getState(childID:uint):uint
		{
			var accState:uint = STATE_SYSTEM_NORMAL;
			if(childID==0)
			{
				if (!master.mouseEnabled || !master.tabEnabled)
				{
					accState |= STATE_SYSTEM_UNAVAILABLE;
				}
				else
				{
					accState |= STATE_SYSTEM_FOCUSABLE;
				}
				if(Sprite(master).stage.focus == master){
					accState |= STATE_SYSTEM_FOCUSED;
				}
			}
			return accState;
		}
		
		/**
		 *  @private
		 *  IAccessible method for returning the Default Action.
		 *
		 *  @param childID The child id.
		 *
         *  @return DefaultAction.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get_accDefaultAction(childID:uint):String {
			if(childID==1 || childID==3){
				return "Press";
			}
			return null;
		}

		/**
		 *  @private
		 *  IAccessible method for executing the Default Action.
		 *
		 *  @param childID uint
		 */
		override public function accDoDefaultAction(childID:uint):void
		{
			var percent:Number = _vc.playheadPercentage;
			
			var nearestCuePoint:Object; 
			var nextCuePoint:Object;
			nearestCuePoint	= _vc.findNearestCuePoint(_vc.playheadTime);
			
			if(childID == 1){
				percent -= (_vc.seekBarScrubTolerance*2);
				_vc.playheadPercentage = Math.max(percent,0);
			} else if(childID == 3){
				if(_vc.playheadPercentage>=99){
					return;
				}
				if(nearestCuePoint != null && nearestCuePoint.index<((nearestCuePoint.array as Array).length-1)){
					try{
						nextCuePoint = _vc.findCuePoint(nearestCuePoint.array[nearestCuePoint.index+1]);
						if(nextCuePoint && _vc.isFLVCuePointEnabled(nextCuePoint)){
							if(isNaN(Number(_vc.metadata.videocodecid))){
								_vc.playheadPercentage = Math.max((nextCuePoint.time/_vc.totalTime)*100, Math.min(99,_vc.playheadPercentage+_vc.seekBarScrubTolerance*2));
							} else {
								_vc.playheadTime = nextCuePoint.time;
							}
						}
					} catch (err:Error) {
					}
				}
			}
		}
		
		/**
         *  @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private function getStatusName():String {
			return "";
		}


		//--------------------------------------------------------------------------
		//  Event handlers
		//--------------------------------------------------------------------------
	
		/**
		 *  @private
		 *  Override the generic event handler.
		 *  All AccImpl must implement this to listen
		 *  for events from its master component. 
		 */
		protected function eventHandler(event:Event):void
		{
			if(Accessibility.active)
			{
				switch (event.type)
				{
					case VideoEvent.PLAYHEAD_UPDATE :
						_cachedPercentage = _vc.playheadPercentage;
						var accImpl:SeekBarAccImpl = this;
						if(Accessibility.active){
							Accessibility.sendEvent(master, 0, EVENT_OBJECT_SELECTION);
							Accessibility.sendEvent(master, 0, EVENT_OBJECT_VALUECHANGE, true);
						}
						if(!_timer){
							_timer = new Timer(10);
							_timer.removeEventListener(TimerEvent.TIMER, sendAccessibilityEvent);
							_timer.addEventListener(TimerEvent.TIMER, sendAccessibilityEvent);
							_timer.start();
						}
						break;
				}
			}
		}
		
		/**
		 *  @private
		 *  This is (kind of) a hack to get around the fact that SeekBarSlider is not 
		 *  an IFocusManagerComponent. It forces focus from accessibility its thumb
		 *  gets focus. 
		 */
		private function focusInHandler(event:Event):void
		{
			if(Accessibility.active) {
				Accessibility.sendEvent(master, 0, EVENT_OBJECT_FOCUS);
				Accessibility.sendEvent(master, 0, EVENT_OBJECT_VALUECHANGE, true);
			}
		}
		
		/**
		 *  @private
		 *  Returns a timecode string for a given time in seconds.
		 */
		private function secondsToTime(sec:Number):String {
			var h:String, m:String, s:String, zH:int, zM:int, zS:Number;
			zH = (sec>=3600) ? sec/3600 : 0;
			zM = (sec>=60) ? (sec/60) - zH * 60 : 0;
			zS = sec - (zH * 3600 + zM * 60);
			h = String(zH);
			m = (String(zM).length == 1 && zH>0) ? "0"+String(zM) : String(zM);
			s = (String(Math.floor(zS)).length == 1) ? "0"+String(zS) : String(zS);
			var timecode:String =  m +":"+ s;
			if(zH>0){
				timecode = h + ":" + m + ":" + s;
			}
			return timecode;
		}
		
		/**
		 *  @private
		 *  Dispatches an accessibility event to notify MSAA of a value change.
		 */
		private function sendAccessibilityEvent(event:TimerEvent):void {
			if(_cachedPercentage != _vc.playheadPercentage){
				event.target.stop();
				event.target.removeEventListener(TimerEvent.TIMER, sendAccessibilityEvent);
				_timer = undefined;
				if(Accessibility.active){
					Accessibility.sendEvent(master, 0, EVENT_OBJECT_SELECTION);
					Accessibility.sendEvent(master, 0, EVENT_OBJECT_VALUECHANGE, true);
				} 
			}
		}

	}

}
