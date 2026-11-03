package Brain.AssetRepository
{
   import Brain.Logger.Logger;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   
   public class StarlingPropManifest
   {
      
      public static const FORMAT:String = "dr-prop-manifest/2";
      
      private var mRecipes:Object = {};
      
      private var mScales:Object = {};
      
      public function StarlingPropManifest()
      {
         super();
      }
      
      public function load(manifestFile:File) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         if(manifestFile == null || !manifestFile.exists)
         {
            return;
         }
         var _loc2_:FileStream = new FileStream();
         try
         {
            _loc2_.open(manifestFile,"read");
            _loc3_ = JSON.parse(_loc2_.readUTFBytes(_loc2_.bytesAvailable));
         }
         catch(error:Error)
         {
            Logger.error("StarlingPropManifest.load: could not read " + manifestFile.nativePath + ": " + error.message);
            return;
         }
         finally
         {
            _loc2_.close();
         }
         if(_loc3_ == null || _loc3_.format != "dr-prop-manifest/2")
         {
            Logger.error("StarlingPropManifest.load: refusing " + manifestFile.nativePath + " - expected format \'" + "dr-prop-manifest/2" + "\', got \'" + (_loc3_ != null ? _loc3_.format : null) + "\'");
            return;
         }
         var _loc5_:Number = Number(_loc3_.scale);
         if(_loc5_ <= 0)
         {
            _loc5_ = 1;
         }
         if(manifestFile.parent != null)
         {
            mScales[manifestFile.parent.nativePath] = _loc5_;
         }
         var _loc6_:int = 0;
         for(var _loc7_:String in _loc3_.props)
         {
            _loc4_ = _loc3_.props[_loc7_].parts as Array;
            if(!(_loc4_ == null || _loc4_.length == 0))
            {
               mRecipes[_loc7_] = _loc4_;
               _loc6_++;
            }
         }
         Logger.debugch("Starling","StarlingPropManifest: " + _loc6_ + " prop recipes from " + _loc3_.library + " at " + _loc5_ + "x");
      }
      
      public function clear() : void
      {
         mRecipes = {};
         mScales = {};
      }
      
      public function scaleForFolder(folder:File) : Number
      {
         if(folder == null)
         {
            return 1;
         }
         var _loc2_:Object = mScales[folder.nativePath];
         return _loc2_ == null ? 1 : Number(_loc2_);
      }
      
      public function getParts(assetClassName:String) : Array
      {
         if(assetClassName == null)
         {
            return null;
         }
         return mRecipes[assetClassName] as Array;
      }
   }
}

