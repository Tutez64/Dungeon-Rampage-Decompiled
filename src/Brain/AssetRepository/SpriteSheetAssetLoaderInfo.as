package Brain.AssetRepository
{
   import org.as3commons.collections.Map;
   
   public class SpriteSheetAssetLoaderInfo extends AssetLoaderInfo
   {
      
      private static var mLoadedJson:Map = new Map();
      
      public var bitmapDataName:String;
      
      public function SpriteSheetAssetLoaderInfo(swfPath:String, bitmapDataName:String, shClassName:String, useCache:Boolean)
      {
         super(swfPath,useCache);
         this.bitmapDataName = bitmapDataName;
      }
      
      override public function getKey() : String
      {
         return getRawAssetPath() + "_" + bitmapDataName;
      }
   }
}

