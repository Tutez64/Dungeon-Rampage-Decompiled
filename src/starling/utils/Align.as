package starling.utils
{
   import starling.errors.AbstractClassError;
   
   public final class Align
   {
      
      public static const LEFT:String = "left";
      
      public static const RIGHT:String = "right";
      
      public static const TOP:String = "top";
      
      public static const BOTTOM:String = "bottom";
      
      public static const CENTER:String = "center";
      
      public function Align()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function isValid(align:String) : Boolean
      {
         return align == "left" || align == "right" || align == "center" || align == "top" || align == "bottom";
      }
      
      public static function isValidHorizontal(align:String) : Boolean
      {
         return align == "left" || align == "center" || align == "right";
      }
      
      public static function isValidVertical(align:String) : Boolean
      {
         return align == "top" || align == "center" || align == "bottom";
      }
   }
}

