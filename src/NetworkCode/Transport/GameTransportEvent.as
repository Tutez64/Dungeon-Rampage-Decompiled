package NetworkCode.Transport
{
   import flash.events.Event;
   import flash.utils.ByteArray;
   
   public class GameTransportEvent extends Event
   {
      
      public static const CONNECTED:String = "gameTransportConnected";
      
      public static const DATA:String = "gameTransportData";
      
      public static const CLOSED:String = "gameTransportClosed";
      
      public static const FAILED:String = "gameTransportFailed";
      
      public static const TEXT:String = "gameTransportText";
      
      public static const RECONNECTING:String = "gameTransportReconnecting";
      
      public static const RECONNECT_ATTEMPT:String = "gameTransportReconnectAttempt";
      
      public static const RESUMED:String = "gameTransportResumed";
      
      public static const INITIATOR_SERVER:String = "server";
      
      public static const INITIATOR_CLIENT:String = "client";
      
      public static const INITIATOR_TRANSPORT:String = "transport";
      
      public static const INITIATOR_UNKNOWN:String = "unknown";
      
      public static const CLOSE_CLIENT_ABANDONED:int = 4000;
      
      public static const SOCKET_ERROR_CLOSED:uint = 601;
      
      public static const SOCKET_ERROR_IO:uint = 602;
      
      public static const SOCKET_ERROR_SECURITY:uint = 603;
      
      public var bytes:ByteArray;
      
      public var code:int = 0;
      
      public var reason:String = "";
      
      public var initiator:String = "unknown";
      
      public var errorCode:uint = 0;
      
      public var text:String = "";
      
      public var certificateStatus:String = "";
      
      public var certificateDetail:String = "";
      
      public var attempts:int = 0;
      
      public var elapsedMilliseconds:int = 0;
      
      public var graceMilliseconds:int = 0;
      
      public var gaveUp:Boolean = false;
      
      public var terminal:Boolean = false;
      
      public function GameTransportEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
      
      public static function connectedEvent() : GameTransportEvent
      {
         return new GameTransportEvent("gameTransportConnected");
      }
      
      public static function dataEvent(bytes:ByteArray) : GameTransportEvent
      {
         var _loc2_:GameTransportEvent = new GameTransportEvent("gameTransportData");
         _loc2_.bytes = bytes;
         return _loc2_;
      }
      
      public static function closedEvent(code:int, reason:String, initiator:String) : GameTransportEvent
      {
         var _loc4_:GameTransportEvent = new GameTransportEvent("gameTransportClosed");
         _loc4_.code = code;
         _loc4_.reason = reason == null ? "" : reason;
         _loc4_.initiator = initiator == null ? "unknown" : initiator;
         return _loc4_;
      }
      
      public static function failedEvent(errorCode:uint, text:String, certificateStatus:String = "", certificateDetail:String = "") : GameTransportEvent
      {
         var _loc5_:GameTransportEvent = new GameTransportEvent("gameTransportFailed");
         _loc5_.errorCode = errorCode;
         _loc5_.text = text == null ? "" : text;
         _loc5_.certificateStatus = certificateStatus == null ? "" : certificateStatus;
         _loc5_.certificateDetail = certificateDetail == null ? "" : certificateDetail;
         return _loc5_;
      }
      
      public static function textEvent(text:String) : GameTransportEvent
      {
         var _loc2_:GameTransportEvent = new GameTransportEvent("gameTransportText");
         _loc2_.text = text == null ? "" : text;
         return _loc2_;
      }
      
      public static function reconnectingEvent(code:int, reason:String, elapsedMilliseconds:int) : GameTransportEvent
      {
         var _loc4_:GameTransportEvent = new GameTransportEvent("gameTransportReconnecting");
         _loc4_.code = code;
         _loc4_.reason = reason == null ? "" : reason;
         _loc4_.initiator = "server";
         _loc4_.elapsedMilliseconds = elapsedMilliseconds;
         return _loc4_;
      }
      
      public static function reconnectAttemptEvent(attempts:int, elapsedMilliseconds:int, graceMilliseconds:int) : GameTransportEvent
      {
         var _loc4_:GameTransportEvent = new GameTransportEvent("gameTransportReconnectAttempt");
         _loc4_.attempts = attempts;
         _loc4_.elapsedMilliseconds = elapsedMilliseconds;
         _loc4_.graceMilliseconds = graceMilliseconds;
         return _loc4_;
      }
      
      public static function resumedEvent(attempts:int, elapsedMilliseconds:int) : GameTransportEvent
      {
         var _loc3_:GameTransportEvent = new GameTransportEvent("gameTransportResumed");
         _loc3_.attempts = attempts;
         _loc3_.elapsedMilliseconds = elapsedMilliseconds;
         return _loc3_;
      }
      
      override public function toString() : String
      {
         return formatToString("GameTransportEvent","type","code","reason","initiator","errorCode","text","certificateStatus","certificateDetail","attempts","elapsedMilliseconds","graceMilliseconds");
      }
   }
}

