package starling.text
{
   import starling.errors.AbstractClassError;
   
   public class BitmapFontType
   {
      
      public static const STANDARD:String = "standard";
      
      public static const DISTANCE_FIELD:String = "distanceField";
      
      public static const MULTI_CHANNEL_DISTANCE_FIELD:String = "multiChannelDistanceField";
      
      public function BitmapFontType()
      {
         super();
         throw new AbstractClassError();
      }
   }
}

