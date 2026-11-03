package Settings.Model
{
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Input.KeyBindings.InputAction;
   import Settings.Model.Bindings.DisplayTimingBinding;
   import Settings.Model.Bindings.HudStyleBinding;
   import Settings.Model.Bindings.KeyBindingSettingBinding;
   import Settings.Model.Bindings.SoundVolumeBinding;
   import flash.utils.Dictionary;
   
   public class SettingsCatalog
   {
      
      public static const STARTUP_FLAGS:Object = buildStartupFlags();
      
      private var mDBFacade:DBFacade;
      
      private var mDefinitions:Vector.<SettingDefinition>;
      
      private var mDefinitionsById:Dictionary;
      
      public function SettingsCatalog(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mDefinitions = new Vector.<SettingDefinition>();
         mDefinitionsById = new Dictionary();
         var _loc4_:Vector.<SettingsSection> = new <SettingsSection>[defineGraphics(),defineAudio(),defineControls(),defineInterface(),defineDisplay(),defineAdvanced()];
         for each(var _loc2_:SettingsSection in _loc4_)
         {
            for each(var _loc3_:SettingDefinition in _loc2_.build())
            {
               mDefinitions.push(_loc3_);
               mDefinitionsById[_loc3_.id] = _loc3_;
            }
         }
      }
      
      private static function startupFlag(declared:SettingsSection, id:String) : SettingBuilder
      {
         return declared.flag(id,STARTUP_FLAGS[id]).requiresRestart();
      }
      
      private static function buildStartupFlags() : Object
      {
         var _loc1_:Object = {};
         _loc1_["steamInput"] = "experimental-use-steam-input";
         _loc1_["startWindowed"] = "start-windowed";
         _loc1_["resumableConnection"] = "experimental-websocket-reconnects";
         return _loc1_;
      }
      
      public function get definitions() : Vector.<SettingDefinition>
      {
         return mDefinitions;
      }
      
      public function getDefinition(id:String) : SettingDefinition
      {
         return mDefinitionsById[id] as SettingDefinition;
      }
      
      public function getDefinitionsForCategory(category:String) : Vector.<SettingDefinition>
      {
         var _loc2_:Vector.<SettingDefinition> = new Vector.<SettingDefinition>();
         for each(var _loc3_:SettingDefinition in mDefinitions)
         {
            if(_loc3_.category == category)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function destroy() : void
      {
         for each(var _loc1_:SettingDefinition in mDefinitions)
         {
            if(_loc1_.binding != null)
            {
               _loc1_.binding.destroy();
               _loc1_.binding = null;
            }
            _loc1_.coerceValue = null;
            _loc1_.descriptionKeyProvider = null;
         }
         mDefinitions = null;
         mDefinitionsById = null;
         mDBFacade = null;
      }
      
      private function section(category:String) : SettingsSection
      {
         return new SettingsSection(mDBFacade,category);
      }
      
      private function defineGraphics() : SettingsSection
      {
         var _loc1_:SettingsSection = section("graphics");
         _loc1_.setting("graphicsPreset").defaultsTo("quality").presetChoice("performance",GraphicsPreset.membersAt(false)).presetChoice("quality",GraphicsPreset.membersAt(true)).derivedChoice("custom");
         _loc1_.flag("zoom","want-zoom");
         _loc1_.flag("damageFloaters","want-damage-floaters");
         _loc1_.flag("rarityBackgrounds","want-dynamic-rarity-backgrounds");
         _loc1_.flag("busterBackgroundFade","want-buster-background-fade");
         return _loc1_;
      }
      
      private function defineAudio() : SettingsSection
      {
         var _loc1_:SettingsSection = section("audio");
         volume(_loc1_,"musicVolume","music");
         volume(_loc1_,"sfxVolume","sfx");
         return _loc1_;
      }
      
      private function volume(audio:SettingsSection, id:String, channel:String) : void
      {
         audio.setting(id).defaultsTo(channel == "music" ? DBGlobal.MUSIC_VOLUME : DBGlobal.SFX_VOLUME).boundTo(new SoundVolumeBinding(mDBFacade,channel)).range(0,1.1,0.1).displayedAs(10);
      }
      
      private function defineControls() : SettingsSection
      {
         var _loc1_:SettingsSection = section("controls");
         startupFlag(_loc1_,"steamInput");
         _loc1_.flag("controllerRumble","want-controller-rumble");
         for each(var _loc2_:String in InputAction.ORDERED)
         {
            _loc1_.setting(SettingIds.keyBindingIdFor(_loc2_)).keyBinding(_loc2_).defaultsTo(KeyBindingValue.make(InputAction.defaultPrimary(_loc2_),InputAction.defaultAlternate(_loc2_))).boundTo(new KeyBindingSettingBinding(mDBFacade,_loc2_));
         }
         return _loc1_;
      }
      
      private function defineInterface() : SettingsSection
      {
         var _loc1_:SettingsSection = section("interface");
         _loc1_.setting("hudStyle").defaultsTo(0).boundTo(new HudStyleBinding(mDBFacade)).choice(0,"SETTING_HUD_STYLE_ORIGINAL").choice(1,"SETTING_HUD_STYLE_CONDENSED");
         _loc1_.flag("numbersOnBars","want-numbered-hud");
         _loc1_.flag("townAnimations","want-town-animations");
         _loc1_.flag("pickupUiPop","want-pickup-ui-pop");
         return _loc1_;
      }
      
      private function defineDisplay() : SettingsSection
      {
         var _loc2_:SettingsSection = section("display");
         var _loc1_:DisplayTimingSettings = mDBFacade.displayTimingSettings;
         _loc2_.setting("fps").defaultsTo(60).boundTo(new DisplayTimingBinding(_loc1_,true)).choicesFrom(_loc1_.frameRates.choices,FrameRateOptions.coerce);
         _loc2_.setting("vsync").defaultsTo(true).boundTo(new DisplayTimingBinding(_loc1_,false)).descriptionFrom(_loc1_.vsyncDescriptionKey);
         startupFlag(_loc2_,"startWindowed");
         return _loc2_;
      }
      
      private function defineAdvanced() : SettingsSection
      {
         var _loc1_:SettingsSection = section("advanced");
         startupFlag(_loc1_,"resumableConnection");
         return _loc1_;
      }
   }
}

