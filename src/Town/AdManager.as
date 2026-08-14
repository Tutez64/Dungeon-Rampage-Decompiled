package Town
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   
   public class AdManager
   {
      
      private static const MIN_AD_AVATAR_LEVEL_DFLT:int = 0;
      
      private static const TOWN_AD_X:int = 612;
      
      private static const TOWN_AD_Y:int = 276;
      
      private var mSMTownAd:SMTownAd;
      
      private var mWTTownAd:WTTownAd;
      
      private var mDBFacade:DBFacade;
      
      private var mTownStateMachine:TownStateMachine;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mTownClip:MovieClip;
      
      private var mAdButtonClip:MovieClip;
      
      private var mAdButton:UIButton;
      
      private var mShowingAdButton:Boolean;
      
      private const RESPONSE_PENDING:int = -1;
      
      private const RESPONSE_NO_ADS:int = 0;
      
      private const RESPONSE_HAS_ADS:int = 1;
      
      private var mProviderResponses:Vector.<int>;
      
      private var mAdProviders:Vector.<ITownAdProvider>;
      
      public function AdManager(dbFacade:DBFacade, townClip:MovieClip, townStateMachine:TownStateMachine)
      {
         super();
         mDBFacade = dbFacade;
         mTownClip = townClip;
         mTownStateMachine = townStateMachine;
         initialize();
      }
      
      private function initialize() : void
      {
         var _loc1_:* = 0;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mAdProviders = new Vector.<ITownAdProvider>();
         mProviderResponses = new Vector.<int>();
         _loc1_ = 0;
         while(_loc1_ < mAdProviders.length)
         {
            mProviderResponses.push(-1);
            _loc1_++;
         }
      }
      
      public function destroy() : void
      {
         Logger.debug("AdManager: destroy called");
         if(mSMTownAd)
         {
            mSMTownAd.destroy();
            mSMTownAd = null;
         }
         if(mWTTownAd)
         {
            mWTTownAd.destroy();
            mWTTownAd = null;
         }
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         clearProviderResponses();
         removeAdButton();
      }
      
      public function resetWT() : void
      {
         Logger.debug("AdManager: resetWT called");
         if(mWTTownAd)
         {
            mWTTownAd.removeWildTangentAPI();
         }
      }
      
      public function assignTownClip(townClip:MovieClip) : void
      {
         Logger.debug("AdManager: assignTownClip called");
         mTownClip = townClip;
         if(mWTTownAd)
         {
            mWTTownAd.assignTownClip(mTownClip);
         }
      }
      
      public function clearProviderResponses() : void
      {
         var _loc1_:* = 0;
         Logger.debug("AdManager: clearProviderResponses called");
         _loc1_ = 0;
         while(_loc1_ < mAdProviders.length)
         {
            mProviderResponses[_loc1_] = -1;
            _loc1_++;
         }
      }
      
      public function removeAdButton() : void
      {
         Logger.debug("AdManager: removeAdButton called");
         if(mAdButtonClip)
         {
            mTownClip.removeChild(mAdButtonClip);
            mAdButtonClip = null;
         }
         if(mAdButton)
         {
            mAdButton.destroy();
            mAdButton = null;
         }
      }
      
      private function reset(provider:uint) : void
      {
         Logger.debug("AdManager: reset called");
         if(provider < mProviderResponses.length)
         {
            mProviderResponses[provider] = -1;
         }
         if(ShouldShowAdButton())
         {
            InitializeAds();
         }
      }
      
      public function InitializeAds() : void
      {
         var _loc1_:int = 0;
         Logger.debug("AdManager: removeAdButton called");
         _loc1_ = 0;
         while(_loc1_ < mAdProviders.length)
         {
            mAdProviders[_loc1_].CheckForAds(receivedAdResponse(_loc1_));
            mAdProviders[_loc1_].SetResetCallback(reset);
            _loc1_++;
         }
      }
      
      public function ShouldShowAdButton() : Boolean
      {
         var _loc1_:int = mDBFacade.dbConfigManager.getConfigNumber("min_avlevel_for_ad",0);
         Logger.debug("minAvLevForAd= " + _loc1_);
         return _loc1_ >= 0 && !mDBFacade.isKongregatePlayer && mDBFacade.dbAccountInfo.inventoryInfo.highestAvatarLevel >= _loc1_;
      }
      
      public function TryDisplayAdButton() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Vector.<int> = new Vector.<int>();
         _loc2_ = 0;
         while(_loc2_ < mProviderResponses.length)
         {
            if(mProviderResponses[_loc2_] == 1)
            {
               Logger.debug("TryDisplayAdButton: " + _loc2_.toString() + " has ads");
               _loc1_.push(_loc2_);
            }
            _loc2_++;
         }
         var _loc3_:uint = 0;
         if(_loc1_.length > 0)
         {
            _loc3_ = Math.floor(Math.random() * _loc1_.length);
            Logger.debug("TryDisplayAdButton: random Provider " + _loc3_.toString() + ";Ad Provider picked: " + _loc1_[_loc3_]);
            ShowAdButton(_loc1_[_loc3_]);
         }
      }
      
      private function receivedAdResponse(adProvider:uint) : Function
      {
         return function(param1:Boolean):void
         {
            mProviderResponses[adProvider] = param1 ? 1 : 0;
            TryDisplayAdButton();
         };
      }
      
      private function ShowAdButton(adProvider:uint) : void
      {
         if(mAdButton != null)
         {
            removeAdButton();
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass("UI_icon_wild_tangent");
            mAdButtonClip = new _loc2_();
            mAdButtonClip.x = 612;
            mAdButtonClip.y = 276;
            mTownClip.addChild(mAdButtonClip);
            mAdButton = new UIButton(mDBFacade,mAdButtonClip.button);
            mAdButton.releaseCallback = mAdProviders[adProvider].ShowAdPlayer;
            mAdProviders[adProvider].ShowingAdButton();
         });
      }
   }
}

