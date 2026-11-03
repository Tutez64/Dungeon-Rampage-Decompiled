package starling.text
{
   import flash.utils.Dictionary;
   import starling.display.Image;
   import starling.textures.Texture;
   
   public class BitmapChar
   {
      
      private var _texture:Texture;
      
      private var _charID:int;
      
      private var _xOffset:Number;
      
      private var _yOffset:Number;
      
      private var _xAdvance:Number;
      
      private var _kernings:Dictionary;
      
      public function BitmapChar(id:int, texture:Texture, xOffset:Number, yOffset:Number, xAdvance:Number)
      {
         super();
         _charID = id;
         _texture = texture;
         _xOffset = xOffset;
         _yOffset = yOffset;
         _xAdvance = xAdvance;
         _kernings = null;
      }
      
      public function addKerning(charID:int, amount:Number) : void
      {
         if(_kernings == null)
         {
            _kernings = new Dictionary();
         }
         _kernings[charID] = amount;
      }
      
      public function getKerning(charID:int) : Number
      {
         if(_kernings == null || _kernings[charID] == undefined)
         {
            return 0;
         }
         return _kernings[charID];
      }
      
      public function createImage() : Image
      {
         return new Image(_texture);
      }
      
      public function get charID() : int
      {
         return _charID;
      }
      
      public function get xOffset() : Number
      {
         return _xOffset;
      }
      
      public function get yOffset() : Number
      {
         return _yOffset;
      }
      
      public function get xAdvance() : Number
      {
         return _xAdvance;
      }
      
      public function get texture() : Texture
      {
         return _texture;
      }
      
      public function get width() : Number
      {
         return _texture ? _texture.width : 0;
      }
      
      public function get height() : Number
      {
         return _texture ? _texture.height : 0;
      }
   }
}

