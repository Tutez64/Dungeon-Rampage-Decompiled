package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.display.Sprite;
   
   public class UIFBInvitePopup extends DBUIOneButtonPopup
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      protected static const POPUP_CLASS_NAME:String = "invite_popup";
      
      public function UIFBInvitePopup(dbFacade:DBFacade, centerCallback:Function)
      {
         super(dbFacade,Locale.getString("INVITE_POPUP_TITLE"),Locale.getString("INVITE_POPUP_MESSAGE"),Locale.getString("INVITE_POPUP_BUTTON"),centerCallback,true,null);
         mDBFacade.metrics.log("InvitePopupPresented");
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override protected function getClassName() : String
      {
         return "invite_popup";
      }
      
      override protected function centerButtonCallback() : void
      {
         mDBFacade.metrics.log("InvitePopupContinue");
         super.centerButtonCallback();
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mPopup.player_name_label.text = mDBFacade.dbAccountInfo.name;
         mPopup.chatBalloon.chatMessage.text = Locale.getString("INVITE_POPUP_CHAT");
         mPopup.nametag_1.visible = false;
         mPopup.nametag_2.visible = false;
         mPopup.nametag_3.visible = false;
         mDBFacade.facebookAccountInfo.loadFriends(this.loadedFriends);
      }
      
      private function loadedFriends(friends:Array) : void
      {
         var _loc2_:* = 0;
         var _loc4_:* = 0;
         var _loc3_:* = 0;
         if(friends.length >= 3)
         {
            Logger.debug("UIInvitePopup showing friends");
            mPopup.nametag_1.visible = true;
            mPopup.nametag_2.visible = true;
            mPopup.nametag_3.visible = true;
            _loc2_ = uint(Math.floor(Math.random() * friends.length));
            _loc4_ = uint(Math.floor(Math.random() * friends.length));
            while(_loc4_ == _loc2_)
            {
               _loc4_ = uint(Math.floor(Math.random() * friends.length));
            }
            _loc3_ = uint(Math.floor(Math.random() * friends.length));
            while(_loc3_ == _loc4_ || _loc3_ == _loc2_)
            {
               _loc3_ = uint(Math.floor(Math.random() * friends.length));
            }
            mPopup.nametag_1.name_label.text = friends[_loc2_].name;
            mPopup.nametag_2.name_label.text = friends[_loc4_].name;
            mPopup.nametag_3.name_label.text = friends[_loc3_].name;
            Sprite(mPopup.nametag_1.pic_bg).addChild(mDBFacade.facebookAccountInfo.loadFriendProfilePic(friends[_loc2_].id));
            Sprite(mPopup.nametag_2.pic_bg).addChild(mDBFacade.facebookAccountInfo.loadFriendProfilePic(friends[_loc4_].id));
            Sprite(mPopup.nametag_3.pic_bg).addChild(mDBFacade.facebookAccountInfo.loadFriendProfilePic(friends[_loc3_].id));
         }
         else
         {
            Logger.debug("UIInvitePopup: not enough friends to show");
         }
      }
   }
}

