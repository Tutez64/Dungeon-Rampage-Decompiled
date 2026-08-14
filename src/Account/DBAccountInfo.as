package Account
{
   import Account.II.II_AccountTopScoreInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.Utils.HttpStatusEventUtils;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.Utf8BitArray;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Brain.jsonRPC.JSONRPCService;
   import Events.DBAccountLoadedEvent;
   import Events.DBAccountResponseEvent;
   import Events.FriendStatusEvent;
   import Events.TrophiesUpdatedAccountEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import UI.Popup.DBUIPopup;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.system.System;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class DBAccountInfo
   {
      
      public static const SFX_ATTRIBUTE_KEY:String = "optionsSFXVolume";
      
      public static const MUSIC_ATTRIBUTE_KEY:String = "optionsMusicVolume";
      
      public static const GRAPHICS_QUALITY_ATTRIBUTE_KEY:String = "optionsGraphicsQuality";
      
      public static const HUD_STYLE_ATTRIBUTE_KEY:String = "optionsHudStyle";
      
      private static const DB_ACCOUNT_INFO_SERVICE:String = "dbAccountInfo/accountdetails";
      
      private static const ONLINE_PRESENCE_NORMAL_REFRESH_TIME:Number = 60;
      
      protected var mDBFacade:DBFacade;
      
      private var mInventory:DBInventoryInfo;
      
      private var mUpdateMessagePopup:DBUIPopup;
      
      private var mActiveAvatar:AvatarInfo;
      
      private var mAttributes:Map;
      
      private var mBasicCurrency:uint;
      
      private var mId:uint;
      
      private var mAccountFlags:uint;
      
      private var mPremiumKeys:uint;
      
      private var mTrophyCount:uint;
      
      private var mName:String;
      
      private var mPremiumCurrency:uint;
      
      private var mInventoryLimitOther:uint;
      
      private var mInventoryLimitWeapons:uint;
      
      private var mFriendsInfo:Map;
      
      private var mGiftsInfo:Map;
      
      private var mGiftExcludeIds:Array;
      
      private var mLastFPSTime:uint;
      
      private var mLastFPSFrame:uint;
      
      private var mFPSLocation:String = "";
      
      private var mCurrentFriendsHash:String;
      
      private var mAccountCreatedDate:String;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mEventComponent:EventComponent;
      
      private var mOnlinePresenceTask:Task;
      
      public var SocketPingMilsecs:int;
      
      private var mErrorPopUp:DBUIPopup;
      
      private var mIgnoredFriendsInfo:Vector.<FriendInfo>;
      
      private var mDBAccountParams:DBAccountParams;
      
      private var mDungeonsCompleted:uint;
      
      private var mCompletedMapnodeMask:Utf8BitArray;
      
      private var mHudStyle:uint = 0;
      
      private var mLocalFriendInfo:FriendInfo;
      
      public function DBAccountInfo(dbFacade:DBFacade)
      {
         super();
         SocketPingMilsecs = -1;
         mDBFacade = dbFacade;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"DBAccountInfo");
         mAttributes = new Map();
         mFriendsInfo = new Map();
         mGiftsInfo = new Map();
         mInventory = new DBInventoryInfo(mDBFacade,parseResponse,parseError);
         mEventComponent = new EventComponent(mDBFacade);
         mIgnoredFriendsInfo = new Vector.<FriendInfo>();
         mGiftExcludeIds = [];
         mCompletedMapnodeMask = new Utf8BitArray();
         mDBFacade.dbAccountInfo = this;
      }
      
      public function get unequippedWeaponCount() : uint
      {
         return mInventory.unequippedWeaponCount;
      }
      
      public function get activeAvatarId() : uint
      {
         return mActiveAvatar.id;
      }
      
      public function get activeAvatarSkinId() : uint
      {
         return mActiveAvatar.skinId;
      }
      
      public function get stackableCount() : uint
      {
         return mInventory.numStacks;
      }
      
      public function get inventoryLimitWeapons() : uint
      {
         return mInventoryLimitWeapons;
      }
      
      public function get inventoryLimitOther() : uint
      {
         return mInventoryLimitOther;
      }
      
      public function get name() : String
      {
         return mName;
      }
      
      public function get facebookId() : String
      {
         return mDBFacade.facebookPlayerId;
      }
      
      public function get kongregateId() : String
      {
         return mDBFacade.kongregatePlayerId;
      }
      
      public function get inventoryInfo() : DBInventoryInfo
      {
         return mInventory;
      }
      
      public function get id() : uint
      {
         return mId;
      }
      
      public function get currentFacebookFriendsHash() : String
      {
         return mCurrentFriendsHash;
      }
      
      public function get currentKongregateFriendsHash() : String
      {
         return mCurrentFriendsHash;
      }
      
      public function checkFriendsHash() : void
      {
         if(mDBFacade.facebookController)
         {
            mDBFacade.facebookController.getFacebookFriendsHash();
         }
         if(mDBFacade.isKongregatePlayer)
         {
            mDBFacade.facebookController.getKongregateFriendsHash();
         }
      }
      
      public function getUsersFullAccountInfo() : void
      {
         var accountId:uint;
         var validationToken:String;
         var getUrl:String;
         var req:URLRequest;
         var loader:URLLoader;
         var traceInfo:String;
         var responseStatusCode:int;
         var _this:DBAccountInfo;
         var removeAllListeners:* = function():void
         {
            loader.removeEventListener("httpResponseStatus",onAccountInfoLoaded);
            loader.removeEventListener("complete",onAccountInfoLoaded);
            loader.removeEventListener("securityError",onAccountInfoError);
            loader.removeEventListener("certificateError",onAccountInfoError);
            loader.removeEventListener("ioError",onAccountInfoError);
         };
         var onResponseStatus:* = function(param1:HTTPStatusEvent):void
         {
            responseStatusCode = param1.status;
            traceInfo = HttpStatusEventUtils.getTraceId(param1);
         };
         var onAccountInfoLoaded:* = function(param1:Event):void
         {
            var _loc2_:Object = null;
            if(responseStatusCode < 200 || responseStatusCode >= 400)
            {
               onAccountInfoError(param1);
               return;
            }
            removeAllListeners();
            var _loc3_:URLLoader = param1.target as URLLoader;
            try
            {
               _loc2_ = JSON.parse(_loc3_.data);
               parseResponse(_loc2_);
               mEventComponent.dispatchEvent(new DBAccountLoadedEvent(_this));
               if(!mCurrentFriendsHash || mCurrentFriendsHash == "")
               {
                  getUsersFriendInfo();
               }
            }
            catch(error:Error)
            {
               Logger.error("Failed to parse account info JSON: " + error.message);
               onAccountInfoError(param1);
            }
         };
         var onAccountInfoError:* = function(param1:Event):void
         {
            removeAllListeners();
            var _loc3_:String = "[" + responseStatusCode + "] Account info loading failed";
            var _loc2_:String = "";
            if(param1 is IOErrorEvent)
            {
               _loc2_ = "IOError: " + (param1 as IOErrorEvent).text;
            }
            else if(param1 is SecurityErrorEvent)
            {
               _loc2_ = "SecurityError: " + (param1 as SecurityErrorEvent).text;
            }
            else
            {
               _loc2_ = param1.toString();
            }
            if(param1 && param1.target && param1.target.data)
            {
               _loc2_ += "; Response: " + param1.target.data;
            }
            Logger.warn(_loc3_ + (_loc2_ ? "; " + _loc2_ : "") + (traceInfo ? "; " + traceInfo : ""));
            mDBFacade.errorPopup(Locale.getString("ERROR"),Locale.getError(100) + "\n[" + responseStatusCode + "]");
         };
         Logger.debug("DBAccountInfo.getUsersFullAccountInfo");
         accountId = mDBFacade.accountId;
         validationToken = mDBFacade.validationToken;
         getUrl = mDBFacade.webServiceAPIRoot + "dbAccountInfo/accountdetails";
         req = new URLRequest(getUrl);
         req.method = "GET";
         req.requestHeaders = [];
         req.requestHeaders.push(new URLRequestHeader("X-Account-Id",accountId.toString()));
         req.requestHeaders.push(new URLRequestHeader("X-Validation-Token",validationToken));
         if(mDBFacade.initialLoginTraceId)
         {
            req.requestHeaders.push(new URLRequestHeader("X-Session-Initial-Trace",JSONRPCService.initialLoginTraceId));
         }
         loader = new URLLoader();
         responseStatusCode = 0;
         loader.addEventListener("httpResponseStatus",onResponseStatus);
         loader.addEventListener("complete",onAccountInfoLoaded);
         loader.addEventListener("securityError",onAccountInfoError);
         loader.addEventListener("certificateError",onAccountInfoError);
         loader.addEventListener("ioError",onAccountInfoError);
         _this = this;
         loader.load(req);
      }
      
      public function getUsersFriendInfo() : void
      {
         var rpcFunc:Function;
         var rpcSuccessCallback:Function;
         Logger.debug("DBAccountInfo.getUsersFriendInfo");
         rpcFunc = JSONRPCService.getFunction("getFriendRecord",mDBFacade.rpcRoot + "leaderboard");
         rpcSuccessCallback = function(param1:*):void
         {
            parseFriendResponse(param1);
         };
         rpcFunc(mDBFacade.accountId,mDBFacade.validationToken,rpcSuccessCallback,parseError);
      }
      
      public function alterAttribute(name:String, value:String) : void
      {
         var rpcSuccessCallback:Function;
         var rpcFunc:Function = JSONRPCService.getFunction("AlterAttribute",mDBFacade.rpcRoot + "account");
         if(mAttributes.hasKey(name))
         {
            mAttributes.replaceFor(name,value);
         }
         else
         {
            mAttributes.add(name,value);
         }
         rpcSuccessCallback = function(param1:*):void
         {
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,name,value,rpcSuccessCallback,parseError);
      }
      
      public function hasAttribute(name:String) : Boolean
      {
         return mAttributes.hasKey(name);
      }
      
      public function getAttribute(name:String) : String
      {
         return mAttributes.itemFor(name);
      }
      
      public function get hudStyle() : uint
      {
         return mHudStyle;
      }
      
      public function set hudStyle(value:uint) : void
      {
         mHudStyle = value;
      }
      
      public function acceptGift(requestId:String, clearGiftCallback:Function, successCallback:Function = null) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("AcceptGift",mDBFacade.rpcRoot + "store");
         var rpcSuccessCallback:Function = function(param1:*):void
         {
            if(param1)
            {
               parseResponse(param1);
            }
            if(successCallback != null)
            {
               successCallback();
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,requestId,mDBFacade.validationToken,mDBFacade.demographics,rpcSuccessCallback,parseError);
         mGiftsInfo.removeKey(requestId);
         if(clearGiftCallback != null)
         {
            clearGiftCallback();
         }
      }
      
      public function acceptAllGifts(clearGiftCallback:Function, successCallback:Function = null) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("AcceptAllGifts",mDBFacade.rpcRoot + "store");
         var rpcSuccessCallback:Function = function(param1:*):void
         {
            if(param1)
            {
               parseResponse(param1);
            }
            if(successCallback != null)
            {
               successCallback();
            }
         };
         var requestIds:Array = mGiftsInfo.keysToArray();
         if(requestIds.length > 0)
         {
            rpcFunc(mDBFacade.dbAccountInfo.id,requestIds,mDBFacade.validationToken,mDBFacade.demographics,rpcSuccessCallback,parseError);
            mGiftsInfo.clear();
            if(clearGiftCallback != null)
            {
               clearGiftCallback();
            }
         }
      }
      
      public function declineGift(requestId:String, successCallback:Function = null) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("DeclineGift",mDBFacade.rpcRoot + "store");
         var rpcSuccessCallback:Function = function():void
         {
            mGiftsInfo.removeKey(requestId);
            if(successCallback != null)
            {
               successCallback();
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,requestId,mDBFacade.validationToken,mDBFacade.demographics,rpcSuccessCallback,parseError);
      }
      
      public function sendGiftData(offerId:uint, requestIds:Array, toIds:Array, successCallback:Function = null) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("GiftOffer",mDBFacade.rpcRoot + "store");
         var rpcSuccessCallback:Function = function(param1:*):void
         {
            if(successCallback != null)
            {
               successCallback();
            }
            if(mDBFacade.steamAchievementsManager)
            {
               mDBFacade.steamAchievementsManager.setAchievement("SEND_A_GIFT");
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,offerId,mDBFacade.dbConfigManager.networkId,requestIds,toIds,mDBFacade.validationToken,rpcSuccessCallback,parseError);
      }
      
      public function sendFacebookRequestData(requestIds:Array, toIds:Array, successCallback:Function = null) : void
      {
         var _loc4_:Function = JSONRPCService.getFunction("AppRequests",mDBFacade.rpcRoot + "facebookrequests");
         _loc4_(mDBFacade.dbAccountInfo.id,requestIds,toIds,mDBFacade.validationToken);
      }
      
      public function getGiftData(successCallback:Function = null) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("GetAllGifts",mDBFacade.rpcRoot + "store");
         var rpcSuccessCallback:Function = function(param1:*):void
         {
            parseGiftData(param1);
            if(successCallback != null)
            {
               successCallback();
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,rpcSuccessCallback,parseError);
      }
      
      private function parseGiftData(gifts:*) : void
      {
         var _loc3_:Array = null;
         var _loc2_:GiftInfo = null;
         var _loc4_:* = 0;
         if(gifts)
         {
            if(gifts.excludeIds)
            {
               mGiftExcludeIds = gifts.excludeIds as Array;
            }
            if(!gifts.gifts)
            {
               return;
            }
            _loc3_ = gifts.gifts as Array;
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc2_ = new GiftInfo(mDBFacade,_loc3_[_loc4_]);
               if(!mGiftsInfo.has(_loc2_.requestId))
               {
                  mGiftsInfo.add(_loc2_.requestId,_loc2_);
               }
               _loc4_++;
            }
         }
      }
      
      public function addFriendCallback(friends:*) : void
      {
         var _loc2_:Array = null;
         var _loc5_:FriendInfo = null;
         var _loc4_:* = 0;
         var _loc3_:* = 0;
         if(friends)
         {
            _loc2_ = friends as Array;
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               _loc3_ = _loc2_[_loc4_].account_id as uint;
               if(!mFriendsInfo.hasKey(_loc3_))
               {
                  _loc5_ = new FriendInfo(mDBFacade,_loc2_[_loc4_]);
                  mFriendsInfo.add(_loc5_.id,_loc5_);
               }
               else
               {
                  _loc5_ = mFriendsInfo.itemFor(_loc3_);
                  _loc5_.parseFriendJson(_loc2_[_loc4_]);
               }
               _loc4_++;
            }
         }
         mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
      }
      
      public function removeFriendCallback(friends:*) : void
      {
         var _loc2_:Array = null;
         var _loc5_:* = null;
         var _loc4_:* = 0;
         var _loc3_:* = 0;
         if(friends)
         {
            _loc2_ = friends as Array;
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               _loc3_ = _loc2_[_loc4_].account_id as uint;
               if(mFriendsInfo.hasKey(_loc3_))
               {
                  mFriendsInfo.removeKey(_loc3_);
               }
               _loc4_++;
            }
         }
         mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
      }
      
      public function isFriend(personId:uint) : Boolean
      {
         if(personId == 0)
         {
            return false;
         }
         return mFriendsInfo.hasKey(personId);
      }
      
      public function getFriendData(successCallback:Function) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("getFriendData",mDBFacade.rpcRoot + "leaderboard");
         var rpcSuccessCallback:Function = function(param1:*):void
         {
            parseFriendData(param1);
            if(successCallback != null)
            {
               successCallback();
            }
            if(mInventory.canShowInfiniteIsland())
            {
               getAllMapnodeScoresRPC(mDBFacade.dbAccountInfo.id);
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.demographics,mDBFacade.validationToken,rpcSuccessCallback,parseError);
      }
      
      public function refreshFriendData(friends:*) : void
      {
         parseFriendData(friends);
      }
      
      public function getIgnoredFriendData(successCallback:Function = null) : void
      {
         var rpcFunc:Function;
         var rpcSuccessCallback:Function;
         if(mIgnoredFriendsInfo.length > 0)
         {
            return;
         }
         rpcFunc = JSONRPCService.getFunction("getIgnoreFriendData",mDBFacade.rpcRoot + "leaderboard");
         rpcSuccessCallback = function(param1:*):void
         {
            parseIgnoredFriendData(param1);
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,rpcSuccessCallback,parseError);
      }
      
      private function parseIgnoredFriendData(ignoredFriends:*) : void
      {
         var _loc2_:Array = null;
         var _loc5_:FriendInfo = null;
         var _loc4_:* = 0;
         var _loc3_:* = 0;
         if(ignoredFriends)
         {
            _loc2_ = ignoredFriends as Array;
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               _loc3_ = _loc2_[_loc4_].account_id as uint;
               if(!mFriendsInfo.hasKey(_loc3_))
               {
                  _loc5_ = new FriendInfo(mDBFacade,_loc2_[_loc4_]);
                  mIgnoredFriendsInfo.push(_loc5_);
               }
               else
               {
                  _loc5_ = mIgnoredFriendsInfo[_loc4_];
                  _loc5_.parseFriendJson(_loc2_[_loc4_]);
               }
               _loc4_++;
            }
         }
      }
      
      private function friendlistUpdate(event:FriendStatusEvent) : void
      {
         var successCallback:Function;
         if(event.status == false || mFriendsInfo.hasKey(event.friendId))
         {
            return;
         }
         successCallback = function():void
         {
            mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
         };
         getFriendData(successCallback);
      }
      
      private function parseFriendData(friends:*, purge:Boolean = false) : void
      {
         var myself:FriendInfo;
         var friendsArray:Array;
         var friendInfo:FriendInfo;
         var i:uint;
         var friendId:uint;
         var myObject:Object = {
            "account_id":this.mId,
            "name":this.mName,
            "trophies":this.trophies,
            "facebook_id":mDBFacade.facebookPlayerId,
            "kongregate_id":mDBFacade.kongregatePlayerId,
            "status_online":true,
            "in_dungeon":false
         };
         if(purge)
         {
            mFriendsInfo.clear();
         }
         if(!mFriendsInfo.hasKey(this.mId))
         {
            myself = new FriendInfo(mDBFacade,myObject);
            mFriendsInfo.add(myself.id,myself);
         }
         else
         {
            myself = mFriendsInfo.itemFor(this.mId);
            myself.parseFriendJson(myObject);
         }
         mEventComponent.addListener("TrophiesUpdatedAccountEvent",function(param1:TrophiesUpdatedAccountEvent):void
         {
            myself = mFriendsInfo.itemFor(mId);
            myself.trophies = param1.trophyCount;
         });
         mLocalFriendInfo = myself;
         mEventComponent.addListener("FRIEND_STATUS_EVENT",friendlistUpdate);
         if(mDBFacade.facebookController && activeAvatarInfo.level >= 5)
         {
            mDBFacade.facebookController.updateGuestAchievement(2);
         }
         if(friends)
         {
            friendsArray = friends as Array;
            i = 0;
            while(i < friendsArray.length)
            {
               friendId = friendsArray[i].account_id as uint;
               if(!mFriendsInfo.hasKey(friendId))
               {
                  friendInfo = new FriendInfo(mDBFacade,friendsArray[i]);
                  mFriendsInfo.add(friendInfo.id,friendInfo);
               }
               else
               {
                  friendInfo = mFriendsInfo.itemFor(friendId);
                  friendInfo.parseFriendJson(friendsArray[i]);
               }
               i = i + 1;
            }
         }
      }
      
      public function addAchievement(achievementId:String, achievementURL:String, achievementCallback:Function) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("AddAchievement",mDBFacade.rpcRoot + "achievement");
         var successCallback:Function = function(param1:*):void
         {
            achievementCallback(achievementId);
            Logger.info("achievement success");
         };
         var failCallback:Function = function(param1:*):void
         {
         };
         rpcFunc(mDBFacade.accountId,mDBFacade.validationToken,mDBFacade.facebookPlayerId,achievementURL,successCallback,failCallback);
      }
      
      public function setPresenceTask(location:String) : void
      {
         if(mOnlinePresenceTask)
         {
            mOnlinePresenceTask.destroy();
         }
         SocketPingMilsecs = -1;
         mLastFPSTime = mDBFacade.gameClock.realTime;
         mLastFPSFrame = mDBFacade.gameClock.frame;
         mFPSLocation = location;
         setOnlinePresence(mDBFacade.gameClock);
         mOnlinePresenceTask = mDBFacade.realClockWorkManager.doEverySeconds(60,setOnlinePresence,true,"DBAccountInfo.onlinePresence");
      }
      
      private function setOnlinePresence(gameClock:GameClock) : void
      {
         var _loc6_:uint = uint(gameClock.realTime);
         var _loc4_:uint = gameClock.frame;
         var _loc2_:Number = (_loc6_ - mLastFPSTime) / 1000;
         var _loc5_:int = _loc2_ > 0 ? Math.round((_loc4_ - mLastFPSFrame) / _loc2_) : -1;
         mLastFPSTime = _loc6_;
         mLastFPSFrame = _loc4_;
         var _loc3_:Object = {};
         if(SocketPingMilsecs > 0)
         {
            _loc3_["socketPingMilsecs"] = SocketPingMilsecs;
         }
         _loc3_["memory"] = Math.round(System.totalMemory / 1024 / 1024);
         if(_loc5_ >= 0)
         {
            _loc3_["fps"] = _loc5_;
            _loc3_["fpsLocation"] = mFPSLocation;
         }
         mDBFacade.metrics.log("Presence",_loc3_);
      }
      
      public function getFacebookIdRPC(remoteId:uint, successCallback:Function) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("GetFacebookId",mDBFacade.rpcRoot + "account");
         var rpcSuccessCallback:Function = function(param1:String):void
         {
            successCallback(param1);
         };
         rpcFunc(remoteId,id,mDBFacade.validationToken,rpcSuccessCallback,parseError);
      }
      
      public function get basicCurrency() : uint
      {
         return mBasicCurrency;
      }
      
      public function get premiumCurrency() : uint
      {
         return mPremiumCurrency;
      }
      
      public function get trophies() : uint
      {
         return mTrophyCount;
      }
      
      public function hasAllTrophies() : Boolean
      {
         if(mTrophyCount >= 106)
         {
            return true;
         }
         return false;
      }
      
      public function get activeAvatarInfo() : AvatarInfo
      {
         return mActiveAvatar;
      }
      
      public function get highestAvatarLevel() : uint
      {
         return mInventory.highestAvatarLevel;
      }
      
      public function get friendInfos() : Map
      {
         return mFriendsInfo;
      }
      
      public function get gifts() : Map
      {
         return mGiftsInfo;
      }
      
      public function get ignoredFriends() : Vector.<FriendInfo>
      {
         return mIgnoredFriendsInfo;
      }
      
      public function get giftExcludeIds() : Array
      {
         return mGiftExcludeIds;
      }
      
      public function set giftExcludeIds(excludeIds:Array) : void
      {
         mGiftExcludeIds = excludeIds;
      }
      
      public function get accountCreatedDate() : String
      {
         return mAccountCreatedDate;
      }
      
      public function set account_flags(val:uint) : void
      {
         mAccountFlags = val;
      }
      
      public function get account_flags() : uint
      {
         return mAccountFlags;
      }
      
      private function parseAttributes(attributeArray:Array) : void
      {
         mAttributes.clear();
         for each(var _loc2_:Object in attributeArray)
         {
            mAttributes.add(_loc2_.name,_loc2_.value);
         }
      }
      
      private function parseCurrency(accountJson:Object) : void
      {
         mPremiumCurrency = accountJson.premium_currency;
         mBasicCurrency = accountJson.basic_currency;
         mTrophyCount = accountJson.trophies;
         mEventComponent.dispatchEvent(new CurrencyUpdatedAccountEvent(mBasicCurrency,mPremiumCurrency));
         mEventComponent.dispatchEvent(new TrophiesUpdatedAccountEvent(mTrophyCount));
      }
      
      public function changeActiveAvatarRPC(heroType:uint) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("setActiveAvatar",mDBFacade.rpcRoot + "avatarrecord");
         var avatarInfo:AvatarInfo = mInventory.getAvatarInfoForHeroType(heroType);
         if(avatarInfo)
         {
            mActiveAvatar = avatarInfo;
            mUpdateMessagePopup = new DBUIPopup(mDBFacade,Locale.getString("SHOP_UPDATING"),null,false);
            MemoryTracker.track(mUpdateMessagePopup,"DBUIPopup - created in DBAccountInfo.changeActiveAvatarRPC()");
            rpcFunc(mDBFacade.validationToken,mDBFacade.dbAccountInfo.id,avatarInfo.id,avatarInfo.skinId,function(param1:*):void
            {
               mUpdateMessagePopup.destroy();
               parseResponse(param1);
            },parseError);
         }
      }
      
      public function getAllMapnodeScoresRPC(requestor:uint) : void
      {
         var avatarArray:Array;
         var rpcFunc:Function;
         if(requestor != mDBFacade.dbAccountInfo.id)
         {
            Logger.debug("getAllMapnodeScoresRPC: requestor not mDBFacade.dbAccountInfo.id...return");
            return;
         }
         if(friendInfos.size == 0)
         {
            Logger.debug("getAllMapnodeScoresRPC: friendInfo not set yet...return");
            return;
         }
         avatarArray = mDBFacade.dbAccountInfo.inventoryInfo.avatars.keysToArray();
         rpcFunc = JSONRPCService.getFunction("getAllMapnodeScores",mDBFacade.rpcRoot + "championsboard");
         rpcFunc(mDBFacade.dbAccountInfo.id,friendInfos.keysToArray(),avatarArray,mDBFacade.validationToken,function(param1:*):void
         {
            parseScoreResponse(param1);
         },parseError);
      }
      
      public function updateFacebookFriendsRPC(friends:Array, newFriendsHash:String, cascade:Boolean) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("updateFBFriends",mDBFacade.rpcRoot + "leaderboard");
         var callback:Function = function(param1:*):void
         {
            mCurrentFriendsHash = newFriendsHash;
            parseFriendData(param1);
            mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,friends,newFriendsHash,cascade,callback);
      }
      
      public function updateDRFriendsRPC(friends:Array, newFriendsHash:String) : void
      {
         var _loc3_:Function = JSONRPCService.getFunction("inviteNewDRFriends",mDBFacade.rpcRoot + "leaderboard");
         mCurrentFriendsHash = newFriendsHash;
         _loc3_(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,friends,newFriendsHash,mDBFacade.dbAccountInfo.name,mDBFacade.dbAccountInfo.trophies,mDBFacade.dbAccountInfo.activeAvatarSkinId,mDBFacade.dbAccountInfo.facebookId);
      }
      
      public function updateKongregateFriendsRPC(friends:Array, newFriendsHash:String, cascade:Boolean) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("updateKongregateFriends",mDBFacade.rpcRoot + "leaderboard");
         var callback:Function = function(param1:*):void
         {
            mCurrentFriendsHash = newFriendsHash;
            parseFriendData(param1);
            mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,friends,newFriendsHash,cascade,callback);
      }
      
      public function parseFriendResponse(details:*, callRefreshOnceDone:Boolean = true) : void
      {
         if(details.friends_hash)
         {
            mCurrentFriendsHash = details.friends_hash as String;
         }
      }
      
      public function parseScoreResponse(details:Object, callRefreshOnceDone:Boolean = true) : void
      {
         if(details == null)
         {
            Logger.error("Got empty array on parseScoreResponse");
            return;
         }
         var _loc4_:II_AccountTopScoreInfo = new II_AccountTopScoreInfo(details.top_scores);
         var _loc3_:IMapIterator = friendInfos.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc3_.next();
            _loc3_.current.parseChampionsboardData(_loc4_.accountIdToTopScoreMapnodeInfo.itemFor(_loc3_.current.id));
            if(_loc3_.current.id == mDBFacade.accountId)
            {
               _loc3_.current.parseIIAvatarScoresData(details.avatar_scores);
            }
         }
      }
      
      public function parseResponse(details:*, callRefreshOnceDone:Boolean = true) : void
      {
         if(details == null || details.length <= 0)
         {
            Logger.error("Got empty array on parseResponse");
            return;
         }
         mCompletedMapnodeMask.init(details.completed_mapnode_mask);
         mAccountFlags = details.account_flags as uint;
         var _loc3_:int = int(details.active_avatar);
         mInventory.parseJson(details);
         mActiveAvatar = mInventory.getAvatarInfoForAvatarInstanceId(_loc3_);
         mEventComponent.dispatchEvent(new Event("ACTIVE_AVATAR_CHANGED_EVENT"));
         parseCurrency(details);
         if(details.account_attributes)
         {
            parseAttributes(details.account_attributes);
         }
         mId = details.id;
         mName = details.name;
         mInventoryLimitWeapons = details.buckets_weapon;
         mInventoryLimitOther = details.buckets_other;
         mAccountCreatedDate = details.created as String;
         mDungeonsCompleted = details.completed_dungeons;
         mDBAccountParams = new DBAccountParams(mDBFacade,this);
         if(callRefreshOnceDone)
         {
            mEventComponent.dispatchEvent(new DBAccountResponseEvent(this));
         }
      }
      
      public function getCompletedMapnodeMask() : Utf8BitArray
      {
         return mCompletedMapnodeMask;
      }
      
      private function parseError(err:Error) : void
      {
         if(mErrorPopUp)
         {
            return;
         }
         mErrorPopUp = new DBUIPopup(mDBFacade,"Error getting account info.");
         MemoryTracker.track(mErrorPopUp,"DBUIPopup - created in DBAccountInfo.parseError()");
         mLogicalWorkComponent.doLater(1.5,killErrorPopUp);
      }
      
      private function killErrorPopUp(gameClock:GameClock) : void
      {
         if(mErrorPopUp)
         {
            mErrorPopUp.destroy();
            mErrorPopUp = null;
         }
      }
      
      public function get dbAccountParams() : DBAccountParams
      {
         return mDBAccountParams;
      }
      
      public function incrementCompletedDungeons() : void
      {
         mDungeonsCompleted = mDungeonsCompleted + 1;
      }
      
      public function getDungeonsCompleted() : uint
      {
         return mDungeonsCompleted;
      }
      
      public function get localFriendInfo() : FriendInfo
      {
         return mLocalFriendInfo;
      }
   }
}

