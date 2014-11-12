/*************************************************************************
*                       
* ADOBE SYSTEMS INCORPORATED
* Copyright 2008 Adobe Systems Incorporated
* All Rights Reserved.
*
* NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
* terms of the Adobe license agreement accompanying it.  If you have received this file from a 
* source other than Adobe, then your use, modification, or distribution of it requires the prior 
* written permission of Adobe.
*
**************************************************************************/

package fl.video {
	
		// events
		import flash.events.NetStatusEvent;
		import flash.events.TimerEvent;
		// networking
		import flash.net.NetConnection;
		import flash.net.NetStream;
		import flash.net.NetStreamPlayOptions;
		import flash.net.NetStreamPlayTransitions;
		import flash.net.SharedObject;
		// timers
		import flash.utils.Timer;
		import flash.utils.getTimer;
	
	/**
	* ...
	* @author Default
	*/
	public class DynamicStream extends NetStream {
		
		private var dsPlayList:Array;
		private var dsPlayListLen:int;
		
		private var dsPlayIndex:int = 0;
		private var dsPlayState:String;
		
		private var _nc:NetConnection;
		
		private var _maxRate:Number = 0;
		private var _maxBandwidth:Number = 0;
		private var _curStreamID:int = 0;
		private var _curBufferTime:uint = 0;
		
		private var _previousDroppedFrames:uint = 0;
		private var _previousDroppedFramesTime:uint = 0;
		private var _bufferMode:int = 0;
		private var _reachedBufferTime:Boolean = false;
		private var _switchMode:Boolean = false;
		
		private var _preferredBufferLength:Number;
		private var _startBufferLength:Number;
		private var _aggressiveModeBufferLength:Number;
		private var _switchQOSTimerDelay:Number;
		private var _manualSwitchMode:Boolean;
		private var _droppedFramesLockRate:int; // rate that drops frames in excess of 25%
		private var _droppedFramesLockDelay:int;
		
		private var qosTimer:Timer;
		private var mainTimer:Timer;
		private var droppedFramesTimer:Timer; // lock delay for dropped frames so it doesn't upswitch again
		
		private const QOS_INTERVAL:uint = 4;
		private const MAIN_TIMER_INTERVAL:uint = 150;
		private const DROPPED_FRAMES_TIMER_INTERVAL:uint = 300;  // delay before we unlock the dropped frames lock (in seconds)
		private const DROPPED_FRAMES_LOCK_LIMIT:uint = 3; // limit before that stream is locked permanently due to dropped frames
		
		private const PREFERRED_BUFFERLENGTH:Number = 10; //trying to keep it around 3 times of QOS_INTERVAL so it gets 3 times to update the bitrate
		private const STARTUP_BUFFERLENGTH:Number = 2;
		private const EMPTY_BUFFERLENGTH:Number = 1;
		
		private const BUFFER_FILLED:Number = 1;
		private const BUFFER_BUFFERING:Number = 2;
		
		private const DEBUG:Boolean = false;
		
		private var _lastMaxBandwidthSO:SharedObject;
		
		public const STATE_PLAYING:String = "playing";
		public const STATE_PAUSED:String = "paused";
		public const STATE_BUFFERING:String = "buffering";
		public const STATE_STOPPED:String = "stopped";
				 
		/**
		 * Creates the <code>DynamicStream</code> object, a component for the Dynamic Streaming
		 * feature for FMS.
		 * 
		 * @param nc
		 *
		 * <p>The DynamicStream class automatically switches your streams according to the current
		 * bandwidth statistics.
		 * var ds:DynamicStream = new DynamicStream(nc); </p>
		 *
		 * @langversion 3.0
		 * @playerversion Flash 10.0.0.0
		 */
		public function DynamicStream(nc:NetConnection) {

			super(nc);
			
			_nc = nc;
			
			dsPlayList = new Array();
			
			////
			_preferredBufferLength = PREFERRED_BUFFERLENGTH;
			_startBufferLength = STARTUP_BUFFERLENGTH;
			_aggressiveModeBufferLength = PREFERRED_BUFFERLENGTH/2;
			_switchQOSTimerDelay = QOS_INTERVAL;
			_maxRate = 500000; ///Assuming max stream rate to be 500000 bytes/sec
			_manualSwitchMode = false;
			_droppedFramesLockRate = int.MAX_VALUE;
			
			_maxBandwidth = 0;
			_lastMaxBandwidthSO = SharedObject.getLocal("AdobeDynamicStream", "/", false);
			_maxBandwidth = _lastMaxBandwidthSO.data.maxBandwidth;
			
			_curBufferTime = _startBufferLength;
			
			mainTimer = new Timer(MAIN_TIMER_INTERVAL, 0)
			mainTimer.addEventListener(TimerEvent.TIMER, monitorQOS);
			
			qosTimer  = new Timer(_switchQOSTimerDelay*1000, 0);
			qosTimer.addEventListener(TimerEvent.TIMER, getQOSAndSwitch);
			
			droppedFramesTimer = new Timer(DROPPED_FRAMES_TIMER_INTERVAL*1000, 0);
			droppedFramesTimer.addEventListener(TimerEvent.TIMER, releaseDFLock);
			
			this.addEventListener(NetStatusEvent.NET_STATUS, onNSStatus);				
		}
				
		/**
		 * This is a placeholder for the onMetaData handler.  
		 * @param	infoObj
		 */
		public function onMetaData(infoObj:Object):void { 
		
			debug("onMetaData called");
		}
		
		/**
		 * This is a placeholder for the onPlayStatus handler.
		 * @param	infoObj
		 */
		public function onPlayStatus(infoObj:Object):void { 
			
			debug("onPlayStatus called");
		}
		
		 /**
 		 * The DynamicStream.play method is a superset of the NetStream play method.
 		 * @param args
 		 * 
 		 */		
 		override public function play(...args):void {
			
			if(args[0] is DynamicStreamItem){

				this.startPlay(args[0]);			
			} else {
			
				var dsi:DynamicStreamItem = new DynamicStreamItem();
				dsi.addStream(String(args[0]), 0);
				if(!isNaN(args[1])){ dsi.start = args[1] };
				if(!isNaN(args[2])){ dsi.len = args[2] };
				if(args[3] == false){ dsi.reset = args[3] };
				
				this.startPlay(dsi);
			}
		}
		
 		/**
 		 * The play2 method is disabled in the DynamicStream object. If you need to use play2 then
 		 * create a NetStream object for play2.
 		 * @param param
 		 * 
 		 * @see flash.net.NetStream
 		 */		
 		override public function play2(param:NetStreamPlayOptions):void {
			
			throw new Error( "The play2() method has been disabled for this class.  Please create a separate NetStream object to use play2()." );
		}
		
		/**
		 * This method gets called after the stream object has been created.  If no stream is currently playing the stream will begin to play.
		 * If a stream is playing this will append subsequent stream objects to a playlist.
		 */
		public function startPlay(dsi:DynamicStreamItem):void {
			
			dsi.streamCount = isNaN(dsi.streamCount) ? dsi.streamCount : dsi.streams.length;
			
			dsPlayList[0] = dsi;
			dsPlayListLen = dsPlayList.length;
			
			_curStreamID = 0;
			
			if(dsi.startRate > 0) {
				var i:int = dsPlayList[dsPlayIndex].streams.length-1;
				while(i >= 0) {
					if(dsi.startRate > dsPlayList[dsPlayIndex].streams[i].rate) {
						_curStreamID = i;
						break;
					}	
				 	i--;
				}
			}
			else {
			
				var j:int = dsPlayList[dsPlayIndex].streams.length-1;
				while(j >= 0 && _maxBandwidth > 0) {
					if(_maxBandwidth > dsPlayList[dsPlayIndex].streams[j].rate) {
						_curStreamID = j;
						break;
					}
					j--;
				}
			}
				
			if(dsi.reset == false) {
				
				playAppend(dsi.start, dsi.len, false);
	
			} else {
			
				_curBufferTime = _startBufferLength;
			
				this.bufferTime = _curBufferTime;	
				playAppend(dsi.start, dsi.len, true);
				
			}
			
			/// This call makes a server side call which tells the server how high the bandwidth 
			/// requirement may be, which helps the server in determining the right bursts of messages 
			/// it needs to send and get a quicker response to any stream switching in the event of a 
			/// drop in bandwidth
			/// Here we are taking the highest bit rate of the stream and set a higher value than that
			/// This needs a server side actionscript call to complete the request.
			///
			/// Alternatively this value could be used to manually change the ServerToClient setting 
			/// in the Application.xml file
			/// <Client>
  			///   <Bandwidth>
   			///		<!- Specified in bytes/sec ->
       		///		<ServerToClient>2500000</ServerToClient> //////CHANGE THIS TO REFLECT CLIENT EXPECTED MAX OR HIGHEST BIT RATE OF THE VIDEO
   			///	 </Bandwidth>
			/// </Client>
			/// 
			_maxRate = Math.max(_maxRate,dsi.streams[dsi.streamCount-1].rate * 1024/8);
			_nc.call("setBandwidthLimit",null, _maxRate * 1.2, _maxRate * 1.2);
			
		}
		
		public function switchToStreamName(name: String):void {
			// strip out the prefix
			if(name.indexOf(":") != -1){
				name = name.split(":")[1];
			}
			
			var streamID:int = -1;
			for(var i:int = 0; i < dsPlayList[dsPlayIndex].streams.length; i++){
				if(dsPlayList[dsPlayIndex].streams[i]["name"].indexOf(name) > 0){
					streamID = i;
					break;
				}
			}

			if(_manualSwitchMode && streamID >= 0)
				switchStream(streamID);			
		}
		
		public function switchToStreamRate(rate: int): void {			
			var streamID:int = -1;
			for(var j:int = 0; j < dsPlayList[dsPlayIndex].streams.length; j++){
				if(dsPlayList[dsPlayIndex].streams[j].rate == rate){
					streamID = j;
					break;
				}
			}
			
			//find the next lowest streamID
			if(streamID < 0) {
				var i:int = dsPlayList[dsPlayIndex].streams.length-1;
				while(i >= 0) {
					if(rate > dsPlayList[dsPlayIndex].streams[i].rate) {
						streamID = i;
						break;
					}	
				 	i--;
				}
			}
			
			if(_manualSwitchMode && streamID >= 0)
				switchStream(streamID);		
		}
		
		public function switchUp():void {

			if(_manualSwitchMode)
				switchStream(_curStreamID + 1);
		}
		
		public function switchDown():void {

			if(_manualSwitchMode)
				switchStream(_curStreamID - 1);
		}
		
		public function manualSwitchMode(mode: Boolean):void {
			
			_manualSwitchMode = mode;
		}

		/**
		 * Returns the max bandwidth capacity of this netstream 
		 * @return 
		 * 
		 */	
		 public function get maxBandwidth():Number {
			return _maxBandwidth;
		}
						
		/**
		 * Returns the bit rate of the stream playing currently 
		 * @return 
		 * 
		 */		
		public function get currentStreamBitRate():Number {
			
			return dsPlayList[dsPlayIndex].streams[_curStreamID].rate;
		}
		
		/**
		 * Returns the name of the stream playing currently 
		 * @return 
		 * 
		 */		
		public function get currentStreamName():String {	
			
			return dsPlayList[dsPlayIndex].streams[_curStreamID].name;
		}
		
			
	 	/**
	 	 * Set a preferred optimal buffer length for the stream to run smoothly, giving enough
	 	 * buffer to switch under low bandwidth conditions
	 	 * 
	 	 */
		public function set preferredBufferLength(length: Number):void {
			_preferredBufferLength = length;			
		}
		
		public function get preferredBufferLength():Number {
			return _preferredBufferLength;			
		}
		
	 	/**
	 	 * Set a start value of buffer length. The stream uses this to buffer initially before it starts playback
	 	 * and then switches to the preferred buffer length. This should be a low value for a quick start but big
	 	 * enough to give the stream a chance to compute the max bandwidth available to the stream
	 	 * 
	 	 */
		public function set startBufferLength(length: Number):void {
			_startBufferLength = length;			
		}
		
		public function get startBufferLength():Number {
			return _startBufferLength;			
		}
		
		/**
		 * Set a cut off buffer length value at which we want the stream to switch to the lowest possible bit rate
		 * This is the lowest buffer length we would want the stream to reach and the stream should get into an aggressive
		 * switching mode to prevent buffer getting empty and causing a buffering stage and hence a pause/stutter in the video
		 */
		public function set aggressiveModeBufferLength(length: Number):void {
			_aggressiveModeBufferLength = length;			
		}
		
		public function get aggressiveModeBufferLength():Number {
			return _aggressiveModeBufferLength;			
		}
		
		/**
		 * Specify the frequence at which the stream should check its performance and make switching decisions, either switching up
		 * or down the bit rate options
		 */
		public function set switchQOSTimerDelay(delay: Number):void {
			qosTimer.delay = delay * 1000;
			_switchQOSTimerDelay = delay;			
		}
		
		public function get switchQOSTimerDelay():Number {
			return _switchQOSTimerDelay;			
		}

		/**
		 * Specify the time in seconds in which the stream should not attempt to switch up due to a history of dropping frames.
		 */
		public function set droppedFramesLockDelay(delay: Number):void {
			droppedFramesTimer.delay = delay * 1000;
			_droppedFramesLockDelay = delay;			
		}
		
		public function get droppedFramesLockDelay():Number {
			return _droppedFramesLockDelay;			
		}
				
		/**
		 * Used in building the native playlist 
		 * @param reset
		 * @private
		 */		
		private function playAppend(start:Number, len:Number, reset:Boolean):void {
			
			var nso:NetStreamPlayOptions = new NetStreamPlayOptions();
				nso.streamName = dsPlayList[dsPlayIndex].streams[_curStreamID].name;
				nso.start = start;
				nso.len = len;
				nso.transition = reset ? NetStreamPlayTransitions.RESET : NetStreamPlayTransitions.APPEND;
			
			super.play2(nso);
			
		}
		
		/**
		 * NetStream Status Event Handler
		 * Users wishing to add their own even listener can do so by 
		 * adding one to the DynamicStream object they create.
		 * @param event
		 * @private
		 */		
		private function onNSStatus(event:NetStatusEvent):void
		{
			debug("ns status: " + event.info.code);
			
			switch (event.info.code) {
				
				case "NetStream.Play.Stop":
				
					debug("no more QOS check");		
					dsPlayState = STATE_STOPPED;
					// stream has stopped
					mainTimer.stop();
					qosTimer.stop();
					break;
				
				case "NetStream.Play.Start":
				
					init();
					mainTimer.start();
					dsPlayState = STATE_PLAYING;
					break;
					
				case "NetStream.Buffer.Full":

					getMaxBandwidth();
					SwitchOnMaxBandwidth();
					_bufferMode = BUFFER_FILLED;		
					qosTimer.start();
					break;
				
				case "NetStream.Buffer.Empty":
				
					if(!_manualSwitchMode)
						_curStreamID = 0;
					_curBufferTime = EMPTY_BUFFERLENGTH;
					this.bufferTime = _curBufferTime;
					if(!_manualSwitchMode)
						switchStream();
					qosTimer.stop();
					init();				
					break;
				
				case "NetStream.Seek.Notify":
					_curBufferTime = _startBufferLength;
					this.bufferTime = _curBufferTime;											
					_bufferMode = BUFFER_BUFFERING;
					_reachedBufferTime = false;
					
					break;
				
				case "NetStream.Pause.Notify":
					if(qosTimer.running){ qosTimer.stop(); }
					if(mainTimer.running){ mainTimer.stop(); }
					dsPlayState = STATE_PAUSED;
					break;
				
				case "NetStream.Unpause.Notify":
					if(!qosTimer.running){ qosTimer.start(); }
					if(!mainTimer.running){ mainTimer.start(); }
					dsPlayState = STATE_PLAYING;
					break;	
					
				case "NetStream.Play.Transition":
					_switchMode = false;
					break;
					
			}
			
		}
		
		/**
		 * Returns the max bandwidth value in Kbps 
		 * @return 
		 * 
		 */		
		private function getMaxBandwidth():void {
			_maxBandwidth =  this.info.maxBytesPerSecond*8/1024;			
		}


		/**
		 * Defaults variables 
		 * 
		 */			
		private function init():void {
			
			debug("initializing ...");
			
			
			
			_previousDroppedFrames = this.info.droppedFrames;
			_previousDroppedFramesTime = getTimer();
			
			_bufferMode = BUFFER_BUFFERING;
			
			_reachedBufferTime = false;
			_switchMode = false;
		}

		/**
		 * Monitors the QOS stats 
		 * @param te
		 * @private
		 */
		private function monitorQOS(te:TimerEvent):void {
			var curTime:Number = this.time;
		
			if(this.time == 0)
				return;
							
			if(_bufferMode == BUFFER_BUFFERING) 
				return;
			
			if(this.bufferLength >= _preferredBufferLength)
				_reachedBufferTime = true;
			
			getMaxBandwidth();
				
		}

		/**
		 * Switches the stream in the native playlist 
		 * @param streamID
		 * @private
		 */		
		private function switchStream(streamID:Number = 0): void {

			if(streamID < 0)
				streamID = 0;
				
			if(streamID > dsPlayList[dsPlayIndex].streams.length-1)
				streamID = dsPlayList[dsPlayIndex].streams.length-1;
				 
			if(streamID == _curStreamID)
				return;
			
			if(_switchMode == true) //dont send another transition if the previous 
				return;			   //one is in process already
		
			_curStreamID = streamID;
		
			debug("switching to bit rate: "+ dsPlayList[dsPlayIndex].streams[_curStreamID].rate);
			
			var nso:NetStreamPlayOptions = new NetStreamPlayOptions();
				nso.streamName = dsPlayList[dsPlayIndex].streams[_curStreamID].name;
				nso.transition = NetStreamPlayTransitions.SWITCH;
				nso.start = dsPlayList[dsPlayIndex].start;
				nso.len = dsPlayList[dsPlayIndex].len;
			
			super.play2(nso);
			_switchMode = true;
		}


		private function getQOSAndSwitch(te:TimerEvent):void {
			
			if(_manualSwitchMode)
				return;
				
			//debug("getQOSAndSwitch called");
			debug("current max bandwidth: "+_maxBandwidth);
			
			///writing out the max bandwidth value for future sessions
			_lastMaxBandwidthSO.data.maxBandwidth = _maxBandwidth;
			
			//downscale
			var nowTime:int = getTimer();
			if( (this.bufferLength < _preferredBufferLength)|| ((_maxBandwidth < dsPlayList[dsPlayIndex].streams[_curStreamID].rate) && (_maxBandwidth != 0)) 
				|| ((this.info.droppedFrames - _previousDroppedFrames)*1000/(nowTime - _previousDroppedFramesTime) > this.currentFPS*0.25)) {
				var nextStreamID:int = 0;
			
				if(this.bufferLength < _preferredBufferLength || (_maxBandwidth < dsPlayList[dsPlayIndex].streams[_curStreamID].rate)) {
					//debug("buffer length less than target buffertime or bitrate lower than max: "+_curBufferTime);
					var droppedFrames:Number = this.info.droppedFrames;
			
				
					var i:int = dsPlayList[dsPlayIndex].streamCount-1;
					while(i >= 0) {
						if(_maxBandwidth > dsPlayList[dsPlayIndex].streams[i].rate) {
							nextStreamID = i;
							break;
						}	
				 		i--;
					}
					
				
					if(this.bufferLength > _curBufferTime && _curBufferTime != _preferredBufferLength) 
					{
						_curBufferTime =  _preferredBufferLength;
						debug("setting buffer time to "+_curBufferTime);
						this.bufferTime = _curBufferTime;
					}
					
					if( nextStreamID < _curStreamID) {
						if(_maxBandwidth < dsPlayList[dsPlayIndex].streams[_curStreamID].rate) {
							debug("Switching down because of maxBitrate lower than current stream bitrate");
						} else if(this.bufferLength < _curBufferTime) {
							debug("Switching down because of buffer");
						}
					}
					
				} else {
					debug("Switching down because of dropped fps "+(this.info.droppedFrames - _previousDroppedFrames)*1000/(nowTime - _previousDroppedFramesTime)+ " is greather than 0.25 of fps: "+ this.currentFPS*0.25);
					
					// init lock timer and flag lock rate
					_droppedFramesLockRate = dsPlayList[dsPlayIndex].streams[_curStreamID].rate;
										
					if((droppedFramesTimer.currentCount < DROPPED_FRAMES_LOCK_LIMIT)  && !droppedFramesTimer.running) {
						droppedFramesTimer.start();
						debug("Activating lock to prevent switching to " + _droppedFramesLockRate + " | Offense Number " + droppedFramesTimer.currentCount);
					}
					
					
					nextStreamID = _curStreamID -1;
				}
				
				///aggressively go down to the latest bit rate if the buffer is below the half mark of the expected buffer length
				if(this.bufferLength < _aggressiveModeBufferLength && _reachedBufferTime) {
						debug("switching to the aggressive mode");
						nextStreamID = 0;
						///check more frequently
						qosTimer.delay = _switchQOSTimerDelay*1000/2;									
				} 	
				
				if(nextStreamID > 0) {
	 				if(dsPlayList[dsPlayIndex].streams[nextStreamID].rate >= _droppedFramesLockRate) {
						return;
					}
				}
					
				if(_curStreamID != nextStreamID) {
					switchStream(nextStreamID);
				}
					
				_previousDroppedFrames = this.info.droppedFrames;
				_previousDroppedFramesTime = getTimer();
				
			} else {
				
				SwitchOnMaxBandwidth();
		
				///also reverting QOS interval
				if(qosTimer.delay != _switchQOSTimerDelay*1000) {
					qosTimer.delay = _switchQOSTimerDelay*1000;
				}
			}
		}
		
		private function releaseDFLock(te:TimerEvent):void {
			
			debug("Releasing dropped frames lock and setting the rate back to MAX_VALUE");
			_droppedFramesLockRate = int.MAX_VALUE;
			droppedFramesTimer.stop();
		}

		private function SwitchOnMaxBandwidth():void {

			if(_manualSwitchMode)
				return;
				
			var nowTime:int = getTimer();
			debug("current max bandwidth: "+_maxBandwidth);
			
			var droppedFrames:int = this.info.droppedFrames;
			var nextStreamID:int = 0;
			var i:int = dsPlayList[dsPlayIndex].streamCount-1;
			while(i >= 0) {
				if(_maxBandwidth > dsPlayList[dsPlayIndex].streams[i].rate) {
					nextStreamID = i;
					break;
				}
				 i--;
			}
			
			if( nextStreamID < _curStreamID) {
				//we are testing if we can switch up here... so dont go down
				nextStreamID = _curStreamID;
			}  else if (nextStreamID > _curStreamID) {
				///go up only if the buffer length looks good
				if(this.bufferLength < _curBufferTime) {
						nextStreamID = _curStreamID;
				}
			}
			
			//regardless of bandwidth if the dropped frame count is higher than 25% of fps
			//then switch to lower bitrate
			if(_curStreamID > 0 && ((droppedFrames - _previousDroppedFrames)*1000/(nowTime - _previousDroppedFramesTime) > this.currentFPS*0.25)) {
				nextStreamID = _curStreamID-1;
				debug("switching down because of dropped frames");
			}
			
			if(nextStreamID > (dsPlayList[dsPlayIndex].streamCount - 1)) {
				nextStreamID = dsPlayList[dsPlayIndex].streamCount - 1;
			}
			
			if(nextStreamID > 0) {
				if(dsPlayList[dsPlayIndex].streams[nextStreamID].rate >= _droppedFramesLockRate) {
					return;
				}
			}
			
			if(_curStreamID != nextStreamID) {
				switchStream(nextStreamID);
			} 
			
			if(_curBufferTime != _preferredBufferLength) 
			{
				_curBufferTime =  _preferredBufferLength;
				debug("setting buffer time to "+_curBufferTime);
				this.bufferTime = _curBufferTime;
			}
		}

		/**
		 * Debug function, a superset of trace that can be toggled with DEBUG 
		 * @param msg
		 * @private
		 */	
		private function debug(msg:String):void {
			if(DEBUG) { trace(msg); }
		}
	
	}
}
