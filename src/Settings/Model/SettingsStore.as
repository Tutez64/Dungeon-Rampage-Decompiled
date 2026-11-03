package Settings.Model
{
   import Brain.Utils.FeatureFlags;
   import Settings.Model.Bindings.FeatureFlagBinding;
   
   public class SettingsStore
   {
      
      private static const FILE_VERSION_KEY:String = "settingsFileVersion";
      
      private static const FILE_VERSION:int = 2;
      
      private var mLocalFile:LocalSettingsFile;
      
      public function SettingsStore()
      {
         super();
         mLocalFile = new LocalSettingsFile();
      }
      
      public static function applyStartupFlags(featureFlags:FeatureFlags) : void
      {
         var _loc3_:String = null;
         var _loc5_:* = undefined;
         var _loc2_:Object = new LocalSettingsFile().read();
         if(_loc2_ == null)
         {
            return;
         }
         for(var _loc4_:String in SettingsCatalog.STARTUP_FLAGS)
         {
            _loc3_ = SettingsCatalog.STARTUP_FLAGS[_loc4_];
            _loc5_ = storedFlagValue(_loc2_,_loc4_,featureFlags.getFlagDefaultValue(_loc3_));
            if(_loc5_ !== undefined)
            {
               featureFlags.setFlagStoredSettingValue(_loc3_,_loc5_);
            }
         }
      }
      
      private static function coerce(definition:SettingDefinition, raw:*) : *
      {
         var _loc3_:Number = NaN;
         if(definition.coerceValue != null)
         {
            return definition.coerceValue(raw);
         }
         if(definition.isKeyBinding)
         {
            return KeyBindingValue.coerce(raw,definition.defaultValue);
         }
         if(definition.isChoice)
         {
            for each(var _loc4_:SettingChoice in definition.choices)
            {
               if(String(_loc4_.value) == String(raw))
               {
                  return _loc4_.value;
               }
            }
            return definition.defaultValue;
         }
         if(definition.isSlider)
         {
            _loc3_ = raw;
            if(isNaN(_loc3_))
            {
               return definition.defaultValue;
            }
            return Math.max(definition.minimum,Math.min(definition.maximum,_loc3_));
         }
         return coerceBoolean(raw);
      }
      
      private static function storedFlagValue(stored:Object, id:String, defaultValue:Boolean) : *
      {
         if(stored == null || !stored.hasOwnProperty(id))
         {
            return undefined;
         }
         var _loc4_:Boolean = coerceBoolean(stored[id]);
         if(!stored.hasOwnProperty("settingsFileVersion") && _loc4_ == defaultValue)
         {
            return undefined;
         }
         return _loc4_;
      }
      
      private static function coerceBoolean(raw:*) : Boolean
      {
         if(raw is Boolean)
         {
            return raw;
         }
         return String(raw) == "true" || String(raw) == "1";
      }
      
      public function destroy() : void
      {
         mLocalFile = null;
      }
      
      public function readAll(catalog:SettingsCatalog) : Object
      {
         var _loc4_:* = undefined;
         var _loc2_:Object = mLocalFile.read();
         var _loc3_:Object = {};
         for each(var _loc5_:SettingDefinition in catalog.definitions)
         {
            if(_loc5_.isPersisted)
            {
               if(_loc5_.binding is FeatureFlagBinding)
               {
                  _loc4_ = storedFlagValue(_loc2_,_loc5_.id,_loc5_.defaultValue);
                  if(_loc4_ !== undefined)
                  {
                     _loc3_[_loc5_.id] = _loc4_;
                  }
               }
               else if(_loc2_ != null && _loc2_.hasOwnProperty(_loc5_.id))
               {
                  _loc3_[_loc5_.id] = coerce(_loc5_,_loc2_[_loc5_.id]);
               }
               else
               {
                  _loc3_[_loc5_.id] = _loc5_.binding.read();
               }
            }
         }
         return _loc3_;
      }
      
      public function writeAll(catalog:SettingsCatalog, values:Object) : void
      {
         var _loc3_:Object = {};
         _loc3_["settingsFileVersion"] = 2;
         for each(var _loc4_:SettingDefinition in catalog.definitions)
         {
            if(_loc4_.isPersisted && values.hasOwnProperty(_loc4_.id))
            {
               _loc3_[_loc4_.id] = values[_loc4_.id];
            }
         }
         mLocalFile.write(_loc3_);
      }
   }
}

