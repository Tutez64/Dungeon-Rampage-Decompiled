package starling.display
{
   public final class MaskRole
   {
      
      public function MaskRole()
      {
         super();
      }
      
      public static function isMask(object:DisplayObject) : Boolean
      {
         return object.isMask;
      }
   }
}

