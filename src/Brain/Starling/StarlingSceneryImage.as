package Brain.Starling
{
   import starling.display.Image;
   import starling.textures.Texture;
   
   public class StarlingSceneryImage extends Image
   {
      
      private var mChangingVisibility:Boolean = false;
      
      public function StarlingSceneryImage(texture:Texture)
      {
         super(texture);
      }
      
      override public function setRequiresRedraw() : void
      {
         super.setRequiresRedraw();
         var _loc1_:StarlingScenerySprite = parent as StarlingScenerySprite;
         if(_loc1_ != null)
         {
            _loc1_.imageChanged(mChangingVisibility);
         }
      }
      
      override public function set visible(value:Boolean) : void
      {
         mChangingVisibility = true;
         super.visible = value;
         mChangingVisibility = false;
      }
      
      override public function set pixelSnapping(value:Boolean) : void
      {
         if(super.pixelSnapping == value)
         {
            return;
         }
         super.pixelSnapping = value;
         setRequiresRedraw();
      }
   }
}

