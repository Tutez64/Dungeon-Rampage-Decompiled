package starling.extensions.animate
{
   import starling.errors.AbstractClassError;
   
   internal class LoopMode
   {
      
      public static const LOOP:String = "loop";
      
      public static const PLAY_ONCE:String = "playonce";
      
      public static const SINGLE_FRAME:String = "singleframe";
      
      public function LoopMode()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function isValid(value:String) : Boolean
      {
         return value == "loop" || value == "playonce" || value == "singleframe";
      }
      
      public static function parse(value:String) : String
      {
         switch(value)
         {
            case "LP":
            case "loop":
               break;
            case "PO":
            case "playonce":
               return "playonce";
            case "SF":
            case "singleframe":
               return "singleframe";
            default:
               throw new ArgumentError("Invalid loop mode: " + value);
         }
         return "loop";
      }
   }
}

