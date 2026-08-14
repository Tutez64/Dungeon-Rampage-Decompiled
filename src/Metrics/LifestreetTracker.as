package Metrics
{
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import com.adobe.serialization.json.JSON;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class LifestreetTracker
   {
      
      private static var LIFESTREET_NODE_COMPLETED_URL:String = "https://pix.lfstmedia.com/_tracker/455?__noscript=true&propname=%7Cadvertiser_offer_id&propvalue=125041";
      
      private static var LIFESTREET_CAMPAIGN:String = "lifestreet";
      
      public static var IS_FUNCTIONAL:Boolean = true;
      
      public static var LIFESTREET_NODE_ID:uint = 50007;
      
      public static var LIFESTREET_TUTORIAL_COMPLETED:String = "LIFESTREET_TUTORIAL_COMPLETED";
      
      public static var LIFESTREET_NODE_COMPLETED:String = "LIFESTREET_NODE_COMPLETED";
      
      public function LifestreetTracker()
      {
         super();
      }
      
      public static function isLifestreetUser(dbFacade:DBFacade) : Boolean
      {
         if(!dbFacade.isFacebookPlayer)
         {
            return false;
         }
         var _loc2_:String = dbFacade.dbConfigManager.getConfigString("AncestorCampaign","");
         Logger.info("Ancestor Campaign:" + _loc2_);
         return _loc2_.indexOf(LIFESTREET_CAMPAIGN) == 0;
      }
      
      private static function callURL(dbFacade:DBFacade, url:String) : void
      {
         var loader:URLLoader;
         var facebookIdUrl:String = "https://graph.facebook.com/" + dbFacade.dbAccountInfo.facebookId;
         var fbURLRequest:URLRequest = new URLRequest(facebookIdUrl);
         fbURLRequest.method = "GET";
         loader = new URLLoader(fbURLRequest);
         loader.addEventListener("ioError",function():void
         {
         });
         loader.addEventListener("securityError",function():void
         {
         });
         loader.addEventListener("complete",function(param1:Event):void
         {
            var _loc2_:URLRequest = null;
            Logger.debug("Lifestreet graph event received");
            var _loc3_:URLLoader = URLLoader(param1.target);
            var _loc4_:Object = com.adobe.serialization.json.JSON.decode(_loc3_.data);
            if(_loc4_.gender == "male")
            {
               _loc2_ = new URLRequest(url);
               _loc2_.method = "GET";
               Logger.debug("LifestreetTracker: " + _loc2_.url);
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("addLifestreetNodeCompletionTracker");
               }
            }
         });
         loader.load(fbURLRequest);
      }
      
      public static function nodeCompleted(dbFacade:DBFacade) : void
      {
         callURL(dbFacade,LIFESTREET_NODE_COMPLETED_URL);
         dbFacade.dbAccountInfo.dbAccountParams.setLifestreetParam();
      }
   }
}

