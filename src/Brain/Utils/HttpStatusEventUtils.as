package Brain.Utils
{
   import flash.events.HTTPStatusEvent;
   import flash.net.URLRequestHeader;
   
   public class HttpStatusEventUtils
   {
      
      public function HttpStatusEventUtils()
      {
         super();
      }
      
      public static function getTraceId(e:HTTPStatusEvent) : String
      {
         if(!e || !e.responseHeaders)
         {
            return null;
         }
         for each(var _loc2_:URLRequestHeader in e.responseHeaders)
         {
            if(_loc2_.name.toLowerCase() == "x-trace-id")
            {
               return _loc2_.value;
            }
         }
         return null;
      }
   }
}

