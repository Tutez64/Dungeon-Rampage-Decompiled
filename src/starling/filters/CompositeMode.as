package starling.filters
{
   import starling.errors.AbstractClassError;
   
   public class CompositeMode
   {
      
      public static const NORMAL:String = "normal";
      
      public static const INSIDE:String = "inside";
      
      public static const OUTSIDE:String = "outside";
      
      public static const INSIDE_KNOCKOUT:String = "insideKnockout";
      
      public static const OUTSIDE_KNOCKOUT:String = "outsideKnockout";
      
      private static const allModes:Array = ["normal","inside","insideKnockout","outside","outsideKnockout"];
      
      public function CompositeMode()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function getIndex(mode:String) : int
      {
         return allModes.indexOf(mode);
      }
   }
}

