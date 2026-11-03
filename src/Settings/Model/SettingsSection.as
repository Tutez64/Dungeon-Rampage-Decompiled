package Settings.Model
{
   import Facade.DBFacade;
   import Settings.Model.Bindings.FeatureFlagBinding;
   
   public class SettingsSection
   {
      
      private var mDBFacade:DBFacade;
      
      private var mCategory:String;
      
      private var mBuilders:Vector.<SettingBuilder> = new Vector.<SettingBuilder>();
      
      public function SettingsSection(dbFacade:DBFacade, category:String)
      {
         super();
         mDBFacade = dbFacade;
         mCategory = category;
      }
      
      public function setting(id:String) : SettingBuilder
      {
         var _loc2_:SettingBuilder = new SettingBuilder(id,mCategory);
         mBuilders.push(_loc2_);
         return _loc2_;
      }
      
      public function flag(id:String, flagName:String) : SettingBuilder
      {
         return setting(id).defaultsTo(mDBFacade.featureFlags.getFlagDefaultValue(flagName)).boundTo(new FeatureFlagBinding(mDBFacade,flagName));
      }
      
      public function build() : Vector.<SettingDefinition>
      {
         var _loc2_:Vector.<SettingDefinition> = new Vector.<SettingDefinition>();
         for each(var _loc1_:SettingBuilder in mBuilders)
         {
            _loc2_.push(_loc1_.build());
         }
         mBuilders = null;
         mDBFacade = null;
         return _loc2_;
      }
   }
}

