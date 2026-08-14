package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderController;
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMFeedPosts;
   import GameMasterDictionary.GMSkin;
   import flash.display.MovieClip;
   
   public class UIDungeonSummaryLevelUpPopup extends DBUIOneButtonPopup
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_town.swf";
      
      protected static const POPUP_CLASS_NAME:String = "UI_prompt_levelup";
      
      private static const AVATAR_PIC_SCALE:Number = 0.45;
      
      private var mGMSkin:GMSkin;
      
      private var mLevelUpPost:GMFeedPosts;
      
      private var mPicClass:Class;
      
      public function UIDungeonSummaryLevelUpPopup(dbFacade:DBFacade, centerCallback:Function, gmSkin:GMSkin, levelUpPost:GMFeedPosts, avatarClass:Class)
      {
         mGMSkin = gmSkin;
         mLevelUpPost = levelUpPost;
         mPicClass = avatarClass;
         super(dbFacade,Locale.getString("INVITE_POPUP_TITLE"),Locale.getString("INVITE_POPUP_MESSAGE"),null,centerCallback,true,null,null,null,true,"DUNGEON_SUMMARY_LEVEL_UP_POPUP");
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
         mPopup.level_text.text = mLevelUpPost.LevelTrigger;
         mPopup.congrats_label.text = Locale.getString("LEVEL_UP_SHARE_TITLE");
         mPopup.label.text = Locale.getString("LEVEL_UP_SHARE_TEXT") + mLevelUpPost.LevelTrigger;
         levelUpButton = new UIButton(mDBFacade,mPopup.share);
         if(mDBFacade.isDRPlayer)
         {
            levelUpButton.label.text = Locale.getString("SWEET");
         }
         else
         {
            levelUpButton.label.text = Locale.getString("LEVEL_UP_SHARE_BUTTON_TEXT");
         }
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

