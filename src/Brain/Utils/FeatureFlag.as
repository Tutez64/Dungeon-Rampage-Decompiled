package Brain.Utils
{
   public class FeatureFlag
   {
      
      private static const UNSET_ENUM:uint = 0;
      
      private static const FALSE_ENUM:uint = 1;
      
      private static const TRUE_ENUM:uint = 2;
      
      public var name:String;
      
      public var defaultValue:Boolean;
      
      private var _currentValue:Boolean;
      
      private var _commandLineFlag:String;
      
      private var _configFileAttributeName:String;
      
      private var configFileValue:uint;
      
      private var dbValue:uint;
      
      private var cliValue:uint;
      
      private var overrideValue:uint;
      
      public function FeatureFlag(name:String, defaultValue:Boolean, commandLineFlag:String, configFileAttributeName:String)
      {
         super();
         this.name = name;
         this._currentValue = defaultValue;
         this.defaultValue = defaultValue;
         if(commandLineFlag)
         {
            this._commandLineFlag = commandLineFlag;
         }
         else
         {
            this._commandLineFlag = "--" + name;
         }
         if(_commandLineFlag.indexOf("--") != 0)
         {
            throw new ArgumentError("FeatureFlag commandLineFlag must start with --");
         }
         if(_commandLineFlag.indexOf(" ") != -1)
         {
            throw new ArgumentError("FeatureFlag commandLineFlag must not contain spaces");
         }
         if(configFileAttributeName)
         {
            this._configFileAttributeName = configFileAttributeName;
         }
         else
         {
            this._configFileAttributeName = name;
         }
         if(_configFileAttributeName.indexOf(" ") != -1)
         {
            throw new ArgumentError("ConfigFileAttributeName  must not contain spaces");
         }
         this.configFileValue = 0;
         this.dbValue = 0;
         this.cliValue = 0;
         this.overrideValue = 0;
      }
      
      public static function featureFlagFactory(name:String, defaultValue:Boolean, commandLineFlag:String = null, configFileAttributeName:String = null) : FeatureFlag
      {
         return new FeatureFlag(name,defaultValue,commandLineFlag,configFileAttributeName);
      }
      
      public function setConfigFileValue(value:Boolean) : void
      {
         this.configFileValue = value ? 2 : 1;
         this.updateCurrentValue();
      }
      
      public function setDbValue(value:Boolean) : void
      {
         this.dbValue = value ? 2 : 1;
         this.updateCurrentValue();
      }
      
      public function setCliValue(value:Boolean) : void
      {
         this.cliValue = value ? 2 : 1;
         this.updateCurrentValue();
      }
      
      public function setOverrideValue(value:Boolean) : void
      {
         this.overrideValue = value ? 2 : 1;
         this.updateCurrentValue();
      }
      
      public function updateCurrentValue() : void
      {
         if(this.overrideValue != 0)
         {
            this._currentValue = this.overrideValue == 2;
            return;
         }
         if(this.cliValue != 0)
         {
            this._currentValue = this.cliValue == 2;
            return;
         }
         if(this.dbValue != 0)
         {
            this._currentValue = this.dbValue == 2;
            return;
         }
         if(this.configFileValue != 0)
         {
            this._currentValue = this.configFileValue == 2;
            return;
         }
      }
      
      public function get currentValue() : Boolean
      {
         return _currentValue;
      }
      
      public function get commandLineFlag() : String
      {
         return _commandLineFlag;
      }
      
      public function get configFileAttributeName() : String
      {
         return _configFileAttributeName;
      }
   }
}

