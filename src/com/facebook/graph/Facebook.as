package com.facebook.graph
{
   import com.adobe.serialization.json.JSON;
   import com.adobe.serialization.json.JSONParseError;
   import com.facebook.graph.core.AbstractFacebook;
   import com.facebook.graph.core.FacebookJSBridge;
   import com.facebook.graph.core.FacebookURLDefaults;
   import com.facebook.graph.data.Batch;
   import com.facebook.graph.data.FQLMultiQuery;
   import com.facebook.graph.data.FacebookAuthResponse;
   import com.facebook.graph.net.FacebookRequest;
   import com.facebook.graph.utils.IResultParser;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.net.navigateToURL;
   import flash.utils.Dictionary;
   
   public class Facebook extends AbstractFacebook
   {
      
      protected static var _instance:Facebook;
      
      protected static var _canInit:Boolean = false;
      
      protected var jsCallbacks:Object;
      
      protected var openUICalls:Dictionary;
      
      protected var jsBridge:FacebookJSBridge;
      
      protected var applicationId:String;
      
      protected var _initCallback:Function;
      
      protected var _loginCallback:Function;
      
      protected var _logoutCallback:Function;
      
      public function Facebook()
      {
         super();
         if(_canInit == false)
         {
            throw new Error("Facebook is an singleton and cannot be instantiated.");
         }
         this.jsBridge = new FacebookJSBridge();
         this.jsCallbacks = {};
         this.openUICalls = new Dictionary();
      }
      
      public static function init(applicationId:String, callback:Function = null, options:Object = null, accessToken:String = null) : void
      {
         getInstance().init(applicationId,callback,options,accessToken);
      }
      
      public static function set locale(value:String) : void
      {
         getInstance().locale = value;
      }
      
      public static function login(callback:Function, options:Object = null) : void
      {
         getInstance().login(callback,options);
      }
      
      public static function mobileLogin(redirectUri:String, display:String = "touch", extendedPermissions:Array = null) : void
      {
         var _loc4_:URLVariables = new URLVariables();
         _loc4_.client_id = getInstance().applicationId;
         _loc4_.redirect_uri = redirectUri;
         _loc4_.display = display;
         if(extendedPermissions != null)
         {
            _loc4_.scope = extendedPermissions.join(",");
         }
         var _loc5_:URLRequest = new URLRequest(FacebookURLDefaults.AUTH_URL);
         _loc5_.method = URLRequestMethod.GET;
         _loc5_.data = _loc4_;
         navigateToURL(_loc5_,"_self");
      }
      
      public static function mobileLogout(redirectUri:String) : void
      {
         getInstance().authResponse = null;
         var _loc2_:URLVariables = new URLVariables();
         _loc2_.confirm = 1;
         _loc2_.next = redirectUri;
         var _loc3_:URLRequest = new URLRequest("http://m.facebook.com/logout.php");
         _loc3_.method = URLRequestMethod.GET;
         _loc3_.data = _loc2_;
         navigateToURL(_loc3_,"_self");
      }
      
      public static function logout(callback:Function) : void
      {
         getInstance().logout(callback);
      }
      
      public static function ui(method:String, data:Object, callback:Function = null, display:String = null) : void
      {
         getInstance().ui(method,data,callback,display);
      }
      
      public static function api(method:String, callback:Function = null, params:* = null, requestMethod:String = "GET") : void
      {
         getInstance().api(method,callback,params,requestMethod);
      }
      
      public static function getRawResult(data:Object) : Object
      {
         return getInstance().getRawResult(data);
      }
      
      public static function hasNext(data:Object) : Boolean
      {
         var _loc2_:Object = getInstance().getRawResult(data);
         if(!_loc2_.paging)
         {
            return false;
         }
         return _loc2_.paging.next != null;
      }
      
      public static function hasPrevious(data:Object) : Boolean
      {
         var _loc2_:Object = getInstance().getRawResult(data);
         if(!_loc2_.paging)
         {
            return false;
         }
         return _loc2_.paging.previous != null;
      }
      
      public static function nextPage(data:Object, callback:Function) : FacebookRequest
      {
         return getInstance().nextPage(data,callback);
      }
      
      public static function previousPage(data:Object, callback:Function) : FacebookRequest
      {
         return getInstance().previousPage(data,callback);
      }
      
      public static function postData(method:String, callback:Function = null, params:Object = null) : void
      {
         api(method,callback,params,URLRequestMethod.POST);
      }
      
      public static function uploadVideo(method:String, callback:Function = null, params:* = null) : void
      {
         getInstance().uploadVideo(method,callback,params);
      }
      
      public static function fqlQuery(query:String, callback:Function = null, values:Object = null) : void
      {
         getInstance().fqlQuery(query,callback,values);
      }
      
      public static function fqlMultiQuery(queries:FQLMultiQuery, callback:Function = null, parser:IResultParser = null) : void
      {
         getInstance().fqlMultiQuery(queries,callback,parser);
      }
      
      public static function batchRequest(batch:Batch, callback:Function = null) : void
      {
         getInstance().batchRequest(batch,callback);
      }
      
      public static function callRestAPI(methodName:String, callback:Function, values:* = null, requestMethod:String = "GET") : void
      {
         getInstance().callRestAPI(methodName,callback,values,requestMethod);
      }
      
      public static function getImageUrl(id:String, type:String = null) : String
      {
         return getInstance().getImageUrl(id,type);
      }
      
      public static function deleteObject(method:String, callback:Function = null) : void
      {
         getInstance().deleteObject(method,callback);
      }
      
      public static function addJSEventListener(event:String, listener:Function) : void
      {
         getInstance().addJSEventListener(event,listener);
      }
      
      public static function removeJSEventListener(event:String, listener:Function) : void
      {
         getInstance().removeJSEventListener(event,listener);
      }
      
      public static function hasJSEventListener(event:String, listener:Function) : Boolean
      {
         return getInstance().hasJSEventListener(event,listener);
      }
      
      public static function setCanvasAutoResize(autoSize:Boolean = true, interval:uint = 100) : void
      {
         getInstance().setCanvasAutoResize(autoSize,interval);
      }
      
      public static function setCanvasSize(width:Number, height:Number) : void
      {
         getInstance().setCanvasSize(width,height);
      }
      
      public static function callJS(methodName:String, params:Object) : void
      {
         getInstance().callJS(methodName,params);
      }
      
      public static function getAuthResponse() : FacebookAuthResponse
      {
         return getInstance().getAuthResponse();
      }
      
      public static function getLoginStatus() : void
      {
         getInstance().getLoginStatus();
      }
      
      protected static function getInstance() : Facebook
      {
         if(_instance == null)
         {
            _canInit = true;
            _instance = new Facebook();
            _canInit = false;
         }
         return _instance;
      }
      
      protected function init(applicationId:String, callback:Function = null, options:Object = null, accessToken:String = null) : void
      {
         ExternalInterface.addCallback("handleJsEvent",this.handleJSEvent);
         ExternalInterface.addCallback("authResponseChange",this.handleAuthResponseChange);
         ExternalInterface.addCallback("logout",this.handleLogout);
         ExternalInterface.addCallback("uiResponse",this.handleUI);
         this._initCallback = callback;
         this.applicationId = applicationId;
         this.oauth2 = true;
         if(options == null)
         {
            options = {};
         }
         options.appId = applicationId;
         options.oauth = true;
         ExternalInterface.call("FBAS.init",com.adobe.serialization.json.JSON.encode(options));
         if(accessToken != null)
         {
            authResponse = new FacebookAuthResponse();
            authResponse.accessToken = accessToken;
         }
         if(options.status !== false)
         {
            this.getLoginStatus();
         }
         else if(this._initCallback != null)
         {
            this._initCallback(authResponse,null);
            this._initCallback = null;
         }
      }
      
      protected function getLoginStatus() : void
      {
         ExternalInterface.call("FBAS.getLoginStatus");
      }
      
      protected function callJS(methodName:String, params:Object) : void
      {
         ExternalInterface.call(methodName,params);
      }
      
      protected function setCanvasSize(width:Number, height:Number) : void
      {
         ExternalInterface.call("FBAS.setCanvasSize",width,height);
      }
      
      protected function setCanvasAutoResize(autoSize:Boolean = true, interval:uint = 100) : void
      {
         ExternalInterface.call("FBAS.setCanvasAutoResize",autoSize,interval);
      }
      
      protected function login(callback:Function, options:Object = null) : void
      {
         this._loginCallback = callback;
         ExternalInterface.call("FBAS.login",com.adobe.serialization.json.JSON.encode(options));
      }
      
      protected function logout(callback:Function) : void
      {
         this._logoutCallback = callback;
         ExternalInterface.call("FBAS.logout");
      }
      
      protected function getAuthResponse() : FacebookAuthResponse
      {
         var a:FacebookAuthResponse;
         var authResponseObj:Object = null;
         var result:String = ExternalInterface.call("FBAS.getAuthResponse");
         try
         {
            authResponseObj = com.adobe.serialization.json.JSON.decode(result);
         }
         catch(e:*)
         {
            return null;
         }
         a = new FacebookAuthResponse();
         a.fromJSON(authResponseObj);
         this.authResponse = a;
         return authResponse;
      }
      
      protected function ui(method:String, data:Object, callback:Function = null, display:String = null) : void
      {
         data.method = method;
         if(callback != null)
         {
            this.openUICalls[method] = callback;
         }
         if(display)
         {
            data.display = display;
         }
         ExternalInterface.call("FBAS.ui",com.adobe.serialization.json.JSON.encode(data));
      }
      
      protected function addJSEventListener(event:String, listener:Function) : void
      {
         if(this.jsCallbacks[event] == null)
         {
            this.jsCallbacks[event] = new Dictionary();
            ExternalInterface.call("FBAS.addEventListener",event);
         }
         this.jsCallbacks[event][listener] = null;
      }
      
      protected function removeJSEventListener(event:String, listener:Function) : void
      {
         if(this.jsCallbacks[event] == null)
         {
            return;
         }
         delete this.jsCallbacks[event][listener];
      }
      
      protected function hasJSEventListener(event:String, listener:Function) : Boolean
      {
         if(this.jsCallbacks[event] == null || this.jsCallbacks[event][listener] !== null)
         {
            return false;
         }
         return true;
      }
      
      protected function handleUI(result:String, method:String) : void
      {
         var _loc3_:Object = result ? com.adobe.serialization.json.JSON.decode(result) : null;
         var _loc4_:Function = this.openUICalls[method];
         if(_loc4_ === null)
         {
            delete this.openUICalls[method];
         }
         else
         {
            _loc4_(_loc3_);
            delete this.openUICalls[method];
         }
      }
      
      protected function handleLogout() : void
      {
         authResponse = null;
         if(this._logoutCallback != null)
         {
            this._logoutCallback(true);
            this._logoutCallback = null;
         }
      }
      
      protected function handleJSEvent(event:String, result:String = null) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(this.jsCallbacks[event] != null)
         {
            try
            {
               _loc3_ = com.adobe.serialization.json.JSON.decode(result);
            }
            catch(e:JSONParseError)
            {
            }
            for(_loc4_ in this.jsCallbacks[event])
            {
               (_loc4_ as Function)(_loc3_);
               delete this.jsCallbacks[event][_loc4_];
            }
         }
      }
      
      protected function handleAuthResponseChange(result:String) : void
      {
         var resultObj:Object = null;
         var success:Boolean = true;
         if(result != null)
         {
            try
            {
               resultObj = com.adobe.serialization.json.JSON.decode(result);
            }
            catch(e:JSONParseError)
            {
               success = false;
            }
         }
         else
         {
            success = false;
         }
         if(success)
         {
            if(authResponse == null)
            {
               authResponse = new FacebookAuthResponse();
               authResponse.fromJSON(resultObj);
            }
            else
            {
               authResponse.fromJSON(resultObj);
            }
         }
         if(this._initCallback != null)
         {
            this._initCallback(authResponse,null);
            this._initCallback = null;
         }
         if(this._loginCallback != null)
         {
            this._loginCallback(authResponse,null);
            this._loginCallback = null;
         }
      }
   }
}

