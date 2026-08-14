package UI.FriendManager.States
{
   import Account.FriendInfo;
   import Brain.Event.EventComponent;
   import Brain.UI.UIButton;
   import Brain.jsonRPC.JSONRPCService;
   import DistributedObjects.PresenceManager;
   import Events.FriendshipEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import Town.TownStateMachine;
   import UI.FriendManager.FriendPopulater;
   import UI.FriendManager.UIFriendManager;
   
   public class UIPending extends UIFMState
   {
      
      public static const BUTTON_DECLINE_POS_X:uint = 800;
      
      public static const BUTTON_DECLINE_POS_Y:uint = 1000;
      
      public static const BUTTON_ACCEPT_POS_X:uint = 1075;
      
      public static const BUTTON_ACCEPT_POS_Y:uint = 1000;
      
      public static const ACCEPT_REQUEST:uint = 1;
      
      public static const DECLINE_REQUEST:uint = 2;
      
      private var mEventComponent:EventComponent;
      
      private var mFriendRequestPopulater:FriendPopulater;
      
      private var mListOfFriendRequests:Vector.<FriendInfo>;
      
      private var mDeclineButton:UIButton;
      
      private var mAcceptButton:UIButton;
      
      private var mPendingFriendRequests:Array;
      
      private var mSelectedFriendToIds:Array = [];
      
      private var mSelectedFriendRequestIds:Array = [];
      
      public function UIPending(uiFriendManager:UIFriendManager, dbFacade:DBFacade, townStateMachine:TownStateMachine)
      {
         super(dbFacade,uiFriendManager,townStateMachine);
         mListOfFriendRequests = new Vector.<FriendInfo>();
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener(UIFriendManager.FRIENDSHIP_MADE,friendshipMadeHandler);
      }
      
      override public function enter() : void
      {
         mUIFriendManager.updateHeading(Locale.getString("FRIEND_MANAGEMENT_HEADING_PENDING"));
         mUIFriendManager.updateDescription(Locale.getString("FRIEND_MANAGEMENT_DESCRIPTION_PENDING"));
         setupUI();
      }
      
      override public function exit() : void
      {
         mListOfFriendRequests.splice(0,mListOfFriendRequests.length);
         if(mFriendRequestPopulater != null)
         {
            mFriendRequestPopulater.destroy();
            mFriendRequestPopulater = null;
         }
         mDeclineButton = null;
         mAcceptButton = null;
         mUIFriendManager.clearUI();
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         mEventComponent.removeListener(UIFriendManager.FRIENDSHIP_MADE);
         mEventComponent.destroy();
      }
      
      private function refresh(list:Array) : void
      {
         var _loc3_:* = 0;
         for each(var _loc2_:uint in list)
         {
            _loc3_ = 0;
            while(_loc3_ < mPendingFriendRequests.length)
            {
               if(mPendingFriendRequests[_loc3_].id == _loc2_)
               {
                  mPendingFriendRequests.splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
         }
         exit();
         enter();
      }
      
      public function set pendingFriendRequests(requests:Array) : void
      {
         mPendingFriendRequests = requests;
         if(mPendingFriendRequests != null && mPendingFriendRequests.length > 0)
         {
            mUIFriendManager.alert = true;
         }
         else
         {
            mUIFriendManager.alert = false;
            mTownStateMachine.leaderboard.alert = false;
         }
      }
      
      public function setupUI() : void
      {
         var _loc2_:FriendInfo = null;
         pendingFriendRequests = mPendingFriendRequests;
         for each(var _loc1_:Object in mPendingFriendRequests)
         {
            _loc2_ = new FriendInfo(mDBFacade,_loc1_);
            mListOfFriendRequests.push(_loc2_);
         }
         mFriendRequestPopulater = new FriendPopulater(mDBFacade,mTownStateMachine,mListOfFriendRequests,mUIFriendManager);
         mDeclineButton = createButton("friend_management_button_grey",Locale.getString("DECLINE"),800,1000,declineButtonCallback);
         mAcceptButton = createButton("friend_management_button",Locale.getString("ACCEPT"),1075,1000,acceptButtonCallback);
      }
      
      private function declineButtonCallback() : void
      {
         var rpcFunc:Function;
         var idx:uint;
         mSelectedFriendToIds.splice(0,mSelectedFriendToIds.length);
         mSelectedFriendRequestIds.splice(0,mSelectedFriendRequestIds.length);
         for each(idx in mFriendRequestPopulater.getSelectedToggles())
         {
            mSelectedFriendToIds.push(mPendingFriendRequests[idx].account_id);
            mSelectedFriendRequestIds.push(mPendingFriendRequests[idx].id);
         }
         if(mSelectedFriendToIds.length > 0)
         {
            rpcFunc = JSONRPCService.getFunction("DRFriendRequestUpdate",mDBFacade.rpcRoot + "friendrequests");
            rpcFunc(mDBFacade.accountId,mSelectedFriendRequestIds,mSelectedFriendToIds,2,mDBFacade.validationToken,function(param1:*):void
            {
               var _loc2_:* = 0;
               refresh(mSelectedFriendRequestIds);
               _loc2_ = 0;
               while(_loc2_ < mSelectedFriendToIds.length)
               {
                  mDBFacade.metrics.log("DRFriendDecline",{"friendId":mSelectedFriendToIds[_loc2_].toString()});
                  _loc2_++;
               }
            });
         }
      }
      
      private function acceptButtonCallback() : void
      {
         var rpcFunc:Function;
         var fullAcceptList:String;
         var idx:uint;
         mSelectedFriendToIds.splice(0,mSelectedFriendToIds.length);
         mSelectedFriendRequestIds.splice(0,mSelectedFriendRequestIds.length);
         fullAcceptList = "[";
         for each(idx in mFriendRequestPopulater.getSelectedToggles())
         {
            mSelectedFriendToIds.push(mPendingFriendRequests[idx].account_id);
            mSelectedFriendRequestIds.push(mPendingFriendRequests[idx].id);
         }
         if(mSelectedFriendToIds.length > 0)
         {
            rpcFunc = JSONRPCService.getFunction("DRFriendRequestUpdate",mDBFacade.rpcRoot + "friendrequests");
            rpcFunc(mDBFacade.accountId,mSelectedFriendRequestIds,mSelectedFriendToIds,1,mDBFacade.validationToken,function(param1:*):void
            {
               var _loc2_:* = 0;
               refresh(mSelectedFriendRequestIds);
               var _loc3_:Vector.<uint> = Vector.<uint>(mSelectedFriendToIds);
               PresenceManager.instance().addFriends(_loc3_);
               mDBFacade.dbAccountInfo.addFriendCallback(param1);
               mTownStateMachine.leaderboard.refreshLeaderboard();
               _loc2_ = 0;
               while(_loc2_ < mSelectedFriendToIds.length)
               {
                  mDBFacade.metrics.log("DRFriendAccept",{"friendId":mSelectedFriendToIds[_loc2_].toString()});
                  _loc2_++;
               }
            },UIFriendManager.createFriendRPCErrorCallback(mDBFacade,"acceptButton"));
         }
      }
      
      private function friendshipMadeHandler(event:FriendshipEvent) : void
      {
         var _loc3_:* = 0;
         var _loc2_:uint = event.id;
         _loc3_ = 0;
         while(_loc3_ < mPendingFriendRequests.length)
         {
            if(mPendingFriendRequests[_loc3_].id == event.id)
            {
               mPendingFriendRequests.splice(_loc3_,1);
               break;
            }
            _loc3_++;
         }
      }
   }
}

