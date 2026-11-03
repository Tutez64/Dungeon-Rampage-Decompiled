package UI
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Event.EventComponent;
   import Brain.SceneGraph.SceneGraphComponent;
   import Events.LevelUpPostEvent;
   import Facade.DBFacade;
   import GameMasterDictionary.GMSkin;
   import UI.Popup.UIDungeonSummaryLevelUpPopup;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class UILevelUpPostController
   {
      
      public static const TIME_TO_SHARE_LEVEL_UP_EVENT:String = "TIME_TO_SHARE_LEVEL_UP_EVENT";
      
      private var mDBFacade:DBFacade;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mEventComponent:EventComponent;
      
      private var mCurtain:Sprite;
      
      private var mSelectedLevel:uint;
      
      public function UILevelUpPostController(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UILevelUpPostController");
         mEventComponent.addListener("LevelUpPostEvent",setlevelUpPost);
         mEventComponent.addListener("TIME_TO_SHARE_LEVEL_UP_EVENT",checkToSharePopup);
      }
      
      public static function makeCurtain(dbFacade:DBFacade, sceneGraphComponent:SceneGraphComponent) : Sprite
      {
         if(!dbFacade || !sceneGraphComponent)
         {
            return null;
         }
         var _loc3_:Sprite = new Sprite();
         _loc3_.alpha = 0.75;
         _loc3_.x = 0;
         _loc3_.y = 0;
         _loc3_.graphics.clear();
         _loc3_.graphics.beginFill(0);
         _loc3_.graphics.drawRect(0,0,dbFacade.viewWidth,dbFacade.viewHeight);
         _loc3_.graphics.endFill();
         sceneGraphComponent.addChild(_loc3_,105);
         return _loc3_;
      }
      
      public static function removeCurtain(curtain:Sprite, sceneGraphComponent:SceneGraphComponent) : void
      {
         if(!curtain || !sceneGraphComponent)
         {
            return;
         }
         if(sceneGraphComponent.contains(curtain,105))
         {
            sceneGraphComponent.removeChild(curtain);
         }
         curtain = null;
      }
      
      private function showPopup(level:uint) : void
      {
         var gmSkin:GMSkin = mDBFacade.gameMaster.getSkinByType(mDBFacade.dbAccountInfo.activeAvatarInfo.skinId);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass(gmSkin.PortraitClassName);
            var _loc2_:UIDungeonSummaryLevelUpPopup = new UIDungeonSummaryLevelUpPopup(mDBFacade,null,gmSkin,level,_loc3_);
         });
      }
      
      private function checkToSharePopup(event:Event) : void
      {
         if(mSelectedLevel > 0)
         {
            showPopup(mSelectedLevel);
            mSelectedLevel = 0;
         }
      }
      
      private function setlevelUpPost(event:LevelUpPostEvent) : void
      {
         if(UIDungeonSummaryLevelUpPopup.LEVELS.indexOf(event.level) >= 0)
         {
            mSelectedLevel = event.level;
         }
      }
      
      public function destroy() : void
      {
         if(mEventComponent)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         if(mSceneGraphComponent)
         {
            mSceneGraphComponent.destroy();
            mSceneGraphComponent = null;
         }
         mDBFacade = null;
         mSelectedLevel = 0;
      }
   }
}

