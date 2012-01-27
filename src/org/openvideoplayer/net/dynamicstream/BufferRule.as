﻿//
// Copyright (c) 2009, the Open Video Player authors. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are 
// met:
//
//    * Redistributions of source code must retain the above copyright 
//		notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above 
//		copyright notice, this list of conditions and the following 
//		disclaimer in the documentation and/or other materials provided 
//		with the distribution.
//    * Neither the name of the openvideoplayer.org nor the names of its 
//		contributors may be used to endorse or promote products derived 
//		from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

package org.openvideoplayer.net.dynamicstream 
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	
	import org.openvideoplayer.events.OvpEvent;

	/**
	 * Dispatched when a debug message is being sent. The message itself will
	 * be carried by the contents of the data property.
	 * 
	 * @see org.openvideoplayer.events.OvpEvent
	 */
 	[Event (name="debug", type="org.openvideoplayer.events.OvpEvent")]
 	
	/**
	 * Switching rule for Buffer detection.
	 */
	public class BufferRule extends EventDispatcher implements ISwitchingRule {

		
		/* TUNABLE PARAMETERS FOR THIS RULE */
		
		private const PANIC_BUFFER_LEVEL:Number = 2;
		
		/* END TUNABLE PARAMETERS */
		

		private var _metrics:INetStreamMetrics;
		private var _panic:Boolean;
		private var _reason: String;
		
		/**
		 * Constructor
		 * 
		 * @param a metrics provider which implements the INetStreamMetrics interface
		 */
		public function BufferRule(metrics:INetStreamMetrics):void {
			super(null);
			_metrics = metrics;
			_metrics.netStream.addEventListener(NetStatusEvent.NET_STATUS,monitorNetStatus);
			_panic = false;
		}
		
		/**
		 * The new bitrate index to which this rule recommends switching. If the rule has no change request, either up or down, it will
		 * return a value of -1. 
		 * 
		 */
        public function getNewIndex():int { 
			if (!_panic) {
				_reason = "Buffer  of " + Math.round(_metrics.bufferLength)  + " < " + PANIC_BUFFER_LEVEL + " seconds";
			}
			return _panic  || (_metrics.bufferLength < PANIC_BUFFER_LEVEL && _metrics.reachedTargetBufferFull)? 0:-1;
		}
		
		/** 
		 * @private
		 */
		private function monitorNetStatus(e:NetStatusEvent):void {
			switch (e.info.code) {
				case "NetStream.Buffer.Full":
					_panic = false;
				break;
				case "NetStream.Buffer.Empty":
				if (Math.round(_metrics.netStream.time) != 0) {
					_panic = true;
					_reason = "Buffer was empty";
				}
				break;
				case "NetStream.Play.InsufficientBW":
					_panic = true;
					_reason = "Stream had insufficient bandwidth";
				break;
			}
		}
		
		/**
		 * Returns the reason the rule is suggesting the new index. This information is intended to be read by humans
		 * and may be used during the debugging process. 
		 */
		public function get reason():String {
			return _reason;
		}
    }
}
