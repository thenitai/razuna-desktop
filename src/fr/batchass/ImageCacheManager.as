/*
*
* Copyright (C) 2005-2010 Razuna ltd.
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
* 
* Written by Bruce LANE http://www.batchass.fr
* June 22, 2010 version
*/
package fr.batchass
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class ImageCacheManager
	{
		private var _imageDir:File = File.documentsDirectory.resolvePath("razuna" );
		private var _localFolderId:String; 
		private static var instance:ImageCacheManager;
		private var pendingDictionaryByLoader:Dictionary = new Dictionary();
		private var pendingDictionaryByURL:Dictionary = new Dictionary();
		private static var gb:Singleton;
		
		public function ImageCacheManager()
		{
		}

		public static function getInstance():ImageCacheManager
        {
            if (instance == null)
            {
                instance = new ImageCacheManager();
            }

            return instance;
        }
		public function getAssetThumbnailByURL( thumbnailUrl:String, localFolderId:String ):String
		{
			_localFolderId = localFolderId;
			gb = Singleton.getInstance();
			var localUrl:String = _imageDir.nativePath + File.separator + gb.hostDir + File.separator + _localFolderId + File.separator + getFileName( thumbnailUrl ) ;
			var cacheFile:File = new File( localUrl );
			
			gb.log( "ImageCacheManager, getAssetThumbnailByURL localUrl: " + localUrl );
			gb.log( "ImageCacheManager, getAssetThumbnailByURL _localFolderId: " + _localFolderId );
			if( cacheFile.exists )
			{
				gb.log( "ImageCacheManager, getAssetThumbnailByURL cacheFile exists: " + cacheFile.url );
				return cacheFile.url;
			} 
			else 
			{
				gb.log( "ImageCacheManager, getAssetThumbnailByURL cacheFile does not exist: " + thumbnailUrl );
				addImageToCache( thumbnailUrl );
				return thumbnailUrl;
			}

		}
		public function getAssetByURL( assetUrl:String, localFolderId:String ):String
		{
			_localFolderId = localFolderId;
			gb = Singleton.getInstance();
			//var cacheFile:File = new File( _imageDir.nativePath + folder + File.separator + cleanURLString( url ) );
			var localUrl:String = _imageDir.nativePath + File.separator + gb.hostDir + File.separator + _localFolderId + File.separator + getFileName( assetUrl ) ;
			var cacheFile:File = new File( localUrl );
			
			gb.log( "ImageCacheManager, getAssetByURL localUrl: " + localUrl );
			gb.log( "ImageCacheManager, getAssetByURL _localFolderId: " + _localFolderId );
			//			gb.log( "ImageCacheManager, getAssetByURL gb.folderDictionary[_localFolderId]: " + gb.folderDictionary[_localFolderId] );
			if( cacheFile.exists )
			{
				gb.log( "ImageCacheManager, getAssetByURL cacheFile exists: " + cacheFile.url );
				if ( _localFolderId != "global" ) cacheFile.openWithDefaultApplication();
				return cacheFile.url;
			} 
			else 
			{
				gb.log( "ImageCacheManager, getAssetByURL cacheFile does not exist: " + assetUrl );
				addAssetToCache( assetUrl );
				return assetUrl;
			}
		}
		// download image for gallery
		public function getGalleryImageByURL( url:String, width:int, height:int ):String
		{
			gb = Singleton.getInstance();
			var fileName:String = width.toString() + 'x' + height.toString() + '_' + getFileName( url );
			var localUrl:String = 'razuna' + File.separator + 'gallery' + File.separator + 'images' + File.separator +  fileName;
			var cacheFile:File = File.documentsDirectory.resolvePath( localUrl );
			
			gb.log( "ImageCacheManager, getGalleryImageByURL localUrl: " + localUrl );
			if( cacheFile.exists )
			{
				gb.log( "ImageCacheManager, getGalleryImageByURL cacheFile exists: " + cacheFile.url );
			} 
			else 
			{
				gb.log( "ImageCacheManager, getGalleryImageByURL cacheFile does not exist: " + url );
				addGalleryImageToCache( url, width, height );
			}
			return fileName;

		}
		// download files for gallery
		public function getGalleryFilesByURL( url:String ):String
		{
			gb = Singleton.getInstance();
			var fileName:String = getCleanPathAndFileName( url );
			var localUrl:String = 'razuna' + File.separator + 'gallery' + File.separator + fileName;
			var cacheFile:File = File.documentsDirectory.resolvePath( localUrl );
			
			gb.log( "ImageCacheManager, getGalleryFilesByURL localUrl: " + localUrl );
			if( cacheFile.exists )
			{
				gb.log( "ImageCacheManager, getGalleryFilesByURL cacheFile exists: " + cacheFile.url );
			} 
			else 
			{
				gb.log( "ImageCacheManager, getGalleryFilesByURL cacheFile does not exist: " + url );
				addGalleryFileToCache( url );
			}
			return fileName;

		}

		private function addImageToCache( url:String ):void
		{
			if(!pendingDictionaryByURL[url]){
				var req:URLRequest = new URLRequest(url);
				var loader:URLLoader = new URLLoader();
				loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
				loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
				loader.addEventListener( Event.COMPLETE, imageLoadComplete );
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.load(req);
				pendingDictionaryByLoader[loader] = url;
				pendingDictionaryByURL[url] = true;
			} 
		}
		private  function addAssetToCache( url:String ):void
		{
			if(!pendingDictionaryByURL[url]){
				var req:URLRequest = new URLRequest(url);
				var loader:URLLoader = new URLLoader();
				loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
				loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
				loader.addEventListener( Event.COMPLETE, assetLoadComplete );
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.load(req);
				pendingDictionaryByLoader[loader] = url;
				pendingDictionaryByURL[url] = true;
			} 
		}
		private function addGalleryImageToCache( url:String, width:Number, height:int ):void
		{
			var localUrlPath:String = width.toString() + 'x' + height.toString() + '_' + url;
			if(!pendingDictionaryByURL[localUrlPath])
			{
				var req:URLRequest = new URLRequest(url);
				var loader:Loader = new Loader();
				
				loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, galleryImageLoadComplete ) ;
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 

				loader.load(req);
				pendingDictionaryByLoader[loader.contentLoaderInfo] = localUrlPath;
				pendingDictionaryByURL[localUrlPath] = true;
			} 
		}
		private function addGalleryFileToCache( url:String ):void
		{
			if(!pendingDictionaryByURL[url])
			{
				var fileName:String = getCleanPathAndFileName( url );
				var prefix:String = getPrefix( url );
				
				var req:URLRequest = new URLRequest( prefix + fileName );
				var loader:URLLoader = new URLLoader();
				loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
				loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
				loader.addEventListener( Event.COMPLETE, galleryFileLoadComplete );
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.load( req );
				pendingDictionaryByLoader[loader] = url;
				pendingDictionaryByURL[url] = true;
			} 
		}
		private function imageLoadComplete( event:Event ):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var url:String = pendingDictionaryByLoader[loader];
				
			gb = Singleton.getInstance();
			var cacheFile:File = new File( _imageDir.nativePath + File.separator + gb.hostDir + File.separator + _localFolderId + File.separator + getFileName( url ) );
			var stream:FileStream = new FileStream();
			cacheFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.open(cacheFile,FileMode.WRITE);
			stream.writeBytes(loader.data);
			stream.close();

			delete pendingDictionaryByLoader[loader]
			delete pendingDictionaryByURL[url];
		}
		private function assetLoadComplete( event:Event ):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var url:String = pendingDictionaryByLoader[loader];
			
			gb = Singleton.getInstance(); //useless?
			var cacheFile:File = new File( _imageDir.nativePath + File.separator + gb.hostDir + File.separator + _localFolderId + File.separator + getFileName( url ) );
			var stream:FileStream = new FileStream();
			cacheFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.open(cacheFile,FileMode.WRITE);
			stream.writeBytes(loader.data);
			stream.close();
			if ( _localFolderId != "global" ) cacheFile.openWithDefaultApplication();

			delete pendingDictionaryByLoader[loader]
			delete pendingDictionaryByURL[url];
		}
		//generate resized images
		private function galleryImageLoadComplete( event:Event ):void
		{
			var loader:LoaderInfo = event.target as LoaderInfo;
			var passedUrl:String = pendingDictionaryByLoader[loader];
			var indexOfX:int = passedUrl.indexOf( 'x');
			var indexOfUD:int = passedUrl.indexOf( '_');
			var url:String = passedUrl.substr( indexOfUD + 1 );
			var w:String = passedUrl.substr( 0, indexOfX );
			var h:String = passedUrl.substr( indexOfX + 1, indexOfUD - indexOfX - 1 );
			var fileName:String = w + 'x' + h + '_' + getFileName( url );
			
			var localUrl:String = 'razuna' + File.separator + 'gallery' + File.separator + 'images' + File.separator + fileName;
			var cacheFile:File = File.documentsDirectory.resolvePath( localUrl );

			//var cacheFile:File = new File( _imageDir.nativePath + File.separator + gb.hostDir + File.separator + _localFolderId + File.separator + fileName );
			var stream:FileStream = new FileStream();

			
			var originalImage:Bitmap = Bitmap(loader.content);
			
			var scale:Number = int(w) / originalImage.width;
			if ( scale > 1 ) scale = 1;
			var newWidth:int = originalImage.width * scale;
			var newHeight:int = originalImage.height * scale;
			var pixelsResized:BitmapData = new BitmapData( newWidth, newHeight, true);
			//var pixelsResized:BitmapData = new BitmapData( int(w), Math.min( int(h), newHeight ), true);
			pixelsResized.draw(originalImage.bitmapData, new Matrix(scale, 0, 0, scale));
			
			cacheFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.open( cacheFile, FileMode.WRITE );
			stream.writeBytes( encodeJPG( pixelsResized ) );
			stream.close();
			
			delete pendingDictionaryByLoader[loader]
			delete pendingDictionaryByURL[url];
		}
		private function galleryFileLoadComplete( event:Event ):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var url:String = pendingDictionaryByLoader[loader];
			
			var localUrl:String = 'razuna' + File.separator + 'gallery' + File.separator + getCleanPathAndFileName( url );
			var cacheFile:File = File.documentsDirectory.resolvePath( localUrl );
			var stream:FileStream = new FileStream();
						
			cacheFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.open( cacheFile, FileMode.WRITE );
			stream.writeBytes( loader.data );
			stream.close();
			
			delete pendingDictionaryByLoader[loader]
			delete pendingDictionaryByURL[url];
		}

		//jpg encoding
		private function encodeJPG( bd:BitmapData ):ByteArray
		{
			var jpgEncoder:JPGEncoder = new JPGEncoder();
			var bytes:ByteArray = jpgEncoder.encode(bd);
			return bytes;
		} 
		
		public function getPrefix( url:String ):String
		{
			var lastSign:uint = url.lastIndexOf( '§' );
			var fileName:String = "";
			if ( lastSign > -1 )
			{
				fileName = url.substr( 0, lastSign );
			}
			return fileName;
		}
		
		public function getCleanPathAndFileName( url:String ):String
		{
			var lastSign:uint = url.lastIndexOf( '§' );
			var fileName:String = "";
			if ( lastSign > -1 )
			{
				fileName = url.substr( lastSign + 1 );
			}
			return fileName;
		}

		public function getFileName( url:String ):String
		{
			var lastSlash:uint = url.lastIndexOf( '/' );
			var fileName:String = "assets/closeBtn.png";
			if ( lastSlash > -1 )
			{
				fileName = url.substr( lastSlash + 1 );
			}
			return fileName;
		}
		private function ioErrorHandler( event:IOErrorEvent ):void
		{
			gb.log( 'ImageCacheManager, An IO Error has occured: ' + event.text );
			//TODO: this.parentApplication.statusText.text = "An IO error has occured";
		}    
		// only called if a security error detected by flash player such as a sandbox violation
		private function securityErrorHandler( event:SecurityErrorEvent ):void
		{
			gb.log( "ImageCacheManager, securityErrorHandler: " + event.text );
			//TODO: this.parentApplication.statusText.text = "A security error has occured";
		}		
		//  after a file upload is complete or attemted the server will return an http status code, code 200 means all is good anything else is bad.
		private function httpStatusHandler( event:HTTPStatusEvent ):void 
		{  
			gb.log( "ImageCacheManager, httpStatusHandler, status(200 is ok): " + event.status );
		}
	}
}