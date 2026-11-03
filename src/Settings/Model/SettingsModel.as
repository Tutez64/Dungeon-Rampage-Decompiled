package Settings.Model
{
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import Input.KeyBindings.KeyBindings;
   import Settings.Model.Bindings.FeatureFlagBinding;
   
   public class SettingsModel
   {
      
      private static const MUSIC_VOLUME_ELEVEN:int = 11;
      
      private var mDBFacade:DBFacade;
      
      private var mCatalog:SettingsCatalog;
      
      private var mStore:SettingsStore;
      
      private var mValues:Object;
      
      private var mStoredValues:Object;
      
      private var mForgottenIds:Object;
      
      private var mLoadedValues:Object;
      
      private var mDirtyIds:Object;
      
      private var mChangeListeners:Vector.<Function>;
      
      public function SettingsModel(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mCatalog = new SettingsCatalog(dbFacade);
         mStore = new SettingsStore();
         mChangeListeners = new Vector.<Function>();
         mDirtyIds = {};
         mForgottenIds = {};
         loadAndApply();
         mDBFacade.displayTimingSettings.changed = notifyChanged;
      }
      
      private static function sameValue(definition:SettingDefinition, a:*, b:*) : Boolean
      {
         if(a === b)
         {
            return true;
         }
         return definition.isKeyBinding && KeyBindingValue.equals(a,b);
      }
      
      public function get catalog() : SettingsCatalog
      {
         return mCatalog;
      }
      
      public function get isDirty() : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Object = mDirtyIds;
         for(var _loc1_:String in _loc2_)
         {
            return true;
         }
         return false;
      }
      
      public function get hasPendingRestart() : Boolean
      {
         var _loc1_:SettingDefinition = null;
         for(var _loc2_:String in mDirtyIds)
         {
            _loc1_ = mCatalog.getDefinition(_loc2_);
            if(_loc1_ != null && _loc1_.requiresRestart)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getValue(id:String) : *
      {
         var _loc2_:SettingDefinition = mCatalog.getDefinition(id);
         if(_loc2_ == null)
         {
            return null;
         }
         if(_loc2_.isPreset)
         {
            return resolvePreset(_loc2_);
         }
         return mValues[id];
      }
      
      public function getBoolean(id:String) : Boolean
      {
         return getValue(id) == true;
      }
      
      public function getNumber(id:String) : Number
      {
         return Number(getValue(id));
      }
      
      public function setValue(id:String, value:*) : void
      {
         var _loc3_:SettingDefinition = mCatalog.getDefinition(id);
         if(_loc3_ == null)
         {
            Logger.warn("Tried to set unknown setting: " + id);
            return;
         }
         if(_loc3_.isPreset)
         {
            applyPreset(_loc3_,value);
            return;
         }
         if(_loc3_.coerceValue != null)
         {
            value = _loc3_.coerceValue(value);
         }
         if(sameValue(_loc3_,mValues[id],value))
         {
            return;
         }
         mValues[id] = value;
         mDirtyIds[id] = true;
         delete mForgottenIds[id];
         if(_loc3_.binding != null)
         {
            _loc3_.binding.write(value);
         }
         applyAchievementHooks(_loc3_,value);
         notifyChanged(id);
      }
      
      public function assignKey(id:String, slotName:String, keyCode:int) : void
      {
         var _loc5_:Object = null;
         var _loc6_:SettingDefinition = mCatalog.getDefinition(id);
         if(_loc6_ == null || !_loc6_.isKeyBinding)
         {
            Logger.warn("Tried to assign a key to a setting that is not a binding: " + id);
            return;
         }
         if(!KeyBindings.isBindable(keyCode))
         {
            return;
         }
         for each(var _loc4_:SettingDefinition in mCatalog.definitions)
         {
            if(_loc4_.isKeyBinding)
            {
               _loc5_ = mValues[_loc4_.id];
               if(KeyBindingValue.primary(_loc5_) == keyCode)
               {
                  setValue(_loc4_.id,KeyBindingValue.withSlot(_loc5_,"primary",0));
               }
               if(KeyBindingValue.alternate(_loc5_) == keyCode)
               {
                  setValue(_loc4_.id,KeyBindingValue.withSlot(mValues[_loc4_.id],"alternate",0));
               }
            }
         }
         setValue(id,KeyBindingValue.withSlot(mValues[id],slotName,keyCode));
      }
      
      public function resetKeyBinding(id:String) : void
      {
         var _loc4_:SettingDefinition = mCatalog.getDefinition(id);
         if(_loc4_ == null || !_loc4_.isKeyBinding)
         {
            Logger.warn("Tried to reset the keys of a setting that is not a binding: " + id);
            return;
         }
         var _loc2_:int = KeyBindingValue.primary(_loc4_.defaultValue);
         var _loc3_:int = KeyBindingValue.alternate(_loc4_.defaultValue);
         setValue(id,KeyBindingValue.make(0,0));
         if(KeyBindings.isBindable(_loc2_))
         {
            assignKey(id,"primary",_loc2_);
         }
         if(KeyBindings.isBindable(_loc3_))
         {
            assignKey(id,"alternate",_loc3_);
         }
      }
      
      public function revert() : void
      {
         for(var _loc1_:String in mDirtyIds)
         {
            setValue(_loc1_,mLoadedValues[_loc1_]);
         }
         mDirtyIds = {};
         mForgottenIds = {};
      }
      
      public function resetCategory(category:String) : void
      {
         for each(var _loc2_:SettingDefinition in mCatalog.getDefinitionsForCategory(category))
         {
            if(_loc2_.isPersisted)
            {
               if(_loc2_.binding is FeatureFlagBinding)
               {
                  forgetFlag(_loc2_);
               }
               else
               {
                  setValue(_loc2_.id,_loc2_.defaultValue);
                  if(!sameValue(_loc2_,mStoredValues[_loc2_.id],_loc2_.defaultValue))
                  {
                     mDirtyIds[_loc2_.id] = true;
                  }
               }
            }
         }
      }
      
      public function resetAll() : void
      {
         for each(var _loc1_:String in SettingCategory.ORDERED)
         {
            resetCategory(_loc1_);
         }
      }
      
      public function apply() : void
      {
         if(!isDirty)
         {
            return;
         }
         for(var _loc1_:String in mDirtyIds)
         {
            if(mForgottenIds[_loc1_])
            {
               delete mStoredValues[_loc1_];
            }
            else
            {
               mStoredValues[_loc1_] = mValues[_loc1_];
            }
            mLoadedValues[_loc1_] = mValues[_loc1_];
         }
         mDirtyIds = {};
         mForgottenIds = {};
         mStore.writeAll(mCatalog,mStoredValues);
      }
      
      private function forgetFlag(definition:SettingDefinition) : void
      {
         var _loc2_:String = definition.id;
         var _loc3_:Boolean = mStoredValues.hasOwnProperty(_loc2_) || mDirtyIds[_loc2_];
         FeatureFlagBinding(definition.binding).clear();
         var _loc4_:* = definition.binding.read();
         var _loc5_:Boolean = !sameValue(definition,mValues[_loc2_],_loc4_);
         mValues[_loc2_] = _loc4_;
         if(_loc3_ || _loc5_)
         {
            mDirtyIds[_loc2_] = true;
            mForgottenIds[_loc2_] = true;
         }
         if(_loc5_)
         {
            notifyChanged(_loc2_);
         }
      }
      
      public function addChangeListener(listener:Function) : void
      {
         if(mChangeListeners.indexOf(listener) == -1)
         {
            mChangeListeners.push(listener);
         }
      }
      
      public function removeChangeListener(listener:Function) : void
      {
         var _loc2_:int = mChangeListeners.indexOf(listener);
         if(_loc2_ != -1)
         {
            mChangeListeners.splice(_loc2_,1);
         }
      }
      
      public function destroy() : void
      {
         apply();
         mDBFacade.displayTimingSettings.changed = null;
         mChangeListeners = null;
         mValues = null;
         mStoredValues = null;
         mLoadedValues = null;
         mDirtyIds = null;
         mForgottenIds = null;
         mStore.destroy();
         mStore = null;
         mCatalog.destroy();
         mCatalog = null;
         mDBFacade = null;
      }
      
      private function loadAndApply() : void
      {
         var _loc2_:* = undefined;
         mStoredValues = mStore.readAll(mCatalog);
         mValues = {};
         mLoadedValues = {};
         for each(var _loc1_:SettingDefinition in mCatalog.definitions)
         {
            if(_loc1_.isPersisted)
            {
               if(mStoredValues.hasOwnProperty(_loc1_.id))
               {
                  _loc1_.binding.writeInitial(mStoredValues[_loc1_.id]);
               }
               _loc2_ = _loc1_.binding.read();
               mValues[_loc1_.id] = _loc2_;
               mLoadedValues[_loc1_.id] = _loc2_;
            }
         }
      }
      
      private function resolvePreset(definition:SettingDefinition) : *
      {
         var _loc2_:SettingChoice = null;
         for each(var _loc3_:SettingChoice in definition.choices)
         {
            if(_loc3_.derived)
            {
               _loc2_ = _loc3_;
            }
            else if(_loc3_.memberValues != null)
            {
               if(membersMatch(_loc3_.memberValues))
               {
                  return _loc3_.value;
               }
            }
         }
         return _loc2_ != null ? _loc2_.value : definition.defaultValue;
      }
      
      private function membersMatch(memberValues:Object) : Boolean
      {
         for(var _loc2_:String in memberValues)
         {
            if(mValues[_loc2_] !== memberValues[_loc2_])
            {
               return false;
            }
         }
         return true;
      }
      
      private function applyPreset(definition:SettingDefinition, value:*) : void
      {
         var _loc3_:SettingChoice = definition.findChoice(value);
         if(_loc3_ == null || _loc3_.memberValues == null)
         {
            return;
         }
         for(var _loc4_:String in _loc3_.memberValues)
         {
            choosePresetMember(_loc4_,_loc3_.memberValues[_loc4_]);
         }
         notifyChanged(definition.id);
      }
      
      private function choosePresetMember(id:String, value:*) : void
      {
         var _loc3_:SettingDefinition = mCatalog.getDefinition(id);
         if(_loc3_ == null || !sameValue(_loc3_,mValues[id],value))
         {
            setValue(id,value);
            return;
         }
         mDirtyIds[id] = true;
         delete mForgottenIds[id];
         if(_loc3_.binding != null)
         {
            _loc3_.binding.write(value);
         }
      }
      
      private function applyAchievementHooks(definition:SettingDefinition, value:*) : void
      {
         if(definition.id != "musicVolume")
         {
            return;
         }
         if(int(Number(value) * definition.displayScale) != 11)
         {
            return;
         }
         if(mDBFacade.steamAchievementsHelper == null)
         {
            return;
         }
         mDBFacade.steamAchievementsHelper.unlockAchievement("MUSIC_VOLUME_SET_TO_11");
      }
      
      private function notifyChanged(id:String) : void
      {
         var _loc2_:Vector.<Function> = mChangeListeners.concat();
         for each(var _loc3_:Function in _loc2_)
         {
            _loc3_(id);
         }
      }
   }
}

