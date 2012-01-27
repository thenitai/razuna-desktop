package components
{
	public class FileBuffer
	{
		import flash.events.Event;
		import flash.filesystem.File;
		import flash.filesystem.FileStream;
		import flash.filesystem.FileMode;
		import flash.net.URLLoader;
		
		private var file:File;
		
		public function FileBuffer(file:File)
		{
			this.file = file;
		}
		
		public function write(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			
			var fileStream:FileStream = new FileStream();
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(loader.data);
			fileStream.close();
		}
		
	}
}