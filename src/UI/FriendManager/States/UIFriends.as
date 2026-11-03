package UI.FriendManager.States
{
   import Account.FriendInfo;
   import Account.StoreServicesController;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.MemoryTracker;
   import Brain.jsonRPC.JSONRPCService;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import Town.TownStateMachine;
   import UI.FriendManager.FriendPopulater;
   import UI.FriendManager.UIFriendManager;
   import UI.Popup.DBUITwoButtonPopup;
   
   public class UIFriends extends UIFMState
   {
      
      public static const BUTTON_REMOVE_POS_X:uint = 800;
      
      public static const BUTTON_REMOVE_POS_Y:uint = 1000;
      
      public static const BUTTON_GIFT_POS_X:uint = 1075;
      
      public static const BUTTON_GIFT_POS_Y:uint = 1000;
      
      private var mFriendPopulater:FriendPopulater;
      
      private var mListOfFriends:Vector.<FriendInfo>;
      
      private var mRemoveButton:UIButton;
      
      private var mGiftButton:UIButton;
      
      private var mRemoveFriendsPopUp:DBUITwoButtonPopup;
      
      private var mSelectedDRFriends:Array = [];
      
      public function UIFriends(uiFriendManager:UIFriendManager, dbFacade:DBFacade, townStateMachine:TownStateMachine)
      {
         super(dbFacade,uiFriendManager,townStateMachine);
         mListOfFriends = new Vector.<FriendInfo>();
      }
      
      override public function enter() : void
      {
         mUIFriendManager.updateHeading(Locale.getString("FRIEND_MANAGEMENT_HEADING_FRIENDS"));
         mUIFriendManager.updateDescription(Locale.getString("FRIEND_MANAGEMENT_DESCRIPTION_FRIENDS"));
         setupUI();
      }
      
      override public function exit() : void
      {
         mListOfFriends.splice(0,mListOfFriends.length);
         if(mFriendPopulater != null)
         {
            mFriendPopulater.destroy();
            mFriendPopulater = null;
         }
         if(mRemoveButton)
         {
            mRemoveButton.destroy();
            mRemoveButton = null;
         }
         if(mGiftButton)
         {
            mGiftButton.destroy();
            mGiftButton = null;
         }
         mUIFriendManager.clearUI();
         if(mRemoveFriendsPopUp)
         {
            mRemoveFriendsPopUp.destroy();
            mRemoveFriendsPopUp = null;
         }
      }
      
      private function refresh(list:Array) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:uint = 0;
         for each(var _loc2_:uint in list)
         {
            _loc3_ = false;
            _loc4_ = 0;
            while(_loc4_ < mTownStateMachine.leaderboard.onlineFriends.length)
            {
               if(mTownStateMachine.leaderboard.onlineFriends[_loc4_].id == _loc2_)
               {
                  mTownStateMachine.leaderboard.onlineFriends.splice(_loc4_,1);
                  _loc3_ = true;
                  break;
               }
               _loc4_++;
            }
            if(!_loc3_)
            {
               _loc4_ = 0;
               while(_loc4_ < mTownStateMachine.leaderboard.offlineFriends.length)
               {
                  if(mTownStateMachine.leaderboard.offlineFriends[_loc4_].id == _loc2_)
                  {
                     mTownStateMachine.leaderboard.offlineFriends.splice(_loc4_,1);
                     _loc3_ = true;
                     break;
                  }
                  _loc4_++;
               }
            }
         }
         exit();
         enter();
      }
      
      private function setupUI() : void
      {
         var _loc3_:int = 0;
         var _loc2_:Vector.<FriendInfo> = mTownStateMachine.leaderboard.onlineFriends;
         var _loc1_:Vector.<FriendInfo> = mTownStateMachine.leaderboard.offlineFriends;
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            if(_loc2_[_loc3_].id != mDBFacade.accountId)
            {
               mListOfFriends.push(_loc2_[_loc3_]);
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc1_.length)
         {
            mListOfFriends.push(_loc1_[_loc3_]);
            _loc3_++;
         }
         mFriendPopulater = new FriendPopulater(mDBFacade,mTownStateMachine,mListOfFriends,mUIFriendManager);
         mRemoveButton = createButton("friend_management_button_grey",Locale.getString("REMOVE"),800,1000,removeFriendsConfirmation);
         mGiftButton = createButton("friend_management_button",Locale.getString("GIFT"),1075,1000,giftButtonCallback);
         setupMenuNavigation();
      }
      
      private function setupMenuNavigation() : void
      {
         mRemoveButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mGiftButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mRemoveButton.isToTheLeftOf(mGiftButton);
         mFriendPopulater.setupMenuNavigation(mUIFriendManager.currentTabButton,mRemoveButton,mGiftButton);
      }
      
      override public function getFirstNavigationUIObject() : UIObject
      {
         return mFriendPopulater.getFirstNavigationUIObject();
      }
      
      private function removeFriendsConfirmation() : void
      {
         mRemoveFriendsPopUp = new DBUITwoButtonPopup(mDBFacade,"REMOVE_FRIEND_POPUP",Locale.getString("REMOVE_FRIEND_POPUP_TITLE"),Locale.getString("REMOVE_FRIEND_POPUP_DESC"),Locale.getString("REMOVE_FRIEND_POPUP_CANCEL"),closeRemoveFriendsPopUp,Locale.getString("REMOVE_FRIEND_POPUP_CONFIRM"),removeButtonCallback);
         MemoryTracker.track(mRemoveFriendsPopUp,"DBUITwoButtonPopup - created in UIFriends.removeFriendsConfirmation()");
      }
      
      private function closeRemoveFriendsPopUp() : void
      {
         if(mRemoveFriendsPopUp)
         {
            mRemoveFriendsPopUp.destroy();
            mRemoveFriendsPopUp = null;
         }
      }
      
      private function removeButtonCallback() : void
      {
         var rpcFunc:Function;
         var idx:uint;
         mSelectedDRFriends.splice(0,mSelectedDRFriends.length);
         for each(idx in mFriendPopulater.getSelectedToggles())
         {
            mSelectedDRFriends.push(mListOfFriends[idx].id);
         }
         if(mSelectedDRFriends.length > 0)
         {
            rpcFunc = JSONRPCService.getFunction("DRFriendRemove",mDBFacade.rpcRoot + "friendrequests");
            rpcFunc(mDBFacade.accountId,mSelectedDRFriends,mDBFacade.validationToken,function(param1:*):void
            {
               var _loc2_:uint = 0;
               refresh(mSelectedDRFriends);
               mDBFacade.dbAccountInfo.removeFriendCallback(param1);
               mTownStateMachine.leaderboard.refreshLeaderboard();
               _loc2_ = 0;
               while(_loc2_ < mSelectedDRFriends.length)
               {
                  mDBFacade.metrics.log("DRFriendRemove",{"friendId":mSelectedDRFriends[_loc2_].toString()});
                  _loc2_++;
               }
            });
         }
      }
      
      private function giftButtonCallback() : void
      {
         var _loc1_:Boolean = false;
         for each(var _loc2_:uint in mFriendPopulater.getSelectedToggles())
         {
            if(mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(mListOfFriends[_loc2_].excludeId) < 0)
            {
               _loc1_ = true;
            }
         }
         if(_loc1_)
         {
            StoreServicesController.showGiftPage(mDBFacade,drGiftFlow);
         }
      }
      
      private function drGiftFlow(offerName:String, offerId:uint) : void
      {
         var _loc3_:Array = [];
         for each(var _loc4_:uint in mFriendPopulater.getSelectedToggles())
         {
            if(mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(mListOfFriends[_loc4_].excludeId) < 0)
            {
               _loc3_.push(_loc4_);
            }
         }
         if(_loc3_.length > 0)
         {
            sendDRComGift(offerName,offerId,_loc3_);
         }
      }
      
      private function sendDRComGift(offerName:String, offerId:uint, drFriends:Array) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc8_:Array = [];
         var _loc7_:Array = [];
         var _loc6_:String = new Date().time.toString();
         for each(var _loc9_:uint in drFriends)
         {
            _loc4_ = mListOfFriends[_loc9_].id.toString();
            _loc5_ = "0_" + _loc6_ + "_" + _loc4_;
            _loc7_.push(_loc5_);
            _loc8_.push(_loc4_);
            mDBFacade.metrics.log("DRGiftRequest",{"friendId":_loc4_});
         }
         mDBFacade.dbAccountInfo.giftExcludeIds = mDBFacade.dbAccountInfo.giftExcludeIds.concat(_loc8_);
         mDBFacade.dbAccountInfo.sendGiftData(offerId,_loc7_,_loc8_);
         mFriendPopulater.refreshGiftedOnCurrentPage();
      }
   }
}

