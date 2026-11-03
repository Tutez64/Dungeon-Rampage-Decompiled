package UI.Leaderboard
{
   import Account.FriendInfo;
   import Account.PlayerSpecialStatus;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.Clock.GameClock;
   import Brain.UI.UIButton;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import UI.Portrait.PlayerPortraits;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class LeaderboardFriendSlot
   {
      
      public static const ONLINE_POPUP_TWEEN_DURATION:Number = 0.2;
      
      public static const OFFLINE_POPUP_TWEEN_DURATION:Number = 0.2;
      
      public static const ONLINE_POPUP_OFFSET:Number = 50;
      
      public static const OFFLINE_POPUP_OFFSET:Number = 60;
      
      public static const POPUP_TIME_TO_LIVE:Number = 1;
      
      private var mPortraits:PlayerPortraits = new PlayerPortraits();
      
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
         mLogicalWorkComponent = new LogicalWorkComponent(dbFacade);
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
         Locale.setText(mJoinOnlineFriendButton.label,"LEADERBOARD_JOIN_FRIEND_BUTTON");
         mFriendLevel = mFriendSlot.friend_level;
         mFriendLevel.mouseEnabled = false;
         mFriendLevel.mouseChildren = false;
         mFriendInviteButton = new UIButton(mDBFacade,mFriendSlot.invite_friend);
         Locale.setText(mFriendInviteButton.label,"LEADERBOARD_INVITE_FRIEND");
         mFriendInviteButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mFriendPicButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mFriendPicButton.navigationSelectedInteraction = focusFriendDetails;
      }
      
      private function focusFriendDetails() : void
      {
         if(!mFriendInfo)
         {
            mLeaderboard.callStopOnPopupTimeToLiveTask();
            hidePopups();
            return;
         }
         if(mFriendInfo.id == mDBFacade.accountId)
         {
            mLeaderboard.callStopOnPopupTimeToLiveTask();
            minimizePopup();
            return;
         }
         if(mLeaderboard.currentPopupIndex == mThisSlotIndex && (mOnlinePopup.visible || mOfflinePopup.visible))
         {
            mLeaderboard.callStopOnPopupTimeToLiveTask();
            return;
         }
         showFriendDetails();
      }
      
      private function showFriendDetails() : void
      {
         if(mFriendInfo && mFriendInfo.id == mDBFacade.accountId)
         {
            stopPopupTimeToLiveTask();
            minimizePopup();
            return;
         }
         if(mLeaderboard.currentPopupIndex == mThisSlotIndex && (mOnlinePopup.visible || mOfflinePopup.visible))
         {
            mLeaderboard.callStopOnPopupTimeToLiveTask();
            return;
         }
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
      
      public function populateSlot(data:FriendInfo) : void
      {
         var joinFriendCallback:Function;
         mPortraits.clear();
         mFriendInfo = data;
         if(!mFriendPicButton.isFocused())
         {
            mFriendPicButton.root.filters = [];
         }
         mLeaderboard.resetFriendSlotUpNavigation(mFriendPicButton);
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
            applyFriendNameSize();
            mFriendName.textColor = PlayerSpecialStatus.getSpecialTextColor(data.name,mFriendName.textColor);
            TextUtil.setText(mFriendLevel.level,String(data.trophies));
            if(data.isOnline() && data.isInDungeon())
            {
               mJoinOnlineClip.visible = true;
               mJoinOnlineFriendButton.root.visible = true;
               joinFriendCallback = function():void
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
               mJoinOnlineFriendButton.releaseCallback = joinFriendCallback;
               mFriendPicButton.releaseCallback = joinFriendCallback;
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
            mPortraits.showFriend(mFriendPicButton.root.friend_pic,mDBFacade,data);
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
      
      private function applyFriendNameSize() : void
      {
         var _loc2_:int = 0;
         var _loc1_:TextFormat = mFriendName.defaultTextFormat;
         if(!Locale.isLowRes)
         {
            _loc2_ = Math.ceil(9 / (0.846 * mDBFacade.viewScale));
            _loc1_.size = Math.max(12,_loc2_);
         }
         mFriendName.setTextFormat(_loc1_);
      }
      
      private function get onlinePopupTitle() : String
      {
         if(!mFriendInfo.isInDungeon())
         {
            return Locale.getString("LEADERBOARD_IN_TOWN_TEXT");
         }
         var _loc1_:String = mFriendInfo.dungeonName;
         return _loc1_ ? _loc1_.toUpperCase() : Locale.getString("LEADERBOARD_IN_DUNGEON_TEXT");
      }
      
      private function populateOnlinePopup() : void
      {
         mDBFacade.mTween.killTweensOf(mOnlinePopup);
         mOnlinePopup.visible = true;
         mFriendSlotPosition = mDBFacade.designLocalToGlobal(mFriendSlot,new Point(0,0));
         mOnlinePopup.y = mFriendSlotPosition.y;
         mOnlinePopup.x = mFriendSlotPosition.x;
         mLeaderboard.setOnlinePopupTitle(onlinePopupTitle);
         mDBFacade.mTween.tweenMaxTo(mOnlinePopup,0.2,{"y":mOnlinePopup.y - 50});
         mRemoveFriendButton = mLeaderboard.removeOnlineFriend;
         mRemoveFriendButton.releaseCallback = function():void
         {
            mLeaderboard.loadRemoveFriendPopup(mFriendInfo);
         };
         mLeaderboard.setupTooltipNavigation(mFriendPicButton,mRemoveFriendButton,mLeaderboard.giftFriend);
      }
      
      private function populateOfflinePopup() : void
      {
         mDBFacade.mTween.killTweensOf(mOfflinePopup);
         mOfflinePopup.visible = true;
         mFriendSlotPosition = mDBFacade.designLocalToGlobal(mFriendSlot,new Point(0,0));
         mOfflinePopup.y = mFriendSlotPosition.y;
         mOfflinePopup.x = mFriendSlotPosition.x;
         mDBFacade.mTween.tweenMaxTo(mOfflinePopup,0.2,{"y":mOfflinePopup.y - 60});
         mLeaderboard.disableMessageFriendButton();
         mRemoveFriendButton = mLeaderboard.removeOfflineFriend;
         mRemoveFriendButton.releaseCallback = function():void
         {
            mLeaderboard.loadRemoveFriendPopup(mFriendInfo);
         };
         mLeaderboard.setupTooltipNavigation(mFriendPicButton,mRemoveFriendButton);
      }
      
      public function hidePopups() : void
      {
         mLeaderboard.releaseTooltipFocus();
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
         mLeaderboard.releaseTooltipFocus();
         if(mOnlinePopup.visible)
         {
            mDBFacade.mTween.killTweensOf(mOnlinePopup);
            mDBFacade.mTween.tweenMaxTo(mOnlinePopup,0.2,{
               "y":mOnlinePopup.y + 50 + 10,
               "visible":false
            });
         }
         if(mOfflinePopup.visible)
         {
            mDBFacade.mTween.killTweensOf(mOfflinePopup);
            mDBFacade.mTween.tweenMaxTo(mOfflinePopup,0.2,{
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
      
      public function get friendPicButton() : UIButton
      {
         return mFriendPicButton;
      }
      
      public function destroy() : void
      {
         mPortraits.destroy();
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

