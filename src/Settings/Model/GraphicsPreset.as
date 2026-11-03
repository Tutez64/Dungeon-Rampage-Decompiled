package Settings.Model
{
   public class GraphicsPreset
   {
      
      public static const PERFORMANCE:String = "performance";
      
      public static const QUALITY:String = "quality";
      
      public static const CUSTOM:String = "custom";
      
      public static const MEMBERS:Vector.<String> = new <String>["zoom","rarityBackgrounds","damageFloaters","busterBackgroundFade"];
      
      public function GraphicsPreset()
      {
         super();
      }
      
      public static function membersAt(value:Boolean) : Object
      {
         var _loc2_:Object = {};
         for each(var _loc3_:String in MEMBERS)
         {
            _loc2_[_loc3_] = value;
         }
         return _loc2_;
      }
   }
}

