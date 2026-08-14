package Account
{
   import Account.II.II_AvatarMapnodeScore;
   import Account.II.II_AvatarsScoresInfo;
   import Account.II.II_FriendChampionsboardInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.UI.UIObject;
   import Facade.DBFacade;
   import GameMasterDictionary.GMSkin;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   
   public class FriendInfo
   {
      
      public static var FRIEND_SCORES_PARSED:String = "FRIEND_SCORES_PARSED";
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mRoot:MovieClip;
      
      private var mAccountId:uint;
      
      private var mIsDRFriend:Boolean;
      
      private var mFacebookId:String;
      
      private var mKongregateId:String;
      
      private var mFriendName:String;
      
      private var mTrophies:uint;
      
      private var mGMSkin:GMSkin;
      
      private var mIcon:MovieClip;
      
      private var mDBFacade:DBFacade;
      
      private var mResponseCallback:Function;
      
      private var mProfilePic:DisplayObject;
      
      private var mProfilePicBitmap:Bitmap;
      
      private var mIILeaderboardInfo:II_FriendChampionsboardInfo;
      
      private var mIIAvatarScoresInfo:II_AvatarsScoresInfo;
      
      protected var mEventComponent:EventComponent;
      
      public function FriendInfo(dbFacade:DBFacade, friendJson:Object, responseCallback:Function = null)
      {
         super();
         mResponseCallback = responseCallback;
         mDBFacade = dbFacade;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         parseFriendJson(friendJson);
      }
      
      private function loadHeroIcon() : DisplayObject
      {
         var swfPath:String = mGMSkin.UISwfFilepath;
         var iconName:String = mGMSkin.IconName;
         if(mIcon != null && mRoot != null && mRoot.contains(mIcon))
         {
            mRoot.removeChild(mIcon);
         }
         mIcon = new MovieClip();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
         {
            var _loc4_:Class = param1.getClass(iconName);
            var _loc3_:MovieClip = new _loc4_();
            var _loc2_:uint = 50;
            UIObject.scaleToFit(_loc3_,_loc2_);
            _loc3_.x = 25;
            _loc3_.y = 25;
            mIcon.addChild(_loc3_);
         });
         return mIcon;
      }
      
      public function parseFriendJson(friendJson:Object) : void
      {
         var identifier:Array;
         var network:String;
         var key:String;
         var loader:Loader;
         var picUrl:String;
         var url:URLRequest;
         var skinId:uint;
         var avatarInfo:AvatarInfo;
         var context:LoaderContext;
         if(friendJson == null)
         {
            return;
         }
         mAccountId = friendJson.account_id as uint;
         mFriendName = friendJson.name as String;
         mTrophies = friendJson.trophies as uint;
         mFacebookId = friendJson.facebook_id as String;
         mKongregateId = friendJson.kongregate_id as String;
         if(friendJson.is_ingame_friend)
         {
            mIsDRFriend = friendJson.is_ingame_friend as Boolean;
         }
         if(friendJson.identifier)
         {
            identifier = friendJson.identifier.split("_");
            if(identifier.length > 1)
            {
               network = identifier[0];
               key = identifier[1];
            }
            else
            {
               key = identifier[0];
            }
            if(network == "1")
            {
               mFacebookId = key;
            }
            else if(network == "2")
            {
               mKongregateId = key;
            }
         }
         if(!mProfilePic)
         {
            loader = new Loader();
            picUrl = "";
            if(!this.facebookId || this.facebookId == "" || mDBFacade.isDRPlayer)
            {
               avatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mDBFacade.dbAccountInfo.activeAvatarInfo.avatarType);
               if(avatarInfo == null)
               {
                  mGMSkin = mDBFacade.gameMaster.getSkinByType(164);
               }
               else
               {
                  if(friendJson.hasOwnProperty("active_skin"))
                  {
                     skinId = uint(friendJson.active_skin);
                  }
                  else
                  {
                     skinId = avatarInfo.skinId;
                  }
                  mGMSkin = mDBFacade.gameMaster.getSkinByType(skinId);
               }
               mProfilePic = loadHeroIcon();
            }
            else if(mFacebookId != null || mFacebookId != "")
            {
               context = new LoaderContext();
               context.checkPolicyFile = true;
               context.applicationDomain = ApplicationDomain.currentDomain;
               picUrl = "https://graph.facebook.com/" + mFacebookId + "/picture";
               url = new URLRequest(picUrl);
               loader.contentLoaderInfo.addEventListener("ioError",ignoreError);
               loader.contentLoaderInfo.addEventListener("securityError",function(param1:SecurityErrorEvent):void
               {
                  Logger.error("parseFriendJson :" + param1.toString() + " Data:" + url.data.toString() + " URL:" + picUrl);
               });
               loader.contentLoaderInfo.addEventListener("complete",function(param1:Event):void
               {
                  loader.cacheAsBitmap = true;
                  mProfilePicBitmap = loader.content as Bitmap;
               });
               loader.load(url,context);
               mProfilePic = loader;
            }
         }
         if(mResponseCallback != null)
         {
            mResponseCallback();
         }
      }
      
      public function parseChampionsboardData(friendChampionsBoardInfo:II_FriendChampionsboardInfo) : void
      {
         mIILeaderboardInfo = friendChampionsBoardInfo;
      }
      
      public function parseIIAvatarScoresData(avatarScoresJson:Object) : void
      {
         mIIAvatarScoresInfo = new II_AvatarsScoresInfo(avatarScoresJson);
         mEventComponent.dispatchEvent(new Event(FRIEND_SCORES_PARSED));
      }
      
      private function ignoreError(event:Event) : void
      {
      }
      
      public function get pic() : DisplayObject
      {
         return mProfilePic;
      }
      
      public function clonePic() : DisplayObject
      {
         var loader:Loader;
         var picUrl:String;
         var url:URLRequest;
         var lc:LoaderContext;
         var clone:DisplayObject;
         if(this.facebookId == null || this.facebookId == "")
         {
            return loadHeroIcon();
         }
         if(!mProfilePicBitmap)
         {
            loader = new Loader();
            picUrl = "https://graph.facebook.com/" + mFacebookId + "/picture";
            url = new URLRequest(picUrl);
            loader.contentLoaderInfo.addEventListener("ioError",ignoreError);
            loader.contentLoaderInfo.addEventListener("securityError",function(param1:SecurityErrorEvent):void
            {
               Logger.error("clonePic: " + param1.toString() + " Data:" + url.data.toString() + " URL:" + picUrl);
            });
            lc = new LoaderContext(true);
            lc.checkPolicyFile = true;
            loader.load(url,lc);
            return loader;
         }
         clone = new Bitmap(mProfilePicBitmap.bitmapData) as DisplayObject;
         return clone;
      }
      
      public function get id() : uint
      {
         return mAccountId;
      }
      
      public function get isDRFriend() : Boolean
      {
         return mIsDRFriend;
      }
      
      public function get facebookId() : String
      {
         return mFacebookId;
      }
      
      public function get kongregateId() : String
      {
         return mKongregateId;
      }
      
      public function get trophies() : uint
      {
         return mTrophies;
      }
      
      public function set trophies(value:uint) : void
      {
         mTrophies = value;
      }
      
      public function get lastMapNode() : uint
      {
         if(mDBFacade.mDistributedObjectManager && mDBFacade.mDistributedObjectManager.mPresenceManager)
         {
            return mDBFacade.mDistributedObjectManager.mPresenceManager.InDungeonId(mAccountId);
         }
         return 0;
      }
      
      public function isOnline() : Boolean
      {
         if(mAccountId == mDBFacade.dbAccountInfo.id)
         {
            return true;
         }
         if(mDBFacade.mDistributedObjectManager && mDBFacade.mDistributedObjectManager.mPresenceManager)
         {
            return mDBFacade.mDistributedObjectManager.mPresenceManager.isOnline(mAccountId);
         }
         return false;
      }
      
      public function isInDungeon() : Boolean
      {
         if(mDBFacade.mDistributedObjectManager && mDBFacade.mDistributedObjectManager.mPresenceManager)
         {
            return mDBFacade.mDistributedObjectManager.mPresenceManager.isInDungeon(mAccountId);
         }
         return false;
      }
      
      public function get name() : String
      {
         return mFriendName;
      }
      
      public function get excludeId() : String
      {
         if(mDBFacade.isDRPlayer || this.isDRFriend)
         {
            return this.id.toString();
         }
         if(mDBFacade.isFacebookPlayer && this.facebookId)
         {
            return this.facebookId.toString();
         }
         if(mDBFacade.isKongregatePlayer && this.kongregateId)
         {
            return this.kongregateId.toString();
         }
         return "not found";
      }
      
      public function getWeaponsUsedForNode(nodeId:uint) : Vector.<Object>
      {
         if(mIILeaderboardInfo)
         {
            return mIILeaderboardInfo.getWeaponsForNodeId(nodeId);
         }
         return new Vector.<Object>();
      }
      
      public function getIILeaderboardScoreForNode(nodeId:int) : int
      {
         if(mIILeaderboardInfo && mIILeaderboardInfo.nodeIdToScore.hasKey(nodeId))
         {
            return mIILeaderboardInfo.nodeIdToScore.itemFor(nodeId);
         }
         return 0;
      }
      
      public function getIILeaderboardAvatarSkinForNode(nodeId:int) : int
      {
         if(mIILeaderboardInfo && mIILeaderboardInfo.nodeIdToActiveSkin.hasKey(nodeId))
         {
            return mIILeaderboardInfo.nodeIdToActiveSkin.itemFor(nodeId);
         }
         return 151;
      }
      
      public function getIIAvatarScoreForNode(avatarId:int, nodeId:int) : int
      {
         var _loc3_:int = 0;
         if(mIIAvatarScoresInfo == null)
         {
            return 0;
         }
         var _loc4_:II_AvatarMapnodeScore = mIIAvatarScoresInfo.avatarIdToAvatarScore.itemFor(avatarId);
         if(_loc4_)
         {
            _loc3_ = _loc4_.nodeIdToScore.itemFor(nodeId);
            if(_loc3_)
            {
               return _loc3_;
            }
         }
         return 0;
      }
   }
}

