package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderController;
   import Brain.UI.UIButton;
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMSkin;
   import flash.display.MovieClip;
   
   public class UIDungeonSummaryLevelUpPopup extends DBUIOneButtonPopup
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_town.swf";
      
      protected static const POPUP_CLASS_NAME:String = "UI_prompt_levelup";
      
      private static const AVATAR_PIC_SCALE:Number = 0.45;
      
      public static const LEVELS:Vector.<uint> = new <uint>[3,4,5,10,15,20,25,30,40,50,60,70,80,90,100];
      
      private var mGMSkin:GMSkin;
      
      private var mLevel:uint;
      
      private var mPicClass:Class;
      
      public function UIDungeonSummaryLevelUpPopup(dbFacade:DBFacade, centerCallback:Function, gmSkin:GMSkin, level:uint, avatarClass:Class)
      {
         mGMSkin = gmSkin;
         mLevel = level;
         mPicClass = avatarClass;
         super(dbFacade,"DUNGEON_SUMMARY_LEVEL_UP_POPUP",Locale.getString("INVITE_POPUP_TITLE"),Locale.getString("INVITE_POPUP_MESSAGE"),null,centerCallback);
         mDBFacade.metrics.log("InvitePopupPresented");
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_town.swf";
      }
      
      override protected function getClassName() : String
      {
         return "UI_prompt_levelup";
      }
      
      override protected function centerButtonCallback() : void
      {
         mDBFacade.metrics.log("InvitePopupContinue");
         super.centerButtonCallback();
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         var avatarPic:MovieClip;
         var movieClipRenderer:MovieClipRenderController;
         var levelUpButton:UIButton;
         super.setupUI(swfAsset,titleText,null,allowClose,closeCallback);
         mPopup.x += 40;
         avatarPic = new mPicClass();
         movieClipRenderer = new MovieClipRenderController(mDBFacade,avatarPic);
         movieClipRenderer.play();
         avatarPic.scaleX = avatarPic.scaleY = 0.45;
         mPopup.avatar.addChildAt(avatarPic,0);
         TextUtil.setText(mPopup.level_text,String(mLevel));
         Locale.setText(mPopup.congrats_label,"LEVEL_UP_SHARE_TITLE");
         TextUtil.setText(mPopup.label,Locale.getString("LEVEL_UP_SHARE_TEXT") + mLevel);
         levelUpButton = new UIButton(mDBFacade,mPopup.share);
         Locale.setText(levelUpButton.label,"SWEET");
         levelUpButton.releaseCallback = function():void
         {
            close(null);
         };
         mPopup.x = mDBFacade.viewWidth / 2;
         mPopup.y = mDBFacade.viewHeight / 2;
         mCloseButton.clearNavigationAndInteractions();
         mCloseButton.isAbove(levelUpButton);
      }
   }
}

