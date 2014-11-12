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
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/**
	 * 
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */ 
	public class VolumeBarAccImpl extends AccessibilityImplementation {
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
		private static const ROLE_WINDOW:uint = 0x09;
		
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
			sprite.accessibilityImplementation = new VolumeBarAccImpl(sprite);
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
		public function VolumeBarAccImpl(sprite:Sprite) {
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
				_vc.addEventListener(SoundEvent.SOUND_UPDATE, eventHandler);
			} catch(e:Error){
			}
			
			role = VolumeBarAccImpl.ROLE_SLIDER;
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
		 *  Returns the name of the MovieClip.
		 *
		 *  @param childID The child id.
		 *
         *  @return Name of the MovieClip.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get_accName(childID:uint):String {
			var accName:String = "";
			if (childID == 0
					&& master.accessibilityProperties 
					&& master.accessibilityProperties.name 
					&& master.accessibilityProperties.name != "") {
				accName += master.accessibilityProperties.name + " ";
			}
			accName += getName(childID) + getStatusName();
			return (accName != null && accName != "") ? accName : null;
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
			if(childID==0){
				var volume:Number = Math.round(_vc.volume*10000)/100;
				return String(volume)+"%";
			}
			return null;
		}

		//--------------------------------------------------------------------------
		//  Methods
		//--------------------------------------------------------------------------
	
		/**
		 *  @private
		 *  Method for returning the name of the component or its child element
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
		 *  IAccessible method for returning the bounding box of the component or its child element
		 *
		 *  @param childID:uint
		 *
		 *  @return Location:Object
		 */
		override public function accLocation(childID:uint):*
		{
			var location:Object = master;
			var uiMgr:UIManager = _vc.uiMgr as UIManager;
			var ctrl:DisplayObject = uiMgr.controls[UIManager.VOLUME_BAR] as DisplayObject;
			var ctrlDataDict:Dictionary= UIManager(uiMgr).ctrlDataDict as Dictionary;
			var ctrlData:ControlData = ctrlDataDict[ctrl];
			var mask_mc:DisplayObject;
			if(ctrlDataDict[ctrlData.fullness_mc].mask_mc){
				mask_mc = DisplayObject(ctrlDataDict[ctrlData.fullness_mc].mask_mc);
			}
			switch (childID)
			{
				case 1:
				case 3:
				{
					if(mask_mc){
						location = mask_mc;
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
			var uiMgr:UIManager = _vc.uiMgr as UIManager;
			// store mute state
			var wasMuted:Boolean = uiMgr._isMuted;
			// the current volume as a percentage, if muted used the cachedSoundLevel, otherwise use the current _vc.volume
			var num:Number = (wasMuted) ? Math.round(uiMgr.cachedSoundLevel*1000)/100 : Math.round(_vc.volume*1000)/100;
			if(childID == 1){
				if(Math.floor(num) != num){
					_vc.volume = Math.floor(num)/10;
				} else {
					_vc.volume = Math.max(0, (num-1)/10);
				}
			} else if(childID == 3){
				if(Math.round(num) != num){
					_vc.volume = Math.round(num)/10;
				} else {
					_vc.volume = Math.min(1, (num+1)/10);
				}
			}
			// cache the new sound level
			uiMgr.cachedSoundLevel = _vc.volume;
			// if volume was muted, restore the muted state
			if(wasMuted){
				uiMgr._isMuted = true;
				uiMgr.cachedSoundLevel = _vc.volume;
				_vc.volume = 0;
				uiMgr.setEnabledAndVisibleForState(UIManager.MUTE_OFF_BUTTON, VideoState.PLAYING);
				uiMgr.skinButtonControl(uiMgr.controls[UIManager.MUTE_OFF_BUTTON]);
				uiMgr.setEnabledAndVisibleForState(UIManager.MUTE_ON_BUTTON, VideoState.PLAYING);
				uiMgr.skinButtonControl(uiMgr.controls[UIManager.MUTE_ON_BUTTON]);
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
			if (event.type == SoundEvent.SOUND_UPDATE)
			{
				// var childID:uint = SliderEvent(event).thumbIndex + 1;
				if(Accessibility.active) {
					Accessibility.sendEvent(master, 0, EVENT_OBJECT_SELECTION);
					Accessibility.sendEvent(master, 0,
										EVENT_OBJECT_VALUECHANGE, true);
				}
			} 
		}
		
		/**
		 *  @private
		 *  This is (kind of) a hack to get around the fact that VolumeBar is not 
		 *  an IFocusManagerComponent. It forces frocus from accessibility when one of 
		 *  its thumbs get focus. 
		 */
		private function focusInHandler(event:Event):void
		{
			if(Accessibility.active) {
				Accessibility.sendEvent(master, 0, EVENT_OBJECT_FOCUS);
				Accessibility.sendEvent(master, 0, EVENT_OBJECT_VALUECHANGE, true);
			}
		}
	}

}
