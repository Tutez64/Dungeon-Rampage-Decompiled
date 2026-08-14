package Town
{
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class SMTownAd implements ITownAdProvider
   {
      
      private static const TOWN_AD_X:int = 612;
      
      private static const TOWN_AD_Y:int = 276;
      
      private var mDBFacade:DBFacade;
      
      private var mAdsAvailable:Boolean = false;
      
      private var mResponseCallback:Function = null;
      
      private var mResetCallback:Function = null;
      
      private var mInitialized:Boolean = false;
      
      public function SMTownAd(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
      }
      
      public function destroy() : void
      {
         mInitialized = false;
         mResponseCallback = null;
         mResetCallback = null;
      }
      
      public function CheckForAds(callback:Function) : void
      {
         var accountId:String;
         var query:String;
         var request:URLRequest;
         var urlLoader:URLLoader;
         if(!mDBFacade.isKongregatePlayer)
         {
            mResponseCallback = callback;
            accountId = mDBFacade.accountId.toString();
            Logger.debug("SM ad query for account : " + accountId);
            query = "https://ads.sele.co/v2/videos_for/" + accountId + "/on/DungeonRampage_5205_5077.xml";
            request = new URLRequest(query);
            urlLoader = new URLLoader(request);
            urlLoader.addEventListener("ioError",function(param1:Event):void
            {
               Logger.warn("IOError on scores logging: " + param1.toString());
            });
            urlLoader.addEventListener("securityError",function(param1:Event):void
            {
               Logger.warn("SecurityError on scores logging: " + param1.toString());
            });
            urlLoader.addEventListener("complete",SelectableMediaResponse);
            urlLoader.load(request);
         }
         else
         {
            callback(false);
         }
      }
      
      private function SelectableMediaResponse(e:Event) : void
      {
         var _loc2_:XML = new XML(e.target.data);
         mAdsAvailable = false;
         if(_loc2_.hasOwnProperty("available"))
         {
            Logger.debug("SM json available: " + _loc2_.available.toString());
            mAdsAvailable = _loc2_.available.toString() == "true";
            Logger.warn("SM ad available: " + mAdsAvailable.toString());
         }
         else
         {
            Logger.warn("Unexpected format in SM Response. Response: " + _loc2_.toXMLString());
         }
         if(mResponseCallback != null)
         {
            mResponseCallback(mAdsAvailable);
         }
      }
      
      public function SetResetCallback(callback:Function) : void
      {
         mResetCallback = callback;
      }
      
      public function ShowingAdButton() : void
      {
         mDBFacade.metrics.log("SMTownButton");
         Logger.debug("SM Ad set up");
      }
      
      public function ShowAdPlayer() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(mAdsAvailable && ExternalInterface.available)
         {
            _loc1_ = mDBFacade.accountId.toString();
            _loc2_ = mDBFacade.facebookAccountInfo != null ? mDBFacade.facebookAccountInfo.gender : "";
            Logger.warn("Showing SM ads");
            if(!mInitialized)
            {
               ExternalInterface.addCallback("SMInitialized",InitializedCallback);
               ExternalInterface.addCallback("SMOpenedPlayer",OpenedPlayerCallback);
               ExternalInterface.addCallback("SMClosedPlayer",ClosedPlayerCallback);
               ExternalInterface.addCallback("SMAdCompleted",AdCompletedCallback);
               mInitialized = true;
            }
            ExternalInterface.call("DoSelectableMedia",_loc1_,_loc2_);
         }
         else
         {
            Logger.warn("Attempted to show SM ads when none were available");
         }
      }
      
      private function InitializedCallback() : void
      {
         Logger.debug("SM: InitializedCallback");
      }
      
      private function OpenedPlayerCallback() : void
      {
         Logger.debug("SM: OpenedPlayerCallback");
         mDBFacade.metrics.log("SMOpenedPlayer");
      }
      
      private function ClosedPlayerCallback() : void
      {
         Logger.debug("SM: ClosedPlayerCallback");
         mDBFacade.metrics.log("SMClosedPlayer");
         mResetCallback(1);
      }
      
      private function AdCompletedCallback() : void
      {
         Logger.debug("SM: AdCompletedCallback");
         mDBFacade.metrics.log("SMAdCompleted");
         mDBFacade.dbAccountInfo.getUsersFullAccountInfo();
      }
   }
}

