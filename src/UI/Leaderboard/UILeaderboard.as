package UI.Leaderboard
{
   import Account.FriendInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Event.EventComponent;
   import Brain.Event.EventListeners;
   import Brain.Render.MovieClipRenderController;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.SceneGraph.SceneGraphManager;
   import Brain.UI.UIButton;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.jsonRPC.JSONRPCService;
   import Collections.Map;
   import Facade.DBFacade;
   import Facade.Locale;
   import Town.TownStateMachine;
   import UI.Popup.DBUITwoButtonPopup;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class UILeaderboard
   {
      
      private static var FRIEND_NAME_HIGHLIGHT_COLOR:uint = 16764232;
      
      public static const LEADERBOARD_INITIALIZED_EVENT_NAME:String = "LEADERBOARD_INITIALIZED_EVENT";
      
      public static const REFRESH_FRIENDS_EVENT_NAME:String = "REFRESH_FRIENDS_EVENT";
      
      public static const REVERSE_FRIEND_SLOT:Boolean = false;
      
      public static const FRIEND_SLOTS_PER_TOWN_BUTTON:int = 3;
      
      public static const ONLINE_POPUP_TITLE_MAX_LINES:int = 2;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mEventComponent:EventComponent;
      
      private var mDBFacade:DBFacade;
      
      public var townSwf:SwfAsset;
      
      private var mRootMovieClip:MovieClip;
      
      private var mLeaderboard:MovieClip;
      
      private var mOnlinePopup:MovieClip;
      
      private var mOfflinePopup:MovieClip;
      
      private var mOnlinePopupBg:DisplayObject;
      
      private var mOnlinePopupBgScaleY:Number;
      
      private var mOnlinePopupBgY:Number;
      
      private var mOnlinePopupTitleY:Number;
      
      private var mOnlinePopupTitleHeight:Number;
      
      private var mMessageFriendButton:UIButton;
      
      private var mRemoveOnlineFriendButton:UIButton;
      
      private var mRemoveOfflineFriendButton:UIButton;
      
      private var mGiftFriendButton:UIButton;
      
      private var mScrollRightButton:UIButton;
      
      private var mScrollLeftButton:UIButton;
      
      private var mScrollPageRightButton:UIButton;
      
      private var mScrollPageLeftButton:UIButton;
      
      private var mDRRemoveFriendPopup:DBUITwoButtonPopup;
      
      private var mFriendSlots:Vector.<LeaderboardFriendSlot>;
      
      private var mInviteFriendSlot:LeaderboardFriendSlot;
      
      private var mInviteFriendButton:UIButton;
      
      private var mOnlineFriends:Vector.<FriendInfo>;
      
      private var mOfflineFriends:Vector.<FriendInfo>;
      
      private var mFriendsLength:uint;
      
      private var mCurrentPopupIndex:uint;
      
      private var mScrollIndex:int = 0;
      
      private var mRefreshLeaderboard:Boolean;
      
      private var mCurrentStateName:String;
      
      private var mStoreCallback:Function;
      
      private var mGetGiftsCallback:Function;
      
      public var initialized:Boolean;
      
      private var mTownStateMachine:TownStateMachine;
      
      private var mFriendManagementButton:UIButton;
      
      private var mTownButtons:Array;
      
      private var mAlert:MovieClip;
      
      private var mAlertRenderer:MovieClipRenderController;
      
      public function UILeaderboard(dbFacade:DBFacade, rootSwf:SwfAsset, storeCallback:Function, getGiftsCallback:Function, townStateMachine:TownStateMachine)
      {
         super();
         mDBFacade = dbFacade;
         townSwf = rootSwf;
         mRootMovieClip = rootSwf.root;
         mStoreCallback = storeCallback;
         mGetGiftsCallback = getGiftsCallback;
         mFriendSlots = new Vector.<LeaderboardFriendSlot>();
         mOnlineFriends = new Vector.<FriendInfo>();
         mOfflineFriends = new Vector.<FriendInfo>();
         mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mSceneGraphComponent = new SceneGraphComponent(dbFacade,"UILeaderboard");
         mLogicalWorkComponent = new LogicalWorkComponent(dbFacade,"UILeaderboard");
         mEventComponent = new EventComponent(mDBFacade);
         mTownStateMachine = townStateMachine;
      }
      
      public function preLoadSWF() : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_leaderboard.swf"),leaderboardLoaded);
      }
      
      public function loadRemoveFriendPopup(info:FriendInfo) : void
      {
         var tf:TextFormat;
         var mcClass:Class = townSwf.getClass("popup");
         var colorizeStart:uint = uint(Locale.getString("LEADERBOARD_DR_REMOVE_FRIEND_POPUP_DESC_1").length);
         mDRRemoveFriendPopup = new DBUITwoButtonPopup(mDBFacade,"LEADERBOARD_REMOVE_FRIEND_POPUP",Locale.getString("LEADERBOARD_DR_REMOVE_FRIEND_POPUP_TITLE"),Locale.getString("LEADERBOARD_DR_REMOVE_FRIEND_POPUP_DESC_1") + info.name + Locale.getString("LEADERBOARD_DR_REMOVE_FRIEND_POPUP_DESC_2"),Locale.getString("REMOVE"),function():void
         {
            var _loc2_:Array = [];
            _loc2_.push(info.id);
            var _loc1_:Function = JSONRPCService.getFunction("DRFriendRemove",mDBFacade.rpcRoot + "friendrequests");
            _loc1_(mDBFacade.accountId,_loc2_,mDBFacade.validationToken,mDBFacade.dbAccountInfo.removeFriendCallback);
            mDBFacade.metrics.log("DRFriendRemove",{"friendId":info.id.toString()});
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(mDRRemoveFriendPopup,"DBUITwoButtonPopup - created in UILeaderboard.loadRemoveFriendPopup()");
         tf = new TextFormat();
         tf.color = FRIEND_NAME_HIGHLIGHT_COLOR;
         mDRRemoveFriendPopup.colorizeMessage(tf,colorizeStart,colorizeStart + info.name.length);
      }
      
      private function leaderboardLoaded(swfAsset:SwfAsset) : void
      {
         if(!swfAsset)
         {
            return;
         }
         loadOnlinePopup(swfAsset);
         loadOfflinePopup(swfAsset);
         loadLeaderboard(swfAsset);
         setInitialScrollBarStatus();
         initialized = true;
         mEventComponent.dispatchEvent(new Event("LEADERBOARD_INITIALIZED_EVENT"));
         getFriendData();
      }
      
      private function loadOnlinePopup(swfAsset:SwfAsset) : void
      {
         var title:TextField;
         var i:int;
         var child:DisplayObject;
         var mcClass:Class = swfAsset.getClass("DR_leaderboard_online_tooltip");
         mOnlinePopup = new mcClass();
         if(!mOnlinePopup)
         {
            return;
         }
         mRootMovieClip.addChild(mOnlinePopup);
         mOnlinePopup.visible = false;
         mGiftFriendButton = new UIButton(mDBFacade,mOnlinePopup.join_friend);
         Locale.setText(mGiftFriendButton.label,"LEADERBOARD_GIFT_FRIEND_BUTTON");
         mGiftFriendButton.navigationSelectedInteraction = callStopOnPopupTimeToLiveTask;
         mGiftFriendButton.releaseCallback = function():void
         {
            if(mStoreCallback != null)
            {
               mStoreCallback();
            }
         };
         mRemoveOnlineFriendButton = new UIButton(mDBFacade,mOnlinePopup.remove_friend);
         Locale.setText(mRemoveOnlineFriendButton.label,"LEADERBOARD_REMOVE_FRIEND_BUTTON");
         mRemoveOnlineFriendButton.navigationSelectedInteraction = callStopOnPopupTimeToLiveTask;
         mRemoveOnlineFriendButton.releaseCallback = removeFriends;
         title = mOnlinePopup.title_label;
         title.mouseEnabled = false;
         title.multiline = true;
         title.wordWrap = true;
         mOnlinePopupTitleY = title.y;
         mOnlinePopupTitleHeight = title.height;
         i = 0;
         while(i < mOnlinePopup.numChildren)
         {
            child = mOnlinePopup.getChildAt(i);
            if(child.name.indexOf("instance") == 0)
            {
               mOnlinePopupBg = child;
               break;
            }
            i = i + 1;
         }
         if(mOnlinePopupBg)
         {
            mOnlinePopupBgScaleY = mOnlinePopupBg.scaleY;
            mOnlinePopupBgY = mOnlinePopupBg.y;
         }
         mOnlinePopup.nextassist.mouseEnabled = false;
         Locale.setText(mOnlinePopup.nextassist,"LEADERBOARD_NEXT_ASSIST");
         mOnlinePopup.nextassist.visible = false;
         mOnlinePopup.assist_time.visible = false;
         EventListeners.add(mOnlinePopup,"rollOver",callStopOnPopupTimeToLiveTask);
         EventListeners.add(mOnlinePopup,"rollOut",hidePopup);
      }
      
      private function loadOfflinePopup(swfAsset:SwfAsset) : void
      {
         var _loc2_:Class = swfAsset.getClass("DR_leaderboard_offline_tooltip");
         mOfflinePopup = new _loc2_();
         if(!mOfflinePopup)
         {
            return;
         }
         mRootMovieClip.addChild(mOfflinePopup);
         mOfflinePopup.visible = false;
         SceneGraphManager.setGrayScaleSaturation(mOfflinePopup.join_friend,10);
         mOfflinePopup.title_label.mouseEnabled = false;
         Locale.setText(mOfflinePopup.title_label,"LEADERBOARD_OFFLINE_TEXT");
         mOfflinePopup.join_friend.label.mouseEnabled = false;
         Locale.setText(mOfflinePopup.join_friend.label,"LEADERBOARD_JOIN_FRIEND_BUTTON");
         mOfflinePopup.nextassist.mouseEnabled = false;
         Locale.setText(mOfflinePopup.nextassist,"LEADERBOARD_NEXT_ASSIST");
         mMessageFriendButton = new UIButton(mDBFacade,mOfflinePopup.message_friend);
         Locale.setText(mMessageFriendButton.label,"LEADERBOARD_MESSAGE_FRIEND_BUTTON");
         mMessageFriendButton.navigationSelectedInteraction = callStopOnPopupTimeToLiveTask;
         disableMessageFriendButton();
         mRemoveOfflineFriendButton = new UIButton(mDBFacade,mOfflinePopup.remove_friend);
         Locale.setText(mRemoveOfflineFriendButton.label,"LEADERBOARD_REMOVE_FRIEND_BUTTON");
         mRemoveOfflineFriendButton.navigationSelectedInteraction = callStopOnPopupTimeToLiveTask;
         mRemoveOfflineFriendButton.releaseCallback = removeFriends;
         mOfflinePopup.nextassist.visible = false;
         mOfflinePopup.assist_time.visible = false;
         EventListeners.add(mOfflinePopup,"rollOver",callStopOnPopupTimeToLiveTask);
         EventListeners.add(mOfflinePopup,"rollOut",hidePopup);
      }
      
      private function loadLeaderboard(swfAsset:SwfAsset) : void
      {
         var leaderboard:Class = swfAsset.getClass("DR_leaderboard");
         mLeaderboard = new leaderboard();
         mLeaderboard.y = mDBFacade.viewHeight - mLeaderboard.height;
         mRootMovieClip.addChild(mLeaderboard);
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,mLeaderboard.slot_0,this,0));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,mLeaderboard.slot_1,this,1));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,mLeaderboard.slot_2,this,2));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,mLeaderboard.slot_3,this,3));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,mLeaderboard.slot_4,this,4));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,mLeaderboard.slot_5,this,5));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,mLeaderboard.slot_6,this,6));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,mLeaderboard.slot_7,this,7));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,mLeaderboard.slot_8,this,8));
         mInviteFriendButton = new UIButton(mDBFacade,mLeaderboard.invite_friend);
         Locale.setText(mInviteFriendButton.label,"INVITE_POPUP_BUTTON");
         mInviteFriendButton.releaseCallback = inviteFriendDR;
         mScrollRightButton = new UIButton(mDBFacade,mLeaderboard.scrollRight);
         mScrollLeftButton = new UIButton(mDBFacade,mLeaderboard.scrollLeft);
         mScrollPageRightButton = new UIButton(mDBFacade,mLeaderboard.scrollPageRight);
         mScrollPageLeftButton = new UIButton(mDBFacade,mLeaderboard.scrollPageLeft);
         mScrollRightButton.releaseCallback = function():void
         {
            scrollLeaderboard(-1);
         };
         mScrollLeftButton.releaseCallback = function():void
         {
            scrollLeaderboard(1);
         };
         mScrollPageRightButton.releaseCallback = function():void
         {
            scrollLeaderboard(-mFriendSlots.length);
         };
         mScrollPageLeftButton.releaseCallback = function():void
         {
            scrollLeaderboard(mFriendSlots.length);
         };
         mDBFacade.dbAccountInfo.getIgnoredFriendData();
         mFriendManagementButton = new UIButton(mDBFacade,mLeaderboard.block_button);
         Locale.setText(mFriendManagementButton.label,"FRIEND_MANAGEMENT_HEADING_FRIENDS");
         mFriendManagementButton.releaseCallback = function():void
         {
            mTownStateMachine.enterFriendManagementState();
         };
         mAlert = mLeaderboard.block_button.alert_icon;
         mAlertRenderer = new MovieClipRenderController(mDBFacade,mAlert);
         mAlertRenderer.play(0,true);
         mAlert.visible = false;
      }
      
      public function inviteFriendDR() : void
      {
         hidePopup();
         mDBFacade.metrics.log("InviteLeaderboardClickedDR");
         showDRInvitePopup();
      }
      
      public function setupNavigationlinks() : void
      {
         var _loc5_:int = 0;
         mFriendManagementButton.clearLeftNavigation();
         mFriendManagementButton.clearRightNavigation();
         mInviteFriendButton.clearLeftNavigation();
         mInviteFriendButton.clearRightNavigation();
         var _loc2_:Array = [mScrollLeftButton,mScrollPageLeftButton,mScrollRightButton,mScrollPageRightButton];
         for each(var _loc6_:UIButton in _loc2_)
         {
            _loc6_.clearLeftNavigation();
            _loc6_.clearRightNavigation();
            _loc6_.clearUpNavigation();
            _loc6_.clearDownNavigation();
         }
         for each(var _loc4_:LeaderboardFriendSlot in mFriendSlots)
         {
            _loc4_.friendPicButton.clearLeftNavigation();
            _loc4_.friendPicButton.clearRightNavigation();
         }
         var _loc3_:UIButton = mFriendSlots[mFriendSlots.length - 1].friendPicButton;
         var _loc1_:UIButton = mFriendSlots[0].friendPicButton;
         mFriendManagementButton.isToTheLeftOf(mScrollLeftButton);
         mScrollLeftButton.isToTheLeftOf(_loc3_);
         mScrollLeftButton.isAbove(mScrollPageLeftButton);
         mScrollPageLeftButton.leftNavigation = mFriendManagementButton;
         mScrollPageLeftButton.rightNavigation = _loc3_;
         _loc5_ = mFriendSlots.length - 1;
         while(_loc5_ > 0)
         {
            mFriendSlots[_loc5_].friendPicButton.isToTheLeftOf(mFriendSlots[_loc5_ - 1].friendPicButton);
            _loc5_--;
         }
         _loc1_.isToTheLeftOf(mScrollRightButton);
         mScrollRightButton.isToTheLeftOf(mInviteFriendButton);
         mScrollRightButton.isAbove(mScrollPageRightButton);
         mScrollPageRightButton.leftNavigation = _loc1_;
         mScrollPageRightButton.rightNavigation = mInviteFriendButton;
         _loc3_.leftNavigationAdditionalInteraction = minimizeCurrentPopup;
         _loc1_.rightNavigationAdditionalInteraction = minimizeCurrentPopup;
      }
      
      public function focusPreviousFriendSlot() : void
      {
         focusAdjacentFriendSlot(1);
      }
      
      public function focusNextFriendSlot() : void
      {
         focusAdjacentFriendSlot(-1);
      }
      
      private function focusAdjacentFriendSlot(direction:int) : void
      {
         var _loc3_:uint = 0;
         var _loc5_:int = 0;
         if(mFriendSlots.length == 0)
         {
            return;
         }
         var _loc2_:int = -1;
         _loc3_ = 0;
         while(_loc3_ < mFriendSlots.length)
         {
            if(mFriendSlots[_loc3_].friendPicButton.isFocused())
            {
               _loc2_ = int(_loc3_);
               break;
            }
            _loc3_++;
         }
         if(_loc2_ < 0 && (mGiftFriendButton.isFocused() || mRemoveOnlineFriendButton.isFocused() || mMessageFriendButton.isFocused() || mRemoveOfflineFriendButton.isFocused()))
         {
            _loc2_ = int(mCurrentPopupIndex);
         }
         if(_loc2_ < 0)
         {
            _loc5_ = direction < 0 ? mFriendSlots.length - 1 : 0;
         }
         else if(int(mFriendsLength) <= mFriendSlots.length)
         {
            _loc5_ = (_loc2_ + direction + mFriendSlots.length) % mFriendSlots.length;
         }
         else
         {
            _loc5_ = scrollFriendIntoView(_loc2_ + mScrollIndex + direction);
         }
         var _loc4_:UIButton = mFriendSlots[_loc5_].friendPicButton;
         mDBFacade.menuNavigationController.setFocusedUiObject(_loc4_);
         if(Boolean(_loc4_.navigationSelectedInteraction))
         {
            _loc4_.navigationSelectedInteraction();
         }
      }
      
      private function scrollFriendIntoView(friendIndex:int) : int
      {
         var _loc5_:int = 0;
         var _loc2_:int = int(mFriendsLength);
         var _loc3_:int = int(mFriendSlots.length);
         if(friendIndex < 0)
         {
            friendIndex = _loc2_ - 1;
         }
         else if(friendIndex >= _loc2_)
         {
            friendIndex = 0;
         }
         var _loc4_:int = mScrollIndex;
         if(friendIndex < mScrollIndex)
         {
            _loc4_ = friendIndex;
         }
         else if(friendIndex > mScrollIndex + _loc3_ - 1)
         {
            _loc4_ = friendIndex - _loc3_ + 1;
         }
         if(_loc4_ != mScrollIndex)
         {
            _loc5_ = _loc4_ - mScrollIndex;
            scrollLeaderboard(_loc5_);
         }
         return friendIndex - mScrollIndex;
      }
      
      public function setupTooltipNavigation(friendPicButton:UIButton, firstButton:UIButton, secondButton:UIButton = null) : void
      {
         for each(var _loc5_:LeaderboardFriendSlot in mFriendSlots)
         {
            resetFriendSlotUpNavigation(_loc5_.friendPicButton);
         }
         var _loc6_:Array = [mGiftFriendButton,mRemoveOnlineFriendButton,mMessageFriendButton,mRemoveOfflineFriendButton];
         for each(var _loc8_:UIButton in _loc6_)
         {
            _loc8_.clearLeftNavigation();
            _loc8_.clearRightNavigation();
            _loc8_.clearUpNavigation();
            _loc8_.clearDownNavigation();
         }
         friendPicButton.clearUpNavigation();
         friendPicButton.upNavigation = firstButton;
         firstButton.downNavigation = friendPicButton;
         if(secondButton)
         {
            secondButton.isAbove(firstButton);
         }
         var _loc4_:UIButton = secondButton ? secondButton : firstButton;
         var _loc7_:UIButton = townButtonAbove(mCurrentPopupIndex);
         if(_loc7_)
         {
            _loc4_.upNavigation = _loc7_;
            _loc4_.upNavigationAdditionalInteraction = minimizeCurrentPopup;
         }
      }
      
      public function linkTownButtons(townButtons:Array) : void
      {
         var _loc4_:int = 0;
         var _loc3_:UIButton = null;
         mTownButtons = townButtons;
         _loc4_ = 0;
         while(_loc4_ < townButtons.length)
         {
            _loc3_ = townButtons[_loc4_];
            _loc3_.clearDownNavigation();
            _loc3_.downNavigation = mFriendSlots[mFriendSlots.length - 1 - _loc4_ * 3].friendPicButton;
            _loc4_++;
         }
         for each(var _loc2_:LeaderboardFriendSlot in mFriendSlots)
         {
            resetFriendSlotUpNavigation(_loc2_.friendPicButton);
         }
         mFriendManagementButton.clearUpNavigation();
         mFriendManagementButton.upNavigation = townButtons[0];
         mInviteFriendButton.clearUpNavigation();
         mInviteFriendButton.upNavigation = townButtons[townButtons.length - 1];
      }
      
      private function townButtonAbove(friendSlotIndex:int) : UIButton
      {
         if(!mTownButtons || friendSlotIndex < 0)
         {
            return null;
         }
         var _loc2_:int = mFriendSlots.length - 1 - friendSlotIndex;
         return mTownButtons[Math.min(int(_loc2_ / 3),mTownButtons.length - 1)];
      }
      
      private function minimizeCurrentPopup() : void
      {
         callStopOnPopupTimeToLiveTask();
         mFriendSlots[mCurrentPopupIndex].minimizePopup();
      }
      
      public function resetFriendSlotUpNavigation(friendPicButton:UIButton) : void
      {
         friendPicButton.clearUpNavigation();
         var _loc2_:UIButton = townButtonAbove(friendSlotIndexOf(friendPicButton));
         if(_loc2_)
         {
            friendPicButton.upNavigation = _loc2_;
         }
      }
      
      private function friendSlotIndexOf(friendPicButton:UIButton) : int
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < mFriendSlots.length)
         {
            if(mFriendSlots[_loc2_].friendPicButton == friendPicButton)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function showDRInvitePopup() : void
      {
         townStateMachine.setFriendManagementTabCategory(4);
         townStateMachine.enterFriendManagementState();
         townStateMachine.setFriendManagementTabCategory(1);
      }
      
      private function friendDataSuccessCallback() : void
      {
         if(mDBFacade)
         {
            loadFriends();
         }
         if(mEventComponent)
         {
            mEventComponent.addListener("REFRESH_FRIENDS_EVENT",checkToRefreshLeaderboard);
         }
         if(mGetGiftsCallback != null)
         {
            mGetGiftsCallback();
         }
      }
      
      public function getFriendData() : void
      {
         if(mDBFacade.dbAccountInfo.friendInfos.size > 0)
         {
            friendDataSuccessCallback();
            return;
         }
         mDBFacade.dbAccountInfo.getFriendData(friendDataSuccessCallback);
      }
      
      private function populateFriendSlots() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:uint = 0;
         var _loc4_:uint = 0;
         var _loc3_:uint = 0;
         _loc1_ = 0;
         while(_loc1_ < mFriendSlots.length)
         {
            mFriendSlots[_loc1_].populateSlot(null);
            _loc2_ = _loc1_ + mScrollIndex;
            if(_loc2_ < mOnlineFriends.length)
            {
               mFriendSlots[_loc1_].populateSlot(mOnlineFriends[_loc2_]);
            }
            else if(_loc2_ - mOnlineFriends.length < mOfflineFriends.length)
            {
               mFriendSlots[_loc1_].populateSlot(mOfflineFriends[_loc2_ - mOnlineFriends.length]);
            }
            _loc1_++;
         }
      }
      
      private function scrollLeaderboard(value:int) : void
      {
         hidePopup();
         mScrollIndex += value;
         if(mScrollIndex > mFriendsLength - mFriendSlots.length)
         {
            mScrollIndex = mFriendsLength - mFriendSlots.length;
         }
         if(mScrollIndex < 0 || mFriendsLength < mFriendSlots.length)
         {
            mScrollIndex = 0;
         }
         if(mScrollIndex == 0)
         {
            mScrollRightButton.enabled = false;
            mScrollPageRightButton.enabled = false;
         }
         else
         {
            mScrollRightButton.enabled = true;
            mScrollPageRightButton.enabled = true;
         }
         if(mScrollIndex == mFriendsLength - mFriendSlots.length)
         {
            mScrollLeftButton.enabled = false;
            mScrollPageLeftButton.enabled = false;
         }
         else
         {
            mScrollLeftButton.enabled = true;
            mScrollPageLeftButton.enabled = true;
         }
         populateFriendSlots();
         moveFocusOffSpentScrollButton();
      }
      
      private function moveFocusOffSpentScrollButton() : void
      {
         if(!mScrollLeftButton.enabled && (mScrollLeftButton.isFocused() || mScrollPageLeftButton.isFocused()))
         {
            mDBFacade.menuNavigationController.setFocusedUiObject(mFriendSlots[mFriendSlots.length - 1].friendPicButton);
         }
         else if(!mScrollRightButton.enabled && (mScrollRightButton.isFocused() || mScrollPageRightButton.isFocused()))
         {
            mDBFacade.menuNavigationController.setFocusedUiObject(mFriendSlots[0].friendPicButton);
         }
      }
      
      private function loadFriends() : void
      {
         var _loc3_:FriendInfo = null;
         var _loc2_:FriendInfo = null;
         var _loc4_:Map = mDBFacade.dbAccountInfo.friendInfos;
         var _loc1_:Array = _loc4_.keysToArray();
         mOfflineFriends.splice(0,mOfflineFriends.length);
         mOnlineFriends.splice(0,mOnlineFriends.length);
         for each(var _loc5_:uint in _loc1_)
         {
            _loc2_ = _loc4_.itemFor(_loc5_);
            if(_loc2_.id == mDBFacade.accountId)
            {
               _loc3_ = _loc2_;
            }
            else if(_loc2_.isOnline())
            {
               mOnlineFriends.push(_loc2_);
            }
            else
            {
               mOfflineFriends.push(_loc2_);
            }
         }
         sortFriends();
         mOnlineFriends.unshift(_loc3_);
         mFriendsLength = mOnlineFriends.length + mOfflineFriends.length;
         if(mFriendsLength <= mFriendSlots.length)
         {
            mScrollLeftButton.enabled = false;
            mScrollPageLeftButton.enabled = false;
         }
         populateFriendSlots();
      }
      
      private function removeFriends() : void
      {
      }
      
      private function sortFriends() : void
      {
         mOnlineFriends.sort(sortBasedOnFriendsHighestAvatarLevel);
         mOfflineFriends.sort(sortBasedOnFriendsHighestAvatarLevel);
      }
      
      private function sortBasedOnFriendsHighestAvatarLevel(friend1:FriendInfo, friend2:FriendInfo) : int
      {
         if(friend1.trophies < friend2.trophies)
         {
            return 1;
         }
         return -1;
      }
      
      public function hidePopup(event:MouseEvent = null) : void
      {
         releaseTooltipFocus();
         if(mRefreshLeaderboard)
         {
            refreshLeaderboard();
         }
         if(mOnlinePopup)
         {
            mOnlinePopup.visible = false;
         }
         if(mOfflinePopup)
         {
            mOfflinePopup.visible = false;
         }
      }
      
      public function releaseTooltipFocus() : void
      {
         if(mFriendSlots.length == 0)
         {
            return;
         }
         if(mGiftFriendButton.isFocused() || mRemoveOnlineFriendButton.isFocused() || mMessageFriendButton.isFocused() || mRemoveOfflineFriendButton.isFocused())
         {
            mDBFacade.menuNavigationController.setFocusedUiObject(mFriendSlots[mCurrentPopupIndex].friendPicButton);
         }
         for each(var _loc1_:LeaderboardFriendSlot in mFriendSlots)
         {
            resetFriendSlotUpNavigation(_loc1_.friendPicButton);
         }
      }
      
      public function set alert(val:Boolean) : void
      {
         mAlert.visible = val;
      }
      
      public function get onlinePopup() : MovieClip
      {
         return mOnlinePopup;
      }
      
      public function setOnlinePopupTitle(text:String) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:TextField = mOnlinePopup.title_label;
         _loc3_.y = mOnlinePopupTitleY;
         _loc3_.height = mOnlinePopupTitleHeight * 2;
         if(mOnlinePopupBg)
         {
            mOnlinePopupBg.scaleY = mOnlinePopupBgScaleY;
            mOnlinePopupBg.y = mOnlinePopupBgY;
         }
         TextUtil.setText(_loc3_,text);
         var _loc4_:int = Math.max(0,_loc3_.numLines - 1);
         var _loc5_:Number = _loc4_ > 0 ? _loc4_ * _loc3_.getLineMetrics(0).height * Math.abs(_loc3_.scaleY) : 0;
         _loc3_.height = mOnlinePopupTitleHeight + _loc5_;
         _loc3_.y -= _loc5_;
         if(mOnlinePopupBg && _loc5_ > 0)
         {
            _loc2_ = mOnlinePopupBg.getBounds(mOnlinePopup).bottom;
            mOnlinePopupBg.height += _loc5_;
            mOnlinePopupBg.y += _loc2_ - mOnlinePopupBg.getBounds(mOnlinePopup).bottom;
         }
      }
      
      public function get offlinePopup() : MovieClip
      {
         return mOfflinePopup;
      }
      
      public function get messageFriend() : UIButton
      {
         return mMessageFriendButton;
      }
      
      public function get removeOnlineFriend() : UIButton
      {
         return mRemoveOnlineFriendButton;
      }
      
      public function get removeOfflineFriend() : UIButton
      {
         return mRemoveOfflineFriendButton;
      }
      
      public function get giftFriend() : UIButton
      {
         return mGiftFriendButton;
      }
      
      public function setRootMovieClip(root:MovieClip) : void
      {
         mRootMovieClip = root;
         if(mOnlinePopup)
         {
            mRootMovieClip.addChild(mOnlinePopup);
         }
         if(mOfflinePopup)
         {
            mRootMovieClip.addChild(mOfflinePopup);
         }
         if(mLeaderboard)
         {
            mRootMovieClip.addChild(mLeaderboard);
         }
      }
      
      public function setInitialScrollBarStatus() : void
      {
         mScrollRightButton.enabled = false;
         mScrollPageRightButton.enabled = false;
      }
      
      private function checkToRefreshLeaderboard(event:Event) : void
      {
         if(mOnlinePopup.visible || mOfflinePopup.visible)
         {
            mRefreshLeaderboard = true;
         }
         else
         {
            refreshLeaderboard();
         }
      }
      
      public function refreshLeaderboard() : void
      {
         mRefreshLeaderboard = false;
         hidePopup();
         loadFriends();
      }
      
      public function set currentPopupIndex(value:uint) : void
      {
         mCurrentPopupIndex = value;
      }
      
      public function get currentPopupIndex() : uint
      {
         return mCurrentPopupIndex;
      }
      
      public function get mustRefreshLeaderboard() : Boolean
      {
         return mRefreshLeaderboard;
      }
      
      public function callStopOnPopupTimeToLiveTask(event:MouseEvent = null) : void
      {
         for each(var _loc2_:LeaderboardFriendSlot in mFriendSlots)
         {
            _loc2_.stopPopupTimeToLiveTask();
         }
      }
      
      public function destroy() : void
      {
         initialized = false;
         mDBFacade = null;
         for each(var _loc2_:LeaderboardFriendSlot in mFriendSlots)
         {
            _loc2_.destroy();
            _loc2_ = null;
         }
         if(mInviteFriendSlot)
         {
            mInviteFriendSlot.destroy();
         }
         mInviteFriendSlot = null;
         if(mInviteFriendButton)
         {
            mInviteFriendButton.destroy();
         }
         mInviteFriendButton = null;
         if(mAlertRenderer != null)
         {
            mAlertRenderer.destroy();
         }
         mAlertRenderer = null;
         for each(var _loc3_:FriendInfo in mOnlineFriends)
         {
            _loc3_ = null;
         }
         for each(var _loc1_:FriendInfo in mOfflineFriends)
         {
            _loc1_ = null;
         }
         if(mEventComponent)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mSceneGraphComponent)
         {
            mSceneGraphComponent.destroy();
         }
         mSceneGraphComponent = null;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mMessageFriendButton)
         {
            mMessageFriendButton.destroy();
         }
         mMessageFriendButton = null;
         if(mRemoveOnlineFriendButton)
         {
            mRemoveOnlineFriendButton.destroy();
         }
         mRemoveOnlineFriendButton = null;
         if(mRemoveOfflineFriendButton)
         {
            mRemoveOfflineFriendButton.destroy();
         }
         mRemoveOfflineFriendButton = null;
         if(mGiftFriendButton)
         {
            mGiftFriendButton.destroy();
         }
         mGiftFriendButton = null;
         if(mScrollRightButton)
         {
            mScrollRightButton.destroy();
         }
         mScrollRightButton = null;
         if(mScrollLeftButton)
         {
            mScrollLeftButton.destroy();
         }
         mScrollLeftButton = null;
         if(mScrollPageRightButton)
         {
            mScrollPageRightButton.destroy();
         }
         mScrollPageRightButton = null;
         if(mScrollPageLeftButton)
         {
            mScrollPageLeftButton.destroy();
         }
         mScrollPageLeftButton = null;
         mRootMovieClip = null;
         mLeaderboard = null;
         mOnlinePopupBg = null;
         mOnlinePopup = null;
         mOfflinePopup = null;
         mStoreCallback = null;
         mGetGiftsCallback = null;
      }
      
      public function set currentStateName(value:String) : void
      {
         mCurrentStateName = value;
      }
      
      public function get currentStateName() : String
      {
         return mCurrentStateName;
      }
      
      public function get onlineFriends() : Vector.<FriendInfo>
      {
         return mOnlineFriends;
      }
      
      public function get offlineFriends() : Vector.<FriendInfo>
      {
         return mOfflineFriends;
      }
      
      public function get townStateMachine() : TownStateMachine
      {
         return mTownStateMachine;
      }
      
      public function get getManageFriendsButton() : UIButton
      {
         return mFriendManagementButton;
      }
      
      public function get getInviteFriendsButton() : UIButton
      {
         return mInviteFriendButton;
      }
      
      public function enableMessageFriendButton() : void
      {
         SceneGraphManager.setGrayScaleSaturation(mOfflinePopup.message_friend,100);
         mOfflinePopup.message_friend.label.mouseEnabled = true;
         mMessageFriendButton.enabled = true;
      }
      
      public function disableMessageFriendButton() : void
      {
         SceneGraphManager.setGrayScaleSaturation(mOfflinePopup.message_friend,10);
         mOfflinePopup.message_friend.label.mouseEnabled = false;
         mMessageFriendButton.enabled = false;
      }
   }
}

