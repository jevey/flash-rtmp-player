// Copyright � 2004-2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.video {

	import flash.display.*;

	/**
     * @private
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class ControlData {
		public function ControlData(uiMgr:UIManager, ctrl:DisplayObject, owner:DisplayObject, index:int) {
			this.uiMgr = uiMgr;
			this.index = index;
			this.ctrl = ctrl;
			this.owner = owner;
			try {
				ctrl["uiMgr"] = uiMgr;
			} catch (re:ReferenceError) {
			}
		}

		// general info for any button, bar control or custom clip
		public var uiMgr:UIManager;
		public var index:int;
		public var ctrl:DisplayObject;
		public var owner:DisplayObject; // null for top level controls, set for handles, fills, etc
		public var enabled:Boolean;
		public var avatar:DisplayObject;

		// button specific info
		public var state:uint;
		public var state_mc:Array;
		public var disabled_mc:DisplayObject;
		public var currentState_mc:DisplayObject;

		// info used for calculating placement of bar fills and handles,
		// set for the bars and handles not for the bars
		public var origX:Number;
		public var origY:Number;
		public var origScaleX:Number;
		public var origScaleY:Number;
		public var origWidth:Number;
		public var origHeight:Number;
		public var leftMargin:Number;
		public var rightMargin:Number;
		public var topMargin:Number;
		public var bottomMargin:Number;

		// bar specific info for bars with handles (volume and seek)
		public var handle_mc:Sprite;
		public var percentage:Number;
		public var isDragging:Boolean;
		public var hit_mc:Sprite;

		// bar specific skinning info
		public var progress_mc:DisplayObject;
		public var fullness_mc:DisplayObject;
		public var fill_mc:DisplayObject;
		public var mask_mc:DisplayObject;
		
		public var cachedFocusRect:Boolean;
		public var captureFocus:Boolean;

	} // class ControlData

} // package fl.video
