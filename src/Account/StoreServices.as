package Account
{
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.jsonRPC.JSONRPCService;
   import Facade.DBFacade;
   import FacebookAPI.DBFacebookAPIController;
   import GameMasterDictionary.GMCashDeal;
   import GameMasterDictionary.GMOffer;
   import Metrics.PixelTracker;
   import com.facebook.graph.Facebook;
   import com.maccherone.json.JSON;
   import flash.external.ExternalInterface;
   import org.as3commons.collections.Map;
   
   public class StoreServices
   {
      
      private static var mLimitedOffers:Map = new Map();
      
      public function StoreServices()
      {
         super();
      }
      
      public static function createCashDealOrder(dbFacade:DBFacade, dealId:uint, dealMultiplier:Number, successCallback:Function, errorCallback:Function) : void
      {
         if(dbFacade.isFacebookPlayer)
         {
            createCashDealOrderFB(dbFacade,dealId,dealMultiplier,successCallback,errorCallback);
         }
         else if(dbFacade.isKongregatePlayer)
         {
            createCashDealOrderKongregate(dbFacade,dealId,dealMultiplier,successCallback,errorCallback);
         }
         else
         {
            createCashDealOrderCashbox(dbFacade,dealId,dealMultiplier,successCallback,errorCallback);
         }
      }
      
      public static function createCashDealOrderCashbox(dbFacade:DBFacade, dealId:uint, dealMultiplier:Number, successCallback:Function, errorCallback:Function) : void
      {
         var createCashDealOrderCBFunc:Function;
         Logger.debug("createCashDealOrderCashbox " + dbFacade.dbAccountInfo.id.toString() + " dealId: " + dealId.toString());
         createCashDealOrderCBFunc = JSONRPCService.getFunction("CreateOrderCB",dbFacade.rpcRoot + "store");
         createCashDealOrderCBFunc(dbFacade.dbAccountInfo.id,dealId,dbFacade.demographics,function(param1:*):void
         {
            var error:Error;
            var orderId:uint;
            var details:* = param1;
            dbFacade.metrics.log("CreateCashDealOrderCB");
            if(details == null)
            {
               Logger.debug("createCashDealOrderCB success: but detail null, possibly a local build");
               error = new Error("dev box");
               errorCallback(error);
               return;
            }
            if(!ExternalInterface.available)
            {
               Logger.warn("GBS: ExternalInterface unavailable");
               return;
            }
            Logger.debug("createCashDealOrderCB success: " + details.toString());
            orderId = uint(details.id);
            ExternalInterface.addCallback("cashboxOrderResult",function(param1:int, param2:String):void
            {
               var _loc3_:GMCashDeal = null;
               if(param1)
               {
                  dbFacade.metrics.log("CashboxPaySuccess");
                  _loc3_ = dbFacade.gameMaster.cashDealById.itemFor(dealId);
                  if(_loc3_)
                  {
                     PixelTracker.purchaseEvent(dbFacade,_loc3_.Price * dealMultiplier);
                  }
                  Logger.debug("CashboxPaySuccess: " + param2);
                  StoreServices.orderCompleteCallback(dbFacade,"success",orderId);
                  if(successCallback != null)
                  {
                     successCallback(details);
                  }
               }
               else
               {
                  dbFacade.metrics.log("CashboxPayFail");
                  Logger.debug("CashboxPayFail: " + param2);
                  StoreServices.orderCompleteCallback(dbFacade,"failure",orderId);
                  if(errorCallback != null)
                  {
                     errorCallback(new Error("FBCashboxPayFail",701));
                  }
               }
            });
            ExternalInterface.call("payinit",details.id,details.deal_id);
         },errorCallback);
      }
      
      public static function createCashDealOrderFB(dbFacade:DBFacade, dealId:uint, dealMultiplier:Number, successCallback:Function, errorCallback:Function) : void
      {
         var createCashDealOrderFunc:Function;
         Logger.debug("createCashDealOrder: " + dbFacade.dbAccountInfo.id.toString() + " dealId: " + dealId.toString());
         createCashDealOrderFunc = JSONRPCService.getFunction("CreateOrder",dbFacade.rpcRoot + "store");
         createCashDealOrderFunc(dbFacade.dbAccountInfo.id,dealId,dbFacade.demographics,1,function(param1:*):void
         {
            var orderId:uint;
            var og_url:String;
            var params:Object;
            var details:* = param1;
            dbFacade.metrics.log("CreateCashDealOrder");
            Logger.debug("createCashDealOrder success id: " + details.id + "; details: " + details.toString());
            orderId = uint(details.id);
            og_url = dbFacade.downloadRoot + "general/gem-" + details.price + ".html";
            params = {
               "action":"purchaseitem",
               "request_id":orderId,
               "product":og_url,
               "quantity":1
            };
            Facebook.ui("pay",params,function(param1:Object):void
            {
               var fulfillOrderFBFunc:Function;
               var gmCashDeal:GMCashDeal;
               var response:Object = param1;
               var responseJson:String = com.maccherone.json.JSON.encode(response);
               if(response.status == "completed" && response.payment_id)
               {
                  fulfillOrderFBFunc = JSONRPCService.getFunction("FulfillOrderFB",dbFacade.rpcRoot + "store");
                  fulfillOrderFBFunc(dbFacade.dbAccountInfo.id,response.request_id,response.payment_id,response.status,response.currency,response.amount,dbFacade.validationToken,function(param1:*):void
                  {
                     dbFacade.metrics.log("FacebookUIPaySuccess");
                     StoreServices.orderCompleteCallback(dbFacade,"success",param1.reference_id);
                  });
                  gmCashDeal = dbFacade.gameMaster.cashDealById.itemFor(dealId);
                  if(gmCashDeal)
                  {
                     PixelTracker.purchaseEvent(dbFacade,gmCashDeal.Price * dealMultiplier);
                  }
                  Logger.debug("FB UI success: " + responseJson);
                  if(successCallback != null)
                  {
                     successCallback(details);
                  }
               }
               else
               {
                  dbFacade.metrics.log("FacebookUIPayFail");
                  Logger.debug("FB UI fail: " + responseJson);
                  StoreServices.orderCompleteCallback(dbFacade,"failure",orderId);
                  if(errorCallback != null)
                  {
                     errorCallback(new Error("FB UI Fail",701));
                  }
               }
            });
         },errorCallback);
      }
      
      public static function createCashDealOrderKongregate(dbFacade:DBFacade, dealId:uint, dealMultiplier:Number, successCallback:Function, errorCallback:Function) : void
      {
         var createCashDealOrderFunc:Function;
         Logger.debug("createCashDealOrderKong: " + dbFacade.dbAccountInfo.id.toString() + " dealId: " + dealId.toString());
         createCashDealOrderFunc = JSONRPCService.getFunction("CreateOrder",dbFacade.rpcRoot + "store");
         createCashDealOrderFunc(dbFacade.dbAccountInfo.id,dealId,dbFacade.demographics,2,function(param1:*):void
         {
            var orderId:uint;
            var details:* = param1;
            dbFacade.metrics.log("CreateCashDealOrderKongregate");
            orderId = uint(details.id);
            Logger.debug("createCashDealOrderKongregate success: " + orderId);
            dbFacade.kongregateAPI.mtx.purchaseItems([String(dealId)],function(param1:Object):void
            {
               var gmCashDeal:GMCashDeal;
               var settleCashDealOrderFunc:Function;
               var response:Object = param1;
               if(response.success)
               {
                  dbFacade.metrics.log("KongregateUIPaySuccess");
                  gmCashDeal = dbFacade.gameMaster.cashDealById.itemFor(dealId);
                  if(gmCashDeal)
                  {
                     PixelTracker.purchaseEvent(dbFacade,gmCashDeal.Price * dealMultiplier);
                  }
                  Logger.debug("Kongregate Pay success");
                  settleCashDealOrderFunc = JSONRPCService.getFunction("purchase",dbFacade.rpcRoot + "kongregate");
                  settleCashDealOrderFunc(dbFacade.dbAccountInfo.id,orderId,function(param1:*):void
                  {
                     Logger.debug("Kongregate order settled");
                     StoreServices.orderCompleteCallback(dbFacade,"success",orderId);
                     Logger.debug("Kongregate Pay called orderCompleteCallback");
                     if(successCallback != null)
                     {
                        successCallback(param1);
                     }
                  },function(param1:*):void
                  {
                     Logger.debug("Kongregate order settle failed");
                  });
               }
               else
               {
                  dbFacade.metrics.log("KongregateUIPayFail");
                  Logger.debug("Kongregate Pay fail");
                  StoreServices.orderCompleteCallback(dbFacade,"failure",orderId);
                  if(errorCallback != null)
                  {
                     errorCallback(new Error("Kongregate Pay Fail",701));
                  }
               }
            });
         },errorCallback);
      }
      
      public static function orderCompleteCallback(dbFacade:DBFacade, result:String, orderId:uint) : void
      {
         Logger.debug("orderCompleteCallback: orderId: " + orderId.toString() + " result: " + result);
         if(result == "success")
         {
            Logger.debug("Refreshing currency");
            dbFacade.dbAccountInfo.getUsersFullAccountInfo();
         }
      }
      
      public static function earnCredits(dbFacade:DBFacade, callback:Function) : void
      {
         if(!dbFacade.isFacebookPlayer)
         {
            return;
         }
         DBFacebookAPIController.earnCredits(dbFacade,callback);
      }
      
      private static function callJSEarnCurrency(dbFacade:DBFacade, thirdPartyId:String) : void
      {
         ExternalInterface.call("earnCredits",thirdPartyId);
      }
      
      public static function purchaseOffer(dbFacade:DBFacade, offerId:uint, successCallback:Function, errorCallback:Function, heroId:uint = 0, callRefreshOnceDone:Boolean = true) : void
      {
         var purchaseFunc:Function;
         var currentAvatarId:uint = uint(dbFacade.dbAccountInfo.activeAvatarInfo ? dbFacade.dbAccountInfo.activeAvatarInfo.id : 0);
         Logger.debug("purchaseOffer: " + offerId.toString());
         purchaseFunc = JSONRPCService.getFunction("PurchaseOffer",dbFacade.rpcRoot + "store");
         purchaseFunc(dbFacade.dbAccountInfo.id,heroId,offerId,dbFacade.validationToken,dbFacade.demographics,function(param1:*):void
         {
            dbFacade.dbAccountInfo.parseResponse(param1,callRefreshOnceDone);
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },errorCallback);
      }
      
      public static function purchaseAndOpenChest(dbFacade:DBFacade, offerId:uint, successCallback:Function, errorCallback:Function, forHero:uint, callRefreshOnceDone:Boolean = true) : void
      {
         var purchaseFunc:Function;
         var currentAvatarId:uint = uint(dbFacade.dbAccountInfo.activeAvatarInfo ? dbFacade.dbAccountInfo.activeAvatarInfo.id : 0);
         Logger.debug("purchaseChest: " + offerId.toString());
         purchaseFunc = JSONRPCService.getFunction("PurchaseChest",dbFacade.rpcRoot + "store");
         purchaseFunc(dbFacade.dbAccountInfo.id,currentAvatarId,offerId,dbFacade.validationToken,dbFacade.demographics,function(param1:*):void
         {
            dbFacade.dbAccountInfo.parseResponse(param1,callRefreshOnceDone);
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
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },errorCallback);
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
         var _loc3_:* = 0;
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

