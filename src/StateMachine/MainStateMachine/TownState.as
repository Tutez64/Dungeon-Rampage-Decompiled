package StateMachine.MainStateMachine
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.StateMachine.State;
   import Facade.DBFacade;
   import Facade.TrickleCacheLoader;
   import Town.TownStateMachine;
   import UI.Leaderboard.UILeaderboard;
   import flash.display.MovieClip;
   import flash.geom.Vector3D;
   
   public class TownState extends State
   {
      
      public static const TOWN_PATH:String = "Resources/Art2D/UI/db_UI_town.swf";
      
      public static const MAP_PATH:String = "Resources/Art2D/UI/db_UI_map.swf";
      
      public static const NAME:String = "TownState";
      
      protected var mDBFacade:DBFacade;
      
      private var mPlayGameCallback:Function;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mTownRoot:MovieClip;
      
      private var mMapSwfAsset:SwfAsset;
      
      private var mTownSwfAsset:SwfAsset;
      
      protected var mTownStateMachine:TownStateMachine;
      
      protected var mJumpToMapState:Boolean = false;
      
      public function TownState(dbFacade:DBFacade)
      {
         super("TownState");
         mDBFacade = dbFacade;
      }
      
      public static function preLoadAssets(dbFacade:DBFacade) : void
      {
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),dbFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_map.swf"),dbFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),dbFacade);
      }
      
      override public function destroy() : void
      {
         mDBFacade = null;
         mMapSwfAsset = null;
         mTownSwfAsset = null;
         mPlayGameCallback = null;
         super.destroy();
      }
      
      public function get townStateMachine() : TownStateMachine
      {
         return mTownStateMachine;
      }
      
      override public function enterState() : void
      {
         Logger.debug("MAIN STATE MACHINE TRANSITION -- ENTERING TOWN STATE");
         super.enterState();
         mDBFacade.dbAccountInfo.setPresenceTask("TOWN");
         mTownStateMachine = new TownStateMachine(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"TownState");
         loadNecessarySwfs();
         mDBFacade.camera.centerCameraOnPoint(new Vector3D());
         mSceneGraphComponent.fadeIn(0.5);
      }
      
      override public function exitState() : void
      {
         mTownStateMachine.exit();
         mTownStateMachine.destroy();
         mTownStateMachine = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         super.exitState();
      }
      
      private function loadNecessarySwfs() : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),setTownSwf);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_map.swf"),setMapSwf);
         mAssetLoadingComponent.setTransitionToEmptyCallback(setUpTownScreen);
      }
      
      private function setTownSwf(swfAsset:SwfAsset) : void
      {
         mTownSwfAsset = swfAsset;
      }
      
      private function setMapSwf(swfAsset:SwfAsset) : void
      {
         mMapSwfAsset = swfAsset;
      }
      
      private function setUpTownScreen() : void
      {
         mTownRoot = mTownSwfAsset.root;
         mTownStateMachine.setSwfs(mTownSwfAsset,mMapSwfAsset);
         startLazyLoading();
         if(mJumpToMapState)
         {
            mTownStateMachine.enterMapState();
         }
         else
         {
            mTownStateMachine.enterHomeState();
         }
         mJumpToMapState = false;
      }
      
      public function get leaderboard() : UILeaderboard
      {
         return mTownStateMachine.leaderboard;
      }
      
      public function set jumpToMapState(value:Boolean) : void
      {
         mJumpToMapState = value;
      }
      
      private function startLazyLoading() : void
      {
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_loading_screen.swf"),mDBFacade);
      }
   }
}

