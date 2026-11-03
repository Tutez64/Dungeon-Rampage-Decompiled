package Settings.Model
{
   public class SettingChoice
   {
      
      public var value:*;
      
      public var labelKey:String;
      
      public var memberValues:Object;
      
      public var derived:Boolean;
      
      public function SettingChoice(value:*, labelKey:String, memberValues:Object = null, derived:Boolean = false)
      {
         super();
         this.value = value;
         this.labelKey = labelKey;
         this.memberValues = memberValues;
         this.derived = derived;
      }
   }
}

