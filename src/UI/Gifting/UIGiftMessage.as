package UI.Gifting
{
   import Account.FriendInfo;
   import Account.GiftInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMOffer;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class UIGiftMessage
   {
      
      private var mDBFacade:DBFacade;
      
      private var mGiftMessage:MovieClip;
      
      private var mUIGift:UIGift;
      
      private var mGiftText:TextField;
      
      private var mAcceptAndSendButton:UIButton;
      
      private var mDeclineButton:UIButton;
      
      private var mFriendPic:MovieClip;
      
      private var mGiftIcon:MovieClip;
      
      private var mGiftInfo:GiftInfo;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      public function UIGiftMessage(dbFacade:DBFacade, giftMessageRoot:MovieClip, uiGift:UIGift)
      {
         super();
         mDBFacade = dbFacade;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mGiftMessage = giftMessageRoot;
         mUIGift = uiGift;
         loadInitialVariables();
      }
      
      private function loadInitialVariables() : void
      {
         mGiftText = mGiftMessage.message_label;
         mGiftText.text = "";
         mAcceptAndSendButton = new UIButton(mDBFacade,mGiftMessage.left_button);
         mAcceptAndSendButton.label.text = Locale.getString("GIFT_MESSAGE_ACCEPT");
         mDeclineButton = new UIButton(mDBFacade,mGiftMessage.right_button);
         mFriendPic = mGiftMessage.friendPic;
         mGiftIcon = mGiftMessage.icon;
      }
      
      public function populateGiftMessage(data:GiftInfo) : void
      {
         var giftText:String;
         var friendName:String;
         var friend:FriendInfo;
         var offer:GMOffer;
         var offerName:String;
         if(!data)
         {
            return;
         }
         mGiftInfo = data;
         giftText = Locale.getString("GIFT_MESSAGE_TEXT");
         friendName = "SOMEBODY";
         friend = mDBFacade.dbAccountInfo.friendInfos.itemFor(data.fromAccountId);
         if(friend)
         {
            friendName = friend.name;
            if(mFriendPic.numChildren > 0)
            {
               mFriendPic.removeChildAt(0);
            }
            if(data.pic)
            {
               mFriendPic.addChildAt(data.pic,0);
            }
            else
            {
               data.pic = friend.clonePic();
               mFriendPic.addChildAt(data.pic,0);
            }
         }
         giftText = giftText.replace("#NAME",friendName);
         offer = mDBFacade.gameMaster.offerById.itemFor(mGiftInfo.offerId);
         if(offer)
         {
            offerName = offer.getDisplayName(mDBFacade.gameMaster,Locale.getString("GIFT_UNKNOWN_NAME"));
            giftText = giftText.concat(offerName);
            if(offer.BundleSwfFilepath != "" && offer.BundleIcon != "")
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(offer.BundleSwfFilepath),function(param1:SwfAsset):void
               {
                  var _loc4_:int = 0;
                  var _loc2_:Class = param1.getClass(offer.BundleIcon);
                  var _loc3_:MovieClip = new _loc2_();
                  _loc3_.scaleX = _loc3_.scaleY = 0.8;
                  if(mGiftIcon.numChildren > 0)
                  {
                     _loc4_ = mGiftIcon.numChildren - 1;
                     while(_loc4_ >= 0)
                     {
                        mGiftIcon.removeChild(mGiftIcon.getChildAt(_loc4_));
                        _loc4_--;
                     }
                  }
                  mGiftIcon.addChild(_loc3_);
               });
            }
            else
            {
               Logger.error("OfferID" + offer.Id.toString() + " is missing a bunble swf path and/or buncle icon");
            }
         }
         mAcceptAndSendButton.enabled = true;
         mAcceptAndSendButton.releaseCallback = function():void
         {
            var _loc1_:String = null;
            var _loc6_:Array = null;
            var _loc4_:Array = null;
            var _loc2_:String = null;
            var _loc3_:String = null;
            mAcceptAndSendButton.enabled = false;
            var _loc5_:Array = mDBFacade.dbAccountInfo.giftExcludeIds;
            if(friend != null && _loc5_.indexOf(friend.excludeId) < 0)
            {
               if(!friend.isDRFriend && friend.facebookId && friend.facebookId != "" && mDBFacade.facebookController.accessToken)
               {
                  mDBFacade.facebookController.sendGiftRequests(offerName,mGiftInfo.offerId,friend.facebookId);
               }
               else
               {
                  _loc6_ = [];
                  _loc4_ = [];
                  _loc3_ = new Date().time.toString();
                  if(friend.isDRFriend)
                  {
                     _loc1_ = friend.id.toString();
                  }
                  else
                  {
                     _loc1_ = friend.kongregateId.toString();
                  }
                  _loc2_ = "0_" + _loc3_ + "_" + _loc1_;
                  _loc4_.push(_loc2_);
                  _loc6_.push(_loc1_);
                  mDBFacade.dbAccountInfo.giftExcludeIds = _loc5_.concat(_loc6_);
                  mDBFacade.dbAccountInfo.sendGiftData(offer.Id,_loc4_,_loc6_);
               }
            }
            mDBFacade.dbAccountInfo.acceptGift(data.requestId,refreshGiftPopup);
         };
         mDeclineButton.enabled = true;
         mDeclineButton.releaseCallback = function():void
         {
            mDeclineButton.enabled = false;
            mDBFacade.dbAccountInfo.declineGift(data.requestId,refreshGiftPopup);
         };
         giftText = giftText.toLocaleUpperCase();
         mGiftText.text = giftText;
      }
      
      private function refreshGiftPopup() : void
      {
         mUIGift.refresh();
      }
      
      public function get root() : MovieClip
      {
         return mGiftMessage;
      }
      
      public function destroy() : void
      {
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         mDBFacade = null;
         mUIGift = null;
         mGiftMessage = null;
         mGiftInfo = null;
         mFriendPic = null;
         mGiftIcon = null;
         if(mAcceptAndSendButton)
         {
            mAcceptAndSendButton.destroy();
         }
         mAcceptAndSendButton = null;
         if(mDeclineButton)
         {
            mDeclineButton.destroy();
         }
         mDeclineButton = null;
      }
   }
}

