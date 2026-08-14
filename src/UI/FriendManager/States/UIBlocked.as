package UI.FriendManager.States
{
   import Account.FriendInfo;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.jsonRPC.JSONRPCService;
   import Facade.DBFacade;
   import Facade.Locale;
   import Town.TownStateMachine;
   import UI.FriendManager.FriendPopulater;
   import UI.FriendManager.UIFriendManager;
   
   public class UIBlocked extends UIFMState
   {
      
      public static const BUTTON_UNLOCK_POS_X:uint = 960;
      
      public static const BUTTON_UNLOCK_POS_Y:uint = 1000;
      
      private var mFriendPopulater:FriendPopulater;
      
      private var mListOfBlockedFriends:Vector.<FriendInfo>;
      
      private var mUnblockButton:UIButton;
      
      private var mSelectedFriends:Array = [];
      
      public function UIBlocked(uiFriendManager:UIFriendManager, dbFacade:DBFacade, townStateMachine:TownStateMachine)
      {
         super(dbFacade,uiFriendManager,townStateMachine);
      }
      
      override public function enter() : void
      {
         Logger.debug("Enterred Blocked State");
         mUIFriendManager.updateHeading(Locale.getString("FRIEND_MANAGEMENT_HEADING_BLOCKED"));
         mUIFriendManager.updateDescription(Locale.getString("FRIEND_MANAGEMENT_DESCRIPTION_BLOCKED"));
         setupUI();
      }
      
      override public function exit() : void
      {
         Logger.debug("Exiting Blocked State");
         mListOfBlockedFriends = null;
         if(mFriendPopulater != null)
         {
            mFriendPopulater.destroy();
            mFriendPopulater = null;
         }
         mUnblockButton = null;
         mUIFriendManager.clearUI();
      }
      
      private function refresh(list:Array) : void
      {
         var _loc3_:* = 0;
         for each(var _loc2_:uint in list)
         {
            _loc3_ = 0;
            while(_loc3_ < mListOfBlockedFriends.length)
            {
               if(mListOfBlockedFriends[_loc3_].id == _loc2_)
               {
                  mListOfBlockedFriends.splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
         }
         exit();
         enter();
      }
      
      private function setupUI() : void
      {
         mListOfBlockedFriends = mDBFacade.dbAccountInfo.ignoredFriends;
         mFriendPopulater = new FriendPopulater(mDBFacade,mTownStateMachine,mListOfBlockedFriends,mUIFriendManager);
         mUnblockButton = createButton("friend_management_button",Locale.getString("UNBLOCK"),960,1000,unblockButtonCallback);
      }
      
      private function unblockButtonCallback() : void
      {
         var rpcFunc:Function;
         var idx:uint;
         Logger.debug("unblock button clicked");
         mSelectedFriends.splice(0,mSelectedFriends.length);
         for each(idx in mFriendPopulater.getSelectedToggles())
         {
            mSelectedFriends.push(mListOfBlockedFriends[idx].id);
         }
         if(mSelectedFriends.length > 0)
         {
            rpcFunc = JSONRPCService.getFunction("UnblockFriend",mDBFacade.rpcRoot + "friendrequests");
            rpcFunc(mDBFacade.accountId,mSelectedFriends,mDBFacade.validationToken,function(param1:*):void
            {
               Logger.debug("friends unblocked: ");
               refresh(mSelectedFriends);
               mDBFacade.dbAccountInfo.refreshFriendData(param1);
               mTownStateMachine.leaderboard.refreshLeaderboard();
            });
         }
      }
   }
}

