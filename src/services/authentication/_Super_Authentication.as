/**
 * This is a generated class and is not intended for modfication.  To customize behavior
 * of this service wrapper you may modify the generated sub-class of this class - Authentication.as.
 */
package services.authentication
{
import com.adobe.fiber.core.model_internal;
import com.adobe.fiber.services.wrapper.WebServiceWrapper;
import com.adobe.serializers.utility.TypeUtility;
import mx.rpc.AbstractOperation;
import mx.rpc.AsyncToken;
import mx.rpc.soap.mxml.Operation;
import mx.rpc.soap.mxml.WebService;

[ExcludeClass]
internal class _Super_Authentication extends com.adobe.fiber.services.wrapper.WebServiceWrapper
{
     
    // Constructor
    public function _Super_Authentication( hostname:String )
    {
        // initialize service control
        _serviceControl = new mx.rpc.soap.mxml.WebService();
        var operations:Object = new Object();
        var operation:mx.rpc.soap.mxml.Operation;
         
        operation = new mx.rpc.soap.mxml.Operation(null, "login");
		 operation.resultType = String; 		 
        operations["login"] = operation;
    
        operation = new mx.rpc.soap.mxml.Operation(null, "loginhost");
		 operation.resultType = String; 		 
        operations["loginhost"] = operation;
    
        _serviceControl.operations = operations;
        try
        {
            _serviceControl.convertResultHandler = com.adobe.serializers.utility.TypeUtility.convertResultHandler;
        }
        catch (e: Error)
        { /* Flex 3.4 and eralier does not support the convertResultHandler functionality. */ }

  

        _serviceControl.service = "authenticationService";
        _serviceControl.port = "authentication.cfc";
        wsdl = "http://" + hostname + "/global/api/authentication.cfc?WSDL";
        model_internal::loadWSDLIfNecessary();
      
     
        model_internal::initialize();
    }

	/**
	  * This method is a generated wrapper used to call the 'login' operation. It returns an mx.rpc.AsyncToken whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.rpc.AsyncToken
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.rpc.AsyncToken whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function login(hostid:Number, user:String, pass:String, passhashed:Number) : mx.rpc.AsyncToken
	{
		model_internal::loadWSDLIfNecessary();
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("login");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send(hostid,user,pass,passhashed) ;

		return _internal_token;
	}   
	 
	/**
	  * This method is a generated wrapper used to call the 'loginhost' operation. It returns an mx.rpc.AsyncToken whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.rpc.AsyncToken
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.rpc.AsyncToken whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function loginhost(hostname:String, user:String, pass:String, passhashed:Number) : mx.rpc.AsyncToken
	{
		model_internal::loadWSDLIfNecessary();
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("loginhost");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send(hostname,user,pass,passhashed) ;

		return _internal_token;
	}   
	 
}

}
