package UI.UINewsFeed
{
   import Account.FriendInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Events.ChatLogEvent;
   import Events.FriendStatusEvent;
   import Events.FriendSummaryNewsFeedEvent;
   import Events.GenericNewsFeedEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import UI.UIChatLog;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class UINewsFeed
   {
      
      public static const FRIEND_STATUS_TYPE:uint = 0;
      
      public static const PLAYER_DUNGEON_STATUS_TYPE:uint = 1;
      
      public static const GENERIC_MESSAGE_STATUS_TYPE:uint = 2;
      
      public static const FRIEND_SUMMARY_MESSAGE_STATUS_TYPE:uint = 3;
      
      public static const LERP_INTO_SCREEN_TIME:Number = 0.25;
      
      public static const LERP_OUT_OF_SCREEN_TIME:Number = 0.25;
      
      public static const STAY_ON_SCREEN_DURATION:Number = 5;
      
      public static const FEED_HANGING_OFF_THE_EDGE_OFFSET:Number = 13;
      
      private var mDBFacade:DBFacade;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mRoot:MovieClip;
      
      private var mLabel:TextField;
      
      private var mLabelY:Number;
      
      private var mIcon:MovieClip;
      
      private var mFriendEvent:FriendStatusEvent;
      
      private var mGenericFeedMessageEvent:GenericNewsFeedEvent;
      
      private var mFriendSummaryFeedMessageEvent:FriendSummaryNewsFeedEvent;
      
      private var mFinishedCallback:Function;
      
      private var mIsValid:Boolean = true;
      
      public function UINewsFeed(dbFacade:DBFacade, root:MovieClip, finishedCallback:Function, feedType:uint, event:Event = null)
      {
         super();
         mDBFacade = dbFacade;
         mRoot = root;
         mFinishedCallback = finishedCallback;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UINewsFeed");
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UINewsFeed");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent.addChild(mRoot,50);
         setupUI();
         if(event is FriendStatusEvent)
         {
            mFriendEvent = event as FriendStatusEvent;
            loadFriendDetails();
         }
         else if(event is GenericNewsFeedEvent)
         {
            mGenericFeedMessageEvent = event as GenericNewsFeedEvent;
         }
         else if(event is FriendSummaryNewsFeedEvent)
         {
            mFriendSummaryFeedMessageEvent = event as FriendSummaryNewsFeedEvent;
         }
         else
         {
            mIsValid = false;
         }
         switch(int(feedType))
         {
            case 0:
               prepareFriendStatusFeed();
               break;
            case 1:
               preparePlayerDungeonStatusFeed();
               break;
            case 2:
               prepareGenericMessageFeed();
               break;
            case 3:
               prepareFriendSummaryMessageFeed();
         }
         mRoot.visible = false;
      }
      
      private function setupUI() : void
      {
         mLabel = mRoot.label;
         mLabelY = mLabel.y;
         mIcon = mRoot.icon;
      }
      
      public function lerpIntoScreen() : void
      {
         mRoot.visible = true;
         TweenMax.to(mRoot,0.25,{"x":mRoot.x - mRoot.width / 2 + 13});
         mLogicalWorkComponent.doLater(5,lerpOutOfScreen);
      }
      
      public function lerpOutOfScreen(gameClock:GameClock) : void
      {
         TweenMax.to(mRoot,0.25,{"x":mRoot.x + mRoot.width});
         mLogicalWorkComponent.doLater(0.25,mFinishedCallback);
      }
      
      public function get root() : MovieClip
      {
         return mRoot;
      }
      
      private function loadFriendDetails() : void
      {
         if(!mFriendEvent)
         {
            mIsValid = false;
            return;
         }
         var _loc2_:FriendInfo = mDBFacade.dbAccountInfo.friendInfos.itemFor(mFriendEvent.friendId);
         if(!_loc2_)
         {
            mIsValid = false;
            return;
         }
         var _loc1_:String = _loc2_.name;
         mLabel.text = _loc1_;
         var _loc3_:DisplayObject = _loc2_.clonePic();
         mIcon.addChild(_loc3_);
         _loc3_.x -= 25;
         _loc3_.y -= 25;
      }
      
      private function adjustLabelHeight() : void
      {
         if(mLabel.numLines == 1)
         {
            mLabel.y = mLabelY + mLabel.height * 0.2;
         }
         else
         {
            mLabel.y = mLabelY;
         }
      }
      
      private function prepareFriendStatusFeed() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = "";
         if(mFriendEvent.status)
         {
            _loc2_ += Locale.getString("NEWS_FEED_FRIEND_ONLINE");
            _loc1_ = UIChatLog.FRIEND_STATUS_ONLINE_TYPE;
         }
         else
         {
            _loc2_ += Locale.getString("NEWS_FEED_FRIEND_OFFLINE");
            _loc1_ = UIChatLog.FRIEND_STATUS_OFFLINE_TYPE;
         }
         mLabel.text = mLabel.text.concat(_loc2_);
         mDBFacade.eventManager.dispatchEvent(new ChatLogEvent("CHAT_LOG_EVENT",mLabel.text.toLocaleUpperCase(),_loc1_));
         adjustLabelHeight();
      }
      
      private function preparePlayerDungeonStatusFeed() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = "";
         if(mFriendEvent.status)
         {
            _loc2_ += Locale.getString("NEWS_FEED_PLAYER_JOINED_DUNGEON");
            _loc1_ = UIChatLog.JOINED_DUNGEON_TYPE;
         }
         else
         {
            _loc2_ += Locale.getString("NEWS_FEED_PLAYER_LEFT_DUNGEON");
            _loc1_ = UIChatLog.LEFT_DUNGEON_TYPE;
         }
         mLabel.text = mLabel.text.concat(_loc2_);
         mDBFacade.eventManager.dispatchEvent(new ChatLogEvent("CHAT_LOG_EVENT",mLabel.text.toLocaleUpperCase(),_loc1_));
         adjustLabelHeight();
      }
      
      public function colorizeMessage(tf:TextFormat, start:int, end:int) : void
      {
         mLabel.setTextFormat(tf,start,end);
      }
      
      private function prepareFriendSummaryMessageFeed() : void
      {
         if(!mFriendSummaryFeedMessageEvent)
         {
            mIsValid = false;
            return;
         }
         var _loc1_:TextFormat = new TextFormat();
         _loc1_.color = FriendSummaryNewsFeedEvent.FRIEND_NAME_HIGHLIGHT_COLOR;
         if(mFriendSummaryFeedMessageEvent.isFriendNameInFront)
         {
            mLabel.text = mFriendSummaryFeedMessageEvent.friendName + mFriendSummaryFeedMessageEvent.message;
            colorizeMessage(_loc1_,0,mFriendSummaryFeedMessageEvent.friendName.length);
         }
         else
         {
            mLabel.text = mFriendSummaryFeedMessageEvent.message + mFriendSummaryFeedMessageEvent.friendName;
            colorizeMessage(_loc1_,mFriendSummaryFeedMessageEvent.message.length,mFriendSummaryFeedMessageEvent.message.length + mFriendSummaryFeedMessageEvent.friendName.length);
         }
         adjustLabelHeight();
         var _loc2_:MovieClip = mFriendSummaryFeedMessageEvent.pic;
         _loc2_.scaleX = _loc2_.scaleY = 0.75;
         mIcon.addChild(_loc2_);
      }
      
      private function prepareGenericMessageFeed() : void
      {
         var picLocation:String;
         var picClassName:String;
         if(!mGenericFeedMessageEvent)
         {
            mIsValid = false;
            return;
         }
         mLabel.text = mGenericFeedMessageEvent.message;
         adjustLabelHeight();
         picLocation = mGenericFeedMessageEvent.picLocation;
         picClassName = mGenericFeedMessageEvent.picClassName;
         if(picLocation != "")
         {
            if(picClassName != "")
            {
               mAssetLoadingComponent.getSwfAsset(picLocation,function(param1:SwfAsset):void
               {
                  var _loc2_:Class = param1.getClass(picClassName);
                  var _loc3_:MovieClip = new _loc2_();
                  _loc3_.scaleX = _loc3_.scaleY = 1.07;
                  _loc3_.x -= _loc3_.width / 2 + 10;
                  _loc3_.y -= _loc3_.height / 2;
                  mIcon.addChild(_loc3_);
               });
            }
         }
      }
      
      public function get isValid() : Boolean
      {
         return mIsValid;
      }
      
      public function destroy() : void
      {
         if(mSceneGraphComponent.contains(mRoot,50))
         {
            mSceneGraphComponent.removeChild(mRoot);
         }
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mSceneGraphComponent)
         {
            mSceneGraphComponent.destroy();
         }
         mSceneGraphComponent = null;
         mDBFacade = null;
         mFinishedCallback = null;
         mRoot = null;
         mLabel = null;
         mIcon = null;
         mFriendEvent = null;
      }
   }
}

