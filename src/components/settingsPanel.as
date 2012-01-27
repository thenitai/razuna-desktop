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
import flash.events.Event;
internal var gb:Singleton = Singleton.getInstance();
[Bindable]
private var labelWidth:Number = 200;
[Bindable]
private var lineHeight:Number = 27;

private function init():void
{
	loadSettings();
	debug.addEventListener( MouseEvent.CLICK, handleDebug );
}
protected function handleDebug( event: MouseEvent ):void
{
	gb.debug = debug.selected;
}

protected function retryNumStepper_changeHandler(event:Event):void
{
	gb.retry = event.currentTarget.value;
}

protected function thumbWidth_changeHandler(event:Event):void
{
	gb.thumbWidth = event.currentTarget.value;
}

protected function thumbHeight_changeHandler(event:Event):void
{
	gb.thumbHeight = event.currentTarget.value;
}

protected function imageHeight_changeHandler(event:Event):void
{
	gb.imageHeight = event.currentTarget.value;
}
protected function imageWidth_changeHandler(event:Event):void
{
	gb.imageWidth = event.currentTarget.value;
}
//Save the encrypted credentials to the file system
private function saveSettings():void
{
	/*var lBytes:ByteArray = new ByteArray();
	lBytes.writeUTFBytes( 'English' );
	EncryptedLocalStore.setItem( "language", lBytes );*/
	var zBytes:ByteArray = new ByteArray();
	zBytes.writeUTFBytes( unzip.selected.toString() );
	EncryptedLocalStore.setItem( "unzip", zBytes );
	var gBytes:ByteArray = new ByteArray();
	gBytes.writeUTFBytes( debug.selected.toString() );
	EncryptedLocalStore.setItem( "debug", gBytes );
	var rBytes:ByteArray = new ByteArray();
	rBytes.writeUTFBytes( retryNumStepper.value.toString() );
	EncryptedLocalStore.setItem( "retry", rBytes );
	var twBytes:ByteArray = new ByteArray();
	twBytes.writeUTFBytes( thumbWidth.value.toString() );
	EncryptedLocalStore.setItem( "tw", twBytes );
	var thBytes:ByteArray = new ByteArray();
	thBytes.writeUTFBytes( thumbHeight.value.toString() );
	EncryptedLocalStore.setItem( "th", thBytes );
	var iwBytes:ByteArray = new ByteArray();
	iwBytes.writeUTFBytes( imageWidth.value.toString() );
	EncryptedLocalStore.setItem( "iw", iwBytes );
	var ihBytes:ByteArray = new ByteArray();
	ihBytes.writeUTFBytes( imageHeight.value.toString() );
	EncryptedLocalStore.setItem( "ih", ihBytes );
}
//Load the encrypted credentials from the file system
public function loadSettings():void
{
	var rBytes:ByteArray = EncryptedLocalStore.getItem( "retry" );
	if (rBytes) 
	{ 
		retryNumStepper.value = Number(rBytes.readUTFBytes( rBytes.length ) ); 
	}
	else
	{
		retryNumStepper.value = 30; 
	}
	gb.retry = retryNumStepper.value;
	gb.log("settings, loadSettings, retry:" + retryNumStepper.value);
	
	var zBytes:ByteArray = EncryptedLocalStore.getItem( "unzip" );
	if ( zBytes ) 
	{
		var zb:String = zBytes.readUTFBytes( zBytes.length );
		if ( zb == 'true' ) 
		{
			unzip.selected = true;
			gb.zip_extract = 1;
		} 
		else 
		{
			unzip.selected = false;
			gb.zip_extract = 0;
		}
	}
	var gBytes:ByteArray = EncryptedLocalStore.getItem( "debug" );
	if ( gBytes ) 
	{
		var sgb:String = gBytes.readUTFBytes( gBytes.length );
		if ( sgb == 'true' ) 
		{
			gb.debug = true;
			debug.selected = true;
		} 
		else
		{
			gb.debug = false;
			debug.selected = false;
		}
	}
	var twBytes:ByteArray = EncryptedLocalStore.getItem( "tw" );
	if (twBytes) 
	{ 
		thumbWidth.value = Number(twBytes.readUTFBytes( twBytes.length ) ); 
	}
	else
	{
		thumbWidth.value = 150; 
	}
	gb.thumbWidth = thumbWidth.value;
	var thBytes:ByteArray = EncryptedLocalStore.getItem( "th" );
	if (thBytes) 
	{ 
		thumbHeight.value = Number(thBytes.readUTFBytes( thBytes.length ) ); 
	}
	else
	{
		thumbHeight.value = 150; 
	}
	gb.thumbHeight = thumbHeight.value;
	var iwBytes:ByteArray = EncryptedLocalStore.getItem( "iw" );
	if (iwBytes) 
	{ 
		imageWidth.value = Number(iwBytes.readUTFBytes( iwBytes.length ) ); 
	}
	else
	{
		imageWidth.value = 350; 
	}
	gb.imageWidth = imageWidth.value;
	var ihBytes:ByteArray = EncryptedLocalStore.getItem( "ih" );
	if (ihBytes) 
	{ 
		imageHeight.value = Number(ihBytes.readUTFBytes( ihBytes.length ) ); 
	}
	else
	{
		imageHeight.value = 350; 
	}
	gb.imageHeight = imageHeight.value;
	
}
