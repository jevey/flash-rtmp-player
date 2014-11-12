// Copyright © 2004-2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.video {

	use namespace flvplayback_internal;
	
	/**
     * @private
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public dynamic class VideoPlayerClient {

		protected var _owner:VideoPlayer;
		protected var gotMetadata:Boolean;

		public function VideoPlayerClient(vp:VideoPlayer) {
			_owner = vp;
			gotMetadata = false;
		}

		public function get owner():VideoPlayer {
			return _owner;
		}
		
		/**
		 * handles NetStream.onMetaData callback
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */

		public function onMetaData(info:Object, ...rest):void {
			// First sanity checks to ensure this is good metadata.
			// if not, these will cause an error to be thrown
			info.duration;
			info.width;
			info.height;
			
			_owner.onMetaData(info);
			gotMetadata = true;
		}

		/**
		 * handles NetStream.onCuePoint callback
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function onCuePoint(info:Object, ...rest):void {
			// First sanity checks to ensure this is a good cue point.
			// if not, these will cause an error to be thrown
			info.name;
			info.time;
			info.type;

			_owner.onCuePoint(info);
		}

		/**
		 * property that specifies whether early messages (onMetaData, any
		 * custom messages that might be expected) have been received so
		 * it is OK for the player to rewind back to the beginning.
		 */
		public function get ready():Boolean {
			return gotMetadata;
		}
		
	} // class VideoPlayerClient

} // package fl.video
