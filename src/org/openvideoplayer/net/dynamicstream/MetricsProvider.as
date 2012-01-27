//
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
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import org.openvideoplayer.events.OvpEvent;
	
	/**
 	 * Dispatched when the class has a debug message to propagate.
	 */
 	[Event (name = "debug", type = "org.openvideoplayer.events.OvpEvent")]
	
	/**
	 * The purpose of the MetricsProvider class is to provide run-time metrics to the switching rules. It 
	 * makes use of the metrics offered by netstream.info, but more importantly it calculates running averages, which we feel
	 * are more robust metrics on which to make switching decisions. It's goal is to be the one-stop shop for all the info you
	 * need about the health of the stream.
	 */
	public class MetricsProvider extends EventDispatcher implements INetStreamMetrics
	{
		private var _ns:NetStream;
		private var _timer:Timer;
		private var _reachedTargetBufferFull:Boolean;
		private var _currentBufferSize:Number;
		private var _maxBufferSize:Number;
		private var _lastMaxBitrate:Number;
		private var _avgMaxBitrateArray:Array;
		private var _avgMaxBitrate:Number;
		private var _avgDroppedFrameRateArray:Array;
		private var _avgDroppedFrameRate:Number;
		private var _frameDropRate:Number;
		private var _lastFrameDropValue:Number;
		private var _lastFrameDropCounter:Number;
		private var _maxFrameRate:Number
		private var _currentIndex:uint;
		private var _dsi:DynamicStreamItem;
		private var _so:SharedObject;
		private var _targetBufferTime:Number;
		private var _enabled:Boolean;
		private var _optimizeForLivebandwidthEstimate:Boolean;
		
		private var _qualityRating:Number;
		
		private const DEFAULT_UPDATE_INTERVAL:Number = 100;
		private const DEFAULT_AVG_BANDWIDTH_SAMPLE_SIZE:Number = 50;
		private const DEFAULT_AVG_FRAMERATE_SAMPLE_SIZE:Number = 50;
		
		
		/**
		 * Constructor
		 * 
		 * Note that for correct operation of this class, the caller must set the dynamicStreamItem which
		 * the monitored stream is playing each time a new item is played.
		 * 
		 * @param	netstream instance that it will monitor.
		 * @see #dynamicStreamItem()
		 */
		public function MetricsProvider(ns:NetStream)
		{
			super(null);
			_ns = ns;
			_ns.addEventListener(NetStatusEvent.NET_STATUS,netStatus);
			initValues();
			_so = SharedObject.getLocal("OVPMetricsProvider", "/", false);
			if (_so.data.avgMaxBitrate != undefined) {
				_avgMaxBitrate = _so.data.avgMaxBitrate;
			}
			_timer = new Timer(DEFAULT_UPDATE_INTERVAL);
			_timer.addEventListener(TimerEvent.TIMER, update);
		}
		
		
		/**
		 *@private
		 */
		private function initValues():void {
			_frameDropRate = 0;
			_reachedTargetBufferFull = false;
			_lastFrameDropCounter = 0;
			_lastFrameDropValue = 0;
			_maxFrameRate = 0;
			_optimizeForLivebandwidthEstimate = false;
			_avgMaxBitrateArray = new Array();
			_avgDroppedFrameRateArray = new Array();
			_enabled = true;
			_targetBufferTime = 0;
		}
		
		/**
		 * Returns the update interval at which metrics and averages are recalculated
		 */
		public function get updateInterval():Number {
			return _timer.delay
		}
		
		public function set updateInterval(intervalInMilliseconds:Number):void {
			_timer.delay = intervalInMilliseconds;
		}
		
		/**
		 * Returns the NetStream sent in the constructor
		 */
		public function get netStream():NetStream{
			return _ns;
		}
				
		/**
		 * Returns the current index
		 */
		public function get currentIndex():uint{
			return _currentIndex;
		}
		
		public function set currentIndex(i:uint):void {
			_currentIndex = i;
		}
		
		/**
		 * Returns the maximum index value 
		 */
		public function get maxIndex():uint {
			return _dsi.streamCount -1 as uint
		}
		
		/**
		 * Returns the DynamicStreamItem which the class is referencing
		 */
		public function get dynamicStreamItem():DynamicStreamItem{
			return _dsi;
		}
		
		public function set dynamicStreamItem(dsi:DynamicStreamItem):void {
			_dsi= dsi;
		}
		
		/**
		 * Returns true if the target buffer has been reached by the stream
		 */
		public function get reachedTargetBufferFull():Boolean
		{
			return _reachedTargetBufferFull;
		}
		
		/**
		 * Returns the current bufferlength of the NetStream
		 */
		public function get bufferLength():Number
		{
			return _ns.bufferLength;
		}
		
		/**
		 * Retufns the current bufferTime of the NetStream
		 */
		public function get bufferTime():Number
		{
			return _ns.bufferTime;
		}
		
		/**
		 * Returns the target buffer time for the stream. This target is the buffer level at which the 
		 * stream is considered stable. 
		 */
		public function get targetBufferTime():Number
		{
			return _targetBufferTime;
		}
		
		public function set targetBufferTime(targetBufferTime:Number):void 
		{
			_targetBufferTime = targetBufferTime;
		}
		
		
		/**
		 * Flash player can have problems attempting to accurately estimate max bytes available with live streams. The server will buffer the 
		 * content and then dump it quickly to the client. The client sees this as an oscillating series of maxBytesPerSecond measurements, where
		 * the peak roughly corresponds to the true estimate of max bandwidth available. Setting this parameter to true will cause this class
		 * to optimize its estimate for averageMaxBandwidth. It should only be set true for live streams and should always be false for ondemand streams. 
		 */
		public function get optimizeForLivebandwidthEstimate ():Boolean
		{
			return _optimizeForLivebandwidthEstimate 
		}
		public function set optimizeForLivebandwidthEstimate (optimizeForLivebandwidthEstimate :Boolean):void 
		{
			_optimizeForLivebandwidthEstimate  = optimizeForLivebandwidthEstimate ;
		}
		
		/**
		 * Returns the expected frame rate for this NetStream. 
		 */
		public function get expectedFPS():Number
		{
			return _maxFrameRate;
		}
		
		/**
		 * Returns the frame drop rate calculated over the last interval.
		 */
		public function get droppedFPS():Number
		{
			return _frameDropRate;
		}
		
		/**
		 * Returns the average frame-drop rate
		 */
		public function get averageDroppedFPS():Number
		{
			return _avgDroppedFrameRate
		}
		
		
		/**
		 * Returns the last maximum bandwidth measurement, in kbps
		 */
		public function get maxBandwidth():Number
		{
			return _lastMaxBitrate;
		}
		
		/**
		 * Returns the average max bandwidth value, in kbps
		 */
		public function get averageMaxBandwidth():Number
		{
			return _avgMaxBitrate;
		}
		
		/**
		 * Returns a reference to the info property of the monitored NetStream
		 */
		public function get info():NetStreamInfo {
			return _ns.info;
		}
		/**
		 * Enables this metrics engine.  The background processes will only resume on the next
		 * netStream.Play.Start event.
		 */
		public function enable(): void {
			_enabled = true;
		}
		
		/**
		 * Disables this metrics engine. The background averaging processes
		 * are stopped. 
		 */
		public function disable(): void {
			_enabled = false;
			_timer.stop();
		}
		
		/**
		 * @private
		 */
		private function netStatus(e:NetStatusEvent):void {
			switch (e.info.code) {
				case "NetStream.Buffer.Full":
					_reachedTargetBufferFull = _ns.bufferLength >= _targetBufferTime;
					break;
				case "NetStream.Buffer.Empty":
					_reachedTargetBufferFull = false;
					break;
				case "NetStream.Play.Start":
					_reachedTargetBufferFull = false;
					if (!_timer.running && _enabled) {
						_timer.start();
					}
					break;
				case "NetStream.Seek.Notify":
					_reachedTargetBufferFull = false;
					break;
				case "NetStream.Play.Stop":
					_timer.stop();
					break;
			}
		}
		
		/**
		 * @private
		 */
		private function update(e:TimerEvent):void {
			try {
				// Average max bandwdith
				 _lastMaxBitrate = _ns.info.maxBytesPerSecond * 8 / 1024;
				_avgMaxBitrateArray.unshift(_lastMaxBitrate);
				if (_avgMaxBitrateArray.length > DEFAULT_AVG_BANDWIDTH_SAMPLE_SIZE) {
					_avgMaxBitrateArray.pop();
				}
				var totalMaxBitrate:Number = 0;
				var peakMaxBitrate:Number = 0;
				for (var b:uint=0;b<_avgMaxBitrateArray.length;b++) {
					totalMaxBitrate += _avgMaxBitrateArray[b];
					peakMaxBitrate = _avgMaxBitrateArray[b] > peakMaxBitrate ? _avgMaxBitrateArray[b]: peakMaxBitrate;
				}
				_avgMaxBitrate = _avgMaxBitrateArray.length < DEFAULT_AVG_BANDWIDTH_SAMPLE_SIZE ? 0:_optimizeForLivebandwidthEstimate ? peakMaxBitrate:totalMaxBitrate/_avgMaxBitrateArray.length;
				_so.data.avgMaxBitrate = _avgMaxBitrate;
				// Estimate max (true) framerate
				_maxFrameRate = _ns.currentFPS > _maxFrameRate ? _ns.currentFPS:_maxFrameRate;
				// Frame drop rate, per second, calculated over last second.
				if (_timer.currentCount - _lastFrameDropCounter > 1000/_timer.delay) {
					_frameDropRate = (_ns.info.droppedFrames - _lastFrameDropValue)/((_timer.currentCount - _lastFrameDropCounter)*_timer.delay/1000);
					_lastFrameDropCounter = _timer.currentCount;
					_lastFrameDropValue = _ns.info.droppedFrames;
				}
				_avgDroppedFrameRateArray.unshift(_frameDropRate);
				if (_avgDroppedFrameRateArray.length > DEFAULT_AVG_FRAMERATE_SAMPLE_SIZE) {
					_avgDroppedFrameRateArray.pop();
				}
				var totalDroppedFrameRate:Number = 0;
				for (var f:uint=0;f<_avgDroppedFrameRateArray.length;f++) {
					totalDroppedFrameRate +=_avgDroppedFrameRateArray[f];
				}
				
				_avgDroppedFrameRate = _avgDroppedFrameRateArray.length < DEFAULT_AVG_FRAMERATE_SAMPLE_SIZE? 0:totalDroppedFrameRate/_avgDroppedFrameRateArray.length;
				
				}
			catch (e:Error) {
				
			}
			
		}
		
		/**
		 * @private
		 */
		private function debug(msg:String):void {
			dispatchEvent(new OvpEvent(OvpEvent.DEBUG,msg));
		}
	}
}
