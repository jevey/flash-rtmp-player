// ActionScript file
import com.adobetv.*;

import fl.video.*;

import flash.display.*;
import flash.events.*;

import mx.events.SliderEvent;

//SWF Input variables
private var streamType:String;
private var serverURL:String;
private var streamName:String;
private var dynamicStreamControl:String;
private var dynamicSensitivity:String;
private var autoStart:String; 
private var ds_Status_ON:String;

//Current Swf size
[Bindable]private var swfWidth:Number;
[Bindable]private var swfHeight:Number;
// It is a constant for this video player
[Bindable]private var videoWidth:Number;
[Bindable]private var videoHeight:Number;
[Bindable]private var videoX:Number;
[Bindable]private var videoY:Number;
// It is the current size of the video
[Bindable]private var currentVideoW:Number;
[Bindable]private var currentVideoH:Number;

// Control Panel settings
//  *** Always**** 
// Initialize with default values;
[Bindable]private var playerControlHeight:Number;
[Bindable]private var playerControlWidth:Number;
[Bindable]private var playerControlX:Number;
[Bindable]private var playerControlY:Number;
[Bindable]private var isVideoControlVisible:Boolean;
[Bindable]private var qualityPercentage:Number;
[Bindable]private var strQualityToolTip:String;

// UI related declarations
private var normalSwfW:Number = 640;
private var normalSwfH:Number = 377;
private var normalControlH:Number = 25;
private var normalControlW:Number = 640;
// ***** Video size settings *** 
// Video should never be larger than this ( Except in full screen :))
private var maxVideoH:Number = 352;
private var maxVideoW:Number = 640;
// ToDo: Desired size of video as given by HTML embed tags
private var iRegistrationH:Number = 352;
private var iRegistrationW:Number = 640;
// **************
// Playback states
private var isMuted:Boolean = false;
private var currentVolume:Number = 0.5;
public var vid:FLVPlayback;
private var isPlaying:Boolean = false; // TODO: set it to false now. set this variable when playback starts.
private var state:Number = 0;
private var isFullScreen:Boolean = false;
private var sliderDragging:Boolean;
private var waitForSeek:Boolean;
private var isVideoEnabled:Boolean = true;
private var ns:*;

private var source:String;
private var currentDeliveryType:String;
private var isFirstPlay:Boolean;	// set when video is played for first time
private var isDsEnabled:Boolean;	// whether dynamic stream is disabled or not
private var flashVersion:Number;
private var inSmilDataForm:Boolean = false;	// whether the url is given in text form instead of smil file

private var dsItems:DynamicStreamItem;

private var streams:Array;	// contains the streams of the dynamic stream
private var urls:Array; // contains the stream name and bitrates in case of the smil data sis specified through url

// this defines the time interval in which the buffer progress showing func would be called
// only in progressive download case
private var progressInterval:Number;

//workaround for reconnecting back when stream got disconnected/connection error
//vid.play() has a bug when if reconnect gets success, we continueously see buffering though playback
// start( not getting VideoState.PLAYING)
private var canPlay:Boolean = false;
private var isReinitAllowed:Boolean = false;
private var isReinitInProgress:Boolean = false;

// Mouse activity Timeout for fullscreen mode
private var mouseActivityTimer:Timer = new Timer(5000, 0);
// blink timer of HD bar
private var HDBlinkTimer:Timer = new Timer(700, 0);
// timer for displaying server messages
private var serverMesgTimer:Timer = new Timer(2000, 0);

//public var ds:DynamicStream;
//VideoPlayer.iNCManagerClass = fl.video.NCManagerDynamicStream;

// Ir will never work if the screen size is less than 640 x 23
public function initScreen(height:Number, width:Number):void{

	var currentW:Number;
	var currentH:Number;
	
 //initialize swf width.
	swfWidth = width;
	swfHeight = height;	
	// Video Controls-- Constants!
	playerControlHeight = normalControlH;
	playerControlWidth = normalControlW;
	// Always put the control in center
	playerControlX = (swfWidth- playerControlWidth)/2;
	playerControlY = isFullScreen ? (swfHeight- playerControlHeight - 100)
					: (swfHeight- playerControlHeight);
	
	// Video Panel Size
//	videoWidth = swfWidth;
//	videoHeight = isFullScreen ? swfHeight : swfHeight-playerControlHeight;

	currentVideoW = isFullScreen ? swfWidth : videoWidth;
	currentVideoH = isFullScreen ? swfHeight : videoHeight;

	videoX = (swfWidth-currentVideoW)/2;
	videoY = (swfHeight - currentVideoH - (isFullScreen ? 0 : playerControlHeight ))/2;

	// set video size, TODO: Place this call somewhere else.
	vid.setSize(currentVideoW, currentVideoH);
	
	if(isFullScreen)
		isVideoControlVisible = true;
	
	trace("########");
	trace("videoWidth:"+videoWidth);
	trace("videoHeight:"+videoHeight);
	trace("videoX:"+videoX);
	trace("videoY:"+videoY);
}

public function initVars():void{
	
	// get the current flash version used
	currentFlashVersion();
	
	// get the 'flashvars' variables specified in html container
	getHtmlParameters();
	
	// time interval to upgrade the progress bar
	progressInterval = 1000;
	
	// create FLVPlayback instance
	try{
	vid = new FLVPlayback();
	}catch(e:Error){ trace("error");}
	
	// add the instance to stage
	container.addChild(vid);
	vid.fullScreenTakeOver = false;
	
	// register events
	vid.addEventListener(VideoEvent.PLAYHEAD_UPDATE, onPlayheadUpdate);
	vid.addEventListener(VideoEvent.STATE_CHANGE, onVideoStateChange);
	vid.addEventListener(VideoEvent.CLOSE, onVideoClose);
	vid.addEventListener(VideoEvent.COMPLETE, onVideoClose);
	vid.addEventListener(MetadataEvent.METADATA_RECEIVED, onMetaData);
	vid.addEventListener(MetadataEvent.CUE_POINT, onMetaData);
	vid.addEventListener(VideoProgressEvent.PROGRESS, progressEventHandler);
	vid.addEventListener(VideoEvent.UNSUPPORTED_PLAYER_VERSION, unsupportedPlayerHandler);
	vid.addEventListener(VideoEvent.READY, onVideoReady);
	
	addEventListener(MouseEvent.MOUSE_MOVE,onMouseActivity,false);
	mouseActivityTimer.addEventListener(TimerEvent.TIMER, MouseActivityTimeout);
	HDBlinkTimer.addEventListener(TimerEvent.TIMER, ButtonBlink);
	serverMesgTimer.addEventListener(TimerEvent.TIMER, removeServerMesgDisplay);
	
	serverStatusMsgOverlay.addEventListener(MouseEvent.MOUSE_OVER, statusBarMouseOverHandler);
	serverStatusMsgOverlay.addEventListener(MouseEvent.MOUSE_OUT, statusBarMouseOutHandler);
	
	mouseActivityTimer.start();
		
	systemManager.stage.addEventListener(FullScreenEvent.FULL_SCREEN, doFullScreen);
	Security.allowDomain(Security.LOCAL_WITH_NETWORK);

	// initialise the video player	
	initialise();
	
	// initialise the screen width/height
	if(isFullScreen){
		initScreen(screen.height,screen.width);			
	}else{
		initScreen(normalSwfH,normalSwfW);
	}	
	
	slider.value = 0;
	volumeSlider.value = 0.5
	//progressBar.visible = true;
	waitForSeek = false;
	sliderDragging = false;
	slider.enabled = false;
	
	slider.allowTrackClick = false;
	slider.liveDragging = true;	
	isVideoControlVisible = true;

	// if no url is specified	
	if(serverURL == "null")
		source = "http://";
	
	// if the smil data is specified as text in url field
	if(inSmilDataForm == true)
	{
		createNetStream();
	}	
	else
	{	
		// specify the source to flvplayback component
		try{
			vid.source = source;
		} 
		catch(e:VideoError){
			trace("error");
			videoErrorHandling(e.code);
		}
		catch(e:SecurityError){
			trace("error");
			securityErrorHandler(e);
		}
	}
	
	isPlaying = false;
	slider.enabled = true;
	slider.visible = true;
	
	// video smoothing is on
	vid.getVideoPlayer(vid.activeVideoPlayerIndex).smoothing = true;

	check();
}
	
private function createNetStream():void
{
	// get the current player instance
	var vp:VideoPlayer = vid.getVideoPlayer(vid.activeVideoPlayerIndex);

	// create a dynamic stream list
	var dsi:DynamicStreamItem = new DynamicStreamItem();
	
	dsItems = dsi;
	
	for(var i:Number=1; i < urls.length ; i++)
	{
		// add the streams list
		
		if(!urls[i][1])	// if no bitrate is specified
			dsi.addStream(urls[i][0], 0);	
		else
			dsi.addStream(urls[i][0], urls[i][1]);
	}
		
//	ds.startPlay(dsi);
	try{
		dsi.uri = urls[0][0];	// specify the fms server url which is the first entry in urls list
		vid.play2(dsi);			// now play the dynamic stream
	}catch(err:VideoError){
    	 videoErrorHandling(err.code);
	}
	

}

// ******** Seek Bar Handling **********	
// Converts time to timecode
private function showScrubTime(val:String):String {
	// Current play time
   	var sec:Number = Number(val);
	var h:Number = Math.floor(sec/3600);
	var m:Number = Math.floor((sec%3600)/60);
	var s:Number = Math.floor((sec%3600)%60);
	// Total play time
	var secMax:Number = Number(slider.maximum);
	var hMax:Number = Math.floor(secMax/3600);
	var mMax:Number = Math.floor((secMax%3600)/60);
	var sMax:Number = Math.floor((secMax%3600)%60);	
	// 
	return (h == 0 ? "":(h<10 ? "0"+h.toString()+":" : h.toString()+":"))
			+(m<10 ? "0"+m.toString() : m.toString())+":"
			+(s<10 ? "0"+s.toString() : s.toString()) 
			+"/"
			+(hMax<10 ? "0"+hMax.toString()+":" : hMax.toString()+":")
			+(mMax<10 ? "0"+mMax.toString() : mMax.toString())+":"
			+(sMax<10 ? "0"+sMax.toString() : sMax.toString());
}

// Seeks the stream after the slider is dropped
 private function doSeek():void {
 	
 	try{
   		vid.seek(slider.value);
   	}catch(e:Error){
   		trace("seek failed")
   	}
   	if(!isPlaying){
   		doPlayPause();
   	}
 }
 
 // Toggles the dragging state
 private function toggleDragging(state:Boolean):void {
   	sliderDragging = state;
   	
   	if (!state) {
   		waitForSeek = true;
   		bufferFrame.visible=true;
   		serverStatusMsgOverlay.visible = true;
   		serverStatusMsgOverlay.label = "Buffering...";
   		doSeek();
   	}
 }
 
public function progressEventHandler(e:VideoProgressEvent) : void
{
	progressBar.setProgress(vid.bytesLoaded,vid.bytesTotal);
}

public function onVideoStateChange(ve:VideoEvent):void{	
   	trace("in video state change");
   	trace("vid.state: "+vid.state);
   	if(vid.totalTime != slider.maximum){
   		slider.maximum = vid.totalTime;
   	}

   	switch(vid.state)
   	{
   		case VideoState.PLAYING:
   			waitForSeek = false;
   			isPlaying = true;
   			bPlayPause.styleName = "pauseButton";
   			bPlayPause.toolTip = "Pause";
   			bufferFrame.visible = false;
   			isVideoEnabled = true;
   			serverStatusMsgOverlay.visible = false;
   			
   			displayServerMesg("Now Playing the Stream");
   
   			if(isDsEnabled && flashVersion >= 10)
	   		{
	   			// Hack : for displaying overlay play button in case of smil in url form 
	   			if(inSmilDataForm && autoStart == "false" && isFirstPlay && !isReinitInProgress)
	   			{
	   					try{
							vid.pause();
						}catch(err:VideoError){
    	 					videoErrorHandling(err.code);
						}
	   			}

	   			// get netstream from the component
	   			var vp:VideoPlayer = vid.getVideoPlayer(vid.activeVideoPlayerIndex);
	   			
	   			// get the current netstream associated with fms connection
	   			ns = vp.netStream;		
	   			streams = vp.ncMgr.streams;
	   			
	   			sortStreams();
				ns.addEventListener(NetStatusEvent.NET_STATUS, onNSStatus);
				
				changeQualityStatus();
	   			
	   			for(var i=0;i<streams.length;i++)
	   				trace("stream name :" + streams[i].src);
	   			
	   			if(dynamicStreamControl == "manual")
	   			 try{ ns.manualSwitchMode(true); }catch(e:Error){ trace(e.message);}
	   			else
	   			 try{ ns.manualSwitchMode(false); }catch(e:Error){ trace(e.message);}
				
	   		}
	  
	  		// re-size the screen to counter the prob of screen shifting when fullscreen toggling
	  		// is done after playback of stream 		
	   		if(isFullScreen){
				initScreen(screen.height,screen.width);			
			}else{
				initScreen(normalSwfH,normalSwfW);
			}
	   		isReinitInProgress = false;
   			break;
   		case VideoState.BUFFERING:
   			bufferFrame.visible = true;
   			isVideoEnabled = true;
   			serverStatusMsgOverlay.visible = true;
   			serverStatusMsgOverlay.label = "Buffering...";
   			canPlay = true;
   			isReinitAllowed = false;
   			break;
   		case VideoState.STOPPED:
   			bufferFrame.visible = false;
   			//when autostart is false & we have reinitialized then we like to start playback
   			if(!isReinitInProgress)
   			{
   				showOverlayPlayButton();	
   			}
   			isVideoEnabled = false;
   			playStoppedView();
   			canPlay = true;
   			isReinitAllowed = false;

   		case VideoState.PAUSED:
   			isPlaying = false;
   			bPlayPause.styleName = "playButton";
   			bPlayPause.toolTip = "Play";
   			serverStatusMsgOverlay.visible = false;
   			
   			// Hack : for displaying overlay play button in case of smil in url form 
   			if(inSmilDataForm && autoStart == "false" && isFirstPlay && !isReinitInProgress)
   				showOverlayPlayButton();
   			if(isReinitInProgress && autoStart == "false")
   			{
   				//when autostart is false & we have reinitialized then we like to start playback
   				try{
					vid.play();
				}catch(err:VideoError){
 					videoErrorHandling(err.code);
				}   				
   			}	
			break;
   		case VideoState.CONNECTION_ERROR:
   			isPlaying = false;
   			bufferFrame.visible = false;
   			serverStatusMsgOverlay.visible = true;
   			if(serverURL == "" || serverURL == "null")
   				serverStatusMsgOverlay.label = "Please Enter a Stream Name and Play.";
   			else
   				serverStatusMsgOverlay.label = "Connection Error. Please press Play to try again.";
   			isVideoEnabled = false;
   			playStoppedView();
   			canPlay = false;
   			if(serverURL != "" && serverURL != "null")
   			{
   				isReinitAllowed = true;
   			}
   			isReinitInProgress = false;
   			break;
   		case VideoState.DISCONNECTED:
   			bufferFrame.visible = false;
   			serverStatusMsgOverlay.visible = true;
   			serverStatusMsgOverlay.label = "Stream Disconnected. Please press Play to try again.";
   			isVideoEnabled = false;
   			playStoppedView();
   			canPlay = false;
   			isReinitAllowed = true;
   			isReinitInProgress = false;
   			break;
   		case VideoState.LOADING:
   			serverStatusMsgOverlay.visible = true;
   			serverStatusMsgOverlay.label = "Loading...";
   			break;
   		case VideoState.REWINDING:
			try{ 
				vid.play(); 
			}catch(err:VideoError){
				trace("video error"); 
				 videoErrorHandling(err.code);
			}
 			break;  			
   	}
    	
}

private function onNSStatus(event:NetStatusEvent):void
{
	switch (event.info.code) 
	{
		case "NetStream.Play.Transition":
					trace("Switched stream\n");
					
						// update the current stream bitrate status
					changeQualityStatus();
					
					displayServerMesg("Now Playing " + ns.currentStreamBitRate + " kbps Stream");
					
					break;
	}
}

public function onPlayheadUpdate(ve:VideoEvent):void{
   	if(isPlaying && !sliderDragging && !waitForSeek){ 
   		slider.value = ve.playheadTime;
   	}
   	
}

private function videoErrorHandling(err:uint) : void
{
	switch(err)
	{
		case VideoError.INVALID_SOURCE:
			serverStatusMsgOverlay.visible = true;
			slider.y = 11;	
   			serverStatusMsgOverlay.label = "Source Stream Not Found";
			playStoppedView();
			canPlay = false;
			break;
			
		case VideoError.NO_CONNECTION:
			serverStatusMsgOverlay.visible = true;
			serverStatusMsgOverlay.label = "Connection Error. Please press Play to try again.";
			playStoppedView();
			canPlay = false;
			isReinitAllowed = true;
			isReinitInProgress = false;
			break;
			
		default:
			serverStatusMsgOverlay.visible = true;
			serverStatusMsgOverlay.label = "Error has occurred in playback:"+err.toString();
			playStoppedView();
			canPlay = false;
			isReinitAllowed = false;
	}	
}

// Formats the slider dataTip
private function showVolume(val:String):String {
	return (""+Math.round(Number(val)*100)+"");
}

// Changes the stream volume
private function changeVolume(event:SliderEvent):void {
	if(!isPlaying)
		return;
	vid.volume = event.value;
	if(isMuted){
		// Break the silence
		doMute();
	}
}

private function doMute():void{
	if(!isPlaying) 
		return;
	
	if(!isMuted){
		currentVolume= vid.volume;
   		vid.volume=0;
   		isMuted=true;
   		bVolume.toolTip = "Unmute";
   		bVolume.styleName="muteButtonOn";
   	}else{
   		vid.volume=currentVolume;
   		isMuted=false;
   		bVolume.toolTip = "Mute";
   		bVolume.styleName="muteButton";
	}
}
   
// not used currently   
public function onVideoClose(ve:VideoEvent):void{
	trace("Video closed");
}

public function onVideoReady(ve:VideoEvent):void{
	trace("Video Ready");
	var vp:VideoPlayer = vid.getVideoPlayer(ve.vp);
	var nc:NetConnection = vp.netConnection;
	if(nc)
	{
		nc.addEventListener(NetStatusEvent.NET_STATUS, onNCStatus);
	}
}

private function onNCStatus(ev:NetStatusEvent):void{
	switch(ev.info.code)
	{
		case "NetConnection.Connect.Closed":
			isPlaying = false;
			bufferFrame.visible = false;
			bPlayPause.styleName = "playButton";
			bPlayPause.toolTip = "Play";
			serverStatusMsgOverlay.visible = true;
   			serverStatusMsgOverlay.label = "Stream Disconnected. Please press Play to try again.";
   			canPlay = false;
   			isReinitAllowed = true;
   			break;
	}
}

private function reinitialize():void{
	
	vid.removeEventListener(VideoEvent.PLAYHEAD_UPDATE, onPlayheadUpdate);
	vid.removeEventListener(VideoEvent.STATE_CHANGE, onVideoStateChange);
	vid.removeEventListener(VideoEvent.CLOSE, onVideoClose);
	vid.removeEventListener(VideoEvent.COMPLETE, onVideoClose);
	vid.removeEventListener(MetadataEvent.METADATA_RECEIVED, onMetaData);
	vid.removeEventListener(MetadataEvent.CUE_POINT, onMetaData);
	vid.removeEventListener(VideoProgressEvent.PROGRESS, progressEventHandler);
	vid.removeEventListener(VideoEvent.UNSUPPORTED_PLAYER_VERSION, unsupportedPlayerHandler);
	vid.removeEventListener(VideoEvent.READY, onVideoReady);
	
	container.removeChild(vid);
	
	initVars();
}

public function onMetaData(me:MetadataEvent):void{
	for (var i in me.info){
		trace("me.info[i]- "+i+":"+me.info[i])
	}
}
		
public function doPlayPause() : void{
   if(firstTimePlayBtn.visible){
   		firstTimePlayBtn.visible = false;
   }
	if(isPlaying == true){
		try{
			vid.pause();
		}catch(err:VideoError){
			trace("video error"); 
			 videoErrorHandling(err.code);
		}
		bPlayPause.toolTip = "Play";
	}else{
		if(canPlay)
		{
			try{
				vid.play();
			}catch(err:VideoError){
				trace("video error"); 
				 videoErrorHandling(err.code);
			}
			bPlayPause.toolTip = "Pause";
		}
		else if(isReinitAllowed && !isReinitInProgress)
		{
			isReinitInProgress = true;
			reinitialize();
		}
	}
}


private function check() : void{
	var fvideoWidth:Number = videoWidth;
	var fvideoHeight:Number = videoHeight;
	
	if(videoWidth > swfWidth)
		fvideoWidth = swfWidth;
						
	if(videoHeight > (swfHeight - playerControlHeight))
		fvideoHeight = swfHeight - playerControlHeight;
		videoWidth = fvideoWidth;
		videoHeight = fvideoHeight;	
				
}


public function doFullScreen(e:FullScreenEvent) : void{
	try{
		if(e.fullScreen){
			isFullScreen = true;
			initScreen(screen.height,screen.width);			
		}
		else{
			isFullScreen = false;
			isVideoControlVisible = true;
			initScreen(normalSwfH,normalSwfW);
						
		} 
		
	}catch(err:Error){
	trace("Error : " + err.message);
	}
}
	
private function fullScreenHandler() : void{
		try{
			stage.displayState = (stage.displayState == StageDisplayState.FULL_SCREEN) ?
						StageDisplayState.NORMAL : StageDisplayState.FULL_SCREEN;
		}catch(err:Error){
			trace("Security Error : Full screen not allowed");
			serverStatusMsgOverlay.visible = true;
			serverStatusMsgOverlay.label = "Security Error : FullScreen not allowed";
		}
		
		return;	
}

private function onMouseActivity(me:MouseEvent) : void{
	isVideoControlVisible = true;
	state++;

	if(isFullScreen){
		// video controls visible
	
		mouseActivityTimer.reset();
		mouseActivityTimer.start();
	}
}

// functions to handle the focussing of status messages when mouse is placed over the status overlay button
private function statusBarMouseOverHandler(me:MouseEvent) : void
{
	serverStatusMsgOverlay.alpha = 0.8;
}

private function statusBarMouseOutHandler(me:MouseEvent) : void
{
	serverStatusMsgOverlay.alpha = 0.27;
}

private function MouseActivityTimeout(te:TimerEvent):void{
	
	if(isFullScreen){
		// video controls visible
		isVideoControlVisible = false;
		
	}
}

private function removeServerMesgDisplay(te:TimerEvent):void
{
	serverMesgTimer.reset();
	
	// remove the server mesg
	if(canPlay)
	{
		// if canPlay == false it means some error has occured & we like to that error
		// to be persistently displayed on serverStatusMsgOverlay. For ex: lets stream
		// has just started playing & we are displaying 'Now playing the stream' by
		// dsStreamStatusMesgBtn & immediately some connection error occur.
		serverStatusMsgOverlay.visible = false;	
	}
	
	dsStreamStatusMesgBtn.visible = false;
	
}

// change the quality of the dynamic stream
private function onChangeQuality(isUp:Boolean) : void{
	if(!isDsEnabled || !canPlay)
		return;
	
	if(isUp)
	{
		 try{ 
		 	// switch up
		 	ns.switchUp(); 
		 	// display the message
		 	displayServerMesg("Requesting Higher Quality Stream");
		 }catch(e:Error){ 
		 	trace(e.message);
		 }  
	}
	else
	{
		 try{ 
		 	// switch down
		 	ns.switchDown();
		 	// display the message
		 	displayServerMesg("Requesting Lower Quality Stream");
		 }catch(e:Error){ 
		 	trace(e.message);
		 }  
	}
	var bitRate:Number = 0;
	
	try{
		bitRate = ns.currentStreamBitRate;
	}catch(err:Error){
		trace("no property found on ns");
	}
 
} 

private function getHtmlParameters():void{
	var videoH:Number;
	var videoW:Number;
	
	streamType = unescape(parameters.streamType);
//	streamName = unescape(parameters.streamName);
	serverURL = unescape(parameters.serverURL);
	dynamicStreamControl = unescape(parameters.dsControl);
	dynamicSensitivity = parameters.dsSensitivity;	
	autoStart = unescape(parameters.autoStart);
	ds_Status_ON = unescape(parameters.DS_Status);
	videoW = (parameters.videoWidth);
	videoH = parameters.videoHeight;
	
	videoWidth = (videoW > normalSwfW || videoW == 0) ? normalSwfW : videoW;
	videoHeight = (videoH > (normalSwfH - normalControlH) || videoH == 0) ? (normalSwfH - normalControlH) : videoH;
	
	currentVideoW = videoWidth;
	currentVideoH = videoHeight;

}


private function showOverlayPlayButton() : void
{
	if(isFirstPlay)
	{
		isFirstPlay = false;
		
		if(autoStart == "false")
			firstTimePlayBtn.visible = true;
		else
			return;
	}
	isFirstPlay = false;
	firstTimePlayBtn.visible = true;
}

// displays those server mesgs which are time-limit for their display
private function displayServerMesg(mesg:String):void
{
	if(ds_Status_ON == "true")
	{
	//	serverStatusMsgOverlay.visible = true;
//		serverStatusMsgOverlay.label = mesg;

		dsStreamStatusMesgBtn.visible = true;
		dsStreamStatusMesgBtn.label = mesg;
	
		serverMesgTimer.start();
	}
}

private function initialise() : void
{
	autoStart = ((autoStart == "null" || autoStart == "")? "true" : autoStart);
	streamType = ((streamType == "null" || streamType == "")? "vod" : streamType);
	ds_Status_ON = ((ds_Status_ON == "null" || ds_Status_ON == "")? "false" : ds_Status_ON);
	dynamicStreamControl = ((dynamicStreamControl == "null" || dynamicStreamControl == "")? "auto" : dynamicStreamControl);
	
	vid.autoPlay = autoStart == "true" ? true : false;
		
	if(vid.autoPlay == true)
		isFirstPlay = false;
	else
		isFirstPlay = true;
		
	if(streamType == "live")
	{
		vid.isLive = true;
		slider.enabled = false;
	}
	
	// parse the serverURL for stream names and bitrates
	urls = parseXmlSmil(serverURL);
	
	if(!urls)
	{
		return;
	}
		
	// first entry contains the fms server to connect to
	if(urls.length == 1)
		serverURL = urls[0][0];
	else
	{
		serverURL = urls[0][0];
		inSmilDataForm = true;
		
		// if flash player version does not support dynamic streaming then play the first stream specified in
		// smil
		if(flashVersion < 10)
		{
			serverURL = urls[0][0] + "/" + urls[1][0];
			inSmilDataForm = false;
		}			

	}
	
	if(serverURL == "null" || serverURL == "")
		source = "http://";
	else
		source = serverURL;
		
	var type:String = source.substring(source.indexOf(".")+1,source.length);
	
	if(type == "smil" || inSmilDataForm==true)
	{
		VideoPlayer.iNCManagerClass = fl.video.NCManagerDynamicStream;
		
		if(dynamicStreamControl == "manual")
		{
			bQualityDownBtn.enabled = true;
			bQualityUpBtn.enabled = true;
		}
		else
		{
			bQualityDownBtn.enabled = false;
			bQualityUpBtn.enabled = false;
			bQualityDownBtn.toolTip = "Not Available"
			bQualityUpBtn.toolTip = "Not Available"
		}
		
		currentDeliveryType = "smil";
		isDsEnabled = true;
	}
	else
	{
		VideoPlayer.iNCManagerClass = fl.video.NCManagerNative;
		isDsEnabled = false;
		bQualityDownBtn.enabled = false;
		bQualityDownBtn.toolTip = "Not Available"
		bQualityUpBtn.enabled = false;
		bQualityUpBtn.toolTip = "Not Available"
	}

	qualityPercentage = 0;
	qualitySlider.value = 0;
	strQualityToolTip = "";
	
	
	if(flashVersion < 10)
		isDsEnabled = false;
}


private function changeQualityStatus() : void
{
	for(var i:int=0; i<streams.length ; i++)
	{
		if(streams[i].src == ns.currentStreamName)
		{
			qualityPercentage = ((i+1)/streams.length)*100;
			break;
		}
	}
	
	//qualityPercentage;
	strQualityToolTip = "Stream bit-rate " + ns.currentStreamBitRate + "kbps";
	
	HDBlinkBtn.visible = false;
	
	if(qualityPercentage == 100)
		HDBlinkTimer.start();
	else
		HDBlinkTimer.reset();
}

private function playStoppedView() : void
{
	qualityPercentage = 0;
	
	strQualityToolTip = "";
	bPlayPause.styleName = "playButton";
	bPlayPause.toolTip = "Play";
	HDBlinkBtn.visible = false;
	HDBlinkTimer.reset();
}

private function ButtonBlink(te:TimerEvent) : void
{
	//HDBlinkBtn.visible = (HDBlinkBtn.visible == true);// ? false : true);
	HDBlinkBtn.visible = true;
}

private function sortStreams() : void
{
	streams.sort(compareFunc);
}

private function compareFunc(num1:Object, num2:Object) : Number
{
	return ((num1.bitrate > num2.bitrate) ? 1 :((num1.bitrate < num2.bitrate) ? -1 : 0)); 
	
}

private function currentFlashVersion() : void
{
	trace("Flash : " + Capabilities.playerType + "(" + Capabilities.version);
	var versionString:String = Capabilities.version;
	var pattern:RegExp = /^(\w*) (\d*),(\d*),(\d*),(\d*)$/;
	var result:Object = pattern.exec(versionString);
	if (result != null)
	{
	    trace("input: " + result.input);
	    trace("platform: " + result[1]);
	    trace("majorVersion: " + result[2]);
	    trace("minorVersion: " + result[3]);    
	    trace("buildNumber: " + result[4]);
	    trace("internalBuildNumber: " + result[5]);
	    
	    flashVersion = result[2];
	}else{
	    trace("Unable to match RegExp.");
	}
}

// parses source url for server and stream names with bitrates --  deprecated now
private function parseSourceUrl(sourceUrl:String):Array
{
	var sources:Array = sourceUrl.split(';');
	var urls:Array = new Array();
	
	for(var i:Number=0; i < sources.length ; i++)
	{
		var temp:Array = sources[i].split(',');
		urls[i] = temp;
	}	
	
	return urls;
}

// parses source url for server and stream names with bitrates
private function parseXmlSmil(xmlString:String):Array
{
	
	try{
		var smil:XML = new XML(xmlString);
	}catch(e:Error){
		trace("xml parsing error");
		playerErrorHandling(e);
		return null;
	}
	
		
	var urls:Array = new Array();
	var num:Number = 1;
	
	urls[0] = [smil.head.meta.@base.toString(),0];
	
	// if no smil in xml form is specified - i.e simple urls are specified
	if(urls[0][0]=="")
	{
		urls[0][0] = xmlString;
		return urls;
	}
	
	// get each stream parameters
	for each(var i:XML in smil.body.child("switch").video)
	{
		urls[num++] = [i.@src.toString(),int(i.attribute("system-bitrate"))/1000];
	}
	
	
	return urls;
}

private function playerErrorHandling(err:Error):void
{
			serverStatusMsgOverlay.visible = true;
			slider.y = 11;	
   			serverStatusMsgOverlay.label = err.message;
			playStoppedView();
			
}

private function securityErrorHandler(evt:SecurityError):void{
	
	serverStatusMsgOverlay.visible = false;
	securityMesgText.visible = true;
	securityMesgText.enabled = true;
	
	
	slider.y = 11;	  
	playStoppedView();

}

// opens page to change security settings
private function openAdobeSecurityPage():void
{
	navigateToURL(new URLRequest('http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager04a.html'), '_blank');
}

// though this may never be hit but just in case may be needed later on!!
private function unsupportedPlayerHandler(evt:VideoEvent):void
{
	serverStatusMsgOverlay.visible = true;
	serverStatusMsgOverlay.label = "The Flash Player Version you are using is not Supported";
	playStoppedView();
}

// NetConnection.onBWDone handler to avoid Reference Errors
private function onBWDone(... rest):Boolean {
	return true;
}

// NetConnection.onBWCheck handler
private function onBWCheck(... rest):Number {
	return 0;
}