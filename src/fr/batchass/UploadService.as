package fr.batchass
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.events.CollectionEvent;
	import fr.batchass.event.UploadEvent;
	
	
	[Event(name="UploadTokenSuccess",type="fr.batchass.UploadEvent")]
	
	[Event(name="UploadTokenError",type="fr.batchass.UploadEvent")]
	
	[Event(name="UploadSuccess",type="fr.batchass.UploadEvent")]
	
	[Event(name="UploadError",type="fr.batchass.UploadEvent")]
	
	[Event(name="UploadComplete",type="fr.batchass.UploadEvent")]
	
	[Event(name="UploadProgress",type="fr.batchass.UploadEvent")]
	
	[Event(name="ProcessingCountChange",type="fr.batchass.UploadEvent")]
	
	[Event(name="FilesizeExceeded",type="fr.batchass.UploadEvent")]
	
	public class UploadService extends EventDispatcher
	{
		
		public static const MAX_QUEUE_SIZE:int = 1000;
		public static const MAX_FILE_SIZE:Number = (2 * 1024 * 1024 * 1024); // 2 GB
		
		private var localSharedObjKey:String = "UploadService";
		
		//private var _uploadAction:UploadAction;
		//private var _getUploadTokenAction:GetUploadTokenAction;
		
		private var _authToken:String;
		private var _currentUserName:String;
		
		private var _clientID:String;
		private var _devKey:String;
		
		private var _uploadQueue:ArrayCollection;
		
		// this will also serve as a keep-alive
		public static var TIMER_INTERVAL:int = ( 30 * 1000 ); // thirty seconds
		
		// timer to refesh the list of user vids
		private var _refreshTimer:Timer;
		
		[Bindable]
		public var isUploading:Boolean = false;
		
		[Bindable]
		public var uploadFileIndex:int = 0;
		
		[Bindable]
		public var totalUploads:int;
		
		[Bindable]
		public var currentFileUploadProgress:Number;
		
		[Bindable]
		public var currentlyUploadingFile:UserUpload;
		
		[Bindable]
		public var processingCount:int; // the number of videos currently being processed 
		
		
		public function UploadService(target:IEventDispatcher=null)
		{
			super(target);
			uploadQueue.addEventListener(CollectionEvent.COLLECTION_CHANGE,updateBindings);
		}
		

		/**************************************************** uploadQueue
		 */
		[Bindable]
		public function set uploadQueue(value:ArrayCollection):void
		{
			_uploadQueue = value;
		}
		
		
		public function get uploadQueue():ArrayCollection
		{
			if(_uploadQueue == null)
			{
				_uploadQueue = new ArrayCollection();
			}
			return this._uploadQueue;
		}
		
		public function removeUpload(upload:UserUpload):void
		{
			if(upload.status != UserUpload.STATUS_UPLOADING)
			{
				_uploadQueue.removeItemAt(_uploadQueue.getItemIndex(upload));
			}
			else
			{
				//_uploadAction.cancelUpload();
				_uploadQueue.removeItemAt(_uploadQueue.getItemIndex(upload));
				uploadNextFile();
			}
		}
		
		///////////////////////////////////////////////////// 	completedUploadCount
		[Bindable]
		public function get completedUploadCount():int
		{
			var count:int = 0; 
			for(var n:int = 0; n < this._uploadQueue.length; n++)
			{
				if((_uploadQueue[n] as UserUpload).status == UserUpload.STATUS_COMPLETED)
				{
					count++;
				}
			}
			return count;
		}
		
		private function set completedUploadCount(value:int):void
		{
			// to support binding only
		}
		
		///////////////////////////////////////////////////// 	failedUploadCount
		[Bindable]
		public function get failedUploadCount():int
		{
			var count:int = 0; 
			for(var n:int = 0; n < this._uploadQueue.length; n++)
			{
				if((_uploadQueue[n] as UserUpload).status == UserUpload.STATUS_ERROR)
				{
					count++;
				}
			}
			return count;
		}
		
		private function set failedUploadCount(value:int):void
		{
			// to support binding only
		}
		
		///////////////////////////////////////////////////// 	pendingUploadCount
		[Bindable]
		public function get pendingUploadCount():int
		{
			var count:int = 0; 
			for(var n:int = 0; n < this._uploadQueue.length; n++)
			{
				var status:String = (_uploadQueue[n] as UserUpload).status;
				if(status == UserUpload.STATUS_QUEUED)
				{
					count++;
				}
			}
			return count;
		}
		
		private function set pendingUploadCount(value:int):void
		{
			// to support binding only
		}
		
		
		public function clearCompletedUploads():void
		{
			for(var n:int = _uploadQueue.length - 1; n >= 0; n--)
			{
				if(_uploadQueue[n].status == UserUpload.STATUS_COMPLETED)
				{
					_uploadQueue.removeItemAt(n);
				}
			}
			updateBindings();
		}
		
		public function retryFailedUploads():void
		{
			for(var n:int = 0; n < _uploadQueue.length; n++)
			{
				if(_uploadQueue[n].status == UserUpload.STATUS_ERROR)
				{
					_uploadQueue[n].status = UserUpload.STATUS_QUEUED;
				}
			}
			if(!isUploading)
			{
				isUploading = true;
				uploadNextFile();
			}
		}
		
		public function removeFailedUploads():void
		{
			for(var n:int = _uploadQueue.length - 1; n >= 0; n--)
			{
				if(_uploadQueue[n].status == UserUpload.STATUS_ERROR)
				{
					_uploadQueue.removeItemAt(n);
				}
			}
		}
		
		public function addFiles(fileList:Array):Boolean
		{
			for(var n:int = 0; n < fileList.length; n++)
			{
				if(addFile(fileList[n]))
					return true;
			}
			return false;
		}
		
		public function addFile(file:File):Boolean
		{
			return recursiveAddFile(file);
		}
		
		
		// returns true if queue is full
		private function recursiveAddFile(file:File):Boolean
		{
			if(uploadQueue.length < MAX_QUEUE_SIZE)
			{
				if(file.isHidden)
				{
					return false;
				}
				else if(file.isDirectory)
				{
					
					var dirFiles:Array = file.getDirectoryListing();
					for(var n:int = 0; n < dirFiles.length;n++)
					{
						var childFile:File = dirFiles[n] as File;
						if(recursiveAddFile(childFile))
						{
							return true;
						}
					}
				}
				else
				{
					if(file != null && file.extension != null && isSupportedType(file.extension))
					{
						if(file.size > MAX_FILE_SIZE)
						{
							var errEvt:UploadEvent = new UploadEvent(UploadEvent.FILESIZE_EXCEEDED);
							errEvt.data = file;
							dispatchEvent(errEvt);
						}
						else if(fileIsInQueue(file.url))
						{
							
						}
						else
						{
							addFileToQueue(file.url);
						}
					}
				}
				return false;
			}
			return true;	
		}
		
		public function fileIsInQueue(fileUrl:String):Boolean
		{
			for(var n:int = 0; n < _uploadQueue.length; n++)
			{
				if((_uploadQueue.getItemAt(n) as UserUpload).file.url == fileUrl)
				{
					return true;
				}
			}
			return false;
		}
		
		public function isSupportedType(ext:String):Boolean
		{
			return ( ext != null );
		}
		

		
		private function clearSession():void
		{
			currentlyUploadingFile = null;
			uploadQueue = null;
		}
		
	
		private function addFileToQueue(filePath:String):int
		{
			
			_uploadQueue.addItem(UserUpload.create(filePath));
			updateBindings();
			return _uploadQueue.length;
		}
		
		public function removeFileFromQueue(upld:UserUpload):void
		{
			var length:int = uploadQueue.length;
			for(var n:int = 0; n < length; n++)
			{
				var file:File = _uploadQueue.getItemAt(n).file as File;
				if(file != null && file == upld.file)
				{
					_uploadQueue.removeItemAt(n);
					break;
				}
			}
		}
		
		public function startUploading():void
		{
			if( uploadQueue.length > 0 )
			{
				this.isUploading = true;
				this.totalUploads = this.uploadQueue.length;
				uploadNextFile();
				
			}
		}
		
		private function uploadNextFile():void
		{
			/*if(_getUploadTokenAction == null)
			{*/
				currentlyUploadingFile = null;
				for(var n:int = 0; n < _uploadQueue.length ; n++)
				{
					var userUpload:UserUpload = _uploadQueue[n] as UserUpload;
					if(userUpload.status == UserUpload.STATUS_QUEUED)
					{
						userUpload.status = UserUpload.STATUS_PENDING;
						currentlyUploadingFile = userUpload;
						
						dispatchEvent(new Event("upload_start"));
						break;
					}
				}
				if(currentlyUploadingFile == null) // still null?
				{
					this.stopUploading();
				}
				updateBindings();
			/*}
			else
			{
				throw new Error("YouTube.GetUploadTokenAction pending");
			}
			*/
		}
		
		/*private function onGetUploadTokenError(err:Event):void
		{
			cleanup();
			currentlyUploadingFile.status = UserUpload.STATUS_ERROR;
		}*/
		
		/*private function onGetUploadTokenSuccess(evt:Event):void
		{
			var token:String = _getUploadTokenAction.token;
			var url:String = _getUploadTokenAction.uploadUrl;
			
			cleanup();
			
			_uploadAction = new UploadAction();
			_uploadAction.file = currentlyUploadingFile.file;
			_uploadAction.uploadToken = token;
			_uploadAction.url = url;
			_uploadAction.addEventListener(RestAction.REST_EVENT_ERROR,onUploadError);
			_uploadAction.addEventListener(RestAction.REST_EVENT_SUCCESS,onUploadSuccess);
			_uploadAction.addEventListener(UploadAction.REST_EVENT_PROGRESS,onUploadProgress);
			_uploadAction.execute();
			
			currentlyUploadingFile.status = UserUpload.STATUS_UPLOADING;
		}*/
		
		/*private function onUploadError(evt:Event):void
		{
			// add to failed list
			//cleanup();
			currentlyUploadingFile.status = UserUpload.STATUS_ERROR;
			dispatchEvent(new UploadEvent(UploadEvent.UPLOAD_ERROR));
			dispatchEvent(new UploadEvent(UploadEvent.UPLOAD_COMPLETE));
			updateBindings();
		}
		
		private function onUploadSuccess(evt:Event):void
		{
			//var id:String = _uploadAction.videoId;
			currentlyUploadingFile.status = UserUpload.STATUS_COMPLETED;
			
			//cleanup();
			
			dispatchEvent(new UploadEvent(UploadEvent.UPLOAD_SUCCESS));
			dispatchEvent(new UploadEvent(UploadEvent.UPLOAD_COMPLETE));
			
			if(isUploading)
			{
				uploadNextFile();
			}
			
			updateBindings();
		}*/
		
		public function stopUploading():void
		{
			this.isUploading = false;
			/*if(_uploadAction != null)
			{
				_uploadAction.cancelUpload();
				currentlyUploadingFile.status = UserUpload.STATUS_QUEUED;
			}*/
			currentlyUploadingFile.status = UserUpload.STATUS_QUEUED;
			updateBindings();
		}
		
		// Refresh Timer
		
		private function startRefreshTimer():void
		{
			if(_refreshTimer == null)
			{
				_refreshTimer = new Timer(TIMER_INTERVAL);
				_refreshTimer.addEventListener(TimerEvent.TIMER,onRefreshTimer);
			}
			_refreshTimer.start();
		}
		
		private function stopRefreshTimer():void
		{
			if(_refreshTimer != null)
			{
				_refreshTimer.stop();
			}
		}
		
		private function onRefreshTimer(evt:TimerEvent):void
		{
			//refreshUserVideos();
		}
		
		private function updateBindings(evt:CollectionEvent = null):void
		{
			// these calls simply update bindings, the real values are retieved from the getters
			completedUploadCount = -1;
			failedUploadCount = -1;
			pendingUploadCount = -1;
		}
		
		
		
	}
	
	
}