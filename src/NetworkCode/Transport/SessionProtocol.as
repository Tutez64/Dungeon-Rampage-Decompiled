package NetworkCode.Transport
{
   public final class SessionProtocol
   {
      
      public static const CODE_UNKNOWN_SESSION:int = 4004;
      
      private static const MAX_SAFE_COUNT:Number = 9007199254740991;
      
      private static const MAX_POD_ORDINAL:int = 99999;
      
      private static const MAX_CONTROL_FRAME_CHARACTERS:int = 4096;
      
      private static const UNRECOVERABLE_CODES:Array = [4001,4002,4003,4005,4006,4007,4008,4011];
      
      private static const CLOSE_REASONS:Object = {
         4001:"session buffer full",
         4002:"bad control message",
         4003:"session expired",
         4004:"unknown session",
         4005:"replay window exceeded",
         4006:"superseded",
         4007:"upstream ended",
         4008:"unauthenticated",
         4011:"attached idle"
      };
      
      public function SessionProtocol()
      {
         super();
      }
      
      public static function helloMessageFor(credential:SessionCredential) : String
      {
         return "{\"t\":\"hello\",\"v\":1" + fieldsOf(credential) + "}";
      }
      
      public static function ackMessage(received:Number) : String
      {
         return "{\"t\":\"ack\",\"recv\":" + formatCount(received) + "}";
      }
      
      public static function resumeMessageFor(token:String, received:Number, why:String, credential:SessionCredential) : String
      {
         return "{\"t\":\"resume\",\"session\":\"" + token + "\",\"recv\":" + formatCount(received) + whyField(why) + fieldsOf(credential) + "}";
      }
      
      public static function parseControl(text:String) : Object
      {
         var _loc2_:Object = null;
         if(text == null || text.length == 0 || text.length > 4096)
         {
            return null;
         }
         try
         {
            _loc2_ = JSON.parse(text);
            if(_loc2_ == null || _loc2_.t == null)
            {
               return null;
            }
            return _loc2_;
         }
         catch(error:Error)
         {
            var _loc6_:* = null;
         }
         return _loc6_;
      }
      
      public static function isPlausibleToken(token:String) : Boolean
      {
         return token != null && /^[A-Za-z0-9_\-]{16,128}$/.test(token);
      }
      
      public static function isWholeCount(value:Number) : Boolean
      {
         return !isNaN(value) && value >= 0 && value == Math.floor(value) && value <= 9007199254740991;
      }
      
      public static function isPlausiblePod(pod:Number) : Boolean
      {
         return !isNaN(pod) && pod >= 0 && pod <= 99999 && pod == Math.floor(pod);
      }
      
      public static function isUnrecoverable(code:int) : Boolean
      {
         return UNRECOVERABLE_CODES.indexOf(code) >= 0;
      }
      
      public static function closeReasonFor(code:int) : String
      {
         return String(CLOSE_REASONS[code]);
      }
      
      private static function whyField(why:String) : String
      {
         return why == null || why == "" ? "" : ",\"why\":\"" + why + "\"";
      }
      
      private static function fieldsOf(credential:SessionCredential) : String
      {
         return credential?.jsonFields;
      }
      
      private static function formatCount(value:Number) : String
      {
         return value.toFixed(0);
      }
   }
}

