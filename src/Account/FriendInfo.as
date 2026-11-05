package Account
{
   import Account.II.II_AvatarMapNodeScore;
   import Account.II.II_AvatarsScoresInfo;
   import Account.II.II_FriendChampionsboardInfo;
   import Brain.Event.EventComponent;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMMapNode;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class FriendInfo extends EventDispatcher
   {
      
      public static const PORTRAIT_CHANGED:String = "FriendPortraitChanged";
      
      public static var FRIEND_SCORES_PARSED:String = "FRIEND_SCORES_PARSED";
      
      private var mSkinId:uint = 151;
      
      private var mPortraitUrl:String;
      
      private var mAccountId:uint;
      
      private var mSteamAvatarUrl:String;
      
      private var mFriendName:String;
      
      private var mTrophies:uint;
      
      private var mAscensionLevel:uint;
      
      private var mDBFacade:DBFacade;
      
      private var mResponseCallback:Function;
      
      private var mIILeaderboardInfo:II_FriendChampionsboardInfo;
      
      private var mIIAvatarScoresInfo:II_AvatarsScoresInfo;
      
      protected var mEventComponent:EventComponent;
      
      public function FriendInfo(dbFacade:DBFacade, friendJson:Object, responseCallback:Function = null)
      {
         super();
         mResponseCallback = responseCallback;
         mDBFacade = dbFacade;
         mEventComponent = new EventComponent(mDBFacade);
         parseFriendJson(friendJson);
      }
      
      public function parseFriendJson(friendJson:Object) : void
      {
         var _loc4_:AvatarInfo = null;
         if(friendJson == null)
         {
            return;
         }
         mAccountId = friendJson.account_id as uint;
         mFriendName = friendJson.name as String;
         mTrophies = friendJson.trophies as uint;
         mAscensionLevel = friendJson.hasOwnProperty("ascension_level") ? uint(friendJson.ascension_level) : 0;
         mSteamAvatarUrl = friendJson.steam_avatar_url as String;
         var _loc3_:uint = mSkinId;
         var _loc2_:String = mPortraitUrl;
         if(friendJson.hasOwnProperty("active_skin"))
         {
            mSkinId = uint(friendJson.active_skin);
         }
         else if(mAccountId == mDBFacade.accountId)
         {
            _loc4_ = mDBFacade.dbAccountInfo.activeAvatarInfo;
            mSkinId = _loc4_ ? _loc4_.skinId : 151;
         }
         else
         {
            mSkinId = 151;
         }
         mPortraitUrl = mSteamAvatarUrl;
         if(_loc3_ != mSkinId || _loc2_ != mPortraitUrl)
         {
            dispatchEvent(new Event("FriendPortraitChanged"));
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
      
      public function refreshOwnPortrait() : void
      {
         if(mAccountId != mDBFacade.accountId)
         {
            return;
         }
         var _loc2_:AvatarInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
         var _loc1_:uint = _loc2_ ? _loc2_.skinId : 151;
         if(_loc1_ == mSkinId)
         {
            return;
         }
         mSkinId = _loc1_;
         dispatchEvent(new Event("FriendPortraitChanged"));
      }
      
      public function get skinId() : uint
      {
         return mSkinId;
      }
      
      public function get id() : uint
      {
         return mAccountId;
      }
      
      public function get steamAvatarUrl() : String
      {
         return mSteamAvatarUrl;
      }
      
      public function get trophies() : uint
      {
         return mTrophies;
      }
      
      public function set trophies(value:uint) : void
      {
         mTrophies = value;
      }
      
      public function get ascensionLevel() : uint
      {
         return mAscensionLevel;
      }
      
      public function set ascensionLevel(value:uint) : void
      {
         mAscensionLevel = value;
      }
      
      public function get lastMapNode() : uint
      {
         if(mDBFacade.mDistributedObjectManager && mDBFacade.mDistributedObjectManager.mPresenceManager)
         {
            return mDBFacade.mDistributedObjectManager.mPresenceManager.InDungeonId(mAccountId);
         }
         return 0;
      }
      
      public function get dungeonName() : String
      {
         var _loc1_:GMMapNode = mDBFacade.gameMaster ? mDBFacade.gameMaster.getMapNode(lastMapNode) : null;
         if(_loc1_ == null)
         {
            return null;
         }
         return GameMasterLocale.getGameMasterSubString("DUNGEON_NAME",_loc1_.Constant);
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
         return this.id.toString();
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
         var _loc4_:II_AvatarMapNodeScore = mIIAvatarScoresInfo.avatarIdToAvatarScore.itemFor(avatarId);
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

