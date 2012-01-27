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
* December 11, 2009 version
*/
import flash.events.*;
import flash.net.FileReference;
import flash.net.FileReferenceList;
import flash.net.URLRequest;
import flash.net.URLVariables;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.Image;
import mx.controls.ProgressBar;
import mx.controls.dataGridClasses.*;
import mx.events.CollectionEvent;
import mx.events.DragEvent;

import spark.components.Button;
import spark.components.RichText;
import spark.events.IndexChangeEvent;

[Bindable]
private var acImageList:ArrayCollection;
//private var _uploadQueue:ArrayCollection;


private var _testButton:Button;
private var _infoLbl:RichText;

private var _fileref:FileReferenceList;
//[Bindable]
private var _file:FileReference; //Bindable?
private var _uploadURL:URLRequest;
private var _totalbytes:Number;

//File Filter vars
private var _filefilter:Array;

//config vars
private var _url:String; // location of the file upload handler can be a relative path or FQDM
private var _maxFileSize:Number = 2200000000; //bytes
private var _variables:URLVariables; //variables to passed along to the file upload handler on the server.
private var retryTimer:Timer;
internal var gb:Singleton = Singleton.getInstance();

private function init():void
{
	// Set Up Progress Bar UI
	progressBar.mode = "manual";
	progressBar.label = "Drop files or use Browse button.";
	// Set Up UI Buttons;
	uploadButton.enabled = false;
	remselButton.enabled = false;
	remallButton.enabled = false;
	// Setup File Array Collection and FileReference
	_fileref = new FileReferenceList;
	_file = new FileReference;
	
	// Set Up Total Byes Var
	_totalbytes = 0;
	
	// Add Event Listeners to UI 
	browseButton.addEventListener( MouseEvent.CLICK, browseFiles );
	uploadButton.addEventListener( MouseEvent.CLICK, uploadFiles );
	remallButton.addEventListener( MouseEvent.CLICK, clearFileQueue);
	remselButton.addEventListener( MouseEvent.CLICK, removeSelectedFileFromQueue );
	_fileref.addEventListener( Event.SELECT, selectHandler );
	acImageList = new ArrayCollection();
	acImageList.addEventListener( CollectionEvent.COLLECTION_CHANGE, popDataGrid );
}

public function get selectedIndex():int
{
	return imagesList.selectedIndex;
}
public function get length():int
{
	return acImageList.length;
}

protected function itemIndexChangedHandler(event:IndexChangeEvent):void
{
	trace("ImageList, itemIndexChangedHandler, event.newIndex" + event.newIndex);
	trace("ImageList, itemIndexChangedHandler, acImageList.length" + acImageList.length);
	if ( event.newIndex != -1 )
	{
		if ( acImageList.length > 0 )
		{
			trace(imagesList.selectedItem.name );
		}
	}
}
//START
public function addFiles(fileList:Array):Boolean
{
	for(var n:int = 0; n < fileList.length; n++)
	{
		if(addFile(fileList[n]))
			return true;
	}
	return false;
}

public function addFile(file:File):void
{
	return recursiveAddFile(file);
}
private function recursiveAddFile(file:File):void
{
	if(!file.isHidden)
	{
		if(file.isDirectory)
		{
			
			var dirFiles:Array = file.getDirectoryListing();
			for(var n:int = 0; n < dirFiles.length;n++)
			{
				var childFile:File = dirFiles[n] as File;
				recursiveAddFile(childFile)
			}
		}
		else
		{
			if(file != null )
			{
				if(file.size < _maxFileSize)
				{
					addFileToQueue(file.url);
				}
			}
		}
	}
}
private function addFileToQueue(filePath:String):void
{
	
	//_uploadQueue.addItem(filePath);
	
	var file:File = new File(filePath);
	gb.log( "uploadPanel, filePath: " + filePath );
	gb.log( "uploadPanel, file.name: " + file.name );
	gb.log( "uploadPanel, file.url: " + file.url );
	acImageList.addItem(file);
	this.parentApplication.statusText.text = file.name + " added";
}

//END
/*public function addItem( fileItem:FileReference ):void
{
	acImageList.addItem( fileItem );
	trace("ImageList, addItem, fileItem: " + fileItem.name);
	gb.infoLabel.text = fileItem.name + " added";
}*/
public function getItemAt( index:int ):Object
{
	trace("ImageList, getItemAt, index: " + index);
	return acImageList.getItemAt( index );
}
public function removeItem( index:int ):void
{
	trace("ImageList, removeItem, index: " + index);
	trace("ImageList, removeItem, acImageList.length" + acImageList.length);
	if ( index > -1 )
	{
		if ( acImageList.length > 0 )
		{
			acImageList.removeItemAt( index );
			//trace(imagesList.selectedItem.name );
		}
	}
}
public function removeAll():void
{
	acImageList.removeAll();
}
//Show status
public function updateStatus():void
{ 
	if ( acImageList.length > 20)
	{
		progressBar.label = "You might consider creating a zip file when lots of files are to be uploaded.";
	}
	else
	{
		progressBar.label = "Drop files or use the Browse button.";
	}
} 

//Browse for files
private function browseFiles( event:Event ):void
{  
	try
	{
		_fileref.browse( _filefilter );
	}
	catch( e:Error )
	{
		trace("error: " + e.message);
	}      
	
}

//Upload File Queue
private function uploadFiles( event:Event = null ):void
{
	if ( acImageList.length > 0 )
	{
		gb.log( "uploadFiles, acImageList.length: " + acImageList.length );
		trace( "uploadFiles, acImageList.length: " + acImageList.length );
		_variables = null;
		if ( !_variables )
		{
			_variables = new URLVariables;
			_variables.name = "up";
			_variables.type = "up";
			_variables.fa = "c.apiupload";
			_variables.destfolderid = gb.destFolderId;
			if ( gb.debug ) _variables.debug = 1 else _variables.debug = 0;
			_variables.emailto = "bruce@razuna.com";
			_variables.zip_extract = gb.zip_extract;
		}
		_url = "http://" + gb.hostname + gb.pathHosted + "/index.cfm?fa=c.apiupload&sessiontoken=" + gb.sessiontoken + "&destfolderid=" + gb.destFolderId; 
		gb.log( "uploadFiles, url: " + _url );
		_uploadURL = null;
		// Set Up URLRequest
		_uploadURL = new URLRequest();
		_uploadURL.url = _url;
		_uploadURL.method = "POST"; 
		_uploadURL.data = _variables;
		_uploadURL.contentType = "multipart/form-data";
		
		
		fileRefCleanUp();
		
		_file = FileReference( acImageList.getItemAt(0) );  
		_file.addEventListener( Event.OPEN, openHandler );
		_file.addEventListener( ProgressEvent.PROGRESS, progressHandler );
		_file.addEventListener( Event.COMPLETE, completeHandler );
		_file.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
		_file.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
		_file.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
		this.parentApplication.statusText.text = "Uploading to " + gb.hostname;
		/*try
		{
			_file.upload( _uploadURL );
		}
		catch( e:Error )
		{
			gb.infoLabel.text = e.message;
			gb.log( "uploadFiles, error: " + e.message);
		}  */    
		_file.upload( _uploadURL );
		
		setupCancelButton(true);
		//Avoid garbage collection to resolve 2038 IOErrorEvent
		//var succeed:Function = function():void{};
	}
}
private function fileRefCleanUp():void
{
	if ( _file )
	{
		_file.cancel();
		if ( _file.hasEventListener( Event.OPEN ) ) _file.removeEventListener( Event.OPEN, openHandler );
		if ( _file.hasEventListener( ProgressEvent.PROGRESS ) ) _file.removeEventListener( ProgressEvent.PROGRESS, progressHandler );
		if ( _file.hasEventListener( Event.COMPLETE ) ) _file.removeEventListener( Event.COMPLETE, completeHandler );
		if ( _file.hasEventListener( SecurityErrorEvent.SECURITY_ERROR ) ) _file.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
		if ( _file.hasEventListener( HTTPStatusEvent.HTTP_STATUS ) ) _file.removeEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
		if ( _file.hasEventListener( IOErrorEvent.IO_ERROR ) ) _file.removeEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
		_file = null;
		
	}
	
}
//Remove Selected File From Queue
private function removeSelectedFileFromQueue(event:Event):void
{
	updateStatus();
	if (imagesList.selectedIndex > 0)
	{
		acImageList.removeItemAt(imagesList.selectedIndex);
		checkQueue();
	} 
}
//Remove all files from the upload queue;
private function clearFileQueue(event:Event):void
{
	acImageList.removeAll();
	updateStatus();
}

// Cancel Current File Upload
private function cancelFileIO(event:Event):void
{
	_file.cancel();
	setupCancelButton(false);
	checkQueue();
}    

//label function for the datagird File Size Column
private function bytesToKilobytes(data:Object,blank:Object):String 
{
	var kilobytes:String;
	kilobytes = String(Math.round(data.size/ 1024)) + ' kb';
	return kilobytes
}

// Feed the progress bar a meaningful label
private function getByteCount():void
{
	var i:int;
	_totalbytes = 0;
	for(i=0;i < acImageList.length;i++)
	{
		//Error #1069: Property spaceAvailable not found: if ( acImageList[i].spaceAvailable > 0 ) _totalbytes +=  acImageList[i].size;
		_totalbytes +=  acImageList[i].size;
	}
	progressBar.label = "Total Files: "+  acImageList.length + " Total Size: " + Math.round(_totalbytes/1024) + " kb";
}        

// Checks the files do not exceed maxFileSize | if _maxFileSize == 0 No File Limit Set
private function checkFileSize(filesize:Number):Boolean
{
	var r:Boolean = false;
	//if  filesize greater then _maxFileSize
	if (filesize > _maxFileSize)
	{
		r = false;
	}
	else if (filesize <= _maxFileSize)
	{
		r = true;
	}
	if (_maxFileSize == 0)
	{
		r = true;
	}
	return r;
}

// restores progress bar back to normal
private function resetProgressBar():void
{
	progressBar.label = "";
	progressBar.maximum = 0;
	progressBar.minimum = 0;
}

// reset form item elements
private function resetForm():void
{
	uploadButton.enabled = false;
	uploadButton.addEventListener(MouseEvent.CLICK,uploadFiles);
	uploadButton.label = "Upload";
	progressBar.maximum = 0;
	_totalbytes = 0;
	progressBar.label = "";
	remselButton.enabled = false;
	remallButton.enabled = false;
	browseButton.enabled = true;
}

// whenever the _files arraycollection changes this function is called to make sure the datagrid data jives
private function popDataGrid( event:CollectionEvent ):void
{                
	getByteCount();
	checkQueue();
} 

// enable or disable upload and remove controls based on files in the queue;        
public function checkQueue():void
{
	if (acImageList.length > 0)
	{
		uploadButton.enabled = true;
		remselButton.enabled = true;
		remallButton.enabled = true;            
	}
	else
	{
		resetProgressBar();
		uploadButton.enabled = false; 
	}    
}

// toggle upload button label and function to trigger file uploading or upload cancelling
private function setupCancelButton( x:Boolean ):void
{
	if (x == true)
	{
		uploadButton.label = "Cancel";
		browseButton.enabled = false;
		remselButton.enabled = false;
		remallButton.enabled = false;
		uploadButton.addEventListener( MouseEvent.CLICK, cancelFileIO );        
	}
	else
	{
		uploadButton.removeEventListener( MouseEvent.CLICK, cancelFileIO );
		resetForm();
	}
}

/*********************************************************
 *  File IO Event Handlers                                *
 *********************************************************/

//  called after user selected files form the browse dialog box.
private function selectHandler( event:Event ):void 
{
	var i:int;
	var msg:String ="";
	var dl:Array = [];                          
	for ( i=0; i < event.currentTarget.fileList.length; i++ )
	{
		if ( checkFileSize( event.currentTarget.fileList[i].size ) )
		{
			//var ext:String;
			var fileToUpload:FileReference;
			fileToUpload = event.currentTarget.fileList[i];
			acImageList.addItem( fileToUpload );
		} 
		else 
		{
			dl.push( event.currentTarget.fileList[i] );
		}
	}	            
	if ( dl.length > 0 )
	{
		for ( i=0; i<dl.length; i++ )
		{
			msg += String( dl[i].name + " is too large. \n" );
		}
		mx.controls.Alert.show( msg + "Max File Size is: " + Math.round( _maxFileSize / 1024 ) + " kb", "File Too Large", 4, null ).clipContent;
	} 
	checkQueue();      
}        

// called after the file is opened before upload    
private function openHandler(event:Event):void
{
}

// called during the file upload of each file being uploaded | we use this to feed the progress bar its data
private function progressHandler(event:ProgressEvent):void 
{        
	progressBar.setProgress( event.bytesLoaded, event.bytesTotal );
	progressBar.label = "Uploading " + Math.round(event.bytesLoaded / 1024) + " kb of " + Math.round(event.bytesTotal / 1024) + " kb " + (acImageList.length - 1) + " files remaining";
	//gb.log( "progressBar.label: " + progressBar.label );
}

// called after a file has been successully uploaded | we use this as well to check if there are any files left to upload and how to handle it
private function completeHandler(event:Event):void{
	acImageList.removeItemAt(0);
	if ( retryTimer ) retryTimer.stop();
	if (acImageList.length > 0)
	{
		_totalbytes = 0;
		//uploadFiles(null);
		if ( gb.hostname == "srvsql02:8080/razuna" ) uploadRetry() else uploadFiles(null);
	}
	else
	{
		setupCancelButton(false);
		progressBar.label = "Uploads Complete";
		this.parentApplication.statusText.text = "Uploads Complete";
		var uploadCompleted:Event = new Event(Event.COMPLETE);
		//gb.RazunaDesktop.currentState = "LoggedIn";
		dispatchEvent(uploadCompleted);
	}
}    

// only called if there is an  error detected by flash player browsing or uploading a file   
private function ioErrorHandler( event:IOErrorEvent ):void
{
	gb.log( 'And IO Error has occured: ' + event );
	gb.log( 'And IO Error has occured, text: ' + event.text );
	if ( !gb.retry ) gb.retry = 30;
	progressBar.label = 'An IO Error has occured, retrying in ' + gb.retry + ' seconds.'
	uploadRetry();
	//dont show mx.controls.Alert.show(String(event),"ioError",0);
}    
// only called if a security error detected by flash player such as a sandbox violation
private function securityErrorHandler( event:SecurityErrorEvent ):void
{
	gb.log( "securityErrorHandler: " + event );
	if ( !gb.retry ) gb.retry = 30;
	progressBar.label = 'A security error has occured, retrying in ' + gb.retry + ' seconds.'
	uploadRetry();
	//dont show mx.controls.Alert.show(String(event),"Security Error",0);
}

//  This function its not required
private function cancelHandler( event:Event ):void
{
	// cancel button has been clicked;
	checkQueue();//to be verified
}

//  after a file upload is complete or attemted the server will return an http status code, code 200 means all is good anything else is bad.
private function httpStatusHandler( event:HTTPStatusEvent ):void 
{   
	gb.log( "httpStatusHandler, status: " + event.status );
	if (event.status != 200)
	{
		_file.cancel();
		uploadRetry();
		//dont show mx.controls.Alert.show(String(event),"Error",0);
	}
}
private function uploadRetry():void 
{   
	checkQueue();
	if ( retryTimer == null ) 
	{
		if ( !gb.retry ) gb.retry = 31;
		retryTimer = new Timer( gb.retry * 1000, 100 );
		retryTimer.addEventListener("timer", timerHandler);
	}
	retryTimer.start();

}
public function timerHandler( event:TimerEvent ):void 
{
	gb.log( "timerHandler, count: " + retryTimer.currentCount );
	uploadFiles();
}
