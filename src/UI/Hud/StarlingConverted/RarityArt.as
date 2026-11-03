package UI.Hud.StarlingConverted
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Starling.SwfConverter.BakedPages;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   
   internal class RarityArt
   {
      
      internal static const DISPLAY_SCALE:Number = 0.85;
      
      private static var sRows:Vector.<Object>;
      
      private static var sLoading:int;
      
      private static var sLoaded:Function;
      
      private static var sDone:Function;
      
      private static var sPages:BakedPages;
      
      private static var sFrames:BakedPages;
      
      private static var sConverter:HudArtConverter;
      
      private static var sModel:MovieClip;
      
      private static var sIndex:int;
      
      private static var sFailures:int;
      
      private static const SLOT_PATHS:Vector.<String> = new <String>["UI_weapons.weapon_z","UI_weapons.weapon_x","UI_weapons.weapon_c"];
      
      private static var sLibraries:Object = {};
      
      private static var sDefinitions:Vector.<Object> = new Vector.<Object>(0);
      
      public function RarityArt()
      {
         super();
      }
      
      internal static function get busy() : Boolean
      {
         return sDone != null;
      }
      
      internal static function get failures() : int
      {
         return sFailures;
      }
      
      internal static function key(swf:String, name:String, artSetScale:Number) : String
      {
         return swf + "|" + name + "|" + BakedPages.scaleKey(artSetScale);
      }
      
      internal static function verifySlots(layout:ArtNode, facade:DBFacade) : void
      {
         var _loc3_:String = null;
         var _loc6_:Object = null;
         var _loc5_:String = null;
         var _loc4_:ArtNode = null;
         for each(_loc3_ in SLOT_PATHS)
         {
            if(layout == null || layout.find(_loc3_) == null)
            {
               HudArt.fatal("Required HUD rarity slot missing: " + _loc3_);
            }
            for each(_loc6_ in facade.gameMaster.Rarity)
            {
               if(!(_loc6_ == null || !_loc6_.HasColoredBackground))
               {
                  _loc5_ = StarlingHudSlot.rarityKey(layout,_loc6_.BackgroundSwf,_loc6_.BackgroundIcon);
                  _loc4_ = HudArt.artSetContent(layout,_loc5_);
                  if(_loc4_ == null || _loc4_.failures > 0 || !hasPixels(_loc4_))
                  {
                     HudArt.fatal("Required HUD rarity art missing: " + _loc5_ + " at " + _loc3_);
                  }
               }
            }
         }
      }
      
      internal static function load(facade:DBFacade, assets:AssetLoadingComponent, done:Function) : void
      {
         var _loc8_:Object = null;
         var _loc7_:String = null;
         var _loc4_:String = null;
         sLoaded = done;
         var _loc6_:Object = {};
         for each(_loc8_ in facade.gameMaster.Rarity)
         {
            if(_loc8_.HasColoredBackground)
            {
               _loc4_ = _loc8_.BackgroundSwf;
               _loc7_ = _loc4_ + "|" + _loc8_.BackgroundIcon;
               if(_loc4_ == null || _loc4_.length == 0 || _loc8_.BackgroundIcon == null || _loc8_.BackgroundIcon.length == 0)
               {
                  HudArt.fatal("Missing required HUD rarity background definition",true);
                  return;
               }
               if(!_loc6_[_loc7_])
               {
                  _loc6_[_loc7_] = true;
                  sDefinitions.push({
                     "swf":_loc4_,
                     "name":_loc8_.BackgroundIcon
                  });
                  sLibraries[_loc4_] = null;
               }
            }
         }
         var _loc5_:Vector.<String> = new Vector.<String>(0);
         for(_loc4_ in sLibraries)
         {
            _loc5_.push(_loc4_);
         }
         sLoading = _loc5_.length;
         for each(_loc4_ in _loc5_)
         {
            loadLibrary(assets,_loc4_);
         }
         if(_loc5_.length == 0)
         {
            loaded();
         }
      }
      
      private static function loadLibrary(assets:AssetLoadingComponent, path:String) : void
      {
         HudArt.loadStartupSwf(assets,path,function(param1:SwfAsset):void
         {
            TimelineMasks.register(param1);
            sLibraries[path] = param1;
            loaded();
         });
      }
      
      private static function loaded() : void
      {
         var _loc1_:Object = null;
         if(--sLoading > 0)
         {
            return;
         }
         for each(_loc1_ in sDefinitions)
         {
            _loc1_.symbol = HudArt.requireClass(sLibraries[_loc1_.swf],_loc1_.swf,_loc1_.name);
         }
         var _loc2_:Function = sLoaded;
         sLoaded = null;
         if(_loc2_ != null)
         {
            _loc2_();
         }
      }
      
      internal static function bake(pages:BakedPages, frames:BakedPages, scale:Number, art:Object, done:Function) : void
      {
         try
         {
            bakeSafely(pages,frames,scale,art,done);
         }
         catch(error:*)
         {
            failed(error);
         }
      }
      
      private static function bakeSafely(pages:BakedPages, frames:BakedPages, scale:Number, art:Object, done:Function) : void
      {
         var _loc11_:Object = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:ArtNode = null;
         var _loc9_:String = null;
         sPages = pages;
         sFrames = frames;
         sDone = done;
         sRows = new Vector.<Object>(0);
         sIndex = 0;
         sFailures = 0;
         var _loc10_:Number = scale;
         var _loc12_:Object = {};
         for each(_loc6_ in new <String>["ui_hud_old","ui_hud"])
         {
            _loc8_ = art[_loc6_] as ArtNode;
            if(_loc8_ != null)
            {
               for each(_loc7_ in SLOT_PATHS)
               {
                  if(_loc8_.find(_loc7_) == null)
                  {
                     throw new Error("Required HUD rarity slot missing: " + _loc6_ + "." + _loc7_);
                  }
                  for each(_loc11_ in sDefinitions)
                  {
                     _loc9_ = key(_loc11_.swf,_loc11_.name,scale);
                     if(!(_loc12_[_loc9_] || art["content|" + _loc9_] != null))
                     {
                        _loc12_[_loc9_] = true;
                        sRows.push({
                           "key":_loc9_,
                           "symbol":_loc11_.symbol,
                           "scale":_loc10_
                        });
                     }
                  }
               }
            }
         }
         next();
      }
      
      private static function next() : void
      {
         try
         {
            nextSafely();
         }
         catch(error:*)
         {
            failed(error);
         }
      }
      
      private static function nextSafely() : void
      {
         var _loc3_:Function = null;
         if(HudArt.fatalFailure)
         {
            return;
         }
         if(sIndex == sRows.length)
         {
            _loc3_ = sDone;
            sDone = null;
            if(_loc3_ != null)
            {
               _loc3_();
            }
            return;
         }
         var _loc2_:Object = sRows[sIndex];
         var _loc1_:Class = _loc2_.symbol;
         sModel = new _loc1_() as MovieClip;
         if(sModel == null)
         {
            throw new Error("Required HUD rarity is not a MovieClip: " + _loc2_.key);
         }
         sConverter = HudArtConverter.convertAsync(sModel,sPages,_loc2_.scale,{
            "hudScale":HudArt.bakePixelScale(sPages),
            "kind":timeline,
            "stageRate":true,
            "clipMasks":true,
            "stillChildren":true,
            "framePages":sFrames
         },complete,8);
      }
      
      private static function timeline(path:String) : String
      {
         return path.length == 0 ? "timeline" : null;
      }
      
      private static function complete(art:ArtNode) : void
      {
         try
         {
            completeSafely(art);
         }
         catch(error:*)
         {
            failed(error);
         }
      }
      
      private static function completeSafely(art:ArtNode) : void
      {
         HudArtConverter.stopTree(sModel);
         var _loc2_:Object = sRows[sIndex];
         if(art == null || art.failures > 0 || !hasPixels(art))
         {
            if(art != null)
            {
               art.release(sPages);
            }
            if(!HudArt.ready)
            {
               HudArt.fatal("Required HUD rarity bake failed: " + _loc2_.key);
            }
            StarlingHud.reportError(new Error("HUD rarity rebake refused: " + _loc2_.key));
            sFailures = sFailures + 1;
            sConverter = null;
            sModel = null;
            sIndex = sIndex + 1;
            next();
            return;
         }
         art.pinStartupTree();
         HudArt.storeContent(_loc2_.key,art,sPages);
         sConverter = null;
         sModel = null;
         sIndex = sIndex + 1;
         next();
      }
      
      private static function failed(error:*) : void
      {
         var _loc3_:String = sRows != null && sIndex < sRows.length ? sRows[sIndex].key : "preparation";
         var _loc2_:Function = sDone;
         cancel();
         sFailures = sFailures + 1;
         HudArt.fail("HUD rarity conversion: " + _loc3_ + " " + String(error),error as Error);
         if(_loc2_ != null)
         {
            _loc2_();
         }
      }
      
      internal static function request(layout:ArtNode, key:String) : ArtNode
      {
         var _loc3_:ArtNode = HudArt.artSetContent(layout,key);
         if(_loc3_ == null)
         {
            HudArt.fatal("Required HUD rarity art missing: " + key);
         }
         return _loc3_;
      }
      
      internal static function cancel() : void
      {
         if(sConverter != null)
         {
            sConverter.cancel();
         }
         sConverter = null;
         sModel = null;
         sDone = null;
         sRows = null;
      }
      
      private static function hasPixels(art:ArtNode) : Boolean
      {
         var _loc2_:ArtNode = null;
         var _loc3_:ArtFrame = null;
         if(art.cell != null && !art.cell.isEmpty)
         {
            return true;
         }
         for each(_loc3_ in art.frames)
         {
            if(_loc3_ != null && _loc3_.cell != null && !_loc3_.cell.isEmpty)
            {
               return true;
            }
         }
         for each(_loc2_ in art.children)
         {
            if(hasPixels(_loc2_))
            {
               return true;
            }
         }
         return false;
      }
   }
}

