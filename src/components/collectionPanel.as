import fr.batchass.*;

import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.events.TreeEvent;
import mx.managers.CursorManager;
import mx.rpc.events.ResultEvent;

import services.collection.Collection;

[Bindable]
internal var selectedXML:XML;
[Bindable]
private var xCollections:XMLList;
internal var gb:Singleton = Singleton.getInstance();
public static var COLLECTION_XML:XML;
//private static var collId:Number; //not optimum if plenty of clicks

public function collectionPanel_init():void
{
	gb.log("rdCollectionPanel, collectionPanel_init");
	//if ( !gb.collectionPanel ) gb.collectionPanel = this;

	this.collectionTree.addEventListener( TreeEvent.ITEM_OPEN, treeItemOpenHandler );
	this.collectionTree.addEventListener( ListEvent.CHANGE, treeChangeHandler );
	this.collectionTree.addEventListener( ListEvent.ITEM_CLICK, treeItemClickHandler );
}
public function loadCollectionXml( collectionid:String ):void
{
	try
	{
		var collFile:File = File.documentsDirectory.resolvePath( gb.localRootPath + 'collections' + File.separator + collectionid + '.xml' );
		
		if ( !collFile.exists )
		{
			gb.log( collectionid + ".xml does not exist" );
			this.parentApplication.statusText.text = collectionid + ".xml does not exist";
			COLLECTION_XML = <collection />; 
		}
		else
		{
			gb.log( collectionid + ".xml exists, load the file xml" );
			this.parentApplication.statusText.text = "Loading " + collectionid + ".xml";
			COLLECTION_XML = new XML( readTextFile( collFile ) );
			xCollections = COLLECTION_XML.listcollections.collection as XMLList;
			this.collectionTree.dataProvider=xCollections;
		}
	}
	catch ( e:Error )
	{	
		COLLECTION_XML = <collection />;
		this.parentApplication.statusText.text = 'Error loading ' + collectionid + '.xml file' + e.message;
		gb.log( this.parentApplication.statusText.text );
	}
}

public function collectionPanel_populate( collectionid:String ):void
{
	//TODO transform 237 to 8-60 collId = collectionid;
	//CursorManager.setBusyCursor();
	gb.log("rdCollectionPanel, collectionPanel_populate, collectionid:" + collectionid );
	this.parentApplication.statusText.text = "Retrieving selected collections... please wait.";
	if ( gb.collectionService )
	{
		gb.collectionService.getcollections( gb.sessiontoken, collectionid as int, 1);
	}
	else
	{
		//offline mode, try to collections from local cache
		loadCollectionXml( collectionid );
		
	}
}
/*private function collectionAssetsListener( event:GetassetsResultEvent ):void
{
	var result:String =	event.result;
	gb.log("rdCollectionPanel, collectionListener:" + result);

}*/
public function collectionListener( event:ResultEvent ):void
{
	CursorManager.removeBusyCursor();
	this.parentApplication.statusText.text = "Collections loaded.";
	var result:String =	event.result.toString();;
	gb.log("rdCollectionPanel, collectionListener:" + result);
	COLLECTION_XML = XML(result);
	
	xCollections = COLLECTION_XML.listcollections.collection as XMLList;
	this.collectionTree.dataProvider=xCollections;

	var calledwith:String = COLLECTION_XML..calledwith;
	var pathToLocalFile:String;
	if ( calledwith.charAt(0) == 'c' ) 
	{ //assets
		pathToLocalFile = gb.localRootPath + calledwith + File.separator + 'assets.xml';	
	} 
	else 
	{ //collection
		//TODO create collections dir before (works ok but cleaner)
		pathToLocalFile = gb.localRootPath + 'collections' + File.separator + calledwith + '.xml';
	}
	var collFile:File = File.documentsDirectory.resolvePath( pathToLocalFile );	;
	
	
	// write the text file
	writeTextFile( collFile, COLLECTION_XML );	
	
}
private function treeChangeHandler( event:Event ):void
{
	selectedXML = this.collectionTree.selectedItem[0] as XML;
}
private function treeItemOpenHandler(event:TreeEvent):void
{
	selectedXML = event.item.parent().parent().collectionid as XML;
	this.collectionTree.selectedItem = selectedXML; 
	trace(selectedXML);
} 
private function treeItemClickHandler(event:ListEvent):void
{
	gb.RDapp.assetsComponent.setBusyCursor();
	var selectedItem:XML = event.itemRenderer.data as XML;
	gb.collectionId = selectedItem.@collectionid;
	gb.log( "rdCollectionPanel, Selected collection: " + selectedItem.@collectionname + ", collectionid = " + gb.collectionId );
	if ( gb.collectionService )
	{
		gb.collectionService.getassets( gb.sessiontoken, gb.collectionId);
	}
	else
	{
		//offline mode, try to load assets from local cache
		//gb.RDapp.assetsComponent.loadCollectionAssetsXml( collectionId );
		gb.RDapp.assetsComponent.loadAssetsXml( 'c-' + gb.collectionId );
	}
}
