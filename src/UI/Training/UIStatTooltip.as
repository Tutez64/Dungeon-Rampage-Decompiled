package UI.Training
{
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMStat;
   import GameMasterDictionary.GMSuperStat;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class UIStatTooltip extends MovieClip
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mRoot:MovieClip;
      
      protected var mGMStatItem:GMStat;
      
      protected var mGMSuperStatItem:GMSuperStat;
      
      protected var mTitleLabel:TextField;
      
      protected var mDescription:TextField;
      
      public function UIStatTooltip(dbFacade:DBFacade, templateClass:Class)
      {
         super();
         mDBFacade = dbFacade;
         mRoot = new templateClass();
         this.addChild(mRoot);
         mTitleLabel = mRoot.title_label;
         mDescription = mRoot.stat_description_label;
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         this.removeChild(mRoot);
         mRoot = null;
      }
      
      public function set statItem(value:GMStat) : void
      {
         mGMStatItem = value;
         mTitleLabel.text = GameMasterLocale.getGameMasterSubString("STATS_NAME",mGMStatItem.Constant).toUpperCase();
         mDescription.text = GameMasterLocale.getGameMasterSubString("STATS_DESCRIPTION",mGMStatItem.Constant);
      }
      
      public function set superStatItem(value:GMSuperStat) : void
      {
         mGMSuperStatItem = value;
         mTitleLabel.text = GameMasterLocale.getGameMasterSubString("STATS_NAME",mGMSuperStatItem.Constant).toUpperCase();
         mDescription.text = GameMasterLocale.getGameMasterSubString("STATS_DESCRIPTION",mGMSuperStatItem.Constant);
      }
   }
}

