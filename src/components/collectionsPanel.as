import fr.batchass.*;

import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.ListEvent;
import mx.events.TreeEvent;
import mx.managers.CursorManager;
import mx.rpc.events.ResultEvent;

import services.collection.Collection;

internal var collectionid:String="1";
[Bindable]
internal var selectedXML:XML;
[Bindable]
private var xCollections:XMLList;
internal var gb:Singleton = Singleton.getInstance();
public static var COLLECTIONS_XML:XML = <collections />;
private var openTreeItems:Object = new Object();
[Bindable]
private var selectedCollection:String = "root collection";

public function collectionsPanel_populate():void
{
	//this.parentApplication.statusText.text = "Retrieving collections tree... please wait.";
	gb.log( "rdCollectionsPanel, collectionsPanel_populate, hostname: " + gb.hostname + ", sessiontoken: " + gb.sessiontoken );

	loadCollectionsXml();
	if ( gb.sessiontoken == "Offline mode" )
	{
		collsTreeRefresh();
	}
}

public function loadCollectionsXml():void
{
	try
	{
		if ( gb.localRootPath )
		{
			var collsFile:File = File.documentsDirectory.resolvePath( gb.localRootPath + 'global' + File.separator + 'collections.xml' );
			
			if ( !collsFile.exists )
			{
				gb.log( "collections.xml does not exist" );
				this.parentApplication.statusText.text = 'collections.xml does not exist';
				//COLLECTIONS_XML = <collections />; 
			}
			else
			{
				gb.log( "collections.xml exists, load the file xml" );
				COLLECTIONS_XML = new XML( readTextFile( collsFile ) );
			}
		}
	}
	catch ( e:Error )
	{	
		//COLLECTIONS_XML = <collections />;
		this.parentApplication.statusText.text = 'Error loading collections.xml file' + e.message;
		gb.log( this.parentApplication.statusText.text );
	}
	collsTreeRefresh();
	this.collectionsTree.addEventListener( TreeEvent.ITEM_OPEN, treeItemOpenHandler );
	this.collectionsTree.addEventListener( ListEvent.CHANGE, treeChangeHandler );
	this.collectionsTree.addEventListener( ListEvent.ITEM_CLICK, treeItemClickHandler );
}

public function collectionsTreeListener( event:ResultEvent ):void
{
	CursorManager.removeBusyCursor();
	this.parentApplication.statusText.text = "Collections tree loaded.";
	var result:String =	event.result.toString();
	gb.log("rdCollectionsPanel, collectionsTreeListener:" + result);
	
	COLLECTIONS_XML = XML(result);
	
	xCollections = COLLECTIONS_XML.listcollections.collection as XMLList;
	//collectionsPanel
	this.collectionsTree.dataProvider=xCollections;
	trace(xCollections);  
	
	var collsFile:File = File.documentsDirectory.resolvePath( gb.localRootPath + 'global' + File.separator + 'collections.xml' );
	// write the text file
	writeTextFile( collsFile, COLLECTIONS_XML );	

}
private function collsTreeRefresh():void
{
	CursorManager.removeBusyCursor();
	this.collectionsTree.setFocus();
	//var openTreeItems:Object = new Object();
	//openTreeItems = this.collectionsTree.openItems;
	this.collectionsTree.openItems = openTreeItems;
	this.collectionsTree.selectedItem = selectedXML; //select the opened collection
	xCollections = COLLECTIONS_XML.listcollections.collection as XMLList;
	this.collectionsTree.dataProvider=xCollections;
	this.collectionsTree.setFocus();
	
}
private function treeChangeHandler( event:Event ):void
{
	selectedXML = this.collectionsTree.selectedItem[0] as XML;
}
private function treeItemOpenHandler(event:TreeEvent):void
{
	selectedXML = event.item.parent().parent().collectionid as XML;
	this.collectionsTree.selectedItem = selectedXML; 
	trace(selectedXML);
} 
private function treeItemClickHandler(event:ListEvent):void
{
	var selectedItem:XML = event.itemRenderer.data as XML;
	collectionid = selectedItem.@collectionid;
	gb.log( "rdCollectionsPanel, Selected tree collection: " + selectedItem.@collectionname + ", collectionid = " + selectedItem.@collectionid );
	selectedCollection = selectedItem.@collectionname;
	gb.RDapp.assetsComponent.clearAssetList();
	gb.RDapp.collectionPanel.collectionPanel_populate( collectionid );
}
private function reloadTreeCollections():void
{
	collectionsPanel_populate();
	gb.log( "rdCollectionsPanel, reloadTreeCollections, sessiontoken: " + gb.sessiontoken );
	if ( gb.collectionService ) gb.collectionService.getcollectionstree( gb.sessiontoken, 1 ); 
}
private function createCollectionFolder():void
{
	gb.log( "createCollectionFolder, sessiontoken: " + gb.sessiontoken );
	this.setCurrentState("FolderCreation");
}
private function deleteCollectionFolder():void
{
	gb.log( "deleteCollectionFolder, sessiontoken: " + gb.sessiontoken );
	Alert.show("Your selected folder will be removed", "Are you sure?", Alert.YES | Alert.NO, this, alertClickHandler);
}
private function alertClickHandler(event:CloseEvent):void
{
	var outputMessage:String = "";
	switch (event.detail)
	{
		case Alert.YES:
			gb.log( "deleteCollectionFolder, confirmed by yes on folderid: " + collectionid );
			if ( gb.folderService ) 
			{
				gb.folderService.removefolder( gb.sessiontoken, collectionid ); 
				reloadTreeCollections();
			}
			break;
		case Alert.NO:
			gb.log( "deleteCollectionFolder, cancelled by no on folderid: " + collectionid );
			break;
	}
}
protected function okBtn_clickHandler(event:MouseEvent):void
{
	var parent:String;
	if ( gb.folderService && newCollection.text.length > 0 )
	{
		if (collectionid == "1") parent = "" else parent = collectionid;
		gb.folderService.setfolder( gb.sessiontoken, newCollection.text,"", parent, "true", "created via razuna desktop" );
		newCollection.text = "";
		reloadTreeCollections();
	}
	this.setCurrentState("Normal");
}
protected function cancelBtn_clickHandler(event:MouseEvent):void
{
	this.setCurrentState("Normal");
	
}
