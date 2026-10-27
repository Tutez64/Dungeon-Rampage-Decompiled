package Config
{
   import Brain.Logger.Logger;
   import flash.events.*;
   import flash.net.*;
   
   public class ServiceDiscoveryLoader
   {
      
      private var mOnComplete:Function;
      
      private var mLoader:URLLoader;
      
      private var mHttpStatus:int = 0;
      
      private var mUrl:String;
      
      public function ServiceDiscoveryLoader(serviceDiscoveryUrl:String, onComplete:Function)
      {
         super();
         mOnComplete = onComplete;
         mUrl = serviceDiscoveryUrl + "/game-status/service-discovery";
         mLoader = new URLLoader();
         mLoader.addEventListener("httpResponseStatus",onResponseStatus);
         mLoader.addEventListener("complete",onCompleted);
         mLoader.addEventListener("ioError",onError);
         mLoader.addEventListener("securityError",onError);
         mLoader.addEventListener("certificateError",onError);
         mLoader.load(new URLRequest(mUrl));
      }
      
      public static function maintenanceMessage(result:Object) : String
      {
         var _loc2_:String = result ? result.maintenanceMessage as String : null;
         return _loc2_ && /\S/.test(_loc2_) ? _loc2_ : null;
      }
      
      private function onResponseStatus(event:HTTPStatusEvent) : void
      {
         mHttpStatus = event.status;
      }
      
      private function onCompleted(event:Event) : void
      {
         var _loc3_:Object = null;
         var _loc2_:String = event.target && (event.target as URLLoader).data ? (event.target as URLLoader).data as String : null;
         Logger.debugch("HTTP","Service discovery response (HTTP " + mHttpStatus + ") from " + mUrl + ": " + _loc2_);
         if(mHttpStatus < 100 || mHttpStatus >= 400)
         {
            Logger.warn("Service discovery returned HTTP " + mHttpStatus + " from " + mUrl);
            complete(null,1500,mHttpStatus.toString());
            return;
         }
         var _loc4_:Boolean = false;
         try
         {
            _loc3_ = JSON.parse(_loc2_);
            _loc4_ = _loc3_ && _loc3_.webServicesUrl && _loc3_.gameSocketAddress && _loc3_.gameSocketPort;
         }
         catch(e:Error)
         {
            Logger.fatal("Service discovery returned unparseable response from " + mUrl + ": " + e.message);
            complete(null,1503,"Invalid service discovery JSON: " + e.message);
            return;
         }
         if(_loc4_)
         {
            Logger.info("Service discovery resolved from " + mUrl);
            complete(_loc3_,0,"");
            return;
         }
         Logger.fatal("Service discovery response missing required fields from " + mUrl + ": " + _loc2_);
         complete(null,1503,"Service discovery response missing required fields");
      }
      
      private function onError(event:Event) : void
      {
         Logger.warn("Service discovery request failed (HTTP " + mHttpStatus + ") from " + mUrl);
         complete(null,1503,"");
      }
      
      private function complete(result:Object, errorCode:int, diagnostic:String) : void
      {
         var _loc4_:Function = mOnComplete;
         mOnComplete = null;
         cleanup();
         if(_loc4_ != null)
         {
            _loc4_(result,errorCode,diagnostic);
         }
      }
      
      private function cleanup() : void
      {
         if(mLoader == null)
         {
            return;
         }
         mLoader.removeEventListener("httpResponseStatus",onResponseStatus);
         mLoader.removeEventListener("complete",onCompleted);
         mLoader.removeEventListener("ioError",onError);
         mLoader.removeEventListener("securityError",onError);
         mLoader.removeEventListener("certificateError",onError);
         mLoader = null;
      }
   }
}

