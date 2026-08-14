package Account
{
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMOfferDetail;
   import GameMasterDictionary.GMStackable;
   import GameMasterDictionary.GMWeaponItem;
   import UI.Inventory.UIPurchaseOfferPopup;
   import UI.Inventory.UISellItemPopup;
   import UI.Popup.DBUIOneButtonPopup;
   import UI.Popup.DBUIPopup;
   import UI.Popup.DBUITwoButtonPopup;
   import UI.Popup.UICashPage;
   import UI.Popup.UICoinPage;
   import UI.Popup.UIGiftPage;
   import UI.Popup.UIOfferPopup;
   import UI.Popup.UIStorageFullPopup;
   import org.as3commons.collections.Map;
   
   public class StoreServicesController
   {
      
      public static const MAX_INVENTORY_SLOTS:uint = 120;
      
      public static const CONFIRM_PREMIUM_PURCHASES:Boolean = false;
      
      public static const CONFIRM_BASIC_PURCHASES:Boolean = false;
      
      public static const CONFIRM_ALREADY_OWN:Boolean = true;
      
      public static const BASIC_KEY_OFFERS:Vector.<uint> = new <uint>[51201,51203,51205];
      
      public static const PREMIUM_KEY_OFFERS:Vector.<uint> = new <uint>[51211,51212,51213];
      
      public static const COIN_OFFERS:Vector.<uint> = new <uint>[51102,51103,51104];
      
      public static const STORAGE_OFFERS:Vector.<uint> = new <uint>[51401,51402,51403];
      
      public static const GIFT_OFFERS:Vector.<uint> = new <uint>[51301,51399,51398];
      
      public static const HERO_OFFERS:Vector.<uint> = new <uint>[51012,51013,51014,51015];
      
      public function StoreServicesController()
      {
         super();
      }
      
      public static function getOfferMetrics(dbFacade:DBFacade, gmOffer:GMOffer) : Object
      {
         var _loc3_:Object = {};
         _loc3_.offerId = gmOffer.Id;
         _loc3_.offerName = gmOffer.getDisplayName(dbFacade.gameMaster,Locale.getString("SHOP_UNKNOWN_NAME"));
         _loc3_.price = gmOffer.Price;
         _loc3_.currencyType = gmOffer.CurrencyType;
         return _loc3_;
      }
      
      private static function getSellMetrics(dbFacade:DBFacade, info:InventoryBaseInfo) : Object
      {
         var _loc3_:Object = {};
         _loc3_.itemId = info.gmId;
         _loc3_.itemName = info.Name.toUpperCase();
         _loc3_.price = info.sellCoins;
         _loc3_.currencyType = "BASIC";
         return _loc3_;
      }
      
      public static function tryBuyOffer(dbFacade:DBFacade, gmOffer:GMOffer, buySuccessCallback:Function, forHeroId:uint = 0) : void
      {
         dbFacade.metrics.log("ShopPurchaseTry",getOfferMetrics(dbFacade,gmOffer));
         if(StoreServicesController.stackableLimitWouldOverflow(dbFacade,gmOffer))
         {
            StoreServicesController.stackableLimitPopup(dbFacade,gmOffer);
         }
         else if(StoreServicesController.weaponInventoryWouldOverflow(dbFacade,gmOffer))
         {
            StoreServicesController.weaponInventoryFullPopup(dbFacade,gmOffer);
         }
         else if(StoreServicesController.weaponStorageWouldOverflow(dbFacade,gmOffer))
         {
            StoreServicesController.weaponStorageLimitPopup(dbFacade,gmOffer);
         }
         else if(alreadyOwns(dbFacade,gmOffer))
         {
            StoreServicesController.confirmAlreadyOwnsPopup(dbFacade,gmOffer,buySuccessCallback,forHeroId);
         }
         else if(StoreServicesController.getOfferLevelReq(dbFacade,gmOffer) > dbFacade.dbAccountInfo.highestAvatarLevel)
         {
            StoreServicesController.notHighEnoughLevelPopup(dbFacade,gmOffer);
         }
         else if(weaponRestrictedAndHeroNotOwned(dbFacade,gmOffer))
         {
            StoreServicesController.doesntOwnHeroPopup(dbFacade,gmOffer);
         }
         else if(gmOffer.CurrencyType == "PREMIUM" && dbFacade.dbAccountInfo.premiumCurrency < gmOffer.Price)
         {
            StoreServicesController.showCashPage(dbFacade,"tryBuyOffer",gmOffer,buySuccessCallback,null,forHeroId);
         }
         else if(gmOffer.CurrencyType == "BASIC" && dbFacade.dbAccountInfo.basicCurrency < gmOffer.Price)
         {
            StoreServicesController.notEnoughCoinsPopup(dbFacade,gmOffer);
         }
         else if(false && gmOffer.CurrencyType == "PREMIUM")
         {
            StoreServicesController.confirmPurchasePopup(dbFacade,gmOffer,buySuccessCallback,forHeroId);
         }
         else if(false && gmOffer.CurrencyType == "BASIC")
         {
            StoreServicesController.confirmPurchasePopup(dbFacade,gmOffer,buySuccessCallback,forHeroId);
         }
         else
         {
            StoreServicesController.buyOffer(dbFacade,gmOffer,buySuccessCallback,forHeroId);
         }
      }
      
      public static function trySellItem(dbFacade:DBFacade, info:InventoryBaseInfo, successCallback:Function = null, errorCallback:Function = null) : void
      {
         dbFacade.metrics.log("TrySell",StoreServicesController.getSellMetrics(dbFacade,info));
         if(info.isEquipped)
         {
            StoreServicesController.itemIsEquippedPopup(dbFacade,info,successCallback,errorCallback);
         }
         else
         {
            StoreServicesController.confirmSell(dbFacade,info,successCallback,errorCallback);
         }
      }
      
      public static function getOfferLevelReq(dbFacade:DBFacade, gmOffer:GMOffer) : uint
      {
         if(gmOffer.IsBundle)
         {
            return 0;
         }
         var _loc3_:GMOfferDetail = gmOffer.Details[0];
         if(_loc3_.Level)
         {
            return _loc3_.Level;
         }
         return 0;
      }
      
      public static function getWeaponMastertype(dbFacade:DBFacade, gmOffer:GMOffer) : String
      {
         var _loc3_:GMWeaponItem = null;
         if(gmOffer.IsBundle)
         {
            return null;
         }
         var _loc4_:GMOfferDetail = gmOffer.Details[0];
         if(_loc4_.WeaponId)
         {
            _loc3_ = dbFacade.gameMaster.weaponItemById.itemFor(_loc4_.WeaponId);
            return _loc3_.MasterType;
         }
         return null;
      }
      
      public static function getHeroId(dbFacade:DBFacade, gmOffer:GMOffer) : uint
      {
         if(gmOffer.IsBundle)
         {
            return 0;
         }
         var _loc3_:GMOfferDetail = gmOffer.Details[0];
         return _loc3_.HeroId;
      }
      
      public static function getSkinId(dbFacade:DBFacade, gmOffer:GMOffer) : uint
      {
         if(gmOffer.IsBundle)
         {
            return 0;
         }
         var _loc3_:GMOfferDetail = gmOffer.Details[0];
         return _loc3_.SkinId;
      }
      
      public static function alreadyOwns(dbFacade:DBFacade, gmOffer:GMOffer) : Boolean
      {
         var _loc3_:DBInventoryInfo = dbFacade.dbAccountInfo.inventoryInfo;
         for each(var _loc4_:GMOfferDetail in gmOffer.Details)
         {
            if(_loc4_.HeroId && _loc3_.ownsItem(_loc4_.HeroId))
            {
               return true;
            }
            if(_loc4_.PetId && _loc3_.ownsItem(_loc4_.PetId))
            {
               return true;
            }
            if(_loc4_.WeaponId && _loc3_.ownsExactWeapon(_loc4_))
            {
               return true;
            }
            if(_loc4_.SkinId && _loc3_.ownsItem(_loc4_.SkinId))
            {
               return true;
            }
         }
         return false;
      }
      
      public static function weaponRestrictedAndHeroNotOwned(dbFacade:DBFacade, gmOffer:GMOffer) : Boolean
      {
         var _loc3_:uint = requiredHeroForWeapon(dbFacade,gmOffer);
         if(_loc3_ && !dbFacade.dbAccountInfo.inventoryInfo.ownsItem(_loc3_))
         {
            return true;
         }
         return false;
      }
      
      public static function weaponInventoryWouldOverflow(dbFacade:DBFacade, gmOffer:GMOffer) : Boolean
      {
         var _loc4_:uint = 0;
         for each(var _loc5_:GMOfferDetail in gmOffer.Details)
         {
            if(_loc5_.WeaponId != 0)
            {
               _loc4_++;
            }
            else if(_loc5_.ChestId != 0 && (_loc5_.ChestId != 60005 && _loc5_.ChestId != 60006))
            {
               _loc4_++;
            }
         }
         return _loc4_ && _loc4_ + dbFacade.dbAccountInfo.unequippedWeaponCount > dbFacade.dbAccountInfo.inventoryLimitWeapons;
      }
      
      public static function stackableLimitWouldOverflow(dbFacade:DBFacade, gmOffer:GMOffer) : Boolean
      {
         var _loc8_:* = null;
         var _loc4_:* = 0;
         var _loc9_:* = 0;
         var _loc5_:* = 0;
         var _loc3_:* = 0;
         var _loc6_:GMStackable = null;
         var _loc7_:Map = new Map();
         for each(_loc8_ in gmOffer.Details)
         {
            _loc4_ = _loc8_.StackableId;
            if(_loc4_)
            {
               if(_loc7_.hasKey(_loc4_))
               {
                  _loc9_ = uint(_loc7_.itemFor(_loc4_));
                  _loc7_.replaceFor(_loc4_,_loc9_ + _loc8_.StackableCount);
               }
               else
               {
                  _loc7_.add(_loc4_,_loc8_.StackableCount);
               }
            }
         }
         for each(_loc8_ in gmOffer.Details)
         {
            _loc4_ = _loc8_.StackableId;
            if(_loc4_)
            {
               _loc5_ = dbFacade.dbAccountInfo.inventoryInfo.getStackCount(_loc4_);
               _loc3_ = uint(_loc7_.itemFor(_loc4_));
               _loc6_ = dbFacade.gameMaster.stackableById.itemFor(_loc4_);
               if(_loc5_ + _loc3_ > _loc6_.StackLimit)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public static function weaponStorageWouldOverflow(dbFacade:DBFacade, gmOffer:GMOffer) : Boolean
      {
         var _loc5_:uint = 0;
         for each(var _loc4_:GMOfferDetail in gmOffer.Details)
         {
            _loc5_ += _loc4_.WeaponSlots;
         }
         if(_loc5_ == 0)
         {
            return false;
         }
         return _loc5_ + dbFacade.dbAccountInfo.inventoryLimitWeapons > 120;
      }
      
      public static function requiredHeroForWeapon(dbFacade:DBFacade, gmOffer:GMOffer) : uint
      {
         return 0;
      }
      
      public static function itemIsEquippedPopup(dbFacade:DBFacade, info:InventoryBaseInfo, buySuccessCallback:Function, errorCallback:Function) : void
      {
         var popup:UISellItemPopup;
         dbFacade.metrics.log("ItemEquippedDuringSell",StoreServicesController.getSellMetrics(dbFacade,info));
         popup = new UISellItemPopup(dbFacade,Locale.getString("ITEM_CONFIRM_SELL"),info,Locale.getString("CANCEL"),null,Locale.getString("ITEM_SELL_BUTTON"),function():void
         {
            sellItem(dbFacade,info,buySuccessCallback,errorCallback);
         });
         MemoryTracker.track(popup,"UISellItemPopup - created in StoreServicesController.itemIsEquippedPopup()");
      }
      
      public static function confirmSell(dbFacade:DBFacade, info:InventoryBaseInfo, buySuccessCallback:Function, errorCallback:Function) : void
      {
         var popup:UISellItemPopup;
         dbFacade.metrics.log("ConfirmSell",StoreServicesController.getSellMetrics(dbFacade,info));
         popup = new UISellItemPopup(dbFacade,Locale.getString("ITEM_CONFIRM_SELL"),info,Locale.getString("CANCEL"),null,Locale.getString("ITEM_SELL_BUTTON"),function():void
         {
            sellItem(dbFacade,info,buySuccessCallback,errorCallback);
         });
         MemoryTracker.track(popup,"UISellItemPopup - created in StoreServicesController.confirmSell()");
      }
      
      public static function notEnoughCashPopup(dbFacade:DBFacade, gmOffer:GMOffer) : void
      {
         var popup:DBUITwoButtonPopup;
         dbFacade.metrics.log("ShopPurchaseNotEnoughCash",getOfferMetrics(dbFacade,gmOffer));
         popup = new DBUITwoButtonPopup(dbFacade,Locale.getString("SHOP_NOT_ENOUGH_CASH_TITLE"),Locale.getString("SHOP_NOT_ENOUGH_CASH_MESSAGE"),Locale.getString("SHOP_GET_CASH"),function():void
         {
            showCashPage(dbFacade,"notEnoughGemsPopup");
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"DBUITwoButtonPopup - created in StoreServicesController.notEnoughCashPopup()");
      }
      
      public static function notEnoughCoinsPopup(dbFacade:DBFacade, gmOffer:GMOffer) : void
      {
         var popup:DBUITwoButtonPopup;
         dbFacade.metrics.log("ShopPurchaseNotEnoughCoins",getOfferMetrics(dbFacade,gmOffer));
         popup = new DBUITwoButtonPopup(dbFacade,Locale.getString("SHOP_NOT_ENOUGH_COINS_TITLE"),Locale.getString("SHOP_NOT_ENOUGH_COINS_MESSAGE"),Locale.getString("SHOP_GET_COINS"),function():void
         {
            showCoinPage(dbFacade);
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"DBUITwoButtonPopup - created in StoreServicesController.notEnoughCoinsPopup()");
      }
      
      public static function notHighEnoughLevelPopup(dbFacade:DBFacade, gmOffer:GMOffer) : void
      {
         var popup:DBUITwoButtonPopup;
         dbFacade.metrics.log("ShopPurchaseNotHighLevel",getOfferMetrics(dbFacade,gmOffer));
         popup = new DBUITwoButtonPopup(dbFacade,Locale.getString("SHOP_NOT_HIGH_LEVEL_TITLE"),Locale.getString("SHOP_NOT_HIGH_LEVEL_MESSAGE"),Locale.getString("SHOP_BUY_ANYWAYS"),function():void
         {
            buyOffer(dbFacade,gmOffer,null);
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"DBUITwoButtonPopup - created in StoreServicesController.notHighEnoughLevelPopup()");
      }
      
      public static function weaponInventoryFullPopup(dbFacade:DBFacade, gmOffer:GMOffer) : void
      {
         var popup:DBUITwoButtonPopup;
         dbFacade.metrics.log("ShopPurchaseWeaponInventoryFull",getOfferMetrics(dbFacade,gmOffer));
         popup = new UIStorageFullPopup(dbFacade,Locale.getString("SHOP_WEAPON_INVENTORY_FULL_TITLE"),Locale.getString("SHOP_WEAPON_INVENTORY_FULL_MESSAGE"),Locale.getString("SHOP_GET_STORAGE"),function():void
         {
            showStoragePage(dbFacade);
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"UIStorageFullPopup - created in StoreServicesController.weaponInventoryFullPopup()");
      }
      
      public static function stackableLimitPopup(dbFacade:DBFacade, gmOffer:GMOffer) : void
      {
         dbFacade.metrics.log("ShopPurchaseStackLimit",getOfferMetrics(dbFacade,gmOffer));
         var _loc3_:DBUIOneButtonPopup = new DBUIOneButtonPopup(dbFacade,Locale.getString("SHOP_STACK_LIMIT_TITLE"),Locale.getString("SHOP_STACK_LIMIT_MESSAGE"),Locale.getString("CANCEL"),null);
         MemoryTracker.track(_loc3_,"DBUIOneButtonPopup - created in StoreServicesController.stackableLimitPopup()");
      }
      
      public static function weaponStorageLimitPopup(dbFacade:DBFacade, gmOffer:GMOffer) : void
      {
         dbFacade.metrics.log("ShopPurchaseWeaponStorageLimit",getOfferMetrics(dbFacade,gmOffer));
         var _loc3_:DBUIOneButtonPopup = new DBUIOneButtonPopup(dbFacade,Locale.getString("SHOP_WEAPON_STORAGE_LIMIT_TITLE"),Locale.getString("SHOP_WEAPON_STORAGE_LIMIT_MESSAGE"),Locale.getString("CANCEL"),null);
         MemoryTracker.track(_loc3_,"DBUIOneButtonPopup - created in StoreServicesController.weaponStorageLimitPopup()");
      }
      
      public static function doesntOwnHeroPopup(dbFacade:DBFacade, gmOffer:GMOffer) : void
      {
         var popup:DBUITwoButtonPopup;
         dbFacade.metrics.log("ShopPurchaseDoesntOwnHero",getOfferMetrics(dbFacade,gmOffer));
         popup = new DBUITwoButtonPopup(dbFacade,Locale.getString("SHOP_HERO_NOT_OWNED"),null,Locale.getString("SHOP_BUY_ANYWAYS"),function():void
         {
            buyOffer(dbFacade,gmOffer,null);
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"DBUITwoButtonPopup - created in StoreServicesController.doesntOwnHeroPopup()");
      }
      
      public static function confirmPurchasePopup(dbFacade:DBFacade, gmOffer:GMOffer, buySuccessCallback:Function, forHeroId:uint = 0) : void
      {
         var popup:UIPurchaseOfferPopup;
         dbFacade.metrics.log("ShopPurchaseConfirm",getOfferMetrics(dbFacade,gmOffer));
         popup = new UIPurchaseOfferPopup(dbFacade,"purchase_popup",Locale.getString("SHOP_CONFIRM_BUY"),gmOffer,Locale.getString("SHOP_BUY"),function():void
         {
            buyOffer(dbFacade,gmOffer,buySuccessCallback,forHeroId);
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"UIPurchaseOfferPopup - created in StoreServicesController.confirmPurchasePopup()");
      }
      
      public static function confirmAlreadyOwnsPopup(dbFacade:DBFacade, gmOffer:GMOffer, buySuccessCallback:Function, forHeroId:uint = 0) : void
      {
         var popup:UIPurchaseOfferPopup;
         dbFacade.metrics.log("ShopPurchaseConfirmAlreadyOwns",getOfferMetrics(dbFacade,gmOffer));
         popup = new UIPurchaseOfferPopup(dbFacade,"purchase_popup",Locale.getString("SHOP_CONFIRM_DUPLICATE_BUY"),gmOffer,Locale.getString("SHOP_BUY_ANOTHER"),function():void
         {
            buyOffer(dbFacade,gmOffer,buySuccessCallback,forHeroId);
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"UIPurchaseOfferPopup - created in StoreServicesController.confirmAlreadyOwnsPopup()");
      }
      
      public static function waitForPurchaseServicePopup(dbFacade:DBFacade) : DBUIPopup
      {
         var _loc2_:DBUIPopup = new DBUIPopup(dbFacade,Locale.getString("SHOP_PURCHASING"),null,false);
         MemoryTracker.track(_loc2_,"DBUIPopup - created in StoreServicesController.waitForPurchaseServicePopup()");
         return _loc2_;
      }
      
      public static function waitForSellServicePopup(dbFacade:DBFacade) : DBUIPopup
      {
         var _loc2_:DBUIPopup = new DBUIPopup(dbFacade,Locale.getString("SHOP_SELLING"),null,false);
         MemoryTracker.track(_loc2_,"DBUIPopup - created in StoreServicesController.waitForSellServicePopup()");
         return _loc2_;
      }
      
      public static function buyOffer(dbFacade:DBFacade, gmOffer:GMOffer, buySuccessCallback:Function, forHeroId:uint = 0) : void
      {
         var popup:DBUIPopup;
         var previousBucketsWeapon:int;
         dbFacade.metrics.log("ShopPurchase",getOfferMetrics(dbFacade,gmOffer));
         popup = StoreServicesController.waitForPurchaseServicePopup(dbFacade);
         previousBucketsWeapon = int(dbFacade.dbAccountInfo.inventoryInfo.storageLimitWeapon);
         StoreServices.purchaseOffer(dbFacade,gmOffer.Id,function(param1:*):void
         {
            var _loc2_:int = 0;
            popup.destroy();
            if(dbFacade.steamAchievementsManager)
            {
               if(gmOffer.CurrencyType == "BASIC")
               {
                  dbFacade.steamAchievementsManager.addToStatInt("SPEND_COINS_INT",gmOffer.Price);
               }
               if(gmOffer.Tab == "WEAPON")
               {
                  dbFacade.steamAchievementsManager.setAchievement("PURCHASE_WEAPON_FIRST_TIME");
               }
            }
            StoreServices.getLimitedOfferUsage(dbFacade,param1,null,null);
            if(buySuccessCallback != null)
            {
               buySuccessCallback(param1);
               _loc2_ = int(dbFacade.dbAccountInfo.inventoryInfo.storageLimitWeapon);
               if(previousBucketsWeapon < _loc2_ && dbFacade.steamAchievementsManager)
               {
                  dbFacade.steamAchievementsManager.setAchievement("STORAGE_EXPAND_FIRST_TIME");
                  dbFacade.steamAchievementsManager.setMaxStorageStat(previousBucketsWeapon,_loc2_);
               }
            }
         },function(param1:Error):void
         {
            popup.destroy();
            showErrorPopup(dbFacade,param1);
         },forHeroId);
      }
      
      public static function sellItem(dbFacade:DBFacade, info:InventoryBaseInfo, buySuccessCallback:Function = null, errorCallback:Function = null) : void
      {
         var popup:DBUIPopup;
         var sellFunc:Function;
         dbFacade.metrics.log("SellItem",StoreServicesController.getSellMetrics(dbFacade,info));
         popup = StoreServicesController.waitForSellServicePopup(dbFacade);
         if(info is ItemInfo)
         {
            sellFunc = StoreServices.sellWeapon;
         }
         else if(info is StackableInfo)
         {
            sellFunc = StoreServices.sellStackable;
         }
         else
         {
            if(!(info is PetInfo))
            {
               Logger.error("Unknown item type in SellItem");
               return;
            }
            sellFunc = StoreServices.sellPet;
         }
         sellFunc(dbFacade,info.databaseId,function(param1:*):void
         {
            popup.destroy();
            if(buySuccessCallback != null)
            {
               buySuccessCallback(param1);
            }
         },function(param1:Error):void
         {
            popup.destroy();
            showErrorPopup(dbFacade,param1);
            if(errorCallback != null)
            {
               errorCallback();
            }
         });
      }
      
      public static function useAccountBooster(dbFacade:DBFacade, info:InventoryBaseInfo, useSuccessCallback:Function = null, errorCallback:Function = null) : void
      {
         StoreServices.useAccountBooster(dbFacade,info.gmId,useSuccessCallback,errorCallback);
      }
      
      public static function getWebServerTimestamp(dbFacade:DBFacade, useSuccessCallback:Function = null, errorCallback:Function = null) : void
      {
         trace("getWebServerTimestamp");
         StoreServices.getWebServerTimestamp(dbFacade,useSuccessCallback,errorCallback);
      }
      
      public static function showErrorPopup(dbFacade:DBFacade, error:Error) : void
      {
         dbFacade.metrics.log("ShopError",{"error":error.errorID});
         dbFacade.errorPopup(Locale.getString("SHOP_ERROR") + ": " + error.errorID,error.message);
      }
      
      public static function showCashPage(dbFacade:DBFacade, openedFrom:String, attemptedOffer:GMOffer = null, successCallback:Function = null, closeCallback:Function = null, forHeroId:uint = 0) : void
      {
         var _loc7_:Object = {};
         _loc7_.openedFrom = openedFrom;
         dbFacade.metrics.log("ShopCashPagePresented",_loc7_);
         var _loc8_:UICashPage = new UICashPage(dbFacade);
         MemoryTracker.track(_loc8_,"UICashPage - created in StoreServicesController.showCashPage()");
      }
      
      public static function showCoinPage(dbFacade:DBFacade) : void
      {
         dbFacade.metrics.log("ShopCoinPagePresented");
         var _loc2_:UICoinPage = new UICoinPage(dbFacade);
         MemoryTracker.track(_loc2_,"UICoinPage - created in StoreServicesController.showCoinPage()");
      }
      
      public static function showStoragePage(dbFacade:DBFacade) : void
      {
         dbFacade.metrics.log("ShopStoragePagePresented");
         var _loc2_:UIOfferPopup = new UIOfferPopup(dbFacade,Locale.getString("SHOP_STORAGE_PAGE_TITLE"),STORAGE_OFFERS,null,null,true,false);
         MemoryTracker.track(_loc2_,"UIOfferPopup - created in StoreServicesController.showStoragePage()");
      }
      
      public static function showGiftPage(dbFacade:DBFacade, buyCallback:Function) : void
      {
         dbFacade.metrics.log("ShopGiftPagePresented");
         var _loc3_:UIGiftPage = new UIGiftPage(dbFacade,buyCallback,null);
         MemoryTracker.track(_loc3_,"UIGiftPage - created in StoreServicesController.showGiftPage()");
      }
   }
}

