package fr.batchass.event
{
	import flash.events.Event;
	
	public class UploadEvent extends Event
	{
		
		public static const UPLOAD_TOKEN_SUCCESS:String = "UploadTokenSuccess";
		public static const UPLOAD_TOKEN_ERROR:String = "UploadTokenError";
		public static const UPLOAD_SUCCESS:String = "UploadSuccess";
		public static const UPLOAD_ERROR:String = "UploadError";
		public static const UPLOAD_COMPLETE:String = "UploadComplete";
		public static const UPLOAD_PROGRESS:String = "UploadProgress";
		
		public static const PROCESSING_COUNT_CHANGE:String = "ProcessingCountChange";
		
		public static const FILESIZE_EXCEEDED:String = "FilesizeExceeded";
		
		public var data:*;
		
		public function UploadEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		
		
	}
}