package UI.Inventory
{
   import Account.AvatarInfo;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMHero;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class UIHeroTooltip extends MovieClip
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mRoot:MovieClip;
      
      protected var mLabel:TextField;
      
      protected var mLevelLabel:TextField;
      
      protected var mDescriptionLabel:TextField;
      
      protected var mStar:MovieClip;
      
      public function UIHeroTooltip(dbFacade:DBFacade, templateClass:Class)
      {
         super();
         mDBFacade = dbFacade;
         mRoot = new templateClass();
         this.addChild(mRoot);
         mLabel = mRoot.title_label;
         mLevelLabel = mRoot.level_star_label;
         mDescriptionLabel = mRoot.description_label;
         mStar = mRoot.star;
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         this.removeChild(mRoot);
         mRoot = null;
      }
      
      public function set ownedHero(avatarInfo:AvatarInfo) : void
      {
         mLabel.text = GameMasterLocale.getGameMasterSubString("SKIN_NAME",avatarInfo.gmHero.Constant).toUpperCase();
         mLevelLabel.text = avatarInfo.level.toString();
         mLevelLabel.visible = true;
         mStar.visible = true;
         mDescriptionLabel.visible = false;
      }
      
      public function set unownedHero(gmHero:GMHero) : void
      {
         mLabel.text = GameMasterLocale.getGameMasterSubString("SKIN_NAME",gmHero.Constant).toUpperCase();
         mLevelLabel.visible = false;
         mStar.visible = false;
         mDescriptionLabel.text = Locale.getString("HERO_NOT_UNLOCKED_TOOLTIP");
         mDescriptionLabel.visible = true;
      }
   }
}

