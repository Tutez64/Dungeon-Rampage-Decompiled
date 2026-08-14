package com.facebook.graph.net
{
   import flash.events.DataEvent;
   import flash.events.ErrorEvent;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.FileReference;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   
   public class FacebookRequest extends AbstractFacebookRequest
   {
      
      protected var fileReference:FileReference;
      
      public function FacebookRequest()
      {
         super();
      }
      
      public function call(url:String, requestMethod:String = "GET", callback:Function = null, values:* = null) : void
      {
         _url = url;
         _requestMethod = requestMethod;
         _callback = callback;
         var _loc5_:String = url;
         urlRequest = new URLRequest(_loc5_);
         urlRequest.method = _requestMethod;
         if(values == null)
         {
            loadURLLoader();
            return;
         }
         var _loc6_:Object = extractFileData(values);
         if(_loc6_ == null)
         {
            urlRequest.data = objectToURLVariables(values);
            loadURLLoader();
            return;
         }
         if(_loc6_ is FileReference)
         {
            urlRequest.data = objectToURLVariables(values);
            urlRequest.method = URLRequestMethod.POST;
            this.fileReference = _loc6_ as FileReference;
            this.fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,this.handleFileReferenceData,false,0,true);
            this.fileReference.addEventListener(IOErrorEvent.IO_ERROR,this.handelFileReferenceError,false,0,false);
            this.fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handelFileReferenceError,false,0,false);
            this.fileReference.upload(urlRequest);
            return;
         }
         urlRequest.data = createUploadFileRequest(_loc6_,values).getPostData();
         urlRequest.method = URLRequestMethod.POST;
         loadURLLoader();
      }
      
      override public function close() : void
      {
         super.close();
         if(this.fileReference != null)
         {
            this.fileReference.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA,this.handleFileReferenceData);
            this.fileReference.removeEventListener(IOErrorEvent.IO_ERROR,this.handelFileReferenceError);
            this.fileReference.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handelFileReferenceError);
            try
            {
               this.fileReference.cancel();
            }
            catch(e:*)
            {
            }
            this.fileReference = null;
         }
      }
      
      protected function handleFileReferenceData(event:DataEvent) : void
      {
         handleDataLoad(event.data);
      }
      
      protected function handelFileReferenceError(event:ErrorEvent) : void
      {
         _success = false;
         _data = event;
         dispatchComplete();
      }
   }
}

