package Brain.Starling.SwfConverter
{
   import flash.display.BitmapData;
   
   public class BakedPicture
   {
      
      public var bitmap:BitmapData;
      
      public var originX:int;
      
      public var originY:int;
      
      public var pixelScale:Number;
      
      public var requestedScale:Number = NaN;
      
      public var empty:Boolean;
      
      public function BakedPicture()
      {
         super();
      }
      
      public function dispose() : void
      {
         if(bitmap != null)
         {
            bitmap.dispose();
         }
         bitmap = null;
      }
   }
}

