package UI.Training
{
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMStat;
   import GameMasterDictionary.GMSuperStat;
   import GameMasterDictionary.StatVector;
   
   public class UIStatUpgradeDifferenceHelper
   {
      
      private static const FLAME_DPS:String = "FLAME_DPS";
      
      private static const MASTER_DEFENSE:String = "MASTER_DEFENSE";
      
      private static const BURNING_DPS_PER_POINT:Number = 3;
      
      private static const MAX_TRAINING_POINTS:uint = 75;
      
      private var mDBFacade:DBFacade;
      
      private var mStatName:String;
      
      private var mStatAmount:uint;
      
      private var mStatUpgradeAmount:Number;
      
      public function UIStatUpgradeDifferenceHelper(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
      }
      
      public function configure(statName:String, statUpgradeAmount:Number) : void
      {
         mStatName = statName;
         mStatUpgradeAmount = statUpgradeAmount;
      }
      
      public function set statAmount(value:uint) : void
      {
         mStatAmount = value;
      }
      
      public function get statName() : String
      {
         return mStatName;
      }
      
      public function get description() : String
      {
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc3_:Boolean = mStatAmount >= 75;
         if(mStatName == "FLAME_DPS")
         {
            return formatSpecialUpgradeLine(Locale.getString("TRAINING_UPGRADE_BURNING_DAMAGE_PER_SECOND"),3,false,_loc3_);
         }
         var _loc2_:GMSuperStat = mDBFacade.gameMaster.superStatByConstant.itemFor(mStatName);
         if(_loc2_ != null)
         {
            if(_loc2_.CookingRarityMaxPerPoint > 0)
            {
               _loc4_ = Locale.getString("TRAINING_UPGRADE_COOKING_RARITY");
               if(_loc2_.CookingFoodOnHitPerPoint > 0)
               {
                  return formatSpecialUpgradeLine(Locale.getString("TRAINING_UPGRADE_FOOD_ON_HIT_CHANCE_BONUS"),_loc2_.CookingFoodOnHitPerPoint / 100,true,_loc3_) + "\n" + _loc4_;
               }
               return _loc4_;
            }
            if(_loc2_.TrapPower > 0)
            {
               return formatSpecialUpgradeLine(Locale.getString("TRAINING_UPGRADE_TRAP_DAMAGE_BONUS"),_loc2_.TrapPower / 100,true,_loc3_);
            }
         }
         var _loc1_:GMStat = mDBFacade.gameMaster.statByConstant.itemFor(mStatName);
         if(_loc1_ != null)
         {
            return formatUpgradeLine(_loc1_,mStatUpgradeAmount * _loc1_.Bonus,_loc3_);
         }
         var _loc7_:Array = [];
         if(_loc2_ != null)
         {
            _loc5_ = 0;
            while(_loc5_ < StatVector.slotCount)
            {
               if(_loc2_.BaseValues.values[_loc5_] != 0)
               {
                  _loc1_ = mDBFacade.gameMaster.statByConstant.itemFor(DBGlobal.StatNames[_loc5_]);
                  if(_loc1_ != null)
                  {
                     _loc7_.push(formatUpgradeLine(_loc1_,_loc2_.BaseValues.values[_loc5_] * _loc1_.Bonus,_loc3_));
                  }
               }
               _loc5_++;
            }
            if(!isNaN(_loc2_.CooldownReduction) && _loc2_.CooldownReduction != 0)
            {
               _loc6_ = mStatUpgradeAmount * _loc2_.CooldownReduction * 0.01;
               _loc7_.push(formatSpecialUpgradeLine(Locale.getString("TRAINING_UPGRADE_COOLDOWN_BONUS"),_loc6_,true,_loc3_));
            }
         }
         if(_loc7_.length > 0)
         {
            return _loc7_.join("\n");
         }
         return _loc3_ ? Locale.getString("TRAINING_UPGRADE_MAXIMUM_LEVEL_REACHED") : "";
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
      }
      
      private function formatUpgradeLine(stat:GMStat, difference:Number, maximum:Boolean) : String
      {
         var _loc6_:String = GameMasterLocale.getGameMasterSubString("STATS_NAME",stat.Constant);
         var _loc4_:Boolean = stat.Constant == "MELEE_SPD" || stat.Constant == "SHOOT_SPD" || stat.Constant == "MAGIC_SPD" || stat.Constant == "MOVEMENT" || mStatName == "MASTER_DEFENSE";
         var _loc5_:String = Locale.format("TRAINING_UPGRADE_STAT_BONUS",{"STAT":_loc6_});
         return formatSpecialUpgradeLine(_loc5_,difference,_loc4_,maximum);
      }
      
      private function formatSpecialUpgradeLine(label:String, difference:Number, percentage:Boolean, maximum:Boolean) : String
      {
         var _loc5_:String = formatValue(mStatAmount * difference,percentage);
         if(maximum)
         {
            return Locale.format("TRAINING_UPGRADE_MAXIMUM_VALUE",{
               "LABEL":label,
               "CURRENT":_loc5_
            });
         }
         return Locale.format("TRAINING_UPGRADE_CURRENT_TO_NEXT",{
            "LABEL":label,
            "CURRENT":_loc5_,
            "NEXT":formatValue((mStatAmount + 1) * difference,percentage),
            "DIFFERENCE":formatDifference(difference,percentage)
         });
      }
      
      private function formatDifference(value:Number, percentage:Boolean) : String
      {
         return "(" + formatValue(value,percentage,true) + ")";
      }
      
      private function formatValue(value:Number, percentage:Boolean, includePlus:Boolean = false) : String
      {
         if(percentage)
         {
            value *= 100;
         }
         var _loc5_:Number = Math.round(value * 100) / 100;
         var _loc4_:String = _loc5_.toString();
         if(includePlus && _loc5_ > 0)
         {
            _loc4_ = "+" + _loc4_;
         }
         if(percentage)
         {
            _loc4_ += "%";
         }
         return _loc4_;
      }
   }
}

