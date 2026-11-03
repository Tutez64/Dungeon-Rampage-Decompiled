package UI.Inventory
{
   import Account.AvatarInfo;
   import Account.InventoryBaseInfo;
   import Account.ItemInfo;
   import Account.StackableInfo;
   import Brain.AssetRepository.ImageAsset;
   import Brain.AssetRepository.SwfAsset;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.TextUtil;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import UI.Popup.DBUIOneButtonPopup;
   import UI.Popup.DBUIPopup;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class EquipItemToSlotPopup extends DBUIPopup
   {
      
      private static const POPUP_SWF_PATH:String = "Resources/Art2D/UI/db_UI_town.swf";
      
      private static const EQUIP_POPUP_CLASS_NAME:String = "popup_equip";
      
      private static const CONTROLLER_GLYPH_X:Number = 13;
      
      private static const CONTROLLER_GLYPH_Y:Number = -50;
      
      private static const CONTROLLER_GLYPH_SCALE:Number = 0.2;
      
      private var mAvatarInstanceId:int;
      
      private var mClosePopupCallback:Function;
      
      private var mNotAllowedCallback:Function;
      
      private var mItemInfoToEquip:InventoryBaseInfo;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      private var mEquipPopupRoot:MovieClip;
      
      private var mTitleLabel:TextField;
      
      private var mMessageLabel:TextField;
      
      private var mEquipSlot0:UIButton;
      
      private var mEquipSlot1:UIButton;
      
      private var mEquipSlot2:UIButton;
      
      private var mEquipSlot0Tooltip:UIWeaponTooltip;
      
      private var mEquipSlot1Tooltip:UIWeaponTooltip;
      
      private var mEquipSlot2Tooltip:UIWeaponTooltip;
      
      private var mIsConsumable:Boolean;
      
      public function EquipItemToSlotPopup(dbFacade:DBFacade, avatarInstanceId:int, closePopupCallback:Function, itemInfoToEquip:InventoryBaseInfo, notAllowedCallback:Function = null, isConsumable:Boolean = false)
      {
         mDBFacade = dbFacade;
         mAvatarInstanceId = avatarInstanceId;
         mClosePopupCallback = closePopupCallback;
         mNotAllowedCallback = notAllowedCallback;
         mItemInfoToEquip = itemInfoToEquip;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"EquipItemToSlotPopup");
         mIsConsumable = isConsumable;
         super(dbFacade,"EQUIP_ITEM_TO_SLOT_POPUP","",null,true,true,closePopupCallback,false);
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         mSwfAsset = swfAsset;
         var _loc7_:Class = swfAsset.getClass("popup_equip");
         mEquipPopupRoot = new _loc7_();
         mCloseButton = new UIButton(mDBFacade,mEquipPopupRoot.close);
         mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mCloseButton.releaseCallback = mClosePopupCallback;
         mRoot.addChild(mEquipPopupRoot);
         mTitleLabel = mEquipPopupRoot.title_label as TextField;
         Locale.setText(mTitleLabel,"EQUIP_POPUP_TITLE");
         mMessageLabel = mEquipPopupRoot.message_label as TextField;
         Locale.setText(mMessageLabel,"EQUIP_POPUP_MESSAGE");
         mEquipPopupRoot.UI_weapons.visible = false;
         mEquipPopupRoot.UI_potions.visible = false;
         mEquipPopupRoot.UI_pets.visible = false;
         mSceneGraphComponent.addChild(mRoot,105);
         refresh();
         mRoot.scaleY = mRoot.scaleX = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
         var _loc6_:Rectangle = mRoot.getBounds(mDBFacade.scalingRoot);
         mRoot.x = mDBFacade.viewWidth / 2 - _loc6_.width / 2 - _loc6_.x;
         mRoot.y = mDBFacade.viewHeight / 2 - _loc6_.height / 2 - _loc6_.y;
         setupControllerGlyphs();
      }
      
      private function refresh() : void
      {
         if(mEquipPopupRoot == null)
         {
            return;
         }
         if(mAvatarInstanceId != -1)
         {
            if(mIsConsumable)
            {
               refreshAvatarConsumableSlots();
            }
            else
            {
               refreshAvatarWeaponSlots();
            }
         }
      }
      
      private function refreshAvatarConsumableSlots() : void
      {
         var equippedItem:StackableInfo;
         var equippedItemInfo0:StackableInfo;
         var equippedItemInfo1:StackableInfo;
         var avatarInfo:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForAvatarInstanceId(mAvatarInstanceId);
         var equippedItems:Vector.<StackableInfo> = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedConsumablesOnAvatar(avatarInfo);
         var i:uint = 0;
         while(i < equippedItems.length)
         {
            equippedItem = equippedItems[i];
            switch(equippedItem.consumableSlot)
            {
               case 0:
                  equippedItemInfo0 = equippedItem;
                  break;
               case 1:
                  equippedItemInfo1 = equippedItem;
            }
            i = i + 1;
         }
         mEquipPopupRoot.UI_potions.visible = true;
         mEquipSlot0 = new UIButton(mDBFacade,mEquipPopupRoot.UI_potions.equip_slot_0);
         mEquipSlot0.label.visible = true;
         mEquipSlot0.label.text = mDBFacade.keyBindings.displayNameFor("useConsumable1");
         mEquipSlot0.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mEquipSlot0.root.selected.visible = false;
         mEquipSlot0.root.quantity.visible = false;
         mEquipSlot0.root.textx.visible = false;
         mEquipSlot0.releaseCallback = function():void
         {
            equipToAvatarConsumableSlot(0);
         };
         if(equippedItemInfo0 != null)
         {
            ItemInfo.loadItemIconFromId(equippedItemInfo0.gmId,mEquipSlot0.root.graphic,mDBFacade,70,equippedItemInfo0.iconScale,mAssetLoadingComponent);
            mEquipSlot0.root.quantity.visible = true;
            TextUtil.setText(mEquipSlot0.root.quantity,equippedItemInfo0.count.toString());
            mEquipSlot0.root.textx.visible = true;
         }
         mEquipSlot1 = new UIButton(mDBFacade,mEquipPopupRoot.UI_potions.equip_slot_1);
         mEquipSlot1.label.visible = true;
         mEquipSlot1.label.text = mDBFacade.keyBindings.displayNameFor("useConsumable2");
         mEquipSlot1.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mEquipSlot1.root.selected.visible = false;
         mEquipSlot1.root.quantity.visible = false;
         mEquipSlot1.root.textx.visible = false;
         mEquipSlot1.releaseCallback = function():void
         {
            equipToAvatarConsumableSlot(1);
         };
         if(equippedItemInfo1 != null)
         {
            ItemInfo.loadItemIconFromId(equippedItemInfo1.gmId,mEquipSlot1.root.graphic,mDBFacade,70,equippedItemInfo1.iconScale,mAssetLoadingComponent);
            mEquipSlot1.root.quantity.visible = true;
            TextUtil.setText(mEquipSlot1.root.quantity,equippedItemInfo1.count.toString());
            mEquipSlot1.root.textx.visible = true;
         }
         animatedEntrance();
      }
      
      override protected function setupMenuNavigation() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:Vector.<UIButton> = getEquipSlots();
         if(_loc2_.length == 0)
         {
            return;
         }
         mCloseButton.clearNavigationAndInteractions();
         mCloseButton.downNavigation = _loc2_[0];
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            _loc2_[_loc1_].clearNavigationAndInteractions();
            _loc2_[_loc1_].upNavigation = mCloseButton;
            if(_loc1_ > 0)
            {
               _loc2_[_loc1_ - 1].isToTheLeftOf(_loc2_[_loc1_]);
            }
            _loc1_++;
         }
      }
      
      override protected function getNavigationExitCallback() : Function
      {
         return mClosePopupCallback;
      }
      
      override protected function getInitialFocusedNavigationObject() : UIObject
      {
         var _loc1_:Vector.<UIButton> = getEquipSlots();
         return _loc1_.length > 0 ? _loc1_[0] : mCloseButton;
      }
      
      private function setupControllerGlyphs() : void
      {
         var _loc1_:uint = 0;
         if(!mDBFacade.steamInputManager.isSteamInputReady)
         {
            return;
         }
         var _loc2_:Vector.<UIButton> = getEquipSlots();
         var _loc3_:Vector.<String> = new Vector.<String>();
         if(mIsConsumable)
         {
            _loc3_.push("use_consumable_one");
            _loc3_.push("use_consumable_two");
         }
         else
         {
            _loc3_.push("attack_weapon_1");
            _loc3_.push("attack_weapon_2");
            _loc3_.push("attack_weapon_3");
         }
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length && _loc1_ < _loc3_.length)
         {
            loadControllerGlyph(_loc2_[_loc1_],_loc3_[_loc1_]);
            _loc1_++;
         }
      }
      
      private function loadControllerGlyph(equipSlot:UIButton, actionName:String) : void
      {
         var glyphFilePath:String = mDBFacade.steamInputManager.getGlyphFilePathForAction(actionName);
         if(glyphFilePath == null || glyphFilePath == "" || glyphFilePath == "error1")
         {
            return;
         }
         mAssetLoadingComponent.getImageAsset(glyphFilePath,function(param1:ImageAsset):void
         {
            if(param1 == null || equipSlot == null || equipSlot.root == null)
            {
               return;
            }
            var _loc2_:Bitmap = param1.image as Bitmap;
            var _loc3_:DisplayObject = new Bitmap(_loc2_.bitmapData);
            _loc3_.x = 13;
            _loc3_.y = -50;
            _loc3_.scaleX = _loc3_.scaleY = 0.2;
            equipSlot.label.visible = false;
            equipSlot.root.addChild(_loc3_);
         },null,false);
      }
      
      private function getEquipSlots() : Vector.<UIButton>
      {
         var _loc1_:Vector.<UIButton> = new Vector.<UIButton>();
         if(mEquipSlot0 != null)
         {
            _loc1_.push(mEquipSlot0);
         }
         if(mEquipSlot1 != null)
         {
            _loc1_.push(mEquipSlot1);
         }
         if(mEquipSlot2 != null)
         {
            _loc1_.push(mEquipSlot2);
         }
         return _loc1_;
      }
      
      private function refreshAvatarWeaponSlots() : void
      {
         var equippedItems:Vector.<ItemInfo>;
         var equippedItem:ItemInfo;
         var equippedItemInfo0:ItemInfo;
         var equippedItemInfo1:ItemInfo;
         var equippedItemInfo2:ItemInfo;
         var i:uint;
         mEquipPopupRoot.UI_weapons.visible = true;
         equippedItems = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mAvatarInstanceId);
         i = 0;
         while(i < equippedItems.length)
         {
            equippedItem = equippedItems[i];
            switch(int(equippedItem.avatarSlot))
            {
               case 0:
                  equippedItemInfo0 = equippedItem;
                  break;
               case 1:
                  equippedItemInfo1 = equippedItem;
                  break;
               case 2:
                  equippedItemInfo2 = equippedItem;
            }
            i = i + 1;
         }
         if(mEquipSlot0 == null)
         {
            mEquipSlot0 = new UIButton(mDBFacade,mEquipPopupRoot.UI_weapons.equip_slot_0);
         }
         mEquipSlot0.label.text = "J";
         mEquipSlot0.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mEquipSlot0.root.selected.visible = false;
         mEquipSlot0.releaseCallback = function():void
         {
            equipToAvatarWeaponSlot(0);
         };
         if(equippedItemInfo0 != null)
         {
            ItemInfo.loadItemIconFromItemInfo(equippedItemInfo0,mEquipSlot0.root.graphic,mDBFacade,70,equippedItemInfo0.iconScale,mAssetLoadingComponent);
            if(mEquipSlot0Tooltip == null)
            {
               mEquipSlot0Tooltip = new UIWeaponTooltip(mDBFacade,mSwfAsset.getClass("DR_weapon_equip_tooltip"));
               mEquipSlot0.tooltip = mEquipSlot0Tooltip;
            }
            mEquipSlot0Tooltip.setWeaponItemFromItemInfo(equippedItemInfo0);
         }
         if(mEquipSlot1 == null)
         {
            mEquipSlot1 = new UIButton(mDBFacade,mEquipPopupRoot.UI_weapons.equip_slot_1);
         }
         mEquipSlot1.label.text = "K";
         mEquipSlot1.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mEquipSlot1.root.selected.visible = false;
         mEquipSlot1.releaseCallback = function():void
         {
            equipToAvatarWeaponSlot(1);
         };
         if(equippedItemInfo1 != null)
         {
            ItemInfo.loadItemIconFromItemInfo(equippedItemInfo1,mEquipSlot1.root.graphic,mDBFacade,70,equippedItemInfo1.iconScale,mAssetLoadingComponent);
            if(mEquipSlot1Tooltip == null)
            {
               mEquipSlot1Tooltip = new UIWeaponTooltip(mDBFacade,mSwfAsset.getClass("DR_weapon_equip_tooltip"));
               mEquipSlot1.tooltip = mEquipSlot1Tooltip;
            }
            mEquipSlot1Tooltip.setWeaponItemFromItemInfo(equippedItemInfo1);
         }
         if(mEquipSlot2 == null)
         {
            mEquipSlot2 = new UIButton(mDBFacade,mEquipPopupRoot.UI_weapons.equip_slot_2);
         }
         mEquipSlot2.label.text = "L";
         mEquipSlot2.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mEquipSlot2.root.selected.visible = false;
         mEquipSlot2.releaseCallback = function():void
         {
            equipToAvatarWeaponSlot(2);
         };
         if(equippedItemInfo2 != null)
         {
            ItemInfo.loadItemIconFromItemInfo(equippedItemInfo2,mEquipSlot2.root.graphic,mDBFacade,70,equippedItemInfo2.iconScale,mAssetLoadingComponent);
            if(mEquipSlot2Tooltip == null)
            {
               mEquipSlot2Tooltip = new UIWeaponTooltip(mDBFacade,mSwfAsset.getClass("DR_weapon_equip_tooltip"));
               mEquipSlot2.tooltip = mEquipSlot2Tooltip;
            }
            mEquipSlot2Tooltip.setWeaponItemFromItemInfo(equippedItemInfo2);
         }
         animatedEntrance();
      }
      
      private function showNotAllowedPopup() : void
      {
         var closePopup:Function = function():void
         {
            if(popup != null)
            {
               popup.destroy();
               popup = null;
            }
         };
         var popup:DBUIOneButtonPopup = new DBUIOneButtonPopup(mDBFacade,"EQUIP_ITEM_NOT_ALLOWED_POPUP",Locale.getString("STACK_NOT_ALLOWED_TITLE"),Locale.getString("STACK_NOT_ALLOWED_MESSAGE"),Locale.getString("CANCEL"),function():void
         {
            if(mNotAllowedCallback != null)
            {
               mNotAllowedCallback();
            }
            closePopup();
         },true,closePopup);
         MemoryTracker.track(popup,"DBUIOneButtonPopup - created in EquipItemToSlotPopup.showNotAllowedPopup()");
      }
      
      private function equipToAvatarWeaponSlot(slotIndex:uint) : void
      {
         mDBFacade.dbAccountInfo.inventoryInfo.equipItemOnAvatar(mAvatarInstanceId,mItemInfoToEquip.databaseId,slotIndex,mClosePopupCallback);
      }
      
      private function equipToAvatarConsumableSlot(slotIndex:uint) : void
      {
         var _loc2_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForAvatarInstanceId(mAvatarInstanceId);
         var _loc3_:StackableInfo = mItemInfoToEquip as StackableInfo;
         if(mDBFacade.dbAccountInfo.inventoryInfo.canEquipThisConsumable(_loc2_,slotIndex,_loc3_.gmId))
         {
            mDBFacade.dbAccountInfo.inventoryInfo.equipConsumableOnAvatar(mAvatarInstanceId,_loc3_.gmStackable.Id,slotIndex,false,mClosePopupCallback);
         }
         else
         {
            showNotAllowedPopup();
         }
      }
      
      override public function destroy() : void
      {
         if(mEquipSlot0 != null)
         {
            mEquipSlot0.destroy();
         }
         if(mEquipSlot1 != null)
         {
            mEquipSlot1.destroy();
         }
         if(mEquipSlot2 != null)
         {
            mEquipSlot2.destroy();
         }
         mEquipSlot0 = null;
         mEquipSlot1 = null;
         mEquipSlot2 = null;
         mSceneGraphComponent.destroy();
         super.destroy();
      }
   }
}

