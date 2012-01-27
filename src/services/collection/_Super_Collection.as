/**
 * This is a generated class and is not intended for modfication.  To customize behavior
 * of this service wrapper you may modify the generated sub-class of this class - Collection.as.
 */
package services.collection
{
import com.adobe.fiber.core.model_internal;
import com.adobe.fiber.services.wrapper.WebServiceWrapper;
import com.adobe.serializers.utility.TypeUtility;
import mx.rpc.AbstractOperation;
import mx.rpc.AsyncToken;
import mx.rpc.soap.mxml.Operation;
import mx.rpc.soap.mxml.WebService;

[ExcludeClass]
internal class _Super_Collection extends com.adobe.fiber.services.wrapper.WebServiceWrapper
{
     
    // Constructor
    public function _Super_Collection( hostname:String )
    {
        // initialize service control
        _serviceControl = new mx.rpc.soap.mxml.WebService();
        var operations:Object = new Object();
        var operation:mx.rpc.soap.mxml.Operation;
         
        operation = new mx.rpc.soap.mxml.Operation(null, "getcollectionstree");
		 operation.resultType = String; 		 
        operations["getcollectionstree"] = operation;
    
        operation = new mx.rpc.soap.mxml.Operation(null, "getcollections");
		 operation.resultType = String; 		 
        operations["getcollections"] = operation;
    
        operation = new mx.rpc.soap.mxml.Operation(null, "getassets");
		 operation.resultType = String; 		 
        operations["getassets"] = operation;
    
        _serviceControl.operations = operations;
        try
        {
            _serviceControl.convertResultHandler = com.adobe.serializers.utility.TypeUtility.convertResultHandler;
        }
        catch (e: Error)
        { /* Flex 3.4 and eralier does not support the convertResultHandler functionality. */ }

  

        _serviceControl.service = "collectionService";
        _serviceControl.port = "collection.cfc";
        wsdl = "http://" + hostname + "/global/api/collection.cfc?WSDL";
        model_internal::loadWSDLIfNecessary();
      
     
        model_internal::initialize();
    }

	/**
	  * This method is a generated wrapper used to call the 'getcollectionstree' operation. It returns an mx.rpc.AsyncToken whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.rpc.AsyncToken
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.rpc.AsyncToken whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function getcollectionstree(sessiontoken:String, e4x:Number) : mx.rpc.AsyncToken
	{
		model_internal::loadWSDLIfNecessary();
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("getcollectionstree");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send(sessiontoken,e4x) ;

		return _internal_token;
	}   
	 
	/**
	  * This method is a generated wrapper used to call the 'getcollections' operation. It returns an mx.rpc.AsyncToken whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.rpc.AsyncToken
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.rpc.AsyncToken whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function getcollections(sessiontoken:String, folderid:Number, e4x:Number) : mx.rpc.AsyncToken
	{
		model_internal::loadWSDLIfNecessary();
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("getcollections");
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
	public function getassets(sessiontoken:String, collectionid:String) : mx.rpc.AsyncToken
	{
		model_internal::loadWSDLIfNecessary();
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("getassets");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send(sessiontoken,collectionid) ;

		return _internal_token;
	}   
	 
}

}
