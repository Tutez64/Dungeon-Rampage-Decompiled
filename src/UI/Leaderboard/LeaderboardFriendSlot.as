package UI.Leaderboard
{
   import Account.FriendInfo;
   import Account.PlayerSpecialStatus;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.Clock.GameClock;
   import Brain.UI.UIButton;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import UI.Popup.DBUIOneButtonPopup;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class LeaderboardFriendSlot
   {
      
      public static const ONLINE_POPUP_TWEEN_DURATION:Number = 0.2;
      
      public static const OFFLINE_POPUP_TWEEN_DURATION:Number = 0.2;
      
      public static const ONLINE_POPUP_OFFSET:Number = 50;
      
      public static const OFFLINE_POPUP_OFFSET:Number = 60;
      
      public static const POPUP_TIME_TO_LIVE:Number = 1;
      
      private var mDBFacade:DBFacade;
      
      private var mFriendSlot:MovieClip;
      
      private var mFriendName:TextField;
      
      private var mFriendOnlineClip:MovieClip;
      
      private var mFriendOfflineClip:MovieClip;
      
      private var mMeOnlineClip:MovieClip;
      
      private var mJoinOnlineClip:MovieClip;
      
      private var mFriendInviteButton:UIButton;
      
      private var mFriendPicButton:UIButton;
      
      private var mFriendLevel:MovieClip;
      
      private var mOnlinePopup:MovieClip;
      
      private var mOfflinePopup:MovieClip;
      
      private var mMessageFriendButton:UIButton;
      
      private var mJoinOnlineFriendButton:UIButton;
      
      private var mRemoveOnlineFriendButton:UIButton;
      
      private var mRemoveFriendButton:UIButton;
      
      private var mFBRemoveFriendPopup:DBUIOneButtonPopup;
      
      private var mFriendInfo:FriendInfo;
      
      private var mLeaderboard:UILeaderboard;
      
      private var mThisSlotIndex:uint;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mFriendSlotPosition:Point;
      
      private var mPopupTimeToLiveTask:Task;
      
      public function LeaderboardFriendSlot(dbFacade:DBFacade, friendSlot:MovieClip, leaderboard:UILeaderboard, slotIndex:int)
      {
         super();
         mDBFacade = dbFacade;
         mFriendSlot = friendSlot;
         mLeaderboard = leaderboard;
         mThisSlotIndex = slotIndex;
         mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(dbFacade,"LeaderboardFriendSlot");
         mFriendSlotPosition = mFriendSlot.localToGlobal(new Point(0,0));
         loadVariables();
         populateSlot(null);
      }
      
      private function loadVariables() : void
      {
         mOnlinePopup = mLeaderboard.onlinePopup;
         mOfflinePopup = mLeaderboard.offlinePopup;
         mMessageFriendButton = mLeaderboard.messageFriend;
         mFriendName = mFriendSlot.friend_name;
         mFriendName.mouseEnabled = false;
         mFriendPicButton = new UIButton(mDBFacade,mFriendSlot.friend_pic);
         mFriendOnlineClip = mFriendSlot.friend_pic.friend_online;
         mFriendOfflineClip = mFriendSlot.friend_pic.friend_offline;
         mMeOnlineClip = mFriendSlot.friend_pic.you_online;
         mJoinOnlineClip = mFriendSlot.friend_pic.join;
         mJoinOnlineFriendButton = new UIButton(mDBFacade,mFriendSlot.friend_pic.join.join);
         mJoinOnlineFriendButton.label.text = Locale.getString("LEADERBOARD_JOIN_FRIEND_BUTTON");
         mFriendLevel = mFriendSlot.friend_level;
         mFriendLevel.mouseEnabled = false;
         mFriendLevel.mouseChildren = false;
         mFriendInviteButton = new UIButton(mDBFacade,mFriendSlot.invite_friend);
         mFriendInviteButton.label.text = Locale.getString("LEADERBOARD_INVITE_FRIEND");
         mFriendInviteButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mFriendPicButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
      }
      
      private function showFriendDetails() : void
      {
         if(mFriendInfo && mFriendInfo.id == mDBFacade.accountId || mLeaderboard.currentPopupIndex == mThisSlotIndex && (mOnlinePopup.visible || mOfflinePopup.visible))
         {
            stopPopupTimeToLiveTask();
            minimizePopup();
         }
         else
         {
            hidePopups();
            if(!mFriendInfo)
            {
               return;
            }
            mLeaderboard.callStopOnPopupTimeToLiveTask();
            mLeaderboard.currentPopupIndex = mThisSlotIndex;
            if(mFriendInfo.isOnline())
            {
               populateOnlinePopup();
            }
            else
            {
               populateOfflinePopup();
            }
         }
      }
      
      public function populateSlot(data:FriendInfo) : void
      {
         mFriendInfo = data;
         mFriendPicButton.root.filters = [];
         if(data)
         {
            mFriendInviteButton.visible = false;
            mFriendName.visible = true;
            mFriendLevel.visible = true;
            mFriendOnlineClip.visible = false;
            mJoinOnlineClip.visible = false;
            mFriendOfflineClip.visible = false;
            mMeOnlineClip.visible = false;
            mJoinOnlineFriendButton.root.visible = false;
            mJoinOnlineFriendButton.releaseCallback = null;
            mFriendPicButton.releaseCallback = null;
            mFriendName.text = data.name;
            mFriendName.textColor = PlayerSpecialStatus.getSpecialTextColor(data.name,mFriendName.textColor);
            mFriendLevel.level.text = data.trophies;
            if(data.isOnline() && data.isInDungeon())
            {
               mJoinOnlineClip.visible = true;
               mJoinOnlineFriendButton.root.visible = true;
               mJoinOnlineFriendButton.releaseCallback = function():void
               {
                  var _loc1_:Boolean = false;
                  if(mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id).length == 0)
                  {
                     mDBFacade.warningPopup("Warning","Cannot enter dungeon with no weapons equipped.");
                  }
                  else
                  {
                     mDBFacade.metrics.log("JoinFriend",{"friendId":data.id});
                     _loc1_ = false;
                     if(mLeaderboard.currentStateName == "MapTownSubState")
                     {
                        _loc1_ = true;
                     }
                     mDBFacade.mainStateMachine.enterLoadingScreenState(0,"",data.id,0,_loc1_);
                  }
               };
            }
            else if(data.isOnline())
            {
               if(data.id != mDBFacade.accountId)
               {
                  mFriendOnlineClip.visible = true;
               }
               else
               {
                  mMeOnlineClip.visible = true;
               }
            }
            else
            {
               mFriendOfflineClip.visible = true;
            }
            if(mFriendPicButton.root.friend_pic.numChildren)
            {
               mFriendPicButton.root.friend_pic.removeChildAt(0);
            }
            mFriendPicButton.root.friend_pic.addChildAt(data.pic,0);
            mFriendPicButton.root.default_pic.visible = false;
            mFriendPicButton.rollOverCallback = showFriendDetails;
            mFriendPicButton.rollOutCallback = function():void
            {
               if(mFriendInfo && mFriendInfo.id == mDBFacade.accountId)
               {
                  return;
               }
               mPopupTimeToLiveTask = mLogicalWorkComponent.doLater(1,minimizePopup);
            };
         }
         else
         {
            mFriendInviteButton.visible = true;
            mFriendInviteButton.releaseCallback = mFriendPicButton.releaseCallback = mLeaderboard.inviteFriendDR;
            if(mFriendPicButton.root.friend_pic.numChildren)
            {
               mFriendPicButton.root.friend_pic.removeChildAt(0);
            }
            mFriendPicButton.root.default_pic.visible = true;
            mFriendName.visible = false;
            mJoinOnlineFriendButton.root.visible = false;
            mJoinOnlineFriendButton.releaseCallback = null;
            mFriendOnlineClip.visible = false;
            mMeOnlineClip.visible = false;
            mFriendLevel.visible = false;
         }
      }
      
      private function populateOnlinePopup() : void
      {
         TweenMax.killTweensOf(mOnlinePopup);
         mOnlinePopup.visible = true;
         mOnlinePopup.y = mFriendSlotPosition.y;
         mOnlinePopup.x = mFriendSlotPosition.x;
         mOnlinePopup.title_label.mouseEnabled = false;
         mOnlinePopup.title_label.text = mFriendInfo.isInDungeon() ? Locale.getString("LEADERBOARD_IN_DUNGEON_TEXT") : Locale.getString("LEADERBOARD_IN_TOWN_TEXT");
         TweenMax.to(mOnlinePopup,0.2,{"y":mOnlinePopup.y - 50});
         mRemoveFriendButton = mLeaderboard.removeOnlineFriend;
         mRemoveFriendButton.releaseCallback = function():void
         {
            mLeaderboard.loadRemoveFriendPopup(mFriendInfo);
         };
      }
      
      private function populateOfflinePopup() : void
      {
         TweenMax.killTweensOf(mOfflinePopup);
         mOfflinePopup.visible = true;
         mOfflinePopup.y = mFriendSlotPosition.y;
         mOfflinePopup.x = mFriendSlotPosition.x;
         TweenMax.to(mOfflinePopup,0.2,{"y":mOfflinePopup.y - 60});
         if(mDBFacade.isFacebookPlayer && !mFriendInfo.isDRFriend)
         {
            mLeaderboard.enableMessageFriendButton();
            mMessageFriendButton.releaseCallback = function():void
            {
               mDBFacade.facebookController.leaderboardFeedPostToASingleUser(mFriendInfo.facebookId);
            };
         }
         else
         {
            mLeaderboard.disableMessageFriendButton();
         }
         mRemoveFriendButton = mLeaderboard.removeOfflineFriend;
         mRemoveFriendButton.releaseCallback = function():void
         {
            mLeaderboard.loadRemoveFriendPopup(mFriendInfo);
         };
      }
      
      public function hidePopups() : void
      {
         checkToRefreshLeaderboard();
         if(mOnlinePopup)
         {
            mOnlinePopup.visible = false;
         }
         if(mOfflinePopup)
         {
            mOfflinePopup.visible = false;
         }
      }
      
      public function minimizePopup(gameClock:GameClock = null) : void
      {
         if(mOnlinePopup.visible)
         {
            TweenMax.killTweensOf(mOnlinePopup);
            TweenMax.to(mOnlinePopup,0.2,{
               "y":mOnlinePopup.y + 50 + 10,
               "visible":false
            });
         }
         if(mOfflinePopup.visible)
         {
            TweenMax.killTweensOf(mOfflinePopup);
            TweenMax.to(mOfflinePopup,0.2,{
               "y":mOfflinePopup.y + 60 + 10,
               "visible":false
            });
         }
         checkToRefreshLeaderboard();
      }
      
      private function checkToRefreshLeaderboard() : void
      {
         if(mLeaderboard.mustRefreshLeaderboard)
         {
            mLeaderboard.refreshLeaderboard();
         }
      }
      
      public function stopPopupTimeToLiveTask() : void
      {
         if(mPopupTimeToLiveTask)
         {
            mPopupTimeToLiveTask.destroy();
         }
         mPopupTimeToLiveTask = null;
      }
      
      public function destroy() : void
      {
         stopPopupTimeToLiveTask();
         if(mFriendInviteButton)
         {
            mFriendInviteButton.destroy();
         }
         mFriendInviteButton = null;
         if(mFriendPicButton)
         {
            mFriendPicButton.destroy();
         }
         mFriendPicButton = null;
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
         if(mJoinOnlineFriendButton)
         {
            mJoinOnlineFriendButton.destroy();
         }
         mJoinOnlineFriendButton = null;
         mMessageFriendButton = null;
         mDBFacade = null;
         mFriendSlot = null;
         mFriendName = null;
         mFriendOnlineClip = null;
         mJoinOnlineClip = null;
         mFriendOfflineClip = null;
         mMeOnlineClip = null;
         mFriendLevel = null;
         mOnlinePopup = null;
         mOfflinePopup = null;
         mFriendInfo = null;
         mLeaderboard = null;
      }
   }
}

