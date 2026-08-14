package Brain.MouseScrollPlugin
{
   public class BrowserInfo
   {
      
      public static const WIN_PLATFORM:String = "win";
      
      public static const MAC_PLATFORM:String = "mac";
      
      public static const SAFARI_AGENT:String = "safari";
      
      public static const OPERA_AGENT:String = "opera";
      
      public static const IE_AGENT:String = "msie";
      
      public static const MOZILLA_AGENT:String = "mozilla";
      
      public static const CHROME_AGENT:String = "chrome";
      
      private var _platform:String = "undefined";
      
      private var _browser:String = "undefined";
      
      private var _version:String = "undefined";
      
      public function BrowserInfo(browserInfoObj:Object, platformObj:Object, agent:String)
      {
         super();
         if(!browserInfoObj || !platformObj || !agent)
         {
            return;
         }
         _version = browserInfoObj.version;
         for(var _loc5_:String in browserInfoObj)
         {
            if(_loc5_ != "version")
            {
               if(browserInfoObj[_loc5_] == true)
               {
                  _browser = _loc5_;
                  break;
               }
            }
         }
         for(var _loc4_:String in platformObj)
         {
            if(platformObj[_loc4_] == true)
            {
               _platform = _loc4_;
            }
         }
      }
      
      public function get platform() : String
      {
         return _platform;
      }
      
      public function get browser() : String
      {
         return _browser;
      }
      
      public function get version() : String
      {
         return _version;
      }
   }
}

