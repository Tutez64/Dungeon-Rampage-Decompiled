package Settings.Model.Bindings
{
   import Facade.DBFacade;
   
   public class FeatureFlagBinding implements ISettingBinding
   {
      
      private var mDBFacade:DBFacade;
      
      private var mFlagName:String;
      
      public function FeatureFlagBinding(dbFacade:DBFacade, flagName:String)
      {
         super();
         mDBFacade = dbFacade;
         mFlagName = flagName;
      }
      
      public function read() : *
      {
         return mDBFacade.featureFlags.getFlagValue(mFlagName);
      }
      
      public function write(value:*) : void
      {
         mDBFacade.featureFlags.setFlagOverrideValue(mFlagName,value as Boolean);
      }
      
      public function writeInitial(value:*) : void
      {
         mDBFacade.featureFlags.setFlagStoredSettingValue(mFlagName,value as Boolean);
      }
      
      public function clear() : void
      {
         mDBFacade.featureFlags.clearFlagPlayerValues(mFlagName);
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
      }
   }
}

