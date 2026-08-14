package UI.Map
{
   public class UIMapAvatarDropMover implements UIMapAvatarMover
   {
      
      private var mUpdatePosition:Function;
      
      public function UIMapAvatarDropMover(updatePosition:Function)
      {
         super();
         mUpdatePosition = updatePosition;
      }
      
      public function moveTo(x:Number, y:Number) : void
      {
         mUpdatePosition(x,y);
      }
      
      public function destroy() : void
      {
      }
   }
}

