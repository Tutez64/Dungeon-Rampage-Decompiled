package com.facebook.graph.core
{
   import com.facebook.graph.data.Batch;
   import com.facebook.graph.data.FQLMultiQuery;
   import com.facebook.graph.data.FacebookAuthResponse;
   import com.facebook.graph.data.FacebookSession;
   import com.facebook.graph.net.FacebookBatchRequest;
   import com.facebook.graph.net.FacebookRequest;
   import com.facebook.graph.utils.FQLMultiQueryParser;
   import com.facebook.graph.utils.IResultParser;
   import flash.net.URLRequestMethod;
   import flash.utils.Dictionary;
   
   public class AbstractFacebook
   {
      
      protected var session:FacebookSession;
      
      protected var authResponse:FacebookAuthResponse;
      
      protected var oauth2:Boolean;
      
      protected var openRequests:Dictionary;
      
      protected var resultHash:Dictionary;
      
      protected var locale:String;
      
      protected var parserHash:Dictionary;
      
      public function AbstractFacebook()
      {
         super();
         this.openRequests = new Dictionary();
         this.resultHash = new Dictionary(true);
         this.parserHash = new Dictionary();
      }
      
      protected function get accessToken() : String
      {
         if(this.oauth2 && this.authResponse != null || this.session != null)
         {
            return this.oauth2 ? this.authResponse.accessToken : this.session.accessToken;
         }
         return null;
      }
      
      protected function api(method:String, callback:Function = null, params:* = null, requestMethod:String = "GET") : void
      {
         method = method.indexOf("/") != 0 ? "/" + method : method;
         if(this.accessToken)
         {
            if(params == null)
            {
               params = {};
            }
            if(params.access_token == null)
            {
               params.access_token = this.accessToken;
            }
         }
         var _loc5_:FacebookRequest = new FacebookRequest();
         if(this.locale)
         {
            params.locale = this.locale;
         }
         this.openRequests[_loc5_] = callback;
         _loc5_.call(FacebookURLDefaults.GRAPH_URL + method,requestMethod,this.handleRequestLoad,params);
      }
      
      protected function uploadVideo(method:String, callback:Function = null, params:* = null) : void
      {
         method = method.indexOf("/") != 0 ? "/" + method : method;
         if(this.accessToken)
         {
            if(params == null)
            {
               params = {};
            }
            if(params.access_token == null)
            {
               params.access_token = this.accessToken;
            }
         }
         var _loc4_:FacebookRequest = new FacebookRequest();
         if(this.locale)
         {
            params.locale = this.locale;
         }
         this.openRequests[_loc4_] = callback;
         _loc4_.call(FacebookURLDefaults.VIDEO_URL + method,"POST",this.handleRequestLoad,params);
      }
      
      protected function pagingCall(url:String, callback:Function) : FacebookRequest
      {
         var _loc3_:FacebookRequest = new FacebookRequest();
         this.openRequests[_loc3_] = callback;
         _loc3_.callURL(this.handleRequestLoad,url,this.locale);
         return _loc3_;
      }
      
      protected function getRawResult(data:Object) : Object
      {
         return this.resultHash[data];
      }
      
      protected function nextPage(data:Object, callback:Function = null) : FacebookRequest
      {
         var _loc3_:FacebookRequest = null;
         var _loc4_:Object = this.getRawResult(data);
         if((Boolean(_loc4_)) && Boolean(_loc4_.paging) && Boolean(_loc4_.paging.next))
         {
            _loc3_ = this.pagingCall(_loc4_.paging.next,callback);
         }
         else if(callback != null)
         {
            callback(null,"no page");
         }
         return _loc3_;
      }
      
      protected function previousPage(data:Object, callback:Function = null) : FacebookRequest
      {
         var _loc3_:FacebookRequest = null;
         var _loc4_:Object = this.getRawResult(data);
         if((Boolean(_loc4_)) && Boolean(_loc4_.paging) && Boolean(_loc4_.paging.previous))
         {
            _loc3_ = this.pagingCall(_loc4_.paging.previous,callback);
         }
         else if(callback != null)
         {
            callback(null,"no page");
         }
         return _loc3_;
      }
      
      protected function handleRequestLoad(target:FacebookRequest) : void
      {
         var _loc3_:Object = null;
         var _loc4_:IResultParser = null;
         var _loc2_:Function = this.openRequests[target];
         if(_loc2_ === null)
         {
            delete this.openRequests[target];
         }
         if(target.success)
         {
            _loc3_ = "data" in target.data ? target.data.data : target.data;
            this.resultHash[_loc3_] = target.data;
            if(_loc3_.hasOwnProperty("error_code"))
            {
               _loc2_(null,_loc3_);
            }
            else
            {
               if(this.parserHash[target] is IResultParser)
               {
                  _loc4_ = this.parserHash[target] as IResultParser;
                  _loc3_ = _loc4_.parse(_loc3_);
                  this.parserHash[target] = null;
                  delete this.parserHash[target];
               }
               _loc2_(_loc3_,null);
            }
         }
         else
         {
            _loc2_(null,target.data);
         }
         delete this.openRequests[target];
      }
      
      protected function callRestAPI(methodName:String, callback:Function = null, values:* = null, requestMethod:String = "GET") : void
      {
         var _loc6_:IResultParser = null;
         if(values == null)
         {
            values = {};
         }
         values.format = "json";
         if(this.accessToken)
         {
            values.access_token = this.accessToken;
         }
         if(this.locale)
         {
            values.locale = this.locale;
         }
         var _loc5_:FacebookRequest = new FacebookRequest();
         this.openRequests[_loc5_] = callback;
         if(this.parserHash[values["queries"]] is IResultParser)
         {
            _loc6_ = this.parserHash[values["queries"]] as IResultParser;
            this.parserHash[values["queries"]] = null;
            delete this.parserHash[values["queries"]];
            this.parserHash[_loc5_] = _loc6_;
         }
         _loc5_.call(FacebookURLDefaults.API_URL + "/method/" + methodName,requestMethod,this.handleRequestLoad,values);
      }
      
      protected function fqlQuery(query:String, callback:Function = null, values:Object = null) : void
      {
         var _loc4_:String = null;
         for(_loc4_ in values)
         {
            query = query.replace(new RegExp("\\{" + _loc4_ + "\\}","g"),values[_loc4_]);
         }
         this.callRestAPI("fql.query",callback,{"query":query});
      }
      
      protected function fqlMultiQuery(queries:FQLMultiQuery, callback:Function = null, parser:IResultParser = null) : void
      {
         this.parserHash[queries.toString()] = parser != null ? parser : new FQLMultiQueryParser();
         this.callRestAPI("fql.multiquery",callback,{"queries":queries.toString()});
      }
      
      protected function batchRequest(batch:Batch, callback:Function = null) : void
      {
         var _loc3_:FacebookBatchRequest = null;
         if(this.accessToken)
         {
            _loc3_ = new FacebookBatchRequest(batch,callback);
            this.resultHash[_loc3_] = true;
            _loc3_.call(this.accessToken);
         }
      }
      
      protected function deleteObject(method:String, callback:Function = null) : void
      {
         var _loc3_:Object = {"method":"delete"};
         this.api(method,callback,_loc3_,URLRequestMethod.POST);
      }
      
      protected function getImageUrl(id:String, type:String = null) : String
      {
         return FacebookURLDefaults.GRAPH_URL + "/" + id + "/picture" + (type != null ? "?type=" + type : "");
      }
   }
}

