package UI.Hud.StarlingConverted
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedImage;
   import Brain.Starling.SwfConverter.BakedPages;
   import Facade.DBFacade;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import starling.core.Starling;
   import starling.display.DisplayObjectContainer;
   
   public class StarlingHudIcon
   {
      
      private var mFacade:DBFacade;
      
      private var mAssets:AssetLoadingComponent;
      
      private var mTicker:HudTicker;
      
      private var mParent:DisplayObjectContainer;
      
      private var mImage:BakedImage;
      
      private var mRetry:Function;
      
      private var mChanged:Function;
      
      private var mDisposed:Boolean;
      
      private var mGeneration:uint;
      
      private var mArt:ArtNode;
      
      private var mAbsent:Boolean;
      
      public function StarlingHudIcon(facade:DBFacade, ticker:HudTicker, parent:DisplayObjectContainer, changed:Function)
      {
         super();
         mFacade = facade;
         mAssets = new AssetLoadingComponent(facade);
         mTicker = ticker;
         mParent = parent;
         mChanged = changed;
      }
      
      public function load(swf:String, name:String, scale:Number = 1, alpha:Number = 1, fit:Number = 0, red:Boolean = false, circle:Boolean = false) : void
      {
         var generation:uint;
         if(mDisposed)
         {
            return;
         }
         if(mParent == null)
         {
            throw new Error("HUD icon mount unavailable: " + name);
         }
         generation = ++mGeneration;
         if(mRetry != null)
         {
            mTicker.cancelBake(mRetry);
         }
         mRetry = null;
         if(mImage != null)
         {
            mImage.removeFromParent(true);
         }
         if(mArt != null)
         {
            mArt.releaseView();
         }
         mArt = null;
         mImage = null;
         mAbsent = false;
         HudArt.loadRuntimeSwf(mAssets,swf,name,function(param1:SwfAsset):void
         {
            var symbol:Class;
            var source:MovieClip;
            var bounds:Rectangle;
            var bakeSource:DisplayObject;
            var holder:Sprite;
            var pixelScale:Number;
            var key:String;
            var masked:Boolean;
            var retry:Function;
            var asset:SwfAsset = param1;
            if(mDisposed || generation != mGeneration)
            {
               return;
            }
            symbol = HudIconBake.symbol(asset,swf,name);
            if(symbol == null)
            {
               mAbsent = true;
               if(mChanged != null)
               {
                  mChanged();
               }
               return;
            }
            source = new symbol() as MovieClip;
            if(source == null)
            {
               HudArt.fatal("Required HUD icon is not a MovieClip: " + swf + " " + name);
            }
            HudArtConverter.stopTree(source);
            bounds = source.getBounds(source);
            if(fit > 0)
            {
               scale = fit / Math.max(source.width,source.height);
            }
            bakeSource = source;
            if(red)
            {
               source.transform.colorTransform = new ColorTransform(2.5,0.25,0.25,1);
               holder = new Sprite();
               holder.addChild(source);
               bakeSource = holder;
            }
            pixelScale = BakeScale.forDisplay(mParent) * scale;
            key = swf + "|" + name + "|" + scale + "|" + red + "|" + (circle ? "circle|" : "") + BakedPages.scaleKey(pixelScale);
            retry = function():Boolean
            {
               var _loc1_:ArtNode = null;
               var _loc2_:BakedCell = null;
               try
               {
                  if(mDisposed || generation != mGeneration)
                  {
                     return true;
                  }
                  if(Starling.current == null || !Starling.current.contextValid)
                  {
                     return false;
                  }
                  _loc1_ = HudArt.content(key);
                  if(_loc1_ == null)
                  {
                     if(circle && !masked)
                     {
                        bakeSource = HudIconBake.maskAvatar(bakeSource);
                        masked = true;
                     }
                     _loc2_ = HudArt.bakeContent(key,bakeSource,pixelScale);
                     if(_loc2_ == null)
                     {
                        return false;
                     }
                     _loc1_ = new ArtNode();
                     _loc1_.cell = _loc1_.hold(_loc2_,HudArt.pages);
                     HudArt.storeContent(key,_loc1_);
                  }
                  mImage = new BakedImage(_loc1_.cell);
                  mArt = _loc1_;
                  _loc1_.retainView();
                  mImage.scaleX = mImage.scaleY = scale;
                  mImage.alpha = alpha;
                  if(fit > 0)
                  {
                     mImage.x = -(bounds.left + bounds.width * 0.5) + 10;
                     mImage.y = -(bounds.top + bounds.height * 0.5) + 10;
                  }
                  mParent.addChild(mImage);
                  mRetry = null;
                  source = null;
                  bakeSource = null;
                  if(mChanged != null)
                  {
                     mChanged();
                  }
                  return true;
               }
               catch(error:Error)
               {
                  StarlingHud.reportError(error);
                  var _loc8_:Boolean = true;
               }
               return _loc8_;
            };
            mRetry = retry;
            if(!retry() && !mDisposed && generation == mGeneration)
            {
               mTicker.deferBake(retry);
            }
         });
      }
      
      public function get image() : BakedImage
      {
         return mImage;
      }
      
      public function get absent() : Boolean
      {
         return mAbsent;
      }
      
      public function dispose() : void
      {
         mDisposed = true;
         mGeneration = mGeneration + 1;
         if(mRetry != null)
         {
            mTicker.cancelBake(mRetry);
         }
         if(mImage != null)
         {
            mImage.removeFromParent(true);
         }
         if(mArt != null)
         {
            mArt.releaseView();
         }
         mArt = null;
         mAssets.destroy();
         mParent = null;
         mImage = null;
         mRetry = mChanged = null;
      }
   }
}

