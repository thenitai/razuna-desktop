import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;

import fr.batchass.*;

import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.ListEvent;
import mx.events.TreeEvent;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.states.State;

import spark.components.TitleWindow;

internal var  folders:XML;
[Bindable]
internal var xFolders:XMLList;
internal var selectedXML:XML;
internal var gb:Singleton = Singleton.getInstance();

public static var FOLDERS_XML:XML;
private var openTreeItems:Object = new Object();
private var folderPopup:TitleWindow;
[Bindable]
private var selectedFolder:String = "root folder";

//called on init also
public function foldersPanel_populate():void
{
	//CursorManager.setBusyCursor();
	//this.parentApplication.statusText.text = "Retrieving folders...please wait.";
	
	loadFoldersXml();
	
	gb.log( "foldersPanel_populate, hostname: " + gb.hostname + ", sessiontoken: " + gb.sessiontoken );

	if ( gb.sessiontoken == "Offline mode" )
	{
		treeRefresh();
		//newFolder.visible = false;
		createButton.visible = false;
		deleteButton.visible = false;
	}
	else
	{
		//newFolder.visible = true;
		createButton.visible = true;
		deleteButton.visible = true;
	}
}

public function loadFoldersXml():void
{
	try
	{
		var folderFile:File = File.documentsDirectory.resolvePath( gb.localRootPath + 'global' + File.separator + 'folders.xml' );
		
		if ( !folderFile.exists )
		{
			gb.log( "folders.xml does not exist" );
			FOLDERS_XML = <folders />;
		}
		else
		{
			gb.log( "folders.xml exists, load the file xml" );
			FOLDERS_XML = new XML( readTextFile( folderFile ) );
		}
	}
	catch ( e:Error )
	{	
		FOLDERS_XML = <folders />;
		this.parentApplication.statusText.text = 'Error loading folders.xml file' + e.message;
		gb.log( this.parentApplication.statusText.text );
	}
	this.folderTree.addEventListener( TreeEvent.ITEM_OPEN, treeItemOpenHandler );
	this.folderTree.addEventListener( ListEvent.CHANGE, treeChangeHandler );
	this.folderTree.addEventListener( ListEvent.ITEM_CLICK, treeItemClickHandler );
}

public function folderListener( event:ResultEvent ):void
{
	var result:String =	event.result.toString();
	var newFolders:XML = XML( result );
	var folderId:String;
	var passedFolderId:String;
	var dirty:Boolean = false;
	var hasLoadingChild:Boolean = false;
	
	
	openTreeItems = this.folderTree.openItems;
	CursorManager.removeBusyCursor();
	//test if folders exists at this level
	if (newFolders.listfolders.folder[0])
	{
		passedFolderId = newFolders.listfolders.folder[0].@folderidpassed;
		this.parentApplication.statusText.text = "Folders loaded, selected folderid = " + passedFolderId;
		
		if ( !FOLDERS_XML )
		{
			FOLDERS_XML = <folders />;//folderid="0" 
			//folders = XML(result);
		}
		for each ( var child:XML in FOLDERS_XML..folder.(@folderid==passedFolderId).folder ) 
		{
			trace( "child:"+child.toXMLString() );
			if ( child.@folderid == "00" ) 
			{
				hasLoadingChild = true;
				//FOLDERS_XML..folder.(@folderid==passedFolderId).setChildren(null);
			}
		}
		for each ( var item:XML in newFolders.listfolders.folder ) 
		{
			if ( item.@hassubfolder == "true" )
			{
				item.appendChild( <folder folderid="00" foldername="loading..." hassubfolder="false" totalassets="0" totalimg="0" totalvid="0" totaldoc="0" totalaud="0" folderowner="0" /> );
			}
				
			//remove duplicates
			if ( item.@folderid != passedFolderId)
			{
				if ( hasLoadingChild )
				{ 
					//replace the 00 loading child
					hasLoadingChild = false;
					if ( item.length() == 1 ) 
					{
						FOLDERS_XML..folder.(@folderid==passedFolderId).folder = item;
						dirty = true;
					}
				}
				else
				{
					var alreadyCreated:Boolean = false;
					for each ( var childFolder:XML in FOLDERS_XML..folder )//FOLDERS_XML..folder.(@folderid==passedFolderId).folder ) 
					{
						trace( "child:"+childFolder.toXMLString() );
						if ( childFolder.@folderid == item.@folderid ) 
						{
							alreadyCreated = true;
							//FOLDERS_XML..folder.(@folderid==passedFolderId).setChildren(null);
							if ( childFolder.@foldername[0] != item.@foldername[0] ) 
							{
								dirty = true;
							}
						}
					}
					//on root populate control
					if ( passedFolderId == "0" ) dirty = true;
					if ( alreadyCreated )
					{
						FOLDERS_XML..folder.(@folderid==passedFolderId).folder = item;
						
					}
					else
					{
						//if called the first time, we are on root
						if ( passedFolderId == "0" )
						{
							dirty = true;
							FOLDERS_XML.appendChild( item );
							//create root tree directory on local profile, maybe useless
							var treeRoot:File = File.documentsDirectory.resolvePath( gb.localRootPath );
							if ( !treeRoot.exists ) treeRoot.createDirectory();	
						}
						else
						{
							FOLDERS_XML..folder.(@folderid==passedFolderId).appendChild( item );
						}
					}
					//create directory on local drive
					var localPath:String = gb.localRootPath + item.@folderid;
					var dir:File = File.documentsDirectory.resolvePath( localPath );
					if ( !File.documentsDirectory.resolvePath( localPath ).exists  ) dir.createDirectory();
					
					//save to local XML file
					writeFolderXmlFile();	
				}
				//}
			}
		}
	}
	if ( dirty )
	{	
		treeRefresh();
	}
}
private function writeFolderXmlFile():void
{
	var folderFile:File = File.documentsDirectory.resolvePath( gb.localRootPath + 'global' + File.separator + 'folders.xml' );
	// write the text file
	writeTextFile(folderFile, FOLDERS_XML);					
}
private function treeRefresh():void
{
	CursorManager.removeBusyCursor();
	this.folderTree.setFocus();
	//var openTreeItems:Object = new Object();
	//openTreeItems = this.folderTree.openItems;
	this.folderTree.openItems = openTreeItems;
	this.folderTree.selectedItem = selectedXML; //select the opened folder
	xFolders = FOLDERS_XML.folder as XMLList;
	this.folderTree.dataProvider=xFolders;
	this.folderTree.setFocus();
	
}
private function treeChangeHandler( event:Event ):void
{
	selectedXML = this.folderTree.selectedItem[0] as XML;
}
private function treeItemOpenHandler(event:TreeEvent):void
{
	selectedXML = event.item as XML;
	this.folderTree.selectedItem = selectedXML; //select the opened folder
	var fId:String = selectedXML.@folderid;
	gb.folderId = fId;
	if ( gb.folderService ) gb.folderService.getfolders( gb.sessiontoken, fId, 1 ); 
}
private function treeItemClickHandler(event:ListEvent):void
{
	//keep the folder for navigation
	selectedXML = event.itemRenderer.data as XML;
	var fId:String = selectedXML.@folderid;
	gb.destFolderId = fId;
	gb.folderId = fId;
	gb.log( "treeItemClick, fId: " + fId );
	gb.log( "treeItemClick, gb.folderId: " + gb.folderId );
	gb.log( "treeItemClick, gb.destFolderId: " + gb.destFolderId );
	gb.log( "treeItemClick, selectedFolder: " + selectedFolder );
	selectedFolder = selectedXML.@foldername;
	this.parentApplication.statusText.text = "Selected folder: " + selectedXML.@foldername + ", folderid = " + selectedXML.@folderid;
	if ( gb.folderService )
	{
		//folderService.addEventListener( ResultEvent.RESULT, gb.RDapp.assetsComponent.AssetsPopulate ); 
		gb.folderService.getassets( gb.sessiontoken, fId, 0, 0, 0, 'all' );
		gb.folderService.getfolders( gb.sessiontoken, fId, 1 ); 
	}
	else
	{
		//offline mode, try to load assets from local cache
		gb.RDapp.assetsComponent.loadAssetsXml( fId );
	}
	trace(selectedXML.folderid);
}
private function reloadFolders():void
{
	gb.log( "reloadFolders, sessiontoken: " + gb.sessiontoken );
	CursorManager.setBusyCursor();
	//delete current folder structure
	FOLDERS_XML = <folders />;
	xFolders = FOLDERS_XML.folder as XMLList;
	this.folderTree.dataProvider=xFolders;
	writeFolderXmlFile();
	if ( gb.folderService ) gb.folderService.getfolders( gb.sessiontoken, "0", 1 ); 
}
private function createFolder():void
{
	gb.log( "createFolder, sessiontoken: " + gb.sessiontoken );
	this.setCurrentState("FolderCreation");
}
private function deleteFolder():void
{
	gb.log( "deleteFolder, sessiontoken: " + gb.sessiontoken );
	Alert.show("Your selected folder will be removed", "Are you sure?", Alert.YES | Alert.NO, this, alertClickHandler);
}
private function alertClickHandler(event:CloseEvent):void
{
	var outputMessage:String = "";
	switch (event.detail)
	{
		case Alert.YES:
			gb.log( "deleteFolder, confirmed by yes on folderid: " + gb.folderId );
			if ( gb.folderService ) 
			{
				gb.folderService.removefolder( gb.sessiontoken, gb.folderId ); 
				reloadFolders();
			}
			break;
		case Alert.NO:
			gb.log( "deleteFolder, cancelled by no on folderid: " + gb.folderId );
			break;
	}
}
protected function okBtn_clickHandler(event:MouseEvent):void
{
	var parent:String;
	if ( gb.folderService && newFolder.text.length > 0 )
	{
		if (gb.folderId == "1") parent = "" else parent = gb.folderId;
		gb.folderService.setfolder( gb.sessiontoken, newFolder.text, "", parent, "false", "created via razuna desktop" ); 
		newFolder.text = "";
		reloadFolders();
	}
	this.setCurrentState("Normal");
}
protected function cancelBtn_clickHandler(event:MouseEvent):void
{
	this.setCurrentState("Normal");
	
}