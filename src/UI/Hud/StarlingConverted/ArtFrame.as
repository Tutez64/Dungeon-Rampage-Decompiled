package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedCell;
   
   public class ArtFrame
   {
      
      public var children:Vector.<ArtChildState> = new Vector.<ArtChildState>(0);
      
      public var cell:BakedCell;
      
      internal var filterState:int = 0;
      
      public function ArtFrame()
      {
         super();
      }
   }
}

