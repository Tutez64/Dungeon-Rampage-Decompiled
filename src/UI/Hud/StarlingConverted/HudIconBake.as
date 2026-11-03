package UI.Hud.StarlingConverted
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Starling.SwfConverter.BakedPages;
   import Facade.DBFacade;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.utils.getTimer;
   import starling.core.Starling;
   
   public class HudIconBake
   {
      
      internal static const AVATAR_MOUNT:String = "UI_widget.UI_avatar";
      
      private static var sLoading:int;
      
      private static var sLoaded:Function;
      
      private static var sDone:Function;
      
      private static var sDriver:Shape;
      
      private static var sPages:BakedPages;
      
      private static var sFrames:BakedPages;
      
      private static var sArt:Object;
      
      private static var sLayout:String;
      
      private static var sIndex:int;
      
      private static var sScale:Number;
      
      private static var sModifierWidth:Number;
      
      private static var sRows:Vector.<Object> = new Vector.<Object>(0);
      
      private static var sSeen:Object = {};
      
      private static var sLibraries:Object = {};
      
      public function HudIconBake()
      {
         super();
      }
      
      internal static function symbol(asset:SwfAsset, swf:String, name:String) : Class
      {
         return HudArt.isOptional(swf,name) ? HudArt.optionalClass(asset,swf,name) : HudArt.requireClass(asset,swf,name);
      }
      
      internal static function get requests() : Vector.<Object>
      {
         return sRows;
      }
      
      internal static function load(facade:DBFacade, assets:AssetLoadingComponent, done:Function) : void
      {
         var _loc5_:Object = null;
         var _loc4_:String = null;
         sLoaded = done;
         var _loc6_:Object = facade.gameMaster;
         for each(_loc5_ in _loc6_.Stackables)
         {
            if(_loc5_.UsageAttack != null && _loc5_.UsageAttack.length > 0 && !_loc5_.AccountBooster)
            {
               add(_loc5_.UISwfFilepath,_loc5_.IconName,0.6,false,true,"consumables_01.graphic");
            }
         }
         for each(_loc5_ in _loc6_.Buffs)
         {
            if(_loc5_.ShowInHUD)
            {
               add(_loc5_.IconSwf,_loc5_.IconName,0.75,false,false,"buff_cooldown_icon.graphic");
            }
         }
         for each(_loc5_ in _loc6_.Npcs)
         {
            if(_loc5_.CharType == "PET" && _loc5_.UsePetUI)
            {
               add(_loc5_.IconSwfFilepath,_loc5_.IconName,1.1764705882352942,false,false,"pet.graphic");
            }
            if(_loc5_.HasOffscreenIndicator)
            {
               avatar(_loc5_.IconSwfFilepath,_loc5_.IconName);
            }
         }
         var _loc8_:Object = _loc6_.getSkinByType(facade.dbAccountInfo.activeAvatarSkinId);
         for each(_loc5_ in _loc6_.Skins)
         {
            avatar(_loc5_.IconSwfFilepath,_loc5_.IconName);
         }
         if(_loc8_ != null)
         {
            add(_loc8_.UISwfFilepath,_loc8_.IconName,1,false,false,"UI_profile.avatar",true);
         }
         for each(_loc5_ in _loc6_.DungeonModifiers)
         {
            add(_loc5_.IconFilepath,_loc5_.IconName,1,false,false,"floor_modifier01");
         }
         var _loc7_:Vector.<String> = new Vector.<String>(0);
         for(_loc4_ in sLibraries)
         {
            _loc7_.push(_loc4_);
         }
         sLoading = _loc7_.length;
         for each(_loc4_ in _loc7_)
         {
            loadLibrary(assets,_loc4_);
         }
         if(_loc7_.length == 0)
         {
            loaded();
         }
      }
      
      private static function avatar(swf:String, name:String) : void
      {
         add(swf,name,1,false,false,"UI_widget.UI_avatar");
         add(swf,name,1,true,false,"UI_widget.UI_avatar");
         add("Resources/Art2D/Icons/Avatars/db_icon_death.swf","death_icon",1,false,false,"UI_widget.UI_avatar");
      }
      
      public static function maskAvatar(source:DisplayObject, widgetClass:Class = null) : Sprite
      {
         var _loc4_:Boolean = false;
         var _loc9_:DisplayObject = null;
         var _loc6_:int = 0;
         if(widgetClass == null)
         {
            widgetClass = HudArt.swfClass("UI_widget");
         }
         var _loc3_:MovieClip = new widgetClass() as MovieClip;
         HudArtConverter.stopTree(_loc3_);
         var _loc8_:DisplayObjectContainer = _loc3_.getChildByName("UI_avatar") as DisplayObjectContainer;
         _loc6_ = 0;
         while(_loc6_ < _loc3_.numChildren)
         {
            _loc9_ = _loc3_.getChildAt(_loc6_);
            if(TimelineMasks.isMask(_loc3_,_loc9_))
            {
               _loc4_ = true;
            }
            else if(_loc9_ != _loc8_)
            {
               _loc9_.visible = false;
            }
            _loc6_++;
         }
         if(_loc8_ == null || !_loc4_)
         {
            HudArt.fatal("UI_widget avatar mask missing");
         }
         _loc8_.addChild(source);
         var _loc5_:Matrix = _loc8_.transform.matrix.clone();
         _loc5_.invert();
         _loc3_.transform.matrix = _loc5_;
         var _loc7_:Sprite = new Sprite();
         _loc7_.addChild(_loc3_);
         return _loc7_;
      }
      
      private static function add(swf:String, name:String, scale:Number, red:Boolean = false, slot:Boolean = false, mount:String = "", portrait:Boolean = false) : void
      {
         if(swf == null || swf.length == 0 || name == null || name.length == 0)
         {
            return;
         }
         var _loc8_:String = swf + "|" + name + "|" + scale + "|" + (slot ? "" : red + "|") + mount + "|" + portrait;
         if(sSeen[_loc8_])
         {
            return;
         }
         sSeen[_loc8_] = true;
         sLibraries[swf] = null;
         sRows.push({
            "swf":swf,
            "name":name,
            "scale":scale,
            "red":red,
            "slot":slot,
            "mount":mount,
            "portrait":portrait
         });
      }
      
      private static function loadLibrary(assets:AssetLoadingComponent, path:String) : void
      {
         HudArt.loadStartupSwf(assets,path,function(param1:SwfAsset):void
         {
            sLibraries[path] = param1;
            loaded();
         });
      }
      
      private static function loaded() : void
      {
         if(--sLoading > 0)
         {
            return;
         }
         var _loc1_:Function = sLoaded;
         sLoaded = null;
         if(_loc1_ != null)
         {
            _loc1_();
         }
      }
      
      internal static function bake(pages:BakedPages, frames:BakedPages, scale:Number, art:Object, layout:String, done:Function) : void
      {
         var _loc8_:ArtView = null;
         var _loc7_:StarlingButton = null;
         sPages = pages;
         sFrames = frames;
         HudPages(pages).mPinBakes = HudPages(frames).mPinBakes = false;
         sLayout = layout;
         sScale = scale;
         sArt = art;
         sDone = done;
         sIndex = 0;
         var _loc9_:ArtNode = sArt[layout] as ArtNode;
         var _loc10_:ArtNode = _loc9_ != null ? _loc9_.find("floor_modifier01") : null;
         sModifierWidth = 0;
         if(_loc10_ != null)
         {
            _loc8_ = ArtView.build(_loc10_);
            _loc7_ = new StarlingButton(_loc8_);
            sModifierWidth = _loc7_.root.width;
            _loc7_.dispose();
            _loc8_.dispose();
         }
         sDriver = new Shape();
         sDriver.addEventListener("enterFrame",update);
      }
      
      private static function mountScale(path:String) : Number
      {
         var _loc2_:String = path.indexOf("UI_widget.") == 0 ? "UI_widget" : (path.indexOf("buff_cooldown_icon.") == 0 ? "buff_cooldown_icon" : sLayout);
         var _loc3_:ArtNode = sArt[_loc2_] as ArtNode;
         if(_loc3_ == null || path.length == 0)
         {
            return 1;
         }
         if(_loc2_ == "UI_widget" || _loc2_ == "buff_cooldown_icon")
         {
            path = path.substr(_loc2_.length + 1);
         }
         return BakeScale.forArt(_loc3_,path) * (_loc2_ == "UI_widget" ? 1.44 : 1);
      }
      
      private static function update(event:Event) : void
      {
         var _loc7_:Object = null;
         var _loc2_:Class = null;
         var _loc8_:DisplayObject = null;
         var _loc6_:Sprite = null;
         var _loc3_:ArtNode = null;
         var _loc10_:String = null;
         var _loc4_:ArtNode = null;
         var _loc9_:Boolean = false;
         if(HudArt.fatalFailure)
         {
            cancel();
            return;
         }
         if(Starling.current == null || !Starling.current.contextValid)
         {
            return;
         }
         if(HudArtConverter.busy)
         {
            return;
         }
         var _loc5_:int = getTimer();
         while(sIndex < sRows.length && getTimer() - _loc5_ < 8)
         {
            _loc7_ = sRows[sIndex++];
            _loc2_ = HudIconBake.symbol(sLibraries[_loc7_.swf],_loc7_.swf,_loc7_.name);
            if(_loc2_ != null)
            {
               try
               {
                  _loc8_ = new _loc2_() as DisplayObject;
                  if(_loc8_ == null)
                  {
                     throw new Error("Required HUD icon is not a DisplayObject");
                  }
                  HudArtConverter.stopTree(_loc8_);
               }
               catch(constructionError:*)
               {
                  cancel();
                  HudArt.fatal("HUD startup icon construction failed: " + _loc7_.swf + " " + _loc7_.name + " " + String(constructionError));
               }
               try
               {
                  if(_loc7_.portrait)
                  {
                     _loc4_ = sArt[sLayout] as ArtNode;
                     _loc7_.mount = _loc4_.find("avatar") != null ? "avatar" : "UI_profile.avatar";
                  }
                  _loc7_.displayScale = _loc7_.mount == "floor_modifier01" && sModifierWidth > 0 ? sModifierWidth / Math.max(_loc8_.width,_loc8_.height) : _loc7_.scale;
                  _loc7_.pixelScale = sScale * _loc7_.displayScale * mountScale(_loc7_.mount);
                  _loc9_ = _loc7_.mount == "UI_widget.UI_avatar";
                  _loc10_ = _loc7_.portrait ? "hudStarlingPortrait|" + _loc7_.swf + "|" + _loc7_.name + "|" + BakedPages.scaleKey(_loc7_.pixelScale) : _loc7_.swf + "|" + _loc7_.name + "|" + _loc7_.displayScale + "|" + (_loc7_.slot ? "" : _loc7_.red + "|") + (_loc9_ ? "circle|" : "") + BakedPages.scaleKey(_loc7_.pixelScale);
                  if(sArt["content|" + _loc10_] == null)
                  {
                     if(_loc7_.red)
                     {
                        _loc8_.transform.colorTransform = new ColorTransform(2.5,0.25,0.25,1);
                        _loc6_ = new Sprite();
                        _loc6_.addChild(_loc8_);
                        _loc8_ = _loc6_;
                     }
                     if(_loc9_)
                     {
                        _loc8_ = maskAvatar(_loc8_);
                     }
                     if(_loc7_.portrait || _loc9_)
                     {
                        _loc3_ = new ArtNode();
                        _loc3_.kind = "static";
                        _loc3_.key = _loc10_;
                        _loc3_.cell = _loc3_.hold(HudArt.bakeOn(sPages,_loc10_,_loc8_,_loc7_.pixelScale,false),sPages);
                        if(_loc3_.cell == null)
                        {
                           _loc3_.failures++;
                        }
                     }
                     else
                     {
                        _loc3_ = HudArtConverter.convert(_loc8_,sPages,_loc7_.pixelScale,{
                           "hudScale":HudArt.bakePixelScale(sPages),
                           "flatten":true,
                           "framePages":sFrames
                        });
                     }
                     HudArtConverter.stopTree(_loc8_);
                     if(_loc3_ == null || _loc3_.failures > 0)
                     {
                        if(_loc3_ != null)
                        {
                           _loc3_.release(sPages);
                        }
                        if(!HudArt.ready)
                        {
                           cancel();
                           HudArt.fatal("Required HUD icon bake failed: " + _loc10_);
                        }
                        StarlingHud.reportError(new Error("HUD icon rebake refused: " + _loc10_));
                     }
                     else
                     {
                        sArt["content|" + _loc10_] = _loc3_;
                        _loc3_.pinStartupTree();
                     }
                  }
               }
               catch(error:*)
               {
                  cancel();
                  if(error is HudFatalError)
                  {
                     throw error;
                  }
                  HudArt.fatal("HUD startup icon preparation failed: " + _loc7_.swf + " " + _loc7_.name + " " + String(error));
               }
            }
         }
         if(sIndex == sRows.length)
         {
            finish();
         }
      }
      
      private static function finish() : void
      {
         cancel();
         var _loc1_:Function = sDone;
         sDone = null;
         if(_loc1_ != null)
         {
            _loc1_();
         }
      }
      
      internal static function cancel() : void
      {
         if(sDriver != null)
         {
            sDriver.removeEventListener("enterFrame",update);
         }
         sDriver = null;
      }
   }
}

