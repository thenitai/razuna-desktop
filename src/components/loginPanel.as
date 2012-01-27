//import air.net.URLMonitor;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;

import fr.batchass.ImageCacheManager;

import mx.managers.CursorManager;
import mx.rpc.events.ResultEvent;

import services.authentication.Authentication;

internal var gb:Singleton = Singleton.getInstance();
private var credCount:int = 0;
//monitor the website url
//private var monitor:URLMonitor;
[Bindable]
private var xData:XML;
[Bindable]
private var labelWidth:Number = 80;
[Bindable]
private var lineHeight:Number = 27;
private static var _imageCache:ImageCacheManager = ImageCacheManager.getInstance();

private function init():void
{
	loadCredentials();
}
public function logout():void
{
	gb.sessiontoken = "logout";
	loginInfo.text = "You are logged out.";
	gb.RDapp.versionLabel.text = "Razuna Desktop v" + gb.RDapp.installedVersion;

	if ( gb.RDapp.assetsComponent ) gb.RDapp.assetsComponent.clearAssetList();	
	if ( gb.folderService ) gb.folderService = null;
	if ( gb.collectionService ) gb.collectionService = null;
	gb.populatePanels();
	//gb.RDapp.browseBtn.visible = false;
	//gb.RDapp.offlineModeBtn.visible = true;
	
	gb.RDapp.currentState = 'Startup';
}

protected function saveCB_clickHandler(event:MouseEvent):void
{
	if ( saveCB.selected ) saveCredentials() else clearCredentials();
}
protected function autoLoginCB_clickHandler(event:MouseEvent):void
{
	gb.autoLogin = ( autoLoginCB.selected );
}

public function offlineMode():void
{
	gb.hostname = hostname.text;
	if ( gb.hostname.indexOf( 'razuna.com' ) > -1 )
	{
		//Hosted on razuna.com
		currentState = 'Hosted';
		gb.log( "offlineMode, hosted: " + gb.hostname );
		gb.hosted = true;
		hosted.selected = true;
	}	
	else
	{
		//Local server
		currentState = 'Local';
		gb.log( "offlineMode, local, hostid: " + hostid.text );
		gb.hosted = false;
		local.selected = true;
		gb.hostId = Number( hostid.text );
	}
	workOffline();
}
protected function logon():void
{
	CursorManager.setBusyCursor();
	loginInfo.text = "Logging in... Please wait...";
	/*gb.host = hostname.text;
	var firstSlash:uint = gb.host.indexOf( '/' );
	if ( firstSlash > -1 )
	{
		if ( gb.host.substr( 0, 7 ) == "http://" )
		{
			hostname.text = gb.host.substr( 7 );
			gb.host = hostname.text;
			firstSlash = gb.host.indexOf( '/' );
			if ( firstSlash > -1 )
			{
				gb.host = gb.host.substr( 0, firstSlash );
			}
		}
		else
		{
			gb.host = gb.host.substr( 0, firstSlash );
		}
		
	}*/
	//urlMonitor( "http://" + gb.host );
	
	
	gb.hostname = hostname.text;
	/*gb.host = hostname.text;
	var colon:uint = gb.hostname.lastIndexOf( ':' );
	if ( colon > -1 )
	{
		gb.host = hostname.text.substr( 0, colon );
		gb.port = hostname.text.substr( colon );
	}	
	if ( !offlineCB.selected )
	{*/
	var loginService:Authentication = new Authentication( hostname.text );
	gb.log( "logon, hostname:" + hostname.text );
	//}
	//var hostLen:int = gb.hostname.length;
	//if ( (hostLen > 10) && ( gb.hostname.substr( hostLen - 10, 10 ) == 'razuna.com') )
	if ( gb.hostname.indexOf( 'razuna.com' ) > -1 )
	{
		//Hosted on razuna.com
		currentState = 'Hosted';
		gb.log( "logon, hosted: " + gb.hostname );
		gb.hosted = true;
		hosted.selected = true;
		/*if ( !offlineCB.selected )
		{*/
		loginService.addEventListener( ResultEvent.RESULT, loginhostListener );
		loginService.loginhost( gb.hostname, username.text, password.text, 0 );
		//}
	}	
	else
	{
		//Local server
		currentState = 'Local';
		gb.log( "logon, local, hostid: " + hostid.text );
		gb.hosted = false;
		local.selected = true;
		gb.hostId = Number( hostid.text );
		/*if ( !offlineCB.selected )
		{*/
		loginService.addEventListener( ResultEvent.RESULT, loginListener );
		loginService.login( gb.hostId, username.text, password.text, 0 );
		//}
	}
	if ( saveCB.selected ) saveCredentials() else clearCredentials();
	//if ( offlineCB.selected ) workOffline();
}

/*private function urlMonitor(url:String):void 
{
	// URLRequest that the Monitor Will Check
	var urlRequest:URLRequest = new URLRequest( url );
	// Checks Only the Headers - Not the Full Page
	urlRequest.method = "HEAD";
	//monitor = null;
	// Create the URL Monitor and Pass it the URLRequest
	monitor = new URLMonitor( urlRequest );
	// Set the Interval (in ms) - 3000 = 3 Seconds
	monitor.pollInterval = 3000;
	// Add Our Event Listener to Respond the a Change in Connection Status
	monitor.addEventListener( StatusEvent.STATUS, onMonitor );
	// Start the URLMonitor
	monitor.start();	
}
private function onMonitor(event:StatusEvent):void 
{
	if ( monitor )
	{
		if(monitor.available) 
		{
			gb.log( "monitor, available: " + gb.host );
		} 
		else 
		{
			gb.log( "monitor, down: " + gb.host );
			gb.statusText.text = "Warning, the url you typed is not available (" + gb.host + ")";
		}
		monitor.stop();
		monitor = null;
	}
}*/

// result from loginhost webservice
private function loginhostListener( event:ResultEvent ):void
{
	var result:String =	event.result.toString();;
	gb.log( "loginhostListener:" + result);
	checkLogon( result );
}
// result from login webservice
private function loginListener( event:ResultEvent ):void
{
	var result:String =	event.result.toString();;
	gb.log( "loginListener:" + result);
	checkLogon( result );
} 
// check if login successful
private function checkLogon( result:String ):void
{
	xData = XML(result);
	gb.sessiontoken = xData..sessiontoken;
	gb.log( "checkLogon, sessiontoken: " + gb.sessiontoken);
	if ( gb.sessiontoken.length < 30 ) 
	{
		this.parentApplication.statusText.text = gb.sessiontoken; //Access denied
	}
	else
	{
		if ( gb.hosted ) gb.hostId = xData..hostid;
		gb.log( "checkLogon, pathHosted: " + gb.pathHosted );
		//if ( gb.hostname == "batchass.razuna.com" ) gb.hostId = 7;

		gb.RDapp.versionLabel.text = "Connected as " + username.text + " on " + gb.hostname;
		//init and populate controls
		initExploreState();
	}
	CursorManager.removeBusyCursor();
}
//init work offline mode
private function workOffline():void
{
	gb.RDapp.versionLabel.text = "Browsing " + gb.hostname + " in offline mode.";
	gb.sessiontoken = "Offline mode";
	gb.log( "workOffline, sessiontoken: " + gb.sessiontoken);

	this.parentApplication.statusText.text = gb.sessiontoken; //Offline mode

	gb.log( "workOffline, pathHosted: " + gb.pathHosted );

	//init and populate controls
	initExploreState();
}
//init and populate controls
private function initExploreState():void
{
	if ( !gb.hosted ) 
	{ 
		gb.pathHosted = dampath.text;
	}
	else
	{
		gb.pathHosted = "";
	}
	gb.hostDir = gb.hostname + gb.pathHosted;
	//load custom logo
	var cachedLogo:String = _imageCache.getAssetByURL( "http://" + gb.hostname + "/global/host/logo/" + gb.hostId.toString() + "/logo.jpg", "global" );
	var loader:Loader = new Loader();
	loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLogoLoaded);
	loader.load( new URLRequest( cachedLogo ) );
	//gb.RDapp.browseBtn.visible = true;
	
	gb.RDapp.currentState = 'LoggedIn';
	//populate panels
	gb.populatePanels();

}
private function onLogoLoaded( event:Event ):void 
{
	gb.RDapp.logo.source = event.target.content.bitmapData;  
}
protected function ToggleButton_click():void
{
	if ( hosted.selected )
	{
		gb.hosted = true;
		currentState = 'Hosted';
		if (gb.hUserName) username.text = gb.hUserName;
		if (gb.hPassword) password.text = gb.hPassword;
		if (gb.hHostName) hostname.text = gb.hostname = gb.hHostName;
	}
	else
	{
		gb.hosted = false;
		currentState = 'Local';
		if (gb.lUserName) username.text = gb.lUserName;
		if (gb.lPassword) password.text = gb.lPassword;
		if (gb.lHostName) hostname.text = gb.hostname = gb.lHostName;
	}
}
// Clear the credentials 
private function clearCredentials():void
{
	EncryptedLocalStore.removeItem( "username" );
	EncryptedLocalStore.removeItem( "password" );
	EncryptedLocalStore.removeItem( "hostname" );
	EncryptedLocalStore.removeItem( "husername" );
	EncryptedLocalStore.removeItem( "hpassword" );
	EncryptedLocalStore.removeItem( "hhostname" );
	EncryptedLocalStore.removeItem( "lusername" );
	EncryptedLocalStore.removeItem( "lpassword" );
	EncryptedLocalStore.removeItem( "lhostname" );
	EncryptedLocalStore.removeItem( "hostid" );
	EncryptedLocalStore.removeItem( "dampath" );
	EncryptedLocalStore.removeItem( "hosted" );
	var sBytes:ByteArray = new ByteArray();
	sBytes.writeUTFBytes( saveCB.selected ? 'true' : 'false' );
	EncryptedLocalStore.setItem( "remember", sBytes );
}
//Save the encrypted credentials to the file system
private function saveCredentials():void
{
	var uBytes:ByteArray = new ByteArray();
	uBytes.writeUTFBytes( username.text );
	if ( gb.hosted ) EncryptedLocalStore.setItem( "husername", uBytes ) else EncryptedLocalStore.setItem( "lusername", uBytes );
	var pBytes:ByteArray = new ByteArray();
	pBytes.writeUTFBytes( password.text );
	if ( gb.hosted ) EncryptedLocalStore.setItem( "hpassword", pBytes ) else EncryptedLocalStore.setItem( "lpassword", pBytes );
	var hBytes:ByteArray = new ByteArray();
	hBytes.writeUTFBytes( hostname.text );
	if ( gb.hosted ) EncryptedLocalStore.setItem( "hhostname", hBytes ) else EncryptedLocalStore.setItem( "lhostname", hBytes );
	gb.log("saveCredentials, hostname:" + hostname.text);
	gb.log("saveCredentials, hostid:" + hostid.text);
	var iBytes:ByteArray = new ByteArray();
	iBytes.writeUTFBytes( hostid.text );
	EncryptedLocalStore.setItem( "hostid", iBytes );
	var sBytes:ByteArray = new ByteArray();
	sBytes.writeUTFBytes( saveCB.selected ? 'true' : 'false' );
	EncryptedLocalStore.setItem( "remember", sBytes );
	var dBytes:ByteArray = new ByteArray();
	dBytes.writeUTFBytes( dampath.text );
	EncryptedLocalStore.setItem( "dampath", dBytes );
	var eBytes:ByteArray = new ByteArray();
	eBytes.writeUTFBytes( hosted.selected.toString() );
	EncryptedLocalStore.setItem( "hosted", eBytes );
	var aBytes:ByteArray = new ByteArray();
	aBytes.writeUTFBytes( autoLoginCB.selected ? 'true' : 'false' );
	EncryptedLocalStore.setItem( "autologin", aBytes );
}
//Load the encrypted credentials from the file system
public function loadCredentials():void
{
	var uhBytes:ByteArray = EncryptedLocalStore.getItem( "husername" );
	if (uhBytes) gb.hUserName = uhBytes.readUTFBytes( uhBytes.length );
	var ulBytes:ByteArray = EncryptedLocalStore.getItem( "lusername" );
	if (ulBytes) gb.lUserName = ulBytes.readUTFBytes( ulBytes.length );
	var phBytes:ByteArray = EncryptedLocalStore.getItem( "hpassword" );
	if (phBytes) gb.hPassword = phBytes.readUTFBytes( phBytes.length );
	var plBytes:ByteArray = EncryptedLocalStore.getItem( "lpassword" );
	if (plBytes) gb.lPassword = plBytes.readUTFBytes( plBytes.length );
	var hhBytes:ByteArray = EncryptedLocalStore.getItem( "hhostname" );
	if (hhBytes) gb.hHostName = hhBytes.readUTFBytes( hhBytes.length );
	var hlBytes:ByteArray = EncryptedLocalStore.getItem( "lhostname" );
	if (hlBytes) gb.lHostName = hlBytes.readUTFBytes( hlBytes.length );
	gb.log("loadCredentials, hostname:" + hostname.text);
	var eBytes:ByteArray = EncryptedLocalStore.getItem( "hosted" );
	if ( eBytes ) 
	{ 
		var hl:String = eBytes.readUTFBytes( eBytes.length );
		gb.log("loadCredentials, hl:" + hl);
		hosted.selected = ( hl == 'true' );
		local.selected = ( hl == 'false' );
		gb.hosted = ( hl == 'true' );
		if ( gb.hosted )
		{
			if (gb.hUserName) { username.text = gb.hUserName;  credCount++; }
			if (gb.hPassword) { password.text = gb.hPassword; credCount++; }
			if (gb.hHostName) { hostname.text = gb.hostname = gb.hHostName; credCount++; }
			currentState = 'Hosted';
		}
		else
		{
			if (gb.lUserName) { username.text = gb.lUserName;  credCount++; }
			if (gb.lPassword) { password.text = gb.lPassword; credCount++; }
			if (gb.lHostName) { hostname.text = gb.hostname = gb.lHostName; credCount++; }
			currentState = 'Local';
		}
		var iBytes:ByteArray = EncryptedLocalStore.getItem( "hostid" );
		if (iBytes) 
		{ 
			if (hostid) { hostid.text = iBytes.readUTFBytes( iBytes.length ); } 
			gb.log("loadCredentials, hostid:" + hostid.text);
		}
		var dBytes:ByteArray = EncryptedLocalStore.getItem( "dampath" );
		if (dBytes) 
		{ 
			if (dampath) { dampath.text = dBytes.readUTFBytes( dBytes.length ) } 
		}
		
	}
	var sBytes:ByteArray = EncryptedLocalStore.getItem( "remember" );
	if ( sBytes ) 
	{
		var sb:String = sBytes.readUTFBytes( sBytes.length );
		saveCB.selected = ( sb == 'true' );
	}
	var aBytes:ByteArray = EncryptedLocalStore.getItem( "autologin" );
	if ( aBytes ) 
	{
		var ab:String = aBytes.readUTFBytes( aBytes.length );
		autoLoginCB.selected = ( ab == 'true' );
		gb.autoLogin = autoLoginCB.selected;
	}
	
	// if it was saved, good chances login worked before...
	if ( ( credCount > 2 ) && ( gb.autoLogin ) ) logon(); 
}