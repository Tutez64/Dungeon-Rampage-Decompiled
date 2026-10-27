package NetworkCode.Transport
{
   public final class TransportFailureText
   {
      
      public static const NO_SERVER_TEXT:String = "NotSet";
      
      public static const NOTHING_KNOWN:String = "the connection closed without a code or a reason";
      
      private static const MAX_WIRE_CHARACTERS:int = 160;
      
      private static const MAX_RUNTIME_CHARACTERS:int = 512;
      
      private static const ELLIPSIS:String = "...";
      
      public static const CODE_SUPERSEDED:int = 4006;
      
      public static const SUPERSEDED_TEXT:String = "this account connected from elsewhere";
      
      public static const CODE_UNAUTHENTICATED:int = 4008;
      
      public static const UNAUTHENTICATED_TEXT:String = "This login was not accepted.";
      
      public static const CODE_ATTACHED_IDLE:int = 4011;
      
      public static const ATTACHED_IDLE_TEXT:String = "the connection sent nothing for too long";
      
      public function TransportFailureText()
      {
         super();
         throw new Error("TransportFailureText is a set of functions, not a thing to build.");
      }
      
      public static function forClose(event:GameTransportEvent) : String
      {
         if(event.code == 4006)
         {
            return "this account connected from elsewhere (" + event.code + ")";
         }
         if(event.code == 4008)
         {
            return "This login was not accepted. (" + event.code + ")";
         }
         if(event.code == 4011)
         {
            return "the connection sent nothing for too long (" + event.code + ")";
         }
         var _loc2_:String = tidy(event.reason,160);
         if(event.code != 0 && _loc2_ != "")
         {
            return _loc2_ + " (" + event.code + ")";
         }
         if(event.code != 0)
         {
            return "closed (" + event.code + ")";
         }
         return _loc2_;
      }
      
      public static function forFailure(event:GameTransportEvent) : String
      {
         var _loc2_:String = tidy(event.text,512);
         return _loc2_ == "" ? "the connection failed without a reason" : _loc2_;
      }
      
      public static function forGiveUp(event:GameTransportEvent) : String
      {
         var _loc2_:int = Math.round(event.elapsedMilliseconds / 1000);
         var _loc3_:String = forClose(event);
         return "could not reconnect after " + _loc2_ + " s" + (_loc3_ == "" ? "" : ": " + _loc3_);
      }
      
      public static function withServerText(serverText:String, detail:String) : String
      {
         var _loc3_:String = tidy(serverText,512);
         if(_loc3_ == "NotSet")
         {
            _loc3_ = "";
         }
         if(_loc3_ == "")
         {
            return detail == null || detail == "" ? "the connection closed without a code or a reason" : detail;
         }
         return detail == null || detail == "" ? _loc3_ : _loc3_ + "\n" + detail;
      }
      
      public static function tidy(text:String, maxCharacters:int) : String
      {
         if(text == null)
         {
            return "";
         }
         var _loc5_:String = text.replace(/[\x00-\x1f\x7f\x85  ]+/g," ").replace(/^\s+|\s+$/g,"");
         if(_loc5_.length <= maxCharacters)
         {
            return _loc5_;
         }
         var _loc3_:String = _loc5_.substr(0,maxCharacters - "...".length);
         var _loc4_:Number = _loc3_.charCodeAt(_loc3_.length - 1);
         if(_loc4_ >= 55296 && _loc4_ <= 56319)
         {
            _loc3_ = _loc3_.substr(0,_loc3_.length - 1);
         }
         return _loc3_ + "...";
      }
   }
}

