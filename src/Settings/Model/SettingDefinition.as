package Settings.Model
{
   import Settings.Model.Bindings.ISettingBinding;
   
   public class SettingDefinition
   {
      
      public var id:String;
      
      public var category:String;
      
      public var labelKey:String;
      
      public var descriptionKey:String;
      
      public var labelText:String;
      
      public var descriptionText:String;
      
      public var defaultValue:*;
      
      public var binding:ISettingBinding;
      
      public var requiresRestart:Boolean;
      
      public var minimum:Number;
      
      public var maximum:Number;
      
      public var step:Number;
      
      public var decimals:int;
      
      public var displayScale:Number = 1;
      
      public var choices:Vector.<SettingChoice>;
      
      public var coerceValue:Function;
      
      public var descriptionKeyProvider:Function;
      
      public var keyBindingAction:String;
      
      public function SettingDefinition(id:String, category:String, labelKey:String, descriptionKey:String, defaultValue:*, binding:ISettingBinding, requiresRestart:Boolean = false)
      {
         super();
         this.id = id;
         this.category = category;
         this.labelKey = labelKey;
         this.descriptionKey = descriptionKey;
         this.defaultValue = defaultValue;
         this.binding = binding;
         this.requiresRestart = requiresRestart;
      }
      
      public static function labelKeyFor(id:String) : String
      {
         return "SETTING_" + toConstantCase(id);
      }
      
      public static function descriptionKeyFor(id:String) : String
      {
         return "SETTING_" + toConstantCase(id) + "_DESC";
      }
      
      public static function choiceLabelKeyFor(id:String, value:*) : String
      {
         return labelKeyFor(id) + "_" + toConstantCase(String(value));
      }
      
      private static function toConstantCase(camelCase:String) : String
      {
         var _loc6_:int = 0;
         var _loc4_:String = null;
         var _loc3_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc2_:String = "";
         var _loc7_:Boolean = false;
         _loc6_ = 0;
         while(_loc6_ < camelCase.length)
         {
            _loc4_ = camelCase.charAt(_loc6_);
            _loc3_ = _loc4_ == _loc4_.toUpperCase() && _loc4_ != _loc4_.toLowerCase();
            _loc5_ = _loc4_ >= "0" && _loc4_ <= "9";
            if(_loc6_ > 0 && (_loc3_ || _loc5_ && !_loc7_))
            {
               _loc2_ += "_";
            }
            _loc2_ += _loc4_.toUpperCase();
            _loc7_ = _loc5_;
            _loc6_++;
         }
         return _loc2_;
      }
      
      public function get isChoice() : Boolean
      {
         return choices != null;
      }
      
      public function get isSlider() : Boolean
      {
         return !isChoice && !isKeyBinding && !isNaN(minimum);
      }
      
      public function get isKeyBinding() : Boolean
      {
         return keyBindingAction != null;
      }
      
      public function get isBoolean() : Boolean
      {
         return !isChoice && !isSlider && !isKeyBinding;
      }
      
      public function get isPersisted() : Boolean
      {
         return binding != null;
      }
      
      public function get isPreset() : Boolean
      {
         if(choices == null)
         {
            return false;
         }
         for each(var _loc1_:SettingChoice in choices)
         {
            if(_loc1_.memberValues != null)
            {
               return true;
            }
         }
         return false;
      }
      
      public function findChoice(value:*) : SettingChoice
      {
         if(choices == null)
         {
            return null;
         }
         for each(var _loc2_:SettingChoice in choices)
         {
            if(_loc2_.value == value)
            {
               return _loc2_;
            }
         }
         return null;
      }
   }
}

