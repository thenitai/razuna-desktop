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
* October 9, 2010 version
*/
import mx.managers.CursorManager;

internal var selectedXML:XML;
internal var gb:Singleton = Singleton.getInstance();
import spark.events.IndexChangeEvent;

import mx.collections.ArrayCollection;
import mx.rpc.events.ResultEvent;
import fr.batchass.*;
import services.collection.Collection;
import services.folder.Folder;
import mx.core.windowClasses.StatusBar;
import mx.events.ListEvent;
// container for gallery
import flash.display.MovieClip;
import mx.states.AddChild;
import flash.display.DisplayObject;


import mx.controls.Alert;

[Bindable]
public var acAssetList:ArrayCollection;

public static var ASSETS_XML:XML;
private static var NOASSETS_XML:XML = <Response>
  							<responsecode>9</responsecode>
  							<listassets>
   							 <totalassetscount>Could not load </totalassetscount>
							</listassets>
						</Response>;
private static var GALLERY_XML:XML;
private function init():void
{
	//if ( !gb.assetsComponent ) gb.assetsComponent = this;
	acAssetList = new ArrayCollection();
	//assetsList.addEventListener( ListEvent.ITEM_CLICK, treeItemClickHandler );
	//acAssetList.addEventListener( CollectionEvent.COLLECTION_CHANGE, assetsChanged );
}
/*protected function assetsList_changeHandler(event:IndexChangeEvent):void
{
	trace( event.currentTarget.toString() );
}

protected function assetsList_clickHandler(event:MouseEvent):void
{
	trace( event.currentTarget.toString() );
}


private function treeItemClickHandler( event:ListEvent ):void
{
	var selectedItem:XML = event.itemRenderer.data as XML;
	var aId:Number = selectedItem.@id;
	gb.log( "treeItemClick, aId: " + aId );
	this.parentApplication.statusText.text = "Selected asset: " + selectedItem.@filename + ", url = " + selectedItem.@url;
	//gb.mediaComponent.streamName = selectedItem.@url;
	//CursorManager.setBusyCursor();
}*/
public function clearAssetList():void
{
	assetsInfo.text = "";
	acAssetList.removeAll();
}
//loads local cache assets.xml
public function loadAssetsXml( calledwith:String ):void
{
	var pathToLocalFile:String = gb.localRootPath + calledwith + File.separator + 'assets.xml';
	try
	{
		var assetsFile:File = File.documentsDirectory.resolvePath( pathToLocalFile );
		
		if ( !assetsFile.exists )
		{
			gb.log( pathToLocalFile + " does not exist in cache" );
			this.parentApplication.statusText.text = pathToLocalFile + " does not exist in cache.";
			ASSETS_XML = NOASSETS_XML; 
		}
		else
		{
			gb.log( pathToLocalFile + " exists, load the file xml" );
			this.parentApplication.statusText.text = pathToLocalFile + " loaded from cache.";
			ASSETS_XML = new XML( readTextFile( assetsFile ) );
		}
	}
	catch ( e:Error )
	{	
		ASSETS_XML = NOASSETS_XML;
		this.parentApplication.statusText.text = 'Error loading ' + pathToLocalFile + ' file' + e.message;
		gb.log( this.parentApplication.statusText.text );
	}
	clearAssetList();
	listLoad();
}

public function AssetsPopulate( event:ResultEvent ):void
{
	CursorManager.removeBusyCursor();
	var result:String =	event.result.toString();
	ASSETS_XML = XML(result);
	var response:uint = ASSETS_XML..responsecode;//0 if ok
	var message:String = ASSETS_XML..message;
	var folderId:String;// = ASSETS_XML..folderid[0];
	
	gb.log("AssetsPopulate, response: "+response);  
	gb.log("AssetsPopulate, message: "+message);  
	gb.log("AssetsPopulate, xml: "+ASSETS_XML);  
	acAssetList.removeAll();
	if ( response == 0 )
	{
		folderId = listLoad();
		if ( folderId != "null" ) saveAssetsXML( gb.localRootPath + folderId );
	}
	else
	{
		assetsInfo.text = "Webservice response not 0, try to load from cached assets.xml";
		loadAssetsXml( gb.folderId );
		//gb.statusText.text = message;
		if ( message == "Session timeout" ) gb.RDapp.currentState = "Startup";
	}
}
private function listLoad():String
{
	var assetList:XMLList = ASSETS_XML..asset as XMLList;
	//var folderId:String = ASSETS_XML..folderid[0];
	var calledwith:String = ASSETS_XML..calledwith;
	assetsInfo.text = ASSETS_XML..totalassetscount + " assets.";
	for each ( var asset:XML in assetList )
	{
		acAssetList.addItem( asset );
		//if different folders, means it was a search result or collection result
		//TODO  test if only 1 from coll OK
		//TODOif ( asset.folderid != folderId ) folderId += '-' + asset.folderid;//"Search";
	}
	return calledwith;
}

private function saveAssetsXML( localPath:String ):void
{
	var assetsFile:File = File.documentsDirectory.resolvePath( localPath + File.separator + 'assets.xml' );
	//  folders should be already created
	var dir:File = File.documentsDirectory.resolvePath( localPath );
	if ( !File.documentsDirectory.resolvePath( localPath ).exists )
	{
		trace("localPath does not exists:" + localPath);
		dir.createDirectory();
	}
	// write the text file
	writeTextFile(assetsFile, ASSETS_XML);					

}

protected function galleryButton_clickHandler(event:MouseEvent):void
{
	if ( ASSETS_XML )
	{
		
		var galleryPath:String = 'razuna' + File.separator + 'gallery' + File.separator;
		
		var imageCache:ImageCacheManager = ImageCacheManager.getInstance();
		var galleryFile:File = File.documentsDirectory.resolvePath( galleryPath + 'data.xml' );
		var imagesFile:File = File.documentsDirectory.resolvePath( galleryPath + 'images' + File.separator );
		var assetList:XMLList = ASSETS_XML..asset as XMLList;
		deleteOldImages( imagesFile );
		GALLERY_XML = <main>
			<config>
				<rotate rad="400" dark="88" />      	<!-- rad:circle radius(in pixels), dark:darkness(0 a 255) -->
				<thumb wMax="192" hMax="192" />	    	<!-- wMax:thumb width, hMax:thumb height -->
				<view type="reduce" thumb="reScale"/> 	<!-- type: "noResize","reduce","fullView" - thumb: "noScale","reScale"","fullScale"-->
				<carousel y="50"/> 						<!-- y of carousel from top of component-->
			</config>
			<images path="images/" />
		</main>;
		GALLERY_XML.@imageWidth = gb.imageWidth;
		GALLERY_XML.@thumbWidth = gb.thumbWidth;
		GALLERY_XML.@imageHeight = gb.imageHeight;
		GALLERY_XML.@thumbHeight = gb.thumbHeight;
		var i:uint = 0;
		for each ( var asset:XML in assetList )
		{
			if ( asset.kind == 'img' )
			{
				var assetXML:XML = <img />;
				assetXML.@id = i++;
				var cachedThumbUrl:String = imageCache.getGalleryImageByURL( asset.thumbnail, gb.thumbWidth, gb.thumbHeight );
				assetXML.@thumbnail = cachedThumbUrl;
				var cachedImageUrl:String = imageCache.getGalleryImageByURL( asset.url, gb.imageWidth, gb.imageHeight );
				assetXML.@url = cachedImageUrl;
				
				GALLERY_XML.images.appendChild( assetXML );
			}
		}
		// write the text file
		writeTextFile(galleryFile, GALLERY_XML);
		Alert.show( "Path: " + File.documentsDirectory.resolvePath( galleryPath ).url + "\nCopy those files to your web server.", "Gallery file generated in:" );
	}
}

private function deleteOldImages( sourceDir:File ):void
{
	for each( var lstFile:File in sourceDir.getDirectoryListing() )
	{
		if( !lstFile.isDirectory )
		{
			try 
			{
				lstFile.deleteFile();
			}
			catch (error:Error)
			{
				gb.log( "deleteOldImages Error:" + error.message );
			}
		}
	}	
}
private function reloadAssets( event:Event ):void
{
	gb.log( "reloadAssets, sessiontoken: " + gb.sessiontoken );
	//CursorManager.setBusyCursor();
	if ( gb.state == "Collections" )
	{
		if ( gb.collectionService ) gb.collectionService.getassets( gb.sessiontoken, gb.collectionId);
	}
	else
	{
		if ( gb.folderService ) gb.folderService.getassets( gb.sessiontoken, gb.folderId, 0, 0, 0, 'all' );
	}

}
public function setBusyCursor():void
{
	//CursorManager.setBusyCursor();
}