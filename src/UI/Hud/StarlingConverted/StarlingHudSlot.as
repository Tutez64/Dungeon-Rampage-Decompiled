package UI.Hud.StarlingConverted
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Starling.SwfConverter.BakedPages;
   import Brain.Utils.TextUtil;
   import Combat.Weapon.ConsumableWeaponGameObject;
   import Combat.Weapon.WeaponGameObject;
   import DBGlobals.DBGlobal;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMRarity;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   
   public class StarlingHudSlot
   {
      
      internal static const WEAPON_TOOLTIP_SWF:String = "Resources/Art2D/UI/db_UI_town.swf";
      
      internal static const WEAPON_TOOLTIPS:Vector.<String> = new <String>["DR_weapon_tooltip_z","DR_weapon_tooltip"];
      
      private var mFacade:DBFacade;
      
      private var mTicker:HudTicker;
      
      private var mAssets:AssetLoadingComponent;
      
      private var mButton:StarlingButton;
      
      private var mRoot:ArtDisplay;
      
      private var mGraphic:ArtDisplay;
      
      private var mSelection:ArtDisplay;
      
      private var mAuthoredTooltip:ArtDisplay;
      
      private var mCooldown:TimelineView;
      
      private var mQuantity:StarlingText;
      
      private var mTextX:ArtDisplay;
      
      private var mSpace:DisplayObject;
      
      private var mOwner:HeroGameObjectOwner;
      
      private var mIndex:int;
      
      private var mTooltip:StarlingTooltip;
      
      private var mWeaponTooltip:StarlingWeaponTooltip;
      
      private var mConsumableTooltip:MovieClip;
      
      private var mIcon:ArtView;
      
      private var mRarity:ArtView;
      
      private var mGeneration:uint;
      
      private var mRetries:Vector.<Function> = new Vector.<Function>(0);
      
      private var mFlashAmount:Number;
      
      private var mChanged:Function;
      
      private var mDestroyed:Boolean;
      
      private var mTooltipY:Number;
      
      private var mArt:ArtNode;
      
      private var mPath:String;
      
      public function StarlingHudSlot(facade:DBFacade, ticker:HudTicker, view:ArtView, path:String, space:DisplayObject, index:int, changed:Function)
      {
         var _loc8_:ArtDisplay = null;
         super();
         mFacade = facade;
         mTicker = ticker;
         mAssets = new AssetLoadingComponent(facade);
         mSpace = space;
         mIndex = index;
         mChanged = changed;
         mArt = view.artNode("");
         mPath = path;
         mButton = new StarlingButton(view,path,space);
         mRoot = mButton.root as ArtDisplay;
         mGraphic = view.node(path + ".graphic") as ArtDisplay;
         if(mRoot == null || mGraphic == null)
         {
            throw new HudFatalError("Required HUD slot art missing: " + path);
         }
         mSelection = view.node(path + ".selectionFrame") as ArtDisplay;
         mAuthoredTooltip = view.node(path + ".tooltip") as ArtDisplay;
         mCooldown = view.node(path + ".cooldown") as TimelineView;
         mQuantity = view.node(path + ".quantity") as StarlingText;
         mTextX = view.node(path + ".textx") as ArtDisplay;
         if(mGraphic.numChildren > 0)
         {
            _loc8_ = mGraphic.flashChild(0);
            if(_loc8_ != null)
            {
               mGraphic.removeArt(_loc8_);
               _loc8_.dispose();
            }
         }
         reset();
         mTooltipY = -mRoot.height * 0.5;
      }
      
      internal static function rarityEnabled(facade:DBFacade, rarity:Object) : Boolean
      {
         return rarity != null && rarity.HasColoredBackground && facade.featureFlags.getFlagValue("want-dynamic-rarity-backgrounds");
      }
      
      internal static function rarityKey(layout:ArtNode, swf:String, name:String) : String
      {
         return RarityArt.key(swf,name,HudArt.artSetScale(layout));
      }
      
      public function get button() : StarlingButton
      {
         return mButton;
      }
      
      public function set consumableTooltip(value:MovieClip) : void
      {
         mConsumableTooltip = value;
      }
      
      public function reset() : void
      {
         var _loc1_:Function = null;
         mGeneration = mGeneration + 1;
         for each(_loc1_ in mRetries)
         {
            mTicker.cancelBake(_loc1_);
         }
         mRetries.length = 0;
         mFacade.mTween.killTweensOf(this);
         mFacade.mTween.killTweensOf(mGraphic);
         flashAmount = 0;
         mGraphic.alpha = 1;
         mGraphic.scaleX = mGraphic.scaleY = 1;
         stopCooldown(false);
         if(mIcon != null)
         {
            mGraphic.removeArt(mIcon.root as ArtDisplay);
            mIcon.dispose();
         }
         if(mRarity != null)
         {
            mRarity.dispose();
         }
         mIcon = mRarity = null;
         if(mTooltip != null)
         {
            mTooltip.dispose();
         }
         if(mWeaponTooltip != null)
         {
            mWeaponTooltip.clearAllIcons();
         }
         mTooltip = null;
         if(mConsumableTooltip != null)
         {
            mConsumableTooltip.visible = false;
         }
         if(mSelection != null)
         {
            mSelection.setHudVisibility(false);
         }
         if(mAuthoredTooltip != null)
         {
            mAuthoredTooltip.setHudVisibility(false);
         }
         mButton.pressCallback = mButton.releaseCallback = mButton.pressRollOutCallback = null;
         mButton.rollOverCallback = mButton.rollOutCallback = null;
         mButton.enabled = true;
         mButton.upOnly = true;
         mButton.restartState();
         mButton.setHover(false);
         mButton.setPressed(false);
         mRoot.setGrayscale(false);
         if(mQuantity != null)
         {
            mQuantity.setContent("","glyphs");
            mQuantity.setHudVisibility(false);
         }
         if(mTextX != null)
         {
            mTextX.setHudVisibility(false);
         }
         mOwner = null;
      }
      
      public function equipWeapon(owner:HeroGameObjectOwner, weapon:WeaponGameObject) : void
      {
         reset();
         mOwner = owner;
         if(weapon == null)
         {
            return;
         }
         mButton.upOnly = false;
         mButton.pressCallback = weaponPressed;
         mButton.releaseCallback = weaponReleased;
         mButton.pressRollOutCallback = heldRollOut;
         loadWeaponTooltip(weapon);
         loadArt(weapon.weaponAesthetic.IconSwf,weapon.weaponAesthetic.IconName);
         var _loc3_:GMRarity = weapon.gmRarity;
         if(rarityEnabled(mFacade,_loc3_))
         {
            attachRarity(_loc3_.BackgroundSwf,_loc3_.BackgroundIcon);
         }
      }
      
      public function equipConsumable(owner:HeroGameObjectOwner, weapon:ConsumableWeaponGameObject) : void
      {
         reset();
         mOwner = owner;
         if(weapon == null)
         {
            return;
         }
         mButton.upOnly = false;
         mQuantity.setHudVisibility(true);
         mTextX.setHudVisibility(true);
         mQuantity.text = weapon.getConsumableCount().toString();
         mButton.releaseCallback = consumableReleased;
         TextUtil.setText(mConsumableTooltip.description_label,GameMasterLocale.getGameMasterSubString("STACKABLE_DESCRIPTION",weapon.getGMStackable().Constant));
         mTooltip = new StarlingTooltip(mFacade,mRoot,mSpace,mConsumableTooltip,0,new Point(mRoot.x,mRoot.y),true);
         mButton.rollOverCallback = mTooltip.rollOver;
         mButton.rollOutCallback = mTooltip.hide;
         loadArt(weapon.getGMStackable().UISwfFilepath,weapon.getGMStackable().IconName);
         if(weapon.getConsumableCount() == 0)
         {
            exhaust();
         }
      }
      
      private function weaponPressed() : void
      {
         if(mOwner == null)
         {
            return;
         }
         if(mOwner.currentWeaponIndex != mIndex)
         {
            mOwner.currentWeaponIndex = mIndex;
         }
         else
         {
            mOwner.PlayerAttack.addToPotentialWeaponInputQueue(mIndex,true,true);
         }
      }
      
      private function weaponReleased() : void
      {
         if(mOwner != null && mOwner.currentWeaponIndex == mIndex)
         {
            mOwner.PlayerAttack.addToPotentialWeaponInputQueue(mIndex,false,true);
         }
      }
      
      private function heldRollOut() : void
      {
         mButton.handPressToGame();
         mFacade.inputManager.onMouseDown(null);
      }
      
      private function consumableReleased() : void
      {
         if(mOwner != null)
         {
            mOwner.tryToUseConsumable(mIndex);
         }
      }
      
      private function loadWeaponTooltip(weapon:WeaponGameObject) : void
      {
         var generation:uint = mGeneration;
         var swf:String = "Resources/Art2D/UI/db_UI_town.swf";
         var name:String = WEAPON_TOOLTIPS[mIndex == 0 ? 0 : 1];
         HudArt.loadRuntimeSwf(mAssets,swf,name,function(param1:SwfAsset):void
         {
            if(mDestroyed || generation != mGeneration)
            {
               return;
            }
            var _loc2_:Class = HudArt.requireClass(param1,swf,name);
            if(mWeaponTooltip == null)
            {
               mWeaponTooltip = new StarlingWeaponTooltip(mFacade,_loc2_);
            }
            mWeaponTooltip.setWeaponItemFromWeaponGameObject(weapon);
            mTooltip = new StarlingTooltip(mFacade,mRoot,mSpace,mWeaponTooltip,0.4,new Point(0,mTooltipY));
            mButton.rollOverCallback = mTooltip.rollOver;
            mButton.rollOutCallback = mTooltip.hide;
         });
      }
      
      private function attachRarity(swf:String, name:String) : void
      {
         var _loc5_:String = rarityKey(mArt,swf,name);
         var _loc3_:ArtNode = RarityArt.request(mArt,_loc5_);
         var _loc4_:ArtView = ArtView.build(_loc3_,mTicker);
         ArtDisplay(_loc4_.root).advanceHiddenTimelines(true);
         _loc4_.root.scaleX = _loc4_.root.scaleY = 0.85;
         _loc4_.root.name = "rarityIcon";
         _loc4_.root.y -= 6;
         if(mRarity != null)
         {
            mRarity.dispose();
         }
         mRarity = _loc4_;
         mRoot.addAtFlashDepth(_loc4_.root,2);
         if(_loc4_.root is TimelineView)
         {
            TimelineView(_loc4_.root).play(0,true);
         }
         mChanged();
      }
      
      private function loadArt(swf:String, name:String) : void
      {
         var generation:uint = mGeneration;
         HudArt.loadRuntimeSwf(mAssets,swf,name,function(param1:SwfAsset):void
         {
            var symbol:Class;
            var scale:Number;
            var pixelScale:Number;
            var key:String;
            var source:MovieClip;
            var retry:Function;
            var asset:SwfAsset = param1;
            if(mDestroyed || generation != mGeneration)
            {
               return;
            }
            symbol = HudIconBake.symbol(asset,swf,name);
            TimelineMasks.register(asset);
            scale = 60 / DBGlobal.WEAPON_ICON_NATIVE_SIZE;
            pixelScale = BakeScale.forArt(mArt,mPath + ".graphic") * HudArt.pixelScale * scale;
            key = swf + "|" + name + "|" + scale + "|" + BakedPages.scaleKey(pixelScale);
            retry = function():Boolean
            {
               var _loc1_:ArtNode = null;
               var _loc2_:ArtView = null;
               try
               {
                  if(mDestroyed || generation != mGeneration)
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
                     if(source == null)
                     {
                        try
                        {
                           source = new symbol() as MovieClip;
                           if(source == null)
                           {
                              throw new Error("Required HUD slot icon is not a MovieClip");
                           }
                        }
                        catch(constructionError:*)
                        {
                           HudArt.runtimeAssetFailed(swf,name,constructionError);
                           return true;
                        }
                     }
                     _loc1_ = HudArtConverter.convert(source,HudArt.pages,pixelScale,{
                        "flatten":true,
                        "framePages":HudArt.framePages
                     });
                     HudArtConverter.stopTree(source);
                     if(_loc1_ == null || _loc1_.failures > 0)
                     {
                        if(_loc1_ != null)
                        {
                           _loc1_.release(HudArt.pages);
                        }
                        throw new Error("HUD slot rasterisation refused");
                     }
                     HudArt.storeContent(key,_loc1_);
                  }
                  _loc2_ = ArtView.build(_loc1_,mTicker);
                  ArtDisplay(_loc2_.root).advanceHiddenTimelines(true);
                  _loc2_.root.scaleX = _loc2_.root.scaleY = scale;
                  _loc2_.root.name = "weaponIcon";
                  mIcon = _loc2_;
                  mGraphic.addAtFlashDepth(_loc2_.root,0,true);
                  if(!mButton.enabled)
                  {
                     applyGrayscale();
                  }
                  source = null;
                  mRetries.removeAt(mRetries.indexOf(retry));
                  mChanged();
                  return true;
               }
               catch(error:Error)
               {
                  StarlingHud.reportError(error);
                  var _loc10_:Boolean = true;
               }
               return _loc10_;
            };
            mRetries.push(retry);
            if(!retry())
            {
               mTicker.deferBake(retry);
            }
         });
      }
      
      public function highlight(value:Boolean) : void
      {
         if(mSelection != null)
         {
            mSelection.setHudVisibility(value);
         }
      }
      
      public function startCooldown(seconds:Number, elapsed:Number = 0) : void
      {
         if(mCooldown == null)
         {
            return;
         }
         mCooldown.setHudVisibility(true);
         mCooldown.stageRate = false;
         mCooldown.playRate = 4.1 / seconds;
         mCooldown.play(Math.min(mCooldown.art.totalFrames - 1,24 * elapsed * mCooldown.playRate));
         mGraphic.alpha = 0.5;
         mChanged();
      }
      
      public function stopCooldown(flash:Boolean = true) : void
      {
         if(mCooldown != null)
         {
            mCooldown.stop();
            mCooldown.setHudVisibility(false);
         }
         mGraphic.alpha = 1;
         if(!flash)
         {
            return;
         }
         mFacade.mTween.tweenMaxTo(mGraphic,0.25,{
            "scaleX":1.25,
            "scaleY":1.25
         });
         mFacade.mTween.tweenMaxTo(this,0.25,{
            "flashAmount":1,
            "onComplete":flashBack
         });
      }
      
      private function flashBack() : void
      {
         try
         {
            mFacade.mTween.tweenMaxTo(mGraphic,0.25,{
               "scaleX":1,
               "scaleY":1
            });
            mFacade.mTween.tweenMaxTo(this,0.25,{"flashAmount":0});
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
      }
      
      public function get flashAmount() : Number
      {
         return mFlashAmount;
      }
      
      public function set flashAmount(value:Number) : void
      {
         try
         {
            mFlashAmount = value;
            mGraphic.tint(1 - value,1 - value,1 - value,255 * value,255 * value,255 * value);
            if(mChanged != null)
            {
               mChanged();
            }
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
      }
      
      public function decrement() : void
      {
         if(mQuantity != null)
         {
            mQuantity.text = String(int(mQuantity.text) - 1);
         }
         mChanged();
      }
      
      private function applyGrayscale() : void
      {
         if(!mRoot.setGrayscale(true))
         {
            throw new Error("HUD grayscale content refused");
         }
      }
      
      public function exhaust() : void
      {
         mButton.enabled = false;
         if(mTooltip != null)
         {
            mTooltip.hide();
         }
         applyGrayscale();
         mChanged();
      }
      
      public function hideTooltip() : void
      {
         if(mTooltip != null)
         {
            mTooltip.hide();
         }
      }
      
      public function dispose() : void
      {
         if(mDestroyed)
         {
            return;
         }
         mDestroyed = true;
         try
         {
            reset();
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
         StarlingHud.disposeResource(mIcon);
         StarlingHud.disposeResource(mRarity);
         StarlingHud.disposeResource(mTooltip);
         StarlingHud.disposeResource(mAssets,"destroy");
         StarlingHud.disposeResource(mWeaponTooltip,"destroy");
         mWeaponTooltip = null;
         StarlingHud.disposeResource(mButton);
         mConsumableTooltip = null;
         mFacade = null;
      }
   }
}

