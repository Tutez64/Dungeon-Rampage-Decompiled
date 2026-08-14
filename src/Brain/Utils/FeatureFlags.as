package Brain.Utils
{
   import Brain.Logger.Logger;
   import flash.utils.Dictionary;
   
   public class FeatureFlags
   {
      
      public static const USE_HD_ASSETS:String = "use-hd-assets";
      
      public static const WANT_ZOOM:String = "want-zoom";
      
      public static const WANT_DYNAMIC_RARITY_BACKGROUNDS:String = "want-dynamic-rarity-backgrounds";
      
      public static const WANT_DAMAGE_FLOATERS:String = "want-damage-floaters";
      
      public static const WANT_TOWN_ANIMATIONS:String = "want-town-animations";
      
      public static const WANT_BUSTER_BACKGROUND_FADE:String = "want-buster-background-fade";
      
      public static const WANT_PICKUP_UI_POP:String = "want-pickup-ui-pop";
      
      public static const WANT_MANA_BARS:String = "want-mana-bars";
      
      public static const QUALITY_CONTROL_BUTTON:String = "quality-control-button";
      
      public static const WANT_NUMBERS_ON_BARS:String = "want-numbered-hud";
      
      public static const WANT_REFRESH_HUD_ON_FLOOR_TRANSITION:String = "want-hud-refresh-on-floor-transition";
      
      public static const EXPERIMENTAL_USE_STEAM_INPUT:String = "experimental-use-steam-input";
      
      public static const WANT_STEAM_ACHIEVEMENTS:String = "want-steam-achievements";
      
      public static const USE_FALLBACK_SOCKET_PORT:String = "use-fallback-socket-port";
      
      private var mFeatureFlags:Dictionary;
      
      public function FeatureFlags()
      {
         super();
         mFeatureFlags = new Dictionary();
         MemoryTracker.track(mFeatureFlags,"Dictionary - feature flags storage in FeatureFlags()","brain");
         addFeatureFlag("use-hd-assets",false,"--experimental-use-hd-assets","experimental_use_hd_assets");
         addFeatureFlag("want-zoom",false);
         addFeatureFlag("want-dynamic-rarity-backgrounds",false);
         addFeatureFlag("want-damage-floaters",false);
         addFeatureFlag("want-town-animations",false);
         addFeatureFlag("want-buster-background-fade",false);
         addFeatureFlag("want-pickup-ui-pop",false);
         addFeatureFlag("want-mana-bars",false);
         addFeatureFlag("quality-control-button",true);
         addFeatureFlag("want-numbered-hud",false);
         addFeatureFlag("want-hud-refresh-on-floor-transition",false);
         addFeatureFlag("experimental-use-steam-input",false);
         addFeatureFlag("want-steam-achievements",false);
         addFeatureFlag("use-fallback-socket-port",false);
      }
      
      private function addFeatureFlag(name:String, defaultValue:Boolean, commandLineFlag:String = null, configFileAttributeName:String = null) : void
      {
         mFeatureFlags[name] = FeatureFlag.featureFlagFactory(name,defaultValue,commandLineFlag,configFileAttributeName);
      }
      
      public function getFlagValue(name:String) : Boolean
      {
         return mFeatureFlags[name].currentValue;
      }
      
      public function setFlagDatabaseValueOnFirstLoad(flagName:String, value:Boolean) : void
      {
         mFeatureFlags[flagName].setDbValue(value);
      }
      
      public function setFlagOverrideValue(flagName:String, value:Boolean) : void
      {
         mFeatureFlags[flagName].setOverrideValue(value);
      }
      
      public function loadFeatureFlagValuesFromCli(arguments:Array) : void
      {
         var _loc6_:int = 0;
         var _loc5_:String = null;
         var _loc8_:FeatureFlag = null;
         var _loc7_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:String = null;
         _loc6_ = 0;
         while(_loc6_ < arguments.length)
         {
            _loc5_ = arguments[_loc6_];
            if(_loc5_.indexOf("--") == 0)
            {
               _loc8_ = null;
               for each(var _loc2_:FeatureFlag in mFeatureFlags)
               {
                  if(_loc2_.commandLineFlag == _loc5_)
                  {
                     _loc8_ = _loc2_;
                     break;
                  }
               }
               if(_loc8_ != null)
               {
                  _loc7_ = true;
                  if(_loc6_ + 1 < arguments.length)
                  {
                     _loc3_ = arguments[_loc6_ + 1];
                     _loc4_ = _loc3_.toLowerCase();
                     if(_loc4_ == "true" || _loc4_ == "false")
                     {
                        _loc7_ = _loc4_ == "true";
                        _loc6_++;
                     }
                  }
                  _loc8_.setCliValue(_loc7_);
               }
            }
            _loc6_++;
         }
      }
      
      public function loadFeatureFlagValuesFromConfigs(configManager:ConfigManager) : void
      {
         var _loc4_:Object = null;
         var _loc3_:Boolean = false;
         for each(var _loc2_:FeatureFlag in mFeatureFlags)
         {
            _loc4_ = configManager.getConfigObject(_loc2_.configFileAttributeName,null);
            if(_loc4_ != null)
            {
               _loc3_ = _loc4_ as Boolean;
               _loc2_.setConfigFileValue(_loc3_);
            }
         }
      }
      
      public function logFeatureFlagNamesAndValues() : void
      {
         for each(var _loc1_:Object in mFeatureFlags)
         {
            Logger.log("Flag Name: " + _loc1_.name.toString() + " Flag Value:" + getFlagValue(_loc1_.name));
         }
      }
   }
}

