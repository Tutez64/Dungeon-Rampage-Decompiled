package UI.Training
{
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMStat;
   import GameMasterDictionary.GMSuperStat;
   
   public class UIStatTooltip extends UIStatTooltipBox
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mGMStatItem:GMStat;
      
      protected var mGMSuperStatItem:GMSuperStat;
      
      public function UIStatTooltip(dbFacade:DBFacade, templateClass:Class)
      {
         super(templateClass);
         mDBFacade = dbFacade;
      }
      
      override public function destroy() : void
      {
         mDBFacade = null;
         super.destroy();
      }
      
      public function set statItem(value:GMStat) : void
      {
         mGMStatItem = value;
         setTexts(GameMasterLocale.getGameMasterSubString("STATS_NAME",mGMStatItem.Constant).toUpperCase(),GameMasterLocale.getGameMasterSubString("STATS_DESCRIPTION",mGMStatItem.Constant),1.55);
      }
      
      public function set superStatItem(value:GMSuperStat) : void
      {
         mGMSuperStatItem = value;
         setTexts(GameMasterLocale.getGameMasterSubString("STATS_NAME",mGMSuperStatItem.Constant).toUpperCase(),GameMasterLocale.getGameMasterSubString("STATS_DESCRIPTION",mGMSuperStatItem.Constant),1.55);
      }
   }
}

