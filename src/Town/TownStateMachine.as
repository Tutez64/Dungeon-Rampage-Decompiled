package Town
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.StateMachine.StateMachine;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import UI.Leaderboard.UILeaderboard;
   import flash.display.MovieClip;
   
   public class TownStateMachine extends StateMachine
   {
      
      private static const TOWN_HOME_CLASS_NAME:String = "UI_town_home";
      
      public static const INVENTORY_CLASS_NAME:String = "DR_UI_town_inventory";
      
      private static const TAVERN_CLASS_NAME:String = "UI_town_tavern";
      
      public static const SHOP_CLASS_NAME:String = "DR_UI_town_shop";
      
      private static const FRIEND_MANAGEMENT_CLASS_NAME:String = "UI_friend_management";
      
      private static const SKILLS_CLASS_NAME:String = "UI_town_skills";
      
      private static const TRAIN_CLASS_NAME:String = "UI_town_train";
      
      private static const MAP_2_1_NAME:String = "Map_2_1";
      
      private static const CREDITS_CLASS_NAME:String = "UI_town_credits";
      
      private var mTownSwfAsset:SwfAsset;
      
      private var mMapSwfAsset:SwfAsset;
      
      private var mHomeState:HomeState;
      
      private var mInventoryState:InventoryTownSubState;
      
      private var mTavernState:TavernTownSubState;
      
      private var mTrainState:TrainTownSubState;
      
      private var mSkillsState:SkillsTownSubState;
      
      private var mShopState:ShopTownSubState;
      
      private var mFriendManagementState:SocialSubState;
      
      private var mMapState:MapTownSubState;
      
      private var mTownHeader:TownHeader;
      
      protected var mUILeaderboard:UILeaderboard;
      
      private var mCreditsState:CreditsTownSubState;
      
      protected var mDBFacade:DBFacade;
      
      public function TownStateMachine(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         buildStates();
         mTownHeader = new TownHeader(mDBFacade,this.enterHomeState,this.enterMapState);
      }
      
      override public function destroy() : void
      {
         mHomeState.destroy();
         mInventoryState.destroy();
         mTavernState.destroy();
         mShopState.destroy();
         mFriendManagementState.destroy();
         mSkillsState.destroy();
         mTrainState.destroy();
         mMapState.destroy();
         mTownHeader.destroy();
         mUILeaderboard.destroy();
         mCreditsState.destroy();
         mHomeState = null;
         mInventoryState = null;
         mTavernState = null;
         mShopState = null;
         mFriendManagementState = null;
         mSkillsState = null;
         mTrainState = null;
         mMapState = null;
         mTownHeader = null;
         mUILeaderboard = null;
         mMapSwfAsset = null;
         mTownSwfAsset = null;
         mCreditsState = null;
         mDBFacade = null;
         super.destroy();
      }
      
      public function setSwfs(townAsset:SwfAsset, mapSwf:SwfAsset) : void
      {
         mTownSwfAsset = townAsset;
         mMapSwfAsset = mapSwf;
         setMovieClipsOnStates();
      }
      
      public function get townSwf() : SwfAsset
      {
         return mTownSwfAsset;
      }
      
      public function get townHeader() : TownHeader
      {
         return mTownHeader;
      }
      
      private function setMovieClipsOnStates() : void
      {
         var _loc3_:Class = null;
         var _loc7_:Class = mTownSwfAsset.getClass("UI_town_home");
         mHomeState.rootMovieClip = new _loc7_() as MovieClip;
         var _loc4_:Class = mTownSwfAsset.getClass("UI_town_tavern");
         mTavernState.rootMovieClip = new _loc4_() as MovieClip;
         var _loc1_:Class = mTownSwfAsset.getClass("DR_UI_town_inventory");
         mInventoryState.rootMovieClip = new _loc1_() as MovieClip;
         var _loc9_:Class = mTownSwfAsset.getClass("DR_UI_town_shop");
         mShopState.rootMovieClip = new _loc9_() as MovieClip;
         var _loc8_:Class = mTownSwfAsset.getClass("UI_friend_management");
         mFriendManagementState.rootMovieClip = new _loc8_() as MovieClip;
         var _loc5_:Class = mTownSwfAsset.getClass("UI_town_skills");
         mSkillsState.rootMovieClip = new _loc5_() as MovieClip;
         var _loc6_:Class = mTownSwfAsset.getClass("UI_town_train");
         mTrainState.rootMovieClip = new _loc6_() as MovieClip;
         var _loc2_:Class = mTownSwfAsset.getClass("UI_town_credits");
         mCreditsState.rootMovieClip = new _loc2_() as MovieClip;
         _loc3_ = mMapSwfAsset.getClass("Map_2_1");
         mMapState.rootMovieClip = new _loc3_() as MovieClip;
         mUILeaderboard = new UILeaderboard(mDBFacade,mTownSwfAsset,callbackToFriendManager,getGifts,this);
      }
      
      private function buildStates() : void
      {
         mHomeState = new HomeState(mDBFacade,this);
         MemoryTracker.track(mHomeState,"HomeState - created in TownStateMachine.buildStates()");
         mInventoryState = new InventoryTownSubState(mDBFacade,this);
         MemoryTracker.track(mInventoryState,"InventoryTownSubState - created in TownStateMachine.buildStates()");
         mTavernState = new TavernTownSubState(mDBFacade,this);
         MemoryTracker.track(mTavernState,"TavernTownSubState - created in TownStateMachine.buildStates()");
         mShopState = new ShopTownSubState(mDBFacade,this);
         MemoryTracker.track(mShopState,"ShopTownSubState - created in TownStateMachine.buildStates()");
         mFriendManagementState = new SocialSubState(mDBFacade,this);
         MemoryTracker.track(mFriendManagementState,"SocialSubState - created in TownStateMachine.buildStates()");
         mSkillsState = new SkillsTownSubState(mDBFacade,this);
         MemoryTracker.track(mSkillsState,"SkillsTownSubState - created in TownStateMachine.buildStates()");
         mTrainState = new TrainTownSubState(mDBFacade,this);
         MemoryTracker.track(mTrainState,"TrainTownSubState - created in TownStateMachine.buildStates()");
         mMapState = new MapTownSubState(mDBFacade,this);
         MemoryTracker.track(mMapState,"MapTownSubState - created in TownStateMachine.buildStates()");
         mCreditsState = new CreditsTownSubState(mDBFacade,this);
         MemoryTracker.track(mCreditsState,"CreditsTownSubState - created in TownStateMachine.buildStates()");
      }
      
      public function enterHomeState() : void
      {
         mTownHeader.show();
         mTownHeader.showCloseButton(false);
         this.transitionToState(mHomeState);
      }
      
      public function enterInventoryState(returnToMapStateOnClose:Boolean = false, tabCategory:String = "", type:uint = 0, offerId:uint = 0, showEquipOption:Boolean = false) : void
      {
         mInventoryState.startAtCategoryTab = tabCategory;
         mTownHeader.jumpToMapState = returnToMapStateOnClose;
         mInventoryState.setRevlealedState(type,offerId,showEquipOption);
         this.transitionToState(mInventoryState);
         if(mDBFacade.steamAchievementsManager)
         {
            mDBFacade.steamAchievementsManager.checkStorageAchievements();
         }
      }
      
      public function enterTavernState(returnToMapStateOnClose:Boolean = false) : void
      {
         mTownHeader.jumpToMapState = returnToMapStateOnClose;
         this.transitionToState(mTavernState);
      }
      
      public function enterTrainState() : void
      {
         this.transitionToState(mTrainState);
      }
      
      public function enterShopState(returnToMapStateOnClose:Boolean = false, jumpToCategoryTab:String = "") : void
      {
         mShopState.startAtCategoryTab = jumpToCategoryTab;
         mTownHeader.jumpToMapState = returnToMapStateOnClose;
         this.transitionToState(mShopState);
      }
      
      public function enterFriendManagementState() : void
      {
         this.transitionToState(mFriendManagementState);
      }
      
      public function setFriendManagementTabCategory(value:uint) : void
      {
         mFriendManagementState.setTabCategory(value);
      }
      
      public function enterSkillsState() : void
      {
         this.transitionToState(mSkillsState);
      }
      
      public function enterMapState() : void
      {
         this.transitionToState(mMapState);
      }
      
      public function enterCreditState() : void
      {
         this.transitionToState(mCreditsState);
      }
      
      public function getGifts() : void
      {
         mHomeState.getGifts();
      }
      
      public function get leaderboard() : UILeaderboard
      {
         return mUILeaderboard;
      }
      
      public function getTownAsset(assetName:String) : Class
      {
         return mTownSwfAsset.getClass(assetName);
      }
      
      public function callbackToFriendManager() : void
      {
         setFriendManagementTabCategory(1);
         enterFriendManagementState();
      }
      
      public function exit() : void
      {
         mTownHeader.hide();
         this.currentState.exitState();
         this.currentState = null;
      }
   }
}

