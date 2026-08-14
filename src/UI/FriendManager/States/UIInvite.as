package UI.FriendManager.States
{
   import Account.SteamIdConverter;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.UI.UIInputText;
   import Brain.UI.UIObject;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.jsonRPC.JSONRPCService;
   import DistributedObjects.PresenceManager;
   import Events.FriendSummaryNewsFeedEvent;
   import Events.FriendshipEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMSkin;
   import Town.TownStateMachine;
   import UI.FriendManager.UIFriendManager;
   import UI.Popup.DBUIOneButtonPopup;
   import flash.display.MovieClip;
   import flash.external.ExternalInterface;
   import flash.utils.getQualifiedClassName;
   
   public class UIInvite extends UIFMState
   {
      
      private static const MAX_INVITE_STRING:uint = 200;
      
      private static const TURN_OFF_WARNING_TIMER:uint = 2;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mEventComponent:EventComponent;
      
      private var mEmailText:String;
      
      private var mInviteUIMC:MovieClip;
      
      private var mInviteInputText:UIInputText;
      
      private var mInviteViaEmailButton:UIButton;
      
      private var mInviteViaFBConnectButton:UIButton;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      public function UIInvite(uiFriendManager:UIFriendManager, dbFacade:DBFacade, townStateMachine:TownStateMachine)
      {
         super(dbFacade,uiFriendManager,townStateMachine);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIInvite");
      }
      
      override public function enter() : void
      {
         Logger.debug("Entered Invite State");
         mUIFriendManager.updateHeading(Locale.getString("FRIEND_MANAGEMENT_HEADING_INVITE"));
         var _loc1_:String = SteamIdConverter.convertSteamID64ToSteamHex(mDBFacade.mSteamUserId);
         mUIFriendManager.updateDescription(Locale.getString("FRIEND_MANAGEMENT_DESCRIPTION_INVITE") + _loc1_,true);
         setupUI();
      }
      
      public function setupUI() : void
      {
         var steamHex:String;
         var inviteUIClass:Class = mTownStateMachine.getTownAsset("popup_invite_B");
         mInviteUIMC = new inviteUIClass() as MovieClip;
         mUIFriendManager.addToUI(mInviteUIMC);
         mInviteUIMC.x = 300;
         mInviteUIMC.y = 150;
         steamHex = SteamIdConverter.convertSteamID64ToSteamHex(mDBFacade.mSteamUserId);
         mInviteUIMC.search_label2.text = Locale.getString("FRIEND_MANAGEMENT_DESCRIPTION_INVITE_2") + steamHex;
         mInviteUIMC.search_label2.selectable = true;
         mInviteUIMC.search_label1.visible = false;
         mInviteUIMC.search_label.textColor = 16711680;
         mInviteUIMC.search_label.visible = false;
         mInviteUIMC.message_label.visible = false;
         mInviteInputText = new UIInputText(mDBFacade,mInviteUIMC.friend_enterEmailId);
         mInviteInputText.defaultText = Locale.getString("DRINVITE_PROMPT");
         mInviteInputText.enterCallback = inviteViaEmail;
         mInviteInputText.textField.maxChars = 200;
         mInviteViaEmailButton = new UIButton(mDBFacade,mInviteUIMC.send_button);
         mInviteViaEmailButton.label.text = Locale.getString("DRINVITE_FRIEND_EMAIL_BUTTON");
         mInviteViaEmailButton.releaseCallback = function():void
         {
            var _loc1_:RegExp = /[\s\r\n]*/gim;
            mInviteUIMC.friend_enterEmailId.textField.text = mInviteUIMC.friend_enterEmailId.textField.text.replace(_loc1_,"");
            inviteViaEmail(mInviteUIMC.friend_enterEmailId.textField.text,inviteViaEmailSuccessCallback);
            mInviteUIMC.friend_enterEmailId.textField.text = "";
         };
         mInviteUIMC.connect_button_kongregate.visible = false;
         mInviteViaFBConnectButton = new UIButton(mDBFacade,mInviteUIMC.connect_button_facebook);
         mInviteViaFBConnectButton.releaseCallback = inviteViaFBConnect;
         if(!mDBFacade.isFacebookPlayer)
         {
            mInviteViaFBConnectButton.visible = false;
         }
      }
      
      private function inviteViaEmail(value:String, successCallback:Function = null) : void
      {
         var finalValue:String;
         var accountIdRegex:RegExp;
         var steamID64:String;
         var rpcSuccessCallback:Function;
         var rpcFunc:Function = JSONRPCService.getFunction("DRFriendRequest",mDBFacade.rpcRoot + "friendrequests");
         var rex:RegExp = /[\s\r\n]*/gim;
         mInviteInputText.text = mInviteInputText.text.replace(rex,"");
         finalValue = mInviteInputText.text;
         accountIdRegex = /^1[0-9]{9}$/;
         if(accountIdRegex.test(finalValue))
         {
            Logger.debug("Requested friend looks like an account ID, not a Steam ID, so not converting to email. Value: " + finalValue);
         }
         else
         {
            if(!SteamIdConverter.isValidSteamId(mInviteInputText.text))
            {
               mInviteInputText.text = "";
               mInviteUIMC.search_label.text = Locale.getString("DRINVITE_PROMPT_INVALID_EMAIL");
               mInviteUIMC.search_label.visible = true;
               mLogicalWorkComponent.doLater(2,function(param1:GameClock):void
               {
                  mInviteUIMC.search_label.visible = false;
               });
               return;
            }
            steamID64 = SteamIdConverter.normalizeSteamIdToSteamID64(mInviteInputText.text);
            if(steamID64 == "")
            {
               mInviteInputText.text = "";
               mInviteUIMC.search_label.text = Locale.getString("DRINVITE_PROMPT_INVALID_EMAIL");
               mInviteUIMC.search_label.visible = true;
               mLogicalWorkComponent.doLater(2,function(param1:GameClock):void
               {
                  mInviteUIMC.search_label.visible = false;
               });
               return;
            }
            finalValue = steamID64 + "@steam.dr.g17s.net";
            rex = /([0-9a-zA-Z]+[-._+&])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}/;
            if(rex.test(finalValue) == false)
            {
               mInviteInputText.text = "";
               mInviteUIMC.search_label.text = Locale.getString("DRINVITE_PROMPT_INVALID_EMAIL");
               mInviteUIMC.search_label.visible = true;
               mLogicalWorkComponent.doLater(2,function(param1:GameClock):void
               {
                  mInviteUIMC.search_label.visible = false;
               });
               return;
            }
         }
         rpcSuccessCallback = function(param1:*):void
         {
            var popup:DBUIOneButtonPopup;
            var requestJson:Object;
            var iconContainer:MovieClip;
            var skin:GMSkin;
            var details:* = param1;
            if(details == null)
            {
               mInviteUIMC.search_label.text = Locale.getString("DRINVITE_PROMPT_ALREADY_FRIEND");
               mInviteUIMC.search_label.visible = true;
               mLogicalWorkComponent.doLater(2,function(param1:GameClock):void
               {
                  mInviteUIMC.search_label.visible = false;
               });
               return;
            }
            if(getQualifiedClassName(details) == "Array" && details.length <= 0)
            {
               mEmailText = value;
               popup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("DRINVITE_FAILED_POPUP_TITLE"),Locale.getString("DRINVITE_FAILED_POPUP_DESC"),Locale.getString("OK"),invokeMailClient);
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in UIInvite.UIInvite()");
               return;
            }
            if(details == false)
            {
               mInviteUIMC.search_label.text = Locale.getString("DRINVITE_PROMPT_INVITE_SENT");
               mInviteUIMC.search_label.visible = true;
               mLogicalWorkComponent.doLater(2,function(param1:GameClock):void
               {
                  mInviteUIMC.search_label.visible = false;
               });
               return;
            }
            requestJson = parseJson(details);
            iconContainer = new MovieClip();
            skin = mDBFacade.gameMaster.getSkinByType(requestJson.active_skin);
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(skin.UISwfFilepath),function(param1:SwfAsset):void
            {
               var _loc3_:Class = param1.getClass(skin.IconName);
               var _loc2_:MovieClip = new _loc3_();
               UIObject.scaleToFit(_loc2_,65);
               iconContainer.addChild(_loc2_);
               mEventComponent.dispatchEvent(new FriendSummaryNewsFeedEvent("FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT",Locale.getString("Friend_Request_Sent_to_"),iconContainer,value));
               mDBFacade.metrics.log("DRFriendRequest",{"friendId":requestJson.to_account_id});
            });
            if(successCallback != null)
            {
               successCallback();
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.name,mDBFacade.dbAccountInfo.trophies,mDBFacade.dbAccountInfo.activeAvatarSkinId,mDBFacade.dbAccountInfo.facebookId,mDBFacade.dbAccountInfo.id,finalValue,mDBFacade.demographics,mDBFacade.validationToken,rpcSuccessCallback,UIFriendManager.createFriendRPCErrorCallback(mDBFacade,"InviteViaEmail"));
         mInviteInputText.text = "";
      }
      
      private function inviteViaFBConnect() : void
      {
         if(mDBFacade.dbConfigManager.getConfigBoolean("FUFB",false))
         {
            mDBFacade.errorPopup("INVITE CURRENTLY DISABLED","Sorry for the inconvenience, we are looking into resolving the issue.");
            return;
         }
         if(mDBFacade.facebookController)
         {
            mDBFacade.facebookController.genericFriendRequests();
         }
      }
      
      private function invokeMailClient() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("sendInviteEmail",mDBFacade.dbAccountInfo.id,mDBFacade.dbConfigManager.networkId,mDBFacade.dbAccountInfo.name,mEmailText);
         }
      }
      
      public function parseJson(details:*) : Object
      {
         var _loc2_:Array = null;
         var _loc4_:Object = null;
         var _loc3_:* = undefined;
         if(getQualifiedClassName(details) == "Array")
         {
            _loc2_ = details[0];
            _loc4_ = details[1];
            _loc3_ = new Vector.<uint>();
            _loc3_.push(_loc4_.account_id);
            PresenceManager.instance().addFriends(_loc3_);
            mDBFacade.dbAccountInfo.addFriendCallback(_loc2_);
            mEventComponent.dispatchEvent(new FriendshipEvent(UIFriendManager.FRIENDSHIP_MADE,_loc4_.id));
         }
         else
         {
            _loc4_ = details as Object;
         }
         Logger.debug("friendRequest: id:" + _loc4_.id + " from:" + _loc4_.account_id + " to:" + _loc4_.to_account_id + " state:" + _loc4_.curr_state);
         return _loc4_;
      }
      
      private function inviteViaEmailSuccessCallback() : void
      {
         mInviteInputText.defaultText = Locale.getString("DRINVITE_PROMPT");
      }
      
      override public function exit() : void
      {
         Logger.debug("Exiting Invite State");
         mUIFriendManager.clearUI();
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         mLogicalWorkComponent.destroy();
         mAssetLoadingComponent.destroy();
         mEventComponent.destroy();
      }
   }
}

