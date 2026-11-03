package starling.extensions.animate
{
   import starling.errors.AbstractClassError;
   
   internal class SymbolType
   {
      
      public static const GRAPHIC:String = "graphic";
      
      public static const MOVIE_CLIP:String = "movieclip";
      
      public static const BUTTON:String = "button";
      
      public function SymbolType()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function isValid(value:String) : Boolean
      {
         return value == "graphic" || value == "movieclip" || value == "button";
      }
      
      public static function parse(value:String) : String
      {
         switch(value)
         {
            case "G":
            case "graphic":
               break;
            case "MC":
            case "movieclip":
               return "movieclip";
            case "B":
            case "button":
               return "button";
            default:
               throw new ArgumentError("Invalid symbol type: " + value);
         }
         return "graphic";
      }
   }
}

