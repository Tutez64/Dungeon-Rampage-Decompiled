package starling.assets
{
   import flash.media.Sound;
   import flash.utils.ByteArray;
   import starling.errors.AbstractClassError;
   import starling.text.BitmapFont;
   import starling.textures.Texture;
   import starling.textures.TextureAtlas;
   
   public class AssetType
   {
      
      public static const TEXTURE:String = "texture";
      
      public static const TEXTURE_ATLAS:String = "textureAtlas";
      
      public static const SOUND:String = "sound";
      
      public static const XML_DOCUMENT:String = "xml";
      
      public static const OBJECT:String = "object";
      
      public static const BYTE_ARRAY:String = "byteArray";
      
      public static const BITMAP_FONT:String = "bitmapFont";
      
      public static const ASSET_MANAGER:String = "assetManager";
      
      public function AssetType()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function fromAsset(asset:Object) : String
      {
         if(asset is Texture)
         {
            return "texture";
         }
         if(asset is TextureAtlas)
         {
            return "textureAtlas";
         }
         if(asset is Sound)
         {
            return "sound";
         }
         if(asset is XML)
         {
            return "xml";
         }
         if(asset is ByteArray)
         {
            return "byteArray";
         }
         if(asset is BitmapFont)
         {
            return "bitmapFont";
         }
         if(asset is AssetManager)
         {
            return "assetManager";
         }
         return "object";
      }
   }
}

