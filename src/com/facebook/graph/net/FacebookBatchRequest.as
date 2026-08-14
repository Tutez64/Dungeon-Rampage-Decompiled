package com.facebook.graph.net
{
   import com.adobe.images.PNGEncoder;
   import com.adobe.serialization.json.JSON;
   import com.facebook.graph.core.FacebookURLDefaults;
   import com.facebook.graph.data.Batch;
   import com.facebook.graph.data.BatchItem;
   import com.facebook.graph.utils.PostRequest;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   
   public class FacebookBatchRequest extends AbstractFacebookRequest
   {
      
      protected var _params:Object;
      
      protected var _relativeURL:String;
      
      protected var _fileData:Object;
      
      protected var _accessToken:String;
      
      protected var _batch:Batch;
      
      public function FacebookBatchRequest(batch:Batch, completeCallback:Function = null)
      {
         super();
         this._batch = batch;
         _callback = completeCallback;
      }
      
      public function call(accessToken:String) : void
      {
         var _loc8_:BatchItem = null;
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         var _loc11_:String = null;
         var _loc12_:URLVariables = null;
         this._accessToken = accessToken;
         urlRequest = new URLRequest(FacebookURLDefaults.GRAPH_URL);
         urlRequest.method = URLRequestMethod.POST;
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         var _loc4_:Boolean = false;
         var _loc5_:Array = this._batch.requests;
         var _loc6_:uint = _loc5_.length;
         var _loc7_:uint = 0;
         while(_loc7_ < _loc6_)
         {
            _loc8_ = _loc5_[_loc7_];
            _loc9_ = this.extractFileData(_loc8_.params);
            _loc10_ = {
               "method":_loc8_.requestMethod,
               "relative_url":_loc8_.relativeURL
            };
            if(_loc8_.params)
            {
               if(_loc8_.params["contentType"] != undefined)
               {
                  _loc10_.contentType = _loc8_.params["contentType"];
               }
               _loc11_ = this.objectToURLVariables(_loc8_.params).toString();
               if(_loc8_.requestMethod == URLRequestMethod.GET || _loc8_.requestMethod.toUpperCase() == "DELETE")
               {
                  _loc10_.relative_url += "?" + _loc11_;
               }
               else
               {
                  _loc10_.body = _loc11_;
               }
            }
            _loc2_.push(_loc10_);
            if(_loc9_)
            {
               _loc3_.push(_loc9_);
               _loc10_.attached_files = _loc8_.params.fileName == null ? "file" + _loc7_ : _loc8_.params.fileName;
               _loc4_ = true;
            }
            else
            {
               _loc3_.push(null);
            }
            _loc7_++;
         }
         if(!_loc4_)
         {
            _loc12_ = new URLVariables();
            _loc12_.access_token = accessToken;
            _loc12_.batch = com.adobe.serialization.json.JSON.encode(_loc2_);
            urlRequest.data = _loc12_;
            loadURLLoader();
         }
         else
         {
            this.sendPostRequest(_loc2_,_loc3_);
         }
      }
      
      protected function sendPostRequest(requests:Array, files:Array) : void
      {
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc8_:ByteArray = null;
         var _loc3_:PostRequest = new PostRequest();
         _loc3_.writePostData("access_token",this._accessToken);
         _loc3_.writePostData("batch",com.adobe.serialization.json.JSON.encode(requests));
         var _loc4_:uint = requests.length;
         var _loc5_:uint = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = requests[_loc5_];
            _loc7_ = files[_loc5_];
            if(_loc7_)
            {
               if(_loc7_ is Bitmap)
               {
                  _loc7_ = (_loc7_ as Bitmap).bitmapData;
               }
               if(_loc7_ is ByteArray)
               {
                  _loc3_.writeFileData(_loc6_.attached_files,_loc7_ as ByteArray,_loc6_.contentType);
               }
               else if(_loc7_ is BitmapData)
               {
                  _loc8_ = PNGEncoder.encode(_loc7_ as BitmapData);
                  _loc3_.writeFileData(_loc6_.attached_files,_loc8_,"image/png");
               }
            }
            _loc5_++;
         }
         _loc3_.close();
         urlRequest.contentType = "multipart/form-data; boundary=" + _loc3_.boundary;
         urlRequest.data = _loc3_.getPostData();
         loadURLLoader();
      }
      
      override protected function handleDataReady() : void
      {
         var _loc4_:Object = null;
         var _loc1_:Array = _data as Array;
         var _loc2_:uint = _loc1_.length;
         var _loc3_:uint = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = com.adobe.serialization.json.JSON.decode(_data[_loc3_].body);
            _data[_loc3_].body = _loc4_;
            if((this._batch.requests[_loc3_] as BatchItem).callback != null)
            {
               (this._batch.requests[_loc3_] as BatchItem).callback(_data[_loc3_]);
            }
            _loc3_++;
         }
      }
   }
}

