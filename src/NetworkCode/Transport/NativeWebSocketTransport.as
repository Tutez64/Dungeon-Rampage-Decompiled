package NetworkCode.Transport
{
   import Brain.Logger.Logger;
   import air.net.WebSocket;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.utils.ByteArray;
   
   public class NativeWebSocketTransport extends EventDispatcher implements IGameTransport
   {
      
      public static const FORMAT_STRING:uint = 1;
      
      public static const FORMAT_BINARY:uint = 2;
      
      private static const CLOSE_NORMAL:int = 1000;
      
      private static const EVENT_CONNECT:String = "connect";
      
      private static const EVENT_DATA:String = "websocketData";
      
      private static const EVENT_CLOSE:String = "close";
      
      private static const EVENT_CERTIFICATE_ERROR:String = "certificateError";
      
      private var mUrl:String;
      
      private var mEnforceServerCertificate:Boolean;
      
      private var mNative:Object;
      
      private var mConnected:Boolean = false;
      
      private var mFinished:Boolean = false;
      
      public function NativeWebSocketTransport(url:String, enforceServerCertificate:Boolean)
      {
         super();
         mUrl = url;
         mEnforceServerCertificate = enforceServerCertificate;
      }
      
      private static function readStringData(payloadEvent:Object) : String
      {
         try
         {
            if(payloadEvent.stringData != null)
            {
               return String(payloadEvent.stringData);
            }
         }
         catch(stringDataError:Error)
         {
         }
         try
         {
            if(payloadEvent.data != null)
            {
               return String(payloadEvent.data);
            }
         }
         catch(dataError:Error)
         {
         }
         return null;
      }
      
      private static function readErrorText(event:Event) : String
      {
         try
         {
            return String(Object(event).text);
         }
         catch(error:Error)
         {
            var _loc4_:String = event.type;
         }
         return _loc4_;
      }
      
      private static function absorbLateError(event:Event) : void
      {
         Logger.debugch("WS","A native WebSocket transport ignored an error raised after it finished: " + event);
      }
      
      public function get name() : String
      {
         return "nativeWss " + mUrl;
      }
      
      public function get connected() : Boolean
      {
         return mConnected;
      }
      
      public function get supportsSessions() : Boolean
      {
         return true;
      }
      
      public function connect() : void
      {
         if(mNative != null || mFinished)
         {
            return;
         }
         try
         {
            mNative = new WebSocket();
            mNative.addEventListener("connect",onNativeConnect);
            mNative.addEventListener("websocketData",onNativeData);
            mNative.addEventListener("close",onNativeClose);
            mNative.addEventListener("ioError",onNativeIoError);
            mNative.addEventListener("securityError",onNativeSecurityError);
            mNative.addEventListener("certificateError",onNativeCertificateError);
            mNative.connect(mUrl);
         }
         catch(error:Error)
         {
            fail(602,error.message);
         }
      }
      
      public function send(bytes:ByteArray) : void
      {
         if(!connected || bytes == null || bytes.length == 0)
         {
            return;
         }
         try
         {
            bytes.position = 0;
            mNative.sendMessage(2,bytes);
         }
         catch(error:Error)
         {
            Logger.warnch("WS","NativeWebSocketTransport send failed: " + error.message);
            fail(602,error.message);
         }
      }
      
      public function sendText(text:String) : void
      {
         if(!connected || text == null)
         {
            return;
         }
         try
         {
            mNative.sendMessage(1,text);
         }
         catch(error:Error)
         {
            Logger.warnch("WS","NativeWebSocketTransport sendText failed: " + error.message);
            fail(602,error.message);
         }
      }
      
      public function close() : void
      {
         closeWith(1000);
      }
      
      public function abandon() : void
      {
         closeWith(4000);
      }
      
      private function closeWith(closeStatus:int) : void
      {
         mFinished = true;
         mConnected = false;
         var _loc2_:Object = mNative;
         releaseNative();
         if(_loc2_ != null)
         {
            try
            {
               _loc2_.close(closeStatus);
            }
            catch(error:Error)
            {
            }
         }
      }
      
      private function onNativeConnect(event:Event) : void
      {
         mConnected = true;
         dispatchEvent(GameTransportEvent.connectedEvent());
      }
      
      private function onNativeData(event:Event) : void
      {
         var _loc3_:ByteArray = null;
         var _loc2_:Object = null;
         var _loc4_:* = 0;
         var _loc5_:String = null;
         try
         {
            _loc2_ = Object(event);
            _loc4_ = uint(_loc2_.format);
            if(_loc4_ == 1)
            {
               _loc5_ = readStringData(_loc2_);
               if(_loc5_ == null)
               {
                  Logger.warnch("WS","NativeWebSocketTransport got a text frame it cannot read the payload of.");
                  return;
               }
            }
            else
            {
               if(_loc4_ != 2)
               {
                  Logger.warnch("WS","NativeWebSocketTransport ignoring a frame of format " + _loc4_);
                  return;
               }
               _loc3_ = _loc2_.data as ByteArray;
            }
         }
         catch(error:Error)
         {
            Logger.error("NativeWebSocketTransport cannot read a websocketData event: " + error.message);
            fail(602,"Unreadable websocketData event: " + error.message);
            return;
         }
         if(_loc5_ != null)
         {
            dispatchEvent(GameTransportEvent.textEvent(_loc5_));
            return;
         }
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return;
         }
         _loc3_.endian = "littleEndian";
         _loc3_.position = 0;
         dispatchEvent(GameTransportEvent.dataEvent(_loc3_));
      }
      
      private function onNativeClose(event:Event) : void
      {
         if(mFinished)
         {
            return;
         }
         var _loc2_:int = readCloseReason();
         mFinished = true;
         mConnected = false;
         releaseNative();
         dispatchEvent(GameTransportEvent.closedEvent(_loc2_,"","server"));
      }
      
      private function onNativeIoError(event:IOErrorEvent) : void
      {
         fail(602,event.text);
      }
      
      private function onNativeSecurityError(event:SecurityErrorEvent) : void
      {
         fail(603,event.text);
      }
      
      private function onNativeCertificateError(event:Event) : void
      {
         var _loc2_:String = readErrorText(event);
         if(mEnforceServerCertificate)
         {
            Logger.warnch("WS","NativeWebSocketTransport rejecting server certificate: " + _loc2_);
            fail(603,"Server certificate rejected: " + _loc2_);
            return;
         }
         Logger.warnch("WS","NativeWebSocketTransport accepting an invalid server certificate because EnforceServerCertificate is false: " + _loc2_);
         if(event.cancelable)
         {
            event.preventDefault();
         }
      }
      
      private function readCloseReason() : int
      {
         try
         {
            return int(mNative.closeReason);
         }
         catch(error:Error)
         {
            var _loc3_:int = 0;
         }
         return _loc3_;
      }
      
      private function fail(errorCode:uint, text:String) : void
      {
         if(mFinished)
         {
            return;
         }
         closeWith(4000);
         dispatchEvent(GameTransportEvent.failedEvent(errorCode,text));
      }
      
      private function releaseNative() : void
      {
         if(mNative != null)
         {
            mNative.removeEventListener("connect",onNativeConnect);
            mNative.removeEventListener("websocketData",onNativeData);
            mNative.removeEventListener("close",onNativeClose);
            mNative.removeEventListener("ioError",onNativeIoError);
            mNative.removeEventListener("securityError",onNativeSecurityError);
            mNative.removeEventListener("certificateError",onNativeCertificateError);
            mNative.addEventListener("ioError",absorbLateError);
            mNative.addEventListener("securityError",absorbLateError);
            mNative.addEventListener("certificateError",absorbLateError);
         }
         mNative = null;
      }
   }
}

