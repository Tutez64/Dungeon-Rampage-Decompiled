package Brain.AssetRepository
{
   import Brain.Logger.Logger;
   
   public class AssetLoaderInfo
   {
      
      public var dependentAssetPath:String;
      
      public var useCache:Boolean;
      
      public function AssetLoaderInfo(path:String, useCacheIn:Boolean)
      {
         super();
         useCache = useCacheIn;
         dependentAssetPath = path;
         if(dependentAssetPath == null || dependentAssetPath == "" || dependentAssetPath == "null" || dependentAssetPath.indexOf("../../../null") != -1)
         {
            Logger.error("Asset Path is null or empty");
         }
      }
      
      public function getKey() : String
      {
         return dependentAssetPath;
      }
      
      public function getRawAssetPath() : String
      {
         return dependentAssetPath;
      }
   }
}

