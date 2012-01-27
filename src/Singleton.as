/*
*
* Copyright (C) 2005-2009 SixSigns Inc.
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
* Singleton class
* Written by Bruce LANE http://www.batchass.fr
* June 17, 2010 version
*/
package
{	
	import components.*;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;
	
	import fr.batchass.ImageCacheManager;
	
	import mx.events.StateChangeEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.CursorManager;
	import mx.rpc.events.ResultEvent;
	
	import services.collection.Collection;
	import services.folder.Folder;
	
	import spark.components.Application;
	import spark.components.RichText;
	import spark.components.TextInput;
	import spark.components.supportClasses.TextBase;
	
	public class Singleton 
	{
		private static var instance:Singleton = new Singleton();
		private static var _sessiontoken:String = "Not Connected.";
		private static var _hostname:String = "razuna.com";
		private static var _hosted:Boolean = true;
		private static var _hostId:Number = 1;
		private static var _autoLogin:Boolean = false;
		private static var _uploadList:components.rdUploadPanel ;
		private static var _imageCache:ImageCacheManager = ImageCacheManager.getInstance();
		private static var _folderId:String="1";
		private static var _destFolderId:String="1";//to store for upload <> explore
		private static var _collectionId:String="1";
		private static var _zip_extract:uint=1;
		private static var _retry:Number;
		private static var _thumbWidth:Number;
		private static var _thumbHeight:Number;
		private static var _imageWidth:Number;
		private static var _imageHeight:Number;
		//private static var _port:String;
		private static var _pathHosted:String="";		
		private static var _debug:Boolean = false;
		private static var dateFormatter:DateFormatter;
		private static var _nowDate:String;
		//private static var _versionLabel:RichText;
		//private static var _statusText:TextBase;
		private static var _localRootPath:String;
		private static var _hostDir:String = "/razuna.com";
		private static var _state:String;
		private static var _previousState:String;
		private static var _RazunaDesktop:Object;
		//private static var _host:String;
		private static var _hUserName:String;
		private static var _lUserName:String;
		private static var _hPassword:String;
		private static var _lPassword:String;
		private static var _hHostName:String;
		private static var _lHostName:String;
		private static var _collectionService:Collection;
		private static var _folderService:Folder;
		
		public function Singleton()
		{
			
			
			if ( instance == null ) 
			{
				dateFormatter = new DateFormatter();
				dateFormatter.formatString = "YYYYMMDD-HHhNN";
				_nowDate = dateFormatter.format(new Date());
			}
			else trace( "Singleton already instanciated." );
		}
		
		/*public function get port():String
		{
		return _port;
		}
		
		public function set port(value:String):void
		{
		_port = value;
		}*/
		
		public function get thumbWidth():Number
		{
			return _thumbWidth;
		}
		
		public function set thumbWidth(value:Number):void
		{
			_thumbWidth = value;
		}
		
		public function get thumbHeight():Number
		{
			return _thumbHeight;
		}
		
		public function set thumbHeight(value:Number):void
		{
			_thumbHeight = value;
		}
		
		public function get imageWidth():Number
		{
			return _imageWidth;
		}
		
		public function set imageWidth(value:Number):void
		{
			_imageWidth = value;
		}
		
		public function get imageHeight():Number
		{
			return _imageHeight;
		}
		
		public function set imageHeight(value:Number):void
		{
			_imageHeight = value;
		}
		
		public function get folderService():Folder
		{
			return _folderService;
		}
		
		public function set folderService(value:Folder):void
		{
			_folderService = value;
		}
		
		public function get collectionService():Collection
		{
			return _collectionService;
		}
		
		public function set collectionService(value:Collection):void
		{
			_collectionService = value;
		}
		
		public function get hostId():Number
		{
			return _hostId;
		}
		
		public function set hostId(value:Number):void
		{
			_hostId = value;
		}
		
		public function get autoLogin():Boolean
		{
			return _autoLogin;
		}
		
		public function set autoLogin(value:Boolean):void
		{
			_autoLogin = value;
		}
		
		public function get collectionId():String
		{
			return _collectionId;
		}
		
		public function set collectionId(value:String):void
		{
			_collectionId = value;
		}
		
		public function get lHostName():String
		{
			return _lHostName;
		}
		
		public function set lHostName(value:String):void
		{
			_lHostName = value;
		}
		
		public function get hHostName():String
		{
			return _hHostName;
		}
		
		public function set hHostName(value:String):void
		{
			_hHostName = value;
		}
		
		public function get lPassword():String
		{
			return _lPassword;
		}
		
		public function set lPassword(value:String):void
		{
			_lPassword = value;
		}
		
		public function get hPassword():String
		{
			return _hPassword;
		}
		
		public function set hPassword(value:String):void
		{
			_hPassword = value;
		}
		
		public function get lUserName():String
		{
			return _lUserName;
		}
		
		public function set lUserName(value:String):void
		{
			_lUserName = value;
		}
		
		public function get hUserName():String
		{
			return _hUserName;
		}
		
		public function set hUserName(value:String):void
		{
			_hUserName = value;
		}
		
		/*public function get host():String
		{
		return _host;
		}
		
		public function set host(value:String):void
		{
		_host = value;
		}*/
		
		public function get RDapp():Object
		{
			return _RazunaDesktop;
		}
		
		public function set RDapp(value:Object):void
		{
			_RazunaDesktop = value;
		}
		
		public function get retry():Number
		{
			return _retry;
		}
		
		public function set retry(value:Number):void
		{
			_retry = value;
		}
		
		public function get hostDir():String
		{
			return _hostDir;
		}
		
		public function set hostDir(value:String):void
		{
			var lastSlash:uint = value.lastIndexOf( ':' );
			var cleanUrl:String;
			
			if ( lastSlash > -1 ) cleanUrl = value.substr( 0, lastSlash ) else cleanUrl = value;
			_localRootPath = "razuna" + File.separator + cleanUrl + File.separator;			
			_hostDir = cleanUrl;
		}
		
		public function get localRootPath():String
		{
			return _localRootPath;
		}
		
		public function get hosted():Boolean
		{
			return _hosted;
		}
		
		public function set hosted(value:Boolean):void
		{
			_hosted = value;
		}
		
		public function get debug():Boolean
		{
			return _debug;
		}
		
		public function set debug(value:Boolean):void
		{
			_debug = value;
		}
		
		public function get destFolderId():String
		{
			return _destFolderId;
		}
		
		public function set destFolderId(value:String):void
		{
			_destFolderId = value;
		}
		
		public function get pathHosted():String
		{
			return _pathHosted;
		}
		
		public function set pathHosted(value:String):void
		{
			_pathHosted = value;
		}
		
		public function get zip_extract():uint
		{
			return _zip_extract;
		}
		
		public function set zip_extract(value:uint):void
		{
			_zip_extract = value;
		}
		
		public function get folderId():String
		{
			return _folderId;
		}
		
		public function set folderId(value:String):void
		{
			_folderId = value;
		}
		
		public function get imageCache():ImageCacheManager
		{
			return _imageCache;
		}
		
		public function get uploadList():components.rdUploadPanel
		{
			return _uploadList;
		}
		
		public function set uploadList(value:rdUploadPanel):void
		{
			_uploadList = value;
		}
		
		public function get hostname():String
		{
			return _hostname;
		}
		
		public function set hostname(value:String):void
		{
			_hostname = value;
			populatePanels();
		}
		// loads control's content, called on login, offline mode, and when hostname is set
		public function populatePanels():void
		{
			if ( isConnected() )
			{
				if ( collectionService )
				{
					collectionService.removeEventListener( ResultEvent.RESULT, serviceListener );       
					collectionService = null;
				}
				collectionService = new Collection( hostname );
				collectionService.addEventListener( ResultEvent.RESULT, serviceListener );
				collectionService.getcollectionstree( sessiontoken, 1 );
				if ( _folderService )
				{
					_folderService.removeEventListener( ResultEvent.RESULT, serviceListener ) ;        
					_folderService = null;		
				}
				_folderService = new Folder( hostname );
				_folderService.addEventListener( ResultEvent.RESULT, serviceListener );
				_folderService.getfolders( _sessiontoken, "0", 1 ); 			
			} 
			if ( RDapp )
			{
				RDapp.foldersComponent.foldersPanel_populate();
				RDapp.collectionsPanel.collectionsPanel_populate();
				RDapp.assetsComponent.clearAssetList();
			}
		}
		
		
		private function serviceListener( event:ResultEvent ):void
		{
			var result:String =	event.result.toString();
			var RESPONSE_XML:XML = XML(result);
			var response:uint = RESPONSE_XML..responsecode;//0 if ok
			var isGetAssetResponse:String = RESPONSE_XML..listassets;
			var isGetCollsTreeResponse:String = RESPONSE_XML..@parentid; 
			var isGetCollsResponse:String = RESPONSE_XML..@totalassets;
			
			if ( response == 0 )
			{
				if ( isGetAssetResponse.length > 0 )
				{
					this.RDapp.assetsComponent.AssetsPopulate( event ); 	
				}
				else
				{
					this.RDapp.assetsComponent.clearAssetList();
					if ( event.currentTarget is Folder )
					{
						//Folder service response
						this.RDapp.foldersComponent.folderListener( event );
					}
					else
					{
						if ( event.currentTarget is Collection )
						{
							if ( isGetCollsTreeResponse.length > 0 )
							{
								//CollectionsTree response
								this.RDapp.collectionsPanel.collectionsTreeListener( event );	
							}
							else
							{
								if ( isGetCollsResponse.length > 0 )
								{
									//Collection response
									this.RDapp.collectionPanel.collectionListener( event );
								}
								else
								{
									log( "serviceListener, collection webservice error: could not find type of result" );
								}
							}
							
							
						}
					}			
				}
			}
		}
		public function get sessiontoken():String
		{
			return _sessiontoken;
		}
		
		public function set sessiontoken(value:String):void
		{
			_sessiontoken = value;
		}
		
		public static function getInstance():Singleton 
		{
			return instance;
		}
		public function log( text:String, clear:Boolean=false ):void
		{
			if ( _debug )
			{
				var file:File = File.applicationStorageDirectory.resolvePath( _nowDate + ".log" );
				var fileMode:String = ( clear ? FileMode.WRITE : FileMode.APPEND );
				
				var fileStream:FileStream = new FileStream();
				fileStream.open( file, fileMode );
				
				fileStream.writeMultiByte( text + "\n", File.systemCharset );
				fileStream.close();
				trace( text );
			}
		} 
		public function currentStateChangingHandler(event:StateChangeEvent):void
		{
			trace(event);
		}
		public function enlarge():void
		{
			if ( this.RDapp )
			{
				this.RDapp.width = 900;
				this.RDapp.minimizeButton.x = 860;
				this.RDapp.closeButton.x = 880;
			}
			
		}
		public function gotoPreviousState():void
		{
			this.RDapp.currentState = previousState;
		}
		public function currentStateChangeHandler(event:StateChangeEvent):void
		{
			log( "currentStateChangeHandler, newState: " + event.newState );
			previousState = event.oldState;
			state = event.newState;
			switch ( event.newState )
			{
				case 'LoggedIn':
					this.RDapp.foldersComponent.foldersPanel_populate();
					this.RDapp.foldersComponent.treeMainPanel.title = "Razuna folders:";
					if ( folderService )
					{
						folderService.getassets( sessiontoken, folderId, 0, 0, 0, 'all' );
					}
					else
					{
						this.RDapp.assetsComponent.clearAssetList();
					}
					enlarge();
					break;
				
				case 'Collections':
					if ( collectionService ) 
					{
						collectionService.getassets( sessiontoken, collectionId);
					}
					else
					{
						this.RDapp.assetsComponent.clearAssetList();
					}	
					enlarge();
					break;
				
				case 'Upload':
					this.RDapp.foldersComponent.foldersPanel_populate();
					this.RDapp.foldersComponent.treeMainPanel.title = "Select a destination folder:";
					enlarge();
					break;
				
				default:
					if ( this.RDapp )
					{
						this.RDapp.width = 470;
						this.RDapp.minimizeButton.x = 430;
						this.RDapp.closeButton.x = 450;
					}
					break;
			}	
			trace(event);
		}
		public function get state():String
		{
			return _state;
		}
		
		public function set state( value:String ):void
		{
			_state = value;
		}
		public function get previousState():String
		{
			return _previousState;
		}
		
		public function set previousState( value:String ):void
		{
			_previousState = value;
		}
		public function isConnected():Boolean
		{
			return ( sessiontoken.length > 30 );
		}
	}
}