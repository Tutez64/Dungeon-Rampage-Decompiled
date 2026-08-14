package FacebookAPI
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Event.EventComponent;
   import Brain.SceneGraph.SceneGraphComponent;
   import Events.FacebookLevelUpPostEvent;
   import Facade.DBFacade;
   import GameMasterDictionary.GMFeedPosts;
   import GameMasterDictionary.GMSkin;
   import UI.Popup.UIDungeonSummaryLevelUpPopup;
   import flash.display.Sprite;
   import flash.events.Event;
   import org.as3commons.collections.Map;
   
   public class DBFacebookLevelUpPostController
   {
      
      public static const LEVEL_UP_BRAG:String = "LEVELUP";
      
      public static const TIME_TO_SHARE_LEVEL_UP_EVENT:String = "TIME_TO_SHARE_LEVEL_UP_EVENT";
      
      private var mDBFacade:DBFacade;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mEventComponent:EventComponent;
      
      private var mLevelUpFeedPostsMap:Map;
      
      private var mCurtain:Sprite;
      
      private var mSelectedLevelUpPost:GMFeedPosts;
      
      private var mFeedPostCallbackFunction:Function;
      
      public function DBFacebookLevelUpPostController(dbFacade:DBFacade, feedPostCallback:Function)
      {
         super();
         mDBFacade = dbFacade;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"DBFacebookLevelUpPostController");
         mFeedPostCallbackFunction = feedPostCallback;
         mLevelUpFeedPostsMap = new Map();
         mEventComponent.addListener("FacebookLevelUpPostEvent",setlevelUpPost);
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
      
      private function loadMap() : void
      {
         for each(var _loc1_:GMFeedPosts in mDBFacade.gameMaster.FeedPosts)
         {
            if(_loc1_.Category == "LEVELUP")
            {
               if(!mLevelUpFeedPostsMap.hasKey(_loc1_.LevelTrigger))
               {
                  mLevelUpFeedPostsMap.add(_loc1_.LevelTrigger,_loc1_);
               }
            }
         }
      }
      
      private function showPopup(levelUpPost:GMFeedPosts) : void
      {
         var gmSkin:GMSkin = mDBFacade.gameMaster.getSkinByType(mDBFacade.dbAccountInfo.activeAvatarInfo.skinId);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass(gmSkin.IconName);
            var _loc2_:UIDungeonSummaryLevelUpPopup = new UIDungeonSummaryLevelUpPopup(mDBFacade,null,gmSkin,levelUpPost,_loc3_);
         });
      }
      
      private function checkIfMapIsLoaded() : void
      {
         if(mLevelUpFeedPostsMap.size > 0)
         {
            return;
         }
         loadMap();
      }
      
      private function checkToSharePopup(event:Event) : void
      {
         checkIfMapIsLoaded();
         if(mSelectedLevelUpPost)
         {
            showPopup(mSelectedLevelUpPost);
            mSelectedLevelUpPost = null;
         }
      }
      
      private function setlevelUpPost(event:FacebookLevelUpPostEvent) : void
      {
         checkIfMapIsLoaded();
         if(mLevelUpFeedPostsMap.hasKey(event.level))
         {
            mSelectedLevelUpPost = mLevelUpFeedPostsMap.itemFor(event.level);
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
         mSelectedLevelUpPost = null;
         mLevelUpFeedPostsMap.clear();
         mFeedPostCallbackFunction = null;
      }
   }
}

