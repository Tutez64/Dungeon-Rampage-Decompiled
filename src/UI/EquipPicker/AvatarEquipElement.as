package UI.EquipPicker
{
   import Account.InventoryBaseInfo;
   import Account.ItemInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import UI.Inventory.UIWeaponTooltip;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class AvatarEquipElement extends UIButton
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mItemInfo:InventoryBaseInfo;
      
      private var mIcon:MovieClip;
      
      private var mWeaponTooltip:UIWeaponTooltip;
      
      protected var mContainerHeight:uint;
      
      protected var mContainerWidth:uint;
      
      protected var mUnequipCallback:Function;
      
      private var mHandleDropCallback:Function;
      
      protected var mEquipSlot:uint;
      
      protected var mEquipResponseCallback:Function;
      
      private var mClickedEquipedWeaponCallback:Function;
      
      private var mAllowEquipmentSwapping:Boolean;
      
      public function AvatarEquipElement(dbFacade:DBFacade, keyLabel:String, root:MovieClip, tooltipClass:Class, unequipCallback:Function, handleDropCallback:Function, equipSlot:uint, clickedEquipedWeaponCallback:Function = null, equipResponseCallback:Function = null, allowEquipmentSwapping:Boolean = false)
      {
         super(dbFacade,root);
         this.label.text = keyLabel;
         this.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mDBFacade = dbFacade;
         mUnequipCallback = unequipCallback;
         mHandleDropCallback = handleDropCallback;
         mEquipSlot = equipSlot;
         mEquipResponseCallback = equipResponseCallback;
         mClickedEquipedWeaponCallback = clickedEquipedWeaponCallback;
         mAllowEquipmentSwapping = allowEquipmentSwapping;
         draggable = false;
         mContainerHeight = mRoot.frame.height;
         mContainerWidth = mRoot.frame.width;
         mWeaponTooltip = new UIWeaponTooltip(mDBFacade,tooltipClass);
         this.tooltip = mWeaponTooltip;
         this.tooltipPos = new Point(0,this.root.height * -0.5);
         mWeaponTooltip.visible = false;
         mRoot.selected.visible = false;
         setupClickedCallback();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mRoot.frame.alpha = 0;
      }
      
      override public function destroy() : void
      {
         mDBFacade = null;
         mItemInfo = null;
         mHandleDropCallback = null;
         mUnequipCallback = null;
         mAssetLoadingComponent.destroy();
         mEquipResponseCallback = null;
         mWeaponTooltip.destroy();
         super.destroy();
      }
      
      public function get itemInfo() : InventoryBaseInfo
      {
         return mItemInfo;
      }
      
      public function get equipSlot() : uint
      {
         return mEquipSlot;
      }
      
      public function set itemInfo(info:InventoryBaseInfo) : void
      {
         var _loc2_:ItemInfo = null;
         clear();
         mItemInfo = info;
         if(mItemInfo != null)
         {
            mRoot.frame.alpha = 1;
            loadItemIcon();
            _loc2_ = mItemInfo as ItemInfo;
            if(_loc2_)
            {
               mWeaponTooltip.setWeaponItemFromItemInfo(_loc2_);
               mWeaponTooltip.visible = true;
            }
            draggable = true;
         }
         else
         {
            mRoot.frame.alpha = 0;
            draggable = false;
         }
      }
      
      override public function set draggable(value:Boolean) : void
      {
         if(mAllowEquipmentSwapping)
         {
            super.draggable = value;
         }
         else
         {
            super.draggable = false;
         }
      }
      
      private function setupClickedCallback() : void
      {
         this.releaseCallbackThis = function(param1:UIButton):void
         {
            if(mClickedEquipedWeaponCallback != null)
            {
               mClickedEquipedWeaponCallback(param1);
            }
         };
      }
      
      protected function loadItemIcon() : void
      {
         var swfPath:String = mItemInfo.uiSwfFilepath;
         var iconName:String = mItemInfo.iconName;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
         {
            var bgColoredExists:Boolean;
            var bgSwfPath:String;
            var bgIconName:String;
            var swfAsset:SwfAsset = param1;
            var iconClass:Class = swfAsset.getClass(iconName);
            if(iconClass == null)
            {
               Logger.error("Unable to find iconClass of name: " + iconName);
            }
            else
            {
               mIcon = new iconClass();
               mIcon.scaleX = mIcon.scaleY = 60 / mItemInfo.iconScale;
               mRoot.graphic.addChild(mIcon);
            }
            bgColoredExists = mItemInfo.hasColoredBackground;
            bgSwfPath = mItemInfo.backgroundSwfPath;
            bgIconName = mItemInfo.backgroundIconName;
            if(bgColoredExists)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset):void
               {
                  var _loc3_:MovieClip = null;
                  var _loc2_:Class = param1.getClass(bgIconName);
                  if(_loc2_)
                  {
                     _loc3_ = new _loc2_() as MovieClip;
                     _loc3_.scaleX = _loc3_.scaleY = 0.85;
                     mRoot.graphic.addChildAt(_loc3_,0);
                  }
               });
            }
         });
      }
      
      public function reset() : void
      {
         super.resetDrag();
      }
      
      override protected function resetDrag() : void
      {
         super.resetDrag();
         resetDragUnequipFunc();
      }
      
      protected function resetDragUnequipFunc() : void
      {
         mUnequipCallback(mItemInfo,mEquipResponseCallback);
      }
      
      override public function handleDrop(dropObject:UIObject) : Boolean
      {
         return mHandleDropCallback(dropObject,mItemInfo,mEquipSlot);
      }
      
      public function clear() : void
      {
         while(mRoot.graphic.numChildren > 0)
         {
            mRoot.graphic.removeChildAt(0);
         }
         mItemInfo = null;
         draggable = false;
         mRoot.frame.alpha = 0;
         mWeaponTooltip.visible = false;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
      }
      
      public function select() : void
      {
         this.root.selected.visible = true;
      }
      
      public function deselect() : void
      {
         this.root.selected.visible = false;
      }
   }
}

