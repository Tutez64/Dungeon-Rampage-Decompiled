package Settings.Model
{
   public class SettingCategory
   {
      
      public static const GRAPHICS:String = "graphics";
      
      public static const AUDIO:String = "audio";
      
      public static const CONTROLS:String = "controls";
      
      public static const INTERFACE:String = "interface";
      
      public static const DISPLAY:String = "display";
      
      public static const ADVANCED:String = "advanced";
      
      public static const ORDERED:Vector.<String> = new <String>["graphics","audio","controls","interface","display","advanced"];
      
      public function SettingCategory()
      {
         super();
      }
      
      public static function getLabelKey(category:String) : String
      {
         return "SETTINGS_CATEGORY_" + category.toUpperCase();
      }
      
      public static function indexOf(category:String) : int
      {
         return ORDERED.indexOf(category);
      }
   }
}

