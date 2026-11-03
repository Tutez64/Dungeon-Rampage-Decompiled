package Starling
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.StarlingAssetMapper;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   
   public class SwfFallbackDebug
   {
      
      public static const CATEGORY_TILE:String = "TILE";
      
      public static const CATEGORY_PROP:String = "PROP";
      
      public static const CATEGORY_EFFECT:String = "EFFECT";
      
      public static const CATEGORY_BUFF:String = "BUFF";
      
      public static const CATEGORY_PROJECTILE:String = "PROJECTILE";
      
      public static const CATEGORY_DOOBER:String = "DOOBER";
      
      public static const OUTLINE_COLOR:uint = 16711897;
      
      private static const BITMAP_BORDER:int = 3;
      
      private static const OUTLINE:GlowFilter = new GlowFilter(16711897,1,16,16,5);
      
      private static const SOUND_ONLY_SWF:RegExp = /(^|[\/\\])soundEffects\.swf$/i;
      
      private static var sReported:Object = {};
      
      public function SwfFallbackDebug()
      {
         super();
      }
      
      public static function isEnabled(facade:DBFacade, category:String = null) : Boolean
      {
         if(facade == null || facade.featureFlags == null)
         {
            return false;
         }
         if(facade.featureFlags.getFlagValue("debug-outline-swf-fallback"))
         {
            return true;
         }
         return isLegacyOutlineCategory(category) && facade.featureFlags.getFlagValue("debug-outline-swf-fallback-props");
      }
      
      private static function isLegacyOutlineCategory(category:String) : Boolean
      {
         return category == "PROP" || category != null && (category.indexOf("ACTOR") == 0 || category.indexOf("WEAPON") == 0);
      }
      
      public static function applyOutline(facade:DBFacade, node:DisplayObject, category:String = null) : void
      {
         if(node == null || !isEnabled(facade,category))
         {
            return;
         }
         var _loc4_:Array = node.filters || [];
         if(findOutline(_loc4_) < 0)
         {
            _loc4_.push(OUTLINE);
            node.filters = _loc4_;
         }
      }
      
      public static function removeOutline(node:DisplayObject) : void
      {
         if(node == null)
         {
            return;
         }
         var _loc2_:Array = node.filters;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = findOutline(_loc2_);
         if(_loc3_ >= 0)
         {
            _loc2_.splice(_loc3_,1);
            node.filters = _loc2_;
         }
      }
      
      private static function findOutline(filters:Array) : int
      {
         var _loc2_:int = 0;
         var _loc3_:GlowFilter = null;
         _loc2_ = 0;
         while(_loc2_ < filters.length)
         {
            _loc3_ = filters[_loc2_] as GlowFilter;
            if(_loc3_ != null && _loc3_.color == 16711897 && _loc3_.blurX == OUTLINE.blurX && _loc3_.blurY == OUTLINE.blurY)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public static function markFallbackBitmap(facade:DBFacade, bmd:BitmapData, category:String = null) : void
      {
         if(bmd == null || !isEnabled(facade,category))
         {
            return;
         }
         var _loc5_:Number = bmd.width;
         var _loc6_:Number = bmd.height;
         var _loc4_:int = Math.min(3,Math.min(_loc5_,_loc6_) / 2);
         bmd.fillRect(new Rectangle(0,0,_loc5_,_loc4_),0xFFFF0000 | 0xFF00D9);
         bmd.fillRect(new Rectangle(0,_loc6_ - _loc4_,_loc5_,_loc4_),0xFFFF0000 | 0xFF00D9);
         bmd.fillRect(new Rectangle(0,0,_loc4_,_loc6_),0xFFFF0000 | 0xFF00D9);
         bmd.fillRect(new Rectangle(_loc5_ - _loc4_,0,_loc4_,_loc6_),0xFFFF0000 | 0xFF00D9);
      }
      
      public static function report(facade:DBFacade, category:String, assetName:String, swfPath:String, reason:String, asError:Boolean = false) : void
      {
         if(swfPath != null && SOUND_ONLY_SWF.test(swfPath))
         {
            return;
         }
         var _loc8_:String = category + "|" + assetName + "|" + swfPath + "|" + reason;
         if(sReported[_loc8_])
         {
            return;
         }
         sReported[_loc8_] = true;
         var _loc7_:String = "SWF fallback [" + category + "] " + assetName + " (" + reason + ") path=" + swfPath + describeContext(facade,swfPath);
         if(asError)
         {
            try
            {
               Logger.error(_loc7_);
            }
            catch(e:Error)
            {
            }
         }
         else
         {
            Logger.warnch("SwfFallback",_loc7_);
         }
      }
      
      private static function describeContext(facade:DBFacade, swfPath:String) : String
      {
         var _loc3_:AssetLoadingComponent = facade != null ? facade.assetLoadingComponent : null;
         var _loc4_:String = null;
         try
         {
            _loc4_ = swfPath != null ? StarlingAssetMapper.getBiomeKeyFromPath(swfPath) : null;
         }
         catch(e:Error)
         {
            _loc4_ = "<unmapped>";
         }
         return " [context: starlingReady=" + (_loc3_ != null && _loc3_.isStarlingReady) + " loadPending=" + (_loc3_ != null && _loc3_.isStarlingLoadPending) + " floorBiome=" + (_loc3_ != null ? _loc3_.currentFloorBiome : null) + " purgeCount=" + (_loc3_ != null ? _loc3_.starlingPurgeCount : -1) + " pathBiome=" + _loc4_ + "]";
      }
   }
}

