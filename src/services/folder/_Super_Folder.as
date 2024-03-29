/**
 * This is a generated class and is not intended for modfication.  To customize behavior
 * of this service wrapper you may modify the generated sub-class of this class - Folder.as.
 */
package services.folder
{
import com.adobe.fiber.core.model_internal;
import com.adobe.fiber.services.wrapper.WebServiceWrapper;
import com.adobe.serializers.utility.TypeUtility;

import mx.rpc.AbstractOperation;
import mx.rpc.AsyncToken;
import mx.rpc.soap.mxml.Operation;
import mx.rpc.soap.mxml.WebService;

[ExcludeClass]
internal class _Super_Folder extends com.adobe.fiber.services.wrapper.WebServiceWrapper
{
     
    // Constructor
    public function _Super_Folder( hostname:String )
    {
        // initialize service control
        _serviceControl = new mx.rpc.soap.mxml.WebService();
        var operations:Object = new Object();
        var operation:mx.rpc.soap.mxml.Operation;
         
        operation = new mx.rpc.soap.mxml.Operation(null, "getfolders");
		 operation.resultType = String; 		 
        operations["getfolders"] = operation;
    
        operation = new mx.rpc.soap.mxml.Operation(null, "getassets");
		 operation.resultType = String; 		 
        operations["getassets"] = operation;
    
        operation = new mx.rpc.soap.mxml.Operation(null, "getfolderstree");
		 operation.resultType = String; 		 
        operations["getfolderstree"] = operation;
    
        operation = new mx.rpc.soap.mxml.Operation(null, "setfolder");
		 operation.resultType = String; 		 
        operations["setfolder"] = operation;
		
		operation = new mx.rpc.soap.mxml.Operation(null, "removefolder");
		operation.resultType = String;
		operations["removefolder"] = operation;
   
        _serviceControl.operations = operations;
        try
        {
            _serviceControl.convertResultHandler = com.adobe.serializers.utility.TypeUtility.convertResultHandler;
        }
        catch (e: Error)
        { /* Flex 3.4 and eralier does not support the convertResultHandler functionality. */ }

  

        _serviceControl.service = "folderService";
        _serviceControl.port = "folder.cfc";
        wsdl = "http://" + hostname + "/global/api/folder.cfc?WSDL";
        model_internal::loadWSDLIfNecessary();
      
     
        model_internal::initialize();
    }

	/**
	  * This method is a generated wrapper used to call the 'getfolders' operation. It returns an mx.rpc.AsyncToken whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.rpc.AsyncToken
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.rpc.AsyncToken whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function getfolders(sessiontoken:String, folderid:String, e4x:Number) : mx.rpc.AsyncToken
	{
		model_internal::loadWSDLIfNecessary();
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("getfolders");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send(sessiontoken,folderid,e4x) ;

		return _internal_token;
	}   
	 
	/**
	  * This method is a generated wrapper used to call the 'getassets' operation. It returns an mx.rpc.AsyncToken whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.rpc.AsyncToken
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.rpc.AsyncToken whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function getassets(sessiontoken:String, folderid:String, showsubfolders:Number, offset:Number, maxrows:Number, show:String) : mx.rpc.AsyncToken
	{
		model_internal::loadWSDLIfNecessary();
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("getassets");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send(sessiontoken,folderid,showsubfolders,offset,maxrows,show) ;

		return _internal_token;
	}   
	 
	/**
	  * This method is a generated wrapper used to call the 'getfolderstree' operation. It returns an mx.rpc.AsyncToken whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.rpc.AsyncToken
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.rpc.AsyncToken whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function getfolderstree(sessiontoken:String, e4x:Number) : mx.rpc.AsyncToken
	{
		model_internal::loadWSDLIfNecessary();
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("getfolderstree");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send(sessiontoken,e4x) ;

		return _internal_token;
	}   
	public function setfolder(sessiontoken:String, folder_name:String, folder_owner:String, folder_related:String, folder_collection:String, folder_description:String) : mx.rpc.AsyncToken
	{
		model_internal::loadWSDLIfNecessary();
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("setfolder");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send(sessiontoken,folder_name,folder_owner, folder_related, folder_collection, folder_description);
		
		return _internal_token;
	}   
	public function removefolder(sessiontoken:String, folder_id:String ) : mx.rpc.AsyncToken
	{
		model_internal::loadWSDLIfNecessary();
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("removefolder");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send(sessiontoken,folder_id);
		
		return _internal_token;
	}   
}

}
