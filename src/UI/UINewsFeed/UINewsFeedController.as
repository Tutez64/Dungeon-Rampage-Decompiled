package UI.UINewsFeed
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.GameObject.GameObject;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DistributedObjects.HeroGameObject;
   import DistributedObjects.PlayerGameObject;
   import Events.FriendStatusEvent;
   import Events.FriendSummaryNewsFeedEvent;
   import Events.GenericNewsFeedEvent;
   import Facade.DBFacade;
   import com.greensock.TweenMax;
   
   public class UINewsFeedController
   {
      
      public static const MAX_VISIBLE_FEEDS:uint = 1;
      
      public static const QUEDED_FEEDS_CHECK_INTERVAL:Number = 0.5;
      
      public static const FEED_HEIGHT_OFFSET:Number = 75;
      
      public static const FEED_LERP_UP_DURATION:Number = 0.16666666666666666;
      
      private var mDBFacade:DBFacade;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mEventComponent:EventComponent;
      
      private var mNewsFeedClass:Class;
      
      private var mVisibleFeeds:Vector.<UINewsFeed>;
      
      private var mQueuedFeeds:Vector.<UINewsFeed>;
      
      private var mNewsFeedTask:Task;
      
      public function UINewsFeedController(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UINewsFeedController");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mVisibleFeeds = new Vector.<UINewsFeed>();
         mQueuedFeeds = new Vector.<UINewsFeed>();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),assetLoaded);
         mEventComponent.addListener("GENERIC_NEWS_FEED_MESSAGE_EVENT",genericNewsFeedMessage);
         mEventComponent.addListener("FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT",friendSummaryStatusUpdate);
      }
      
      public function startFeedTask() : void
      {
         if(mNewsFeedTask)
         {
            mNewsFeedTask.destroy();
         }
         mNewsFeedTask = mLogicalWorkComponent.doEverySeconds(0.5,checkNewsFeedQueue);
         mEventComponent.addListener("FRIEND_STATUS_EVENT",friendOnlineStatusUpdate);
         mEventComponent.addListener("FRIEND_DUNGEON_STATUS_EVENT",friendDungeonStatusUpdate);
      }
      
      public function stopFeedTask() : void
      {
         if(mNewsFeedTask)
         {
            mNewsFeedTask.destroy();
         }
         mNewsFeedTask = null;
         flushFeeds();
         mEventComponent.removeListener("FRIEND_STATUS_EVENT");
         mEventComponent.removeListener("FRIEND_DUNGEON_STATUS_EVENT");
      }
      
      private function assetLoaded(swfAsset:SwfAsset) : void
      {
         mNewsFeedClass = swfAsset.getClass("UI_alertPrompt");
      }
      
      private function friendOnlineStatusUpdate(event:FriendStatusEvent) : void
      {
         var _loc3_:GameObject = mDBFacade.gameObjectManager.getReferenceFromId(event.friendId);
         var _loc4_:PlayerGameObject = _loc3_ as PlayerGameObject;
         if(_loc4_)
         {
            return;
         }
         var _loc2_:UINewsFeed = new UINewsFeed(mDBFacade,new mNewsFeedClass(),removeNewsFeed,0,event);
         if(_loc2_.isValid)
         {
            mQueuedFeeds.push(_loc2_);
         }
      }
      
      private function friendSummaryStatusUpdate(event:FriendSummaryNewsFeedEvent) : void
      {
         var _loc2_:UINewsFeed = new UINewsFeed(mDBFacade,new mNewsFeedClass(),removeNewsFeed,3,event);
         if(_loc2_.isValid)
         {
            mQueuedFeeds.push(_loc2_);
         }
      }
      
      private function friendDungeonStatusUpdate(event:FriendStatusEvent) : void
      {
         var _loc3_:GameObject = mDBFacade.gameObjectManager.getReferenceFromId(mDBFacade.dbAccountInfo.activeAvatarInfo.id);
         var _loc4_:HeroGameObject = _loc3_ as HeroGameObject;
         if(!_loc4_ || !_loc4_.distributedDungeonFloor)
         {
            return;
         }
         if(!mDBFacade.dbAccountInfo.friendInfos.itemFor(event.friendId))
         {
            return;
         }
         var _loc2_:UINewsFeed = new UINewsFeed(mDBFacade,new mNewsFeedClass(),removeNewsFeed,1,event);
         if(_loc2_.isValid)
         {
            mQueuedFeeds.push(_loc2_);
         }
      }
      
      private function genericNewsFeedMessage(event:GenericNewsFeedEvent) : void
      {
         var _loc2_:UINewsFeed = new UINewsFeed(mDBFacade,new mNewsFeedClass(),removeNewsFeed,2,event);
         if(_loc2_.isValid)
         {
            mQueuedFeeds.push(_loc2_);
         }
      }
      
      private function checkNewsFeedQueue(gameClock:GameClock) : void
      {
         if(mQueuedFeeds.length == 0 || mVisibleFeeds.length >= 1)
         {
            return;
         }
         var _loc2_:UINewsFeed = mQueuedFeeds.shift();
         mVisibleFeeds.push(_loc2_);
         _loc2_.root.x = mDBFacade.viewWidth;
         _loc2_.root.y = (mVisibleFeeds.length + 1) * 75;
         _loc2_.lerpIntoScreen();
      }
      
      private function removeNewsFeed(gameClock:GameClock) : void
      {
         var _loc2_:UINewsFeed = mVisibleFeeds.shift();
         _loc2_.destroy();
         lerpAllfeedsUp();
      }
      
      private function lerpAllfeedsUp() : void
      {
         for each(var _loc1_:UINewsFeed in mVisibleFeeds)
         {
            if(_loc1_)
            {
               TweenMax.to(_loc1_.root,0.16666666666666666,{"y":_loc1_.root.y - 75});
            }
         }
      }
      
      private function flushFeeds() : void
      {
         for each(var _loc1_:UINewsFeed in mQueuedFeeds)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
            _loc1_ = null;
         }
         mQueuedFeeds.splice(0,mQueuedFeeds.length);
         for each(_loc1_ in mVisibleFeeds)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
            _loc1_ = null;
         }
         mVisibleFeeds.splice(0,mVisibleFeeds.length);
      }
      
      public function destroy() : void
      {
         flushFeeds();
         mDBFacade = null;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mEventComponent)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         if(mNewsFeedTask)
         {
            mNewsFeedTask.destroy();
         }
         mNewsFeedTask = null;
      }
   }
}

