// Copyright © 2004-2007. Adobe Systems Incorporated. All Rights Reserved.

//Examples for this package are untested for Blaze as of 10/02/2006. 
//They can be found here: main\player\FlashPlayer\avmglue\ASDocs\AS3\Process\fl\video\

package fl.video {

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;

	use namespace flvplayback_internal;

	/**
	 * Dispatched when the video player is resized or laid out automatically. A video player is 
	 * laid out automatically based on the values of the <code>align</code> and <code>scaleMode</code> properties
	 * when a new FLV file is loaded or when one of those two properties is changed.
	 * 
	 * <p>The <code>autoLayout</code> event is of type AutoLayoutEvent and has the constant 
	 * <code>AutoLayoutEvent.AUTO_LAYOUT</code>.</p>
	 * 
	 * <p>After an attempt to automatically lay out a video player, the event object is dispatched even if the dimensions were
	 * not changed. </p>
	 * 
	 * <p>A <code>LayoutEvent</code> is also dispatched in these three scenarios:</p>
	 * <ul>
	 * <li>If the video player that laid itself out is visible.</li>
	 * <li>If there are two video players of different sizes or positions and the 
	 * <code>visibleVideoPlayerIndex</code> property is switched from one video player to another.</li>
	 * <li>If methods or properties that change the size of the video player such
	 * as <code>setSize()</code>, <code>setScale()</code>, 
	 * <code>width</code>, <code>height</code>, <code>scaleX</code>, <code>scaleY</code>,
	 * <code>registrationWidth</code> and <code>registrationHeight</code>, are called.</li>
	 * </ul>
	 *
	 * <p>If multiple video player instances are in use, this event may
	 * not apply to the visible video player.</p>
	 * 
	 * @see AutoLayoutEvent#AUTO_LAYOUT 
	 * @see #scaleMode  
	 * @see #event:layout layout event
	 * @see #visibleVideoPlayerIndex  
	 * 
	 * @tiptext autoLayout event
     * @eventType fl.video.AutoLayoutEvent.AUTO_LAYOUT
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("autoLayout", type="fl.video.AutoLayoutEvent")]

	/**
	 * Dispatched when the playhead is moved to the start of the video player because the 
	 * <code>autoRewind</code> property is set to <code>true</code>. When the
	 * <code>autoRewound</code> event is dispatched, the <code>rewind</code> event is also
	 * dispatched. 
	 * 
	 * <p>The <code>autoRewound</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.AUTO_REWOUND</code>.</p>
	 * 
	 * @see VideoEvent#AUTO_REWOUND 
	 * @see #autoRewind  
	 * @see #event:rewind rewind event
	 * 
	 * @tiptext autoRewound event
     * @eventType fl.video.VideoEvent.AUTO_REWOUND
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("autoRewound", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when the FLVPlayback instance enters the buffering state. 
	 * The FLVPlayback instance typically enters this state immediately after a call to the 
	 * <code>play()</code> method or when the <code>Play</code> control is clicked, 
	 * before entering the playing state. 
	 *
	 * <p>The <code>stateChange</code> event is also dispatched.</p>
	 * 
	 * <p>The <code>bufferingStateEntered</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.BUFFERING_STATE_ENTERED</code>.</p>
	 * 
	 * @see VideoState#BUFFERING 
	 * @see VideoEvent#BUFFERING_STATE_ENTERED 
	 * @see #play() 
	 * @see #playheadTime 
	 * @see #state 
	 * @see #event:stateChange stateChange event
	 * 
	 * @tiptext buffering event
     * @eventType fl.video.VideoEvent.BUFFERING_STATE_ENTERED
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("bufferingStateEntered", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when the event object closes the NetConnection, 
	 * by timing out or through a call to the <code>closeVideoPlayer()</code> method or when 
	 * you call the <code>load()</code> or <code>play()</code> methods or set the 
	 * <code>source</code> property and cause the RTMP connection 
	 * to close as a result. The FLVPlayback instance dispatches this event only when 
	 * streaming from Flash Media Server (FMS) or other Flash Video Streaming Service (FVSS). 
	 * 
	 * <p>The <code>close</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.CLOSE</code>.</p>
	 * 
 	 * @see VideoEvent#CLOSE 
	 * @see #closeVideoPlayer() 
	 * @see #source 
	 * @see #load() 
	 * @see #play() 
	 * 
	 * @tiptext close event
     * @eventType fl.video.VideoEvent.CLOSE
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("close", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when playing completes because the player reached the end of the FLV file. 
	 * The component does not dispatch the event if you call the <code>stop()</code> or 
	 * <code>pause()</code> methods 
	 * or click the corresponding controls. 
	 * 
	 * <p>When the application uses progressive download, it does not set the 
	 * <code>totalTime</code>
	 * property explicitly, and it downloads an FLV file that does not specify the duration 
	 * in the metadata. The video player sets the <code>totalTime</code> property to an approximate 
	 * total value before it dispatches this event.</p>
	 * 
	 * <p>The video player also dispatches the <code>stateChange</code> and <code>stoppedStateEntered</code>
	 * events.</p>
	 * 
	 * <p>The <code>complete</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.COMPLETE</code>.</p>
	 * 
	 * @see #event:stateChange stateChange event
	 * @see #event:stoppedStateEntered stoppedStateEntered event
	 * @see #stop() 
	 * @see #pause() 
	 * @see #totalTime 
	 * 
	 * @tiptext complete event
     * @eventType fl.video.VideoEvent.COMPLETE
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("complete", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when a cue point is reached. The event object has an 
	 * <code>info</code> property that contains the info object received by the 
	 * <code>NetStream.onCuePoint</code> event callback for FLV file cue points. 
	 * For ActionScript cue points, it contains the object that was passed 
	 * into the ActionScript cue point methods or properties.
	 * 
	 * <p>The <code>cuePoint</code> event is of type MetadataEvent and has the constant 
	 * <code>MetadataEvent.CUE_POINT</code>.</p>
	 * 
	 * @see MetadataEvent#CUE_POINT 
	 * @see flash.net.NetStream#event:onCuePoint NetStream.onCuePoint event
	 * 
	 * @tiptext cuePoint event
     * @eventType fl.video.MetadataEvent.CUE_POINT
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("cuePoint", type="fl.video.MetadataEvent")]

	/**
	 * Dispatched when the location of the playhead moves forward by a call to
	 * the <code>seek()</code> method or by clicking the ForwardButton control. 
	 * 
	 * <p>The FLVPlayback instance also dispatches <code>playheadUpdate</code> event.</p>
	 * 
	 * <p>The <code>fastForward</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.FAST_FORWARD</code>.</p> 
	 * 
	 * @see VideoEvent#FAST_FORWARD 
	 * @see #event:playheadUpdate playheadUpdate event
	 * @see #seek() 
	 * 
	 * @tiptext fastForward event
     * @eventType fl.video.VideoEvent.FAST_FORWARD
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("fastForward", type="fl.video.VideoEvent")]

	/**
	 * Dispatched the first time the FLV file's metadata is reached.
	 * The event object has an <code>info</code> property that contains the 
	 * info object received by the <code>NetStream.onMetaData</code> event callback.
	 *
	 * <p>The <code>metadataReceived</code> event is of type MetadataEvent and has the constant 
	 * <code>MetadataEvent.METADATA_RECEIVED</code>.</p>
	 * 
	 * @see MetadataEvent#METADATA_RECEIVED 
	 * @see flash.net.NetStream#event:onMetaData Netstream.onMetaData event
	 * 
     * @tiptext metadataReceived event
	 * @eventType fl.video.MetadataEvent.METADATA_RECEIVED
	 * 
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("metadataReceived", type="fl.video.MetadataEvent")]

	/**
	 * Dispatched when the player enters the paused state. This happens when you call 
	 * the <code>pause()</code> method or click the corresponding control and it also happens 
	 * in some cases when the FLV file is loaded and the <code>autoPlay</code> property 
	 * is <code>false</code> (the state may be stopped instead). 
	 * 
	 * <p>The <code>stateChange</code> event is also dispatched. </p>
	 * 
	 * <p>The <code>pausedStateEntered</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.PAUSED_STATE_ENTERED</code>.</p> 
	 * 
	 * @see #autoPlay 
	 * @see #pause() 
	 * @see VideoEvent#PAUSED_STATE_ENTERED 
	 * @see #event:stateChange stateChange event
	 * 
	 * @tiptext pausedStateEntered event
     * @eventType fl.video.VideoEvent.PAUSED_STATE_ENTERED
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("pausedStateEntered", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when the playing state is entered. This may not occur immediately 
	 * after the <code>play()</code> method is called or the corresponding control is clicked; 
	 * often the buffering state is entered first, and then the playing state. 
	 * 
	 * <p>The FLVPlayback instance also dispatches the <code>stateChange</code> event.</p>
	 * 
	 * <p>The <code>playingStateEntered</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.PLAYING_STATE_ENTERED</code>.</p> 
	 * 
	 * @see #play() 
	 * @see #event:stateChange stateChange event
	 * 
	 * @tiptext playingStateEntered event
     * @eventType fl.video.VideoEvent.PLAYING_STATE_ENTERED
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("playingStateEntered", type="fl.video.VideoEvent")]

	/**
	 * Dispatched while the FLV file is playing at the frequency specified by the 
	 * <code>playheadUpdateInterval</code> property or when rewinding starts. 
	 * The component does not dispatch this event when the video player is paused or stopped 
	 * unless a seek occurs. 
	 * 
	 * <p>The <code>playheadUpdate</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.PLAYHEAD_UPDATE</code>.</p> 
	 * 
	 * 
	 * @see VideoEvent#PLAYHEAD_UPDATE 
	 * @see #playheadUpdateInterval 
	 * 
	 * @tiptext change event
	 * @eventType fl.video.VideoEvent.PLAYHEAD_UPDATE
     * @default .25 seconds
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("playheadUpdate", type="fl.video.VideoEvent")]

	/**
	 * Indicates progress made in number of bytes downloaded. Dispatched at the frequency 
	 * specified by the <code>progressInterval</code> property, starting 
	 * when the load begins and ending when all bytes are loaded or there is a network error. 
	 * The default is every .25 seconds starting when load is called and ending
	 * when all bytes are loaded or if there is a network error. Use this event to check 
	 * bytes loaded or number of bytes in the buffer. 
	 *
	 * <p>Dispatched only for a progressive HTTP download. Indicates progress in number of 
	 * downloaded bytes. The event object has the <code>bytesLoaded</code> and <code>bytesTotal</code>
	 * properties, which are the same as the FLVPlayback properties of the same names.</p>
	 * 
	 * <p>The <code>progress</code> event is of type VideoProgressEvent and has the constant 
	 * <code>VideoProgressEvent.PROGRESS</code>.</p> 
	 * 
	 * @see #bytesLoaded 
	 * @see #bytesTotal 
	 * @see VideoProgressEvent#PROGRESS 
	 * @see #progressInterval 
	 * 
	 * @tiptext progress event
	 * @eventType fl.video.VideoProgressEvent.PROGRESS
     * 
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("progress", type="fl.video.VideoProgressEvent")]

	/**
	 * Dispatched when an FLV file is loaded and ready to display. It starts the first 
	 * time you enter a responsive state after you load a new FLV file with the <code>play()</code>
	 * or <code>load()</code> method. It starts only once for each FLV file that is loaded.
	 * 
	 * <p>The <code>ready</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.READY</code>.</p> 
	 * 
	 * @see #load() 
	 * @see #play() 
     * @see VideoEvent#READY 
     *
	 * @tiptext ready event
	 * @eventType fl.video.VideoEvent.READY
	 * 
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("ready", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when the video player is resized or laid out. Here are two layout scenarios:<br/>
	 * <ul><li>If the video player is laid out by either using the <code>autoLayout</code> 
	 * event or calling the <code>setScale()</code> or 
	 * <code>setSize()</code> methods or changing the <code>width</code>, <code>height</code>,
	 * <code>scaleX</code>, and <code>scaleY</code> properties.</li>
	 * <li>If there are two video players of different sizes and the 
	 * <code>visibleVideoPlayerIndex</code> property is switched from one video player to another.</li>
	 * </ul>  
	 *
	 * <p>The <code>layout</code> event is of type LayoutEvent and has the constant 
	 * <code>LayoutEvent.LAYOUT</code>.</p> 
	 * 
	 * @see #event:autoLayout autoLayout event
 	 * @see LayoutEvent#LAYOUT 
	 * @see #visibleVideoPlayerIndex 
     *
	 * @tiptext layout event
	 * @eventType fl.video.LayoutEvent.LAYOUT
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("layout", type="fl.video.LayoutEvent")]

	/**
	 * Dispatched when the location of the playhead moves backward by
	 * a call to <code>seek()</code> or when an <code>autoRewind</code> call is
	 * completed. When an <code>autoRewind</code> call is completed, an <code>autoRewound</code>
	 * event is triggered first. 
	 * 
	 * <p>The <code>rewind</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.REWIND</code>.</p> 
	 * 
	 * @see #autoRewind 
	 * @see #event:autoRewound autoRewound event
	 * @see VideoEvent#REWIND 
	 * @see VideoState#REWINDING 
	 * @see #seek() 
	 * 
	 * @tiptext rewind event
	 * @eventType fl.video.VideoEvent.REWIND
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("rewind", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when the user stops scrubbing the FLV file with the seek bar. 
	 * Scrubbing refers to grabbing the handle of the SeekBar and dragging it in 
	 * either direction to locate a particular scene in the FLV file. Scrubbing stops 
	 * when the user releases the handle of the seek bar.
	 * 
	 * <p>The component also dispatches the <code>stateChange</code> event with 
	 * the <code>state</code> property, which is either playing, paused, 
	 * stopped, or buffering. The <code>state</code> property is
	 * seeking until the user finishes scrubbing.</p>
	 * 
     * <p>The <code>scrubFinish</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.SCRUB_FINISH</code>.</p> 
	 * 
	 * @see VideoEvent#SCRUB_FINISH 
	 * @see #state 
     * @see #event:stateChange stateChange event
     *
	 * @tiptext scrubFinish event
	 * @eventType fl.video.VideoEvent.SCRUB_FINISH
	 * 
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("scrubFinish", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when the user begins scrubbing the FLV file with the seek bar. 
	 * Scrubbing refers to grabbing the handle of the SeekBar and dragging it in either direction 
	 * to locate a particular scene in the FLV file. 
	 * Scrubbing begins when the user clicks the SeekBar handle and ends when the user 
	 * releases it.
	 * 
	 * <p>The component also dispatches the <code>stateChange</code> event with the 
	 * <code>state</code> property equal to seeking. The state remains seeking until the user 
	 * stops scrubbing. </p>
	 * 
	 * <p>The <code>scrubStart</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.SCRUB_START</code>.</p>
	 * 
	 * @see VideoEvent#SCRUB_START 
	 * @see #state 
     * @see #event:stateChange stateChange event
     *
	 * @tiptext scrubStart event
	 * @eventType fl.video.VideoEvent.SCRUB_START
	 * 
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("scrubStart", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when the location of the playhead is changed by a call to
	 * <code>seek()</code> or by setting the <code>playheadTime</code> property or 
	 * by using the SeekBar control. The
	 * <code>playheadTime</code> property is the destination time. 
	 *
     * <p>The <code>seeked</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.SEEKED</code>.</p>
	 *
	 * <p>The FLVPlayback instance dispatches the <code>rewind</code> event when the seek 
	 * is backward and the <code>fastForward</code> event when the seek is forward. It also 
	 * dispatches the <code>playheadUpdate</code> event.</p>
	 *
	 * <p>For several reasons, the <code>playheadTime</code> property might not have the 
	 * expected value immediately after you call one of the seek methods or set 
	 * <code>playheadTime</code> to cause seeking. First, for a progressive download, 
	 * you can seek only to a keyframe, so a seek takes you to the time of the first 
	 * keyframe after the specified time. (When streaming, a seek always goes to the precise 
	 * specified time even if the source FLV file doesn't have a keyframe there.) Second, 
	 * seeking is asynchronous, so if you call a seek method or set the <code>playheadTime</code> 
	 * property, <code>playheadTime</code> does not update immediately. To obtain the time after the 
	 * seek is complete, listen for the <code>seek</code> event, which does not start until the 
	 * <code>playheadTime</code> property has updated.</p>
	 *
 	 * @see #event:fastForward fastForward event
	 * @see #playheadTime 
	 * @see #event:playheadUpdate playheadUpdate event
	 * @see #seek() 
	 * @see VideoEvent#SEEKED 
	 * 
	 * @tiptext seeked event
	 * @eventType fl.video.VideoEvent.SEEKED
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("seeked", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when an error occurs loading a skin SWF file.  	 
	 * The event has a message property that contains the error message.
	 * If a skin SWF file is set, playback begins when the <code>ready</code> event 
	 * and <code>skinLoaded</code> (or <code>skinError</code>) events have both started.
	 *
	 * <p>The <code>skinError</code> event is of type SkinErrorEvent and has the constant 
	 * <code>SkinErrorEvent.SKIN_ERROR</code>.</p>
	 * 
	 * @see #event:ready ready event
	 * @see SkinErrorEvent#SKIN_ERROR 
     * @see #event:skinLoaded skinLoaded event
     *
	 * @tiptext skinError event
	 * @eventType fl.video.SkinErrorEvent.SKIN_ERROR
	 * 
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("skinError", type="fl.video.SkinErrorEvent")]

	/**
	 * Dispatched when a skin SWF file is loaded. The component 
	 * does not begin playing an FLV file until the <code>ready</code> event 
	 * and <code>skinLoaded</code> (or <code>skinError</code>) events have both started.
	 * 
	 * <p>The <code>skinLoaded</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.SKIN_LOADED</code>.</p>
	 * 
	 * @see #event:ready ready event
	 * @see VideoEvent#SKIN_LOADED 
     * @see #event:skinError skinError event
     *
	 * @tiptext skinLoaded event
	 * @eventType fl.video.VideoEvent.SKIN_LOADED
	 * 
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("skinLoaded", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when the playback state changes. When an <code>autoRewind</code> call is 
	 * completed the <code>stateChange</code> event is dispatched with the rewinding
	 * state. The <code>stateChange</code> event does not 
	 * start until rewinding has completed. 
	 * 
	 * <p>This event can be used to track when playback enters or leaves unresponsive 
	 * states such as in the middle of connecting, resizing, or rewinding. The  
	 * <code>play()</code>, <code>pause()</code>, <code>stop()</code> and <code>seek()</code> 
	 * methods queue the requests to be executed when the player enters
	 * a responsive state.</p>
	 *
	 * <p>The <code>stateChange</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.STATE_CHANGE</code>.</p>
	 * 
     * @see VideoEvent#STATE_CHANGE 
     *
	 * @tiptext stateChange event
	 * @eventType fl.video.VideoEvent.STATE_CHANGE
	 * 
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("stateChange", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when the playback encounters an unsupported player feature. When a connection is 
	 * attempted and fails due to an unsupported player feature, the <code>unsupportedPlayerVersion</code> 
	 * event is dispatched.
	 *
	 * <p>The <code>unsupportedPlayerVersion</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.UNSUPPORTED_PLAYER_VERSION</code>.</p>
	 * 
     * @see VideoEvent#UNSUPPORTED_PLAYER_VERSION
     *
	 * @tiptext unsupportedPlayerVersion event
	 * @eventType fl.video.VideoEvent.UNSUPPORTED_PLAYER_VERSION
	 * 
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("unsupportedPlayerVersion", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when entering the stopped state.
	 * This happens when you call the <code>stop()</code> method or click the 
	 * <code>stopButton</code> control. It also happens, in some cases, if the 
	 * <code>autoPlay</code> property is 
	 * <code>false</code> (the state might become paused
	 * instead) when the FLV file is loaded. The FLVPlayback instance also dispatches this 
	 * event when the playhead stops at the end of the FLV file
	 * because it has reached the end of the timeline. 
	 *
	 * <p>The FLVPlayback instance also dispatches the <code>stateChange</code> event.</p>
	 *
	 * <p>The <code>stoppedStateEntered</code> event is of type VideoEvent and has the constant 
	 * <code>VideoEvent.STOPPED_STATE_ENTERED</code>.</p>
	 * 
	 * @see #autoPlay 
	 * @see #event:stateChange stateChange event
	 * @see #stop() 
	 * @see VideoState#STOPPED 
	 * @see VideoEvent#STOPPED_STATE_ENTERED 
	 * 
	 * @tiptext stopped event
	 * @eventType fl.video.VideoEvent.STOPPED_STATE_ENTERED
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("stoppedStateEntered", type="fl.video.VideoEvent")]

	/**
	 * Dispatched when sound changes by the user either moving the handle of the 
	 * volumeBar control or setting the <code>volume</code> or <code>soundTransform</code> 
	 * property.  
	 * 
	 * <p>The <code>soundUpdate</code> event is of type SoundEvent and has the constant 
	 * <code>SoundEvent.SOUND_UPDATE</code>.</p>
	 * 
	 * @see #soundTransform 
	 * @see SoundEvent#SOUND_UPDATE 
	 * @see #volume 
	 * 
	 * @tiptext soundUpdate event
	 * @eventType fl.video.SoundEvent.SOUND_UPDATE
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("soundUpdate", type="fl.video.SoundEvent")]

	[IconFile("FLVPlayback.png")]
	[minimumPlayerVersion("10")]
	[RequiresDataBinding(true)]
	[LivePreviewVersion("1")]

    /**
     * FLVPlayback extends the Sprite class and wraps a VideoPlayer object. 
	 * 
	 * <hr/>
     * <strong>NOTE: </strong> This documentation is intended for use with the FLVPlayback with Accessibility component.
	 * <p>It updates the ActionScript 3.0 Language and Components Reference for the FLVPlayback class to include the following 
	 * properties and methods which were added to improve the component's keyboard and screenreader accessibility.</p>
	 * <br/>
	 * <div class="seeAlso">
	 *  <a href="#assignTabIndexes()"><code>assignTabIndexes()</code></a><br/>
	 * 	<a href="#startTabIndex"><code>startTabIndex</code></a><br/>
	 * 	<a href="#endTabIndex"><code>endTabIndex</code></a>
	 * </div>
	 * 
	 * <p>Make sure you are including the &quot; with Accessibility&quot; version of the component in your project 
	 * before attempting to access the new properties or methods.</p> 
	 * <hr/>
	 * 
     * 
     * <p>The FLVPlayback class allows you to include a video player in your application to play 
     * progressively downloaded video (FLV) files over HTTP, or play streaming FLV files 
     * from Flash Media Server (FMS) or other Flash Video Streaming Service (FVSS).</p>
     * 
     * <p>Unlike other ActionScript 3.0 components, the FLVPlayback component does not extend 
     * UIComponent; therefore, it does not support the methods and properties of that class.</p>
     * 
     * <p>To access the properties, methods, and events of the FLVPlayback class, you must import the
     * class to your application either by dragging the FLVPlayback component to the Stage in your Flash
     * application, or by explicitly importing it in ActionScript using the <code>import</code> statement.
     * The following statement imports the FLVPlayback class:</p>
     * 
     * <listing>
     * import fl.video.FLVPlayback;</listing>
     * 
     * <p>The FLVPlayback class has a <code>VERSION</code> constant, which is a class property. Class properties are
     * available only on the class itself. The <code>VERSION</code> constant returns a string that indicates the 
     * version of the component. The following code shows the version in the Output panel:</p>
     * 
     * <listing>
     * import fl.video.FLVPlayback;
     * trace(FLVPlayback.VERSION);</listing>
     * 
     * @see AutoLayoutEvent 
     * @see FLVPlaybackCaptioning 
     * @see MetadataEvent 
     * @see NCManager 
     * @see LayoutEvent 
     * @see SoundEvent 
     * @see VideoPlayer 
     * @see VideoError 
     * @see VideoEvent 
     * @see VideoProgressEvent 
     *
     * @includeExample examples/FLVPlaybackExample.as -noswf
     * 
     * @tiptext	FLVPlayback
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	public class FLVPlayback extends Sprite {

		include "ComponentVersion.as"

		//
		// private instance vars
		//

		/**
		 * bounding box movie clip inside of component on stage
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var boundingBox_mc:DisplayObject;

		// stuff for live preview in authoring
		private var preview_mc:MovieClip;
		private var previewImage_mc:Loader;
		private var previewImageUrl:String;
		private var isLivePreview:Boolean;
		private var livePreviewWidth:Number;
		private var livePreviewHeight:Number;

		// flag that tells us whether the authoring tool is setting
		// our properties from the component inspector right now
		private var _componentInspectorSetting:Boolean;

		// the VideoPlayers
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal var videoPlayers:Array;
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal var videoPlayerStates:Array;
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal var videoPlayerStateDict:Dictionary;
		private var _activeVP:uint;
		private var _visibleVP:uint;
		private var _topVP:uint;

		// the UIManager
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal var uiMgr:UIManager;

		// the CuePointManagers (one for each VideoPlayer)
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal var cuePointMgrs:Array;

		// state
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal var _firstStreamReady:Boolean;
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal var _firstStreamShown:Boolean; // true once we have shown the first stream
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal var resizingNow:Boolean;
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal var skinShowTimer:Timer;
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal static const DEFAULT_SKIN_SHOW_TIMER_INTERVAL:Number = 2000;
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal static const skinShowTimerInterval:Number = DEFAULT_SKIN_SHOW_TIMER_INTERVAL;

		// properties
		private var _align:String;
		private var _autoRewind:Boolean;
		private var _bufferTime:Number;
		private var _idleTimeout:Number;
		private var _aspectRatio:Boolean;
		private var _playheadUpdateInterval:Number;
		private var _progressInterval:Number;
		private var _origWidth:Number;
		private var _origHeight:Number;
		private var _scaleMode:String;
		private var _seekToPrevOffset:Number;
		private var _soundTransform:SoundTransform;
		private var _volume:Number;

		// force the compilation of the NCManager Classes
		private var __forceNCMgr:NCManager;
		private var __forceNCMgrNative:NCManagerNative;
		private var __forceNCMgrDynamicStream:NCManagerDynamicStream;
		// for verifying RTMP URI's
		private var _rtmpProtocols:Array;

		//ifdef DEBUG
		//private var _debuggingOn:Boolean = false;
		//private var _debugFn:Function = null;
		//endif

		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const SEEK_TO_PREV_OFFSET_DEFAULT:Number = 1;

		//
		// public methods
		//

		/**
         * Creates a new FLVPlayback instance. After creating the FLVPlayback 
		 * instance, call the <code>addChild()</code> or <code>addChildAt()</code> 
		 * method to place the instance on the Stage or another display object container.
		 * 
		 * @see flash.display.DisplayObjectContainer#addChild() DisplayObjectContainer#addChild()
         * 
		 * @tiptext FLVPlayback constructor
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function FLVPlayback() {
			// allows clicks to pass through for alpha video
			mouseEnabled = false;

			// determine if we are in live preview mode
			isLivePreview = (parent != null && getQualifiedClassName(parent) == "fl.livepreview::LivePreviewParent");

			// flag used to tell if we are being configured by the
			// component inspector right now.  This flag is set
			// by code generated by the authoring tool.  Unlike
			// with AS2 components, the properties are NOT set
			// before the constructor is called.
			_componentInspectorSetting = false;

			// have to manage our own height and width and set scale
			// to 100 otherwise VideoPlayer and skins within component
			// will be scaled.
			var r:Number = rotation;
			rotation = 0;
			_origWidth = super.width;
			_origHeight = super.height;
			super.scaleX = 1;
			super.scaleY = 1;
			rotation = r;

			// first create first VideoPlayer, we will use it to take
			// property default values so we match VideoPlayer
			// defaults and then we will configure it up later when
			// createVideoPlayer() is called
			var vp:VideoPlayer = new VideoPlayer(0, 0);
			vp.setSize(_origWidth, _origHeight);
			videoPlayers = new Array();
			videoPlayers[0] = vp;

			// set properties to defaults note that these defaults are
			// in line with the VideoPlayer defaults, so they do not
			// have to be set on the VideoPlayer object as well.

			_align = vp.align;
			_autoRewind = vp.autoRewind;
			_scaleMode = vp.scaleMode;
			_bufferTime = vp.bufferTime;
			_idleTimeout = vp.idleTimeout;
			_playheadUpdateInterval = vp.playheadUpdateInterval;
			_progressInterval = vp.progressInterval;
			_soundTransform = vp.soundTransform;
			_volume = vp.volume;

			// set defaults not related to VideoPlayer defaults
			_seekToPrevOffset = SEEK_TO_PREV_OFFSET_DEFAULT;

			// state
			_firstStreamReady = false;
			_firstStreamShown = false;
			resizingNow = false;
			
			// create UIManager
			uiMgr = new UIManager(this);
			if (isLivePreview) {
				uiMgr.visible = true;
			}

			// create VideoPlayer and CuePointManager
			_activeVP = 0;
			_visibleVP = 0;
			_topVP = 0;
			videoPlayerStates = new Array();
			videoPlayerStateDict = new Dictionary(true);
			cuePointMgrs = new Array();
			createVideoPlayer(0);

			// remove boundingBox_mc
			if(boundingBox_mc)
			{
			boundingBox_mc.visible = false;
			removeChild(boundingBox_mc);
			}
			boundingBox_mc = null;

			// setup live preview look
			if (isLivePreview) {
				previewImageUrl = "";
				createLivePreviewMovieClip();
				setSize(_origWidth, _origHeight);
			}
			
			_rtmpProtocols = new Array("rtmp","rtmpt","rtmpe","rtmpte","rtmps","rtmfp");
		}

        /**
         * Sets width and height simultaneously. Because setting either one, 
         * individually, can cause automatic resizing, setting them simultaneously 
         * is more efficient than setting the <code>width</code> and <code>height</code>
         * properties individually.
         *
         * <p>If <code>scaleMode</code> property is set to
         * <code>VideoScaleMode.MAINTAIN_ASPECT_RATIO</code> or <code>VideoScaleMode.NO_SCALE</code>, then
         * calling this causes an immediate <code>autolayout</code> event.</p>
         *
         * @param width A number that specifies the width of the video player.
         * 
         * @param height A number that specifies the height of the video player.
         * 
         * @see #width 
         * @see #height 
         * @see VideoScaleMode 
         * 
         * @tiptext setSize method
         * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function setSize(width:Number, height:Number):void
		{
			var oldBounds:Rectangle = new Rectangle(x, y, this.width, this.height);
			var oldRegistrationBounds:Rectangle = new Rectangle(registrationX, registrationY, registrationWidth, registrationHeight);

			if (isLivePreview) {
				livePreviewWidth = width;
				livePreviewHeight = height;

				if (previewImage_mc != null) {
					previewImage_mc.width = width;
					previewImage_mc.height = height;
				}

				preview_mc.box_mc.width = width;
				preview_mc.box_mc.height = height;

				if ( preview_mc.box_mc.width < preview_mc.icon_mc.width ||
				     preview_mc.box_mc.height < preview_mc.icon_mc.height ) {
					preview_mc.icon_mc.visible = false;
				} else {
					preview_mc.icon_mc.visible = true;
					preview_mc.icon_mc.x = (preview_mc.box_mc.width - preview_mc.icon_mc.width) / 2;
					preview_mc.icon_mc.y = (preview_mc.box_mc.height - preview_mc.icon_mc.height) / 2;
				}

				dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT, false, false, oldBounds, oldRegistrationBounds));
				return;
			}

			// flag to avoid sending multiple layout events if autolayout occurs
			resizingNow = true;
			for (var i:int = 0; i < videoPlayers.length; i++) {
				var vp:VideoPlayer = videoPlayers[i];
				if (vp != null) vp.setSize(width, height);
			}
			resizingNow = false;

			dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT, false, false, oldBounds, oldRegistrationBounds));
		}

		/**
		 * Sets the <code>scaleX</code> and <code>scaleY</code> properties simultaneously. 
		 * Because setting either one, individually, can cause automatic
		 * resizing, setting them simultaneously can be more efficient 
		 * than setting the <code>scaleX</code> and <code>scaleY</code> properties individually.
		 * 
		 * <p>If <code>scaleMode</code> property is set to
		 * <code>VideoScaleMode.MAINTAIN_ASPECT_RATIO</code> or <code>VideoScaleMode.NO_SCALE</code>, then
		 * calling this causes an immediate <code>autolayout</code> event.</p>
		 *
		 * @param scaleX A number representing the horizontal scale.
		 * @param scaleY A number representing the vertical scale.
		 * 
		 * @see #scaleX 
                 * @see #scaleY 
                 * @see VideoScaleMode
                 *
		 * @tiptext setScale method
		 * 
                 * @langversion 3.0
                 * @playerversion Flash 9.0.28.0
		 */
		public function setScale(scaleX:Number, scaleY:Number):void {
			var oldBounds:Rectangle = new Rectangle(x, y, width, height);
			var oldRegistrationBounds:Rectangle = new Rectangle(registrationX, registrationY, registrationWidth, registrationHeight);

			// flag to avoid sending multiple layout events if autolayout occurs
			resizingNow = true;
			for (var i:int = 0; i < videoPlayers.length; i++) {
				var vp:VideoPlayer = videoPlayers[i];
				if (vp !== null) vp.setSize(_origWidth * scaleX, _origWidth * scaleY);
			}
			resizingNow = false;

			dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT, false, false, oldBounds, oldRegistrationBounds));
		}

		/**
		 * handles events
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function handleAutoLayoutEvent(e:AutoLayoutEvent):void {
			var vpState:VideoPlayerState = videoPlayerStateDict[e.currentTarget];

			var eCopy:AutoLayoutEvent = AutoLayoutEvent(e.clone());
			// adjust x and y values into FLVPlayback coordinate space
			eCopy.oldBounds.x += super.x;
			eCopy.oldBounds.y += super.y;
			eCopy.oldRegistrationBounds.x += super.y;
			eCopy.oldRegistrationBounds.y += super.y;
			// set the vp index
			eCopy.vp = vpState.index;
			dispatchEvent(eCopy);

			if (!resizingNow && vpState.index == _visibleVP) {
				var oldBounds:Rectangle = Rectangle(e.oldBounds.clone());
				var oldRegistrationBounds:Rectangle = Rectangle(e.oldRegistrationBounds.clone());
				// adjust x and y values into FLVPlayback coordinate space
				oldBounds.x += super.x;
				oldBounds.y += super.y;
				oldRegistrationBounds.x += super.y;
				oldRegistrationBounds.y += super.y;
				dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT, false, false, oldBounds, oldRegistrationBounds));
			}
		}

		/**
		 * handles events
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function handleMetadataEvent(e:MetadataEvent):void {
			var vpState:VideoPlayerState = videoPlayerStateDict[e.currentTarget];

			var cpMgr:CuePointManager = cuePointMgrs[vpState.index];
			switch (e.type) {
			case MetadataEvent.METADATA_RECEIVED:
				cpMgr.processFLVCuePoints(e.info.cuePoints);
				break;
			case MetadataEvent.CUE_POINT:
				if (!cpMgr.isFLVCuePointEnabled(e.info)) {
					return;
				}
				break;
			}

			var eCopy:MetadataEvent = MetadataEvent(e.clone());
			eCopy.vp = vpState.index;
			dispatchEvent(eCopy);
		}

		/**
		 * handles events
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function handleVideoProgressEvent(e:VideoProgressEvent):void {
			var vpState:VideoPlayerState = videoPlayerStateDict[e.currentTarget];

			var eCopy:VideoProgressEvent = VideoProgressEvent(e.clone());
			eCopy.vp = vpState.index;
			dispatchEvent(eCopy);
		}

		/**
		 * handles events
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function handleVideoEvent(e:VideoEvent):void {
			var vpState:VideoPlayerState = videoPlayerStateDict[e.currentTarget];
			var cpMgr:CuePointManager = cuePointMgrs[vpState.index];

			var eCopy:VideoEvent = VideoEvent(e.clone());
			eCopy.vp = vpState.index;

			// change staet to SEEKING if we are scrubbing to smooth out the rough edges
			var smoothState:String = (vpState.index == _visibleVP && scrubbing) ? VideoState.SEEKING : e.state;

			switch (e.type) {
			case VideoEvent.AUTO_REWOUND:
				dispatchEvent(eCopy);
				dispatchEvent(new VideoEvent(VideoEvent.REWIND, false, false, smoothState, e.playheadTime, vpState.index));
				cpMgr.resetASCuePointIndex(e.playheadTime);
				break;
			case VideoEvent.PLAYHEAD_UPDATE:
				eCopy.state = smoothState;
				dispatchEvent(eCopy);
				if (!isNaN(vpState.preSeekTime) && e.state != VideoState.SEEKING) {
					var cachePreSeekTime:Number = vpState.preSeekTime;
					vpState.preSeekTime = NaN;
					cpMgr.resetASCuePointIndex(e.playheadTime);
					dispatchEvent(new VideoEvent(VideoEvent.SEEKED, false, false, e.state, e.playheadTime, vpState.index));
					if (cachePreSeekTime < e.playheadTime) {
						dispatchEvent(new VideoEvent(VideoEvent.FAST_FORWARD, false, false, e.state, e.playheadTime, vpState.index));
					} else if (cachePreSeekTime > e.playheadTime) {
						dispatchEvent(new VideoEvent(VideoEvent.REWIND, false, false, e.state, e.playheadTime, vpState.index));
					}
				}
				cpMgr.dispatchASCuePoints();
				break;
			case VideoEvent.STATE_CHANGE:
				// suppress stateChange events while scrubbing
				if (vpState.index == _visibleVP && scrubbing) break;;

				// suppress RESIZING state, just needed for internal
				// VideoPlayer use anyways, make it LOADING, less confusing
				// for user, esp when suppressing STOPPED as we do below...
				if (e.state == VideoState.RESIZING) break;

				// suppress STOPPED stateChange at beginning when autoPlay
				// is on and waiting for skin to download to show all at once
				if (vpState.prevState == VideoState.LOADING && vpState.autoPlay && e.state == VideoState.STOPPED) {
					return;
				}

				// if we have a connection error on visible VP and we haven't gone visible yet, do so
				if (e.state == VideoState.CONNECTION_ERROR && e.vp == _visibleVP && !_firstStreamShown && uiMgr.skinReady) {
					showFirstStream();
					uiMgr.visible = true;
					if (uiMgr.skin == "") {
						uiMgr.hookUpCustomComponents();
					}
					if (skinShowTimer != null) {
						skinShowTimer.reset();
						skinShowTimer = null;
					}
				}

				vpState.prevState = e.state;
				eCopy.state = smoothState;
				dispatchEvent(eCopy);

				// check to be sure did not change out from under me before dispatching second event
				if (vpState.owner.state != e.state) return;

				switch (e.state) {
				case VideoState.BUFFERING:
					dispatchEvent(new VideoEvent(VideoEvent.BUFFERING_STATE_ENTERED, false, false, smoothState, e.playheadTime, vpState.index));
					break;
				case VideoState.PAUSED:
					dispatchEvent(new VideoEvent(VideoEvent.PAUSED_STATE_ENTERED, false, false, smoothState, e.playheadTime, vpState.index));
					break;
				case VideoState.PLAYING:
					dispatchEvent(new VideoEvent(VideoEvent.PLAYING_STATE_ENTERED, false, false, smoothState, e.playheadTime, vpState.index));
					break;
				case VideoState.STOPPED:
					dispatchEvent(new VideoEvent(VideoEvent.STOPPED_STATE_ENTERED, false, false, smoothState, e.playheadTime, vpState.index));
					break;
				} // switch

				break;
			case VideoEvent.READY:
				if (!_firstStreamReady) {
					if (vpState.index == _visibleVP) {
						_firstStreamReady = true;
						if (uiMgr.skinReady && !_firstStreamShown) {
							uiMgr.visible = true;
							if (uiMgr.skin == "") {
								uiMgr.hookUpCustomComponents();
							}
							showFirstStream();
						}
					}
				} else if (_firstStreamShown && e.state == VideoState.STOPPED && vpState.autoPlay) {
					if (vpState.owner.isRTMP) {
						vpState.owner.play();
					} else {
						vpState.prevState = VideoState.STOPPED;
						vpState.owner.playWhenEnoughDownloaded();
					}
				}
				eCopy.state = smoothState;
				dispatchEvent(eCopy);
				break;
			case VideoEvent.CLOSE:
			case VideoEvent.COMPLETE:
				eCopy.state = smoothState;
				dispatchEvent(eCopy);
				break;
			case VideoEvent.UNSUPPORTED_PLAYER_VERSION:
				dispatchEvent(eCopy);
				break;
			} // switch
		}

		/**
		 * Begins loading the FLV file and provides a shortcut for setting the 
		 * <code>autoPlay</code> property to <code>false</code> and setting the 
		 * <code>source</code>, <code>totalTime</code>, and <code>isLive</code> 
		 * properties, if given. If the <code>totalTime</code> and <code>isLive</code> 
		 * properties are undefined, they are not set. If the <code>source</code> 
		 * property is undefined, <code>null</code>, or an empty string, this method 
		 * does nothing.
		 *
		 * @param source A string that specifies the URL of the FLV file to stream 
		 * and how to stream it. The URL can be a local path, an HTTP URL to an FLV file, 
		 * an RTMP URL to an FLV file stream, or an HTTP URL to an XML file.
		 * 
		 * @param totalTime A number that is the total playing time for the video. Optional.
		 * 
		 * @param isLive A Boolean value that is <code>true</code> if the video stream is live. 
		 * This value is effective only when streaming from Flash Media Server (FMS) or other Flash 
		 * Video Streaming Service (FVSS). The value of 
		 * this property is ignored for an HTTP download. Optional.
		 * 
		 * @see #autoPlay 
		 * @see #source 
		 * @see #isLive 
                 * @see #totalTime 
                 *
		 * @tiptext load method
		 * 
                 * @langversion 3.0
                 * @playerversion Flash 9.0.28.0
		 */
		public function load(source:String, totalTime:Number=NaN, isLive:Boolean=false):void {
			if (source == null || source.length == 0) {
				return;
			}
			if (source == this.source) {
				return;
			}
			this.autoPlay = false;
			this.totalTime = totalTime;
			this.isLive = isLive;
			this.source = source;
		}

		/**
		 * Plays the video stream. With no parameters, the method simply takes the FLV 
		 * file from a paused or stopped state to the playing state.
		 * 
		 * <p>If parameters are used, the method acts as a shortcut for setting the 
		 * <code>autoPlay</code> property to <code>true</code> and setting the <code>isLive</code>, 
		 * <code>totalTime</code> and, <code>source</code>
		 * properties. If the <code>totalTime</code> and <code>isLive</code> properties are undefined, 
		 * they are not set. </p>
		 *
		 * <p>When waiting for enough of a progressive download FLV to load before playing
		 * starts automatically, call the <code>play()</code> method with no parameters
		 * to force playback to start immediately.</p>
		 * 
		 * @param source A string that specifies the URL of the FLV file to stream 
		 * and how to stream it. The URL can be a local path, an HTTP URL to an FLV file, 
		 * an RTMP URL to an FLV file stream, or an HTTP URL to an XML file. It is optional, 
		 * but the <code>source</code> property must be set either through the 
		 * Component inspector or through ActionScript or this method has no effect.
		 * 
		 * @param totalTime A number that is the total playing time for the video. Optional.
		 * 
		 * @param isLive A Boolean value that is <code>true</code> if the video stream is live. 
		 * This value is effective only when streaming from Flash Media Server (FMS) or other Flash Video Streaming Service (FVSS). 
		 * The value of this property is ignored for an HTTP download. Optional.
		 * 
		 * @see #autoPlay 
		 * @see #source 
		 * @see #isLive 
         * @see #totalTime 
         *
		 * @tiptext play method
		 * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function play(source:String=null, totalTime:Number=NaN, isLive:Boolean=false):void {
			if (source == null) {
				if (!_firstStreamShown) {
					var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
					queueCmd(vpState, QueuedCommand.PLAY);
				} else {
					var vp:VideoPlayer = videoPlayers[_activeVP];
					vp.play();
				}
			} else {
				if (source == this.source) {
					return;
				}
				this.autoPlay = true;
				this.totalTime = totalTime;
				this.isLive = isLive;
				this.source = source;
			}
		}
		
		/**
		 * Plays a stream using the Dynamic Streaming feature.  You will need to create a new
		 * DynamicStreamItem and pass that as an argument in play2.  The component will then
		 * automatically switch between the available bit rates passed in with the streams to 
		 * play the most appropriate stream bit rate for the users available bandwidth at that time.
		 * 
		 * @param dsi A DynamicStreamItem object containing the URI, streams and stream bit rates.
		 * 
		 */
		public function play2(dsi:DynamicStreamItem):void {
			
			if(!(dsi.uri is String) || dsi.uri == "" || _rtmpProtocols.indexOf(dsi.uri.split(":")[0].toLowerCase()) == -1){
				throw new VideoError(VideoError.INVALID_SOURCE, "You must specify a RTMP URL to connect to.");
			}
			
			var vp:VideoPlayer = videoPlayers[_activeVP];
			var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
				vp.play2(dsi);
			vpState.isLiveSet = false;
			vpState.totalTimeSet = false;
			vpState.isWaiting = false;					
		}
		
		/**
		 * Plays the FLV file when enough of it has downloaded. If the FLV file has 
		 * downloaded or you are streaming from Flash Media Server (FMS), then calling the 
		 * <code>playWhenEnoughDownloaded()</code> method
		 * is identical to the <code>play()</code> method with no parameters.  Calling this
		 * method does not pause playback, so in many cases, you may want to call the <code>pause()</code> method
         * before you call this method.
         *
		 * @tiptext playWhenEnoughDownloaded method
		 * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function playWhenEnoughDownloaded():void {
			if (!_firstStreamShown) {
				var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
				queueCmd(vpState, QueuedCommand.PLAY_WHEN_ENOUGH);
			} else {
				var vp:VideoPlayer = videoPlayers[_activeVP];
				vp.playWhenEnoughDownloaded();
			}
		}

	/**
         * Pauses playing the video stream. 
         *
         * <p>If playback has begun and you want to 
         * return to the state of waiting for enough to download and then automatically 
         * begin playback, call the <code>pause()</code> method, and then the 
         * <code>playWhenEnoughDownloaded()</code> method.</p>
         *
	 * @tiptext pause method
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function pause():void {
			if (!_firstStreamShown) {
				var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
				queueCmd(vpState, QueuedCommand.PAUSE);
			} else {
				var vp:VideoPlayer = videoPlayers[_activeVP];
				vp.pause();
			}
		}

		/**
		 * Stops the video from playing. 
		 * If the <code>autoRewind</code> property is <code>true</code>, 
         * the FLV file rewinds to the beginning.
         *
		 * @tiptext stop method
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function stop():void {
			if (!_firstStreamShown) {
				var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
				queueCmd(vpState, QueuedCommand.STOP);
			} else {
				var vp:VideoPlayer = videoPlayers[_activeVP];
				vp.stop();
			}
		}

		/**
		 * Seeks to a given time in the file, specified in seconds, 
		 * with a precision of three decimal places (milliseconds).
		 *
		 * <p>For several reasons, the <code>playheadTime</code> property might not 
		 * have the expected value immediately after you call one of 
		 * the seek methods or set <code>playheadTime</code> to cause seeking. 
		 * First, for a progressive download, you can seek only to a 
		 * keyframe, so a seek takes you to the time of the first 
		 * keyframe after the specified time. (When streaming, a seek 
		 * always goes to the precise specified time even if the source 
		 * FLV file doesn't have a keyframe there.) Second, seeking 
		 * is asynchronous, so if you call a seek method or set the 
		 * <code>playheadTime</code> property, <code>playheadTime</code> does not update immediately. 
		 * To obtain the time after the seek is complete, listen for the 
		 * seek event, which does not start until the <code>playheadTime</code> property 
		 * has updated.</p>
		 * 
		 * @param time A number that specifies the time, in seconds, at which to 
		 * place the playhead.
		 * 
		 * @throws fl.video.VideoError If time is &lt; 0.
		 * 
         * @see VideoPlayer#seek()
         *
		 * @tiptext seek method
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function seek(time:Number):void {
			var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
			if (!_firstStreamShown) {
				vpState.preSeekTime = 0;
				queueCmd(vpState, QueuedCommand.SEEK, time);
			} else {
				vpState.preSeekTime = playheadTime;
				var vp:VideoPlayer = videoPlayers[_activeVP];
				vp.seek(time);
			}
		}

		/**
		 * Seeks to a given time in the file, specified in seconds, with a precision up to 
		 * three decimal places (milliseconds). This method performs the same operation as the 
		 * <code>seek()</code> method; it is provided for symmetry with the <code>seekPercent()</code>
		 * method.
		 * 
		 * <p>For several reasons, the <code>playheadTime</code> property might not have the expected 
		 * value immediately after you call one of the seek methods or set <code>playheadTime</code> 
		 * to cause seeking. First, for a progressive download, you can seek only to a 
		 * keyframe, so a seek takes you to the time of the first keyframe after the 
		 * specified time. (When streaming, a seek always goes to the precise specified 
		 * time even if the source FLV file doesn't have a keyframe there.) Second, 
		 * seeking is asynchronous, so if you call a seek method or set the <code>playheadTime</code> 
		 * property, <code>playheadTime</code> does not update immediately. To obtain the time after 
		 * the seek is complete, listen for the seek event, which does not start until 
		 * the <code>playheadTime</code> property has updated. </p>
		 *
		 * @param time A number that specifies the time, in seconds, 
		 * of the total play time at which to place the playhead.
		 * 
         * @see #seek()
         *
		 * @tiptext seekSeconds method
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function seekSeconds(time:Number):void {
			seek(time);
		}

		/**
		 * Seeks to a percentage of the file and places the playhead there. 
		 * The percentage is a number between 0 and 100.
		 * 
		 * <p>For several reasons, the <code>playheadTime</code> property might not have 
		 * the expected value immediately after you call one of the seek 
		 * methods or set <code>playheadTime</code> to cause seeking. First, for 
		 * a progressive download, you can seek only to a keyframe, 
		 * so a seek takes you to the time of the first keyframe after 
		 * the specified time. (When streaming, a seek always goes 
		 * to the precise specified time even if the source FLV file 
		 * doesn't have a keyframe there.) Second, seeking is asynchronous, 
		 * so if you call a seek method or set the <code>playheadTime</code> property, 
		 * <code>playheadTime</code> does not update immediately. To obtain the time 
		 * after the seek is complete, listen for the seek event, which 
		 * does not start until the <code>playheadTime</code> property has updated.</p>
		 * 
		 * @param A number that specifies a percentage of the length of the FLV file 
		 * at which to place the playhead.
		 *
		 * @throws fl.video.VideoError If <code>percent</code> is invalid or if <code>totalTime</code> is
		 * undefined, <code>null</code> or &lt;= 0.
         * @see #seek()
         *
		 * @tiptext seekPercent method
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function seekPercent(percent:Number):void {
			var vp:VideoPlayer = videoPlayers[_activeVP];
			if ( isNaN(percent) || percent < 0 || percent > 100 ||
			     isNaN(vp.totalTime) || vp.totalTime <= 0 ) {
				throw new VideoError(VideoError.INVALID_SEEK);
			}
			seek(vp.totalTime * percent / 100);
		}
		
		/**
		 * A number that specifies the current <code>playheadTime</code> as a percentage of the 
		 * <code>totalTime</code> property. If you access this property, it contains the percentage 
		 * of playing time that has elapsed. If you set this property, it causes a seek 
		 * operation to the point representing that percentage of the FLV file's playing time.
		 * 
		 * <p>The value of this property is relative to the value of the <code>totalTime</code> 
		 * property.</p>
		 * 
		 * @throws fl.video.VideoError If you specify a percentage that is invalid or if the 
		 * <code>totalTime</code> property is
		 * undefined, <code>null</code>, or less than or equal to zero.	 
         * 
		 * @tiptext playheadPercentage method
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get playheadPercentage():Number
		{
			var vp:VideoPlayer = videoPlayers[_activeVP];
			if (isNaN(vp.totalTime)) return NaN
			return (vp.playheadTime / vp.totalTime * 100);
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set playheadPercentage(percent:Number):void
		{
			seekPercent(percent);
		}

        [Inspectable(type="Video Preview")]
		/**
         * Only for live preview. Reads in a PNG file for the preview.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set preview(filename:String):void
		{
			if (!isLivePreview) return;
			previewImageUrl = filename;
			if (previewImage_mc != null) {
				removeChild(previewImage_mc);
			}
			previewImage_mc = new Loader();
			previewImage_mc.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompletePreview);
			previewImage_mc.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void { });
			previewImage_mc.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void { });
			addChildAt(previewImage_mc, 1);
			previewImage_mc.load(new URLRequest(previewImageUrl));
		}

		/**
		 * Seeks to a navigation cue point that matches the specified time, name, or 
		 * time and name.
		 *
		 * <p>The time is the starting time, in seconds, 
		 * from which to look for the next navigation cue point. The default is the 
		 * current <code>playheadTime</code> property. If you specify a time, the method seeks 
		 * to a cue point that matches that time or is later. If time is undefined, 
		 * <code>null</code>, or less than 0, the method starts its 
		 * search at time 0.</p>
		 *
		 * <p>The name is the cue point to seek. The method seeks to the first enabled navigation 
		 * cue point with this name. </p>
		 * 
		 * <p>The time and name together are a navigation cue point with the specified 
		 * name at or after the specified time. 
		 * </p>
		 * 
		 * <p>For several reasons, the <code>playheadTime</code> property might not have the 
		 * expected value immediately after you call one of the seek methods or 
		 * set <code>playheadTime</code> to cause seeking. First, for a progressive 
		 * download, you can seek only to a keyframe, so a seek takes you 
		 * to the time of the first keyframe after the specified time. 
		 * (When streaming, a seek always goes to the precise specified 
		 * time even if the source FLV file doesn't have a keyframe there.) 
		 * Second, seeking is asynchronous, so if you call a seek method or 
		 * set the <code>playheadTime</code> property, <code>playheadTime</code> does not 
		 * update immediately. To obtain the time after the seek is complete, 
		 * listen for the <code>seek</code> event, 
		 * which does not start until the <code>playheadTime</code> property has updated.</p>
		 * 
		 * @param timeNameOrCuePoint A number that is the time, a string that is the name, or
		 * both a number and string that are the specified name and time.
		 * 
		 * @throws fl.video.VideoError No cue point matching the criteria is found.
		 * @see #seek()
		 * @see #seekToPrevNavCuePoint()
		 * @see #seekToNextNavCuePoint()
		 * @see #findCuePoint()
         * @see #isFLVCuePointEnabled()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function seekToNavCuePoint(timeNameOrCuePoint:*):void {
			var cuePoint:Object;
			if (timeNameOrCuePoint is String) {
				cuePoint = { name: String(timeNameOrCuePoint) };
			} else if (timeNameOrCuePoint is Number) {
				cuePoint = { time: Number(timeNameOrCuePoint) };
			} else {
				cuePoint = timeNameOrCuePoint;
			}
	
			// just seek to next if no name
			if (cuePoint.name == undefined) {
				seekToNextNavCuePoint(cuePoint.time);
				return;
			}

			// get next enabled cue point with this name
			if (isNaN(cuePoint.time)) cuePoint.time = 0;
			var navCuePoint:Object = findNearestCuePoint(timeNameOrCuePoint, CuePointType.NAVIGATION);
			while ( navCuePoint != null &&
			        ( navCuePoint.time < cuePoint.time || (!isFLVCuePointEnabled(navCuePoint)) ) ) {
				navCuePoint = findNextCuePointWithName(navCuePoint);
			}
			if (navCuePoint == null) throw new VideoError(VideoError.INVALID_SEEK);
			seek(navCuePoint.time);
		}

		/**
		 * Seeks to the next navigation cue point, based on the current value of the 
		 * <code>playheadTime</code> property. The method skips navigation cue points that have 
		 * been disabled and goes to the end of the FLV file if there is no other cue point.
		 *
		 * <p>For several reasons, the <code>playheadTime</code> property might not have the 
		 * expected value immediately after you call one of the seek methods or 
		 * set <code>playheadTime</code> to cause seeking. First, for a progressive 
		 * download, you can seek only to a keyframe, so a seek takes you 
		 * to the time of the first keyframe after the specified time. 
		 * (When streaming, a seek always goes to the precise specified 
		 * time even if the source FLV file doesn't have a keyframe there.) 
		 * Second, seeking is asynchronous, so if you call a seek method or 
		 * set the <code>playheadTime</code> property, <code>playheadTime</code> does not 
		 * update immediately. To obtain the time after the seek is complete, 
		 * listen for the <code>seek</code> event, 
		 * which does not start until the <code>playheadTime</code> property has updated.</p>
		 *
		 * @param time A number that is the starting time, in seconds, from which to look for 
		 * the next navigation cue point. The default is the current <code>playheadTime</code>
		 * property. Optional.
		 * 
		 * @see #cuePoints
		 * @see #seek()
		 * @see #seekToNavCuePoint()
		 * @see #seekToPrevNavCuePoint()
		 * @see #findCuePoint()
         * @see #isFLVCuePointEnabled()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function seekToNextNavCuePoint(time:Number=NaN):void {
			var vp:VideoPlayer = videoPlayers[_activeVP];
			if (isNaN(time) || time < 0) {
				time = vp.playheadTime + 0.001;
			}
			var cuePoint:Object = findNearestCuePoint(time, CuePointType.NAVIGATION);
			if (cuePoint == null) {
				//if no cue points could be found, go to the end
				seek(vp.totalTime);
				return;
			}
			var index:Number = cuePoint.index;
			if (cuePoint.time < time) index++;
			while (index < cuePoint.array.length && !isFLVCuePointEnabled(cuePoint.array[index])) {
				index++;
			}
			if (index >= cuePoint.array.length) {
				//if no cue points could be found, go to the end
				time = vp.totalTime;
				// if the last navigation point in the array is past what
				// we think is the end time, use that instead (even if
				// disabled).
				if (cuePoint.array[cuePoint.array.length - 1].time > time) {
					time = cuePoint.array[cuePoint.array.length - 1];
				}
				seek(time);
			} else {
				seek(cuePoint.array[index].time);
			}
		}

		/**
		 * Seeks to the previous navigation cue point, based on the current 
		 * value of the <code>playheadTime</code> property. It goes to the beginning if 
		 * there is no previous cue point. The method skips navigation cue 
		 * points that have been disabled.
		 *
         * <p>For several reasons, the <code>playheadTime</code> property might not have the 
		 * expected value immediately after you call one of the seek methods or 
		 * set <code>playheadTime</code> to cause seeking. First, for a progressive 
		 * download, you can seek only to a keyframe, so a seek takes you 
		 * to the time of the first keyframe after the specified time. 
		 * (When streaming, a seek always goes to the precise specified 
		 * time even if the source FLV file doesn't have a keyframe there.) 
		 * Second, seeking is asynchronous, so if you call a seek method or 
		 * set the <code>playheadTime</code> property, <code>playheadTime</code> does not 
		 * update immediately. To obtain the time after the seek is complete, 
		 * listen for the <code>seek</code> event, 
		 * which does not start until the <code>playheadTime</code> property has updated.</p>
		 * 
		 * @param time A number that is the starting time in seconds from which to 
		 * look for the previous navigation cue point. The default is the current 
		 * value of the <code>playheadTime</code> property. Optional.
		 * 
		 * @see #cuePoints
		 * @see #seek()
		 * @see #seekToNavCuePoint()
		 * @see #seekToNextNavCuePoint()
		 * @see #findCuePoint()
         * @see #isFLVCuePointEnabled()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function seekToPrevNavCuePoint(time:Number=NaN):void {
			if (isNaN(time) || time < 0) {
				var vp:VideoPlayer = videoPlayers[_activeVP];
				time = vp.playheadTime;
			}
			var cuePoint:Object = findNearestCuePoint(time, CuePointType.NAVIGATION);
			if (cuePoint == null) {
				// if no cue points could be found, go to the beginning
				seek(0);
				return;
			}
			var index:Number = cuePoint.index;
			while ( index >= 0 &&
			        ( !isFLVCuePointEnabled(cuePoint.array[index]) ||
			          cuePoint.array[index].time >= time - _seekToPrevOffset ) ) {
				index--;
			}
			if (index < 0) {
				seek(0);
			} else {
				seek(cuePoint.array[index].time);
			}
		}

		/**
		 * Adds an ActionScript cue point and has the same effect as adding an ActionScript 
		 * cue point using the Cue Points dialog box, except that it occurs when an application 
		 * executes rather than during application development.
		 * 
		 * <p>Cue point information is wiped out when the <code>source</code> property is 
		 * set. To set cue point information for the next FLV file to be loaded, 
		 * set the <code>source</code> property first.</p>
		 * 
		 * <p>It is valid to add multiple ActionScript cue points with the same name and time. 
		 * When you remove ActionScript cue points with the <code>removeASCuePoint()</code> 
		 * method, all cue points with the same name and time are removed.</p>
		 *
		 * @param timeOrCuePoint An object having <code>name</code> and 
		 * <code>time</code> properties, which describe the cue point. It also might have a 
		 * <code>parameters</code> property that holds name/value pairs. It may have the
		 * <code>type</code> property set 
		 * to "<code>actionscript</code>". If the type is missing or set to something else, it is set 
		 * automatically. If the object does not conform to these conventions, the 
		 * method throws a VideoError error.
		 *
		 * <p>The <code>time</code> property sets the time in seconds for a new cue point 
		 * to be added and the <code>name</code> parameter must follow.</p>
		 * 
		 * @param name A string that specifies the name of the cue point if you submit 
		 * a <code>time</code> parameter instead of the cue point.

		 * @param parameters Optional parameters for the cue point if the
		 * <code>timeOrCuePoint</code> parameter is a number.
		 * 
		 * @return The cue point object that was added. Edits to this
		 * object affect the <code>cuePoint</code> event dispatch.
		 * 
		 * @throws fl.video.VideoError Parameters are invalid.
		 * 
		 * @see #findCuePoint() 
         * @see #removeASCuePoint() 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function addASCuePoint(timeOrCuePoint:*, name:String=null, parameters:Object=null):Object {
			var cpMgr:CuePointManager = cuePointMgrs[_activeVP];
			return cpMgr.addASCuePoint(timeOrCuePoint, name, parameters);
		}

		/**
		 * Removes an ActionScript cue point from the currently loaded FLV file. 
		 * Only the <code>name</code> and <code>time</code> properties are used from the
		 * <code>timeNameOrCuePoint</code> parameter to find the cue point to remove.
		 *
		 * <p>If multiple ActionScript cue points match the search criteria, only one is removed. 
		 * To remove all, call this function repeatedly in a loop with the same parameters 
		 * until it returns <code>null</code>.</p>
		 *
		 * <p>Cue point information is wiped out when the <code>source</code> property is 
		 * set, so to set cue point information for the next FLV file to be loaded, set the 
		 * <code>source</code> property first.</p>
		 *
		 * @param timeNameOrCuePoint A cue point string that contains the <code>time</code> and 
		 * <code>name</code> properties for the cue point to remove. The method removes the 
		 * first cue point with this name.
		 * Or, if this parameter is a number, the method removes the 
		 * first cue point with this time. 
		 * If this parameter is an object, the method removes the cue point with both the 
		 * <code>time</code> and <code>name</code> properties.
		 * 
		 * @return The cue point object that was removed. If there is no
		 * matching cue point, the method returns <code>null</code>.
		 * 
		 * 
		 * @see #addASCuePoint()
         * @see #findCuePoint()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function removeASCuePoint(timeNameOrCuePoint:*):Object {
			var cpMgr:CuePointManager = cuePointMgrs[_activeVP];
			return cpMgr.removeASCuePoint(timeNameOrCuePoint);
		}

		/**
		 * Finds the cue point of the type specified by the <code>type</code> parameter and 
		 * having the time, name, or combination of time and name that you specify 
		 * through the parameters.
		 * 
		 * <p>If you do not provide a value for either the time or name of the 
		 * cue point, or if the time is <code>null</code>, undefined, or less than zero 
		 * and the name is <code>null</code> or undefined, 
		 * the method throws VideoError error 1002. </p>
		 * 
		 * <p>The method includes disabled cue points in the search. 
		 * Use the <code>isFLVCuePointEnabled()</code> method to determine 
		 * whether a cue point is disabled.</p>
		 *
		 * @param timeNameOrCuePoint This can be a number specifying a time, a string
		 * specifying a name, or an object with time and/or name properties.
		 * 
		 * <p>If this parameter is a string, the method searches for the 
		 * first cue point with this name and returns <code>null</code> if there is no match.</p>
		 *
		 * <p>If this parameter is a number, the method searches for and returns the first
		 * cue point with this time. If there are multiple cue points with the same time, 
		 * which is possible only with ActionScript cue points, the cue point with the
		 * first name alphabetically is returned. Returns <code>null</code> if there is no match.
		 * The first three decimal places for the time are used. More than
		 * three decimal places are rounded.</p>
		 * 
		 * <p>If this parameter is an object, the method searches for the cue point object 
		 * that contains the specified <code>time</code> and/or <code>name</code>
		 * properties.  If only time or name is specified, then the behavior is the same
		 * as calling with a number or a string.  If both the <code>time</code>
		 * and <code>name</code> properties are defined and a cue point object exists with both of them,
		 * then the cue point object is returned; otherwise, <code>null</code> is returned.</p>
		 *
		 * <p>If time is <code>null</code>, NaN or less than 0 and name is <code>null</code>
		 * or undefined, a VideoError object is thrown.</p>
		 *
		 * @param type A string that specifies the type of cue point for which to 
		 * search. The possible values for this parameter are <code>"actionscript"</code>, <code>"all"</code>, <code>"event"</code>, 
		 * <code>"flv"</code>, or <code>"navigation"</code>. You can specify these values using the following class 
		 * properties: <code>CuePointType.ACTIONSCRIPT</code>, <code>CuePointType.ALL</code>, <code>CuePointType.EVENT</code>, 
		 * <code>CuePointType.FLV</code>, and <code>CuePointType.NAVIGATION</code>. If this parameter 
		 * is not specified, the default is <code>"all"</code>, which means the method 
		 * searches all cue point types. Optional. 
		 * 
		 * @return An object that is a copy of the found cue point object 
		 * with the following additional properties:
		 *
		 * <ul>
		 * 
		 * <li><code>array</code>&#x2014;The array of cue points that were
		 * searched. Treat this array as read-only because adding, removing, 
		 * or editing objects within it can cause cue points to malfunction.</li>
		 *
		 * <li><code>index</code>&#x2014;The index into the array for the returned cue point.</li>
		 *
		 * </ul>
		 * 
		 * <p>Returns <code>null</code> if no match is found.</p>
		 * 
		 * @throws fl.video.VideoError If the <code>time</code> property is <code>null</code>, 
		 * undefined or less than 0 and the <code>name</code> property is <code>null</code>
		 * or undefined.
		 * 
		 * @see #addASCuePoint() 
		 * @see #cuePoints 
		 * @see #findNearestCuePoint() 
		 * @see #findNextCuePointWithName() 
		 * @see #isFLVCuePointEnabled() 
		 * @see #removeASCuePoint() 
		 * @see #seekToNavCuePoint() 
		 * @see #seekToNextNavCuePoint() 
		 * @see #seekToPrevNavCuePoint() 
         * @see #setFLVCuePointEnabled() 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function findCuePoint(timeNameOrCuePoint:*, type:String=CuePointType.ALL):Object {
			var cpMgr:CuePointManager = cuePointMgrs[_activeVP];
			switch (type) {
			case "event":
				return cpMgr.getCuePoint(cpMgr.eventCuePoints, false, timeNameOrCuePoint);
			case "navigation":
				return cpMgr.getCuePoint(cpMgr.navCuePoints, false, timeNameOrCuePoint);
			case "flv":
				return cpMgr.getCuePoint(cpMgr.flvCuePoints, false, timeNameOrCuePoint);
			case "actionscript":
				return cpMgr.getCuePoint(cpMgr.asCuePoints, false, timeNameOrCuePoint);
			case "all":
			default:
				return cpMgr.getCuePoint(cpMgr.allCuePoints, false, timeNameOrCuePoint);
			}
			return null;
		}

		/**
		 * Finds a cue point of the specified type that matches or is 
		 * earlier than the time that you specify. If you specify both 
		 * a time and a name and no earlier cue point matches that name, 
		 * it finds a cue point that matches the name that you specify. 
		 * Otherwise, it returns <code>null</code>.
		 * Default is to search all cue points. 
		 * 
		 * <p>The method includes disabled cue points in the search. Use 
		 * the <code>isFLVCuePointEnabled()</code> method to determine whether 
		 * a cue point is disabled.</p>
		 * 
		 *
		 * @param timeNameOrCuePoint This can be a number specifying a time, a string
		 * specifying a name, or an object with time and/or name properties.
		 * 
		 * <p>If this parameter is a string, the method searches for the 
		 * first cue point with this name and returns <code>null</code> if there is no match.</p>
		 *
		 * <p>If this parameter is a number then the closest cue point to this time that is
		 * an exact match or earlier will be returned.  If there is no cue point at or earlier
		 * than that time, then the first cue point is returned.
		 * If there are multiple cue points with the same time, 
		 * which is possible only with ActionScript cue points, the cue point with the
		 * first name alphabetically is returned. Returns <code>null</code> if there is no match.
		 * The first three decimal places for the time are used. More than
		 * three decimal places are rounded.</p>
		 * 
		 * <p>If this parameter is an object, the method searches for the cue point object 
		 * that contains the specified <code>time</code> and/or <code>name</code>
		 * properties.  If only time or name is specified, then the behavior is the same
		 * as calling with a number or a string.  If both the <code>time</code>
		 * and <code>name</code> properties are defined and a cue point object exists with both of them,
		 * then the cue point object is returned.  Otherwise the nearest cue point with an
		 * earlier time and the same name is returned.  If no cue point earlier than that time
		 * with that name is found <code>null</code> is returned.</p>
		 *
		 * <p>If time is <code>null</code>, undefined or less than 0 and name is <code>null</code>
		 * or undefined, a VideoError object is thrown.</p>
		 *
		 * @param type A string that specifies the type of cue point for which to 
		 * search. The possible values for this parameter are <code>"actionscript"</code>, <code>"all"</code>, <code>"event"</code>, 
		 * <code>"flv"</code>, or <code>"navigation"</code>. You can specify these values using the following class 
		 * properties: <code>CuePointType.ACTIONSCRIPT</code>, <code>CuePointType.ALL</code>, <code>CuePointType.EVENT</code>, 
		 * <code>CuePointType.FLV</code>, and <code>CuePointType.NAVIGATION</code>. If this parameter 
		 * is not specified, the default is <code>"all"</code>, which means the method 
		 * searches all cue point types. Optional. 
		 *
		 * @return An object that is a copy of the found cue point 
		 * object with the following additional properties:
		 *
		 * <ul>
		 * 
		 * <li><code>array</code>&#x2014;The array of cue points searched. 
		 * Treat this array as read-only as adding, removing or editing 
		 * objects within it can cause cue points to malfunction.</li>
		 *
		 * <li><code>index</code>&#x2014;The index into the array for the returned cue point.</li>
         * </ul>
		 * <p>Returns <code>null</code> if no match was found.</p>
		 *
		 * 
		 * 
		 * @throws fl.video.VideoError If the time is <code>null</code>, undefined, or less 
		 * than 0 and the name is <code>null</code> or undefined.
		 * 
		 * @see CuePointType#ALL
		 * @see CuePointType#EVENT
		 * @see CuePointType#NAVIGATION
		 * @see CuePointType#FLV
		 * @see CuePointType#ACTIONSCRIPT
		 * @see #cuePoints
		 * @see #addASCuePoint()
		 * @see #removeASCuePoint()
         * @see #findCuePoint()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function findNearestCuePoint(timeNameOrCuePoint:*, type:String=CuePointType.ALL):Object {
			var cpMgr:CuePointManager = cuePointMgrs[_activeVP];
			switch (type) {
			case "event":
				return cpMgr.getCuePoint(cpMgr.eventCuePoints, true, timeNameOrCuePoint);
			case "navigation":
				return cpMgr.getCuePoint(cpMgr.navCuePoints, true, timeNameOrCuePoint);
			case "flv":
				return cpMgr.getCuePoint(cpMgr.flvCuePoints, true, timeNameOrCuePoint);
			case "actionscript":
				return cpMgr.getCuePoint(cpMgr.asCuePoints, true, timeNameOrCuePoint);
			case "all":
			default:
				return cpMgr.getCuePoint(cpMgr.allCuePoints, true, timeNameOrCuePoint);
			}
			return null;
		}

		/**
		 * Finds the next cue point in <code>my_cuePoint.array</code> that has the same name as 
		 * <code>my_cuePoint.name</code>. The <code>my_cuePoint</code> object must be a 
		 * cue point object that has been returned by the <code>findCuePoint()</code> method, the 
		 * <code>findNearestCuePoint()</code> method, or a previous call to this method. 
		 * This method uses the <code>array</code> parameter that these methods add to the 
		 * CuePoint object.
		 * 
		 * <p>The method includes disabled cue points in the search. Use the 
		 * <code>isFLVCuePointEnabled()</code> method to determine whether a cue point is disabled.</p>
		 * 
		 * @param cuePoint A cue point object that has been returned by either the 
		 * <code>findCuePoint()</code> method, 
		 * the <code>findNearestCuePoint()</code> method, or a previous call to this method.
		 * 
         * @return If there are no more cue points in the array with a matching 
		 * name, then <code>null</code>; otherwise, returns a
		 * copy of the cue point object with additional properties:
		 *
		 * <ul>
		 * 
		 * <li><code>array</code>&#x2014;The array of cue points searched. 
		 * Treat this array as read-only because adding, removing or 
		 * editing objects within it can cause cue points to malfunction.</li>
		 *
		 * <li><code>index</code>&#x2014;The index into the array for the returned cue point.</li>
		 *
		 * </ul>
		 * 
         * @throws fl.video.VideoError When argument is invalid.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function findNextCuePointWithName(cuePoint:Object):Object {
			var cpMgr:CuePointManager = cuePointMgrs[_activeVP];
			return cpMgr.getNextCuePointWithName(cuePoint);
		}

		/**
		 * Enables or disables one or more FLV file cue points. Disabled cue points 
		 * are disabled for purposes of being dispatched as events and for navigating 
		 * to them with the <code>seekToPrevNavCuePoint()</code>, 
		 * <code>seekToNextNavCuePoint()</code>, and <code>seekToNavCuePoint()</code> methods.
		 * 
		 * <p>Cue point information is deleted when you set the <code>source</code>
		 * property to a different FLV file, so set the <code>source</code> property before 
		 * setting cue point information for the next FLV file to be loaded.</p>
		 * 
		 * <p>Changes caused by this method are not reflected by calls to the 
		 * <code>isFLVCuePointEnabled()</code> method until metadata is loaded.</p>
		 *
		 * @param enabled A Boolean value that specifies whether to enable (<code>true</code>) 
		 * or disable (<code>false</code>) an FLV file cue point.
		 * 
		 * @param timeNameOrCuePoint If this parameter is a string, the method enables or disables
		 * the cue point with this name. If this parameter is a number, the method enables or
		 * disables the cue point with this time. If this parameter is an object, the method 
		 * enables or disables the cue point with both the <code>name</code> and <code>time</code>
		 * properties.
		 * 
		 * @return If <code>metadataLoaded</code> is <code>true</code>, the method returns the
		 * number of cue points whose enabled state was changed.  If
		 * <code>metadataLoaded</code> is <code>false</code>, the method returns -1 because the 
		 * component cannot yet determine which, if any, cue points to set. 
		 * When the metadata arrives, however, the component sets the specified cue points appropriately.
		 * 
		 * @see #cuePoints
		 * @see #isFLVCuePointEnabled()
		 * @see #findCuePoint()
		 * @see #findNearestCuePoint()
         * @see #findNextCuePointWithName()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function setFLVCuePointEnabled(enabled:Boolean, timeNameOrCuePoint:*):Number {
			var cpMgr:CuePointManager = cuePointMgrs[_activeVP];
			return cpMgr.setFLVCuePointEnabled(enabled, timeNameOrCuePoint);
		}

		/**
		 * Returns <code>false</code> if the FLV file embedded cue point is disabled. 
		 * You can disable cue points either by setting the <code>cuePoints</code> property through 
		 * the Flash Video Cue Points dialog box or by calling the 
		 * <code>setFLVCuePointEnabled()</code> method.
		 * 
		 * <p>The return value from this function is meaningful only when the 
		 * <code>metadataLoaded</code> property is <code>true</code>, the 
		 * <code>metadata</code> property is not <code>null</code>, or after a 
		 * <code>metadataReceived</code> event. When <code>metadataLoaded</code> is 
		 * <code>false</code>, this function always returns <code>true</code>.</p>
		 *
		 * @param timeNameOrCuePoint If this parameter is a string, returns the name of 
		 * the cue point to check; returns <code>false</code> only if all cue points with 
		 * this name are disabled.  
		 * 
		 * <p>If this parameter is a number, it is the time of the cue point to check.</p>
		 * 
		 * <p>If this parameter is an object, returns the object with the matching
		 * <code>name</code> and <code>time</code> properties.</p>
		 * 
		 * @return Returns <code>false</code> if the FLV file embedded cue point is disabled. 
		 * You can disable cue points either by setting the <code>cuePoints</code> property through the 
		 * Flash Video Cue Points dialog box or by calling the <code>setFLVCuePointEnabled()</code> method.
		 * 
		 * <p>The return value from this function is meaningful only when the 
		 * <code>metadataLoaded</code> property is <code>true</code>, the <code>metadata</code> 
		 * property is not <code>null</code>, or after a 
		 * <code>metadataReceived</code> event. When <code>metadataLoaded</code> is <code>false</code>, 
		 * this function always returns <code>true</code>.</p>
		 * 
		 * 
		 * @see #findCuePoint()
		 * @see #findNearestCuePoint()
		 * @see #findNextCuePointWithName()
         * @see #setFLVCuePointEnabled()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function isFLVCuePointEnabled(timeNameOrCuePoint:*):Boolean {
			var cpMgr:CuePointManager = cuePointMgrs[_activeVP];
			return cpMgr.isFLVCuePointEnabled(timeNameOrCuePoint);
		}

		/**
		 * Brings a video player to the front of the stack of video players. 
		 * Useful for custom transitions between video players. The default stack 
		 * order is the same as it is for the <code>activeVideoPlayerIndex</code> property: 
		 * 0 is on the bottom, 1 is above it, 2 is above 1, and so on. However, when you
		 * call the <code>bringVideoPlayerToFront()</code> method this order may change. For
		 * example, 2 may be the bottom.
		 * 
		 * @param index A number that is the index of the video player to move to the front.
		 * 
		 * @see #activeVideoPlayerIndex 
		 * @see #getVideoPlayer() 
		 * @see VideoPlayer 
         * @see #visibleVideoPlayerIndex 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function bringVideoPlayerToFront(index:uint):void {
			if (index == _topVP) return;
			var vp:VideoPlayer = videoPlayers[index];
			if (vp == null) {
				createVideoPlayer(index);
				vp = videoPlayers[index];
			}
			var moved:Boolean = false;
			if (uiMgr.skin_mc != null) {
				try {
					var skinDepth:int = getChildIndex(uiMgr.skin_mc);
					if (skinDepth > 0) {
						setChildIndex(vp, skinDepth - 1);
						moved = true;
					}
				} catch (err:Error) {
				}
			}
			if (!moved) {
				setChildIndex(vp, numChildren - 1);
			}
			_topVP = index;
		}

		/**
		 * Gets the video player specified by the <code>index</code> parameter. 
		 * When possible, it is best to access the VideoPlayer methods and properties 
		 * using FLVPlayback methods and properties. Each <code>DisplayObject.name</code> property 
		 * is its index converted to a string.
		 * 
		 * @param index A number that is the index of the video player to get.
		 * 
         * @return A VideoPlayer object.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function getVideoPlayer(index:Number):VideoPlayer {
			return videoPlayers[index];
		}

		/**
		 * Closes NetStream and deletes the video player specified by the <code>index</code>
		 * parameter. If the closed video player is the active or visible video player, 
		 * the FLVPlayback instance sets the active and or visible video player to the 
		 * default player (with index 0). You cannot close the default player, and 
		 * trying to do so causes the component to throw an error.
		 * 
		 * @param index A number that is the index of the video player to close.
		 * 
		 * @see #activeVideoPlayerIndex 
		 * @see #event:close close event
         * @see #visibleVideoPlayerIndex 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function closeVideoPlayer(index:uint):void {
			if (index == 0) throw new VideoError(VideoError.DELETE_DEFAULT_PLAYER);
			if (videoPlayers[index] == undefined) return;

			var vp:VideoPlayer = videoPlayers[index];

			if (_visibleVP == index) visibleVideoPlayerIndex = 0;
			if (_activeVP == index) activeVideoPlayerIndex = 0;
			
			removeChild(vp);
			vp.close();
			delete videoPlayers[index];
			delete videoPlayerStates[index];
			delete videoPlayerStateDict[vp];
		}

	/**
	* Sets the FLVPlayback video player to full screen. Calling this method has 
	* the same effect as clicking the full screen toggle button that's built into some
	* FLVPlayback skins and is also available as the FullScreenButton in the Video section
	* of the Components panel.
	*
	* <p>This method supports hardware acceleration in Flash Player for 
	* full screen video.  If the user's version of Flash Player does not support
	* hardware acceleration, this method still works and full screen video will work
	* the same as it does without hardware acceleration support.</p>
	*
	* <p>Because a call to this method sets the <code>displayState</code> property of the 
	* Stage class to <code>StageDisplayState.FULL_SCREEN</code>, it has
	* the same restrictions as the <code>displayState</code> property. 
	*
	* If, instead of calling this method, you implement full screen mode by directly setting the 
	* <code>stage.displayState</code> property to <code>StageDisplayState.FULL_SCREEN</code>, 
	* hardware acceleration is not used.</p>
	*  
	* <p>Full screen support occurs only if the <code>fullScreenTakeOver</code>
	* property is set to true, which it is by default.</p>
    *
    * <p><strong>Player Version</strong>: Flash Player 9 <a target="mm_external" href="http://www.adobe.com/go/fp9_update3">Update 3</a>.</p>
    *
	* @see #fullScreenTakeover
	* @see #skinScaleMaximum
	* @see flash.display.Stage#displayState
	* 
	* @includeExample examples/FLVPlayback.enterFullScreenDisplayState.1.as -noswf
	*
	* @langversion 3.0
	* @internal Flash 9.0.xx.0
	*/
		
		public function enterFullScreenDisplayState():void {
			uiMgr.enterFullScreenDisplayState();
		}

		//
		// public properties
		//

		/**
		 * This flag is set by code automatically generated by the
		 * authoring tool.  It is turned on before properties
		 * automatically set by the component inspector start getting
		 * set and it is turned off after the last property is set.
		 * 
		 * With AS2 these properties were set before the constructor
		 * was called, which gave us a way to know that was how they
		 * were set, although it was generally annoying.  Now we
		 * have a way to know in AS3 and we don't have to deal with
		 * having properties called before our constructor.  Cool!
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set componentInspectorSetting(b:Boolean):void {
			_componentInspectorSetting = b;
		}

		/**
                 * A number that specifies which video player instance is affected by other application
                 * programming interfaces (APIs). 
		 * Use this property to manage multiple FLV file streams. 
		 * 
		 * <p>This property does not make the video player visible; 
		 * use the <code>visibleVideoPlayerIndex</code> property to do that.</p>
		 * 
		 * <p>A new video player is created the first time <code>activeVideoPlayerIndex</code> 
		 * is set to a number. When the new video player is created, 
		 * its properties are set to the value of the default video player 
		 * (<code>activeVideoPlayerIndex == 0</code>) except for <code>source</code>, 
		 * <code>totalTime</code>, and <code>isLive</code>, which are always set to the 
		 * default values (empty string, NaN, and <code>false</code>, respectively), 
		 * and <code>autoPlay</code>, which is always <code>false</code> (the default is <code>true</code> 
		 * only for the default video player, 0). The <code>cuePoints</code> 
		 * property has no effect, as it would have no effect 
		 * on a subsequent load into the default video player.</p>
		 * 
		 * <p>APIs that control volume, positioning, dimensions, visibility, 
		 * and UI controls are always global, and their behavior is not 
		 * affected by setting <code>activeVideoPlayerIndex</code>. Specifically, setting 
		 * the <code>activeVideoPlayerIndex</code> property does not affect the following 
		 * properties and methods:</p>		
		 * 
		 * <strong>Properties and Methods Not Affected by <code>activeVideoPlayerIndex</code></strong>
		 * <table class="innertable" width="100%">
		 * 		<tr><td><code>backButton</code></td><td><code>playPauseButton</code></td><td><code>skin</code></td><td><code>width</code></td></tr>
		 * 		<tr><td><code>bufferingBar</code></td><td><code>scaleX</code></td><td><code>stopButton</code></td><td><code>x</code></td></tr>
		 * 		<tr><td><code>bufferingBarHidesAndDisablesOthers</code></td><td><code>transform</code></td><td><code>y</code></td><td><code>setSize()</code></td></tr>
		 * 		<tr><td><code>forwardButton</code></td><td><code>scaleY</code></td><td><code>visible</code></td><td><code>setScale()</code></td></tr>
 		 * 		<tr><td><code>height</code></td><td><code>seekBar</code></td><td><code>volume</code></td><td><code>fullScreenBackgroundColor</code></td></tr>
 		 * 		<tr><td><code>muteButton</code></td><td><code>seekBarInterval</code></td><td><code>volumeBar</code></td><td><code>fullScreenButton</code></td></tr>
 		 * 		<tr><td><code>pauseButton</code></td><td><code>seekBarScrubTolerance</code></td><td><code>volumeBarInterval</code></td><td><code>fullScreenSkinDelay</code></td></tr>
 		 * 		<tr><td><code>playButton</code></td><td><code>seekToPrevOffset</code></td><td><code>volumeBarScrubTolerance</code></td><td><code>fullScreenTakeOver</code></td></tr>
		 *  		<tr><td><code>registrationX</code></td><td><code>registrationY</code></td><td><code>registrationWidth</code></td><td><code>registrationHeight</code></td></tr>
		 *  		<tr><td><code>skinBackgroundAlpha</code></td><td><code>skinBackgroundColor</code></td><td><code>skinFadeTime</code></td><td></td></tr>
		 * </table>
		 * 
                 * <p><b>Note</b>: The <code>visibleVideoPlayerIndex</code> property, not the 
		 * <code>activeVideoPlayerIndex</code> property, determines which 
		 * video player the skin controls. Additionaly, APIs that control dimensions 
		 * do interact with the <code>visibleVideoPlayerIndex</code> property.</p>
		 * 
		 * <p>The remaining APIs target a specific video player based on the 
		 * setting of <code>activeVideoPlayerIndex</code>.</p>
		 * 
		 * <p>To load a second FLV file in the background, set <code>activeVideoPlayerIndex</code>
		 * to 1 and call the <code>load()</code> method. When you are 
		 * ready to show this FLV file and hide the first one, 
		 * set <code>visibleVideoPlayerIndex</code> to 1.</p>
		 * 		 
                 * @see #visibleVideoPlayerIndex
                 * @default 0
                 * @langversion 3.0
                 * @playerversion Flash 9.0.28.0
		 */
		public function get activeVideoPlayerIndex():uint {
			return _activeVP;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set activeVideoPlayerIndex(index:uint):void {
			if (_activeVP == index) return;
			_activeVP = index;
			if (videoPlayers[_activeVP] == undefined) {
				createVideoPlayer(_activeVP);
			}
		}

        [Inspectable(type="List",enumeration="center,top,left,bottom,right,topLeft,topRight,bottomLeft,bottomRight",defaultValue="center")]
		/**
		 * Specifies the video layout when the <code>scaleMode</code> property  is set to
		 * <code>VideoScaleMode.MAINTAIN_ASPECT_RATIO</code> or <code>VideoScaleMode.NO_SCALE</code>.
		 * The video dimensions are based on the
		 * <code>registrationX</code>, <code>registrationY</code>,
		 * <code>registrationWidth</code>, and
		 * <code>registrationHeight</code> properties. When you set the <code>align</code> property,
		 * values come from the VideoAlign class. The default is <code>VideoAlign.CENTER</code>.
		 *
		 * @see #scaleMode
		 * @see #registrationX
		 * @see #registrationY
		 * @see #registrationWidth
		 * @see #registrationHeight
		 * @see VideoAlign
         * @see VideoPlayer#align
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get align():String {
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.align;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set align(s:String):void {
			if (_activeVP == 0) _align = s;
			var vp:VideoPlayer = videoPlayers[_activeVP];
			vp.align = s;
		}

        [Inspectable(defaultValue=true)]
		/**
	     * A Boolean value that, if set to <code>true</code>, causes the FLV file to start
		 * playing automatically after the <code>source</code> property is set.  If it is set to <code>false</code>,
		 * the FLV file loads but does not start playing until the <code>play()</code>
		 * or <code>playWhenEnoughDownloaded()</code> method is called.  
		 * 
		 * <p>Playback starts immediately when you are streaming an FLV file from Flash Media Server (FMS) and the 
		 * <code>autoPlay</code> property is set to <code>true</code>. However, 
		 * when loading an FLV file by progressive download, playback starts only
		 * when enough of the FLV file has download so that the FLV file can play from start
		 * to finish. </p>
		 * 
		 * <p>To force playback before enough of the FLV file has downloaded,
		 * call the <code>play()</code> method with no parameters. If playback
		 * has begun and you want to return to the state of waiting
		 * for enough to download and then automatically begin playback, 
		 * call the <code>pause()</code> method, and then the 
		 * <code>playWhenEnoughDownloaded()</code> method.</p>
		 * 
		 * <p>If you set the property to <code>true</code> between the loading of new FLV files, 
		 * it has no effect until the <code>source</code> property is set.</p>
		 * 
		 * <p>Setting the <code>autoPlay</code> property to <code>true</code> and
		 * then setting the <code>source</code> property to a URL has the same
		 * effect as calling the <code>play()</code> method with that URL.</p>
		 * 
		 * <p>Calling the <code>load()</code> method with a URL has the same effect
		 * as setting the <code>source</code> property to that URL with the
		 * <code>autoPlay</code> property set to <code>false</code>.</p>
		 *
		 * @see #source
		 * @see #load()
		 * @see #play()
		 * @see #playWhenEnoughDownloaded()
         * @default true
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get autoPlay():Boolean
		{
			var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
			return vpState.autoPlay;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set autoPlay(flag:Boolean):void
		{
			var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
			vpState.autoPlay = flag;
		}

		/**
		 * A Boolean value that, if <code>true</code>, causes the FLV file to rewind to Frame 1 when 
		 * play stops, either because the player reached the end of the stream or the 
		 * <code>stop()</code> method was called. This property is meaningless for live streams. 
         * @default false
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get autoRewind():Boolean
		{
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.autoRewind;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set autoRewind(flag:Boolean):void
		{
			if (_activeVP == 0) _autoRewind = flag;
			var vp:VideoPlayer = videoPlayers[_activeVP];
			vp.autoRewind = flag;
		}

	/**
	 * A number that specifies the bits per second at which to transfer the FLV file.
	 *
	 * <p>When streaming from a Flash Video Streaming service that supports
	 * native bandwidth detection, you can provide a SMIL file that
	 * describes how to switch between multiple streams based on the
	 * bandwidth. Depending on your FVSS, bandwidth may automatically be
	 * detected, and if this value is set, it is ignored.</p>
	 *
	 * <p>When doing HTTP progressive download, you can use the same SMIL
	 * format, but you must set the bitrate as there is no automatic
         * detection.</p>
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
	 */
		public function get bitrate():Number {
			return ncMgr.bitrate;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set bitrate(b:Number):void {
			ncMgr.bitrate = b;
		}

		/**
		 * A Boolean value that is <code>true</code> if the video is in a buffering state. 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get buffering():Boolean {
			return (state == VideoState.BUFFERING);
		}

		/**
		 * Buffering bar control. This control is displayed when the FLV file is in 
         * a loading or buffering state.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get bufferingBar():Sprite {
			return uiMgr.getControl(UIManager.BUFFERING_BAR);
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set bufferingBar(s:Sprite):void {
			uiMgr.setControl(UIManager.BUFFERING_BAR, s);
		}

		/**
		 * If set to <code>true</code>, hides the SeekBar control and disables the 
		 * Play, Pause, PlayPause, BackButton and ForwardButton controls while the 
		 * FLV file is in the buffering state. This can be useful to prevent a 
		 * user from using these controls to try to speed up playing the FLV file 
         * when it is downloading or streaming over a slow connection.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get bufferingBarHidesAndDisablesOthers():Boolean {
			return uiMgr.bufferingBarHidesAndDisablesOthers;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set bufferingBarHidesAndDisablesOthers(b:Boolean):void {
			uiMgr.bufferingBarHidesAndDisablesOthers = b;
		}

		/**
		 * BackButton playback control. Clicking calls the 
		 * <code>seekToPrevNavCuePoint()</code> method.
		 * 
         * @see #seekToPrevNavCuePoint() 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get backButton():Sprite {
			return uiMgr.getControl(UIManager.BACK_BUTTON);
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set backButton(s:Sprite):void {
			uiMgr.setControl(UIManager.BACK_BUTTON, s);
		}

		/**
		 * A number that specifies the number of seconds to buffer in memory before 
		 * beginning to play a video stream. For FLV files streaming over RTMP, 
		 * which are not downloaded and buffer only in memory, it can be important 
		 * to increase this setting from the default value of 0.1. For a progressively 
		 * downloaded FLV file over HTTP, there is little benefit to increasing this 
		 * value although it could improve viewing a high-quality video on an older, 
		 * slower computer.
		 * 
		 * <p>For prerecorded (not live) video, do not set the <code>bufferTime</code> 
		 * property to <code>0</code>: 
		 * use the default buffer time or increase the buffer time.</p>
		 * 
		 * <p>This property does not specify the amount of the FLV file to download before 
		 * starting playback. </p>
		 * 
		 * @see VideoPlayer#bufferTime 
         * @see #isLive 
         *
		 * @default 0.1
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get bufferTime():Number
		{
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.bufferTime;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set bufferTime(aTime:Number):void
		{
			var vp:VideoPlayer = videoPlayers[_activeVP];
			vp.bufferTime = aTime;
		}

		/**
		 * A number that indicates the extent of downloading, in number of bytes, for an 
		 * HTTP download.  Returns 0 when there
		 * is no stream, when the stream is from Flash Media Server (FMS), or if the information
		 * is not yet available. The returned value is useful only for an HTTP download.
		 *
		 * @tiptext Number of bytes already loaded
         * @helpid 3455
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get bytesLoaded():uint
		{
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.bytesLoaded;
		}

		/**
		 * A number that specifies the total number of bytes downloaded for an HTTP download.  
		 * Returns 0 when there is no stream, when the stream is from Flash Media Server (FMS), or if 
		 * the information is not yet available. The returned value is useful only 
		 * for an HTTP download. 
		 *
		 * @tiptext Number of bytes to be loaded
         * @helpid 3456
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get bytesTotal():uint
		{
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.bytesTotal;
		}

        [Inspectable(type="Video Content Path")]
		/**
		 * A string that specifies the URL of the FLV file to stream and how to stream it.
		 * The URL can be an HTTP URL to an FLV file, an RTMP URL to a stream, or an 
		 * HTTP URL to an XML file.
		 *
		 * <p>If you set this property through the Component inspector or the Property inspector, the
		 * FLV file begins loading and playing at the next "<code>enterFrame</code>" event.
		 * The delay provides time to set the <code>isLive</code>, <code>autoPlay</code>, 
		 * and <code>cuePoints</code> properties, 
		 * among others, which affect loading. It also allows ActionScript that is placed 
		 * on the first frame to affect the FLVPlayback component before it starts playing.</p>
		 *
		 * <p>If you set this property through ActionScript, it immediately calls the
		 * <code>VideoPlayer.load()</code> method when the <code>autoPlay</code> property is
		 * set to <code>false</code> or it calls the <code>VideoPlayer.play()</code> method when
		 * the <code>autoPlay</code> property is set to <code>true</code>.  The <code>autoPlay</code>, 
		 * <code>totalTime</code>, and <code>isLive</code> properties affect how the new FLV file is 
		 * loaded, so if you set these properties, you must set them before setting the
		 * <code>source</code> property.</p>
		 * 
		 * <p>Set the <code>autoPlay</code> property to <code>false</code> to prevent the new 
		 * FLV file from playing automatically.</p>
		 *
		 * @see #autoPlay
		 * @see #isLive
		 * @see #totalTime
		 * @see #load()
		 * @see #play()
		 * @see VideoPlayer#load()
         * @see VideoPlayer#play()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get source():String {
			var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
			if (vpState.isWaiting) return vpState.url;

			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.source;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set source(url:String):void {
			// live preview we don't play videos!
			if (isLivePreview) return;

			// fix url so never null
			if (url == null) url = "";

			var vpState:VideoPlayerState;

			if (_componentInspectorSetting) {
				// if set by component inspector then we connect after
				// waiting a frame to give time for all necessary
				// properties to be initialized
				vpState = videoPlayerStates[_activeVP];
				vpState.url = url;
				if (url.length > 0) {
					vpState.isWaiting = true;
					addEventListener(Event.ENTER_FRAME, doContentPathConnect);
				}
			} else {
				if (source == url) return;

				var cpMgr:CuePointManager = cuePointMgrs[_activeVP];
				cpMgr.reset();

				vpState = videoPlayerStates[_activeVP];
				vpState.url = url;
				vpState.isWaiting = true;

				doContentPathConnect(_activeVP);
			}
		}

        [Inspectable(type="Video Cue Points")]
		/**
		 * An array that describes ActionScript cue points and disabled embedded 
		 * FLV file cue points. This property is created specifically for use by 
		 * the Component inspector and Property inspector. It does not work if it is 
		 * set any other way. Its value has an effect only on the first FLV file 
		 * loaded and only if it is loaded by setting the <code>source</code> 
		 * property in the Component inspector or the Property inspector.
		 * 
		 * <p><b>Note</b>: This property is not accessible in ActionScript. To 
		 * access cue point information in ActionScript, use the <code>metadata</code> property.</p>
		 * 
		 * <p>To add, remove, enable or disable cue points with ActionScript, 
		 * use the <code>addASCuePoint()</code>, <code>removeASCuePoint()</code>, or
		 * <code>setFLVCuePointEnabled()</code> methods.</p>
		 *
		 * @see #source
		 * @see #addASCuePoint()
		 * @see #removeASCuePoint()
         * @see #setFLVCuePointEnabled()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set cuePoints(cuePointsArray:Array):void {
			// this property can only be set via the component inspector,
			// otherwise it has no effect
			if (!_componentInspectorSetting) return;
			cuePointMgrs[0].processCuePointsProperty(cuePointsArray);
		}

		//ifdef DEBUG
		///**
		// * temporary for development
		// */
		//[Inspectable(defaultValue=false)]
		//public function get debuggingOn():Boolean {
		//	return _debuggingOn;
		//}
		//public function set debuggingOn(d:Boolean):void {
		//	_debuggingOn = d;
		//}

		///**
		// * temporary for development.  Should be a function that takes
		// * a String argument.
		// */
		//public function get debuggingOutputFunction():Function {
		//	return _debugFn;
		//}
		//public function set debuggingOutputFunction(d:Function):void {
		//	_debugFn = d;
		//}
		//endif

		/**
		 * Forward button control. Clicking calls the
		 * <code>seekToNextNavCuePoint()</code> method.
		 * 
         * @see #seekToNextNavCuePoint()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get forwardButton():Sprite {
			return uiMgr.getControl(UIManager.FORWARD_BUTTON);
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set forwardButton(s:Sprite):void {
			uiMgr.setControl(UIManager.FORWARD_BUTTON, s);
		}

		/**
		 * Background color used when in full-screen takeover
		 * mode.  This color is visible if the video does
		 * not cover the entire screen based on the <code>scaleMode</code>
		 * property value.
         *
         * @default 0x000000
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get fullScreenBackgroundColor():uint {
			return uiMgr.fullScreenBackgroundColor;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set fullScreenBackgroundColor(c:uint):void {
			uiMgr.fullScreenBackgroundColor = c;
		}

		/**
         * FullScreen button control.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get fullScreenButton():Sprite {
			return uiMgr.getControl(UIManager.FULL_SCREEN_BUTTON);
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set fullScreenButton(s:Sprite):void {
			uiMgr.setControl(UIManager.FULL_SCREEN_BUTTON, s);
		}

		/**
		 * Specifies the delay time in milliseconds to hide the skin. 
		 * When in full-screen takeover mode, if the <code>skinAutoHide</code> property
		 * is <code>true</code>, autohiding is triggered when the user doesn't move the
		 * mouse for more than the seconds indicated by the <code>fullScreenSkinDelay</code> 
		 * property. If the mouse is over the skin itself, autohiding is not triggered.
         *
		 * @default 3000 milliseconds (3 seconds)
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get fullScreenSkinDelay():int {
			return uiMgr.fullScreenSkinDelay;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set fullScreenSkinDelay(i:int):void {
			uiMgr.fullScreenSkinDelay = i;
		}

		/**
		 * When the stage enters full-screen mode, the
		 * FLVPlayback component is on top of all
		 * content and takes over the entire screen.  When
		 * the stage exits full-screen mode, the screen returns to 
		 * how it was before. 
		 *
		 * <p>The recommended settings for full-screen
		 * takeover mode are <code>scaleMode = VideoScaleMode.MAINTAIN_ASPECT_RATIO</code>
		 * and <code>align = VideoAlign.CENTER</code>.</p>
		 *
		 * <p>If the SWF file with the FLVPlayback component
		 * is loaded and does not have access to the
		 * stage because of security restrictions, full-screen
		 * takeover mode does not function. No
         * errors are thrown.</p>
         *
		 * @default true
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get fullScreenTakeOver():Boolean {
			return uiMgr.fullScreenTakeOver;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set fullScreenTakeOver(v:Boolean):void {
			uiMgr.fullScreenTakeOver = v;
		}

		/**
		 * A number that specifies the height of the FLVPlayback instance. 
		 * This property affects only the height of the FLVPlayback instance 
		 * and does not include the height of a skin SWF file that might be loaded.
		 * Setting the height property also sets the <code>registrationHeight</code> property
		 * to the same value.
		 * 
		 * @see #setSize()
         * @helpid 0
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public override function get height():Number {
			if (isLivePreview) return livePreviewHeight;			
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			return vp.height;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public override function set height(h:Number):void {
			if (isLivePreview) {
				setSize(this.width, h);
				return;
			}

			var oldBounds:Rectangle = new Rectangle(x, y, width, height);
			var oldRegistrationBounds:Rectangle = new Rectangle(registrationX, registrationY, registrationWidth, registrationHeight);
			// flag to avoid sending multiple layout events if autolayout occurs
			resizingNow = true;
			for (var i:int = 0; i < videoPlayers.length; i++) {
				var vp:VideoPlayer = videoPlayers[i];
				if (vp != null) vp.height = h;
			}
			resizingNow = false;

			dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT, false, false, oldBounds, oldRegistrationBounds));
		}

		/**
		 * The amount of time, in milliseconds, before Flash terminates an idle connection 
		 * to Flash Media Server (FMS) because playing paused or stopped. This property has no effect on an 
		 * FLV file downloading over HTTP.
		 * 
		 * <p>If this property is set when a video stream is already idle, it restarts the 
		 * timeout period with the new value.</p>
		 * 
         * @default 300,000 milliseconds (5 minutes)
         *
         * @see #event:close
         *
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get idleTimeout():Number {
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.idleTimeout;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set idleTimeout(aTime:Number):void {
			if (_activeVP == 0) _idleTimeout = aTime;
			var vp:VideoPlayer = videoPlayers[_activeVP];
			vp.idleTimeout = aTime;
		}

		/**
		 * A Boolean value that is <code>true</code> if the FLV file is streaming from 
		 * Flash Media Server (FMS) using RTMP. Its value is <code>false</code> for any other FLV file source. 
		 *
         * @see VideoPlayer#isRTMP
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get isRTMP():Boolean {
			if (isLivePreview) return true;
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.isRTMP;
		}

        [Inspectable(defaultValue=false)]
		/**
		 * A Boolean value that is <code>true</code> if the video stream is live. This property 
		 * is effective only when streaming from Flash Media Server (FMS) or other Flash Video Streaming Service (FVSS). The value of this 
		 * property is ignored for an HTTP download.
		 * 
		 * <p>If you set this property between loading new FLV files, it has no 
		 * effect until the <code>source</code> property is set for the new FLV file.</p>
		 * 
		 * <p>Set the <code>isLive</code> property to <code>false</code> when sending a prerecorded video 
		 * stream to the video player and to <code>true</code> when sending real-time data 
		 * such as a live broadcast. For better performance when you set 
		 * the <code>isLive</code> property to <code>false</code>, do not set the 
		 * <code>bufferTime</code> property to <code>0</code>.</p>
		 *
		 * @see #bufferTime  
		 * @see #source 
         * @see VideoPlayer#isLive 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get isLive():Boolean {
			var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
			if (vpState.isLiveSet) return vpState.isLive;
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.isLive;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set isLive(flag:Boolean):void {
			var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
			vpState.isLive = flag;
			vpState.isLiveSet = true;
		}

		/**
		 * An object that is a metadata information packet that is received from a call to 
		 * the <code>NetSteam.onMetaData()</code> callback method, if available.  
		 * Ready when the <code>metadataReceived</code> event is dispatched.
		 * 
		 * <p>If the FLV file is encoded with the Flash 8 encoder, the <code>metadata</code> 
		 * property contains the following information. Older FLV files contain 
		 * only the <code>height</code>, <code>width</code>, and <code>duration</code> values.</p>
		 * 
		 * <table class="innertable" width="100%">
		 * 	<tr><th><b>Parameter</b></th><th><b>Description</b></th></tr>
		 * 		<tr><td><code>canSeekToEnd</code></td><td>A Boolean value that is <code>true</code> if the FLV file is encoded with a keyframe on the last frame that allows seeking to the end of a progressive download movie clip. It is <code>false</code> if the FLV file is not encoded with a keyframe on the last frame.</td></tr>
		 * 		<tr><td><code>cuePoints</code></td><td>An array of objects, one for each cue point embedded in the FLV file. Value is undefined if the FLV file does not contain any cue points. Each object has the following properties:
	     *   	
		 * 			<ul>
		 * 				<li><code>type</code>&#x2014;A string that specifies the type of cue point as either "navigation" or "event".</li>
		 * 				<li><code>name</code>&#x2014;A string that is the name of the cue point.</li>
		 * 				<li><code>time</code>&#x2014;A number that is the time of the cue point in seconds with a precision of three decimal places (milliseconds).</li>
		 * 				<li><code>parameters</code>&#x2014;An optional object that has name-value pairs that are designated by the user when creating the cue points.</li>
		 * 			</ul>
		 * 		</td></tr>
		 * <tr><td><code>audiocodecid</code></td><td>A number that indicates the audio codec (code/decode technique) that was used.</td></tr>
		 * <tr><td><code>audiodelay</code></td><td>A number that represents time <code>0</code> in the source file from which the FLV file was encoded. 
		 * <p>Video content is delayed for the short period of time that is required to synchronize the audio. For example, if the <code>audiodelay</code> value is <code>.038</code>, the video that started at time <code>0</code> in the source file starts at time <code>.038</code> in the FLV file.</p> 
		 * <p>Note that the FLVPlayback and VideoPlayer classes compensate for this delay in their time settings. This means that you can continue to use the time settings that you used in your the source file.</p>
</td></tr>
 		 * <tr><td><code>audiodatarate</code></td><td>A number that is the kilobytes per second of audio.</td></tr>
 		 * <tr><td><code>videocodecid</code></td><td>A number that is the codec version that was used to encode the video.</td></tr>
 		 * <tr><td><code>framerate</code></td><td>A number that is the frame rate of the FLV file.</td></tr>
 		 * <tr><td><code>videodatarate</code></td><td>A number that is the video data rate of the FLV file.</td></tr>
		 * <tr><td><code>height</code></td><td>A number that is the height of the FLV file.</td></tr>
 		 * <tr><td><code>width</code></td><td>A number that is the width of the FLV file.</td></tr>
 		 * <tr><td><code>duration</code></td><td>A number that specifies the duration of the FLV file in seconds.</td></tr>
		 * </table>
		 *
         * @see VideoPlayer#metadata
         * @see http://livedocs.adobe.com/flash/9.0/main/00001037.html Working with cue points
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get metadata():Object {
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.metadata;
		}

		/**
		 * A Boolean value that is <code>true</code> if a metadata packet has been 
		 * encountered and processed or if the FLV file was encoded without the 
		 * metadata packet. In other words, the value is <code>true</code> if the metadata is 
		 * received, or if you are never going to get any metadata. So, you 
		 * know whether you have the metadata; and if you don't have the metadata, 
		 * you know not to wait around for it. If you just want to know whether 
		 * or not you have metadata, you can check the value with:  
		 * 
		 * <listing>FLVPlayback.metadata != null</listing>
		 * 
		 * <p>Use this property to check whether you can retrieve useful 
		 * information with the methods for finding and enabling or 
		 * disabling cue points (<code>findCuePoint</code>, <code>findNearestCuePoint</code>,
		 * <code>findNextCuePointWithName</code>, <code>isFLVCuePointEnabled</code>).</p>
		 *
		 * @see #findCuePoint()
		 * @see #findNearestCuePoint()
		 * @see #findNextCuePointWithName()
         * @see #isFLVCuePointEnabled()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get metadataLoaded():Boolean {
			var cpMgr:CuePointManager = cuePointMgrs[_activeVP];
			return cpMgr.metadataLoaded;
		}

		/**
         * Mute button control.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get muteButton():Sprite {
			return uiMgr.getControl(UIManager.MUTE_BUTTON);
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set muteButton(s:Sprite):void {
			uiMgr.setControl(UIManager.MUTE_BUTTON, s);
		}

		/**
		 * An INCManager object that provides access to an instance of the class implementing 
		 * <code>INCManager</code>, which is an interface to the NCManager class.
		 * 
		 * <p>You can use this property to implement a custom INCManager that requires 
		 * custom initialization.</p>
		 *
         * @see VideoPlayer#ncMgr
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get ncMgr():INCManager {
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.ncMgr;
		}

		/**
         * Pause button control.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get pauseButton():Sprite {
			return uiMgr.getControl(UIManager.PAUSE_BUTTON);
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set pauseButton(s:Sprite):void {
			uiMgr.setControl(UIManager.PAUSE_BUTTON, s);
		}

		/**
         * A Boolean value that is <code>true</code> if the FLV file is in a paused state.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get paused():Boolean {
			return (state == VideoState.PAUSED);
		}

		/**
         * Play button control.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get playButton():Sprite {
			return uiMgr.getControl(UIManager.PLAY_BUTTON);
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set playButton(s:Sprite):void {
			uiMgr.setControl(UIManager.PLAY_BUTTON, s);
		}

		/**
		 * A number that is the current playhead time or position, measured in seconds, 
		 * which can be a fractional value. Setting this property triggers a seek and 
		 * has all the restrictions of a seek.
		 * 
		 * <p>When the playhead time changes, which occurs once every .25 seconds 
		 * while the FLV file plays, the component dispatches the <code>playheadUpdate</code>
		 * event.</p>
		 * 
		 * <p>For several reasons, the <code>playheadTime</code> property might not have the expected 
		 * value immediately after you call one of the seek methods or set <code>playheadTime</code> 
		 * to cause seeking. First, for a progressive download, you can seek only to a 
		 * keyframe, so a seek takes you to the time of the first keyframe after the 
		 * specified time. (When streaming, a seek always goes to the precise specified 
		 * time even if the source FLV file doesn't have a keyframe there.) Second, 
		 * seeking is asynchronous, so if you call a seek method or set the 
		 * <code>playheadTime</code> property, <code>playheadTime</code> does not update immediately. 
		 * To obtain the time after the seek is complete, listen for the <code>seek</code> event, 
		 * which does not fire until the <code>playheadTime</code> property has updated.</p>
		 *
		 * @tiptext Current position of the playhead in seconds
		 * @helpid 3463
		 * @see #seek()
         * @see VideoPlayer#playheadTime
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get playheadTime():Number
		{
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.playheadTime;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set playheadTime(position:Number):void
		{
			seek(position);
		}

		/**
		 * A number that is the amount of time, in milliseconds, between each 
		 * <code>playheadUpdate</code> event. Setting this property while the FLV file is 
		 * playing restarts the timer. 
		 * 
		 * <p>Because ActionScript cue points start on playhead updates, lowering 
		 * the value of the <code>playheadUpdateInterval</code> property can increase the accuracy 
		 * of ActionScript cue points.</p>
		 * 
		 * <p>Because the playhead update interval is set by a call to the global 
		 * <code>setInterval()</code> method, the update cannot fire more frequently than the 
		 * SWF file frame rate, as with any interval that is set this way. 
		 * So, as an example, for the default frame rate of 12 frames per second, 
		 * the lowest effective interval that you can create is approximately 
		 * 83 milliseconds, or one second (1000 milliseconds) divided by 12.</p>
		 *
         * @see VideoPlayer#playheadUpdateInterval
         * @default 250
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get playheadUpdateInterval():Number {
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.playheadUpdateInterval;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set playheadUpdateInterval(aTime:Number):void {
			if (_activeVP == 0) _playheadUpdateInterval = aTime;
			var cpMgr:CuePointManager = cuePointMgrs[_activeVP];
			cpMgr.playheadUpdateInterval = aTime;
			var vp:VideoPlayer = videoPlayers[_activeVP];
			vp.playheadUpdateInterval = aTime;
		}

		/**
		 * A Boolean value that is <code>true</code> if the FLV file is in the playing state. 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get playing():Boolean {
			return (state == VideoState.PLAYING);
		}

		/**
         * Play/pause button control.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get playPauseButton():Sprite {
			return uiMgr.getControl(UIManager.PLAY_PAUSE_BUTTON);
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set playPauseButton(s:Sprite):void {
			uiMgr.setControl(UIManager.PLAY_PAUSE_BUTTON, s);
		}

		/**
		 * A number that specifies the height of the source FLV file. This information 
		 * is not valid immediately upon calling the <code>play()</code> or <code>load()</code> 
		 * methods. It is valid when the <code>ready</code> event starts. If the value of the 
		 * <code>scaleMode</code> property is <code>VideoScaleMode.MAINTAIN_ASPECT_RATIO</code>
		 * or <code>VideoScaleMode.NO_SCALE</code>, it is best to read 
		 * the value after the <code>layout</code> event is dispatched. This property returns
		 * -1 if no information is available yet.
		 * 
		 * @see #scaleMode
		 * @tiptext The preferred height of the display
         * @helpid 3465
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get preferredHeight():int
		{
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.videoHeight;
		}

		/**
		 * Gives the width of the source FLV file. This information is not valid immediately 
		 * when the <code>play()</code> or <code>load()</code> methods are called; it is valid 
		 * after the <code>ready</code> event is dispatched. If the value of the 
		 * <code>scaleMode</code> property is <code>VideoScaleMode.MAINTAIN_ASPECT_RATIO</code>
		 * or <code>VideoScaleMode.NO_SCALE</code>, it is best to read 
		 * the value after the <code>layout</code> event is dispatched. This property returns
		 * -1 if no information is available yet.
		 * 
		 * @see #scaleMode
		 * @tiptext The preferred width of the display
         * @helpid 3466
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get preferredWidth():int
		{
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.videoWidth;
		}

		/**
         * A number that is the amount of time, in milliseconds, between each <code>progress</code> 
		 * event. If you set this property while the video stream is playing, the timer restarts. 
		 * 
		 *
         * @see VideoPlayer#progressInterval
         * @default 250
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get progressInterval():Number {
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.progressInterval;
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set progressInterval(aTime:Number):void {
			if (_activeVP == 0) _progressInterval = aTime;
			var vp:VideoPlayer = videoPlayers[_activeVP];
			vp.progressInterval = aTime;
		}

		/**
         * @copy fl.video.VideoPlayer#registrationX
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get registrationX():Number {
			return super.x;
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set registrationX(x:Number):void {
			super.x = x;
		}

		/**
         * @copy fl.video.VideoPlayer#registrationY
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get registrationY():Number {
			return super.y;
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set registrationY(y:Number):void {
			super.y = y;
		}

		/**
         * @copy fl.video.VideoPlayer#registrationWidth
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get registrationWidth():Number {
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			return vp.registrationWidth;
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set registrationWidth(w:Number):void {
			width = w;
		}

		/**
         * @copy fl.video.VideoPlayer#registrationHeight
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get registrationHeight():Number {
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			return vp.registrationHeight;
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set registrationHeight(h:Number):void {
			height = h;
		}

        [Inspectable(type="List",enumeration="maintainAspectRatio,noScale,exactFit",defaultValue="maintainAspectRatio")]
		/**
		 * Specifies how the video will resize after loading.  If set to
		 * <code>VideoScaleMode.MAINTAIN_ASPECT_RATIO</code>, maintains the
		 * video aspect ratio within the rectangle defined by
		 * <code>registrationX</code>, <code>registrationY</code>,
		 * <code>registrationWidth</code> and
		 * <code>registrationHeight</code>.  If set to
		 * <code>VideoScaleMode.NO_SCALE</code>, causes the video to size automatically
		 * to the dimensions of the source FLV file.  If set to
		 * <code>VideoScaleMode.EXACT_FIT</code>, causes the dimensions of
		 * the source FLV file to be ignored and the video is stretched to
		 * fit the rectangle defined by
		 * <code>registrationX</code>, <code>registrationY</code>,
		 * <code>registrationWidth</code> and
		 * <code>registrationHeight</code>. If this is set
		 * after an FLV file has been loaded an automatic layout will start
		 * immediately.  Values come from
		 * <code>VideoScaleMode</code>.
		 *
		 * @see #preferredHeight
		 * @see #preferredWidth
		 * @see VideoScaleMode
		 * @default VideoScaleMode.MAINTAIN_ASPECT_RATIO
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get scaleMode():String {
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.scaleMode;
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set scaleMode(s:String):void {
			if (_activeVP == 0) _scaleMode = s;
			var vp:VideoPlayer = videoPlayers[_activeVP];
			vp.scaleMode = s;
		}

		/**
		 * A number that is the horizontal scale. The standard scale is 1.
		 *
		 * @see #setScale()
		 * @tiptext Specifies the horizontal scale factor
         * @helpid 3974
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public override function get scaleX():Number
		{
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			return (vp.width / _origWidth);
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public override function set scaleX(xs:Number):void
		{
			var oldBounds:Rectangle = new Rectangle(x, y, width, height);
			var oldRegistrationBounds:Rectangle = new Rectangle(registrationX, registrationY, registrationWidth, registrationHeight);

			// flag to avoid sending multiple layout events if autolayout occurs
			resizingNow = true;
			for (var i:int = 0; i < videoPlayers.length; i++) {
				var vp:VideoPlayer = videoPlayers[i];
				if (vp !== null) vp.width = _origWidth * xs;
			}
			resizingNow = false;

			dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT, false, false, oldBounds, oldRegistrationBounds));
		}

		/**
		 * A number that is the vertical scale. The standard scale is 1.
		 *
		 * @see #setScale()
		 * @tiptext Specifies the vertical scale factor
         * @helpid 3975
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public override function get scaleY():Number
		{
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			return (vp.height / _origHeight);
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public override function set scaleY(ys:Number):void
		{
			var oldBounds:Rectangle = new Rectangle(x, y, width, height);
			var oldRegistrationBounds:Rectangle = new Rectangle(registrationX, registrationY, registrationWidth, registrationHeight);

			// flag to avoid sending multiple layout events if autolayout occurs
			resizingNow = true;
			for (var i:int = 0; i < videoPlayers.length; i++) {
				var vp:VideoPlayer = videoPlayers[i];
				if (vp !== null) vp.height = _origHeight * ys;
			}
			resizingNow = false;

			dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT, false, false, oldBounds, oldRegistrationBounds));
		}

		/**
		 * A Boolean value that is <code>true</code> if the user is scrubbing with the SeekBar 
		 * and <code>false</code> otherwise. 
		 * 
		 * <p>Scrubbing refers to grabbing the handle of the SeekBar and dragging 
         * it in either direction to locate a particular scene in the FLV file.</p> 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get scrubbing():Boolean {
			var ctrl:Sprite = seekBar;
			if (ctrl != null) {
				var ctrlData:ControlData = uiMgr.ctrlDataDict[ctrl];
				return ctrlData.isDragging;
			}
			return false;
		}

		/**
         * The SeekBar control.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get seekBar():Sprite {
			return uiMgr.getControl(UIManager.SEEK_BAR);
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set seekBar(s:Sprite):void {
			uiMgr.setControl(UIManager.SEEK_BAR, s);
		}

		/**
		 * A number that specifies, in milliseconds, how often to check the SeekBar handle 
		 * when scrubbing. 
		 * 
		 * <p>Because this interval is set by a call to the global <code>setInterval()</code> method, 
		 * the update cannot start more frequently than the SWF file frame rate. So, for 
		 * the default frame rate of 12 frames per second, for example, the lowest 
		 * effective interval that you can create is approximately 83 milliseconds, 
         * or 1 second (1000 milliseconds) divided by 12.</p>
         *
		 * @default 250
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get seekBarInterval():Number {
			return uiMgr.seekBarInterval
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set seekBarInterval(s:Number):void {
			uiMgr.seekBarInterval = s;
		}

		/**
		 * A number that specifies how far a user can move the SeekBar handle before an 
		 * update occurs. The value is specified as a percentage, ranging from 1 to 100. 
		 * 
         * @default 5
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get seekBarScrubTolerance():Number {
			return uiMgr.seekBarScrubTolerance;
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set seekBarScrubTolerance(s:Number):void {
			uiMgr.seekBarScrubTolerance = s;
		}

		/**
		 * The number of seconds that the <code>seekToPrevNavCuePoint()</code> method uses 
		 * when it compares its time against the previous cue point. The method uses this 
		 * value to ensure that, if you are just ahead of a cue point, you can hop 
		 * over it to the previous one and avoid going to the same cue point that 
         * just occurred.
         *
         * @default 1
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get seekToPrevOffset():Number {
			return _seekToPrevOffset;
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set seekToPrevOffset(s:Number):void {
			_seekToPrevOffset = s;
		}

        [Inspectable(type="Video Skin")]
		/**
		 * A string that specifies the URL to a skin SWF file. This string could contain a 
		 * file name, a relative path such as Skins/MySkin.swf, or an absolute URL such 
         * as http://www.&#37;somedomain&#37;.com/MySkin.swf.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get skin():String {
			return uiMgr.skin;
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set skin(s:String):void {
			uiMgr.skin = s;
		}

        [Inspectable(defaultValue=false)]
		/**
		 * A Boolean value that, if <code>true</code>, hides the component skin when the mouse 
		 * is not over the video. This property affects only skins that are loaded by setting 
		 * the <code>skin</code> property and not a skin that you create from the FLVPlayback 
		 * Custom UI components.
		 *
		 * <p>When the component is in full-screen takeover mode and the skin is one that does not lay over
		 * the video, then <code>skinAutoHide</code> mode is turned on automatically. Setting <code>skinAutoHide = false</code>
		 * after you enter full-screen mode overrides this behavior. Also when the component is
		 * in full-screen takeover mode, autohiding is triggered if the user doesn't move the
         * mouse for more than <code>fullScreenSkinDelay</code> seconds, unless the mouse is over the skin itself.</p>
         *
         * @default false
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get skinAutoHide():Boolean {
			return uiMgr.skinAutoHide;
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set skinAutoHide(b:Boolean):void {
			// in live preview always leave to default of false
			if (isLivePreview) return;
			uiMgr.skinAutoHide = b;
		}

        [Inspectable(defaultValue="0.85")]
		/**
		 * The alpha for the background of the skin. The <code>skinBackgroundAlpha</code>
		 * property works only with SWF files that have skins loaded by using the
		 * <code>skin</code> property and with skins that support setting the color
		 * and alpha. You can set the <code>skinBackgroundAlpha</code> property
		 * to a number between 0.0 and 1.0. The default is the last value chosen by the
		 * user as the default.
		 *
		 * <p>To get the skin colors that come with the ActionScript 2.0 FLVPlayback component,
		 * use the following values for the
		 * <code>skinBackgroundAlpha</code> and <code>skinBackgroundColor</code> properties:
		 * Arctic - 0.85, 0x47ABCB;
		 * Clear - 0.20, 0xFFFFFF; Mojave - 0.85, 0xBFBD9F; Steel - 0.85, 0x666666. 
		 * The default is .85.</p>
		 *
                 *
		 * @see #skin
         * @see #skinBackgroundColor
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get skinBackgroundAlpha():Number {
			return uiMgr.skinBackgroundAlpha;
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set skinBackgroundAlpha(a:Number):void {
			uiMgr.skinBackgroundAlpha = a;
		}

        [Inspectable(type="Color",defaultValue="#47ABCB")]
		/**
		 * The color for the background of the skin (0xRRGGBB).  The <code>skinBackgroundColor</code>
		 * property works only with SWF files that have skins loaded by using the
		 * <code>skin</code> property and with skins that support setting the color
		 * and alpha. The default is the last value chosen by the
		 * user as the default.
		 *
		 * <p>To get the skin colors that come with the ActionScript 2.0 FLVPlayback component,
		 * use the following values for the
		 * <code>skinBackgroundAlpha</code> and <code>skinBackgroundColor</code> properties:
		 * Arctic - 0.85, 0x47ABCB;
		 * Clear - 0.20, 0xFFFFFF; Mojave - 0.85, 0xBFBD9F; Steel - 0.85, 0x666666. 
		 * The default is 0x47ABCB.</p>
		 *
                 *
		 * @see #skin
         * @see #skinBackgroundAlpha
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get skinBackgroundColor():uint {
			return uiMgr.skinBackgroundColor;
        }
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set skinBackgroundColor(c:uint):void {
			uiMgr.skinBackgroundColor = c;
		}

		/**
		 * The amount of time in milliseconds that it takes for the skin to fade in or fade out when 
		 * hiding or showing. Hiding and showing occurs because the <code>skinAutoHide</code> 
		 * property is set to <code>true</code>. Set the <code>skinFadeTime</code> property to 
         * 0 to eliminate the fade effect. 
         * 
		 * @default 500 milliseconds (.5 seconds)
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get skinFadeTime():int {
			return uiMgr.skinFadeTime;
		}
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set skinFadeTime(i:int):void {
			uiMgr.skinFadeTime = i;
		}

	/**
	* This property specifies the largest multiple that FLVPlayback will use to scale up
	* its skin when it enters full screen mode with a Flash Player that supports
	* hardware acceleration. With hardware acceleration, the video and the skin are scaled
	* by the same factor. By default, FLVPlayback renders the video at its native dimensions
	* and allows hardware acceleration to do the rest of the scaling. If, for example,
	* your video has dimensions of 640 x 512 and it goes to full screen size on a monitor with
	* a resolution of 1280 x 1024, the video and the skin will be scaled up to twice their
	* size.
	*
	* <p>This property enables you to restrict scaling of the skin when hardware acceleration 
	* is used, based on the specific content that is being scaled and your aesthetic
	* tastes regarding the appearance of large skins. To limit scaling of the skin to the 
	* specified multiplier, FLVPlayback uses a mix of software and hardware scaling for the skin, 
	* which can have a negative impact on the performance of video playback and the
	* appearance of the FLV.</p>
	* 
	* <p>For example, if this property was set to 5.0 or greater, going to full screen on a 
	* monitor that has a resolution of 1600 x 1200 with a video that has dimensions of
	* 320 x 240 would scale the skin five times. If this property was set to 2.5, the player 
	* would render the video (but not the skin) at 640 x 480, twice it's original size, and hardware acceleration
	* would do the remainder of the scaling (640 x 2.5 = 1600 and 480 x 2.5 = 1200).</p>
	*
	* <p>Setting this property after full screen mode has already
	* been entered has no effect until the next time FLVPlayback enters full screen
	* mode.</p>
	*
	* <p>If the FLV is large (for example, 640 pixels wide or more, 480 pixels 
	* tall or more) you should not set this property to a small value because it
	* could cause noticeable performance problems on large monitors.</p>
	*
    * <p><strong>Player Version</strong>: Flash Player 9 <a target="mm_external" href="http://www.adobe.com/go/fp9_update3">Update 3</a>.</p>
    *
	* @default 4.0
	*
	* @see #enterFullScreenDisplayState()
	* @see flash.display.Stage#displayState 
	*
	* @includeExample examples/FLVPlayback.skinScaleMaximum.1.as -noswf
	*
        * @langversion 3.0
        * @internal Flash 9.0.xx.0
	*/
		public function get skinScaleMaximum():Number {
			return uiMgr.skinScaleMaximum;
		}
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set skinScaleMaximum(value:Number):void {
			uiMgr.skinScaleMaximum = value;
		}

		/**
		 * Provides direct access to the
		 * <code>VideoPlayer.soundTransform</code> property to expose
		 * more sound control. You need to set this property for changes to take effect, 
		 * or you can get the value of this property to get a copy of the current settings. 
		 *
		 * @see #volume
         * @see VideoPlayer#soundTransform
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public override function get soundTransform():SoundTransform {
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			var st:SoundTransform = vp.soundTransform;
			if (scrubbing) {
				st.volume = _volume;
			}
			return st;
		}
        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public override function set soundTransform(st:SoundTransform):void {
			if (st == null) return;

			_volume = st.volume;

			_soundTransform.volume = (scrubbing) ? 0 : st.volume;
			_soundTransform.leftToLeft = st.leftToLeft;
			_soundTransform.leftToRight = st.leftToRight;
			_soundTransform.rightToLeft = st.rightToLeft;
			_soundTransform.rightToRight = st.rightToRight;

			var vp:VideoPlayer = videoPlayers[_activeVP];
			vp.soundTransform = _soundTransform;

			dispatchEvent(new SoundEvent(SoundEvent.SOUND_UPDATE, false, false, vp.soundTransform));
		}

		/**
		 * A string that specifies the state of the component. This property is set by the 
		 * <code>load()</code>, <code>play()</code>, <code>stop()</code>, <code>pause()</code>, 
		 * and <code>seek()</code> methods. 
		 * 
		 * <p>The possible values for the state property are: <code>"buffering"</code>, <code>"connectionError"</code>, 
		 * <code>"disconnected"</code>, <code>"loading"</code>, <code>"paused"</code>, <code>"playing"</code>, <code>"rewinding"</code>, <code>"seeking"</code>, and 
		 * <code>"stopped"</code>. You can use the FLVPlayback class properties to test for 
		 * these states. </p>
		 *
		 * @see VideoState#DISCONNECTED
		 * @see VideoState#STOPPED
		 * @see VideoState#PLAYING
		 * @see VideoState#PAUSED
		 * @see VideoState#BUFFERING
		 * @see VideoState#LOADING
		 * @see VideoState#CONNECTION_ERROR
		 * @see VideoState#REWINDING
         * @see VideoState#SEEKING
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get state():String {
			// for live preview, always make state STOPPED
			if (isLivePreview) {
				return VideoState.STOPPED;
			}
				
			// if no VideoPlayer exists (would only happen constructor
			// called), return VideoState.DISCONNECTED
			var vp:VideoPlayer = videoPlayers[_activeVP];

			// force state to SEEKING while scrubbing
			if (_activeVP == _visibleVP && scrubbing) return VideoState.SEEKING;


			var currentState:String = vp.state;

			// force state to LOADING if it is RESIZING. RESIZING is just
			// needed for internal VideoPlayer use anyways, make it
			// LOADING, less confusing for user, esp when suppressing
			// STOPPED as we do below...
			if (currentState == VideoState.RESIZING) return VideoState.LOADING;

			// force state to LOADING when STOPPED because autoPlay is
			// true and waiting for skin to download to show all at once
			var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
			if (vpState.prevState == VideoState.LOADING && vpState.autoPlay && currentState == VideoState.STOPPED) {
				return VideoState.LOADING;
			}

			return currentState;
		}

		/**
		 * A Boolean value that is <code>true</code> if the state is responsive. If the state is 
		 * unresponsive, calls to the <code>play()</code>, <code>load()</code>, <code>stop()</code>, <code>pause()</code> and <code>seek()</code>
		 * methods are queued and executed later, when the state changes to a 
		 * responsive one. Because these calls are queued and executed later, 
		 * it is usually not necessary to track the value of the <code>stateResponsive </code>
		 * property. The responsive states are: 
		 * <code>stopped</code>, <code>playing</code>, <code>paused</code>, and <code>buffering</code>. 
		 *
         * @see VideoPlayer#stateResponsive
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get stateResponsive():Boolean {
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.stateResponsive;
		}

		/**
         * The Stop button control.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get stopButton():Sprite {
			return uiMgr.getControl(UIManager.STOP_BUTTON);
		}
		public function set stopButton(s:Sprite):void {
			uiMgr.setControl(UIManager.STOP_BUTTON, s);
		}

		/**
		 * A Boolean value that is <code>true</code> if the state of the FLVPlayback instance is stopped. 
         * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get stopped():Boolean {
			return (state == VideoState.STOPPED);
		}

		/**
		 * A number that is the total playing time for the video in seconds.
		 *
		 * <p>When streaming from Flash Media Server (FMS) and using the default
		 * <code>NCManager</code>, this value is determined
		 * automatically by server-side APIs, and that value 
		 * overrides anything set through this property or gathered
		 * from metadata. The property is ready for reading when the
		 * <code>stopped</code> or <code>playing</code> state is reached after setting the
		 * <code>source</code> property. This property is meaningless for live streams
		 * from a FMS.</p>
		 *
		 * <p>With an HTTP download, the value is determined
		 * automatically if the FLV file has metadata embedded; otherwise,
		 * set it explicitly or it will be NaN.  If you set it
		 * explicitly, the metadata value in the stream is
		 * ignored.</p>
		 *
		 * <p>When you set this property, the value takes effect for the next
		 * FLV file that is loaded by setting the <code>source</code> property. It has no effect
		 * on an FLV file that has already loaded.  Also, this property does not return 
		 * the new value passed in until an FLV file is loaded.</p>
		 *
		 * <p>Playback still works if this property is never set (either
		 * explicitly or automatically), but it can cause problems
		 * with seek controls.</p>
		 *
		 * <p>Unless set explicitly, the value will be NaN until it is set to a valid value from metadata.</p>
		 *
		 * @see #source
		 * @tiptext The total length of the FLV file in seconds
         * @helpid 3467
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get totalTime():Number
		{
			if (isLivePreview) return 1;
			var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
			if (vpState.totalTimeSet) return vpState.totalTime;
			var vp:VideoPlayer = videoPlayers[_activeVP];
			return vp.totalTime;
        }

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set totalTime(aTime:Number):void
		{
			var vpState:VideoPlayerState = videoPlayerStates[_activeVP];
			vpState.totalTime = aTime;
			vpState.totalTimeSet = true;
		}

		/**
		 * A number that you can use to manage multiple FLV file streams. 
		 * Sets which video player instance is visible, audible, and
		 * controlled by the skin or playback controls, while the rest 
		 * of the video players are hidden and muted. It does
		 * not make the video player the
		 * target for most APIs; use the <code>activeVideoPlayerIndex</code> property to do that.
		 *
		 * <p>Methods and properties that control dimensions interact with this property. 
		 * The methods and properties that set the dimensions of the video player 
		 * (<code>setScale()</code>, <code>setSize()</code>, <code>width</code>, <code>height</code>, <code>scaleX</code>, <code>scaleY</code>) can be used 
		 * for all video players. However, depending on the value of the
		 * <code>scaleMode</code> property
		 * on those video players, they might have different dimensions. Reading 
		 * the dimensions using the <code>width</code>, <code>height</code>, <code>scaleX,</code> and <code>scaleY</code> 
		 * properties gives you 
		 * the dimensions only of the visible video player. Other video players might have 
		 * the same dimensions or might not.</p>
		 *
		 * <p>To get the dimensions of various video players when they are
		 * not visible, listen for the <code>layout</code> event, and store the size
		 * value.</p>
		 *
		 * <p>This property does not have any implications for visibility of the 
		 * component as a whole, only which video player is visible when the component is visible.
		 * To set visibility for the entire component, use the <code>visible</code> property.</p>
		 *
		 * @see #activeVideoPlayerIndex
         * @see flash.display.DisplayObject#visible DisplayObject.visible
         * 
		 * @default 0
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get visibleVideoPlayerIndex():uint {
			return _visibleVP;
        }

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set visibleVideoPlayerIndex(i:uint):void {
			if (_visibleVP == i) return;

			if (videoPlayers[i] == undefined) createVideoPlayer(i);

			var newVp:VideoPlayer = videoPlayers[i];
			var oldVp:VideoPlayer = videoPlayers[_visibleVP];
			oldVp.visible = false;
			oldVp.volume = 0;
			_visibleVP = i;

			// only show it if stream and skin ready
			if (_firstStreamShown) {
				uiMgr.setupSkinAutoHide(false);
				newVp.visible = true;
				_soundTransform.volume = (scrubbing) ? 0 : _volume;
				newVp.soundTransform = _soundTransform;
			} else if ((newVp.stateResponsive || newVp.state == VideoState.CONNECTION_ERROR || newVp.state == VideoState.DISCONNECTED) && uiMgr.skinReady) {
				uiMgr.visible = true;
				uiMgr.setupSkinAutoHide(false);
				_firstStreamReady = true;
				if (uiMgr.skin == "") {
					uiMgr.hookUpCustomComponents();
				}
				showFirstStream();
			}

			// layout event				
			if (newVp.height != oldVp.height || newVp.width != oldVp.width) {
				var oldBounds:Rectangle = new Rectangle(oldVp.x + super.x, oldVp.y + super.y, oldVp.width, oldVp.height);
				var oldRegistrationBounds:Rectangle = new Rectangle(oldVp.registrationX + super.x, oldVp.registrationY + super.y, oldVp.registrationWidth, oldVp.registrationHeight);
				dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT, false, false, oldBounds, oldRegistrationBounds));
			}

			// sending extra bogus events to UIManager so UI is updated propertly for new vp
			var cachedActiveVP:uint = _activeVP;
			_activeVP = _visibleVP;
			uiMgr.handleIVPEvent(new VideoEvent(VideoEvent.STATE_CHANGE, false, false, state, playheadTime, _visibleVP));
			uiMgr.handleIVPEvent(new VideoEvent(VideoEvent.PLAYHEAD_UPDATE, false, false, state, playheadTime, _visibleVP));
			if (newVp.isRTMP) {
				uiMgr.handleIVPEvent(new VideoEvent(VideoEvent.READY, false, false, state, playheadTime, _visibleVP));
			} else {
				uiMgr.handleIVPEvent(new VideoProgressEvent(VideoProgressEvent.PROGRESS, false, false, bytesLoaded, bytesTotal, _visibleVP));
			}
			_activeVP = cachedActiveVP;
		}

        [Inspectable(defaultValue=1)]
		/**
		 * A number in the range of 0 to 1 that indicates the volume control setting. 
		 * @default 1
		 *
		 * @tiptext The volume setting in value range from 0 to 1.
		 * @helpid 3468
         * @see #soundTransform
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get volume():Number
		{
			return _volume;
        }

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set volume(aVol:Number):void
		{
			if (_volume == aVol) return;
			_volume = aVol;
			if (!scrubbing) {
				var vp:VideoPlayer = videoPlayers[_visibleVP];
				vp.volume = _volume;
			}
			dispatchEvent(new SoundEvent(SoundEvent.SOUND_UPDATE, false, false, vp.soundTransform));
		}

		/**
         * The volume bar control.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get volumeBar():Sprite {
			return uiMgr.getControl(UIManager.VOLUME_BAR);
        }

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set volumeBar(s:Sprite):void {
			uiMgr.setControl(UIManager.VOLUME_BAR, s);
		}

		/**
		 * A number that specifies, in milliseconds, how often 
		 * to check the volume bar handle location when scrubbing.
         *
         * @default 250
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get volumeBarInterval():Number {
			return uiMgr.volumeBarInterval
        }

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set volumeBarInterval(s:Number):void {
			uiMgr.volumeBarInterval = s;
		}

		/**
		 * A number that specifies how far a user can move the volume bar handle before 
		 * an update occurs. The value is expressed as a percentage from 1 to 100.  Set to 0
		 * to indicate no scrub tolerance. Always update the volume on the
		 * <code>volumeBarInterval</code> property regardless of how far the user moved the handle.
         *
         * @default 0
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 *
		 */
		public function get volumeBarScrubTolerance():Number {
			return uiMgr.volumeBarScrubTolerance;
        }

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set volumeBarScrubTolerance(s:Number):void {
			uiMgr.volumeBarScrubTolerance = s;
		}

		/**
		 * A number that specifies the width of the FLVPlayback instance on the Stage. 
		 * This property affects only the width of the FLVPlayback instance and does 
		 * not include the width of a skin SWF file that might be loaded. Use the 
		 * FLVPlayback <code>width</code> property and not the <code>DisplayObject.width</code> property because 
		 * the <code>width</code> property might give a different value if a skin SWF file is loaded.
		 * Setting the width property also sets the <code>registrationWidth</code> property
		 * to the same value.
		 *
		 * @see #setSize()
         * @helpid 0
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public override function get width():Number {
			if (isLivePreview) return livePreviewWidth;
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			return vp.width;
		}
        /**
         * @private (setter)
         */
		public override function set width(w:Number):void {
			if (isLivePreview) {
				setSize(w, this.height);
				return;
			}

			var oldBounds:Rectangle = new Rectangle(x, y, width, height);
			var oldRegistrationBounds:Rectangle = new Rectangle(registrationX, registrationY, registrationWidth, registrationHeight);

			// flag to avoid sending multiple layout events if autolayout occurs
			resizingNow = true;
			for (var i:int = 0; i < videoPlayers.length; i++) {
				var vp:VideoPlayer = videoPlayers[i];
				if (vp != null) vp.width = w;
			}
			resizingNow = false;

			dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT, false, false, oldBounds, oldRegistrationBounds));
		}

		/**
         * @copy fl.video.VideoPlayer#x
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public override function get x():Number {
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			return (super.x + vp.x);
		}
        /**
         * @private (setter)
         *
         */
		public override function set x(x:Number):void {
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			super.x = (x - vp.x);
		}

		/**
         * @copy fl.video.VideoPlayer#y
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public override function get y():Number {
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			return (super.y + vp.y);
        }

        /**
         * @private (setter)
         *
      	 */
		public override function set y(y:Number):void {
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			super.y = (y - vp.y);
		}
		//
		// private and package internal methods
		//


		/**
		 * Creates and configures VideoPlayer movie clip.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function createVideoPlayer(index:Number):void {
			// do nothing for live preview
			if (isLivePreview) return;

			// create if not already created
			var vp:VideoPlayer = videoPlayers[index];
			if (vp == null) {
				videoPlayers[index] = vp = new VideoPlayer(0, 0);
				vp.setSize(registrationWidth, registrationHeight);
			}

			// invisible and mute by default
			vp.visible = false;
			vp.volume = 0;
			vp.name = String(index);

			// add to display list
			var added:Boolean = false;
			if (uiMgr.skin_mc != null) {
				try {
					var skinDepth:int = getChildIndex(uiMgr.skin_mc);
					if (skinDepth > 0) {
						addChildAt(vp, skinDepth);
						added = true;
					}
				} catch (err:Error) {
				}
			}
			if (!added) {
				addChild(vp);
			}
			_topVP = index;

			// init
			vp.autoRewind = _autoRewind;
			vp.scaleMode = _scaleMode;
			vp.bufferTime = _bufferTime;
			vp.idleTimeout = _idleTimeout;
			vp.playheadUpdateInterval = _playheadUpdateInterval;
			vp.progressInterval = _progressInterval;
			vp.soundTransform = _soundTransform;

			// init state object and start onEnterFrame if source set
			var vpState:VideoPlayerState = new VideoPlayerState(vp, index);
			videoPlayerStates[index] = vpState;
			videoPlayerStateDict[vp] = vpState;

			// listen to events from VideoPlayer
			vp.addEventListener(AutoLayoutEvent.AUTO_LAYOUT, handleAutoLayoutEvent);
			vp.addEventListener(MetadataEvent.CUE_POINT, handleMetadataEvent);
			vp.addEventListener(MetadataEvent.METADATA_RECEIVED, handleMetadataEvent);
			vp.addEventListener(VideoProgressEvent.PROGRESS, handleVideoProgressEvent);
			vp.addEventListener(VideoEvent.AUTO_REWOUND, handleVideoEvent);
			vp.addEventListener(VideoEvent.CLOSE, handleVideoEvent);
			vp.addEventListener(VideoEvent.COMPLETE, handleVideoEvent);
			vp.addEventListener(VideoEvent.PLAYHEAD_UPDATE, handleVideoEvent);
			vp.addEventListener(VideoEvent.STATE_CHANGE, handleVideoEvent);
			vp.addEventListener(VideoEvent.READY, handleVideoEvent);
			vp.addEventListener(VideoEvent.UNSUPPORTED_PLAYER_VERSION, handleVideoEvent);

			// create CuePointManager to pair with VideoPlayer
			var cpMgr:CuePointManager = new CuePointManager(this, index);
			cuePointMgrs[index] = cpMgr;
			cpMgr.playheadUpdateInterval = _playheadUpdateInterval;
		}

		/**
		 * Creates live preview placeholder.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private function createLivePreviewMovieClip():void {
			preview_mc = new MovieClip();
			preview_mc.name = "preview_mc";

			preview_mc.box_mc = new MovieClip();
			preview_mc.box_mc.name = "box_mc";
			preview_mc.box_mc.graphics.beginFill(0x000000);
			preview_mc.box_mc.graphics.moveTo(0, 0);
			preview_mc.box_mc.graphics.lineTo(0, 100);
			preview_mc.box_mc.graphics.lineTo(100, 100);
			preview_mc.box_mc.graphics.lineTo(100, 0);
			preview_mc.box_mc.graphics.lineTo(0, 0);
			preview_mc.box_mc.graphics.endFill();
			preview_mc.addChild(preview_mc.box_mc);

			preview_mc.icon_mc = new Icon();
			preview_mc.icon_mc.name = "icon_mc";
			preview_mc.addChild(preview_mc.icon_mc);

			addChild(preview_mc);
		}

		/**
		 * Handles load of live preview image
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private function onCompletePreview(e:Event):void {
			try {
				previewImage_mc.width = livePreviewWidth;
				previewImage_mc.height = livePreviewHeight;
			} catch (e:Error) {
			}
		}

		/**
		 * Called on <code>onEnterFrame</code> to initiate loading the new
		 * source url.  We delay to give the user time to set other
		 * vars as well.  Only done this way when source set from the
		 * component inspector or property inspector, not when set with AS.
		 *
		 * @see #source
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private function doContentPathConnect(eventOrIndex:*):void {
			if (isLivePreview) return;

			var index:int = 0;
			if (eventOrIndex is int) {
				index = int(eventOrIndex);
			} else {
				// if this was on an event, remove
				removeEventListener(Event.ENTER_FRAME, doContentPathConnect);
			}

			var vp:VideoPlayer = videoPlayers[index];
			var vpState:VideoPlayerState = videoPlayerStates[index];
			if (!vpState.isWaiting) return;
			if (vpState.autoPlay && _firstStreamShown) {
				vp.play(vpState.url, vpState.totalTime, vpState.isLive);
			} else {
				vp.load(vpState.url, vpState.totalTime, vpState.isLive);
			}
			vpState.isLiveSet = false;
			vpState.totalTimeSet = false;
			vpState.isWaiting = false;
		}

		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function showFirstStream():void {
			_firstStreamShown = true;
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			vp.visible = true;
			if (!scrubbing) {
				_soundTransform.volume = _volume;
				vp.soundTransform = _soundTransform;
			}
			// play all autoPlay streams loaded into other video players
			// that have been waiting and fire all the queued commands
			for (var i:int = 0; i < videoPlayers.length; i++) {
				vp = videoPlayers[i];
				if (vp != null) {
					// start all my autoplays
					var vpState:VideoPlayerState = videoPlayerStates[i];
					if (vp.state == VideoState.STOPPED && vpState.autoPlay) {
						if (vp.isRTMP) {
							vp.play();
						} else {
							vpState.prevState = VideoState.STOPPED;
							vp.playWhenEnoughDownloaded();
						}
					}
					// fire off queued commands
					if (vpState.cmdQueue != null) {
						for (var j:int = 0; j < vpState.cmdQueue.length; j++) {
							switch (vpState.cmdQueue[j].type) {
							case QueuedCommand.PLAY:
								vp.play();
								break;
							case QueuedCommand.PAUSE:
								vp.pause();
								break;
							case QueuedCommand.STOP:
								vp.stop();
								break;
							case QueuedCommand.SEEK:
								vp.seek(vpState.cmdQueue[j].time);
								break;
							case QueuedCommand.PLAY_WHEN_ENOUGH:
								vp.playWhenEnoughDownloaded();
								break;
							} // switch
						}
						vpState.cmdQueue = null;
					}
				}
			}
		}

		/**
		 * Called by UIManager when SeekBar scrubbing starts
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function _scrubStart():void {
			var nowTime:Number = playheadTime;
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			_volume = vp.volume;
			vp.volume = 0;
			dispatchEvent(new VideoEvent(VideoEvent.STATE_CHANGE, false, false, VideoState.SEEKING, nowTime, _visibleVP));
			dispatchEvent(new VideoEvent(VideoEvent.SCRUB_START, false, false, VideoState.SEEKING, nowTime, _visibleVP))
		}

		/**
		 * Called by UIManager when seekbar scrubbing finishes
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function _scrubFinish():void {
			var nowTime:Number = playheadTime;
			var nowState:String = state;
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			_soundTransform.volume = _volume;
			vp.soundTransform = _soundTransform;
			if (nowState != VideoState.SEEKING) {
				dispatchEvent(new VideoEvent(VideoEvent.STATE_CHANGE, false, false, nowState, nowTime, _visibleVP));
			}
			dispatchEvent(new VideoEvent(VideoEvent.SCRUB_FINISH, false, false, nowState, nowTime, _visibleVP))
		}

		/**
		 * Called by UIManager when skin errors
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function skinError(message:String):void {
			if (isLivePreview) return;
			if (_firstStreamReady && !_firstStreamShown) {
				showFirstStream();
			}
			dispatchEvent(new SkinErrorEvent(SkinErrorEvent.SKIN_ERROR, false, false, message));
		}

		/**
		 * Called by UIManager when skin loads
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function skinLoaded():void {
			if (isLivePreview) return;
			var vp:VideoPlayer = videoPlayers[_visibleVP];
			if (_firstStreamReady || vp.state == VideoState.CONNECTION_ERROR || vp.state == VideoState.DISCONNECTED) {
				uiMgr.visible = true;
				if (!_firstStreamShown) {
					showFirstStream();
				}
			} else {
				if (skinShowTimer != null) {
					skinShowTimer.reset();
					skinShowTimer = null;
				}
				skinShowTimer = new Timer(DEFAULT_SKIN_SHOW_TIMER_INTERVAL, 1);
				skinShowTimer.addEventListener(TimerEvent.TIMER, showSkinNow);
				skinShowTimer.start();
			}
			dispatchEvent(new VideoEvent(VideoEvent.SKIN_LOADED, false, false, state, playheadTime, _visibleVP));
		}

		/**
		 * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function showSkinNow(e:TimerEvent):void {
			skinShowTimer = null;
			uiMgr.visible = true;
		}

		/**
		 * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function queueCmd(vpState:VideoPlayerState, type:Number, time:Number=NaN):void {
			if (vpState.cmdQueue == null) vpState.cmdQueue = new Array();
			vpState.cmdQueue.push(new QueuedCommand(type, null, false, time));
		}

		/**
		 * Assigns a tabIndex value to each of the FLVPlayback controls by sorting 
		 * them by position horizontally left to right. This method returns the next available tabIndex value.
		 * 
		 * <p>If you call <code>assignTabIndexes</code> with <code>NaN</code> as the <code>startTabbing</code> 
		 * parameter and the FLVPlayback component instance has a <code>tabIndex</code> value assigned to it, 
		 * the method will use the FLVPlayback component instance's assigned <code>tabIndex</code> as the <code>startTabIndex</code>.</p>
		 * <p>When an FLVPlayback skin is specified, you should wait a frame after the <code>FLVPlayback.SKIN_LOADED</code> event 
		 * to allow the skin controls to initialize before calling this method.</p>
		 * 
		 * <p>When using custom controls, wait a frame after the <code>FLVPlayback.READY</code> event to allow
		 * the custom controls to initialize befor calling this method.</p>
		 * 
         * @param startTabbing The starting tabIndex for FLVPlayback controls.
		 * 
		 * @return The next available tabIndex after the FLVPlayback controls.
		 * 
		 * @see #endTabIndex
		 * @see #startTabIndex
         *
		 * @includeExample examples/FLVPlaybackTabIndexExample.as -noswf
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function assignTabIndexes(startTabIndex:int):int {
			
			if(tabIndex){
				tabEnabled = false;
				tabChildren = true;
				if(isNaN(startTabIndex)){
					startTabIndex = tabIndex;
				}
			}
			
			var nextTabIndex:int = uiMgr.assignTabIndexes(startTabIndex);
			return nextTabIndex;
		}
		
		/**
		 * Returns the next available tabIndex value after the FLVPlayback controls. The value is set after the <code>assignTabIndexes</code> method is called.
		 * 
		 * @return the next available tabIndex after the FLVPlayback controls
		 * 
		 * @see #assignTabIndexes()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get endTabIndex():int {
			return uiMgr.endTabIndex; 
		}
		
		
		/**
		 * Returns the first tabIndex value for the FLVPlayback controls. The value is set after the <code>assignTabIndexes</code> method is called.
		 * 
		 * @return first tabIndex value for the FLVPlayback controls
		 * 
		 * @see #assignTabIndexes()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get startTabIndex():int {
			if(uiMgr.startTabIndex){
				return uiMgr.startTabIndex;
			} else if(tabIndex){
				return tabIndex;
			}
			return uiMgr.startTabIndex;
		}
		
		//ifdef DEBUG
		///**
		// * @private
		// */
		//public function debugTrace(s:String):void {
		//	if (_debuggingOn) {
		//		if (_debugFn != null) {
		//			_debugFn.call(null, s);
		//		} else {
		//			trace(s);
		//		}
		//	}
		//}
		//endif	
	} // class FLVPlayback

} // package fl.video
