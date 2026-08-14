package StateMachine.MainStateMachine
{
   import Brain.Logger.Logger;
   import Brain.StateMachine.StateMachine;
   import Brain.Utils.MemoryTracker;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import UI.Leaderboard.UILeaderboard;
   
   public class MainStateMachine extends StateMachine
   {
      
      protected var mLoadingState:LoadingState;
      
      protected var mReloadTownState:ReloadTownState;
      
      protected var mLoadingScreenState:LoadingScreenState;
      
      protected var mTownState:TownState;
      
      protected var mRunState:RunState;
      
      protected var mSocketErrorState:SocketErrorState;
      
      protected var mDBFacade:DBFacade;
      
      private var mLastHeroId:uint;
      
      private var mLastHeroLevel:uint;
      
      private var mShowedInvitePopup:Boolean = false;
      
      private var mShowedHeroUpsellPopup:Boolean = false;
      
      private var mShowedRewardPopup:Boolean = false;
      
      public function MainStateMachine(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mLoadingState = new LoadingState(dbFacade);
         MemoryTracker.track(mLoadingState,"LoadingState - created in MainStateMachine.MainStateMachine()");
         mReloadTownState = new ReloadTownState(dbFacade,enterTownState);
         MemoryTracker.track(mReloadTownState,"ReloadTownState - created in MainStateMachine.MainStateMachine()");
         mLoadingScreenState = new LoadingScreenState(dbFacade,enterRunState);
         MemoryTracker.track(mLoadingScreenState,"LoadingScreenState - created in MainStateMachine.MainStateMachine()");
         mTownState = new TownState(dbFacade);
         MemoryTracker.track(mTownState,"TownState - created in MainStateMachine.MainStateMachine()");
         mRunState = new RunState(dbFacade,enterReloadTownState);
         MemoryTracker.track(mRunState,"RunState - created in MainStateMachine.MainStateMachine()");
         mSocketErrorState = new SocketErrorState(dbFacade);
         MemoryTracker.track(mSocketErrorState,"SocketErrorState - created in MainStateMachine.MainStateMachine()");
      }
      
      public function enterLoadingState() : void
      {
         this.transitionToState(mLoadingState);
      }
      
      public function enterLoadingScreenState(mapNodeID:uint = 0, nodeType:String = "", friendID:uint = 0, mapID:uint = 0, jumpToMap:Boolean = false, makeprivate:Boolean = false) : void
      {
         if(mapNodeID != 0)
         {
            mLoadingScreenState.mapNodeID = mapNodeID;
         }
         else if(friendID != 0)
         {
            mLoadingScreenState.friendID = friendID;
         }
         else if(mapID != 0)
         {
            mLoadingScreenState.mapID = mapID;
         }
         mLoadingScreenState.friendsOnly = makeprivate;
         mLoadingScreenState.nodeType = nodeType;
         mLoadingScreenState.jumpToMapState = jumpToMap;
         this.transitionToState(mLoadingScreenState);
      }
      
      public function start() : void
      {
         if(!mDBFacade.dbAccountInfo.activeAvatarInfo)
         {
            Logger.error("Account has invalid active avatar: accountId: " + mDBFacade.dbAccountInfo.id.toString() + " activeAvatar: " + mDBFacade.dbAccountInfo.activeAvatarId.toString());
            return;
         }
         var _loc1_:Boolean = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id).length > 0;
         if(_loc1_ && !mDBFacade.dbAccountInfo.dbAccountParams.hasMovementTutorialParam())
         {
            this.enterLoadingScreenState(DBGlobal.TUTORIAL_MAP_NODE_ID,"",0,0,true);
         }
         else
         {
            this.enterTownState();
         }
      }
      
      public function enterTownInventoryState(type:uint = 0, offerId:uint = 0, showEquipOption:Boolean = false) : void
      {
         if(this.currentStateName == mTownState.name)
         {
            mTownState.townStateMachine.enterInventoryState(false,"",type,offerId,showEquipOption);
         }
         else
         {
            Logger.error("Trying to enter inventory state while not in the town state.");
         }
      }
      
      public function enterTownState(mJumpToMapState:Boolean = false) : void
      {
         if(mJumpToMapState)
         {
            mTownState.jumpToMapState = mJumpToMapState;
         }
         this.transitionToState(mTownState);
      }
      
      public function enterReloadTownState(mJumpToMapState:Boolean = false) : void
      {
         if(mTownState && mJumpToMapState)
         {
            mTownState.jumpToMapState = mJumpToMapState;
         }
         this.transitionToState(mReloadTownState);
      }
      
      public function enterRunState() : void
      {
         mDBFacade.mainStateMachine.markHasHeroLeveledUp();
         this.transitionToState(mRunState);
      }
      
      public function get leaderboard() : UILeaderboard
      {
         return mTownState.leaderboard;
      }
      
      public function enterSocketErrorState(errorCode:uint, errorText:String = "") : void
      {
         this.transitionToState(mSocketErrorState);
         mSocketErrorState.enterReason(errorCode,errorText);
      }
      
      public function markHasHeroLeveledUp() : Boolean
      {
         var _loc1_:Boolean = false;
         if(mLastHeroId && mLastHeroId == mDBFacade.dbAccountInfo.activeAvatarInfo.avatarType && mLastHeroLevel && mLastHeroLevel < mDBFacade.dbAccountInfo.activeAvatarInfo.level)
         {
            _loc1_ = true;
         }
         mLastHeroId = mDBFacade.dbAccountInfo.activeAvatarInfo.avatarType;
         mLastHeroLevel = mDBFacade.dbAccountInfo.activeAvatarInfo.level;
         return _loc1_;
      }
      
      public function set showedHeroUpsellPopup(value:Boolean) : void
      {
         mShowedHeroUpsellPopup = value;
      }
      
      public function get showedHeroUpsellPopup() : Boolean
      {
         return mShowedHeroUpsellPopup;
      }
      
      public function set showedInvitePopup(value:Boolean) : void
      {
         mShowedInvitePopup = value;
      }
      
      public function get showedInvitePopup() : Boolean
      {
         return mShowedInvitePopup;
      }
      
      public function set showedRewardPopup(value:Boolean) : void
      {
         mShowedRewardPopup = value;
      }
      
      public function get showedRewardPopup() : Boolean
      {
         return mShowedRewardPopup;
      }
   }
}

