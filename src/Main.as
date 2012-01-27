/*
*
* Copyright (C) 2005-2011 Razuna ltd.
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
* July 25th, 2011 version
*/

import air.update.events.UpdateEvent;
import air.update.ApplicationUpdaterUI;

import components.infoButton;

import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.desktop.ClipboardTransferMode;
import flash.desktop.DockIcon;
import flash.display.Loader;
import flash.display.NativeWindow;
import flash.display.NativeWindowDisplayState;
import flash.display.Stage;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.filesystem.File;
import flash.net.URLRequest;

import fr.batchass.ImageCacheManager;

import mx.controls.Alert;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.managers.DragManager;

private var filesDataProvider:XML;
[Bindable]
private var xList:XMLList;

private var fileRef:File;

//private var translationXML:XML;
//private var translation:Translations ;

//File Reference Vars
private var uploadURL:URLRequest;
private var totalbytes:Number;
private var loader:Loader;

//File Filter vars
private var filefilter:Array;

private static var _imageCache:ImageCacheManager = ImageCacheManager.getInstance();

[Bindable]
public var installedVersion: String = '';

private var gb:Singleton = Singleton.getInstance();

public var galleryPath:String = "http://www.batchass.fr/razuna/gallery/";
// Used for auto-update
protected var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI(); 


private function init():void
{
	gb.RDapp = this;
	statusText.text = "Developed by Bruce Lane (http://bruce.lane.free.fr)";
	gb.uploadList = uploadList;

	gb.log("Init");
    /* filesDataProvider = 
    	<files>
    	</files>; */
    //selectLanguage();
	
    // Set Up Total Bytes Var
    totalbytes = 0;
 	this.addEventListener( DragEvent.DRAG_ENTER, onDragEnter );
	this.addEventListener( DragEvent.DRAG_DROP, onDragDrop );
	this.addEventListener( MouseEvent.MOUSE_DOWN, moveWindow );
	this.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowMaximize);
	
	// Check for update
	this.checkUpdate();
	
	gb.log( "Check for new version, current: " + appUpdater.currentVersion );
	installedVersion = appUpdater.currentVersion;

	versionLabel.text = "Razuna Desktop v" + installedVersion;
	setUserAgent();
	
	// download gallery files
	var filesArray:Array = ["§CarouselGallery.html", 
							"§CarouselGallery.swf", 
							"§playerProductInstall.swf",
							"§swfobject.js",
							"§history/history.css",
							"§history/history.js",
							"§history/historyFrame.html",
							"§images/dummy.txt"
							];
	
	filesArray.forEach(dlGallery);

	NativeApplication.nativeApplication.addEventListener( Event.EXITING, cleanUp );  
}
// This function is triggered when the application finished loading.
// Initialize appUpdater and set some properties
protected function checkUpdate():void
{
	// set the URL for the update.xml file
	appUpdater.updateURL = "http://s.razuna.com.s3.amazonaws.com/installers/rd/update.xml";
	appUpdater.addEventListener(UpdateEvent.INITIALIZED, onUpdate);
	appUpdater.addEventListener(ErrorEvent.ERROR, onUpdaterError);
	// Hide the dialog asking for permission for checking for a new update.
	// If you want to see it just leave the default value (or set true).
	appUpdater.isCheckForUpdateVisible = false;
	appUpdater.initialize();
}

// Handler function triggered by the ApplicationUpdater.initialize.
// The updater was initialized and it is ready to take commands.
protected function onUpdate(event:UpdateEvent):void 
{
	// start the process of checking for a new update and to install
	appUpdater.checkNow();
}

// Handler function for error events triggered by the ApplicationUpdater.initialize
protected function onUpdaterError(event:ErrorEvent):void
{
	Alert.show(event.toString());
}
private function dlGallery( url:String, index:int, arr:Array ):void
{
	var galleryFile:File = File.documentsDirectory.resolvePath( 'razuna' + File.separator + 'gallery' + File.separator + url );
	
	if( !galleryFile.exists )
	{
		_imageCache.getGalleryFilesByURL( galleryPath + url );
	}
}


private function getApplicationVersion():String
{
	var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
	var ns:Namespace = appXML.namespace();
	return appXML.ns::version; 
}
private function setUserAgent():void
{
	URLRequestDefaults.userAgent += " " + NativeApplication.nativeApplication.applicationID + "/" +	installedVersion;
	gb.log( "UserAgent: " + URLRequestDefaults.userAgent );
}
private function getApplicationName():String
{
	var applicationName: String;
	var xmlNS:Namespace = new Namespace("http://www.w3.org/XML/1998/namespace");
	var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
	var ns:Namespace = appXML.namespace();
	// filename is mandatory
	var elem:XMLList = appXML.ns::filename;
	// use name is if it exists in the application descriptor
	if ((appXML.ns::name).length() != 0)
	{
		elem = appXML.ns::name;
	}
	// See if element contains simple content
	if (elem.hasSimpleContent())
	{
		applicationName = elem.toString();
	}

	return applicationName;
}

private function cleanUp( e:Event ):void 
{  
	
}

// Find the current version for our Label below  
private function setApplicationVersion():void 
{  
	var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;  
	var ns:Namespace = appXML.namespace();  
	//statusText.text = "Razuna Desktop version " + appXML.ns::version;  
	gb.log(appXML.ns::version); 
} 

/*   private function selectLanguage():void
{
	var urlXML:URLLoader = new URLLoader( new URLRequest( "translations/french.xml?t=" + new Date().getMilliseconds() ) );
	urlXML.addEventListener( Event.COMPLETE, trXML );
	urlXML.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ); 
	
}
private function trXML(e:Event):void
{
 	translationXML = new XML( e.target.data );
 	translation = new Translations( translationXML );
 	trace( translation.Utilisateur );
 	var userName:String = translationXML.transid.(@name == "username").transtext;
	trace( userName);
}
*/
public function onDragStart(evt:DragEvent):void
{
	// nothing
	trace("onDragStart" );
}
public function onDragEnter(evt:DragEvent):void
{
	trace("evt.dragSource.formats = " + evt.dragSource.formats);
	if(evt.dragSource.hasFormat("air:file list"))
	{
		DragManager.acceptDragDrop(this);
	}
	else
	{
		statusText.text = 'Format not supported, please drop file(s).';
	}
}
public function onDragDrop(evt:DragEvent):void
{
	trace("onDragDrop" );
	var fileToUpload:File;
	if ( currentState != 'Upload' ) currentState = 'Upload' ;
	var itemsArray:Array = evt.dragSource.dataForFormat("air:file list") as Array;
	if(itemsArray != null)
	{
		gb.uploadList.addFiles(itemsArray);
	}
	statusText.text = "Dropped file(s) added, please click the Upload button."
}
/*protected function isNewerFunction(currentVersion:String, updateVersion:String):Boolean
{
	// Example of custom isNewerFunction function, it can be omitted if one doesn't want
	// to implement it's own version comparison logic. Be default it does simple string
	// comparison.
	return ( currentVersion != updateVersion );
}*/

/*protected function updater_errorHandler(event:ErrorEvent):void
{
	Alert.show(event.text);
}

protected function updater_initializedHandler(event:UpdateEvent):void
{
	//check for update
	gb.log( "Check now, current: " + updater.currentVersion );
	updater.checkNow();//TODO check if connected but later
}*/
/*protected function update():void
{
	// In case user wants to download and install update display download progress bar
	// and invoke downloadUpdate() function.
	showUpdateBtn( false );
	updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, updater_downloadErrorHandler);
	updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, updater_downloadCompleteHandler);
	updater.downloadUpdate();
}
private function updater_downloadCompleteHandler(event:UpdateEvent):void
{
	// When update is downloaded install it.
	updater.installUpdate();
}
*/
/*private function updater_downloadErrorHandler(event:DownloadErrorEvent):void
{
	Alert.show("Error downloading update file, try again later.");
}
protected function updater_updateStatusHandler(event:StatusUpdateEvent):void
{
	if (event.available)
	{
		// In case update is available prevent default behavior of checkNow() function 
		// and switch to the view that gives the user ability to decide if he wants to
		// install new version of the application.
		event.preventDefault();
		showUpdateBtn( true );
	}
}*/
/*private function showUpdateBtn( show:Boolean )
{
	leftRule.visible = show;
	updateBtn.visible = show;
	rightRule.visible = show;
}*/
private function moveWindow( evt:MouseEvent ):void
{
	var clickedElement:String = evt.target.name;
	if ( clickedElement.substring( 0, 5 ) == "Group" ) nativeWindow.startMove();
}
private function resizeWindow( evt:MouseEvent ):void
{
	var clickedElement:String = evt.target.name;
	nativeWindow.startResize();
}
//prevent from maximizing
protected function onWindowMaximize(event:NativeWindowDisplayStateEvent):void
{
	if (event.afterDisplayState == NativeWindowDisplayState.MAXIMIZED) this.nativeWindow.restore();
	
}
public function errorEventErrorHandler(event:ErrorEvent):void
{
	gb.log( 'An ErrorEvent has occured: ' + event.text );
}    
public function ioErrorHandler( event:IOErrorEvent ):void
{
	gb.log( 'An IO Error has occured: ' + event.text );
}    
// only called if a security error detected by flash player such as a sandbox violation
public function securityErrorHandler( event:SecurityErrorEvent ):void
{
	gb.log( "securityErrorHandler: " + event.text );
}		
//  after a file upload is complete or attemted the server will return an http status code, code 200 means all is good anything else is bad.
public function httpStatusHandler( event:HTTPStatusEvent ):void 
{  
	gb.log( "httpStatusHandler, status(200 is ok): " + event.status );
}
