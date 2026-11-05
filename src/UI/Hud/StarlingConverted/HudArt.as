package UI.Hud.StarlingConverted
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Starling.SwfConverter.BakeBudget;
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedPages;
   import Brain.Starling.SwfConverter.BakedPicture;
   import Facade.DBFacade;
   import Settings.Model.LocalSettingsFile;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.system.Capabilities;
   import flash.text.TextField;
   import flash.utils.getTimer;
   import starling.core.Starling;
   
   public class HudArt
   {
      
      private static const HUD_PATH:String = "Resources/Art2D/UI/db_UI_HUD.swf";
      
      private static const TOWN_PATH:String = "Resources/Art2D/UI/db_UI_town.swf";
      
      private static const NAMETAG_PATH:String = "Resources/Art2D/UI/db_UI_nametag.swf";
      
      private static var sSymbols:Vector.<String>;
      
      private static var sAssets:AssetLoadingComponent;
      
      private static var sClasses:Object;
      
      private static var sArt:Object;
      
      private static var sPages:HudPages;
      
      private static var sPixelScale:Number = 1;
      
      private static var sReady:Boolean = false;
      
      private static var sBegun:Boolean = false;
      
      private static var sLoading:int = 0;
      
      private static var sCallbacks:Vector.<Function>;
      
      private static var sPendingPages:HudPages;
      
      private static var sPendingArt:Object;
      
      private static var sPendingScale:Number;
      
      private static var sConverter:HudArtConverter;
      
      private static var sIndex:int = 0;
      
      private static var sPendingFailures:int;
      
      private static var sRequestedScale:Number = 0;
      
      private static var sWait:Shape;
      
      private static var sContextWait:Shape;
      
      private static var sRebakedCallbacks:Vector.<Function>;
      
      private static var sLease:Object;
      
      private static var sSwfs:Vector.<SwfAsset>;
      
      private static var sLeases:Vector.<Object>;
      
      private static var sFramePages:HudPages;
      
      private static var sPendingFramePages:HudPages;
      
      private static var sBakeSymbols:Vector.<String>;
      
      private static var sLayout:String;
      
      private static var sModel:DisplayObject;
      
      private static var sFailureReason:String;
      
      private static var sScaleSince:int = 0;
      
      private static var sScaleMonitor:Shape;
      
      private static var sDemand:Vector.<Object>;
      
      private static var sDemandActive:Object;
      
      private static var sFacade:DBFacade;
      
      private static var sRejectedScale:Number = NaN;
      
      private static var sObservedScale:Number = NaN;
      
      private static var sHandlingFrame:Boolean = false;
      
      private static var sFatal:Boolean = false;
      
      private static var sCacheHead:ArtNode;
      
      private static var sCacheTail:ArtNode;
      
      private static var sEvictCursor:ArtNode;
      
      internal static const DEATH_ICON_SWF:String = "Resources/Art2D/Icons/Avatars/db_icon_death.swf";
      
      private static var sPinnedSymbols:Object = {};
      
      private static const OPTIONAL_SYMBOLS:Vector.<String> = new <String>["Resources/Art2D/Icons/Princess/db_icons_princess.swf death_icon","Resources/Art2D/Icons/Treasure/db_icons_treasure.swf death_icon"];
      
      public function HudArt()
      {
         super();
      }
      
      internal static function bakeContent(key:String, source:DisplayObject, scale:Number) : BakedCell
      {
         return bakeOn(sPages,key,source,scale);
      }
      
      internal static function bakeOn(pages:BakedPages, key:String, source:DisplayObject, scale:Number, required:Boolean = true) : BakedCell
      {
         var _loc7_:BakedCell = pages.acquire(key);
         if(_loc7_ != null)
         {
            return _loc7_;
         }
         var _loc6_:BakedPicture = StarlingRaster.bake(source,scale);
         _loc7_ = _loc6_ != null ? pages.add(key,_loc6_,true) : null;
         if(_loc7_ == null && required)
         {
            throw new Error("HUD content rasterisation refused");
         }
         return _loc7_;
      }
      
      internal static function bakePixels(source:DisplayObject, scale:Number) : BakedPicture
      {
         return StarlingRaster.bake(source,scale);
      }
      
      internal static function buildFont(pages:BakedPages, prefix:String, model:TextField, scale:Number, chars:String, layer:int) : StarlingGlyphFont
      {
         var _loc8_:StarlingGlyphFont = null;
         var _loc7_:ArtNode = null;
         try
         {
            _loc8_ = StarlingGlyphFont.build(pages,prefix,model,scale,chars,layer);
         }
         catch(error:Error)
         {
            if(!sReady)
            {
               throw error;
            }
            StarlingHud.reportError(error);
            _loc8_ = null;
         }
         if(_loc8_ == null && !sReady)
         {
            throw new Error("HUD glyph font unavailable: " + model.name);
         }
         if(_loc8_ != null && content("font|" + _loc8_.cell.key,pages) == null)
         {
            _loc7_ = new ArtNode();
            _loc7_.cell = _loc7_.hold(pages.acquire(_loc8_.cell.key),pages);
            storeContent("font|" + _loc8_.cell.key,_loc7_,pages);
         }
         return _loc8_;
      }
      
      public static function begin(facade:DBFacade) : void
      {
         if(sBegun)
         {
            return;
         }
         sSymbols = new <String>["ui_hud_old","ui_hud","stacks_hud","buff_cooldown_icon","floater_text","options_panel_button","UI_widget","UI_nametag","UI_speechbubble_typing","UI_teamloot_basic","UI_teamloot_uncommon","UI_teamloot_rare","UI_teamloot_legendary","UI_teamloot_box_small","UI_teamloot_box_royal"];
         sClasses = {};
         sArt = {};
         if(sCallbacks == null)
         {
            sCallbacks = new Vector.<Function>(0);
         }
         if(sRebakedCallbacks == null)
         {
            sRebakedCallbacks = new Vector.<Function>(0);
         }
         sSwfs = new Vector.<SwfAsset>(0);
         sDemand = new Vector.<Object>(0);
         sLeases = new Vector.<Object>(0);
         sBegun = true;
         sFacade = facade;
         sPixelScale = Math.min(Capabilities.screenResolutionX / 1920,Capabilities.screenResolutionY / 1080);
         var _loc2_:Object = new LocalSettingsFile().read();
         sLayout = _loc2_ != null && _loc2_.hasOwnProperty("hudStyle") && String(_loc2_["hudStyle"]) == "1" ? "ui_hud" : "ui_hud_old";
         sAssets = new AssetLoadingComponent(facade);
         sContextWait = new Shape();
         sContextWait.addEventListener("enterFrame",waitForContext);
         sLoading = 5;
         loadStartupSwf(sAssets,"Resources/Art2D/UI/db_UI_HUD.swf",loadedHud);
         loadStartupSwf(sAssets,"Resources/Art2D/UI/db_UI_town.swf",loadedTown);
         loadStartupSwf(sAssets,"Resources/Art2D/UI/db_UI_nametag.swf",loadedNametag);
         HudIconBake.load(facade,sAssets,loaded);
         RarityArt.load(facade,sAssets,loaded);
      }
      
      private static function loadedHud(asset:SwfAsset) : void
      {
         var _loc2_:int = 0;
         TimelineMasks.register(asset);
         sSwfs.push(asset);
         _loc2_ = 0;
         while(_loc2_ < sSymbols.length)
         {
            if(sSymbols[_loc2_] != "options_panel_button" && sSymbols[_loc2_] != "UI_widget" && sSymbols[_loc2_] != "UI_nametag" && sSymbols[_loc2_] != "UI_speechbubble_typing")
            {
               sClasses[sSymbols[_loc2_]] = requireClass(asset,"Resources/Art2D/UI/db_UI_HUD.swf",sSymbols[_loc2_]);
            }
            _loc2_++;
         }
         loaded();
      }
      
      private static function loadedTown(asset:SwfAsset) : void
      {
         TimelineMasks.register(asset);
         sSwfs.push(asset);
         sClasses.options_panel_button = requireClass(asset,"Resources/Art2D/UI/db_UI_town.swf","options_panel_button");
         sClasses.legendary_background_icon = requireClass(asset,"Resources/Art2D/UI/db_UI_town.swf","legendary_background_icon");
         loaded();
      }
      
      private static function loadedNametag(asset:SwfAsset) : void
      {
         sSwfs.push(asset);
         TimelineMasks.register(asset);
         sClasses.UI_widget = requireClass(asset,"Resources/Art2D/UI/db_UI_nametag.swf","UI_widget");
         sClasses.UI_nametag = requireClass(asset,"Resources/Art2D/UI/db_UI_nametag.swf","UI_nametag");
         sClasses.UI_speechbubble_typing = requireClass(asset,"Resources/Art2D/UI/db_UI_nametag.swf","UI_speechbubble_typing");
         loaded();
      }
      
      internal static function requireClass(asset:SwfAsset, swf:String, name:String) : Class
      {
         var _loc4_:Class = optionalClass(asset,swf,name);
         if(_loc4_ == null)
         {
            fatal("Missing required HUD class: " + swf + " " + name);
         }
         return _loc4_;
      }
      
      internal static function isOptional(swf:String, name:String) : Boolean
      {
         return OPTIONAL_SYMBOLS.indexOf(swf + " " + name) >= 0;
      }
      
      internal static function optionalClass(asset:SwfAsset, swf:String, name:String) : Class
      {
         var _loc4_:Class = null;
         if(asset == null || name == null || name.length == 0)
         {
            fatal("HUD SWF or class name missing: " + swf + " " + name);
         }
         try
         {
            _loc4_ = asset.getClass(name,true);
         }
         catch(error:Error)
         {
            fatal("HUD class load failed: " + swf + " " + name + " " + error.message);
         }
         return _loc4_;
      }
      
      internal static function loadStartupSwf(assets:AssetLoadingComponent, path:String, onLoaded:Function) : void
      {
         assets.getSwfAsset(DBFacade.buildFullDownloadPath(path),function(param1:SwfAsset):void
         {
            try
            {
               onLoaded(param1);
            }
            catch(error:Error)
            {
               fatal("HUD startup SWF: " + path + " " + error.message,true);
            }
         },function():void
         {
            fatal("HUD startup SWF load failed: " + path,true);
         });
      }
      
      internal static function loadRuntimeSwf(assets:AssetLoadingComponent, path:String, symbol:String, onLoaded:Function) : void
      {
         try
         {
            assets.getSwfAsset(DBFacade.buildFullDownloadPath(path),function(param1:SwfAsset):void
            {
               try
               {
                  onLoaded(param1);
               }
               catch(error:*)
               {
                  runtimeAssetFailed(path,symbol,error);
               }
            },function():void
            {
               fatal("HUD runtime SWF load failed: " + path + " " + symbol,true);
            });
         }
         catch(loadError:*)
         {
            runtimeAssetFailed(path,symbol,loadError);
         }
      }
      
      internal static function runtimeAssetFailed(path:String, symbol:String, error:*) : void
      {
         fatal("HUD runtime SWF load/construction failed: " + path + " " + symbol + " " + String(error),true);
      }
      
      internal static function fatal(reason:String, deferred:Boolean = false) : void
      {
         var first:Boolean = !sFatal;
         sFatal = true;
         sReady = false;
         sFailureReason = reason;
         sDemandActive = null;
         if(sDemand != null)
         {
            sDemand.length = 0;
         }
         if(sPages != null && sFramePages != null)
         {
            setPinBakes(sPages,sFramePages,false);
         }
         if(sPendingPages != null && sPendingFramePages != null)
         {
            setPinBakes(sPendingPages,sPendingFramePages,false);
         }
         if(first)
         {
            StarlingHud.giveUp();
         }
         if(deferred)
         {
            sFacade.preRenderWorkManager.doLater(0,function(... rest):void
            {
               fatal(reason);
            },false,"HudArt.fatal");
            return;
         }
         throw new HudFatalError(reason);
      }
      
      internal static function fail(reason:String, error:Error = null, report:Boolean = true) : void
      {
         if(error is HudFatalError)
         {
            fatal(error.message);
         }
         if(!sReady)
         {
            fatal(reason);
         }
         sFailureReason = reason;
         if(error == null)
         {
            error = new Error(reason);
         }
         if(report)
         {
            StarlingHud.reportError(error);
         }
      }
      
      private static function starlingInUse() : Boolean
      {
         return sFacade != null && sFacade.featureFlags.getFlagValue("starling-hud");
      }
      
      private static function discardPending() : void
      {
         var _loc1_:ArtNode = null;
         HudIconBake.cancel();
         RarityArt.cancel();
         if(sPendingArt != null)
         {
            for each(_loc1_ in sPendingArt)
            {
               try
               {
                  _loc1_.release(sPendingPages);
               }
               catch(error:*)
               {
               }
            }
         }
         if(sPendingPages != null)
         {
            try
            {
               sPendingPages.dispose();
            }
            catch(pagesError:*)
            {
            }
         }
         if(sPendingFramePages != null)
         {
            try
            {
               sPendingFramePages.dispose();
            }
            catch(framesError:*)
            {
            }
         }
         sPendingPages = sPendingFramePages = null;
         sPendingArt = null;
         nextDemand();
      }
      
      private static function loaded() : void
      {
         sLoading = sLoading - 1;
      }
      
      private static function waitForContext(event:Event) : void
      {
         if(sFatal || HudArtConverter.busy || sHandlingFrame || sContextWait == null)
         {
            return;
         }
         sHandlingFrame = true;
         try
         {
            contextReady();
         }
         catch(error:*)
         {
            fail("HUD context wait: " + String(error),error as Error);
         }
         finally
         {
            sHandlingFrame = false;
         }
      }
      
      private static function contextReady() : void
      {
         var _loc1_:Starling = sFacade.starlingLayerManager != null ? sFacade.starlingLayerManager.starlingInstance : null;
         if(sLoading != 0 || _loc1_ == null || !_loc1_.contextValid || !sFacade.starlingLayerManager.isReady())
         {
            return;
         }
         sContextWait.removeEventListener("enterFrame",waitForContext);
         sContextWait = null;
         try
         {
            startBake(sPixelScale);
         }
         catch(error:Error)
         {
            fail("HUD context/bake: " + error.message,error);
         }
      }
      
      private static function startBake(scale:Number) : void
      {
         var _loc2_:String = null;
         reserveBakeCap(scale);
         sPendingScale = scale;
         sPendingPages = new HudPages();
         sPendingFramePages = new HudPages(true);
         sPendingArt = {};
         sBakeSymbols = new Vector.<String>(0);
         for each(_loc2_ in sSymbols)
         {
            if(!((_loc2_ == "ui_hud" || _loc2_ == "ui_hud_old") && _loc2_ != sLayout && !sPinnedSymbols[_loc2_]))
            {
               sBakeSymbols.push(_loc2_);
            }
         }
         sPendingFailures = 0;
         sIndex = 0;
         convertNext();
      }
      
      private static function convertNext() : void
      {
         var _loc1_:String = null;
         var _loc2_:Class = null;
         var _loc3_:DisplayObject = null;
         if(sFatal)
         {
            return;
         }
         while(sIndex < sBakeSymbols.length)
         {
            _loc1_ = sBakeSymbols[sIndex];
            setPinBakes(sPendingPages,sPendingFramePages,!sReady || sPinnedSymbols[_loc1_] === true || _loc1_ == "ui_hud" || _loc1_ == "ui_hud_old");
            _loc2_ = sClasses[_loc1_] as Class;
            if(_loc2_ == null)
            {
               fail("Missing required HUD class: " + _loc1_);
               sPendingFailures = sPendingFailures + 1;
               sIndex = sIndex + 1;
            }
            else
            {
               HudArtConverter.beginWork();
               try
               {
                  _loc3_ = new _loc2_() as DisplayObject;
                  if(_loc1_ == "UI_nametag")
                  {
                     HudArtConverter.stopTree(_loc3_);
                     _loc3_ = MovieClip(_loc3_).hp.hpBar;
                  }
                  sModel = _loc3_;
                  sConverter = HudArtConverter.convertAsync(_loc3_,sPendingPages,sPendingScale * symbolScale(_loc1_),{
                     "hudScale":sPendingScale,
                     "kind":kindFor(_loc1_),
                     "clipMasks":petMasks,
                     "stageRate":currencyStageRate,
                     "framePages":sPendingFramePages
                  },converted,8);
                  return;
               }
               catch(error:*)
               {
                  fail("HUD conversion: " + _loc1_ + " " + String(error),error as Error);
                  sPendingFailures = sPendingFailures + 1;
                  sIndex = sIndex + 1;
                  convertNext();
                  return;
               }
               finally
               {
                  HudArtConverter.endWork();
               }
            }
         }
         if(sReady && sPendingFailures > 0)
         {
            completeBake();
            return;
         }
         setPinBakes(sPendingPages,sPendingFramePages,true);
         HudIconBake.bake(sPendingPages,sPendingFramePages,sPendingScale,sPendingArt,sLayout,iconsBaked);
      }
      
      private static function iconsBaked() : void
      {
         RarityArt.bake(sPendingPages,sPendingFramePages,sPendingScale,sPendingArt,rarityBaked);
      }
      
      private static function rarityBaked() : void
      {
         sPendingFailures += RarityArt.failures;
         if(RarityArt.failures > 0)
         {
            sFailureReason = "HUD rarity rebake incomplete";
         }
         setPinBakes(sPendingPages,sPendingFramePages,false);
         completeBake();
      }
      
      private static function setPinBakes(pages:HudPages, frames:HudPages, pinned:Boolean) : void
      {
         pages.mPinBakes = pinned;
         frames.mPinBakes = pinned;
      }
      
      private static function prepareText(node:ArtNode, path:String = "") : void
      {
         var _loc3_:StarlingText = null;
         var _loc5_:ArtNode = null;
         var _loc4_:Boolean = false;
         if(node == null)
         {
            return;
         }
         if(node.kind == "text")
         {
            _loc4_ = node.name == "HP_text" || node.name == "mana_text" || node.name == "xp_level" || node.name == "xp_points" || node.name == "game_currency_text" || node.name == "cash_text" || node.name == "quantity";
            try
            {
               _loc3_ = new StarlingText(node,node.textPages,node.pixelScale,_loc4_ ? "glyphs" : (node.name == "NametagText" || node.name == "AlertText" ? "baked" : "auto"));
            }
            catch(error:Error)
            {
               fail("HUD text preparation: " + path + " " + error.message,error);
            }
            finally
            {
               if(_loc3_ != null)
               {
                  _loc3_.dispose();
               }
            }
         }
         for each(_loc5_ in node.children)
         {
            prepareText(_loc5_,path + "." + _loc5_.name);
         }
      }
      
      private static function kindFor(symbol:String) : Function
      {
         return function(param1:String):String
         {
            if(param1.length == 0 && symbol.indexOf("UI_teamloot_") == 0)
            {
               return "timeline";
            }
            return /^UI_currency_cash\.cash\.@\d+$/.test(param1) ? "flipbook" : null;
         };
      }
      
      private static function petMasks(path:String) : Boolean
      {
         return path == "pet" || path.indexOf("pet.") == 0;
      }
      
      private static function symbolScale(symbol:String) : Number
      {
         if(symbol == "options_panel_button")
         {
            return 0.9;
         }
         if(symbol.indexOf("UI_teamloot_") == 0)
         {
            return 1.8;
         }
         if(symbol == "UI_widget" || symbol == "UI_nametag" || symbol == "UI_speechbubble_typing")
         {
            return 1.44;
         }
         return 1;
      }
      
      private static function currencyStageRate(path:String) : Boolean
      {
         return path.indexOf("UI_currency_coin.coin.") == 0 || path.indexOf("UI_currency_cash.cash.") == 0;
      }
      
      internal static function content(key:String, pages:BakedPages = null) : ArtNode
      {
         var _loc4_:Object = pages != null && pages == sPendingPages ? sPendingArt : sArt;
         var _loc3_:ArtNode = _loc4_ != null ? _loc4_["content|" + key] as ArtNode : null;
         if(_loc3_ != null)
         {
            touchContent(_loc3_);
         }
         return _loc3_;
      }
      
      internal static function artSetScale(layout:ArtNode) : Number
      {
         if(layout == null || layout.lease == null)
         {
            fatal("Required HUD art-set lease missing");
         }
         return Number(layout.lease.pixelScale);
      }
      
      internal static function artSetContent(layout:ArtNode, key:String) : ArtNode
      {
         artSetScale(layout);
         return layout.lease.art["content|" + key] as ArtNode;
      }
      
      internal static function storeContent(key:String, node:ArtNode, pages:BakedPages = null) : void
      {
         if(pages is HudPages && Boolean(HudPages(pages).mPinBakes))
         {
            node.mPinned = true;
         }
         if(pages != null && pages == sPendingPages)
         {
            sPendingArt["content|" + key] = node;
         }
         else
         {
            sArt["content|" + key] = node;
            assignLease(node,sLease);
         }
         cacheContent(node,"content|" + key,pages != null && pages == sPendingPages ? sPendingArt : sArt,pages ?? sPages);
      }
      
      private static function cacheContent(node:ArtNode, key:String, art:Object, pages:BakedPages) : void
      {
         if(node == null || node.mPinned)
         {
            return;
         }
         node.mCacheKey = key;
         node.mCacheArt = art;
         node.mCachePages = pages;
         touchContent(node);
      }
      
      private static function touchContent(node:ArtNode) : void
      {
         if(node.mCacheArt == null || sCacheTail == node)
         {
            return;
         }
         removeCached(node);
         node.mCachePrevious = sCacheTail;
         if(sCacheTail != null)
         {
            sCacheTail.mCacheNext = node;
         }
         else
         {
            sCacheHead = node;
         }
         sCacheTail = node;
      }
      
      internal static function removeCached(node:ArtNode) : void
      {
         if(sEvictCursor == node)
         {
            sEvictCursor = node.mCacheNext;
         }
         if(node.mCachePrevious != null)
         {
            node.mCachePrevious.mCacheNext = node.mCacheNext;
         }
         else if(sCacheHead == node)
         {
            sCacheHead = node.mCacheNext;
         }
         if(node.mCacheNext != null)
         {
            node.mCacheNext.mCachePrevious = node.mCachePrevious;
         }
         else if(sCacheTail == node)
         {
            sCacheTail = node.mCachePrevious;
         }
         node.mCachePrevious = node.mCacheNext = null;
      }
      
      internal static function beginEviction() : void
      {
         sEvictCursor = sCacheHead;
      }
      
      internal static function evictContent() : Boolean
      {
         var _loc1_:ArtNode = null;
         while(sEvictCursor != null)
         {
            _loc1_ = sEvictCursor;
            sEvictCursor = _loc1_.mCacheNext;
            if(_loc1_.canEvict())
            {
               delete _loc1_.mCacheArt[_loc1_.mCacheKey];
               _loc1_.release(_loc1_.mCachePages);
               return true;
            }
         }
         return false;
      }
      
      private static function converted(art:ArtNode) : void
      {
         try
         {
            convertedSafely(art);
         }
         catch(error:Error)
         {
            fail("HUD conversion completion: " + error.message,error);
         }
      }
      
      private static function convertedSafely(art:ArtNode) : void
      {
         if(sFatal)
         {
            return;
         }
         var _loc2_:String = sBakeSymbols[sIndex];
         HudArtConverter.stopTree(sModel);
         sModel = null;
         prepareText(art,_loc2_);
         var _loc3_:HudArtConverter = sConverter;
         if(!sReady && (art == null || _loc3_.failures > 0))
         {
            if(art != null)
            {
               art.release(sPendingPages);
            }
            fatal("Required HUD bake failed: " + _loc2_ + (_loc3_.error != null ? " " + _loc3_.error : ""));
         }
         if(art != null)
         {
            art.mPinned = sPendingPages.mPinBakes;
            if(art.mPinned)
            {
               sPinnedSymbols[_loc2_] = true;
            }
            sPendingArt[_loc2_] = art;
         }
         sPendingFailures += _loc3_.failures;
         if(_loc3_.failures > 0)
         {
            sFailureReason = "HUD bake failed: " + _loc2_ + (_loc3_.error != null ? " " + _loc3_.error : "");
         }
         sConverter = null;
         sIndex = sIndex + 1;
         convertNext();
      }
      
      private static function completeBake() : void
      {
         var _loc1_:ArtNode = null;
         var _loc4_:String = null;
         var _loc3_:Function = null;
         HudIconBake.cancel();
         setPinBakes(sPendingPages,sPendingFramePages,false);
         if(sFatal)
         {
            return;
         }
         if(!sReady && sPendingFailures > 0)
         {
            fatal(sFailureReason ?? "HUD startup conversion incomplete");
         }
         if(sReady && sPendingFailures > 0)
         {
            sRejectedScale = Math.round(sPendingScale * 1000);
            fail(sFailureReason ?? "HUD rebake incomplete",null,false);
            discardPending();
            return;
         }
         var _loc5_:Object = {
            "pages":sPendingPages,
            "framePages":sPendingFramePages,
            "art":sPendingArt,
            "pixelScale":sPendingScale,
            "views":0,
            "retired":false,
            "release":releaseLease
         };
         for(_loc4_ in sPendingArt)
         {
            assignLease(sPendingArt[_loc4_] as ArtNode,_loc5_);
         }
         for each(_loc4_ in new <String>["ui_hud_old","ui_hud"])
         {
            _loc1_ = sPendingArt[_loc4_] as ArtNode;
            if(_loc1_ != null)
            {
               RarityArt.verifySlots(_loc1_,sFacade);
            }
         }
         var _loc2_:Object = sLease;
         sPages = sPendingPages;
         sFramePages = sPendingFramePages;
         sArt = sPendingArt;
         sPixelScale = sPendingScale;
         sPendingPages = null;
         sPendingFramePages = null;
         sPendingArt = null;
         sLease = _loc5_;
         sLeases.push(sLease);
         sizeStarlingCap();
         for(_loc4_ in sArt)
         {
            _loc1_ = sArt[_loc4_] as ArtNode;
            cacheContent(_loc1_,_loc4_,sArt,sPages);
         }
         sReady = true;
         try
         {
            while(sCallbacks.length > 0)
            {
               _loc3_ = sCallbacks.shift();
               try
               {
                  _loc3_();
               }
               catch(error:Error)
               {
                  StarlingHud.reportError(error);
               }
            }
            if(_loc2_ != null)
            {
               for each(_loc3_ in sRebakedCallbacks)
               {
                  try
                  {
                     _loc3_();
                  }
                  catch(rebakedError:Error)
                  {
                     StarlingHud.reportError(rebakedError);
                  }
               }
            }
         }
         finally
         {
            if(_loc2_ != null)
            {
               _loc2_.retired = true;
               if(_loc2_.views == 0)
               {
                  releaseLease(_loc2_);
               }
            }
         }
         if(sRequestedScale > 0)
         {
            waitForRebake();
         }
         if(sScaleMonitor == null)
         {
            sScaleMonitor = new Shape();
            sScaleMonitor.addEventListener("enterFrame",monitorScale);
         }
         nextDemand();
      }
      
      private static function rebake(scale:Number) : void
      {
         if(!sBegun || !starlingInUse() || scale <= 0 || !isFinite(scale))
         {
            return;
         }
         var _loc2_:Number = Math.round(scale * 1000);
         if(sObservedScale != _loc2_)
         {
            sObservedScale = _loc2_;
            sRejectedScale = NaN;
            sScaleSince = getTimer();
         }
         if(_loc2_ == sRejectedScale)
         {
            return;
         }
         if(Math.abs(scale / sPixelScale - 1) <= 0.15)
         {
            sRequestedScale = 0;
            sScaleSince = 0;
            if(sWait != null)
            {
               sWait.removeEventListener("enterFrame",tryRebake);
            }
            sWait = null;
            return;
         }
         if(sRequestedScale == 0)
         {
            sScaleSince = getTimer();
         }
         sRequestedScale = scale;
         waitForRebake();
      }
      
      private static function waitForRebake() : void
      {
         if(sWait != null)
         {
            return;
         }
         sWait = new Shape();
         sWait.addEventListener("enterFrame",tryRebake);
      }
      
      private static function tryRebake(event:Event) : void
      {
         if(HudArtConverter.busy || sHandlingFrame || sWait == null)
         {
            return;
         }
         sHandlingFrame = true;
         try
         {
            rebakeWhenReady();
         }
         catch(error:*)
         {
            fail("HUD rebake: " + String(error),error as Error);
         }
         finally
         {
            sHandlingFrame = false;
         }
      }
      
      private static function rebakeWhenReady() : void
      {
         if(!starlingInUse())
         {
            return;
         }
         if(sRequestedScale <= 0 || !isFinite(sRequestedScale))
         {
            return;
         }
         if(Math.round(sRequestedScale * 1000) == sRejectedScale)
         {
            sRequestedScale = 0;
            sWait.removeEventListener("enterFrame",tryRebake);
            sWait = null;
            return;
         }
         if(!sReady || sPendingPages != null || sDemandActive != null || RarityArt.busy || getTimer() - sScaleSince <= 2000 || !BakeBudget.mayAllocate)
         {
            return;
         }
         sWait.removeEventListener("enterFrame",tryRebake);
         sWait = null;
         var _loc1_:Number = sRequestedScale;
         sRequestedScale = 0;
         if(Math.abs(_loc1_ / sPixelScale - 1) > 0.15)
         {
            startBake(_loc1_);
         }
      }
      
      private static function monitorScale(event:Event) : void
      {
         if(HudArtConverter.busy || sHandlingFrame)
         {
            return;
         }
         try
         {
            if(starlingInUse() && Starling.current != null && Starling.current.contextValid)
            {
               rebake(Starling.contentScaleFactor);
            }
         }
         catch(error:Error)
         {
            fail("HUD scale monitor: " + error.message,error);
         }
      }
      
      public static function get begun() : Boolean
      {
         return sBegun;
      }
      
      public static function removeReady(callback:Function) : void
      {
         var _loc2_:int = sCallbacks.indexOf(callback);
         if(_loc2_ >= 0)
         {
            sCallbacks.removeAt(_loc2_);
         }
      }
      
      public static function get ready() : Boolean
      {
         return sReady;
      }
      
      internal static function get fatalFailure() : Boolean
      {
         return sFatal;
      }
      
      public static function onReady(callback:Function) : void
      {
         if(sReady)
         {
            callback();
         }
         else
         {
            if(sCallbacks == null)
            {
               sCallbacks = new Vector.<Function>(0);
            }
            sCallbacks.push(callback);
         }
      }
      
      public static function onRebaked(callback:Function) : void
      {
         if(sRebakedCallbacks == null)
         {
            sRebakedCallbacks = new Vector.<Function>(0);
         }
         if(sRebakedCallbacks.indexOf(callback) < 0)
         {
            sRebakedCallbacks.push(callback);
         }
      }
      
      public static function removeRebaked(callback:Function) : void
      {
         var _loc2_:int = sRebakedCallbacks.indexOf(callback);
         if(_loc2_ >= 0)
         {
            sRebakedCallbacks.removeAt(_loc2_);
         }
      }
      
      public static function art(symbolName:String) : ArtNode
      {
         var _loc2_:ArtNode = sArt[symbolName] as ArtNode;
         if(_loc2_ != null)
         {
            touchContent(_loc2_);
         }
         return _loc2_;
      }
      
      public static function swfClass(symbolName:String) : Class
      {
         var _loc4_:SwfAsset = null;
         var _loc2_:Class = sClasses[symbolName] as Class;
         if(_loc2_ != null)
         {
            return _loc2_;
         }
         for each(_loc4_ in sSwfs)
         {
            try
            {
               _loc2_ = _loc4_.getClass(symbolName,true);
            }
            catch(error:Error)
            {
               fatal("HUD class load failed: " + _loc4_.swfPath + " " + symbolName + " " + error.message);
            }
            if(_loc2_ != null)
            {
               sClasses[symbolName] = _loc2_;
               return _loc2_;
            }
         }
         var _loc3_:String = "";
         for each(_loc4_ in sSwfs)
         {
            _loc3_ += _loc4_.swfPath + " ";
         }
         fatal("Missing required HUD class: " + _loc3_ + symbolName);
         return null;
      }
      
      public static function get pages() : BakedPages
      {
         return sPages;
      }
      
      public static function get framePages() : BakedPages
      {
         return sFramePages;
      }
      
      public static function get pixelScale() : Number
      {
         return sPixelScale;
      }
      
      internal static function bakePixelScale(pages:BakedPages) : Number
      {
         return pages == sPendingPages ? sPendingScale : sPixelScale;
      }
      
      public static function convertLayout(type:uint, onDone:Function) : void
      {
         sDemand.push({
            "symbol":(type == 1 ? "ui_hud" : "ui_hud_old"),
            "callback":onDone,
            "layout":true
         });
         nextDemand();
      }
      
      public static function convertSymbol(symbol:String, onDone:Function) : void
      {
         var _loc3_:ArtNode = art(symbol);
         if(_loc3_ != null)
         {
            if(onDone != null)
            {
               onDone(_loc3_);
            }
            return;
         }
         sDemand.push({
            "symbol":symbol,
            "callback":onDone
         });
         nextDemand();
      }
      
      private static function nextDemand() : void
      {
         var _loc3_:Class = null;
         if(sFatal || !sReady || sPendingPages != null || sDemandActive != null || sDemand.length == 0)
         {
            return;
         }
         sDemandActive = sDemand.shift();
         var _loc1_:ArtNode = art(sDemandActive.symbol);
         if(_loc1_ != null)
         {
            finishDemand(_loc1_);
            return;
         }
         var _loc2_:Boolean = sDemandActive.symbol == "ui_hud" || sDemandActive.symbol == "ui_hud_old";
         setPinBakes(sPages,sFramePages,_loc2_);
         HudArtConverter.beginWork();
         try
         {
            if(_loc2_)
            {
               reserveBakeCap(sPixelScale);
            }
            _loc3_ = swfClass(sDemandActive.symbol);
            sModel = new _loc3_() as DisplayObject;
            sConverter = HudArtConverter.convertAsync(sModel,sPages,sPixelScale * symbolScale(sDemandActive.symbol),{
               "hudScale":sPixelScale,
               "kind":kindFor(sDemandActive.symbol),
               "clipMasks":petMasks,
               "stageRate":currencyStageRate,
               "framePages":sFramePages
            },demandConverted,8);
         }
         catch(error:*)
         {
            fail("HUD conversion: " + String(error),error as Error);
            finishDemand(null);
         }
         finally
         {
            HudArtConverter.endWork();
         }
      }
      
      private static function demandConverted(node:ArtNode) : void
      {
         try
         {
            demandConvertedSafely(node);
         }
         catch(error:Error)
         {
            fail("HUD demand completion: " + error.message,error);
         }
      }
      
      private static function demandConvertedSafely(node:ArtNode) : void
      {
         if(sFatal)
         {
            return;
         }
         HudArtConverter.stopTree(sModel);
         sModel = null;
         var _loc4_:Boolean = sDemandActive.symbol == "ui_hud" || sDemandActive.symbol == "ui_hud_old";
         if(_loc4_ && node != null)
         {
            node.pinStartupTree();
         }
         setPinBakes(sPages,sFramePages,_loc4_);
         try
         {
            prepareText(node,sDemandActive.symbol);
         }
         catch(error:Error)
         {
            fail("HUD text preparation: " + error.message,error);
         }
         finally
         {
            setPinBakes(sPages,sFramePages,false);
         }
         var _loc3_:HudArtConverter = sConverter;
         var _loc2_:String = sDemandActive.symbol;
         if(_loc3_.failures > 0)
         {
            fail("HUD conversion incomplete: " + _loc2_,null,false);
            if(node != null)
            {
               node.release(sPages);
            }
            sConverter = null;
            finishDemand(null);
            return;
         }
         if(node != null)
         {
            node.mPinned = _loc4_;
            if(node.mPinned)
            {
               sPinnedSymbols[_loc2_] = true;
            }
         }
         sArt[_loc2_] = node;
         assignLease(node,sLease);
         cacheContent(node,_loc2_,sArt,sPages);
         if(_loc4_)
         {
            RarityArt.bake(sPages,sFramePages,sPixelScale,sArt,layoutPrepared);
            return;
         }
         sConverter = null;
         finishDemand(node);
      }
      
      private static function layoutPrepared() : void
      {
         var _loc1_:String = null;
         var _loc2_:ArtNode = null;
         if(sFatal)
         {
            return;
         }
         if(RarityArt.failures > 0)
         {
            _loc1_ = sDemandActive.symbol;
            fail("HUD rarity preparation incomplete: " + _loc1_,null,false);
            _loc2_ = sArt[_loc1_] as ArtNode;
            delete sArt[_loc1_];
            delete sPinnedSymbols[_loc1_];
            if(_loc2_ != null)
            {
               _loc2_.release(sPages);
            }
            sConverter = null;
            finishDemand(null);
            return;
         }
         RarityArt.verifySlots(sArt[sDemandActive.symbol] as ArtNode,sFacade);
         sizeStarlingCap();
         sConverter = null;
         finishDemand(sArt[sDemandActive.symbol] as ArtNode);
      }
      
      private static function finishDemand(node:ArtNode) : void
      {
         setPinBakes(sPages,sFramePages,false);
         if(sFatal)
         {
            return;
         }
         if(node != null && sDemandActive.layout === true)
         {
            sLayout = sDemandActive.symbol;
         }
         var _loc2_:Function = sDemandActive.callback;
         sDemandActive = null;
         if(_loc2_ != null)
         {
            try
            {
               _loc2_(node);
            }
            catch(error:Error)
            {
               StarlingHud.reportError(error);
            }
         }
         nextDemand();
      }
      
      private static function sizeStarlingCap() : void
      {
         var _loc1_:Number = (sPages.pinnedBytes + sFramePages.pinnedBytes) / 1048576;
         BakeBudget.HUD_STARLING_CAP_MIB = Math.ceil(Math.max(32 * Math.max(1,sPixelScale * sPixelScale),_loc1_ * 2.5,accountedBytes() / 1048576 * 2.5,residentBytes() / 1048576));
      }
      
      private static function reserveBakeCap(scale:Number) : void
      {
         var _loc2_:Number = scale * scale;
         var _loc3_:Number = sReady ? accountedBytes() / 1048576 * _loc2_ / (sPixelScale * sPixelScale) * 1.5 : 64 * Math.max(1,_loc2_);
         BakeBudget.HUD_STARLING_CAP_MIB = Math.ceil(Math.max(BakeBudget.HUD_STARLING_CAP_MIB,residentBytes() / 1048576 + _loc3_));
      }
      
      private static function accountedBytes() : Number
      {
         return sPages != null ? sPages.accountedBytes + sFramePages.accountedBytes : 0;
      }
      
      private static function residentBytes() : Number
      {
         var _loc2_:Object = null;
         var _loc1_:Number = 0;
         for each(_loc2_ in sLeases)
         {
            _loc1_ += HudPages(_loc2_.pages).accountedBytes + HudPages(_loc2_.framePages).accountedBytes;
         }
         if(sPendingPages != null)
         {
            _loc1_ += sPendingPages.accountedBytes + sPendingFramePages.accountedBytes;
         }
         return _loc1_;
      }
      
      private static function assignLease(node:ArtNode, lease:Object) : void
      {
         var _loc3_:ArtNode = null;
         if(node == null)
         {
            return;
         }
         node.lease = lease;
         for each(_loc3_ in node.children)
         {
            assignLease(_loc3_,lease);
         }
      }
      
      private static function releaseLease(lease:Object) : void
      {
         var _loc2_:ArtNode = null;
         for each(_loc2_ in lease.art)
         {
            _loc2_.release(lease.pages);
         }
         lease.pages.dispose();
         lease.framePages.dispose();
         lease.art = null;
         var _loc3_:int = sLeases.indexOf(lease);
         if(_loc3_ >= 0)
         {
            sLeases.removeAt(_loc3_);
         }
      }
   }
}

