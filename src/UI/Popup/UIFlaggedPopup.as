package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextFormat;
   
   public class UIFlaggedPopup extends DBUITwoButtonPopup
   {
      
      public function UIFlaggedPopup(dbFacade:DBFacade, isFlaggedDueToFamilySharingOwnerIsFlag:Boolean, isFlaggedDueToFamilySharingOwnerName:String, isFlaggedUntilAfterDate:String)
      {
         var _loc7_:String = null;
         var _loc9_:String = null;
         var _loc5_:String = null;
         var _loc8_:Function = null;
         var _loc10_:String = null;
         var _loc6_:Function = null;
         if(isFlaggedDueToFamilySharingOwnerIsFlag)
         {
            _loc7_ = Locale.getString("FLAGGED_POPUP_TITLE");
            _loc9_ = Locale.getString("FLAGGED_POPUP_MESSAGE_FAMILY_SHARING_OWNER") + "" + isFlaggedDueToFamilySharingOwnerName;
            _loc5_ = Locale.getString("OK");
            _loc8_ = closePopupAction;
            _loc10_ = Locale.getString("FLAGGED_READ_RULES");
            _loc6_ = readGameRules;
         }
         else if(isFlaggedUntilAfterDate != "" && isFlaggedUntilAfterDate != null)
         {
            _loc7_ = Locale.getString("FLAGGED_POPUP_TITLE");
            _loc9_ = Locale.getString("FLAGGED_POPUP_MESSAGE_UNTIL_DATE") + "\n" + isFlaggedUntilAfterDate;
            _loc5_ = Locale.getString("OK");
            _loc8_ = closePopupAction;
            _loc10_ = Locale.getString("FLAGGED_READ_RULES");
            _loc6_ = readGameRules;
         }
         else
         {
            _loc7_ = Locale.getString("FLAGGED_POPUP_TITLE");
            _loc9_ = Locale.getString("FLAGGED_POPUP_MESSAGE_NORMAL");
            _loc5_ = Locale.getString("OK");
            _loc8_ = closePopupAction;
            _loc10_ = Locale.getString("FLAGGED_READ_RULES");
            _loc6_ = readGameRules;
         }
         super(dbFacade,_loc7_,_loc9_,_loc5_,_loc8_,_loc10_,_loc6_,true,null);
      }
      
      private function readGameRules() : void
      {
         var _loc2_:URLRequest = null;
         var _loc1_:Boolean = Boolean(mDBFacade.mSteamworks.isOverlayEnabled());
         var _loc3_:Boolean = mDBFacade.stageRef.displayState == "fullScreenInteractive";
         if(_loc1_ && _loc3_)
         {
            Logger.debug("Using activateGameOverlayToStore to open steam page");
            mDBFacade.mSteamworks.activateGameOverlayToWebPage("https://steamcommunity.com/app/3053950/discussions/0/792200576013303398/");
         }
         else
         {
            Logger.debug("Using navigateToURL to open steam page because isOverlayEnabled:" + _loc1_ + " isFullscreen:" + _loc3_);
            _loc2_ = new URLRequest("https://steamcommunity.com/app/3053950/discussions/0/792200576013303398/");
            navigateToURL(_loc2_,"_blank");
         }
      }
      
      private function closePopupAction() : void
      {
         this.destroy();
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         var _loc6_:TextFormat = null;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         if(mMessage)
         {
            _loc6_ = mMessage.getTextFormat();
            _loc6_.size = int(_loc6_.size) - 2;
            mMessage.setTextFormat(_loc6_);
         }
      }
   }
}

