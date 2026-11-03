package Account
{
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.jsonRPC.JSONRPCService;
   import Collections.Map;
   import Facade.DBFacade;
   import GameMasterDictionary.GMOffer;
   
   public class StoreServices
   {
      
      private static var mLimitedOffers:Map = new Map();
      
      public function StoreServices()
      {
         super();
      }
      
      public static function purchaseOffer(dbFacade:DBFacade, offerId:uint, successCallback:Function, errorCallback:Function, heroId:uint = 0, callRefreshOnceDone:Boolean = true) : void
      {
         var purchaseFunc:Function;
         var gmOffer:GMOffer = dbFacade.gameMaster.offerById.itemFor(offerId);
         var currentAvatarId:uint = uint(dbFacade.dbAccountInfo.activeAvatarInfo ? dbFacade.dbAccountInfo.activeAvatarInfo.id : 0);
         Logger.debug("purchaseOffer: " + offerId.toString());
         purchaseFunc = JSONRPCService.getFunction("PurchaseOffer",dbFacade.rpcRoot + "store");
         purchaseFunc(dbFacade.dbAccountInfo.id,heroId,offerId,dbFacade.validationToken,dbFacade.demographics,function(param1:*):void
         {
            dbFacade.dbAccountInfo.parseResponse(param1,callRefreshOnceDone);
            recordCoinsSpent(dbFacade,gmOffer);
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },errorCallback);
      }
      
      public static function purchaseAndOpenChest(dbFacade:DBFacade, offerId:uint, successCallback:Function, errorCallback:Function, forHero:uint, callRefreshOnceDone:Boolean = true) : void
      {
         var purchaseFunc:Function;
         var gmOffer:GMOffer = dbFacade.gameMaster.offerById.itemFor(offerId);
         var currentAvatarId:uint = uint(dbFacade.dbAccountInfo.activeAvatarInfo ? dbFacade.dbAccountInfo.activeAvatarInfo.id : 0);
         Logger.debug("purchaseChest: " + offerId.toString());
         purchaseFunc = JSONRPCService.getFunction("PurchaseChest",dbFacade.rpcRoot + "store");
         purchaseFunc(dbFacade.dbAccountInfo.id,currentAvatarId,offerId,dbFacade.validationToken,dbFacade.demographics,function(param1:*):void
         {
            dbFacade.dbAccountInfo.parseResponse(param1,callRefreshOnceDone);
            recordCoinsSpent(dbFacade,gmOffer);
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },errorCallback);
      }
      
      public static function sellWeapon(dbFacade:DBFacade, weaponInstanceId:uint, successCallback:Function, errorCallback:Function) : void
      {
         var sellItemFunc:Function = JSONRPCService.getFunction("SellWeapon",dbFacade.rpcRoot + "store");
         sellItemFunc(dbFacade.dbAccountInfo.id,weaponInstanceId,dbFacade.validationToken,function(param1:*):void
         {
            dbFacade.dbAccountInfo.parseResponse(param1);
            recordItemSold(dbFacade);
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },errorCallback);
      }
      
      public static function sellStackable(dbFacade:DBFacade, stackableInstanceId:uint, successCallback:Function, errorCallback:Function) : void
      {
         var sellItemFunc:Function = JSONRPCService.getFunction("SellStackable",dbFacade.rpcRoot + "store");
         sellItemFunc(dbFacade.dbAccountInfo.id,stackableInstanceId,dbFacade.validationToken,function(param1:*):void
         {
            dbFacade.dbAccountInfo.parseResponse(param1);
            recordItemSold(dbFacade);
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },errorCallback);
      }
      
      public static function sellPet(dbFacade:DBFacade, petInstanceId:uint, successCallback:Function, errorCallback:Function) : void
      {
         var sellPetFunc:Function = JSONRPCService.getFunction("SellPet",dbFacade.rpcRoot + "store");
         sellPetFunc(dbFacade.dbAccountInfo.id,petInstanceId,dbFacade.validationToken,function(param1:*):void
         {
            dbFacade.dbAccountInfo.parseResponse(param1);
            recordItemSold(dbFacade);
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },errorCallback);
      }
      
      private static function recordCoinsSpent(dbFacade:DBFacade, gmOffer:GMOffer) : void
      {
         if(gmOffer != null && gmOffer.CurrencyType == GMOffer.BASIC_CURRENCY)
         {
            dbFacade.steamAchievementsHelper.addValueToStatInt(gmOffer.Price,"COINS_SPENT");
         }
      }
      
      private static function recordItemSold(dbFacade:DBFacade) : void
      {
         dbFacade.steamAchievementsHelper.unlockAchievement("SELL_AN_ITEM");
         dbFacade.steamAchievementsHelper.addValueToStatInt(1,"ITEMS_SOLD");
      }
      
      public static function useAccountBooster(dbFacade:DBFacade, stackableId:uint, successCallback:Function, errorCallback:Function) : void
      {
         errorCallback = function():void
         {
         };
         var useAccountBoosterFunc:Function = JSONRPCService.getFunction("UseAccountBooster",dbFacade.rpcRoot + "store");
         useAccountBoosterFunc(dbFacade.dbAccountInfo.id,stackableId,dbFacade.validationToken,dbFacade.demographics,function(param1:*):void
         {
            dbFacade.dbAccountInfo.parseResponse(param1);
            if(successCallback != null)
            {
               successCallback();
            }
         },errorCallback);
      }
      
      public static function getWebServerTimestamp(dbFacade:DBFacade, successCallback:Function, errorCallback:Function) : void
      {
         errorCallback = function():void
         {
         };
         var getWebServerTimestampFunc:Function = JSONRPCService.getFunction("getWebServerTimestamp",dbFacade.rpcRoot + "storeGetWebServerTimestamp");
         getWebServerTimestampFunc(function(param1:Array):void
         {
            GameClock.finishSetWebServerTime(param1);
            dbFacade.regenerateGameMaster();
            if(successCallback != null)
            {
               successCallback();
            }
         },errorCallback);
      }
      
      private static function parseLimitedOfferUsage(details:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:uint = 0;
         _loc3_ = 0;
         while(_loc3_ < details.length)
         {
            _loc2_ = details[_loc3_];
            if(mLimitedOffers.hasKey(_loc2_.id))
            {
               mLimitedOffers.replaceFor(_loc2_.id,_loc2_.usage_count);
            }
            else
            {
               mLimitedOffers.add(_loc2_.id,_loc2_.usage_count);
            }
            _loc3_++;
         }
      }
      
      public static function getOfferQuantitySold(gmOffer:GMOffer) : uint
      {
         var _loc2_:* = mLimitedOffers.itemFor(gmOffer.Id);
         return _loc2_ == null ? 0 : _loc2_;
      }
      
      public static function getLimitedOfferUsage(dbFacade:DBFacade, details:*, successCallback:Function, errorCallback:Function) : void
      {
         var limitedOfferUsageFunc:Function;
         Logger.debug("getLimitedOfferUsage");
         limitedOfferUsageFunc = JSONRPCService.getFunction("GetLimitedOfferStatus",dbFacade.rpcRoot + "store");
         limitedOfferUsageFunc(dbFacade.dbAccountInfo.id,function(param1:*):void
         {
            parseLimitedOfferUsage(param1);
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },function(param1:Error):void
         {
            if(errorCallback != null)
            {
               errorCallback(param1);
            }
         });
      }
   }
}

