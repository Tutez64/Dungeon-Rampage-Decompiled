package starling.assets
{
   import flash.events.ErrorEvent;
   import flash.events.HTTPStatusEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   import starling.utils.execute;
   
   public class DataLoader
   {
      
      private static const HTTP_RESPONSE_STATUS:String = "httpResponseStatus";
      
      private static const CERTIFICATE_ERROR:String = "certificateError";
      
      private var _urlLoaders:Dictionary;
      
      public function DataLoader()
      {
         super();
         _urlLoaders = new Dictionary(true);
      }
      
      private static function getHttpHeader(headers:Array, headerName:String) : String
      {
         if(headers)
         {
            for each(var _loc3_:Object in headers)
            {
               if(_loc3_.name == headerName)
               {
                  return _loc3_.value;
               }
            }
         }
         return null;
      }
      
      public function load(url:String, onComplete:Function, onError:Function, onProgress:Function = null) : void
      {
         var message:String;
         var onHttpResponseStatus:* = function(param1:HTTPStatusEvent):void
         {
            httpStatus = param1.status;
            mimeType = getHttpHeader(param1["responseHeaders"],"Content-Type");
         };
         var onLoadError:* = function(param1:ErrorEvent):void
         {
            cleanup();
            message = param1.type + " - " + param1.text;
            execute(onError,message);
         };
         var onLoadProgress:* = function(param1:ProgressEvent):void
         {
            if(onProgress != null && param1.bytesTotal > 0)
            {
               onProgress(param1.bytesLoaded / param1.bytesTotal);
            }
         };
         var onLoadComplete:* = function(param1:Object):void
         {
            cleanup();
            if(httpStatus < 400)
            {
               execute(onComplete,loader.data,mimeType);
            }
            else
            {
               execute(onError,"Unexpected HTTP status \'" + httpStatus + "\'. URL: " + request.url,httpStatus);
            }
         };
         var cleanup:* = function():void
         {
            loader.removeEventListener("ioError",onLoadError);
            loader.removeEventListener("securityError",onLoadError);
            loader.removeEventListener("certificateError",onLoadError);
            loader.removeEventListener("httpResponseStatus",onHttpResponseStatus);
            loader.removeEventListener("progress",onLoadProgress);
            loader.removeEventListener("complete",onLoadComplete);
            delete _urlLoaders[loader];
         };
         var mimeType:String = null;
         var httpStatus:int = 0;
         var request:URLRequest = new URLRequest(url);
         var loader:URLLoader = new URLLoader();
         loader.dataFormat = "binary";
         loader.addEventListener("ioError",onLoadError);
         loader.addEventListener("securityError",onLoadError);
         loader.addEventListener("certificateError",onLoadError);
         loader.addEventListener("httpResponseStatus",onHttpResponseStatus);
         loader.addEventListener("progress",onLoadProgress);
         loader.addEventListener("complete",onLoadComplete);
         loader.load(request);
         _urlLoaders[loader] = true;
      }
      
      public function close() : void
      {
         for(var _loc1_ in _urlLoaders)
         {
            try
            {
               _loc1_.close();
            }
            catch(e:Error)
            {
            }
         }
         _urlLoaders = new Dictionary(true);
      }
   }
}

