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
import flash.display.Sprite;
import flash.html.HTMLLoader;
import flash.net.URLRequest;

internal var gb:Singleton = Singleton.getInstance();

private function init():void
{
	//html.location = "http://" + gb.hostname + "/global/api/RazunaUpload.cfm?pathhosted=" + gb.pathHosted + "&hostname=" + gb.hostname+ "&debug=0&sessiontoken=" + gb.sessiontoken + "&destfolderid=" + gb.destFolderId;
	html.location = "http://" + gb.hostname;
	swf.source = "http://" + gb.hostname + "/global/api/RazunaUpload.swf?pathhosted=" + gb.pathHosted + "&hostname=" + gb.hostname+ "&debug=0&sessiontoken=" + gb.sessiontoken + "&folderid=" + gb.destFolderId;
	/*var html:HTMLLoader = new HTMLLoader();
	var urlReq:URLRequest = new URLRequest("http://www.razuna.com/");
	html.width = 800;
	html.height = 400;
	html.load(urlReq); 
	addChild(html);*/
}

