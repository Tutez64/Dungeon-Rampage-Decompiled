package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIButton;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.desktop.NativeApplication;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class UIExitPopup extends DBUITwoButtonPopup
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_town.swf";
      
      protected static const POPUP_CLASS_NAME:String = "popup_exit";
      
      private var mDiscordButton:UIButton;
      
      public function UIExitPopup(dbFacade:DBFacade)
      {
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc2_:String = null;
         var _loc5_:Function = null;
         var _loc8_:String = null;
         var _loc3_:Function = null;
         var _loc7_:Boolean = dbFacade.dbConfigManager.getConfigBoolean("show_wishlist_on_exit_popup",false);
         if(_loc7_)
         {
            _loc4_ = Locale.getString("EXIT_POPUP_TITLE");
            _loc6_ = Locale.getString("EXIT_POPUP_MESSAGE_CALL_TO_ACTION");
            _loc2_ = Locale.getString("EXIT_WISHLIST");
            _loc5_ = wishlistAction;
            _loc8_ = Locale.getString("EXIT_GAME");
            _loc3_ = exitApplicationAction;
         }
         else
         {
            _loc4_ = Locale.getString("EXIT_POPUP_TITLE_CHICKEN_OUT");
            _loc6_ = Locale.getString("EXIT_POPUP_MESSAGE");
            _loc2_ = Locale.getString("EXIT_GAME_GIVE_UP");
            _loc5_ = exitApplicationAction;
            _loc8_ = Locale.getString("EXIT_KEEP_PLAYING");
            _loc3_ = closePopupAction;
         }
         super(dbFacade,_loc4_,_loc6_,_loc2_,_loc5_,_loc8_,_loc3_,true,closePopupAction,true,true,"EXIT_POPUP");
      }
      
      private function wishlistAction() : void
      {
         mDBFacade.overlaySteamwithURL("steam://store/3053950");
      }
      
      private function exitApplicationAction() : void
      {
         NativeApplication.nativeApplication.exit();
      }
      
      private function closePopupAction() : void
      {
         this.destroy();
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mDiscordButton = new UIButton(mDBFacade,mPopup.discord_button);
         mDiscordButton.releaseCallback = function():void
         {
            var _loc1_:URLRequest = new URLRequest("https://discord.com/invite/dungeonrampage");
            navigateToURL(_loc1_,"_blank");
         };
         setupMenuNavigationLinks();
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_town.swf";
      }
      
      override protected function getClassName() : String
      {
         return "popup_exit";
      }
      
      public function setupMenuNavigationLinks() : void
      {
         mCloseButton.clearNavigationAndInteractions();
         mLeftButton.clearNavigationAndInteractions();
         mRightButton.clearNavigationAndInteractions();
         mDiscordButton.clearNavigationAndInteractions();
         mDiscordButton.navigationSelectedInteraction = function():void
         {
            DBGlobal.highlightButton(mDiscordButton);
         };
         mDiscordButton.navigationSetToUnselectedInteraction = function():void
         {
            DBGlobal.unHighlightButton(mDiscordButton);
         };
         mLeftButton.isToTheLeftOf(mDiscordButton);
         mDiscordButton.isToTheLeftOf(mRightButton);
         mCloseButton.isAbove(mLeftButton);
         mRightButton.upNavigation = mCloseButton;
      }
   }
}

