package UI.Training
{
   import Facade.GameMasterLocale;
   import flash.text.TextFormat;
   
   public class UIStatUpgradeTooltip extends UIStatTooltipBox
   {
      
      private static const DIFFERENCE_COLOR:uint = 65280;
      
      public function UIStatUpgradeTooltip(templateClass:Class)
      {
         super(templateClass);
      }
      
      public function update(statName:String, description:String) : void
      {
         var _loc3_:int = 0;
         setTexts(GameMasterLocale.getGameMasterSubString("STATS_NAME",statName).toUpperCase(),description,1.55);
         var _loc5_:TextFormat = new TextFormat();
         _loc5_.color = 65280;
         var _loc4_:int = description.indexOf("(+");
         while(_loc4_ >= 0)
         {
            _loc3_ = description.indexOf(")",_loc4_);
            if(_loc3_ < 0)
            {
               break;
            }
            mDescription.setTextFormat(_loc5_,_loc4_,_loc3_ + 1);
            _loc4_ = description.indexOf("(+",_loc3_ + 1);
         }
      }
   }
}

