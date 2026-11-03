package starling.filters
{
   import flash.geom.Rectangle;
   import starling.display.DisplayObject;
   import starling.textures.Texture;
   
   public interface IFilterHelper
   {
      
      function getTexture(resolution:Number = 1) : Texture;
      
      function putTexture(texture:Texture) : void;
      
      function get targetBounds() : Rectangle;
      
      function get target() : DisplayObject;
   }
}

