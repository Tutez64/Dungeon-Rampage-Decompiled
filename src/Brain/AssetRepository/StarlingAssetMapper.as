package Brain.AssetRepository
{
   import flash.filesystem.File;
   
   public class StarlingAssetMapper
   {
      
      public static const SHARED_KEY:String = "shared";
      
      public static const PROPS_ONLY_KEY_PREFIX:String = "props:";
      
      private static const mSharedPropDir:String = "Resources/Art2D/Environments/shared/props/db_prop_shared_library/";
      
      public static const PROP_MANIFEST_FILE:String = "flattened_registration.json";
      
      private static const mBiomeMap:Object = {
         "castle_arena":"Resources/Art2D/Environments/castle/ground_castle_arena/db_grd_castle_arena_library/",
         "castle_catacomb":"Resources/Art2D/Environments/castle/ground_castle_catacomb/db_grd_castle_catacomb_library/",
         "castle_prison":"Resources/Art2D/Environments/castle/ground_castle_prison/db_grd_castle_prison_library/",
         "nordic_caves":"Resources/Art2D/Environments/nordic/ground_nordic_caves/db_grd_nordic_caves_library/",
         "nordic_temple":"Resources/Art2D/Environments/nordic/ground_nordic_temple/db_grd_nordic_temple_library/",
         "nordic_village":"Resources/Art2D/Environments/nordic/ground_nordic_village/db_grd_nordic_village_library/",
         "jurassic_aztec":"Resources/Art2D/Environments/jurassic/ground_jurassic_aztec/db_grd_jurassic_aztec_library/",
         "jurassic_dino":"Resources/Art2D/Environments/jurassic/ground_jurassic_dino/db_grd_jurassic_dino_library/",
         "jurassic_tribal":"Resources/Art2D/Environments/jurassic/ground_jurassic_tribal/db_grd_jurassic_tribal_library/"
      };
      
      private static const mPropMap:Object = {
         "castle_arena":"Resources/Art2D/Environments/castle/prop_castle_arena/db_prop_castle_arena_library/",
         "castle_catacomb":"Resources/Art2D/Environments/castle/prop_castle_catacomb/db_prop_castle_catacomb_library/",
         "castle_prison":"Resources/Art2D/Environments/castle/prop_castle_prison/db_prop_castle_prison_library/",
         "jurassic_aztec":"Resources/Art2D/Environments/jurassic/prop_jurassic_aztec/db_prop_jurassic_aztec_library/",
         "jurassic_dino":"Resources/Art2D/Environments/jurassic/prop_jurassic_dino/db_prop_jurassic_dino_library/",
         "jurassic_tribal":"Resources/Art2D/Environments/jurassic/prop_jurassic_tribal/db_prop_jurassic_tribal_library/",
         "nordic_caves":"Resources/Art2D/Environments/nordic/prop_nordic_caves/db_prop_nordic_caves_library/",
         "nordic_temple":"Resources/Art2D/Environments/nordic/prop_nordic_temple/db_prop_nordic_temple_library/",
         "nordic_village":"Resources/Art2D/Environments/nordic/prop_nordic_village/db_prop_nordic_village_library/"
      };
      
      private static const mActorAtlasFilePathCache:Object = {};
      
      private static const mPropAtlasFolders:Object = {};
      
      public function StarlingAssetMapper()
      {
         super();
      }
      
      public static function getBiomeKeyFromPath(inPath:String) : String
      {
         var _loc4_:int = inPath.lastIndexOf("/");
         var _loc2_:int = inPath.lastIndexOf("_");
         var _loc3_:String = inPath.substring(_loc4_ + 1,_loc2_);
         var _loc5_:int = _loc3_.indexOf("_",_loc3_.indexOf("_") + 1);
         return _loc3_.substring(_loc5_ + 1);
      }
      
      public static function isPropLibraryPath(inPath:String) : Boolean
      {
         if(inPath == null || inPath.substring(inPath.lastIndexOf("/") + 1).indexOf("db_prop_") != 0)
         {
            return false;
         }
         var _loc2_:String = getBiomeKeyFromPath(inPath);
         return _loc2_ == "shared" || mPropMap.hasOwnProperty(_loc2_);
      }
      
      public static function getPropLibraryKey(libraryPath:String, floorBiomeKey:String) : String
      {
         var _loc3_:String = getBiomeKeyFromPath(libraryPath);
         if(floorBiomeKey == null || _loc3_ == floorBiomeKey || _loc3_ == "shared" || !isPropLibraryPath(libraryPath))
         {
            return _loc3_;
         }
         return getPropsOnlyKey(_loc3_);
      }
      
      public static function getPropsOnlyKey(biomeKey:String) : String
      {
         return "props:" + biomeKey;
      }
      
      private static function getPropsOnlyBiome(key:String) : String
      {
         return key.indexOf("props:") == 0 ? key.substring("props:".length) : null;
      }
      
      public static function isKnownBiome(biomeKey:String) : Boolean
      {
         var _loc2_:String = getPropsOnlyBiome(biomeKey);
         if(_loc2_ != null)
         {
            return mPropMap.hasOwnProperty(_loc2_);
         }
         return mBiomeMap.hasOwnProperty(biomeKey) || mPropMap.hasOwnProperty(biomeKey) || biomeKey == "shared";
      }
      
      public static function getAssetFilesForBiome(biomeKey:String, includeShared:Boolean) : Array
      {
         var _loc4_:Array = [];
         var _loc3_:String = getPropsOnlyBiome(biomeKey);
         if(_loc3_ != null)
         {
            _loc4_.push(AssetLoader.resolveFile(mPropMap[_loc3_]));
            return _loc4_;
         }
         if(mBiomeMap.hasOwnProperty(biomeKey))
         {
            _loc4_.push(AssetLoader.resolveFile(mBiomeMap[biomeKey]));
         }
         if(mPropMap.hasOwnProperty(biomeKey))
         {
            _loc4_.push(AssetLoader.resolveFile(mPropMap[biomeKey]));
         }
         if(includeShared || biomeKey == "shared")
         {
            _loc4_.push(AssetLoader.resolveFile("Resources/Art2D/Environments/shared/props/db_prop_shared_library/"));
         }
         return _loc4_;
      }
      
      public static function getActorAtlasKeyFromPath(assetClassPath:String) : String
      {
         if(assetClassPath == null || !assetClassPath.match(/\.swf$/i))
         {
            return null;
         }
         var _loc2_:int = assetClassPath.lastIndexOf("/") + 1;
         var _loc3_:int = assetClassPath.lastIndexOf(".");
         return assetClassPath.substring(_loc2_,_loc3_);
      }
      
      public static function isArt3DPath(path:String) : Boolean
      {
         return path != null && path.search(/(^|[\/\\])Art3D[\/\\]/i) != -1;
      }
      
      public static function isEnvironmentArtPath(path:String) : Boolean
      {
         return path != null && path.search(/(^|[\/\\])Art2D[\/\\]Environments[\/\\]/i) != -1;
      }
      
      public static function getActorAtlasFile(assetClassPath:String, allowMultiClipFolder:Boolean = false) : File
      {
         var _loc5_:Array = null;
         var _loc8_:String = getActorAtlasKeyFromPath(assetClassPath);
         if(_loc8_ == null)
         {
            return null;
         }
         var _loc7_:String = assetClassPath + "|" + allowMultiClipFolder;
         if(mActorAtlasFilePathCache.hasOwnProperty(_loc7_))
         {
            return mActorAtlasFilePathCache[_loc7_];
         }
         var _loc3_:String = assetClassPath.substring(0,assetClassPath.lastIndexOf("."));
         var _loc6_:File = AssetLoader.resolveFile(_loc3_);
         if(_loc6_.exists && Boolean(_loc6_.isDirectory))
         {
            if(_loc6_.resolvePath("Animation.json").exists)
            {
               mActorAtlasFilePathCache[_loc7_] = _loc6_;
               return _loc6_;
            }
            if(allowMultiClipFolder && !isMappedLibraryFolder(_loc6_))
            {
               _loc5_ = _loc6_.getDirectoryListing();
               for each(var _loc4_:File in _loc5_)
               {
                  if(_loc4_.isDirectory && Boolean(_loc4_.resolvePath("Animation.json").exists))
                  {
                     mActorAtlasFilePathCache[_loc7_] = _loc6_;
                     return _loc6_;
                  }
               }
            }
         }
         mActorAtlasFilePathCache[_loc7_] = null;
         return null;
      }
      
      public static function getPropAtlasFile(libraryKey:String, assetClassName:String) : File
      {
         var _loc6_:String = null;
         var _loc3_:File = null;
         var _loc5_:Boolean = false;
         if(assetClassName == null || assetClassName == "")
         {
            return null;
         }
         var _loc4_:String = libraryKey + "/" + assetClassName;
         if(!mPropAtlasFolders.hasOwnProperty(_loc4_))
         {
            _loc6_ = libraryKey == "shared" ? "Resources/Art2D/Environments/shared/props/db_prop_shared_library/" : mPropMap[libraryKey];
            _loc3_ = _loc6_ != null ? AssetLoader.resolveFile(_loc6_ + assetClassName) : null;
            _loc5_ = _loc3_ != null && Boolean(_loc3_.exists) && Boolean(_loc3_.isDirectory) && Boolean(_loc3_.resolvePath("Animation.json").exists);
            mPropAtlasFolders[_loc4_] = _loc5_ ? _loc3_ : false;
         }
         return mPropAtlasFolders[_loc4_] as File;
      }
      
      private static function isMappedLibraryFolder(folder:File) : Boolean
      {
         var _loc2_:String = folder.url.replace(/\/$/,"");
         for each(var _loc3_:String in mBiomeMap)
         {
            if(AssetLoader.resolveFile(_loc3_).url.replace(/\/$/,"") == _loc2_)
            {
               return true;
            }
         }
         for each(var _loc4_:String in mPropMap)
         {
            if(AssetLoader.resolveFile(_loc4_).url.replace(/\/$/,"") == _loc2_)
            {
               return true;
            }
         }
         return AssetLoader.resolveFile("Resources/Art2D/Environments/shared/props/db_prop_shared_library/").url.replace(/\/$/,"") == _loc2_;
      }
      
      public static function getPropManifestFilesForBiome(biomeKey:String, includeShared:Boolean) : Array
      {
         var _loc5_:Array = [];
         var _loc4_:String = getPropsOnlyBiome(biomeKey);
         var _loc3_:String = _loc4_ != null ? _loc4_ : biomeKey;
         if(mPropMap.hasOwnProperty(_loc3_))
         {
            _loc5_.push(AssetLoader.resolveFile(mPropMap[_loc3_] + "flattened_registration.json"));
         }
         if(includeShared || biomeKey == "shared")
         {
            _loc5_.push(AssetLoader.resolveFile("Resources/Art2D/Environments/shared/props/db_prop_shared_library/" + "flattened_registration.json"));
         }
         return _loc5_;
      }
   }
}

