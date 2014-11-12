// Copyright © 2004-2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.video {

	//import fl.managers.IFocusManagerComponent;
	import flash.accessibility.Accessibility;
	import flash.accessibility.AccessibilityImplementation;
	import flash.accessibility.AccessibilityProperties;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.*;

	use namespace flvplayback_internal;

	/**
	 * <p>Functions you can plugin to seek bar or volume bar with, to
	 * override std behavior: startHandleDrag(), stopHandleDrag(),
	 * positionHandle(), calcPercentageFromHandle(), positionBar().
	 * Return true to override standard behavior or return false to allow
	 * standard behavior to execute.  These do not override default
	 * behavior, but allow you to add addl functionality:
	 * addBarControl()</p>
	 *
	 * <p>Functions you can use for swf based skin controls: layoutSelf()
	 * - called after control is laid out to do additional layout.
	 * Properties that can be set to customize layout: anchorLeft,
	 * anchorRight, anchorTop, anchorLeft.</p>
	 *
	 * <p>Possible seek bar and volume bar customization variables:
	 * handleLeftMargin, handleRightMargin, handleY, handle_mc,
	 * progressLeftMargin, progressRightMargin, progressY, progress_mc,
	 * fullnessLeftMargin, fullnessRightMargin, fullnessY, fullness_mc,
	 * percentage.  These variables will also be set to defaults by
	 * UIManager if values are not passed in.  Percentage is constantly
	 * updated, others will be set by UIManager in addBarControl or
	 * finishAddBarControl.</p>
	 *
	 * <p>These seek bar and volume bar customization variables do not
	 * work with external skin swfs and are not set if no value is passed
	 * in: handleLinkageID, handleBelow, progressLinkageID, progressBelow,
	 * fullnessLinkageID, fullnessBelow</p>
	 *
	 * <p>Note that in swf skins, handle_mc must have same parent as
	 * correpsonding bar.  fullness_mc and progress_mc may be at the same
	 * level or nested, and either of those may have a fill_mc at the same
	 * level or nested.  Note that if any of these nestable clips are
	 * nested, then they must be scaled at 100% on stage, because
	 * UIManager uses xscale and yscale to resize them and assumes 100% is
	 * the original size.  If they are not scaled at 100% when placed on
	 * stage, weird stuff might happen.</p>
	 *
	 * <p>Variables set in seek bar and volume bar that can be used by
	 * custom methods, but should be treated as read only: isDragging,
	 * uiMgr, controlIndex.  Also set on handle mc: controlIndex</p>
	 *
	 * <p>Note that when skinAutoHide is true, skin is hidden unless
	 * mouse if over visible VideoPlayer or over the skin.  Over the
	 * skin is measured by hitTest on border_mc clip from the layout_mc.
	 * If there is no border_mc, then mouse over the skin doesn't make
	 * it visible (unless skin is completely over the video, of course.)</p>
	 *
     * @private
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class UIManager {

		include "ComponentVersion.as"

		public static const PAUSE_BUTTON:int = 0;
		public static const PLAY_BUTTON:int = 1;
		public static const STOP_BUTTON:int = 2;
		public static const SEEK_BAR_HANDLE:int = 3;
		public static const SEEK_BAR_HIT:int = 4;
		public static const BACK_BUTTON:int = 5;
		public static const FORWARD_BUTTON:int = 6;
		public static const FULL_SCREEN_ON_BUTTON:int = 7;
		public static const FULL_SCREEN_OFF_BUTTON:int = 8;
		public static const MUTE_ON_BUTTON:int = 9;
		public static const MUTE_OFF_BUTTON:int = 10;
		public static const VOLUME_BAR_HANDLE:int = 11;
		public static const VOLUME_BAR_HIT:int = 12;
		public static const NUM_BUTTONS:int = 13;

		public static const PLAY_PAUSE_BUTTON:int = 13;
		public static const FULL_SCREEN_BUTTON:int = 14;
		public static const MUTE_BUTTON:int = 15;
		public static const BUFFERING_BAR:int = 16;
		public static const SEEK_BAR:int = 17;
		public static const VOLUME_BAR:int = 18;
		public static const NUM_CONTROLS:int = 19;
		
		public static const NORMAL_STATE:uint = 0;
		public static const OVER_STATE:uint = 1;
		public static const DOWN_STATE:uint = 2;

		public static const FULL_SCREEN_SOURCE_RECT_MIN_WIDTH:uint = 320;
		public static const FULL_SCREEN_SOURCE_RECT_MIN_HEIGHT:uint = 240;

		// controls
		flvplayback_internal var controls:Array, delayedControls:Array;
		public var customClips:Array;       // bg1, bg2... and fg1, fg2... clips
		public var ctrlDataDict:Dictionary;

		// for layout
		flvplayback_internal var skin_mc:Sprite;           // Sprite created to hold skin assets
		flvplayback_internal var skinLoader:Loader;        // loads skinTemplate
		flvplayback_internal var skinTemplate:Sprite;      // template Sprite loaded in or passed directly in
		flvplayback_internal var layout_mc:Sprite;         // layout_mc from the skin_mc
		flvplayback_internal var border_mc:DisplayObject;  // determines bounds of whether mouse is over skin for autohide
		flvplayback_internal var borderCopy:Sprite;        // Sprite holding copied bitmaps created to recolor the border_mc
		flvplayback_internal var borderPrevRect:Rectangle; // location of border_mc last time we did the copy
		flvplayback_internal var borderScale9Rects:Array;   // masking rects we use to fake scale 9 in border copy
		flvplayback_internal var borderAlpha:Number;
		flvplayback_internal var borderColor:uint;
		flvplayback_internal var borderColorTransform:ColorTransform;
		flvplayback_internal var skinLoadDelayCount:uint;
		flvplayback_internal var placeholderLeft:Number;
		flvplayback_internal var placeholderRight:Number;
		flvplayback_internal var placeholderTop:Number;
		flvplayback_internal var placeholderBottom:Number;
		flvplayback_internal var videoLeft:Number;
		flvplayback_internal var videoRight:Number;
		flvplayback_internal var videoTop:Number;
		flvplayback_internal var videoBottom:Number;

		// properties
		flvplayback_internal var _bufferingBarHides:Boolean;
		flvplayback_internal var _controlsEnabled:Boolean;
		flvplayback_internal var _skin:String;
		flvplayback_internal var _skinAutoHide:Boolean;
		flvplayback_internal var _skinFadingMaxTime:int;
		flvplayback_internal var _skinReady:Boolean;
		flvplayback_internal var __visible:Boolean;
		flvplayback_internal var _seekBarScrubTolerance:Number;
		flvplayback_internal var _skinScaleMaximum:Number;

		// progress
		flvplayback_internal var _progressPercent:Number;
		
		//volume and mute
		flvplayback_internal var cachedSoundLevel:Number;
		flvplayback_internal var _lastVolumePos:Number;
		flvplayback_internal var _isMuted:Boolean;
		flvplayback_internal var _volumeBarTimer:Timer;
		flvplayback_internal var _volumeBarScrubTolerance:Number;

		// my FLVPlayback
		flvplayback_internal var _vc:FLVPlayback;

		// buffering
		flvplayback_internal var _bufferingDelayTimer:Timer;
		flvplayback_internal var _bufferingOn:Boolean;

		// seeking
		flvplayback_internal var _seekBarTimer:Timer;
		flvplayback_internal var _lastScrubPos:Number;
		flvplayback_internal var _playAfterScrub:Boolean;

		// skin autohide
		flvplayback_internal var _skinAutoHideTimer:Timer;
		flvplayback_internal static const SKIN_AUTO_HIDE_INTERVAL:Number = 200;
		flvplayback_internal var _skinFadingTimer:Timer;
		flvplayback_internal static const SKIN_FADING_INTERVAL:Number = 100;
		flvplayback_internal var _skinFadingIn:Boolean;
		flvplayback_internal var _skinFadeStartTime:int;
		flvplayback_internal var _skinAutoHideMotionTimeout:int;
		flvplayback_internal var _skinAutoHideMouseX:Number;
		flvplayback_internal var _skinAutoHideMouseY:Number;
		flvplayback_internal var _skinAutoHideLastMotionTime:int;
		flvplayback_internal static const SKIN_FADING_MAX_TIME_DEFAULT:Number = 500;
		flvplayback_internal static const SKIN_AUTO_HIDE_MOTION_TIMEOUT_DEFAULT:Number = 3000;

		// tracks if one of the controls being pressed so we can
		// effect a setCapture style loop
		flvplayback_internal var mouseCaptureCtrl:int;

		// full screen
		flvplayback_internal var fullScreenSourceRectMinWidth:uint;
		flvplayback_internal var fullScreenSourceRectMinHeight:uint;
		flvplayback_internal var fullScreenSourceRectMinAspectRatio:Number;
		flvplayback_internal var _fullScreen:Boolean;
		flvplayback_internal var _fullScreenTakeOver:Boolean;
		flvplayback_internal var _fullScreenBgColor:uint;
		flvplayback_internal var _fullScreenAccel:Boolean;
		flvplayback_internal var _fullScreenVideoWidth:Number;
		flvplayback_internal var _fullScreenVideoHeight:Number;
		flvplayback_internal var cacheStageAlign:String;
		flvplayback_internal var cacheStageScaleMode:String;
		flvplayback_internal var cacheStageBGColor:uint;
		flvplayback_internal var cacheFLVPlaybackParent:DisplayObjectContainer;
		flvplayback_internal var cacheFLVPlaybackIndex:int;
		flvplayback_internal var cacheFLVPlaybackLocation:Rectangle;
		flvplayback_internal var cacheFLVPlaybackScaleMode:Array;
		flvplayback_internal var cacheFLVPlaybackAlign:Array;
		flvplayback_internal var cacheSkinAutoHide:Boolean;

		/**
		 * Default value of volumeBarInterval
		 *
         * @see #volumeBarInterval
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const VOLUME_BAR_INTERVAL_DEFAULT:Number = 250;

		/**
		 * Default value of volumeBarScrubTolerance.
		 *
         * @see #volumeBarScrubTolerance
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const VOLUME_BAR_SCRUB_TOLERANCE_DEFAULT:Number = 0;

		/**
		 * Default value of seekBarInterval
		 *
         * @see #seekBarInterval
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const SEEK_BAR_INTERVAL_DEFAULT:Number = 250;

		/**
		 * Default value of seekBarScrubTolerance.
		 *
         * @see #seekBarScrubTolerance
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const SEEK_BAR_SCRUB_TOLERANCE_DEFAULT:Number = 5;

		/**
		 * Default value of bufferingDelayInterval.
		 *
         * @see #seekBarInterval
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const BUFFERING_DELAY_INTERVAL_DEFAULT:Number = 1000;

		// skinning statics
		flvplayback_internal static var layoutNameToIndexMappings:Object = null;

		flvplayback_internal static var layoutNameArray:Array = [
			"pause_mc",
			"play_mc",
			"stop_mc",
			null, // seekBarHandle_mc
			null, // seekBarHit_mc
			"back_mc",
			"forward_mc",
			null, // fullScreenToggle_mc's on_mc
			null, // fullScreenToggle_mc's off_mc
			null, // volumeMute_mc's on_mc
			null, // volumeMute_mc's off_mc
			null, // volumeBarHandle_mc
			null, // volumeBarHit_mc
			"playpause_mc",
			"fullScreenToggle_mc",
			"volumeMute_mc",
			"bufferingBar_mc",
			"seekBar_mc",
			"volumeBar_mc",

			// these are for other avatar names that should be treated specially
			"seekBarHandle_mc",
			"seekBarHit_mc",
			"seekBarProgress_mc",
			"seekBarFullness_mc",
			"volumeBarHandle_mc",
			"volumeBarHit_mc",
			"volumeBarProgress_mc",
			"volumeBarFullness_mc",
			"progressFill_mc"
		];

		flvplayback_internal static var skinClassPrefixes:Array = [
			"pauseButton",
			"playButton",
			"stopButton",
			null, // seekBarHandle
			null, // seekBarHit
			"backButton",
			"forwardButton",
			"fullScreenButtonOn",
			"fullScreenButtonOff",
			"muteButtonOn",
			"muteButtonOff",
			null, // volumeBarHandle
			null, // volumeBarHit
			null, // playPause
			null, // fullScreenToggle
			null, // volumeMute
			"bufferingBar",
			"seekBar",
			"volumeBar"
		];

		flvplayback_internal static var customComponentClassNames:Array = [
			"PauseButton",
			"PlayButton",
			"StopButton",
			null, // seekBarHandle
			null, // seekBarHit
			"BackButton",
			"ForwardButton",
			null, // fullScreenButtonOn
			null, // fullScreenButtonOff
			null, // muteButtonOn
			null, // muteButtonOff
			null, // volumeBarHandle
			null, // volumeBarHit
			"PlayPauseButton",
			"FullScreenButton",
			"MuteButton",
			"BufferingBar",
			"SeekBar",
			"VolumeBar"
		];
			
		flvplayback_internal var hitTarget_mc:Sprite;
		public static const CAPTIONS_ON_BUTTON:Number = 28;
		public static const CAPTIONS_OFF_BUTTON:Number = 29;
		public static const SHOW_CONTROLS_BUTTON:Number = 30;
		public static const HIDE_CONTROLS_BUTTON:Number = 31;
		
		include "localization/AccessibilityPropertyNames.as"
		
		flvplayback_internal var startTabIndex:int;
		flvplayback_internal var endTabIndex:int;
		flvplayback_internal var focusRect:Boolean = true;
			
		/**
         * Constructor.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function UIManager(vc:FLVPlayback) {
			// init properties
			_vc = vc;
			_skin = null;
			_skinAutoHide = false;
			cacheSkinAutoHide = _skinAutoHide;
			_skinFadingMaxTime = SKIN_FADING_MAX_TIME_DEFAULT;
			_skinAutoHideMotionTimeout = SKIN_AUTO_HIDE_MOTION_TIMEOUT_DEFAULT;
			_skinReady = true;
			__visible = false;
			_bufferingBarHides = false;
			_controlsEnabled = true;
			_lastScrubPos = 0;
			_lastVolumePos = 0;
			cachedSoundLevel = _vc.volume;
			_isMuted = false;
			controls = new Array();
			customClips = null;
			ctrlDataDict = new Dictionary(true);
			skin_mc = null;
			skinLoader = null;
			skinTemplate = null;
			layout_mc = null;
			border_mc = null;
			borderCopy = null;
			borderPrevRect = null;
			borderScale9Rects = null;
			borderAlpha = 0.85;
			borderColor = 0x47ABCB;
			borderColorTransform = new ColorTransform(0, 0, 0, 0, 0x47, 0xAB, 0xCB, 0xFF * borderAlpha);
			_seekBarScrubTolerance = SEEK_BAR_SCRUB_TOLERANCE_DEFAULT;
			_volumeBarScrubTolerance = VOLUME_BAR_SCRUB_TOLERANCE_DEFAULT;
			_bufferingOn = false;
			mouseCaptureCtrl = -1;

			// setup timers
			_seekBarTimer = new Timer(SEEK_BAR_INTERVAL_DEFAULT);
			_seekBarTimer.addEventListener(TimerEvent.TIMER, seekBarListener);
			_volumeBarTimer = new Timer(VOLUME_BAR_INTERVAL_DEFAULT);
			_volumeBarTimer.addEventListener(TimerEvent.TIMER, volumeBarListener);
			_bufferingDelayTimer = new Timer(BUFFERING_DELAY_INTERVAL_DEFAULT, 1);
			_bufferingDelayTimer.addEventListener(TimerEvent.TIMER, doBufferingDelay);
			_skinAutoHideTimer = new Timer(SKIN_AUTO_HIDE_INTERVAL);
			_skinAutoHideTimer.addEventListener(TimerEvent.TIMER, skinAutoHideHitTest);
			_skinFadingTimer = new Timer(SKIN_FADING_INTERVAL);
			_skinFadingTimer.addEventListener(TimerEvent.TIMER, skinFadeMore);

			// listen to the FLVPlayback
			_vc.addEventListener(MetadataEvent.METADATA_RECEIVED, handleIVPEvent);
			_vc.addEventListener(VideoEvent.PLAYHEAD_UPDATE, handleIVPEvent);
			_vc.addEventListener(VideoProgressEvent.PROGRESS, handleIVPEvent);
			_vc.addEventListener(VideoEvent.STATE_CHANGE, handleIVPEvent);
			_vc.addEventListener(VideoEvent.READY, handleIVPEvent);
			_vc.addEventListener(LayoutEvent.LAYOUT, handleLayoutEvent);
			_vc.addEventListener(AutoLayoutEvent.AUTO_LAYOUT, handleLayoutEvent);
			_vc.addEventListener(SoundEvent.SOUND_UPDATE, handleSoundEvent);

			// listen for added to stage
			_vc.addEventListener(Event.ADDED_TO_STAGE, handleEvent);
			_vc.addEventListener(Event.REMOVED_FROM_STAGE, handleEvent);

			// listen for full screen
			fullScreenSourceRectMinWidth = FULL_SCREEN_SOURCE_RECT_MIN_WIDTH;
			fullScreenSourceRectMinHeight = FULL_SCREEN_SOURCE_RECT_MIN_HEIGHT;
			fullScreenSourceRectMinAspectRatio = FULL_SCREEN_SOURCE_RECT_MIN_WIDTH / FULL_SCREEN_SOURCE_RECT_MIN_HEIGHT;
			_fullScreen = false;
			_fullScreenTakeOver = true;
			_fullScreenBgColor = 0x000000;
			_fullScreenAccel = false;
			if (_vc.stage != null) {
				_vc.stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, handleMouseFocusChangeEvent);
				try {
					_fullScreen = (_vc.stage.displayState == StageDisplayState.FULL_SCREEN);
					_vc.stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenEvent);
				} catch (se:SecurityError) {
				}
			}

			if (layoutNameToIndexMappings == null) {
				initLayoutNameToIndexMappings();
			}
		}

		flvplayback_internal static function initLayoutNameToIndexMappings():void {
			layoutNameToIndexMappings = new Object();
			for (var i:int = 0; i < layoutNameArray.length; i++) {
				if ( layoutNameArray[i] != null ) {
					layoutNameToIndexMappings[layoutNameArray[i]] = i;
				}
			}
		}

		flvplayback_internal function handleFullScreenEvent(e:FullScreenEvent):void {
			_fullScreen = e.fullScreen;
			setEnabledAndVisibleForState(FULL_SCREEN_OFF_BUTTON, VideoState.PLAYING);
			skinButtonControl(controls[FULL_SCREEN_OFF_BUTTON]);
			setEnabledAndVisibleForState(FULL_SCREEN_ON_BUTTON, VideoState.PLAYING);
			skinButtonControl(controls[FULL_SCREEN_ON_BUTTON]);
			if (_fullScreen && _fullScreenTakeOver) {
				enterFullScreenTakeOver();
			} else if (!_fullScreen) {
				exitFullScreenTakeOver();
			}
		}

		flvplayback_internal function handleEvent(e:Event):void {
			switch (e.type) {
			case Event.ADDED_TO_STAGE:
				_fullScreen = false;
				if (_vc.stage != null) {
					try {
						_fullScreen = (_vc.stage.displayState == StageDisplayState.FULL_SCREEN);
						_vc.stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenEvent);
					} catch (se:SecurityError) {
					}
				}
				if (!_fullScreen) {
					_fullScreenAccel = false;
				}
				setEnabledAndVisibleForState(FULL_SCREEN_OFF_BUTTON, VideoState.PLAYING);
				skinButtonControl(controls[FULL_SCREEN_OFF_BUTTON]);
				setEnabledAndVisibleForState(FULL_SCREEN_ON_BUTTON, VideoState.PLAYING);
				skinButtonControl(controls[FULL_SCREEN_ON_BUTTON]);
				if (_fullScreen && _fullScreenTakeOver) {
					enterFullScreenTakeOver();
				} else if (!_fullScreen) {
					exitFullScreenTakeOver();
				}
				layoutSkin();
				setupSkinAutoHide(false);
				break;
			case Event.REMOVED_FROM_STAGE:
				_vc.stage.removeEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenEvent);
				break;
			}
		}

		flvplayback_internal function handleSoundEvent(e:SoundEvent):void {
			//ifdef DEBUG
			//debugTrace("handleSoundEvent :: " + e );
			//endif
			if (_isMuted && e.soundTransform.volume > 0) {
				_isMuted = false;
				setEnabledAndVisibleForState(MUTE_OFF_BUTTON, VideoState.PLAYING);
				skinButtonControl(controls[MUTE_OFF_BUTTON]);
				setEnabledAndVisibleForState(MUTE_ON_BUTTON, VideoState.PLAYING);
				skinButtonControl(controls[MUTE_ON_BUTTON]);
			}
			var ctrl:Sprite = controls[VOLUME_BAR];
			if (ctrl != null) {
				var ctrlData:ControlData = ctrlDataDict[ctrl];
				ctrlData.percentage = ((_isMuted) ? cachedSoundLevel : e.soundTransform.volume) * 100;
				if (ctrlData.percentage < 0) {
					ctrlData.percentage = 0;
				} else if (ctrlData.percentage > 100) {
					ctrlData.percentage = 100;
				}
				positionHandle(ctrl);
			}
		}

		flvplayback_internal function handleLayoutEvent(e:LayoutEvent):void {
			if (_fullScreen && _fullScreenTakeOver && _fullScreenAccel && _vc.stage != null) {
				// lots of thing will make us bail out of fullscreen mode...
				if ( _vc.registrationX != 0 ||_vc.registrationY != 0 ||
				     _vc.parent != _vc.stage ||
				     _vc.registrationWidth != _vc.stage.stageWidth ||
				     _vc.registrationHeight != _vc.stage.stageHeight ) {
					_vc.stage.displayState = StageDisplayState.NORMAL;
					return;
				}

				var cacheActiveIndex:int = _vc.activeVideoPlayerIndex;
				_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;
				// if the align is wrong, just fix it
				if (_vc.align != VideoAlign.CENTER) {
					cacheFLVPlaybackAlign[_vc.visibleVideoPlayerIndex] = _vc.align;
					_vc.align = VideoAlign.CENTER;
				}
				// if the scale mode is wrong, just fix it and see if it fixes the width and height problems
				if (_vc.scaleMode != VideoScaleMode.MAINTAIN_ASPECT_RATIO) {
					cacheFLVPlaybackScaleMode[_vc.visibleVideoPlayerIndex] = _vc.scaleMode;
					_vc.scaleMode = VideoScaleMode.MAINTAIN_ASPECT_RATIO;
					// return because this will be called again with the proper values
					_vc.activeVideoPlayerIndex = cacheActiveIndex;
					return;
				}
				_vc.activeVideoPlayerIndex = cacheActiveIndex;
			}

			layoutSkin();
			setupSkinAutoHide(false);
		}

		flvplayback_internal function handleIVPEvent(e:IVPEvent):void {
			// UI only handles events from visible player, must set it to active
			if (e.vp != _vc.visibleVideoPlayerIndex) return;

			// set activeVideoPlayerIndex to visibleVideoPlayerIndex
			var cachedActivePlayerIndex:uint = _vc.activeVideoPlayerIndex;
			_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

			var i:int;
			var ve:VideoEvent;
			var ctrl:Sprite;
			var ctrlData:ControlData;

			//ifdef DEBUG
			////debugTrace("handleIVPEvent :: " + e.type );
			//endif
			switch (e.type) {
			case VideoEvent.STATE_CHANGE:
				ve = VideoEvent(e);
				//ifdef DEBUG
				////debugTrace("state = " + ve.state);
				//endif
				if (ve.state == VideoState.BUFFERING) {
					if (!_bufferingOn) {
						_bufferingDelayTimer.reset();
						_bufferingDelayTimer.start();
					}
				} else {
					_bufferingDelayTimer.reset();
					_bufferingOn = false;
				}
				if (ve.state == VideoState.LOADING) {
					_progressPercent = (_vc.getVideoPlayer(e.vp).isRTMP) ? 100 : 0;
					for (i = SEEK_BAR; i <= VOLUME_BAR; i++) {
						ctrl = controls[i];
						if (controls[i] == null) continue;
						ctrlData = ctrlDataDict[ctrl];
						if (ctrlData.progress_mc != null) {
							positionBar(ctrl, "progress", _progressPercent);
						}
					}
				}
				for (i = 0; i < NUM_CONTROLS; i++) {
					if (controls[i] == undefined) continue;
					setEnabledAndVisibleForState(i, ve.state);
					if (i < NUM_BUTTONS) skinButtonControl(controls[i]);
				}
				break;
			case VideoEvent.READY:
			case MetadataEvent.METADATA_RECEIVED:
				for (i = 0; i < NUM_CONTROLS; i++) {
					if (controls[i] == undefined) continue;
					setEnabledAndVisibleForState(i, _vc.state);
					if (i < NUM_BUTTONS) skinButtonControl(controls[i]);
				}
				if (_vc.getVideoPlayer(e.vp).isRTMP) {
					_progressPercent = 100;
					for (i = SEEK_BAR; i <= VOLUME_BAR; i++) {
						ctrl = controls[i];
						if (ctrl == null) continue;
						ctrlData = ctrlDataDict[ctrl];
						if (ctrlData.progress_mc != null) {
							positionBar(ctrl, "progress", _progressPercent);
						}
					}
				}
				break;
			case VideoEvent.PLAYHEAD_UPDATE:
				// added a check to see if state is SEEKING to prevent the seek bar handle
				// from jerking back to its original position in the middle of a seek.
				// this was not always happening, but did occasionally, seemed like
				// more often on progressive download FLVs when seeking to a time
				// not too close to a keyframe.
				if ( controls[SEEK_BAR] != undefined && !_vc.isLive && !isNaN(_vc.totalTime) &&
				     (_vc.getVideoPlayer(_vc.visibleVideoPlayerIndex).state != VideoState.SEEKING) ) {
					ve = VideoEvent(e);
					var percentage:Number = ve.playheadTime / _vc.totalTime * 100;
					if (percentage < 0) {
						percentage = 0;
					} else if (percentage > 100) {
						percentage = 100;
					}
					ctrl = controls[SEEK_BAR];
					ctrlData = ctrlDataDict[ctrl];
					ctrlData.percentage = percentage;
					positionHandle(ctrl);
				}
				break;
			case VideoProgressEvent.PROGRESS:
				var vpe:VideoProgressEvent = VideoProgressEvent(e);
				_progressPercent = (vpe.bytesTotal <= 0) ? 100 : (vpe.bytesLoaded / vpe.bytesTotal * 100);
				var vpState:VideoPlayerState = _vc.videoPlayerStates[e.vp];
				var minProgressPercent:Number = vpState.minProgressPercent;
				if (!isNaN(minProgressPercent) && minProgressPercent > _progressPercent) {
					_progressPercent = minProgressPercent;
				}
				if (!isNaN(_vc.totalTime)) {
					var playheadPercent:Number = _vc.playheadTime / _vc.totalTime * 100;
					if (playheadPercent > _progressPercent) {
						_progressPercent = playheadPercent;
						vpState.minProgressPercent = _progressPercent;
					}
				}
				for (i = SEEK_BAR; i <= VOLUME_BAR; i++) {
					ctrl = controls[i];
					if (ctrl == null) continue;
					ctrlData = ctrlDataDict[ctrl];
					if (ctrlData.progress_mc != null) {
						positionBar(ctrl, "progress", _progressPercent);
					}
				}
				break;
			} // switch
			
			// set activeVideoPlayerIndex back to prev value
			_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
		}

		/**
		 * If true, we hide and disable certain controls when the
		 * buffering bar is displayed.  The seek bar will be hidden, the
		 * play, pause, play/pause, forward and back buttons would be
		 * disabled.  Default is false.  This only has effect if there
         * is a buffering bar control.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get bufferingBarHidesAndDisablesOthers():Boolean {
			return _bufferingBarHides;
		}
		public function set bufferingBarHidesAndDisablesOthers(b:Boolean):void {
			_bufferingBarHides = b;
		}

		public function get controlsEnabled():Boolean {
			return _controlsEnabled;
		}
		public function set controlsEnabled(flag:Boolean):void {
			if (_controlsEnabled == flag) return;
			_controlsEnabled = flag;
			for (var i:int = 0; i < NUM_BUTTONS; i++) {
				skinButtonControl(controls[i]);
			}
		}

		public function get fullScreenBackgroundColor():uint {
			return _fullScreenBgColor;
		}
		public function set fullScreenBackgroundColor(c:uint):void {
			if (_fullScreenBgColor != c) {
				_fullScreenBgColor = c;
				if (_vc) {
				}
			}
		}

		public function get fullScreenSkinDelay():int {
			return _skinAutoHideMotionTimeout;
		}
		public function set fullScreenSkinDelay(i:int):void {
			_skinAutoHideMotionTimeout = i;
		}

		public function get fullScreenTakeOver():Boolean {
			return _fullScreenTakeOver;
		}
		public function set fullScreenTakeOver(v:Boolean):void {
			if (_fullScreenTakeOver != v) {
				_fullScreenTakeOver = v;
				if (_fullScreenTakeOver) {
					enterFullScreenTakeOver();
				} else {
					if (_vc.stage != null && _fullScreen && _fullScreenAccel) {
						try {
							_vc.stage.displayState = StageDisplayState.NORMAL;
						} catch (se:SecurityError) {
						}
					}
					exitFullScreenTakeOver();
				}
			}
		}

		/**
		 * String URL of skin swf to download.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get skin():String {
			return _skin;
		}
		public function set skin(s:String):void {
			if (s == null) {
				removeSkin();
				_skin = null;
				_skinReady = true;
			} else {
				var paramStr:String = String(s);
				if (s == _skin) return;
				removeSkin();
				_skin = String(s);
				_skinReady = (_skin == "");
				if (!_skinReady) {
					downloadSkin();
				}
			}
		}

		public function get skinAutoHide():Boolean {
			return _skinAutoHide;
		}
		public function set skinAutoHide(b:Boolean):void {
			if (b == _skinAutoHide) return;
			_skinAutoHide = b;
			cacheSkinAutoHide = b;
			setupSkinAutoHide(true);
		}

		public function get skinBackgroundAlpha():Number {
			return borderAlpha;
		}
		public function set skinBackgroundAlpha(a:Number):void {
			if (borderAlpha != a) {
				borderAlpha = a;
				borderColorTransform.alphaOffset = (255 * a);
				borderPrevRect = null; // forces a redraw
				layoutSkin();
			}
		}

		public function get skinBackgroundColor():uint {
			return borderColor;
		}
		public function set skinBackgroundColor(c:uint):void {
			if (borderColor != c) {
				borderColor = c;
				borderColorTransform.redOffset = ((borderColor >> 16) & 0xFF);
				borderColorTransform.greenOffset = ((borderColor >> 8) & 0xFF);
				borderColorTransform.blueOffset = (borderColor & 0xFF);
				borderPrevRect = null; // forces a redraw
				layoutSkin();
			}
		}

		public function get skinFadeTime():int {
			return _skinFadingMaxTime;
		}
		public function set skinFadeTime(i:int):void {
			_skinFadingMaxTime = i;
		}

		public function get skinReady():Boolean {
			return _skinReady;
		}

		/**
		 * Determines how often check the seek bar handle location when
		 * scubbing, in milliseconds.
         *
         * @default 250
		 * 
		 * @see #SEEK_BAR_INTERVAL_DEFAULT
		 */
		public function get seekBarInterval():Number {
			return _seekBarTimer.delay;
		}
		public function set seekBarInterval(s:Number):void {
			if (_seekBarTimer.delay == s) return;
			_seekBarTimer.delay = s;
		}
		
		/**
		 * Determines how often check the volume bar handle location when
		 * scubbing, in milliseconds.
         *
         * @default 250
		 * 
         * @see #VOLUME_BAR_INTERVAL_DEFAULT
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get volumeBarInterval():Number {
			return _volumeBarTimer.delay;
		}
		public function set volumeBarInterval(s:Number):void {
			if (_volumeBarTimer.delay == s) return;
			_volumeBarTimer.delay = s;
		}
		
		/**
		 * Determines how long after VideoState.BUFFERING state entered
		 * we disable controls for buffering.  This delay is put into
		 * place to avoid annoying rapid switching between states.
         *
		 * @default 1000
		 * 
         * @see #BUFFERING_DELAY_INTERVAL_DEFAULT
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get bufferingDelayInterval():Number {
			return _bufferingDelayTimer.delay;
		}
		public function set bufferingDelayInterval(s:Number):void {
			if (_bufferingDelayTimer.delay == s) return;
			_bufferingDelayTimer.delay = s;
		}

		/**
		 * Determines how far user can move scrub bar before an update
		 * will occur.  Specified in percentage from 1 to 100.  Set to 0
		 * to indicate no scrub tolerance--always update volume on
		 * volumeBarInterval regardless of how far user has moved handle.
         *
         * @default 0
		 *
         * @see #VOLUME_BAR_SCRUB_TOLERANCE_DEFAULT
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get volumeBarScrubTolerance():Number {
			return _volumeBarScrubTolerance;
		}
		public function set volumeBarScrubTolerance(s:Number):void {
			_volumeBarScrubTolerance = s;
		}
		

		/**
		 * <p>Determines how far user can move scrub bar before an update
		 * will occur.  Specified in percentage from 1 to 100.  Set to 0
		 * to indicate no scrub tolerance--always update position on
		 * seekBarInterval regardless of how far user has moved handle.
		 * Default is 5.</p>
		 *
         * @see #SEEK_BAR_SCRUB_TOLERANCE_DEFAULT
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get seekBarScrubTolerance():Number {
			return _seekBarScrubTolerance;
		}
		public function set seekBarScrubTolerance(s:Number):void {
			_seekBarScrubTolerance = s;
		}

		/**
		 * controls max amount that we will allow skin to scale
		 * up due to full screen video hardware acceleration
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get skinScaleMaximum():Number {
			return _skinScaleMaximum;
		}
		public function set skinScaleMaximum(value:Number):void {
			_skinScaleMaximum = value;
		}

		/**
		 * whether or not skin swf controls
         * should be shown or hidden
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get visible():Boolean {
			return __visible;
		}
		public function set visible(v:Boolean):void {
			if (__visible == v) return;
			__visible = v;
			if (!__visible) {
				skin_mc.visible = false;
			} else {
				setupSkinAutoHide(false);
			}
		}

		public function getControl(index:int):Sprite {
			return controls[index];
		}

		public function setControl(index:int, ctrl:Sprite):void {
			//ifdef DEBUG
			//debugTrace("setControl(" + index + ", " + ctrl + ")");
			//endif
			// do nothing if the same
			if (ctrl == controls[index]) return;
			// If IFocusManagerComponent is active, toggling tabEnabled will force 
			// the FocusManager to recognize the control as a focusable object.
			if(ctrl){
				ctrl.tabEnabled = false;
			}
			// for some controls, extra stuff we do to keep connections correct
			switch (index) {
			case PAUSE_BUTTON:
			case PLAY_BUTTON:
				resetPlayPause();
				break;
			case PLAY_PAUSE_BUTTON:
				if (ctrl == null || ctrl.parent != skin_mc) {
					resetPlayPause();
				}
				if (ctrl != null) {
					setControl(PAUSE_BUTTON, Sprite(ctrl.getChildByName("pause_mc")));
					setControl(PLAY_BUTTON, Sprite(ctrl.getChildByName("play_mc")));
				}
				break;
			case FULL_SCREEN_BUTTON:
				if (ctrl != null) {
					setControl(FULL_SCREEN_ON_BUTTON, Sprite(ctrl.getChildByName("on_mc")));
					setControl(FULL_SCREEN_OFF_BUTTON, Sprite(ctrl.getChildByName("off_mc")));
				}
				break;
			case MUTE_BUTTON:
				if (ctrl != null) {
					setControl(MUTE_ON_BUTTON, Sprite(ctrl.getChildByName("on_mc")));
					setControl(MUTE_OFF_BUTTON, Sprite(ctrl.getChildByName("off_mc")));
				}
				break;
			} // switch

			// remove entry for previously registered control
			if (controls[index] != null) {
				try {
					delete controls[index]["uiMgr"];
				} catch (re:ReferenceError) {
				}
				if (index < NUM_BUTTONS) {
					removeButtonListeners(controls[index]);
				}
				delete ctrlDataDict[controls[index]];
				delete controls[index];
			}

			// if null passed in for control, then stop here
			if (ctrl == null) {
				return;
			}

			// create new ControlData struct for new control
			var ctrlData:ControlData = ctrlDataDict[ctrl];
			if (ctrlData == null) {
				ctrlData = new ControlData(this, ctrl, null, index);
				ctrlDataDict[ctrl] = ctrlData;
			} else {
				ctrlData.index = index;
			}

			if (index >= NUM_BUTTONS) {
				controls[index] = ctrl;
				switch (index) {
				case SEEK_BAR:
					addBarControl(ctrl);
					break;
				case VOLUME_BAR:
					addBarControl(ctrl);
					ctrlData.percentage = _vc.volume * 100;
					break;
				case BUFFERING_BAR:
					// do right away if from loaded swf, wait to give time for
					// initialization if control defined in this swf
					if (ctrl.parent == skin_mc) {
						finishAddBufferingBar();
					} else {
						ctrl.addEventListener(Event.ENTER_FRAME, finishAddBufferingBar);
					}
					break;
				} // switch
				setEnabledAndVisibleForState(index, _vc.state);
			} else {
				controls[index] = ctrl;
				addButtonControl(ctrl);
			}
		}

		flvplayback_internal function resetPlayPause():void {
			if (controls[PLAY_PAUSE_BUTTON] == undefined) return;
			for (var i:int = PAUSE_BUTTON; i <= PLAY_BUTTON; i++) {
				removeButtonListeners(controls[i]);
				delete ctrlDataDict[controls[i]];
				delete controls[i];
			}
			delete ctrlDataDict[controls[PLAY_PAUSE_BUTTON]];
			delete controls[PLAY_PAUSE_BUTTON];
		}

		flvplayback_internal function addButtonControl(ctrl:Sprite):void {
			if (ctrl == null) return;
			var ctrlData:ControlData = ctrlDataDict[ctrl];

			ctrl.buttonMode = true;
			ctrl.tabEnabled = true;
			ctrl.tabChildren = true;
			ctrl.focusRect = focusRect;
			ctrl.accessibilityProperties = new AccessibilityProperties();
			ctrl.accessibilityProperties.forceSimple = true;
			ctrl.accessibilityProperties.silent = true;
			if(accessibilityPropertyNames[ctrlData.index]!=null) {
				ctrl.accessibilityProperties.name = accessibilityPropertyNames[ctrlData.index];
				ctrl.accessibilityProperties.silent = false;
				
			}
			if(ctrlData.index == VOLUME_BAR_HIT || ctrlData.index == SEEK_BAR_HIT ){
				ctrl.buttonMode = false;
				ctrl.tabEnabled = false;
				ctrl.tabChildren = false;
				ctrl.focusRect = false;
				ctrl.accessibilityProperties.silent = true;
			}
			if(ctrlData.index == VOLUME_BAR_HANDLE || ctrlData.index == SEEK_BAR_HANDLE){
				// added to make the FlashPlayer's default tab order work in skins by adjusting heights of VOLUME_BAR_HANDLE and SEEK_BAR_HANDLE
				ctrl.graphics.moveTo(0,-18);
				ctrl.graphics.lineStyle(0,0,0);
				ctrl.graphics.lineTo(0, -18);
				ctrl.buttonMode = false;
				ctrl.focusRect = true;
				ctrl.accessibilityProperties.silent = false;
				configureBarAccessibility(ctrlData.index);
			}

			// all mouse events go to Sprite wrapper, not to skin assets within the Sprite
			ctrl.mouseChildren = false;

			// set activeVideoPlayerIndex to visibleVideoPlayerIndex
			var cachedActivePlayerIndex:int = _vc.activeVideoPlayerIndex;
			_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

			ctrlData.state = NORMAL_STATE;
			setEnabledAndVisibleForState(ctrlData.index, _vc.state);
			ctrl.addEventListener(MouseEvent.ROLL_OVER, handleButtonEvent);
			ctrl.addEventListener(MouseEvent.ROLL_OUT, handleButtonEvent);
			ctrl.addEventListener(MouseEvent.MOUSE_DOWN, handleButtonEvent);
			ctrl.addEventListener(MouseEvent.CLICK, handleButtonEvent);

			// add keyboard and focus event listeners
			ctrl.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyEvent);
			ctrl.addEventListener(KeyboardEvent.KEY_UP, handleKeyEvent);
			ctrl.addEventListener(FocusEvent.FOCUS_IN, handleFocusEvent);
			ctrl.addEventListener(FocusEvent.FOCUS_OUT, handleFocusEvent);

			// do right away if from loaded swf, wait to give time for
			// initialization if control defined in this swf
			if (ctrl.parent == skin_mc) {
				skinButtonControl(ctrl);
			} else {
				ctrl.addEventListener(Event.ENTER_FRAME, skinButtonControl);
			}

			// set activeVideoPlayerIndex back to prev value
			_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
		}

		flvplayback_internal function handleButtonEvent(e:MouseEvent):void {
			var ctrlData:ControlData = ctrlDataDict[e.currentTarget];
			switch (e.type) {
			case MouseEvent.ROLL_OVER:
				ctrlData.state = OVER_STATE;
				break;
			case MouseEvent.ROLL_OUT:
				ctrlData.state = NORMAL_STATE;
				break;
			case MouseEvent.MOUSE_DOWN:
				ctrlData.state = DOWN_STATE;
				mouseCaptureCtrl = ctrlData.index;
				switch (mouseCaptureCtrl) {
				case SEEK_BAR_HANDLE:
				case SEEK_BAR_HIT:
				case VOLUME_BAR_HANDLE:
				case VOLUME_BAR_HIT:
					dispatchMessage(ctrlData.index);
					break;
				} // switch

				// try to add listeners to stage, then do it to root
				// instead if there is a SecurityError
				var topLevel:DisplayObject = _vc.stage;
				try {
					topLevel.addEventListener(MouseEvent.MOUSE_DOWN, captureMouseEvent, true);
				} catch (se:SecurityError) {
					topLevel = _vc.root;
					topLevel.addEventListener(MouseEvent.MOUSE_DOWN, captureMouseEvent, true);
				}
				topLevel.addEventListener(MouseEvent.MOUSE_OUT, captureMouseEvent, true);
				topLevel.addEventListener(MouseEvent.MOUSE_OVER, captureMouseEvent, true);
				topLevel.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
				topLevel.addEventListener(MouseEvent.ROLL_OUT, captureMouseEvent, true);
				topLevel.addEventListener(MouseEvent.ROLL_OVER, captureMouseEvent, true);
				break;
			case MouseEvent.CLICK:
				switch (mouseCaptureCtrl) {
				case SEEK_BAR_HANDLE:
				case SEEK_BAR_HIT:
				case VOLUME_BAR_HANDLE:
				case VOLUME_BAR_HIT:
				// capture FULL_SCREEN_BUTTON events using MOUSE_UP to prevent SecurityError 
				// when activated from a keyboard event
				case FULL_SCREEN_OFF_BUTTON:
				case FULL_SCREEN_ON_BUTTON:
					// do nothing, handled by handleMouseUp()
					break;
				default:
					dispatchMessage(ctrlData.index);
					break;
				} // switch
				// return instead of break, we are already skinned
				// by handleMouseUp()
				return;
			} // switch
			skinButtonControl(e.currentTarget);
		}

		flvplayback_internal function captureMouseEvent(e:MouseEvent):void {
			//ifdef DEBUG
			////debugTrace("capturing mouse event " + e.type);
			//endif
			e.stopPropagation();
		}

		flvplayback_internal function handleMouseUp(e:MouseEvent):void {
			//ifdef DEBUG
			////debugTrace("handleMouseUp()");
			//endif
			// revert skin to up state
			var ctrl:Sprite = controls[mouseCaptureCtrl];
			if (ctrl != null) {
				var ctrlData:ControlData = ctrlDataDict[ctrl];
				ctrlData.state = (ctrl.hitTestPoint(e.stageX, e.stageY, true) ? OVER_STATE : NORMAL_STATE);
				skinButtonControl(ctrl);

				switch (mouseCaptureCtrl) {
				case SEEK_BAR_HANDLE:
				case SEEK_BAR_HIT:
					handleRelease(SEEK_BAR);
					break;
				case VOLUME_BAR_HANDLE:
				case VOLUME_BAR_HIT:
					handleRelease(VOLUME_BAR);
					break;
				case FULL_SCREEN_OFF_BUTTON:
				case FULL_SCREEN_ON_BUTTON:
					dispatchMessage(ctrlData.index);
					break;
				}
			}

			// remove listeners
			e.currentTarget.removeEventListener(MouseEvent.MOUSE_DOWN, captureMouseEvent, true);
			e.currentTarget.removeEventListener(MouseEvent.MOUSE_OUT, captureMouseEvent, true);
			e.currentTarget.removeEventListener(MouseEvent.MOUSE_OVER, captureMouseEvent, true);
			e.currentTarget.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			e.currentTarget.removeEventListener(MouseEvent.ROLL_OUT, captureMouseEvent, true);
			e.currentTarget.removeEventListener(MouseEvent.ROLL_OVER, captureMouseEvent, true);
		}

		flvplayback_internal function removeButtonListeners(ctrl:Sprite):void {
			if (ctrl == null) return;
			ctrl.removeEventListener(MouseEvent.ROLL_OVER, handleButtonEvent);
			ctrl.removeEventListener(MouseEvent.ROLL_OUT, handleButtonEvent);
			ctrl.removeEventListener(MouseEvent.MOUSE_DOWN, handleButtonEvent);
			ctrl.removeEventListener(MouseEvent.CLICK, handleButtonEvent);
			ctrl.removeEventListener(Event.ENTER_FRAME, skinButtonControl);
		}

		/**
		 * start download of skin swf, called when skin property set.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function downloadSkin():void {
			if (skinLoader == null) {
				skinLoader = new Loader();
				skinLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoad);
				skinLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoadErrorEvent);
				skinLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadErrorEvent);
			}
			skinLoader.load(new URLRequest(_skin));
		}

		/**
         * Loader event handler function
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function handleLoadErrorEvent(e:ErrorEvent):void {
			_skinReady = true;
			_vc.skinError(e.toString());
		}

		/**
         * Loader event handler function
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function handleLoad(e:Event):void {
			try {
				// create skin sprite
				skin_mc = new Sprite();

				// if this is triggered by an event, then we need to grab
				// the skinTemplate from the loader
				if (e != null) {
					skinTemplate = Sprite(skinLoader.content);
				}

				layout_mc = skinTemplate;

				customClips = new Array();
				delayedControls = new Array();

				// iterate over layout_mc, creating clips as necessary
				for (var i:int = 0; i < layout_mc.numChildren; i++) {
					var dispObj:DisplayObject = layout_mc.getChildAt(i);
					var index:Number = layoutNameToIndexMappings[dispObj.name];
					if (!isNaN(index)) {
						setSkin(int(index), dispObj);
					} else if (dispObj.name != "video_mc") {
						setCustomClip(dispObj);
					}
				} // for

				// we need to wait a frame for all newly created objects to initialize,
				// then we can finish the layout, etc.
				skinLoadDelayCount = 0;
				_vc.addEventListener(Event.ENTER_FRAME, finishLoad);

			} catch (err:Error) {
				//ifdef DEBUG
				//debugTrace("skin handleLoad error: " + err + " : " + err.getStackTrace());
				//endif
				_vc.skinError(err.message);
				removeSkin();
			}
		}

		flvplayback_internal function finishLoad(e:Event):void {
			try {
				//ifdef DEBUG
				//debugTrace("finishLoad()");
				//endif

				skinLoadDelayCount++;
				if (skinLoadDelayCount < 2) {
					return;
				} else {
					_vc.removeEventListener(Event.ENTER_FRAME, finishLoad);
				}
				
				// check whether the FlashPlayer's default yellow focusRect 
				// should be active for FLVPlayback controls
				focusRect = isFocusRectActive();
				
				// do all the setControl calls which we delayed
				for (var i:int = 0; i < NUM_CONTROLS; i++) {
					if (delayedControls[i] != undefined) {
						setControl(i, delayedControls[i]);
					}
				}

				// go into full screen takeover mode if appropriate
				if (_fullScreenTakeOver) {
					enterFullScreenTakeOver();
				} else {
					exitFullScreenTakeOver();
				}

				// layout all the clips and controls
				layoutSkin();
				setupSkinAutoHide(false);
				skin_mc.visible = __visible;
				_vc.addChild(skin_mc);

				_skinReady = true;
				_vc.skinLoaded();

				// set activeVideoPlayerIndex to visibleVideoPlayerIndex
				var cachedActivePlayerIndex:int = _vc.activeVideoPlayerIndex;
				_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

				// set enabledness for current state
				var state:String = _vc.state;
				for (var j:int = 0; j < NUM_CONTROLS; j++) {
					if (controls[j] == undefined) continue;
					setEnabledAndVisibleForState(j, state);
					if (j < NUM_BUTTONS) skinButtonControl(controls[j]);
				}

				// set activeVideoPlayerIndex back to prev value
				_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
				
			} catch (err:Error) {
				//ifdef DEBUG
				//debugTrace("skin finishLoad error: " + err + " : " + err.getStackTrace());
				//endif
				_vc.skinError(err.message);
				removeSkin();
			}
		}

		/**
		 * layout all controls from loaded swf
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function layoutSkin():void {
			// sanity check
			if (layout_mc == null) return;

			// we haven't done the first layout yet, so return
			if (skinLoadDelayCount < 2) return;

			// get bounds of placeholder
			var video_mc:DisplayObject = layout_mc["video_mc"];
			if (video_mc == null) throw new Error("No layout_mc.video_mc");
			placeholderLeft = video_mc.x;
			placeholderRight = video_mc.x + video_mc.width;
			placeholderTop = video_mc.y;
			placeholderBottom = video_mc.y + video_mc.height;

			// get bounds of real video
			videoLeft = _vc.x - _vc.registrationX;
			videoRight = videoLeft + _vc.width;
			videoTop = _vc.y - _vc.registrationY;
			videoBottom = videoTop + _vc.height;

			// special logic for keeping skin on screen in fullscreen mode
			if (_fullScreen && _fullScreenTakeOver && border_mc != null) {
				var borderRect:Rectangle = calcLayoutControl(border_mc);
				var forceSkinAutoHide:Boolean = false;
				if (borderRect.width > 0 && borderRect.height > 0) {
					if (borderRect.x < 0) {
						placeholderLeft += (videoLeft - borderRect.x)
						forceSkinAutoHide = true;
					}
					if (borderRect.x + borderRect.width >  _vc.registrationWidth) {
						placeholderRight += ((borderRect.x + borderRect.width) - videoRight);
						forceSkinAutoHide = true;
					}
					if (borderRect.y < 0) {
						placeholderTop += (videoTop - borderRect.y)
						forceSkinAutoHide = true;
					}
					if (borderRect.y + borderRect.height >  _vc.registrationHeight) {
						placeholderBottom += ((borderRect.y + borderRect.height) - videoBottom);
						forceSkinAutoHide = true;
					}
					if (forceSkinAutoHide) {
						_skinAutoHide = true;
						setupSkinAutoHide(true);
					}
				}
			}

			// do not go below min dimensions
			try {
				if (!isNaN(layout_mc["minWidth"])) {
					var minWidth:Number = layout_mc["minWidth"];
					var vidWidth:Number = videoRight - videoLeft;
					if (minWidth > 0 && minWidth > vidWidth) {
						videoLeft -= ((minWidth - vidWidth) / 2);
						videoRight = minWidth + videoLeft;
					}
				}
			} catch (re1:ReferenceError) {
			}
			try {
				if (!isNaN(layout_mc["minHeight"])) {
					var minHeight:Number = layout_mc["minHeight"];
					var vidHeight:Number = videoBottom - videoTop;
					if (minHeight > 0 && minHeight > vidHeight) {
						videoTop -= ((minHeight - vidHeight) / 2);
						videoBottom = minHeight + videoTop;
					}
				}
			} catch (re2:ReferenceError) {
			}

			// iterate over customClips
			var i:int;
			for (i = 0; i < customClips.length; i++) {
				layoutControl(customClips[i]);
				if (customClips[i] == border_mc) {
					bitmapCopyBorder();
				}
			}
			// iterate over controls
			for (i = 0; i < NUM_CONTROLS; i++) {
				layoutControl(controls[i]);
			}
		}

		/**
         * layout and recolor border_mc, via borderCopy filled with Bitmaps
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function bitmapCopyBorder():void {
			if (border_mc == null || borderCopy == null) return;
			var newBorderRect:Rectangle = border_mc.getBounds(skin_mc);
			if (borderPrevRect == null || !borderPrevRect.equals(newBorderRect)) {
				borderCopy.x = newBorderRect.x;
				borderCopy.y = newBorderRect.y;
				var newBitmapData:BitmapData;
				var drawMatrix:Matrix = new Matrix(border_mc.scaleX, 0, 0, border_mc.scaleY, 0, 0);
				if (borderScale9Rects == null) {
					newBitmapData = new BitmapData(newBorderRect.width, newBorderRect.height, true, 0x000000);
					newBitmapData.draw(border_mc, drawMatrix, borderColorTransform);
					Bitmap(borderCopy.getChildAt(0)).bitmapData = newBitmapData;
				} else {
					// doing scale 9!  Walk through the rects 0 thru 8, going left
					// to right, then top to bottom
					var nextX:Number = 0;
					var nextY:Number = 0;
					var maskRect:Rectangle = new Rectangle(0, 0, 0, 0);
					var childIndex:int = 0;
					// first calculate the width and height of the unscaled sections
					var noScaleWidth:Number = 0;
					if (borderScale9Rects[3] != null) {
						noScaleWidth += borderScale9Rects[3].width;
					}
					if (borderScale9Rects[5] != null) {
						noScaleWidth += borderScale9Rects[5].width;
					}
					var noScaleHeight:Number = 0;
					if (borderScale9Rects[1] != null) {
						noScaleHeight += borderScale9Rects[1].height;
					}
					if (borderScale9Rects[7] != null) {
						noScaleHeight += borderScale9Rects[7].height;
					}
					for (var i:int = 0; i < borderScale9Rects.length; i++) {
						// move nextX back to the beginning on every row, move nextY down
						if (i % 3 == 0) {
							nextX = 0;
							nextY += maskRect.height;
						}
						if (borderScale9Rects[i] == null) {
							continue;
						}
						// setup horiz masking and scaling
						maskRect = Rectangle(borderScale9Rects[i]).clone();
						drawMatrix.a = 1;
						if (i == 1 || i == 4 || i == 7) {
							var middleScaleX:Number = (newBorderRect.width - noScaleWidth) / maskRect.width;
							maskRect.x *= middleScaleX;
							maskRect.width *= middleScaleX;
							maskRect.width = Math.round(maskRect.width);
							drawMatrix.a *= middleScaleX;
						}
						drawMatrix.tx = -(maskRect.x);
						maskRect.x = 0;
						// setup vert masking and scaling
						drawMatrix.d = 1;
						if (i >= 3 && i <= 5) {
							var middleScaleY:Number = (newBorderRect.height - noScaleHeight) / maskRect.height;
							maskRect.y *= middleScaleY;
							maskRect.height *= middleScaleY;
							maskRect.height = Math.round(maskRect.height);
							drawMatrix.d *= middleScaleY;
						}
						drawMatrix.ty = -(maskRect.y);
						maskRect.y = 0;
						// create the new BitmapData and draw to it using the mask for this square
						newBitmapData = new BitmapData(maskRect.width, maskRect.height, true, 0x000000);
						newBitmapData.draw(border_mc, drawMatrix, borderColorTransform, null, maskRect, false);
						// pass BitmapData to corresponding Bitmap on stage
						var nextBitmap:Bitmap = Bitmap(borderCopy.getChildAt(childIndex));
						childIndex++;
						nextBitmap.bitmapData = newBitmapData;
						// set the proper x and y for each Bitmap
						nextBitmap.x = nextX;
						nextBitmap.y = nextY;
						// move nextX and nextY forward for next iteration
						nextX += maskRect.width;
					}
				}
				borderPrevRect = newBorderRect;
			}
		}

		/**
		 * layout individual control from loaded swf
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function layoutControl(ctrl:DisplayObject):void {
			//ifdef DEBUG
			//debugTrace("layoutControl(" + ctrl + ")");
			//endif
			if (ctrl == null) return;
			var ctrlData:ControlData = ctrlDataDict[ctrl];
			if (ctrlData == null) return;
			if (ctrlData.avatar == null) return;

			var rect:Rectangle = calcLayoutControl(ctrl);
			ctrl.x = rect.x;
			ctrl.y = rect.y;
			ctrl.width = rect.width;
			ctrl.height = rect.height;

			switch (ctrlData.index) {
			case SEEK_BAR:
			case VOLUME_BAR:
				if (ctrlData.hit_mc != null && ctrlData.hit_mc.parent == skin_mc) {
					var hit_mc:Sprite = ctrlData.hit_mc;
					var hitRect:Rectangle = calcLayoutControl(hit_mc);
					hit_mc.x = hitRect.x;
					hit_mc.y = hitRect.y;
					hit_mc.width = hitRect.width;
					hit_mc.height = hitRect.height;
				}
				if (ctrlData.progress_mc != null) {
					if (isNaN(_progressPercent)) {
						_progressPercent = (_vc.isRTMP ? 100 : 0);
					}
					positionBar(Sprite(ctrl), "progress", _progressPercent);
				}
				positionHandle(Sprite(ctrl));
				break;
			case BUFFERING_BAR:
				positionMaskedFill(ctrl, 100);
				break;
			}
		}

		/**
		 * layout individual control from loaded swf
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function calcLayoutControl(ctrl:DisplayObject):Rectangle {
			//ifdef DEBUG
			//debugTrace("calcayoutControl(" + ctrl + ")");
			//endif
			var rect:Rectangle = new Rectangle();
			if (ctrl == null) return rect;
			var ctrlData:ControlData = ctrlDataDict[ctrl];
			if (ctrlData == null) return rect;
			if (ctrlData.avatar == null) return rect;

			var anchorRight:Boolean = false;
			var anchorLeft:Boolean = true;
			var anchorTop:Boolean = false;
			var anchorBottom:Boolean = true;

			try {
				anchorRight = ctrlData.avatar["anchorRight"];
			} catch (re1:ReferenceError) {
				anchorRight = false;
			}
			try {
				anchorLeft = ctrlData.avatar["anchorLeft"];
			} catch (re1:ReferenceError) {
				anchorLeft = true;
			}
			try {
				anchorTop = ctrlData.avatar["anchorTop"];
			} catch (re1:ReferenceError) {
				anchorTop = false;
			}
			try {
				anchorBottom = ctrlData.avatar["anchorBottom"];
			} catch (re1:ReferenceError) {
				anchorBottom = true;
			}

			if (anchorRight) {
				if (anchorLeft) {
					rect.x = ctrlData.avatar.x - placeholderLeft + videoLeft;
					rect.width = ctrlData.avatar.x + ctrlData.avatar.width - placeholderRight + videoRight - rect.x;
					ctrlData.origWidth = NaN;
				} else {
					rect.x = ctrlData.avatar.x - placeholderRight + videoRight;
					rect.width = ctrl.width;
				}
			} else {
				rect.x = ctrlData.avatar.x - placeholderLeft + videoLeft;
				rect.width = ctrl.width;
			}
			if (anchorTop) {
				if (anchorBottom) {
					rect.y = ctrlData.avatar.y - placeholderTop + videoTop;
					rect.height = ctrlData.avatar.y + ctrlData.avatar.height - placeholderBottom + videoBottom - rect.y;
					ctrlData.origHeight = NaN;

				} else {
					rect.y = ctrlData.avatar.y - placeholderTop + videoTop;
					rect.height = ctrl.height;
				}
			} else {
				rect.y = ctrlData.avatar.y - placeholderBottom + videoBottom;
				rect.height = ctrl.height;
			}

			// optional callback
			try {
				if (ctrl["layoutSelf"] is Function) {
					rect = ctrl["layoutSelf"](rect);
				}
			} catch (re3:ReferenceError) {
			}

			return rect;
		}

		/**
		 * remove controls from prev skin swf
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function removeSkin():void {
			//ifdef DEBUG
			//debugTrace("removeSkin()");
			//endif
			if (skinLoader != null) {
				try {
					skinLoader.close();
				} catch (e1:Error) {
				}
				skinLoader = null;
			}
			if (skin_mc != null) {
				for (var i:int = 0; i < NUM_CONTROLS; i++) {
					if (controls[i] == undefined) continue;
					if (i < NUM_BUTTONS) removeButtonListeners(controls[i]);
					delete ctrlDataDict[controls[i]];
					delete controls[i];
				}
				try {
					skin_mc.parent.removeChild(skin_mc);
				} catch (e2:Error) {
				}
				skin_mc = null;
			}
			skinTemplate = null;
			layout_mc = null;
			border_mc = null;
			borderCopy = null;
			borderPrevRect = null;
			borderScale9Rects = null;
		}

		/**
		 * set custom clip from loaded swf
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function setCustomClip(dispObj:DisplayObject):void {
			var dCopy:DisplayObject = new dispObj["constructor"]();
			skin_mc.addChild(dCopy);
			var ctrlData:ControlData = new ControlData(this, dCopy, null, -1);
			ctrlDataDict[dCopy] = ctrlData;
			ctrlData.avatar = dispObj;
			customClips.push(dCopy);

			dCopy.accessibilityProperties = new AccessibilityProperties();
			dCopy.accessibilityProperties.silent = true;

			// special instance name given to clip to be used as hit
			// test for skin autohide
			if (dispObj.name == "border_mc") {
				border_mc = dCopy;
				try {
					borderCopy = (ctrlData.avatar["colorMe"]) ? new Sprite() : null;
				} catch (re:ReferenceError) {
					borderCopy = null;
				}
				if (borderCopy != null) {
					border_mc.visible = false;
					var scale9Grid:Rectangle = border_mc.scale9Grid;
					// fix the grid to be even pixel values always
					scale9Grid.x = Math.round(scale9Grid.x);
					scale9Grid.y = Math.round(scale9Grid.y);
					scale9Grid.width = Math.round(scale9Grid.width);
					var diff:Number = scale9Grid.x + scale9Grid.width - border_mc.scale9Grid.right;
					if (diff > .5) {
						scale9Grid.width--;
					} else if (diff < -.5) {
						scale9Grid.width++;
					}
					scale9Grid.height = Math.round(scale9Grid.height);
					diff = scale9Grid.y + scale9Grid.height - border_mc.scale9Grid.bottom;
					if (diff > .5) {
						scale9Grid.height--;
					} else if (diff < -.5) {
						scale9Grid.height++;
					}
					if (scale9Grid != null) {
						borderScale9Rects = new Array();
						var lastXDim:Number = border_mc.width - (scale9Grid.x + scale9Grid.width);
						var floorLastXDim:Number = Math.floor(lastXDim);
						if (lastXDim - floorLastXDim < .05) {
							lastXDim = floorLastXDim;
						} else {
							lastXDim = floorLastXDim + 1;
						}
						var lastYDim:Number = border_mc.height - (scale9Grid.y + scale9Grid.height);
						var floorLastYDim:Number = Math.floor(lastYDim);
						if (lastYDim - floorLastYDim < .05) {
							lastYDim = floorLastYDim;
						} else {
							lastYDim = floorLastYDim + 1;
						}
						var newRect:Rectangle = new Rectangle(0, 0, scale9Grid.x, scale9Grid.y);
						borderScale9Rects.push((newRect.width < 1 || newRect.height < 1) ? null : newRect);
						newRect = new Rectangle(scale9Grid.x, 0, scale9Grid.width, scale9Grid.y);
						borderScale9Rects.push((newRect.width < 1 || newRect.height < 1) ? null : newRect);
						newRect = new Rectangle(scale9Grid.x + scale9Grid.width, 0, lastXDim, scale9Grid.y);
						borderScale9Rects.push((newRect.width < 1 || newRect.height < 1) ? null : newRect);
						newRect = new Rectangle(0, scale9Grid.y, scale9Grid.x, scale9Grid.height);
						borderScale9Rects.push((newRect.width < 1 || newRect.height < 1) ? null : newRect);
						newRect = new Rectangle(scale9Grid.x, scale9Grid.y, scale9Grid.width, scale9Grid.height);
						borderScale9Rects.push((newRect.width < 1 || newRect.height < 1) ? null : newRect);
						newRect = new Rectangle(scale9Grid.x + scale9Grid.width, scale9Grid.y, lastXDim, scale9Grid.height);
						borderScale9Rects.push((newRect.width < 1 || newRect.height < 1) ? null : newRect);
						newRect = new Rectangle(0, scale9Grid.y + scale9Grid.height, scale9Grid.x, lastYDim);
						borderScale9Rects.push((newRect.width < 1 || newRect.height < 1) ? null : newRect);
						newRect = new Rectangle(scale9Grid.x, scale9Grid.y + scale9Grid.height, scale9Grid.width, lastYDim);
						borderScale9Rects.push((newRect.width < 1 || newRect.height < 1) ? null : newRect);
						newRect = new Rectangle(scale9Grid.x + scale9Grid.width, scale9Grid.y + scale9Grid.height, lastXDim, lastYDim);
						borderScale9Rects.push((newRect.width < 1 || newRect.height < 1) ? null : newRect);
						for (i = 0; i < borderScale9Rects.length; i++) {
							if (borderScale9Rects[i] != null) break;
						}
						if (i >= borderScale9Rects.length) {
							borderScale9Rects = null;
						}
					}
					var numBorderBitmaps:int = (borderScale9Rects == null) ? 1 : 9;
					for (var i:int = 0; i < numBorderBitmaps; i++) {
						if (borderScale9Rects == null || borderScale9Rects[i] != null) {
							borderCopy.addChild(new Bitmap());
						}
					}

					borderCopy.accessibilityProperties = new AccessibilityProperties();
					borderCopy.accessibilityProperties.silent = true;

					skin_mc.addChild(borderCopy);
					borderPrevRect = null;
				}
			}
		}

		/**
		 * set skin clip from loaded swf
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function setSkin(index:int, avatar:DisplayObject):void {
			//ifdef DEBUG
			//debugTrace("setSkin(" + index + ", " + avatar + ")");
			//endif
			var ctrl:Sprite;
			var ctrlData:ControlData;

			if (index >= NUM_CONTROLS) {
				// this case catches special avatar names which are to be handled elsewhere
				return;
			} else if (index < NUM_BUTTONS) {
				ctrl = setupButtonSkin(index, avatar);
				skin_mc.addChild(ctrl);
				ctrlData = ctrlDataDict[ctrl];
			} else {
				switch (index) {
				case PLAY_PAUSE_BUTTON:
					ctrl = setTwoButtonHolderSkin(index, PLAY_BUTTON, "play_mc", PAUSE_BUTTON, "pause_mc", avatar);
					ctrlData = ctrlDataDict[ctrl];
					break;
				case FULL_SCREEN_BUTTON:
					ctrl = setTwoButtonHolderSkin(index, FULL_SCREEN_ON_BUTTON, "on_mc", FULL_SCREEN_OFF_BUTTON, "off_mc", avatar);
					ctrlData = ctrlDataDict[ctrl];
					break;
				case MUTE_BUTTON:
					ctrl = setTwoButtonHolderSkin(index, MUTE_ON_BUTTON, "on_mc", MUTE_OFF_BUTTON, "off_mc", avatar);
					ctrlData = ctrlDataDict[ctrl];
					break;
				case SEEK_BAR:
				case VOLUME_BAR:
					var prefix:String = skinClassPrefixes[index];
					ctrl = Sprite(createSkin(skinTemplate, prefix));
					if (ctrl != null) {
						skin_mc.addChild(ctrl);
						ctrlData = new ControlData(this, ctrl, null, index);
						ctrlDataDict[ctrl] = ctrlData;
						ctrlData.progress_mc = setupBarSkinPart(ctrl, avatar, skinTemplate, prefix + "Progress", "progress_mc");
						ctrlData.fullness_mc = setupBarSkinPart(ctrl, avatar, skinTemplate, prefix + "Fullness", "fullness_mc");
						ctrlData.hit_mc = Sprite(setupBarSkinPart(ctrl, avatar, skinTemplate, prefix + "Hit", "hit_mc"));
						ctrlData.handle_mc = Sprite(setupBarSkinPart(ctrl, avatar, skinTemplate, prefix + "Handle", "handle_mc", true));
						// resize skin to match size of avatar
						ctrl.width = avatar.width;
						ctrl.height = avatar.height;

						ctrl.accessibilityProperties = new AccessibilityProperties();
						ctrl.accessibilityProperties.silent = true;

					}
					break;
				case BUFFERING_BAR:
					prefix = skinClassPrefixes[index];
					ctrl = Sprite(createSkin(skinTemplate, prefix));
					if (ctrl != null) {
						skin_mc.addChild(ctrl);
						ctrlData = new ControlData(this, ctrl, null, index);
						ctrlDataDict[ctrl] = ctrlData;
						ctrlData.fill_mc = setupBarSkinPart(ctrl, avatar, skinTemplate, prefix + "Fill", "fill_mc");
						// resize skin to match size of avatar
						ctrl.width = avatar.width;
						ctrl.height = avatar.height;

						ctrlData.fill_mc.accessibilityProperties = new AccessibilityProperties();
						ctrlData.fill_mc.accessibilityProperties.silent = true;
						ctrl.accessibilityProperties = new AccessibilityProperties();
						ctrl.accessibilityProperties.silent = true;

					}
					break;
				} //switch
			}

			ctrlData.avatar = avatar;
			ctrlDataDict[ctrl] = ctrlData;

			delayedControls[index] = ctrl;
		}

		flvplayback_internal function setTwoButtonHolderSkin( holderIndex:int,
		                                                      firstIndex:int, firstName:String,
		                                                      secondIndex:int, secondName:String,
		                                                      avatar:DisplayObject ):Sprite {
			var subBtn:Sprite;
			var ctrl:Sprite;
			var ctrlData:ControlData;

			// create ctrl and ctrlData, add them appropriately
			ctrl = new Sprite();
			ctrlData = new ControlData(this, ctrl, null, holderIndex);
			ctrlDataDict[ctrl] = ctrlData;
			skin_mc.addChild(ctrl);

			// add the two children controls
			subBtn = setupButtonSkin(firstIndex, avatar)
			subBtn.name = firstName;
			subBtn.visible = true;
			ctrl.addChild(subBtn);

			subBtn = setupButtonSkin(secondIndex, avatar);
			subBtn.name = secondName;
			subBtn.visible = false;
			ctrl.addChild(subBtn);

			return ctrl;
		}

		flvplayback_internal function setupButtonSkin(index:int, avatar:DisplayObject):Sprite {
			//ifdef DEBUG
			//debugTrace("setupButtonSkin(" + index + ") : prefix = " + prefix);
			//endif

			var prefix:String = skinClassPrefixes[index];
			if (prefix == null) return null;
			//ifdef DEBUG
			//debugTrace("prefix = " + prefix);
			//endif

			var ctrl:Sprite = new Sprite();
			var ctrlData:ControlData = new ControlData(this, ctrl, null, index);
			ctrlDataDict[ctrl] = ctrlData;

			ctrlData.state_mc = new Array();

			ctrlData.state_mc[NORMAL_STATE] =
				setupButtonSkinState(ctrl, skinTemplate, prefix + "NormalState");
			ctrlData.state_mc[NORMAL_STATE].visible = true;

			ctrlData.state_mc[OVER_STATE] =
				setupButtonSkinState(ctrl, skinTemplate, prefix + "OverState", ctrlData.state_mc[NORMAL_STATE]);

			ctrlData.state_mc[DOWN_STATE] =
				setupButtonSkinState(ctrl, skinTemplate, prefix + "DownState", ctrlData.state_mc[NORMAL_STATE]);

			ctrlData.disabled_mc =
				setupButtonSkinState(ctrl, skinTemplate, prefix + "DisabledState", ctrlData.state_mc[NORMAL_STATE]);
			
			// copy tabIndex from the avatar
			if (avatar is InteractiveObject) {
				ctrl.tabIndex = InteractiveObject(avatar).tabIndex;
			}

			//ifdef DEBUG
			//debugTrace("ctrlData.state_mc[NORMAL_STATE] = " + ctrlData.state_mc[NORMAL_STATE]);
			//debugTrace("ctrlData.state_mc[OVER_STATE] = " + ctrlData.state_mc[OVER_STATE]);
			//debugTrace("ctrlData.state_mc[DOWN_STATE] = " + ctrlData.state_mc[DOWN_STATE]);
			//debugTrace("ctrlData.disabled_mc = " + ctrlData.disabled_mc);
			//endif

			return ctrl;
		}

		flvplayback_internal function setupButtonSkinState( ctrl:Sprite, definitionHolder:Sprite,
		                                                    skinName:String, defaultSkin:DisplayObject=null ):DisplayObject {
			//ifdef DEBUG
			//debugTrace("setupButtonSkinState(" + ctrl + ", " + definitionHolder + ", " + skinName + ", " + defaultSkin + ")");
			//endif
			var stateSkin:DisplayObject;
			try {
				stateSkin = createSkin(definitionHolder, skinName);
			} catch (ve:VideoError) {
				if (defaultSkin != null) {
					stateSkin = null;
				} else {
					throw ve;
				}
			}
			if (stateSkin != null) {
				stateSkin.visible = false;
				ctrl.addChild(stateSkin);
			} else if (defaultSkin != null) {
				stateSkin = defaultSkin;
			}
			return stateSkin;
		}

		flvplayback_internal function setupBarSkinPart( ctrl:Sprite, avatar:DisplayObject, definitionHolder:Sprite,
		                                   skinName:String, partName:String, required:Boolean=false):DisplayObject {
			//ifdef DEBUG
			//debugTrace("setupBarSkinPart(" + ctrl + ", " + avatar + ", " + definitionHolder + ", " + skinName + ", " + partName + ", " + required + ")");
			//endif
			var part:DisplayObject;
			try {
				part = ctrl[partName];
			} catch (re:ReferenceError) {
				part = null;
			}
			if (part == null) {
				try {
					part = createSkin(definitionHolder, skinName);
				} catch (ve:VideoError) {
					if (required) throw ve;
				}
				if (part != null) {
					skin_mc.addChild(part);
					part.x = ctrl.x;
					part.y = ctrl.y;

					// place part relative to the ctrl same as its avatar is placed relative to ctrl's avatar
					var partAvatar:DisplayObject = layout_mc.getChildByName(skinName + "_mc")
					//ifdef DEBUG
					//debugTrace("partAvatar for " + skinName + "_mc = " + partAvatar);
					//endif
					if (partAvatar != null) {
						if (partName == "hit_mc") {
							var ctrlData:ControlData = ctrlDataDict[ctrl];
							var partData:ControlData = new ControlData(this, part, controls[ctrlData.index], -1);
							partData.avatar = partAvatar;
							ctrlDataDict[part] = partData;
						} else {
							part.x += (partAvatar.x - avatar.x);
							part.y += (partAvatar.y - avatar.y);
							part.width = partAvatar.width;
							part.height = partAvatar.height;
						}
						// copy tabIndex from the avatar
						if (part is InteractiveObject && partAvatar is InteractiveObject) {
							InteractiveObject(part).tabIndex = InteractiveObject(partAvatar).tabIndex;
						}
					}
				}
			}
			if (required && part == null) {
				throw new VideoError(VideoError.MISSING_SKIN_STYLE, skinName);
			}
			
			if(part!=null){
				part.accessibilityProperties = new AccessibilityProperties();
				part.accessibilityProperties.silent = true;
			}

			return part;
		}

		flvplayback_internal function createSkin(definitionHolder:DisplayObject, skinName:String):DisplayObject {
			//ifdef DEBUG
			//debugTrace("createSkin(" + definitionHolder + ", " + skinName + ")");
			//endif
			try {
				var stateSkinDesc:* = definitionHolder[skinName];
				if (stateSkinDesc is String) {
					var theClass:Class;
					try {
						theClass = Class(definitionHolder.loaderInfo.applicationDomain.getDefinition(stateSkinDesc));
					} catch (err1:Error) {
						theClass = Class(getDefinitionByName(stateSkinDesc));
					}
					return DisplayObject(new theClass());
				} else if (stateSkinDesc is Class) {
					return new stateSkinDesc();
				} else if (stateSkinDesc is DisplayObject) {
					return stateSkinDesc;
				}
				//ifdef DEBUG
				//else {
				//	debugTrace("Error: stateSkinDesc is: " + stateSkinDesc);
				//}
				//endif
			} catch (err2:Error) {
				//ifdef DEBUG
				//debugTrace("Error " + e + " in createSkin(): " + e.getStackTrace());
				//endif
				throw new VideoError(VideoError.MISSING_SKIN_STYLE, skinName);
			}
			return null;
		}

		flvplayback_internal static var buttonSkinLinkageIDs:Array = [
			"upLinkageID",
			"overLinkageID",
			"downLinkageID"
		];

		/**
		 * skin button
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function skinButtonControl(ctrlOrEvent:Object):void {
			// make sense of parameter, Sprite or Event
			if (ctrlOrEvent == null) return;
			var ctrl:Sprite;
			if (ctrlOrEvent is Event) {
				var e:Event = Event(ctrlOrEvent);
				ctrl = Sprite(e.currentTarget);
				ctrl.removeEventListener(Event.ENTER_FRAME, skinButtonControl);
			} else {
				ctrl = Sprite(ctrlOrEvent);
			}
			var ctrlData:ControlData = ctrlDataDict[ctrl];
			if (ctrlData == null) return;

			// remove placeholder if it is there
			try {
				if (ctrl["placeholder_mc"] != undefined) {
					ctrl.removeChild(ctrl["placeholder_mc"]);
					ctrl["placeholder_mc"] = null;
				}
			} catch (re:ReferenceError) {
			}

			// set skin
			if (ctrlData.state_mc == null) ctrlData.state_mc = new Array();
			if (ctrlData.state_mc[NORMAL_STATE] == undefined) {
				ctrlData.state_mc[NORMAL_STATE] = setupButtonSkinState(ctrl, ctrl, buttonSkinLinkageIDs[NORMAL_STATE], null);
			}
			if (ctrlData.enabled && _controlsEnabled) {
				if (ctrlData.state_mc[ctrlData.state] == undefined) {
					ctrlData.state_mc[ctrlData.state] =
						setupButtonSkinState( ctrl, ctrl, buttonSkinLinkageIDs[ctrlData.state],
						                      ctrlData.state_mc[NORMAL_STATE] );
				}
				if (ctrlData.state_mc[ctrlData.state] != ctrlData.currentState_mc) {
					if (ctrlData.currentState_mc != null) {
						ctrlData.currentState_mc.visible = false;
					}
					ctrlData.currentState_mc = ctrlData.state_mc[ctrlData.state];
					ctrlData.currentState_mc.visible = true;
				}
				applySkinState(ctrlData, ctrlData.state_mc[ctrlData.state]);
			} else {
				ctrlData.state = NORMAL_STATE;
				if (ctrlData.disabled_mc == null) {
					ctrlData.disabled_mc =
						setupButtonSkinState(ctrl, ctrl, "disabledLinkageID", ctrlData.state_mc[NORMAL_STATE]);
				}
				applySkinState(ctrlData, ctrlData.disabled_mc);
			}
		}

		/**
		 * helper to skin button
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function applySkinState(ctrlData:ControlData, newState:DisplayObject):void {
			if (newState != ctrlData.currentState_mc) {
				if (ctrlData.currentState_mc != null) {
					ctrlData.currentState_mc.visible = false;
				}
				ctrlData.currentState_mc = newState;
				ctrlData.currentState_mc.visible = true;
			}
		}
			
		/**
		 * adds seek bar or volume bar
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function addBarControl(ctrl:Sprite):void {
			var ctrlData:ControlData = ctrlDataDict[ctrl];

			// init vars
			ctrlData.isDragging = false;
			ctrlData.percentage = 0;

			// do right away if from loaded swf, wait to give time for
			// initialization if control defined in this swf
			if (ctrl.parent == skin_mc && skin_mc != null) {
				finishAddBarControl(ctrl);
			} else {
				ctrl.addEventListener(Event.REMOVED_FROM_STAGE, cleanupHandle);
				ctrl.addEventListener(Event.ENTER_FRAME, finishAddBarControl);
			}
		}

		/**
		 * finish adding seek bar or volume bar onEnterFrame to allow for
		 * initialization to complete
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function finishAddBarControl(ctrlOrEvent:Object):void {
			// make sense of parameter, Sprite or Event
			if (ctrlOrEvent == null) return;
			var ctrl:Sprite;
			if (ctrlOrEvent is Event) {
				var e:Event = Event(ctrlOrEvent);
				ctrl = Sprite(e.currentTarget);
				ctrl.removeEventListener(Event.ENTER_FRAME, finishAddBarControl);
			} else {
				ctrl = Sprite(ctrlOrEvent);
			}
			var ctrlData:ControlData = ctrlDataDict[ctrl];

			// opportunity for custom init code
			try {
				if (ctrl["addBarControl"] is Function) {
					ctrl["addBarControl"]();
				}
			} catch (re:ReferenceError) {
			}

			// save orig width and height, used for bars that are not
			// scaled.  If they are scaled in layoutControl, we will
			// set this to undefined so it will be ignored.
			ctrlData.origWidth = ctrl.width;
			ctrlData.origHeight = ctrl.height;

			// fix up and position the progress bar
			fixUpBar(ctrl, "progress", ctrl, "progress_mc");
			calcBarMargins(ctrl, "progress", false);
			if (ctrlData.progress_mc != null) {
				fixUpBar(ctrl, "progressBarFill", ctrlData.progress_mc, "fill_mc");
				calcBarMargins(ctrlData.progress_mc, "fill", false);
				calcBarMargins(ctrlData.progress_mc, "mask", false);
				if (isNaN(_progressPercent)) {
					_progressPercent = (_vc.isRTMP ? 100 : 0);
				}
				positionBar(ctrl, "progress", _progressPercent);
			}

			// fix up the fullness bar, positioned by positionHandle
			fixUpBar(ctrl, "fullness", ctrl, "fullness_mc");
			calcBarMargins(ctrl, "fullness", false);
			if (ctrlData.fullness_mc != null) {
				fixUpBar(ctrl, "fullnessBarFill", ctrlData.fullness_mc, "fill_mc");
				calcBarMargins(ctrlData.fullness_mc, "fill", false);
				calcBarMargins(ctrlData.fullness_mc, "mask", false);
			}

			// fix up the hit clip
			fixUpBar(ctrl, "hit", ctrl, "hit_mc");

			// fix up and position the handle
			fixUpBar(ctrl, "handle", ctrl, "handle_mc");
			calcBarMargins(ctrl, "handle", true);
			switch (ctrlData.index) {
			case SEEK_BAR:
				setControl(SEEK_BAR_HANDLE, ctrlData.handle_mc);
				if (ctrlData.hit_mc != null) {
					setControl(SEEK_BAR_HIT, ctrlData.hit_mc);
				}
				break;
			case VOLUME_BAR:
				setControl(VOLUME_BAR_HANDLE, ctrlData.handle_mc);
				if (ctrlData.hit_mc != null) {
					setControl(VOLUME_BAR_HIT, ctrlData.hit_mc);
				}
				break;
			} // switch
			positionHandle(ctrl);

			ctrl.accessibilityProperties = new AccessibilityProperties();
			ctrl.accessibilityProperties.silent = true;

		}

		/**
		 * When a bar with a handle is removed from stage, cleanup the handle.
		 * When it is added back to stage, put the handle back!
		 *
		 * @private
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function cleanupHandle(ctrlOrEvent:Object):void {
			try {
				var e:Event;
				if (ctrlOrEvent is Event) {
					e = Event(ctrlOrEvent);
				}
				var ctrl:Sprite = (e == null ? Sprite(ctrlOrEvent) : Sprite(e.currentTarget));
				var ctrlData:ControlData = ctrlDataDict[ctrl];
				if (ctrlData == null || e == null) {
					ctrl.removeEventListener(Event.REMOVED_FROM_STAGE, cleanupHandle, false);
					if (ctrlData == null) return;
				}
				ctrl.removeEventListener(Event.ENTER_FRAME, finishAddBarControl);
				if (ctrlData.handle_mc != null) {
					if (ctrlData.handle_mc.parent != null) {
						ctrlData.handle_mc.parent.removeChild(ctrlData.handle_mc);
					}
					delete ctrlDataDict[ctrlData.handle_mc];
					ctrlData.handle_mc = null;
				}
				if (ctrlData.hit_mc != null) {
					if (ctrlData.hit_mc.parent != null) {
						ctrlData.hit_mc.parent.removeChild(ctrlData.hit_mc);
					}
					delete ctrlDataDict[ctrlData.hit_mc];
					ctrlData.hit_mc = null;
				}
			} catch (err:Error) {
			}
		}		 

		/**
		 * Fix up progres or fullness bar
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function fixUpBar(definitionHolder:DisplayObject, propPrefix:String, ctrl:DisplayObject, name:String):void {
			//ifdef DEBUG
			//debugTrace("fixUpBar(" + definitionHolder + ", " + propPrefix + ", " + ctrl + ", " + name + ")");
			//endif
			// check if already "fixed up"
			var ctrlData:ControlData = ctrlDataDict[ctrl];
			if (ctrlData[name] != null) return;

			// check if instance already exists within ctrl
			var bar:DisplayObject;
			try {
				bar = ctrl[name];
			} catch (re:ReferenceError) {
				bar = null;
			}

			if (bar == null) {
				// create bar based on <propPrefix>LinkageID property
				// (old school so we can use old custom components)
				try {
					bar = createSkin(definitionHolder, propPrefix + "LinkageID");
				} catch (ve:VideoError) {
					bar = null;
				}

				if (bar == null) return;

				// add bar to display list as a sibling of ctrl,
				//  checking <propPrefix>LinkageID>Below property to see if above or below the ctrl
				if (ctrl.parent != null) {
					if (getBooleanPropSafe(ctrl, propPrefix + "Below")) {
						ctrl.parent.addChildAt(bar, ctrl.parent.getChildIndex(ctrl));
					} else {
						ctrl.parent.addChild(bar);
					}
				}
			}

			// lookup/create ControlData instance
			ctrlData[name] = bar;
			var barData:ControlData = ctrlDataDict[bar];
			if (barData == null) {
				barData = new ControlData(this, bar, ctrl, -1);
				ctrlDataDict[bar] = barData;
			}
		}

		/**
		 * Gets left and right margins for progress or fullness
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function calcBarMargins(ctrl:DisplayObject, type:String, symmetricMargins:Boolean):void {
			//ifdef DEBUG
			//debugTrace("calcBarMargins(" + ctrl + ", " + type + ", " + symmetricMargins + ")");
			//endif

			if (ctrl == null) return;

			var ctrlData:ControlData = ctrlDataDict[ctrl];
			var bar:DisplayObject = ctrlData[type + "_mc"];
			if (bar == null) {
				try {
					bar = ctrl[type + "_mc"];
				} catch (re:ReferenceError) {
					bar = null;
				}
				if (bar == null) return;
				ctrlData[type + "_mc"] = bar;
			}

			var barData:ControlData = ctrlDataDict[bar];
			if (barData == null) {
				barData = new ControlData(this, bar, ctrl, -1);
				ctrlDataDict[bar] = barData;
			}

			barData.leftMargin = getNumberPropSafe(ctrl, type + "LeftMargin");
			if (isNaN(barData.leftMargin) && bar.parent == ctrl.parent) {
				barData.leftMargin = bar.x - ctrl.x;
			}

			barData.rightMargin = getNumberPropSafe(ctrl, type + "RightMargin");
			if (isNaN(barData.rightMargin)) {
				if (symmetricMargins) {
					barData.rightMargin = barData.leftMargin;
				} else if (bar.parent == ctrl.parent) {
					barData.rightMargin = ctrl.width - bar.width - bar.x + ctrl.x;
				}
			}

			barData.topMargin = getNumberPropSafe(ctrl, type + "TopMargin");
			if (isNaN(barData.topMargin) && bar.parent == ctrl.parent) {
				barData.topMargin = bar.y - ctrl.y;
			}

			barData.bottomMargin = getNumberPropSafe(ctrl, type + "BottomMargin");
			if (isNaN(barData.bottomMargin)) {
				if (symmetricMargins) {
					barData.bottomMargin = barData.topMargin;
				} else if (bar.parent == ctrl.parent) {
					barData.bottomMargin = ctrl.height - bar.height - bar.y + ctrl.y;
				}
			}

			barData.origX = getNumberPropSafe(ctrl, type + "X");
			if (isNaN(barData.origX)) {
				if (bar.parent == ctrl.parent) {
					barData.origX = bar.x - ctrl.x;
				} else if (bar.parent == ctrl) {
					barData.origX = bar.x;
				}
			}

			barData.origY = getNumberPropSafe(ctrl, type + "Y");
			if (isNaN(barData.origY)) {
				if (bar.parent == ctrl.parent) {
					barData.origY = bar.y - ctrl.y;
				} else if (bar.parent == ctrl) {
					barData.origY = bar.y;
				}
			}

			// grab the orig values
			barData.origWidth = bar.width;
			barData.origHeight = bar.height;
			barData.origScaleX = bar.scaleX;
			barData.origScaleY = bar.scaleY;

			//ifdef DEBUG
			//debugTrace(type + "LeftMargin = " + barData.leftMargin);
			//debugTrace(type + "RightMargin = " + barData.rightMargin);
			//debugTrace(type + "TopMargin = " + barData.topMargin);
			//debugTrace(type + "BottomMargin = " + barData.bottomMargin);
			//debugTrace(type + "X = " + barData.origX);
			//debugTrace(type + "Y = " + barData.origY);
			//debugTrace(type + "XScale = " + barData.origScaleX);
			//debugTrace(type + "YScale = " + barData.origScaleY);
			//debugTrace(type + "Width = " + barData.origWidth);
			//debugTrace(type + "Height = " + barData.origHeight);
			//endif

		}

		flvplayback_internal static function getNumberPropSafe(obj:Object, propName:String):Number {
			try {
				var numProp:* = obj[propName];
				return Number(numProp);
			} catch (re:ReferenceError) {
			}
			return NaN;
		}

		flvplayback_internal static function getBooleanPropSafe(obj:Object, propName:String):Boolean {
			try {
				var boolProp:* = obj[propName];
				return Boolean(boolProp);
			} catch (re:ReferenceError) {
			}
			return false;
		}
		
		/**
		 * finish adding buffer bar onEnterFrame to allow for initialization to complete
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function finishAddBufferingBar(e:Event=null):void {
			if (e != null) {
				e.currentTarget.removeEventListener(Event.ENTER_FRAME, finishAddBufferingBar);
			}

			var bufferingBar:Sprite = controls[BUFFERING_BAR];

			// set the margins
			calcBarMargins(bufferingBar, "fill", true);

			// fix up the fill
			fixUpBar(bufferingBar, "fill", bufferingBar, "fill_mc");
			
			// position the fill
			positionMaskedFill(bufferingBar, 100);
		}
		
		/**
		 * Place the buffering pattern and mask over the buffering bar
         *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function positionMaskedFill(ctrl:DisplayObject, percent:Number):void {
			//ifdef DEBUG
			//debugTrace("positionMaskedFill(" + ctrl + ", " + percent + ")");
			//endif
			if (ctrl == null) return;
			var ctrlData:ControlData = ctrlDataDict[ctrl];
			var fill:DisplayObject = ctrlData.fill_mc;
			if (fill == null) return;

			// create mask if necessary
			var mask:DisplayObject = ctrlData.mask_mc;
			if (ctrlData.mask_mc == null) {
				try {
					ctrlData.mask_mc = mask = ctrl["mask_mc"];
				} catch (re:ReferenceError) {
					ctrlData.mask_mc = null;
				}
				if (ctrlData.mask_mc == null) {
					var maskSprite:Sprite = new Sprite();
					ctrlData.mask_mc = mask = maskSprite;
					maskSprite.graphics.beginFill(0xffffff);
					maskSprite.graphics.drawRect(0, 0, 1, 1);
					maskSprite.graphics.endFill();
					var barData:ControlData = ctrlDataDict[fill];
					maskSprite.x = barData.origX;
					maskSprite.y = barData.origY;
					maskSprite.width = barData.origWidth;
					maskSprite.height = barData.origHeight;
					maskSprite.visible = false;
					fill.parent.addChild(maskSprite);
					fill.mask = maskSprite;
				}
				if (ctrlData.mask_mc != null) {
					calcBarMargins(ctrl, "mask", true);
				}
			}

			var fillData:ControlData = ctrlDataDict[fill];
			var maskData:ControlData = ctrlDataDict[mask];

			// is this a slide reveal fill?
			var slideReveal:Boolean;
			try {
				slideReveal = fill["slideReveal"];
			} catch (re:ReferenceError) {
				slideReveal = false;
			}

			if (fill.parent == ctrl) {
				if (slideReveal) {
					// slide fill, mask stays put
					fill.x = maskData.origX - fillData.origWidth + (fillData.origWidth * percent / 100);
					//ifdef DEBUG
					//debugTrace("fill.x = " + fill.x);
					//endif
				} else {
					// resize mask
					mask.width = fillData.origWidth * percent / 100;
				}
			} else if (fill.parent == ctrl.parent) {
				// in neither of these cases do we ever scale the fill_mc, we just scale the mask
				// and move the fill_mc around, so for skin swf case will usually make sense to
				// make a very long fill_mc that will always be long enough
				if (slideReveal) {
					// place and size mask
					mask.x = ctrl.x + maskData.leftMargin
					mask.y = ctrl.y + maskData.topMargin;
					mask.width = ctrl.width - maskData.rightMargin - maskData.leftMargin;
					mask.height = ctrl.height - maskData.topMargin - maskData.bottomMargin;

					// put fill in correct place
					fill.x = mask.x - fillData.origWidth + (maskData.origWidth * percent / 100);
					fill.y = ctrl.y + fillData.topMargin;
				} else {
					// put fill in correct place, do not scale
					fill.x = ctrl.x + fillData.leftMargin;
					fill.y = ctrl.y + fillData.topMargin;
					
					// place mask
					mask.x = fill.x;
					mask.y = fill.y;
					mask.width = (ctrl.width - fillData.rightMargin - fillData.leftMargin) * percent / 100;
					mask.height = ctrl.height - fillData.topMargin - fillData.bottomMargin;
				}
			}
		}

		/**
		 * Default startHandleDrag function (can be defined on seek bar
		 * movie clip instance) to handle start dragging the seek bar
		 * handle or volume bar handle.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function startHandleDrag(ctrl:Sprite):void {
			//ifdef DEBUG
			//debugTrace("startHandleDrag()");
			//endif
			if (ctrl == null) return;
			var ctrlData:ControlData = ctrlDataDict[ctrl];

			// call custom implementation instead, if available
			try {
				if (ctrl["startHandleDrag"] is Function && ctrl["startHandleDrag"]()) {
					ctrlData.isDragging = true;
					return;
				}
			} catch (re:ReferenceError) {
			}

			// lookup Sprites and ControlData
			var handle:Sprite = ctrlData.handle_mc;
			if (handle == null) return;
			var handleData:ControlData = ctrlDataDict[handle];

			// calc constriction coords
			var theY:Number = ctrl.y + handleData.origY;
			var theWidth:Number = (isNaN(ctrlData.origWidth)) ? ctrl.width : ctrlData.origWidth;
			var bounds:Rectangle =
				new Rectangle( ctrl.x + handleData.leftMargin,
				               theY,
				               theWidth - handleData.rightMargin,
				               0 );

			// start drag
			handle.startDrag(false, bounds);
			ctrlData.isDragging = true;

			handle.focusRect = false;
			handle.stage.focus = handle;
		}
		
		/**
		 * Default stopHandleDrag function (can be defined on seek bar
		 * movie clip instance) to handle stop dragging the seek bar
		 * handle or volume bar handle.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function stopHandleDrag(ctrl:Sprite):void {
			//ifdef DEBUG
			//debugTrace("stopHandleDrag()");
			//endif
			if (ctrl == null) return;
			var ctrlData:ControlData = ctrlDataDict[ctrl];

			// call custom implementation instead, if available
			try {
				if (ctrl["stopHandleDrag"] is Function && ctrl["stopHandleDrag"]()) {
					ctrlData.isDragging = false;
					return;
				}
			} catch (re:ReferenceError) {
			}

			// stop drag
			var handle:Sprite = ctrlData.handle_mc;
			if (handle == null) return;
			handle.stopDrag();

			ctrlData.isDragging = false;

			handle.stage.focus = handle;
		}

		/**
		 * Default positionHandle function (can be defined on seek bar
		 * movie clip instance) to handle positioning seek bar handle.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function positionHandle(ctrl:Sprite):void {
			if (ctrl == null) return;

			// call custom implementation instead, if available
			if (ctrl["positionHandle"] is Function && ctrl["positionHandle"]()) {
				return;
			}

			// lookup Sprites and ControlData
			var ctrlData:ControlData = ctrlDataDict[ctrl];
			var handle:Sprite = ctrlData.handle_mc;
			if (handle == null) return;
			var handleData:ControlData = ctrlDataDict[handle];

			// calc coords
			var theWidth:Number = (isNaN(ctrlData.origWidth)) ? ctrl.width : ctrlData.origWidth;
			var handleSpanLength:Number = theWidth - handleData.rightMargin - handleData.leftMargin;
			handle.x = ctrl.x + handleData.leftMargin + (handleSpanLength * ctrlData.percentage / 100);
			handle.y = ctrl.y + handleData.origY;

			// set fullness mask clip if there is one
			if (ctrlData.fullness_mc != null) {
				positionBar(ctrl, "fullness", ctrlData.percentage);
			}
		}

		/**
		 * helper for other positioning funcs
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function positionBar(ctrl:Sprite, type:String, percent:Number):void {
			//ifdef DEBUG
			//debugTrace("positionBar(" + ctrl + ", " + type + ", " + percent + ")");
			//endif
			try {
				if (ctrl["positionBar"] is Function && ctrl["positionBar"](type, percent)) {
					return;
				}
			} catch (re2:ReferenceError) {
				// do nothing
			}

			// lookup Sprites and ControlData
			var ctrlData:ControlData = ctrlDataDict[ctrl];
			var bar:DisplayObject = ctrlData[type + "_mc"];
			//ifdef DEBUG
			//debugTrace("bar = " + bar);
			//endif
			if (bar == null) return;
			var barData:ControlData = ctrlDataDict[bar];

			if (bar.parent == ctrl) {
				// don't move me, just scale me relative to myself, since
				// I'm already scaled with the parent clip
				if (barData.fill_mc == null) {
					bar.scaleX = barData.origScaleX * percent / 100;
				} else {
					positionMaskedFill(bar, percent);
				}
			} else {
				// assume I'm at the same level of the parent clip, so
				// move and scale to match, taking margins and y pos into
				// account
				bar.x = ctrl.x + barData.leftMargin;
				bar.y = ctrl.y + barData.origY;
				if (barData.fill_mc == null) {
					bar.width = (ctrl.width - barData.leftMargin - barData.rightMargin) * percent / 100;
				} else {
					positionMaskedFill(bar, percent);
				}
			}
		}
		
		/**
		 * Default calcPercentageFromHandle function (can be defined on
		 * seek bar movie clip instance) to handle calculating percentage
		 * from seek bar handle position.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function calcPercentageFromHandle(ctrl:Sprite):void {
			if (ctrl == null) return;
			var ctrlData:ControlData = ctrlDataDict[ctrl];

			// call custom implementation instead, if available
			if (ctrl["calcPercentageFromHandle"] is Function && ctrl["calcPercentageFromHandle"]()) {
				// sanity
				if (ctrlData.percentage < 0) ctrlData.percentage = 0;
				if (ctrlData.percentage > 100) ctrlData.percentage = 100;
				return;
			}

			// lookup Sprites and ControlData
			var handle:Sprite = ctrlData.handle_mc;
			if (handle == null) return;
			var handleData:ControlData = ctrlDataDict[handle];

			var theWidth:Number = (isNaN(ctrlData.origWidth)) ? ctrl.width : ctrlData.origWidth;
			var handleSpanLength:Number = theWidth - handleData.rightMargin - handleData.leftMargin;
			var handleLoc:Number = (handle.x - (ctrl.x + handleData.leftMargin))
			ctrlData.percentage = handleLoc / handleSpanLength * 100;

			// sanity
			if (ctrlData.percentage < 0) ctrlData.percentage = 0;
			if (ctrlData.percentage > 100) ctrlData.percentage = 100;

			// set fullness mask clip if there is one
			if (ctrlData.fullness_mc != null) {
				positionBar(ctrl, "fullness", ctrlData.percentage);
			}

		}

		/**
		 * Called to signal end of seek bar scrub.  Call from
		 * onRelease and onReleaseOutside event listeners.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		flvplayback_internal function handleRelease(index:int):void {
			//ifdef DEBUG
			//debugTrace("handleRelease()");
			//endif

			// set activeVideoPlayerIndex to visibleVideoPlayerIndex
			var cachedActivePlayerIndex:int = _vc.activeVideoPlayerIndex;
			_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

			if (index == SEEK_BAR) {
				seekBarListener(null);
			} else if (index == VOLUME_BAR) {
				volumeBarListener(null);
			}
			stopHandleDrag(controls[index]);

			// set activeVideoPlayerIndex back to prev value
			_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;

			if (index == SEEK_BAR) {
				_vc._scrubFinish();
			}
		}
		
		/**
		 * Called on interval when user scrubbing by dragging seekbar handle.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function seekBarListener(e:TimerEvent):void {
			// set activeVideoPlayerIndex to visibleVideoPlayerIndex
			var cachedActivePlayerIndex:int = _vc.activeVideoPlayerIndex;
			_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;
			
			// lookup Sprites and ControlData
			var ctrl:Sprite = controls[SEEK_BAR];
			if (ctrl == null) return;
			var ctrlData:ControlData = ctrlDataDict[ctrl];

			// get percentage
			calcPercentageFromHandle(ctrl);
			var scrubPos:Number = ctrlData.percentage;

			// if called NOT on the timer, then we are done
			if (e == null) {
				_seekBarTimer.stop();
				if (scrubPos != _lastScrubPos) {
					_vc.seekPercent(scrubPos);
				}
				_vc.addEventListener(VideoEvent.PLAYHEAD_UPDATE, handleIVPEvent);
				if (_playAfterScrub) {
					_vc.play();
				}
			} else if (_vc.getVideoPlayer(_vc.visibleVideoPlayerIndex).state == VideoState.SEEKING) {
				// do nothing if VideoPlayer in the middle of a seek
			} else if ( _seekBarScrubTolerance <= 0 ||
						Math.abs(scrubPos - _lastScrubPos) > _seekBarScrubTolerance ||
						scrubPos < _seekBarScrubTolerance ||
						scrubPos > (100 - _seekBarScrubTolerance) ) {
				if (scrubPos != _lastScrubPos) {
					_lastScrubPos = scrubPos;
					_vc.seekPercent(scrubPos);
				}
			}

			// set activeVideoPlayerIndex back to prev value
			_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
		}
		
		/**
		 * Called on interval when user scrubbing by dragging volumebar handle.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function volumeBarListener(e:TimerEvent):void {
			// lookup Sprites and ControlData
			var ctrl:Sprite = controls[VOLUME_BAR];
			if (ctrl == null) return;
			var ctrlData:ControlData = ctrlDataDict[ctrl];

			calcPercentageFromHandle(ctrl);
			var volumePos:Number = ctrlData.percentage;

			// if called NOT on the timer, then we are done
			var finish:Boolean = (e == null);
			if (finish) {
				_volumeBarTimer.stop();
				_vc.addEventListener(SoundEvent.SOUND_UPDATE, handleSoundEvent);
			}
			if ( finish || _volumeBarScrubTolerance <= 0 ||
				 Math.abs(volumePos - _lastVolumePos) > _volumeBarScrubTolerance ||
				 volumePos < _volumeBarScrubTolerance ||
				 volumePos > (100 - _volumeBarScrubTolerance) ) {
				if (volumePos != _lastVolumePos) {
					if (_isMuted) {
						cachedSoundLevel = volumePos / 100;
					} else {
						_vc.volume = volumePos / 100;
					}
					_lastVolumePos = volumePos;
				}
			}
		}
		
		/**
		 * Called on interval do delay entering buffering state.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function doBufferingDelay(e:TimerEvent):void {
			// stop timer, reset since it only runs once
			_bufferingDelayTimer.reset();

			// set activeVideoPlayerIndex to visibleVideoPlayerIndex
			var cachedActivePlayerIndex:int = _vc.activeVideoPlayerIndex;
			_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

			if (_vc.state == VideoState.BUFFERING) {
				_bufferingOn = true;
				handleIVPEvent(new VideoEvent(VideoEvent.STATE_CHANGE, false, false, VideoState.BUFFERING, NaN, _vc.visibleVideoPlayerIndex));
			}

			// set activeVideoPlayerIndex back to prev value
			_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
		}
		
		flvplayback_internal function dispatchMessage(index:int):void {
			if (index == SEEK_BAR_HANDLE || index == SEEK_BAR_HIT) {
				_vc._scrubStart();
			}

			// set activeVideoPlayerIndex to visibleVideoPlayerIndex
			var cachedActivePlayerIndex:int = _vc.activeVideoPlayerIndex;
			_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

			var ctrl:Sprite;
			var ctrlData:ControlData
			var handle:Sprite;

			switch (index) {
			case PAUSE_BUTTON:
				_vc.pause();
				break;
			case PLAY_BUTTON:
				_vc.play();
				break;
			case STOP_BUTTON:
				_vc.stop();
				break;
			case SEEK_BAR_HIT:
			case SEEK_BAR_HANDLE:
				ctrl = controls[SEEK_BAR];
				ctrlData = ctrlDataDict[ctrl];
				calcPercentageFromHandle(ctrl);
				_lastScrubPos = ctrlData.percentage;
				if (index == SEEK_BAR_HIT) {
					handle = controls[SEEK_BAR_HANDLE];
					handle.x = handle.parent.mouseX;
					handle.y = handle.parent.mouseY;
				}
				_vc.removeEventListener(VideoEvent.PLAYHEAD_UPDATE, handleIVPEvent);
				if (_vc.playing || _vc.buffering) {
					_playAfterScrub = true;
				} else if (_vc.state != VideoState.SEEKING) {
					_playAfterScrub = false;
				}
				_seekBarTimer.start();
				startHandleDrag(ctrl);
				_vc.pause();
				break;
			case VOLUME_BAR_HIT:
			case VOLUME_BAR_HANDLE:
				ctrl = controls[VOLUME_BAR];
				ctrlData = ctrlDataDict[ctrl];
				calcPercentageFromHandle(ctrl);
				_lastVolumePos = ctrlData.percentage;
				if (index == VOLUME_BAR_HIT) {
					handle = controls[VOLUME_BAR_HANDLE];
					handle.x = handle.parent.mouseX;
					handle.y = handle.parent.mouseY;
				}
				_vc.removeEventListener(SoundEvent.SOUND_UPDATE, handleSoundEvent);
				_volumeBarTimer.start();
				startHandleDrag(ctrl);
				break;
			case BACK_BUTTON:
				_vc.seekToPrevNavCuePoint();
				break;
			case FORWARD_BUTTON:
				_vc.seekToNextNavCuePoint();
				break;
			case MUTE_ON_BUTTON:
				if (!_isMuted) {
					_isMuted = true;
					cachedSoundLevel = _vc.volume;
					_vc.volume = 0;
					setEnabledAndVisibleForState(MUTE_OFF_BUTTON, VideoState.PLAYING);
					skinButtonControl(controls[MUTE_OFF_BUTTON]);
					setEnabledAndVisibleForState(MUTE_ON_BUTTON, VideoState.PLAYING);
					skinButtonControl(controls[MUTE_ON_BUTTON]);
				}
				break;
			case MUTE_OFF_BUTTON:
				if (_isMuted) {
					_isMuted = false;
					_vc.volume = cachedSoundLevel;
					setEnabledAndVisibleForState(MUTE_OFF_BUTTON, VideoState.PLAYING);
					skinButtonControl(controls[MUTE_OFF_BUTTON]);
					setEnabledAndVisibleForState(MUTE_ON_BUTTON, VideoState.PLAYING);
					skinButtonControl(controls[MUTE_ON_BUTTON]);
				}
				break;
			case FULL_SCREEN_ON_BUTTON:
				if (!_fullScreen && _vc.stage != null) {
					enterFullScreenDisplayState();
					setEnabledAndVisibleForState(FULL_SCREEN_OFF_BUTTON, VideoState.PLAYING);
					skinButtonControl(controls[FULL_SCREEN_OFF_BUTTON]);
					setEnabledAndVisibleForState(FULL_SCREEN_ON_BUTTON, VideoState.PLAYING);
					skinButtonControl(controls[FULL_SCREEN_ON_BUTTON]);
				}
				break;
			case FULL_SCREEN_OFF_BUTTON:
				if (_fullScreen && _vc.stage != null) {
					try {
						_vc.stage.displayState = StageDisplayState.NORMAL;
					} catch (se:SecurityError) {
					}
					setEnabledAndVisibleForState(FULL_SCREEN_OFF_BUTTON, VideoState.PLAYING);
					skinButtonControl(controls[FULL_SCREEN_OFF_BUTTON]);
					setEnabledAndVisibleForState(FULL_SCREEN_ON_BUTTON, VideoState.PLAYING);
					skinButtonControl(controls[FULL_SCREEN_ON_BUTTON]);
				}
				break;
			default:
				throw new Error("Unknown ButtonControl");
			} // switch

			// set activeVideoPlayerIndex back to prev value
			_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
		}

		flvplayback_internal function setEnabledAndVisibleForState(index:int, state:String):void {
			//ifdef DEBUG
			////debugTrace("setEnabledAndVisibleForState(" + index + ", " + state + ")");
			//endif
			// set activeVideoPlayerIndex to visibleVideoPlayerIndex
			var cachedActivePlayerIndex:int = _vc.activeVideoPlayerIndex;
			_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

			// use effectiveState because BUFFERING has this
			// doBufferingDelay() thing going on
			var effectiveState:String = state;
			if (effectiveState == VideoState.BUFFERING && !_bufferingOn) {
				effectiveState = VideoState.PLAYING;
			}

			// lookup Sprites and ControlData
			var ctrl:Sprite = controls[index];
			if (ctrl == null) return;
			var ctrlData:ControlData = ctrlDataDict[ctrl];
			if (ctrlData == null) return;

			switch (index) {
			case VOLUME_BAR:
			case VOLUME_BAR_HANDLE:
			case VOLUME_BAR_HIT:
				// always enabled
				ctrlData.enabled = true;
				break;
			case FULL_SCREEN_ON_BUTTON:
				ctrlData.enabled = !_fullScreen;
				if (controls[FULL_SCREEN_BUTTON] != undefined) {
					ctrl.visible = ctrlData.enabled;
				}
				break;
			case FULL_SCREEN_OFF_BUTTON:
				ctrlData.enabled = _fullScreen;
				if (controls[FULL_SCREEN_BUTTON] != undefined) {
					ctrl.visible = ctrlData.enabled;
				}
				break;
			case MUTE_ON_BUTTON:
				ctrlData.enabled = !_isMuted;
				if (controls[MUTE_BUTTON] != undefined) {
					ctrl.visible = ctrlData.enabled;
				}
				break;
			case MUTE_OFF_BUTTON:
				ctrlData.enabled = _isMuted;
				if (controls[MUTE_BUTTON] != undefined) {
					ctrl.visible = ctrlData.enabled;
				}
				break;
			default:
				switch (effectiveState) {
				case VideoState.LOADING:
				case VideoState.CONNECTION_ERROR:
					ctrlData.enabled = false;
					break;
				case VideoState.DISCONNECTED:
					ctrlData.enabled  = (_vc.source != null && _vc.source != "");
					break;
				case VideoState.SEEKING:
					// no change
					break;
				default:
					ctrlData.enabled = true;
					break;
				} // switch
				break;
			} // switch

			switch (index) {
			case SEEK_BAR:
				// set enabled
				switch (effectiveState) {
				case VideoState.STOPPED:
				case VideoState.PLAYING:
				case VideoState.PAUSED:
				case VideoState.REWINDING:
				case VideoState.SEEKING:
					ctrlData.enabled = true;
					break;
				case VideoState.BUFFERING:
					ctrlData.enabled = (!_bufferingBarHides || controls[BUFFERING_BAR] == undefined);
					break;
				default:
					ctrlData.enabled = false;
					break;
				} // switch
				if (ctrlData.enabled) {
					ctrlData.enabled = (!isNaN(_vc.totalTime));
				}

				// set handle enabled and visible
				if (ctrlData.handle_mc != null) {
					var handleData:ControlData = ctrlDataDict[ctrlData.handle_mc];
					handleData.enabled = ctrlData.enabled;
					ctrlData.handle_mc.visible = handleData.enabled;
				}
				// set hit clip enabled and visible
				if (ctrlData.hit_mc != null) {
					var hitData:ControlData = ctrlDataDict[ctrlData.hit_mc];
					hitData.enabled = ctrlData.enabled;
					ctrlData.hit_mc.visible = hitData.enabled;
				}

				// hide when buffer bar active
				var vis:Boolean = ( !_bufferingBarHides || ctrlData.enabled || controls[BUFFERING_BAR] == undefined || !controls[BUFFERING_BAR].visible );
				ctrl.visible = vis;
				if (ctrlData.progress_mc != null) {
					ctrlData.progress_mc.visible = vis;
					var progressData:ControlData = ctrlDataDict[ctrlData.progress_mc];
					if (progressData.fill_mc != null) {
						progressData.fill_mc.visible = vis;
					}
				}
				if (ctrlData.fullness_mc != null) {
					ctrlData.fullness_mc.visible = vis;
					var fullnessData:ControlData = ctrlDataDict[ctrlData.fullness_mc];
					if (fullnessData.fill_mc != null) {
						fullnessData.fill_mc.visible = vis;
					}
				}
				break;
			case BUFFERING_BAR:
				// set enabled
				switch (effectiveState) {
				case VideoState.STOPPED:
				case VideoState.PLAYING:
				case VideoState.PAUSED:
				case VideoState.REWINDING:
				case VideoState.SEEKING:
					ctrlData.enabled = false;
					break;
				default:
					ctrlData.enabled = true;
					break;
				} // switch

				// set visible
				ctrl.visible = ctrlData.enabled;
				if (ctrlData.fill_mc != null) {
					ctrlData.fill_mc.visible = ctrlData.enabled;
				}
				break;
			case PAUSE_BUTTON:
				switch (effectiveState) {
				case VideoState.DISCONNECTED:
				case VideoState.STOPPED:
				case VideoState.PAUSED:
				case VideoState.REWINDING:
					ctrlData.enabled = false;
					break;
				case VideoState.PLAYING:
					ctrlData.enabled = true;
					break;
				case VideoState.BUFFERING:
					ctrlData.enabled = (!_bufferingBarHides || controls[BUFFERING_BAR] == undefined);
					break;
				} // switch
				if (controls[PLAY_PAUSE_BUTTON] != undefined) {
					ctrl.visible = ctrlData.enabled;
				}
				break;
			case PLAY_BUTTON:
				switch (effectiveState) {
				case VideoState.PLAYING:
					ctrlData.enabled = false;
					break;
				case VideoState.STOPPED:
				case VideoState.PAUSED:
					ctrlData.enabled = true;
					break;
				case VideoState.BUFFERING:
					ctrlData.enabled = (!_bufferingBarHides || controls[BUFFERING_BAR] == undefined);
					break;
				} // switch
				if (controls[PLAY_PAUSE_BUTTON] != undefined) {
					ctrl.visible = !controls[PAUSE_BUTTON].visible;
				}
				break;
			case STOP_BUTTON:
				switch (effectiveState) {
				case VideoState.DISCONNECTED:
				case VideoState.STOPPED:
					ctrlData.enabled = false;
					ctrl.tabEnabled = false;
					break;
				case VideoState.PAUSED:
				case VideoState.PLAYING:
				case VideoState.BUFFERING:
					ctrlData.enabled = true;
					ctrl.tabEnabled = true;
					break;
				} // switch
				break;
			case BACK_BUTTON:
			case FORWARD_BUTTON:
				switch (effectiveState) {
				case VideoState.BUFFERING:
					ctrlData.enabled = (!_bufferingBarHides || controls[BUFFERING_BAR] == undefined);
					ctrl.tabEnabled = (!_bufferingBarHides || controls[BUFFERING_BAR] == undefined);
					break;
				}
			} // switch index

			// set mouse enabledness
			ctrl.mouseEnabled = ctrlData.enabled;

			// set activeVideoPlayerIndex back to prev value
			_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
		}

		// todo: replace autohide timer with events?
		flvplayback_internal function setupSkinAutoHide(doFade:Boolean):void {
			if (_skinAutoHide && skin_mc != null) {
				// create a hitTarget_mc to receive FocusIn and FocusOut events to hide and show controls
				if(!hitTarget_mc){
					
					hitTarget_mc = new Sprite();
					hitTarget_mc.accessibilityProperties = new AccessibilityProperties();
					hitTarget_mc.accessibilityProperties.name = accessibilityPropertyNames[SHOW_CONTROLS_BUTTON];
					
					customClips.push(hitTarget_mc);
					
					var uiMgr:UIManager = this;
					var clickHandler:Function = function(e:*):void{
							if(e.type == FocusEvent.FOCUS_IN){
								uiMgr._skinAutoHide = false;
							} else if(e.type == MouseEvent.CLICK){
								uiMgr._skinAutoHide = !uiMgr._skinAutoHide;
							}
							
							uiMgr.setupSkinAutoHide(true);
							
							if(uiMgr._skinAutoHide){
								e.target.accessibilityProperties.name = accessibilityPropertyNames[SHOW_CONTROLS_BUTTON];
							} else {
								e.target.accessibilityProperties.name = accessibilityPropertyNames[HIDE_CONTROLS_BUTTON];
							}
							if(Accessibility.active) Accessibility.updateProperties();
						};
						hitTarget_mc.useHandCursor = false;
						hitTarget_mc.buttonMode = true;
						hitTarget_mc.tabEnabled = true;
						hitTarget_mc.tabChildren = true;
						hitTarget_mc.focusRect = true;
						hitTarget_mc.addEventListener(FocusEvent.FOCUS_IN, clickHandler);
						hitTarget_mc.addEventListener(MouseEvent.CLICK, clickHandler);
						hitTarget_mc.accessibilityProperties.silent = _fullScreen;
						hitTarget_mc.tabEnabled = !_fullScreen;
						if(Accessibility.active) Accessibility.updateProperties();
					
					_vc.addChild(hitTarget_mc);
				}
				hitTarget_mc.graphics.clear();
				hitTarget_mc.graphics.lineStyle(0,0xFF0000,0);
				hitTarget_mc.graphics.drawRect(0,0,_vc.width,_vc.height);

				// set visibility
				skinAutoHideHitTest(null, doFade);
				// setup interval
				_skinAutoHideTimer.start();
			} else {
				if (skin_mc != null) {
					if (doFade && _skinFadingMaxTime > 0 && (!skin_mc.visible || skin_mc.alpha < 1) && __visible) {
						_skinFadingTimer.stop();
						_skinFadeStartTime = getTimer();
						_skinFadingIn = true;
						if (skin_mc.alpha == 1) skin_mc.alpha = 0;
						_skinFadingTimer.start();
					} else if (_skinFadingMaxTime <= 0) {
						_skinFadingTimer.stop();
						skin_mc.alpha = 1;
					}
					// set visibility
					skin_mc.visible = __visible;
				}
				// setup interval
				_skinAutoHideTimer.stop();
			}
		}

		flvplayback_internal function skinAutoHideHitTest(e:TimerEvent, doFade:Boolean=true):void {
			try {
				if (!__visible) {
					skin_mc.visible = false;

					if(hitTarget_mc){
						hitTarget_mc.accessibilityProperties.name = accessibilityPropertyNames[SHOW_CONTROLS_BUTTON];
					}

				} else if (_vc.stage != null) {
					var visibleVP:VideoPlayer = _vc.getVideoPlayer(_vc.visibleVideoPlayerIndex);
					var hit:Boolean = visibleVP.hitTestPoint(_vc.stage.mouseX, _vc.stage.mouseY, true);
					if (_fullScreen && _fullScreenTakeOver && e != null) {
						if (_vc.stage.mouseX == _skinAutoHideMouseX && _vc.stage.mouseY == _skinAutoHideMouseY) {
							if (getTimer() - _skinAutoHideLastMotionTime > _skinAutoHideMotionTimeout) {
								hit = false;
							}
						} else {
							_skinAutoHideLastMotionTime = getTimer();
							_skinAutoHideMouseX = _vc.stage.mouseX;
							_skinAutoHideMouseY = _vc.stage.mouseY;
						}
					}
					if (!hit && border_mc != null) {
						hit = border_mc.hitTestPoint(_vc.stage.mouseX, _vc.stage.mouseY, true);
						if (hit && _fullScreen && _fullScreenTakeOver) {
							_skinAutoHideLastMotionTime = getTimer();
						}
					}

					if (!doFade || _skinFadingMaxTime <= 0) {
						_skinFadingTimer.stop();
						skin_mc.visible = hit;
						skin_mc.alpha = 1;
					} else if ( (hit && skin_mc.visible && (!_skinFadingTimer.running || _skinFadingIn)) ||
					            (!hit && (!skin_mc.visible || (_skinFadingTimer.running && !_skinFadingIn))) ) {
						// do nothing, i am already done fading or fading in the right direction
					} else {
						_skinFadingTimer.stop();
						_skinFadingIn = hit;
						if (_skinFadingIn && skin_mc.alpha == 1) {
							skin_mc.alpha = 0;
						}
						_skinFadeStartTime = getTimer();
						_skinFadingTimer.start();
						skin_mc.visible = true;
					}

					if(hitTarget_mc){
						hitTarget_mc.accessibilityProperties.name = (hit) ? accessibilityPropertyNames[HIDE_CONTROLS_BUTTON] : accessibilityPropertyNames[SHOW_CONTROLS_BUTTON] ;
					}

				}
			} catch (se:SecurityError) {
				_skinAutoHideTimer.stop();
				_skinFadingTimer.stop();
				skin_mc.visible = __visible;
				skin_mc.alpha = 1;

				if(hitTarget_mc){
					hitTarget_mc.accessibilityProperties.name = accessibilityPropertyNames[HIDE_CONTROLS_BUTTON];
				}

			}

			// Update accessibility properties
			if(hitTarget_mc && Capabilities.hasAccessibility){
				Accessibility.updateProperties();
			}

		}

		flvplayback_internal function skinFadeMore(e:TimerEvent):void {
			if ((!_skinFadingIn && skin_mc.alpha <= .5) || (_skinFadingIn && skin_mc.alpha >= .95)) {
				skin_mc.visible = _skinFadingIn;
				skin_mc.alpha = 1;
				_skinFadingTimer.stop();
			} else {
				var percent:Number = (getTimer() - _skinFadeStartTime) / _skinFadingMaxTime;
				if (!_skinFadingIn) {
					percent = 1 - percent;
				}
				if (percent < 0) {
					percent = 0;
				} else if (percent > 1) {
					percent = 1;
				}
				skin_mc.alpha = percent;
			}
		}

		public function enterFullScreenDisplayState():void {
			if (!_fullScreen && _vc.stage != null) {
				if (_fullScreenTakeOver) {
					try {
						// do this first to force the ReferenceError which will bail from the special
						// fullScreenSourceRect handling code
						var theRect:Rectangle = _vc.stage.fullScreenSourceRect;

						_fullScreenAccel = true;

						// get the videoWidth and videoHeight of the VideoPlayer
						var vp:VideoPlayer = _vc.getVideoPlayer(_vc.visibleVideoPlayerIndex);
						var effectiveWidth:int = vp.videoWidth;
						var effectiveHeight:int = vp.videoHeight;

						// calculate aspect ratio of video
						var videoAspectRatio:Number = effectiveWidth / effectiveHeight;

						// calculate aspect ratio of the screen
						var screenAspectRatio:Number = _vc.stage.fullScreenWidth / _vc.stage.fullScreenHeight;

						// fix effective width and height to match screen aspect ratio
						if (videoAspectRatio > screenAspectRatio) {
							effectiveHeight = effectiveWidth / screenAspectRatio;
						} else if (videoAspectRatio < screenAspectRatio) {
							effectiveWidth = effectiveHeight * screenAspectRatio;
						}

						// get effectve min width and height based on screen aspect ratio and skinScaleMaximum
						var effectiveMinWidth:int = fullScreenSourceRectMinWidth;
						var effectiveMinHeight:int = fullScreenSourceRectMinHeight;
						if (fullScreenSourceRectMinAspectRatio > screenAspectRatio) {
							effectiveMinHeight = effectiveMinWidth / screenAspectRatio;
						} else if (fullScreenSourceRectMinAspectRatio < screenAspectRatio) {
							effectiveMinWidth = effectiveMinHeight * screenAspectRatio;
						}
						var skinScaleMinWidth:int = _vc.stage.fullScreenWidth / _skinScaleMaximum;
						var skinScaleMinHeight:int = _vc.stage.fullScreenHeight / _skinScaleMaximum;
						if (effectiveMinWidth < skinScaleMinWidth || effectiveMinHeight < skinScaleMinHeight) {
							effectiveMinWidth = skinScaleMinWidth;
							effectiveMinHeight = skinScaleMinHeight;
						}

						// check videoWidth and videoHeight against minimums
						if (effectiveWidth < effectiveMinWidth || effectiveHeight < effectiveMinHeight) {
							effectiveWidth = effectiveMinWidth;
							effectiveHeight = effectiveMinHeight;
						}

						// go into full screen!
						_vc.stage.fullScreenSourceRect = new Rectangle(0, 0, effectiveWidth, effectiveHeight)
						_vc.stage.displayState = StageDisplayState.FULL_SCREEN;
					} catch (re:ReferenceError) {
						_fullScreenAccel = false;
					} catch (re:SecurityError) {
						_fullScreenAccel = false;
					}
				}

				try {
					_vc.stage.displayState = StageDisplayState.FULL_SCREEN;
				} catch (se:SecurityError) {
				}
			}
		}

		flvplayback_internal function enterFullScreenTakeOver():void {
			if (!_fullScreen || cacheFLVPlaybackParent != null) return;

			// suspend this listener for the duration of the call
			_vc.removeEventListener(LayoutEvent.LAYOUT, handleLayoutEvent);
			_vc.removeEventListener(AutoLayoutEvent.AUTO_LAYOUT, handleLayoutEvent);
			_vc.removeEventListener(Event.ADDED_TO_STAGE, handleEvent);
			_vc.stage.removeEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenEvent);

			try {
				cacheFLVPlaybackScaleMode = new Array();
				cacheFLVPlaybackAlign = new Array();
				for (var i:int = 0; i < _vc.videoPlayers.length; i++) {
					var vp:VideoPlayer = _vc.videoPlayers[i] as VideoPlayer;
					if (vp != null) {
						cacheFLVPlaybackScaleMode[i] = vp.scaleMode;
						cacheFLVPlaybackAlign[i] = vp.align;
					}
				}
				cacheFLVPlaybackParent = _vc.parent;
				cacheFLVPlaybackIndex = _vc.parent.getChildIndex(_vc);
				cacheFLVPlaybackLocation = new Rectangle(_vc.registrationX, _vc.registrationY, _vc.registrationWidth, _vc.registrationHeight);
				if (!_fullScreenAccel) {
					cacheStageAlign = _vc.stage.align;
					cacheStageScaleMode = _vc.stage.scaleMode;

					_vc.stage.align = StageAlign.TOP_LEFT;
					_vc.stage.scaleMode = StageScaleMode.NO_SCALE;
				}
				_vc.align = VideoAlign.CENTER;
				_vc.scaleMode = VideoScaleMode.MAINTAIN_ASPECT_RATIO;
				_vc.registrationX = 0;
				_vc.registrationY = 0;
				_vc.setSize(_vc.stage.stageWidth, _vc.stage.stageHeight);

				if (_vc.stage != _vc.parent) {
					_vc.stage.addChild(_vc);
				} else {
					_vc.stage.setChildIndex(_vc, _vc.stage.numChildren - 1);
				}

				// make a big black rectangle
				var fullScreenBG:Sprite = Sprite(_vc.getChildByName("fullScreenBG"));
				if (fullScreenBG == null) {
					fullScreenBG = new Sprite();
					fullScreenBG.name = "fullScreenBG";
					_vc.addChildAt(fullScreenBG, 0);
				} else {
					_vc.setChildIndex(fullScreenBG, 0);
				}
				fullScreenBG.graphics.beginFill(_fullScreenBgColor);
				fullScreenBG.graphics.drawRect(0, 0, _vc.stage.stageWidth, _vc.stage.stageHeight);

				// force skin layout
				layoutSkin();
				setupSkinAutoHide(false);
				
				if(hitTarget_mc != null){
					// redraw the hitTarget_mc graphics to match the full screen stage dimensions
					hitTarget_mc.graphics.clear();
					hitTarget_mc.graphics.lineStyle(0,0,0);
					hitTarget_mc.graphics.drawRect(0,0,_vc.stage.stageWidth, _vc.stage.stageHeight);
				}
				
			} catch (err:Error) {
				cacheFLVPlaybackParent = null;
			}

			// re-add this listener after the call
			_vc.addEventListener(LayoutEvent.LAYOUT, handleLayoutEvent);
			_vc.addEventListener(AutoLayoutEvent.AUTO_LAYOUT, handleLayoutEvent);
			_vc.addEventListener(Event.ADDED_TO_STAGE, handleEvent);
			_vc.stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenEvent);
		}

		flvplayback_internal function exitFullScreenTakeOver():void {
			if (cacheFLVPlaybackParent == null) return;

			// suspend this listener for the duration of the call
			_vc.removeEventListener(Event.ADDED_TO_STAGE, handleEvent);
			_vc.stage.removeEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenEvent);

			try {
				if (_fullScreenAccel) {
					_vc.stage.fullScreenSourceRect = new Rectangle(0, 0, -1, -1);
				} else {
					_vc.stage.align = cacheStageAlign;
					_vc.stage.scaleMode = cacheStageScaleMode;
				}

				// remove big black rectangle
				var fullScreenBG:Sprite = Sprite(_vc.getChildByName("fullScreenBG"));
				if (fullScreenBG != null) {
					_vc.removeChild(fullScreenBG);
				}
				
				if(hitTarget_mc != null){
					// redraw the hitTarget_mc graphics to match the FLVPlayback dimensions
					hitTarget_mc.graphics.clear();
					hitTarget_mc.graphics.lineStyle(0,0,0);
					hitTarget_mc.graphics.drawRect(0,0,_vc.width,_vc.height);
				}

				// reparent
				if (_vc.parent != cacheFLVPlaybackParent) {
					cacheFLVPlaybackParent.addChildAt(_vc, cacheFLVPlaybackIndex);
				} else {
					cacheFLVPlaybackParent.setChildIndex(_vc, cacheFLVPlaybackIndex);
				}

				// set align and scaleMode back on every player
				var cacheActiveIndex:int = _vc.activeVideoPlayerIndex;
				for (var i:int = 0; i < _vc.videoPlayers.length; i++) {
					var vp:VideoPlayer = _vc.videoPlayers[i] as VideoPlayer;
					if (vp != null) {
						_vc.activeVideoPlayerIndex = i;
						if (cacheFLVPlaybackScaleMode[i] != undefined) {
							_vc.scaleMode = cacheFLVPlaybackScaleMode[i];
						}
						if (cacheFLVPlaybackAlign[i]) {
							_vc.align = cacheFLVPlaybackAlign[i];
						}
					}
				}
				_vc.activeVideoPlayerIndex = cacheActiveIndex;

				// resize and put back in the right place
				_vc.registrationX = cacheFLVPlaybackLocation.x;
				_vc.registrationY = cacheFLVPlaybackLocation.y;
				_vc.setSize(cacheFLVPlaybackLocation.width, cacheFLVPlaybackLocation.height);

			} catch (err:Error) {
			}

			// re-add this listener after the call
			_vc.addEventListener(Event.ADDED_TO_STAGE, handleEvent);
			_vc.stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenEvent);

			_fullScreen = false;
			_fullScreenAccel = false;

			cacheStageAlign = null;
			cacheStageScaleMode = null;
			cacheFLVPlaybackParent = null;
			cacheFLVPlaybackIndex = 0;
			cacheFLVPlaybackLocation = null;
			cacheFLVPlaybackScaleMode = null;
			cacheFLVPlaybackAlign = null;
			if (_skinAutoHide != cacheSkinAutoHide) {
				_skinAutoHide = cacheSkinAutoHide;
				setupSkinAutoHide(false);
			}
		}

		flvplayback_internal function hookUpCustomComponents():void {
			
				// check whether the FlashPlayer's default yellow focusRect 
				// should be active for FLVPlayback controls
				focusRect = isFocusRectActive();
			
			var searchHash:Object = new Object();
			var doTheSearch:Boolean = false;
			var i:int;
			for (i = 0; i < NUM_CONTROLS; i++) {
				if (controls[i] == null) {
					searchHash[customComponentClassNames[i]] = i;
					doTheSearch = true;
				}
			}
			if (!doTheSearch) return;

			for (i = 0; i < _vc.parent.numChildren; i++) {
				var dispObj:DisplayObject = _vc.parent.getChildAt(i);
				var name:String = getQualifiedClassName(dispObj);
				if (searchHash[name] != undefined) {
					if (typeof searchHash[name] == "number") {
						var index:int = int(searchHash[name]);
						try {
							var ctrl:Sprite = Sprite(dispObj);
							if ( (index >= NUM_BUTTONS || ctrl["placeholder_mc"] is DisplayObject) && ctrl["uiMgr"] == null ) {
								setControl(index, ctrl);
								searchHash[name] = ctrl;
							}
						} catch (err:Error) {
						}
					}
				}
			}
		}



		/**
		 * Creates an accessibility implementation for seek bar or volume bar control. 
		 * 
         * @param index The index number of the bar control 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function configureBarAccessibility(index:int):void {
			switch(index){
			case SEEK_BAR_HANDLE :
				SeekBarAccImpl.createAccessibilityImplementation(controls[SEEK_BAR_HANDLE]);
				break;
			case VOLUME_BAR_HANDLE :
				VolumeBarAccImpl.createAccessibilityImplementation(controls[VOLUME_BAR_HANDLE]);
				break;
			}
		}
		
		
		/**
		 * Handles keyboard events, and depending on the event target, sets keyboard focus to the appropriate control.
		 * 
         * @param event a KeyboardEvent
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function handleKeyEvent(event:KeyboardEvent):void {
			var ctrlData:ControlData = ctrlDataDict[event.currentTarget];
			var k:int = event.keyCode;
			var ka:int = event.charCode;
			var kaBool:Boolean = (ka>=48 && ka<=57);
			ka = int(String.fromCharCode(event.charCode));
			var focusControl:InteractiveObject;
			switch(event.type){
			case KeyboardEvent.KEY_DOWN :
				switch(event.target){
				case controls[SEEK_BAR_HANDLE] :
				case controls[VOLUME_BAR_HANDLE] :
					if(k!=Keyboard.TAB && 
					   (k==Keyboard.UP || 
						k==Keyboard.DOWN ||
						k==Keyboard.LEFT ||
						k==Keyboard.RIGHT ||
						k==Keyboard.PAGE_UP ||
						k==Keyboard.PAGE_DOWN ||
						k==Keyboard.HOME || 
						k==Keyboard.END ||
						(!isNaN(ka) && kaBool))){
						focusControl = event.target as InteractiveObject;
						focusControl.stage.focus = focusControl;
						if( event.target == controls[SEEK_BAR_HANDLE] ){							
							var percent:Number = _vc.playheadPercentage;
							
							var nearestCuePoint:Object; 
							var nextCuePoint:Object;
							nearestCuePoint	= _vc.findNearestCuePoint(_vc.playheadTime);
							
							if(k==Keyboard.LEFT  || k==Keyboard.DOWN){
								percent -= (_vc.seekBarScrubTolerance*2);
								_vc.playheadPercentage = Math.max(percent,0);
							} else if(k==Keyboard.RIGHT|| k==Keyboard.UP){
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
								} else {
									percent += (_vc.seekBarScrubTolerance);
									_vc.playheadPercentage = Math.min(99,percent);
								}
							} else if(k==Keyboard.PAGE_UP  || k==Keyboard.HOME){
								_vc.playheadPercentage = 0;
							} else if(k==Keyboard.PAGE_DOWN || k==Keyboard.END){
								_vc.playheadPercentage = 99;
							}
						} else {
							// store mute state
							var wasMuted:Boolean = _isMuted;
							// the current volume as a percentage, if muted used the cachedSoundLevel, otherwise use the current _vc.volume
							var num:Number = (_isMuted) ? Math.round(cachedSoundLevel*1000)/100 : Math.round(_vc.volume*1000)/100;
							// adjust the volume based on keyboard input
							if(k==Keyboard.LEFT || k==Keyboard.DOWN){
								if(Math.floor(num) != num){
									_vc.volume = Math.floor(num)/10;
								} else {
									_vc.volume = Math.max(0, (num-1)/10);
								}
							} else if(k==Keyboard.RIGHT || k==Keyboard.UP){
								if(Math.round(num) != num){
									_vc.volume = Math.round(num)/10;
								} else {
									_vc.volume = Math.min(1, (num+1)/10);
								}
							} else if(k==Keyboard.PAGE_UP || k==Keyboard.HOME){
								_vc.volume = 1;
							} else if(k==Keyboard.PAGE_DOWN || k==Keyboard.END){
								_vc.volume = 0;
							} else if(!isNaN(ka) && kaBool){
								_vc.volume = Math.min(1,(ka+1)/10);
							}
							// cache the new sound level
							cachedSoundLevel = _vc.volume;
							// if volume was muted, restore the muted state
							if(wasMuted){
								_isMuted = true;
								cachedSoundLevel = _vc.volume;
								_vc.volume = 0;
								setEnabledAndVisibleForState(MUTE_OFF_BUTTON, VideoState.PLAYING);
								skinButtonControl(controls[MUTE_OFF_BUTTON]);
								setEnabledAndVisibleForState(MUTE_ON_BUTTON, VideoState.PLAYING);
								skinButtonControl(controls[MUTE_ON_BUTTON]);
							}
						}
					}
					break;
				case controls[PAUSE_BUTTON] :
					if(k==Keyboard.SPACE || k==Keyboard.ENTER){
						ctrlData.state = DOWN_STATE;
						if(!event.target.focusRect){
							dispatchMessage(ctrlData.index);
						}
						focusControl = controls[PLAY_BUTTON] as InteractiveObject;
					}
					break;
				case controls[PLAY_BUTTON] :
					if(k==Keyboard.SPACE || k==Keyboard.ENTER){
						ctrlData.state = DOWN_STATE;
						if(!event.target.focusRect){
							dispatchMessage(ctrlData.index);
						}
						focusControl = controls[PAUSE_BUTTON] as InteractiveObject;
					}
					break;
				case controls[STOP_BUTTON] :
				case controls[BACK_BUTTON] :
				case controls[FORWARD_BUTTON] :
					if(k==Keyboard.SPACE || k==Keyboard.ENTER){
						ctrlData.state = DOWN_STATE;
						event.target.tabEnabled = true;
						if(!event.target.focusRect){
							dispatchMessage(ctrlData.index);
						}
						focusControl = event.target as InteractiveObject;
					}
					break;
				case controls[MUTE_ON_BUTTON] :
					if(k==Keyboard.SPACE || k==Keyboard.ENTER){
						ctrlData.state = DOWN_STATE;
						if(!event.target.focusRect){
							dispatchMessage(ctrlData.index);
						}
						focusControl = controls[MUTE_OFF_BUTTON] as InteractiveObject;
					}
					break;
				case controls[MUTE_OFF_BUTTON] :
					if(k==Keyboard.SPACE || k==Keyboard.ENTER){
						ctrlData.state = DOWN_STATE;
						if(!event.target.focusRect){
							dispatchMessage(ctrlData.index);
						}
						focusControl = controls[MUTE_ON_BUTTON] as InteractiveObject;
					}
					break;
				case controls[FULL_SCREEN_ON_BUTTON] :
					if(k==Keyboard.SPACE || k==Keyboard.ENTER){
						ctrlData.state = DOWN_STATE;
						dispatchMessage(FULL_SCREEN_ON_BUTTON);
					}
					break;
				case controls[FULL_SCREEN_OFF_BUTTON] :
					if(k==Keyboard.SPACE || k==Keyboard.ENTER){
						ctrlData.state = DOWN_STATE;
						dispatchMessage(FULL_SCREEN_OFF_BUTTON);
					}
					break;
				}
				skinButtonControl(event.currentTarget);
				break;
			case KeyboardEvent.KEY_UP :
				switch(event.target){
					case controls[SEEK_BAR_HANDLE] :
					case controls[VOLUME_BAR_HANDLE] :
						if(k!=Keyboard.TAB && 
						   (k==Keyboard.UP || 
							k==Keyboard.DOWN ||
							k==Keyboard.LEFT ||
							k==Keyboard.RIGHT ||
							k==Keyboard.PAGE_UP ||
							k==Keyboard.PAGE_DOWN ||
							k==Keyboard.HOME || 
							k==Keyboard.END) ){
							focusControl = event.target as InteractiveObject;
							focusControl.stage.focus = focusControl;
						}
						break;
					default :
						ctrlData.state = OVER_STATE;
						break;
				}
				break;
			}
			if(focusControl!=null){
				if(focusControl.visible){
					ctrlData.state = NORMAL_STATE;
					if(!focusControl.tabEnabled){
						focusControl.tabEnabled = true;
					}
					focusControl.stage.focus = focusControl;
				} else {
					var ctrl:Sprite = event.currentTarget as Sprite;
					var setFocusedControl:Function = function(evt:Event):void {
						if(evt.target.visible){
							ctrlData.state = NORMAL_STATE;
							if(!evt.target.tabEnabled){
								evt.target.tabEnabled = true;
							}
							evt.target.stage.focus = evt.target;
							evt.target.removeEventListener(Event.ENTER_FRAME,setFocusedControl);
						}
					}
					focusControl.addEventListener(Event.ENTER_FRAME,setFocusedControl);
				}
			}
		}
		
		/**
		 * Handles keyboard focus events, to maintain focus on slider controls or the stop button.
		 * 
         * @param event a FocusEvent
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function handleFocusEvent(event:FocusEvent):void{
			var ctrlData:ControlData = ctrlDataDict[event.currentTarget];
			if (ctrlData == null) return;
			switch(event.type){
			case FocusEvent.FOCUS_IN:
				switch(event.target){
					case controls[SEEK_BAR_HANDLE] :
					case controls[VOLUME_BAR_HANDLE] :
						event.target.focusRect = false;
						break;
				}
				ctrlData.state = OVER_STATE;
				break;
			case FocusEvent.FOCUS_OUT :
				switch(event.target){
					case controls[SEEK_BAR_HANDLE] :
					case controls[VOLUME_BAR_HANDLE] :
						event.target.focusRect = true;
						break;
					case controls[STOP_BUTTON] :
						if(!ctrlData.enabled){
							event.target.tabEnabled = false;
						}
						break;
				}
				ctrlData.state = NORMAL_STATE;
				break;
			}
			skinButtonControl(event.currentTarget);
		}
		
		
		/**
		 * Assigns tabIndex values to each of the FLVPlayback controls by sorting 
		 * them horizontally left to right, and returns the next available tabIndex value.
		 * 
         * @param startTabbing the starting tabIndex for FLVPlayback controls
		 * 
		 * @return the next available tabIndex after the FLVPlayback controls
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function assignTabIndexes(startTabbing:int):int {
			if(startTabbing){
				startTabIndex = startTabbing;
				endTabIndex = startTabIndex + 1;
			} else if(_vc.tabIndex){
				startTabIndex = _vc.tabIndex;
				endTabIndex = startTabIndex + 1;
			} else {
				return endTabIndex;
			}
			
			var sortByPosition:Function = function(a:DisplayObject,b:DisplayObject):int {
				var aBounds:Rectangle = a.getBounds(_vc);
				var bBounds:Rectangle = b.getBounds(_vc);
				
				if(aBounds.x > bBounds.x){
					return 1;
				} else if(aBounds.x < bBounds.x){
					return -1;
				} else {
					if(aBounds.y > bBounds.y){
						return -1;
					} else if(aBounds.y < bBounds.y){
						return 1;
					} else {
						return 0;
					}
				}
			}
			
			try {
				var controlsSlice:Array = controls.slice();
				var customSlice:Array; 
				if(customClips && customClips.length>0) {
					customSlice = customClips.slice();
				}
				var sortedControls:Array = (!customSlice) ? controlsSlice : controlsSlice.concat(customSlice);
				sortedControls.sort(sortByPosition);
				for(var i:int; i<sortedControls.length; i++){
					var ctrl:Sprite = sortedControls[i] as Sprite;
					ctrl.tabIndex = ++endTabIndex;
					if(!ctrl.tabEnabled){
						ctrl.tabEnabled = false;
					}
				}
				
			} catch(err:Error){
				
			}
			return ++endTabIndex;
		}
		
		/**
		 * Checks for the presence of an IFocusManagerComponent on the stage to determine whether or 
		 * not to display the FlashPlayer's default yellow focus rectangle, 
		 * when a control receives focus.
		 * 
		 * @return 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function isFocusRectActive():Boolean {
			var o:InteractiveObject = _vc.parent;
			while (o) {
				if (o is DisplayObjectContainer) {
					var doc:DisplayObjectContainer = DisplayObjectContainer(o);
				}	
				var i:int;
				for (i = 0; i < doc.numChildren; i++) {
					try {
						var child:DisplayObject = doc.getChildAt(i) as DisplayObject;
						var classReference:Class = flash.utils.getDefinitionByName("fl.core.UIComponent") as Class;
						if(child != null && child != _vc &&
							child is classReference) {
							var c = child as classReference;
							if(c.focusManager.showFocusIndicator){
								return false;
							}
							break;
						}
					} catch(e:Error) {
						// Ignore this child if we can't access it
						// also ignore case where fl.core.UIComponent is not available
						// and any other error
					}
				}
				o = o.parent;
			}
			return true;
		}
		
		/**
		 * Handles a mouse focus change event and forces focus on the appropriate control.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private function handleMouseFocusChangeEvent(event:FocusEvent):void {
			var ctrlData:ControlData;
			try{
				ctrlData = ctrlDataDict[event.relatedObject];
			} catch(error:ReferenceError){
			}
			if(ctrlData==null){
				return;
			}
			var index:int = ctrlData.index;
			var currentFocus:InteractiveObject = event.target.stage.focus as InteractiveObject;
			var focusControl:InteractiveObject = null;
			switch(index){
				case PLAY_BUTTON :
					focusControl = controls[PAUSE_BUTTON] as InteractiveObject;
					break;
				case PAUSE_BUTTON :
					focusControl = controls[PLAY_BUTTON] as InteractiveObject;
					break;
				case STOP_BUTTON :
				case BACK_BUTTON :
				case FORWARD_BUTTON :
				case SEEK_BAR_HANDLE :
				case VOLUME_BAR_HANDLE :
					focusControl = controls[event.relatedObject] as InteractiveObject;
					break;
				case SEEK_BAR_HIT :
					focusControl = controls[SEEK_BAR_HANDLE] as InteractiveObject;
					break;
				case VOLUME_BAR_HIT :
					focusControl = controls[VOLUME_BAR_HANDLE] as InteractiveObject;
					break;
				case MUTE_ON_BUTTON :
					focusControl = controls[MUTE_OFF_BUTTON] as InteractiveObject;
					break;
				case MUTE_OFF_BUTTON :
					focusControl = controls[MUTE_ON_BUTTON] as InteractiveObject;
					break;
				case FULL_SCREEN_ON_BUTTON :
					focusControl = controls[FULL_SCREEN_OFF_BUTTON] as InteractiveObject;
					break;
				case FULL_SCREEN_OFF_BUTTON :
					focusControl = controls[FULL_SCREEN_ON_BUTTON] as InteractiveObject;
					break;
			}
			if(focusControl!=null){
				var focusCtrlData:ControlData;
				try{
					focusCtrlData = ctrlDataDict[focusControl];
					focusCtrlData.cachedFocusRect = focusControl.focusRect;
				} catch(error:ReferenceError){
				}
				focusControl.focusRect = false;
				if(focusControl.visible){
					focusControl.stage.focus = focusControl;
					focusControl.focusRect = focusCtrlData.cachedFocusRect;
				} else {
					var ctrl:Sprite = event.currentTarget as Sprite;
					var setFocusedControl:Function = function(evt:Event):void {
						if(evt.target.visible){
							evt.target.stage.focus = evt.target;
							evt.target.focusRect = focusCtrlData.cachedFocusRect;
							evt.target.removeEventListener(Event.ENTER_FRAME,setFocusedControl);
						}
					}
					focusControl.addEventListener(Event.ENTER_FRAME,setFocusedControl);
				}
			}
		}


		//ifdef DEBUG
		//public function debugTrace(s:*):void {
		//	try {
		//		_vc.debugTrace(s);
		//	} catch (e:Error) {
		//	}
		//}
		//endif

	} // class UIManager

} // package fl.video
