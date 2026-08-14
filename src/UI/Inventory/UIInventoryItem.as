package UI.Inventory
{
   import Account.InventoryBaseInfo;
   import Account.ItemInfo;
   import Account.StackableInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderer;
   import Brain.UI.UIButton;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class UIInventoryItem extends UIButton
   {
      
      private var mInfo:InventoryBaseInfo;
      
      private var mDBFacade:DBFacade;
      
      private var mIcon:MovieClip;
      
      private var mNewLabel:TextField;
      
      private var mStackCountLabel:TextField;
      
      private var mSelectedEffect:MovieClip;
      
      private var mWeaponTooltip:UIWeaponTooltip;
      
      private var mClickedCallback:Function;
      
      private var mDragDelay:uint;
      
      private var mDragDelayTask:Task;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mEquippable:uint;
      
      private var mParentSlot:MovieClip;
      
      private var mRenderer:MovieClipRenderer;
      
      public function UIInventoryItem(dbFacade:DBFacade, parentSlot:MovieClip, templateClass:Class, tooltipClass:Class, clickedCallback:Function)
      {
         super(dbFacade,new templateClass());
         mDBFacade = dbFacade;
         mParentSlot = parentSlot;
         mClickedCallback = clickedCallback;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mParentSlot.addChild(mRoot);
         mIcon = mRoot.icon;
         mNewLabel = mRoot.new_label;
         mStackCountLabel = mRoot.number_label;
         mStackCountLabel.visible = false;
         mSelectedEffect = mRoot.selected_effect;
         mSelectedEffect.visible = false;
         mWeaponTooltip = new UIWeaponTooltip(mDBFacade,tooltipClass);
         this.tooltip = mWeaponTooltip;
         this.tooltipPos = new Point(0,this.root.height * -0.4);
         mWeaponTooltip.visible = false;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIInventoryItem");
         mPressCallback = function():void
         {
            mClickedCallback(mInfo);
         };
         equippable = mEquippable;
         this.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
      }
      
      override public function destroy() : void
      {
         if(mRenderer)
         {
            mRenderer.destroy();
         }
         mRenderer = null;
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mPressCallback = null;
         if(mWeaponTooltip)
         {
            mWeaponTooltip.destroy();
         }
         mDBFacade = null;
         super.destroy();
      }
      
      public function set info(info:InventoryBaseInfo) : void
      {
         var _loc3_:ItemInfo = null;
         var _loc2_:* = 0;
         mInfo = info;
         while(mIcon.numChildren)
         {
            mIcon.removeChildAt(0);
         }
         mWeaponTooltip.visible = false;
         mStackCountLabel.visible = false;
         if(mInfo != null)
         {
            loadItemIcon();
            mNewLabel.visible = mInfo.isNew;
            mNewLabel.text = Locale.getString("INV_NEW");
            this.enabled = true;
            _loc3_ = mInfo as ItemInfo;
            if(_loc3_ && _loc3_.gmWeaponItem)
            {
               mWeaponTooltip.setWeaponItemFromItemInfo(_loc3_);
               mWeaponTooltip.visible = true;
            }
            if(mInfo as StackableInfo)
            {
               _loc2_ = uint(StackableInfo(mInfo).count);
               mStackCountLabel.text = "x" + _loc2_.toString();
               mStackCountLabel.visible = true;
            }
         }
         else
         {
            this.enabled = false;
         }
      }
      
      public function get info() : InventoryBaseInfo
      {
         return mInfo;
      }
      
      public function dragSwapItem(item:InventoryBaseInfo) : void
      {
         reset();
         mParentSlot.addChild(mRoot);
         info = item;
      }
      
      private function loadItemIcon() : void
      {
         var bgColoredExists:Boolean = mInfo.hasColoredBackground;
         var bgSwfPath:String = mInfo.backgroundSwfPath;
         var bgIconName:String = mInfo.backgroundIconName;
         var swfPath:String = mInfo.uiSwfFilepath;
         var iconName:String = mInfo.iconName;
         var needsRenderer:Boolean = mInfo.needsRenderer;
         while(mIcon.numChildren)
         {
            mIcon.removeChildAt(0);
         }
         if(swfPath && iconName)
         {
            if(bgColoredExists && mDBFacade.featureFlags.getFlagValue("want-dynamic-rarity-backgrounds"))
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset):void
               {
                  var _loc3_:MovieClip = null;
                  var _loc2_:Class = param1.getClass(bgIconName);
                  if(_loc2_)
                  {
                     _loc3_ = new _loc2_() as MovieClip;
                     mIcon.addChild(_loc3_);
                  }
               });
            }
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
            {
               var _loc2_:MovieClip = null;
               var _loc3_:Class = param1.getClass(iconName);
               if(_loc3_)
               {
                  _loc2_ = new _loc3_();
                  _loc2_.scaleX = _loc2_.scaleY = 72 / mInfo.iconScale;
                  mIcon.addChild(_loc2_);
                  if(needsRenderer)
                  {
                     mRenderer = new MovieClipRenderer(mDBFacade,_loc2_);
                     mRenderer.play(0,true);
                  }
               }
               else
               {
                  Logger.warn("Missing icon: " + iconName);
               }
            });
         }
         else
         {
            Logger.error("Missing IconName or UISwfFilepath for GMItem: " + mInfo.gmId);
         }
      }
      
      override public function set enabled(value:Boolean) : void
      {
         super.enabled = value;
         equippable = value ? 1 : 3;
      }
      
      public function set equippable(value:uint) : void
      {
         mEquippable = value;
         switch(int(mEquippable) - 1)
         {
            case 0:
               mDraggable = true;
               mRoot.unequippable.visible = false;
               mRoot.unusable.visible = false;
               break;
            case 1:
               mDraggable = false;
               mRoot.unequippable.visible = true;
               mRoot.unusable.visible = false;
               break;
            case 2:
               mDraggable = false;
               mRoot.unequippable.visible = true;
               mRoot.unusable.visible = true;
         }
      }
      
      public function get equippable() : uint
      {
         return mEquippable;
      }
      
      public function reset() : void
      {
         mRoot.x = mDragStartPos.x;
         mRoot.y = mDragStartPos.y;
         while(mIcon.numChildren)
         {
            mIcon.removeChildAt(0);
         }
      }
      
      public function select() : void
      {
         mSelectedEffect.visible = true;
      }
      
      public function deSelect() : void
      {
         mSelectedEffect.visible = false;
      }
      
      override protected function startDrag() : void
      {
         this.deSelect();
         super.startDrag();
      }
   }
}

