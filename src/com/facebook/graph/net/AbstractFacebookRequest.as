package com.facebook.graph.net
{
   import com.adobe.images.PNGEncoder;
   import com.adobe.serialization.json.JSON;
   import com.facebook.graph.utils.PostRequest;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.FileReference;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   
   public class AbstractFacebookRequest
   {
      
      protected var urlLoader:URLLoader;
      
      protected var urlRequest:URLRequest;
      
      protected var _rawResult:String;
      
      protected var _data:Object;
      
      protected var _success:Boolean;
      
      protected var _url:String;
      
      protected var _requestMethod:String;
      
      protected var _callback:Function;
      
      public function AbstractFacebookRequest()
      {
         super();
      }
      
      public function get rawResult() : String
      {
         return this._rawResult;
      }
      
      public function get success() : Boolean
      {
         return this._success;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function callURL(callback:Function, url:String = "", locale:String = null) : void
      {
         var _loc4_:URLVariables = null;
         this._callback = callback;
         this.urlRequest = new URLRequest(url.length ? url : this._url);
         if(locale)
         {
            _loc4_ = new URLVariables();
            _loc4_.locale = locale;
            this.urlRequest.data = _loc4_;
         }
         this.loadURLLoader();
      }
      
      public function set successCallback(value:Function) : void
      {
         this._callback = value;
      }
      
      protected function isValueFile(value:Object) : Boolean
      {
         return value is FileReference || value is Bitmap || value is BitmapData || value is ByteArray;
      }
      
      protected function objectToURLVariables(values:Object) : URLVariables
      {
         var _loc3_:String = null;
         var _loc2_:URLVariables = new URLVariables();
         if(values == null)
         {
            return _loc2_;
         }
         for(_loc3_ in values)
         {
            _loc2_[_loc3_] = values[_loc3_];
         }
         return _loc2_;
      }
      
      public function close() : void
      {
         if(this.urlLoader != null)
         {
            this.urlLoader.removeEventListener(Event.COMPLETE,this.handleURLLoaderComplete);
            this.urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.handleURLLoaderIOError);
            this.urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleURLLoaderSecurityError);
            try
            {
               this.urlLoader.close();
            }
            catch(e:*)
            {
            }
            this.urlLoader = null;
         }
      }
      
      protected function loadURLLoader() : void
      {
         this.urlLoader = new URLLoader();
         this.urlLoader.addEventListener(Event.COMPLETE,this.handleURLLoaderComplete,false,0,false);
         this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR,this.handleURLLoaderIOError,false,0,true);
         this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleURLLoaderSecurityError,false,0,true);
         this.urlLoader.load(this.urlRequest);
      }
      
      protected function handleURLLoaderComplete(event:Event) : void
      {
         this.handleDataLoad(this.urlLoader.data);
      }
      
      protected function handleDataLoad(result:Object, dispatchCompleteEvent:Boolean = true) : void
      {
         this._rawResult = result as String;
         this._success = true;
         try
         {
            this._data = com.adobe.serialization.json.JSON.decode(this._rawResult);
         }
         catch(e:*)
         {
            _data = _rawResult;
            _success = false;
         }
         this.handleDataReady();
         if(dispatchCompleteEvent)
         {
            this.dispatchComplete();
         }
      }
      
      protected function handleDataReady() : void
      {
      }
      
      protected function dispatchComplete() : void
      {
         if(this._callback != null)
         {
            this._callback(this);
         }
         this.close();
      }
      
      protected function handleURLLoaderIOError(event:IOErrorEvent) : void
      {
         this._success = false;
         this._rawResult = (event.target as URLLoader).data;
         if(this._rawResult != "")
         {
            try
            {
               this._data = com.adobe.serialization.json.JSON.decode(this._rawResult);
            }
            catch(e:*)
            {
               _data = {
                  "type":"Exception",
                  "message":_rawResult
               };
            }
         }
         else
         {
            this._data = event;
         }
         this.dispatchComplete();
      }
      
      protected function handleURLLoaderSecurityError(event:SecurityErrorEvent) : void
      {
         this._success = false;
         this._rawResult = (event.target as URLLoader).data;
         try
         {
            this._data = com.adobe.serialization.json.JSON.decode((event.target as URLLoader).data);
         }
         catch(e:*)
         {
            _data = event;
         }
         this.dispatchComplete();
      }
      
      protected function extractFileData(values:Object) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(values == null)
         {
            return null;
         }
         if(this.isValueFile(values))
         {
            _loc2_ = values;
         }
         else if(values != null)
         {
            for(_loc3_ in values)
            {
               if(this.isValueFile(values[_loc3_]))
               {
                  _loc2_ = values[_loc3_];
                  delete values[_loc3_];
                  break;
               }
            }
         }
         return _loc2_;
      }
      
      protected function createUploadFileRequest(fileData:Object, values:Object = null) : PostRequest
      {
         var _loc4_:String = null;
         var _loc5_:ByteArray = null;
         var _loc3_:PostRequest = new PostRequest();
         if(values)
         {
            for(_loc4_ in values)
            {
               _loc3_.writePostData(_loc4_,values[_loc4_]);
            }
         }
         if(fileData is Bitmap)
         {
            fileData = (fileData as Bitmap).bitmapData;
         }
         if(fileData is ByteArray)
         {
            _loc3_.writeFileData(values.fileName,fileData as ByteArray,values.contentType);
         }
         else if(fileData is BitmapData)
         {
            _loc5_ = PNGEncoder.encode(fileData as BitmapData);
            _loc3_.writeFileData(values.fileName,_loc5_,"image/png");
         }
         _loc3_.close();
         this.urlRequest.contentType = "multipart/form-data; boundary=" + _loc3_.boundary;
         return _loc3_;
      }
      
      public function toString() : String
      {
         return this.urlRequest.url + (this.urlRequest.data == null ? "" : "?" + unescape(this.urlRequest.data.toString()));
      }
   }
}

