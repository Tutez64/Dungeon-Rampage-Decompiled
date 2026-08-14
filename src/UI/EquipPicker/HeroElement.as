package UI.EquipPicker
{
   import Account.AvatarInfo;
   import Account.ItemInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderController;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.ColorMatrix;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMSkin;
   import GameMasterDictionary.GMWeaponItem;
   import UI.Inventory.UIHeroTooltip;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class HeroElement extends UIButton
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mHeroTooltip:UIHeroTooltip;
      
      private var mHeroClicked:Function;
      
      private var mGMHero:GMHero;
      
      private var mIcon:MovieClip;
      
      private var mOverlay:MovieClip;
      
      private var mWeaponUnusable:MovieClip;
      
      private var mWeaponWeaker:MovieClip;
      
      private var mWeaponStronger:MovieClip;
      
      private var mAlert:MovieClip;
      
      private var mAlertRenderer:MovieClipRenderController;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mContainerHeight:uint;
      
      protected var mContainerWidth:uint;
      
      public function HeroElement(dbFacade:DBFacade, root:MovieClip, tooltipClass:Class, heroClicked:Function)
      {
         super(dbFacade,root);
         mDBFacade = dbFacade;
         mHeroClicked = heroClicked;
         this.releaseCallbackThis = function(param1:UIButton):void
         {
            mHeroClicked(param1,owned);
         };
         mOverlay = mRoot.overlay;
         mOverlay.visible = false;
         mWeaponUnusable = mRoot.unusable;
         mWeaponWeaker = mRoot.arrow_down;
         mWeaponStronger = mRoot.arrow_up;
         hideWeaponComparison();
         mAlert = mRoot.alert_icon;
         mAlertRenderer = new MovieClipRenderController(dbFacade,mAlert);
         mAlertRenderer.play(0,true);
         mAlert.visible = false;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mContainerHeight = mRoot.height;
         mContainerWidth = mRoot.width;
         this.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mHeroTooltip = new UIHeroTooltip(mDBFacade,tooltipClass);
         this.tooltip = mHeroTooltip;
         this.tooltipPos = new Point(0,this.root.height * -0.5);
         mHeroTooltip.visible = false;
      }
      
      override public function destroy() : void
      {
         mHeroTooltip.destroy();
         mHeroClicked = null;
         if(mAlertRenderer != null)
         {
            mAlertRenderer.destroy();
            mAlertRenderer = null;
         }
         mAssetLoadingComponent.destroy();
         mDBFacade = null;
         super.destroy();
      }
      
      public function showWeaponComparison(gmWeaponItem:GMWeaponItem, power:uint) : void
      {
         var _loc4_:Boolean = false;
         var _loc6_:* = undefined;
         if(!mGMHero)
         {
            return;
         }
         var _loc3_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mGMHero.Id);
         var _loc5_:Boolean = mGMHero.AllowedWeapons.hasKey(gmWeaponItem.MasterType);
         if(_loc5_)
         {
            mWeaponUnusable.visible = false;
            _loc4_ = true;
            if(_loc3_)
            {
               _loc6_ = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(_loc3_.id);
               for each(var _loc7_:ItemInfo in _loc6_)
               {
                  if(_loc7_.gmWeaponItem.MasterType == gmWeaponItem.MasterType && _loc7_.power >= power)
                  {
                     _loc4_ = false;
                     break;
                  }
               }
            }
            mWeaponWeaker.visible = !_loc4_;
            mWeaponStronger.visible = _loc4_;
         }
         else
         {
            mWeaponUnusable.visible = true;
            mWeaponWeaker.visible = false;
            mWeaponStronger.visible = false;
         }
      }
      
      public function hideWeaponComparison() : void
      {
         mWeaponUnusable.visible = false;
         mWeaponWeaker.visible = false;
         mWeaponStronger.visible = false;
      }
      
      public function set alert(val:Boolean) : void
      {
         mAlert.visible = val;
      }
      
      public function set gmHero(hero:GMHero) : void
      {
         var _loc2_:AvatarInfo = null;
         var _loc3_:ColorMatrix = null;
         mGMHero = hero;
         var _loc4_:Boolean = this.owned;
         loadHeroIcon();
         if(_loc4_)
         {
            mRoot.filters = [];
            _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mGMHero.Id);
            mHeroTooltip.ownedHero = _loc2_;
         }
         else
         {
            _loc3_ = new ColorMatrix();
            _loc3_.adjustSaturation(0.1);
            _loc3_.adjustBrightness(-64);
            _loc3_.adjustContrast(-0.5);
            mRoot.filters = [_loc3_.filter];
            mHeroTooltip.unownedHero = mGMHero;
         }
         mHeroTooltip.visible = true;
      }
      
      public function get gmHero() : GMHero
      {
         return mGMHero;
      }
      
      private function get owned() : Boolean
      {
         return mGMHero ? mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(mGMHero.Id) : false;
      }
      
      private function loadHeroIcon() : void
      {
         var gmSkin:GMSkin;
         var swfPath:String;
         var iconName:String;
         var avatarInfo:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mGMHero.Id);
         if(avatarInfo == null)
         {
            gmSkin = mDBFacade.gameMaster.getSkinByConstant(mGMHero.DefaultSkin);
         }
         else
         {
            gmSkin = mDBFacade.gameMaster.getSkinByType(avatarInfo.skinId);
         }
         swfPath = gmSkin.UISwfFilepath;
         iconName = gmSkin.IconName;
         if(mIcon != null && mRoot.contains(mIcon))
         {
            mRoot.removeChild(mIcon);
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass(iconName);
            mIcon = new _loc3_();
            var _loc2_:uint = mContainerWidth < mContainerHeight ? mContainerWidth : mContainerHeight;
            UIObject.scaleToFit(mIcon,_loc2_);
            mRoot.addChildAt(mIcon,0);
            mIcon.scaleX *= 0.96;
            mIcon.scaleY *= 0.96;
         });
      }
      
      public function clear() : void
      {
         if(mIcon != null && mRoot.contains(mIcon))
         {
            mRoot.removeChild(mIcon);
         }
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
      }
      
      public function select() : void
      {
         mRoot.scaleX = 1.25;
         mRoot.scaleY = 1.25;
      }
      
      public function deselect() : void
      {
         mRoot.scaleX = 1;
         mRoot.scaleY = 1;
      }
   }
}

