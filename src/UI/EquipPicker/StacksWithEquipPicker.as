package UI.EquipPicker
{
   import Account.AvatarInfo;
   import Account.Consumable;
   import Account.InventoryBaseInfo;
   import Account.StackableInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.ImageAsset;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.MemoryTracker;
   import DBGlobals.DBGlobal;
   import Events.DBAccountResponseEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMStackable;
   import UI.ControllerIconData;
   import UI.Inventory.UIInventoryItem;
   import UI.Popup.DBUIOneButtonPopup;
   import UI.Popup.DBUIPopup;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   public class StacksWithEquipPicker extends UIObject
   {
      
      private static const CONTROLLER_ICON_POSITION_FOR_STACK_BUTTONS:Vector3D = new Vector3D(13,-50);
      
      private static const CONTROLLER_GLYPH_SCALE_STACK_BUTTONS:Point = new Point(20,20);
      
      protected var mDBFacade:DBFacade;
      
      protected var mEventComponent:EventComponent;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mHeroSlots:Vector.<HeroElement>;
      
      private var mEquipElements:Vector.<ConsumableEquipElement>;
      
      private var mEquipSlots:Vector.<EquipSlot>;
      
      private var mClickedEquippedWeaponCallback:Function;
      
      private var mCurrentStartIndex:uint = 0;
      
      private var mFirstSlotLeftNavigation:UIObject;
      
      private var mEquipResponseCallback:Function;
      
      private var mSetSelectedHeroCallback:Function;
      
      private var mGetSelectedHeroCallback:Function;
      
      private var mSelectedHeroIndex:int = -1;
      
      private var mTotalGMHeroes:uint;
      
      private var mShiftLeft:UIButton;
      
      private var mShiftRight:UIButton;
      
      private var mGlyphFilePathToControllerIconData:Dictionary = new Dictionary();
      
      public function StacksWithEquipPicker(dbFacade:DBFacade, root:MovieClip, weaponTooltipClass:Class, heroTooltipClass:Class, clickedEquippedWeaponCallback:Function = null, equipResponseFinishedCallback:Function = null, allowEquipmentSwapping:Boolean = false, getSelectedHeroIndexCallback:Function = null, setSelectedHeroIndexCallback:Function = null, isActiveCallback:Function = null)
      {
         super(dbFacade,root);
         mSetSelectedHeroCallback = setSelectedHeroIndexCallback;
         mGetSelectedHeroCallback = getSelectedHeroIndexCallback;
         Locale.setText(mRoot.label,"STACK_PICKER_LABEL");
         mDBFacade = dbFacade;
         mEventComponent = new EventComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mClickedEquippedWeaponCallback = clickedEquippedWeaponCallback;
         mEquipResponseCallback = equipResponseFinishedCallback;
         mEquipElements = new Vector.<ConsumableEquipElement>();
         mEquipElements.push(new ConsumableEquipElement(mDBFacade,mDBFacade.keyBindings.displayNameFor("useConsumable1"),mRoot.UI_potion.equip_slot_0,weaponTooltipClass,unequipPotion,handleItemDrop,0,equippedPotionClicked,equipResponseFinishedCallback,allowEquipmentSwapping));
         mEquipElements.push(new ConsumableEquipElement(mDBFacade,mDBFacade.keyBindings.displayNameFor("useConsumable2"),mRoot.UI_potion.equip_slot_1,weaponTooltipClass,unequipPotion,handleItemDrop,1,equippedPotionClicked,equipResponseFinishedCallback,allowEquipmentSwapping));
         mEventComponent.addListener("OnSteamInputGlyphsChanged",onSteamInputGlyphsChanged);
         mEventComponent.addListener("ControllerConnectionChangedEvent",onControllerConnectionChanged);
         if(mDBFacade.steamInputManager.isSteamInputReady)
         {
            initControllerIcons();
         }
         mEquipSlots = new Vector.<EquipSlot>();
         mEquipSlots.push(new EquipSlot(mDBFacade,mRoot.empty_z,this.handleItemDrop,0));
         mEquipSlots.push(new EquipSlot(mDBFacade,mRoot.empty_x,this.handleItemDrop,1));
         mHeroSlots = new Vector.<HeroElement>();
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_0,heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_1,heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_2,heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_3,heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_4,heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_5,heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_6,heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_7,heroTooltipClass,heroClicked));
         mShiftLeft = new UIButton(mDBFacade,mRoot.shift_left);
         mShiftLeft.releaseCallback = shiftLeft;
         mShiftRight = new UIButton(mDBFacade,mRoot.shift_right);
         mShiftRight.releaseCallback = shiftRight;
         mTotalGMHeroes = mDBFacade.gameMaster.Heroes.length;
         mShiftLeft.visible = mTotalGMHeroes > mHeroSlots.length;
         mShiftRight.visible = mShiftLeft.visible;
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",function(param1:DBAccountResponseEvent):void
         {
            if(isActiveCallback == null || isActiveCallback())
            {
               refresh();
            }
         });
      }
      
      public function unequipPotion(info:StackableInfo, itemSlot:uint, responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var equippingModal:DBUIPopup;
         var equipServiceResponse:Function;
         var avatarInfo:AvatarInfo = selectedAvatarInfo;
         if(avatarInfo)
         {
            equippingModal = createEquippingModal();
            equipServiceResponse = function():void
            {
               equippingModal.destroy();
               if(responseFinishedCallback != null)
               {
                  responseFinishedCallback();
               }
            };
            mDBFacade.dbAccountInfo.inventoryInfo.unequipConsumableOffAvatar(avatarInfo.id,info.gmStackable.Id,itemSlot,equipServiceResponse,closeEquippingModalOnError(equippingModal,errorCallback));
         }
      }
      
      public function equipPotionOnCurrentAvatar(info:StackableInfo, itemSlot:uint, swapping:Boolean = false, responseFinishedCallback:Function = null, errorCallback:Function = null) : Boolean
      {
         var equipServiceResponse:Function;
         var equippingModal:DBUIPopup;
         var avatarId:uint;
         var popup:DBUIOneButtonPopup;
         var avatarInfo:AvatarInfo = selectedAvatarInfo;
         if(avatarInfo)
         {
            equipServiceResponse = function():void
            {
               equippingModal.destroy();
               if(responseFinishedCallback != null)
               {
                  responseFinishedCallback();
               }
            };
            if(swapping || mDBFacade.dbAccountInfo.inventoryInfo.canEquipThisConsumable(avatarInfo,itemSlot,info.gmId))
            {
               equippingModal = createEquippingModal();
               avatarId = avatarInfo.id;
               mDBFacade.dbAccountInfo.inventoryInfo.equipConsumableOnAvatar(avatarId,info.gmStackable.Id,itemSlot,swapping,equipServiceResponse,closeEquippingModalOnError(equippingModal,errorCallback));
               return true;
            }
            popup = new DBUIOneButtonPopup(mDBFacade,"STACK_NOT_ALLOWED_POPUP",Locale.getString("STACK_NOT_ALLOWED_TITLE"),Locale.getString("STACK_NOT_ALLOWED_MESSAGE"),Locale.getString("CANCEL"),null);
            MemoryTracker.track(popup,"DBUIOneButtonPopup - created in StacksWithEquipPicker.tryEquip()");
         }
         return false;
      }
      
      private function createEquippingModal() : DBUIPopup
      {
         return new DBUIPopup(mDBFacade,"",Locale.getString("EQUIPPING_MODAL"),null,false);
      }
      
      private function closeEquippingModalOnError(modal:DBUIPopup, callback:Function) : Function
      {
         return function(... rest):void
         {
            modal.destroy();
            if(callback != null)
            {
               callback.apply(null,rest);
            }
         };
      }
      
      private function equippedPotionClicked(equipElement:ConsumableEquipElement) : void
      {
         deselectEquipment();
         if(mClickedEquippedWeaponCallback != null && equipElement.itemInfo != null)
         {
            equipElement.select();
            mClickedEquippedWeaponCallback(equipElement.itemInfo,equipElement);
         }
      }
      
      private function populateHeroSlots() : void
      {
         var _loc2_:uint = 0;
         var _loc3_:Vector.<GMHero> = mDBFacade.gameMaster.Heroes;
         var _loc1_:uint = mCurrentStartIndex;
         _loc2_ = 0;
         while(_loc2_ < mHeroSlots.length)
         {
            mHeroSlots[_loc2_].clear();
            if(_loc1_ < _loc3_.length && (!_loc3_[_loc1_].Hidden || mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes",false)))
            {
               mHeroSlots[_loc2_].gmHero = _loc3_[_loc1_];
            }
            else
            {
               mHeroSlots[_loc2_].enabled = false;
            }
            _loc1_++;
            _loc2_++;
         }
         updateShiftButtons();
         updateFirstSlotLeftNavigation();
         determineSelectedElement();
      }
      
      private function updateShiftButtons() : void
      {
         if(mCurrentStartIndex == 0)
         {
            mShiftLeft.enabled = false;
         }
         else
         {
            mShiftLeft.enabled = true;
         }
         var _loc1_:uint = mCurrentStartIndex + mHeroSlots.length;
         if(_loc1_ < mTotalGMHeroes)
         {
            mShiftRight.enabled = true;
         }
         else
         {
            mShiftRight.enabled = false;
         }
      }
      
      private function shiftLeft() : void
      {
         mCurrentStartIndex = mCurrentStartIndex - 1;
         populateHeroSlots();
      }
      
      private function shiftRight() : void
      {
         mCurrentStartIndex = mCurrentStartIndex + 1;
         populateHeroSlots();
      }
      
      private function rotateRosterLeft() : void
      {
         if(mCurrentStartIndex > 0)
         {
            shiftLeft();
         }
      }
      
      private function rotateRosterRight() : void
      {
         if(mCurrentStartIndex + mHeroSlots.length < mTotalGMHeroes)
         {
            shiftRight();
         }
      }
      
      private function updateFirstSlotLeftNavigation() : void
      {
         var _loc1_:Function = mHeroSlots[0].leftNavigationAdditionalInteraction;
         mHeroSlots[0].clearLeftNavigation();
         if(_loc1_ != null)
         {
            mHeroSlots[0].leftNavigationAdditionalInteraction = _loc1_;
         }
         if(mCurrentStartIndex == 0 && mFirstSlotLeftNavigation != null)
         {
            mHeroSlots[0].leftNavigation = mFirstSlotLeftNavigation;
         }
      }
      
      override public function destroy() : void
      {
         hideAndUnloadControllerIcons();
         mEventComponent.destroy();
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mDBFacade = null;
         super.destroy();
      }
      
      private function onSteamInputGlyphsChanged(event:Event) : void
      {
         if(mDBFacade.steamInputManager.isSteamInputReady)
         {
            initControllerIcons();
         }
      }
      
      private function onControllerConnectionChanged(event:Event) : void
      {
         hideAndUnloadControllerIcons();
         if(mDBFacade.steamInputManager.isSteamInputReady)
         {
            initControllerIcons();
         }
      }
      
      public function hideAndUnloadControllerIcons() : void
      {
         hideControllerIcons();
         for(var _loc2_:String in mGlyphFilePathToControllerIconData)
         {
            delete mGlyphFilePathToControllerIconData[_loc2_];
         }
         for each(var _loc1_:ConsumableEquipElement in mEquipElements)
         {
            _loc1_.setLabelAsText();
         }
      }
      
      private function hideControllerIcons() : void
      {
         var _loc2_:ControllerIconData = null;
         for(var _loc1_:String in mGlyphFilePathToControllerIconData)
         {
            _loc2_ = mGlyphFilePathToControllerIconData[_loc1_];
            if(!_loc2_.mIsHidden)
            {
               if(_loc2_.mOwner.contains(_loc2_.mControllerGlyph))
               {
                  _loc2_.mOwner.removeChild(_loc2_.mControllerGlyph);
               }
               _loc2_.mIsHidden = true;
            }
         }
      }
      
      private function initControllerIcons() : void
      {
         var _loc1_:uint = 0;
         hideAndUnloadControllerIcons();
         var _loc2_:Vector.<String> = new Vector.<String>();
         _loc2_.push("use_consumable_one");
         _loc2_.push("use_consumable_two");
         _loc1_ = 0;
         while(_loc1_ < mEquipElements.length && _loc1_ < _loc2_.length)
         {
            initControllerIcon(mEquipElements[_loc1_],_loc2_[_loc1_]);
            _loc1_++;
         }
      }
      
      private function initControllerIcon(equipElement:ConsumableEquipElement, actionName:String) : void
      {
         var glyphFilePath:String = mDBFacade.steamInputManager.getGlyphFilePathForAction(actionName);
         if(glyphFilePath == null || glyphFilePath == "" || glyphFilePath == "error1")
         {
            equipElement.setLabelAsText();
            return;
         }
         mAssetLoadingComponent.getImageAsset(glyphFilePath,function(param1:ImageAsset):void
         {
            var _loc2_:Bitmap = param1.image as Bitmap;
            var _loc3_:DisplayObject = new Bitmap(_loc2_.bitmapData);
            _loc3_.x = CONTROLLER_ICON_POSITION_FOR_STACK_BUTTONS.x;
            _loc3_.y = CONTROLLER_ICON_POSITION_FOR_STACK_BUTTONS.y;
            _loc3_.width = CONTROLLER_GLYPH_SCALE_STACK_BUTTONS.x;
            _loc3_.height = CONTROLLER_GLYPH_SCALE_STACK_BUTTONS.y;
            equipElement.setLabelAsControllerGlyph(_loc3_);
            mGlyphFilePathToControllerIconData[glyphFilePath] = new ControllerIconData(_loc3_,equipElement.root,false);
         },null,false);
      }
      
      public function show() : void
      {
         mRoot.visible = true;
      }
      
      public function hide() : void
      {
         mRoot.visible = false;
      }
      
      private function get selectedHeroIndex() : int
      {
         if(mGetSelectedHeroCallback != null)
         {
            mSelectedHeroIndex = mGetSelectedHeroCallback();
         }
         return mSelectedHeroIndex;
      }
      
      private function set selectedHeroIndex(val:int) : void
      {
         mSelectedHeroIndex = val;
         if(mSetSelectedHeroCallback != null)
         {
            mSetSelectedHeroCallback(mSelectedHeroIndex);
         }
      }
      
      private function get selectedGMHero() : GMHero
      {
         var _loc2_:Vector.<GMHero> = mDBFacade.gameMaster.Heroes;
         var _loc1_:int = selectedHeroIndex;
         return _loc1_ >= 0 && _loc1_ < _loc2_.length ? _loc2_[_loc1_] : null;
      }
      
      private function get selectedAvatarInfo() : AvatarInfo
      {
         var _loc1_:GMHero = selectedGMHero;
         return _loc1_ ? mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc1_.Id) : null;
      }
      
      private function heroClicked(heroElement:HeroElement, owned:Boolean) : void
      {
         var _loc3_:uint = mHeroSlots.indexOf(heroElement) + mCurrentStartIndex;
         if(selectedHeroIndex == _loc3_)
         {
            return;
         }
         selectedHeroIndex = _loc3_;
         determineSelectedElement();
         refresh();
      }
      
      private function determineSelectedElement() : void
      {
         var _loc1_:uint = 0;
         _loc1_ = 0;
         while(_loc1_ < mHeroSlots.length)
         {
            if(_loc1_ + mCurrentStartIndex == selectedHeroIndex)
            {
               mHeroSlots[_loc1_].select();
            }
            else
            {
               mHeroSlots[_loc1_].deselect();
            }
            _loc1_++;
         }
      }
      
      private function setCurrentIndexToShowSelectedHero() : void
      {
         if(selectedHeroIndex < mHeroSlots.length)
         {
            mCurrentStartIndex = 0;
            return;
         }
         mCurrentStartIndex = selectedHeroIndex - (mHeroSlots.length - 1);
      }
      
      private function findHeroIndex(avatarId:uint) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:Vector.<GMHero> = mDBFacade.gameMaster.Heroes;
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            if(avatarId == _loc3_[_loc2_].Id)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         Logger.error("Unable to find gmHero for active avatar Id: " + avatarId);
         return 0;
      }
      
      public function refresh(resync:Boolean = false) : void
      {
         if(selectedHeroIndex == -1 || resync)
         {
            setActiveAvatarAsCurrentSelection();
         }
         if(selectedHeroIndex < mCurrentStartIndex || selectedHeroIndex >= mCurrentStartIndex + mHeroSlots.length)
         {
            setCurrentIndexToShowSelectedHero();
         }
         populateHeroSlots();
         setEquipSlots();
      }
      
      private function setActiveAvatarAsCurrentSelection() : void
      {
         var _loc2_:Array = null;
         var _loc1_:AvatarInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
         if(_loc1_ == null)
         {
            Logger.warn("No active avatar set on account id: " + mDBFacade.accountId);
            _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.avatars.keysToArray();
            if(_loc2_ == null)
            {
               Logger.error("No avatars found on account id: " + mDBFacade.accountId);
               return;
            }
            _loc1_ = mDBFacade.dbAccountInfo.inventoryInfo.avatars.itemFor(_loc2_[0]) as AvatarInfo;
            if(_loc1_ == null)
            {
               Logger.fatal("Could not get avatar info for key: " + _loc2_[0] + " Unable to get active avatar.");
               return;
            }
         }
         selectedHeroIndex = findHeroIndex(_loc1_.avatarType);
      }
      
      private function setEquipSlots() : void
      {
         var _loc5_:uint = 0;
         var _loc3_:GMStackable = null;
         var _loc1_:Vector.<Consumable> = undefined;
         var _loc2_:int = 0;
         if(selectedGMHero == null)
         {
            return;
         }
         _loc5_ = 0;
         while(_loc5_ < mEquipElements.length)
         {
            mEquipElements[_loc5_].clear();
            _loc5_++;
         }
         var _loc4_:AvatarInfo = selectedAvatarInfo;
         if(_loc4_)
         {
            _loc1_ = _loc4_.equippedConsumables;
            _loc5_ = 0;
            while(_loc5_ < mEquipElements.length)
            {
               if(_loc5_ >= _loc1_.length)
               {
                  break;
               }
               if(_loc1_[_loc5_].stackId != 0)
               {
                  _loc2_ = int(_loc1_[_loc5_].stackSlot);
                  _loc3_ = mDBFacade.gameMaster.stackableById.itemFor(_loc1_[_loc5_].stackId);
                  if(_loc2_ >= mEquipElements.length || _loc2_ < 0)
                  {
                     Logger.warn("Stackable id: " + _loc3_.Id + " is equipped to an invalid slot: " + _loc1_[_loc5_].stackSlot);
                  }
                  else
                  {
                     mEquipElements[_loc2_].init(_loc3_,_loc1_[_loc5_].stackSlot,_loc1_[_loc5_].stackCount);
                  }
               }
               _loc5_++;
            }
         }
      }
      
      public function highlightItem(info:InventoryBaseInfo) : void
      {
         var _loc2_:ConsumableEquipElement = null;
         var _loc3_:uint = 0;
         _loc3_ = 0;
         while(_loc3_ < mEquipElements.length)
         {
            _loc2_ = mEquipElements[_loc3_];
            if(info && _loc2_.itemInfo == info)
            {
               mEquipElements[_loc3_].select();
            }
            else
            {
               mEquipElements[_loc3_].deselect();
            }
            _loc3_++;
         }
      }
      
      public function deselectEquipment() : void
      {
         var _loc1_:uint = 0;
         _loc1_ = 0;
         while(_loc1_ < mEquipElements.length)
         {
            mEquipElements[_loc1_].deselect();
            _loc1_++;
         }
      }
      
      public function getFirstUIObject() : UIObject
      {
         return mHeroSlots[0];
      }
      
      public function setupMenuNavigation(returnObject:UIObject) : void
      {
         var _loc2_:uint = 0;
         _loc2_ = 0;
         while(_loc2_ < mEquipElements.length)
         {
            mEquipElements[_loc2_].upNavigation = returnObject;
            if(_loc2_ > 0)
            {
               mEquipElements[_loc2_ - 1].isToTheLeftOf(mEquipElements[_loc2_]);
            }
            _loc2_++;
         }
         if(mEquipElements.length > 0)
         {
            mEquipElements[mEquipElements.length - 1].isToTheLeftOf(mHeroSlots[0]);
         }
         _loc2_ = 0;
         while(_loc2_ < mHeroSlots.length)
         {
            mHeroSlots[_loc2_].upNavigation = returnObject;
            if(_loc2_ > 0)
            {
               mHeroSlots[_loc2_ - 1].isToTheLeftOf(mHeroSlots[_loc2_]);
            }
            _loc2_++;
         }
         mHeroSlots[0].leftNavigationAdditionalInteraction = rotateRosterLeft;
         mHeroSlots[mHeroSlots.length - 1].rightNavigationAdditionalInteraction = rotateRosterRight;
         mFirstSlotLeftNavigation = mEquipElements.length > 0 ? mEquipElements[mEquipElements.length - 1] : null;
         updateFirstSlotLeftNavigation();
      }
      
      public function resetMenuNavigation() : void
      {
         mFirstSlotLeftNavigation = null;
         for each(var _loc2_:UIObject in mEquipElements)
         {
            _loc2_.clearNavigationAndInteractions();
         }
         for each(var _loc1_:UIObject in mHeroSlots)
         {
            _loc1_.clearNavigationAndInteractions();
         }
      }
      
      public function handleItemDrop(dropObject:UIObject, stackInfo:StackableInfo, equipSlot:uint) : Boolean
      {
         var equipElement:ConsumableEquipElement;
         var uiInvItem:UIInventoryItem = dropObject as UIInventoryItem;
         if(uiInvItem && uiInvItem.info != null && uiInvItem.info as StackableInfo)
         {
            if(uiInvItem.info.gmId == DBGlobal.RESSURECTION_POTION_STACK_ID || uiInvItem.info.gmId == DBGlobal.PARTYBOMB_POTION_STACK_ID)
            {
               return false;
            }
            if(!this.equipPotionOnCurrentAvatar(StackableInfo(uiInvItem.info),equipSlot,false,mEquipResponseCallback))
            {
               return false;
            }
            uiInvItem.dragSwapItem(stackInfo);
            return true;
         }
         equipElement = dropObject as ConsumableEquipElement;
         if(equipElement && equipElement.itemInfo != null)
         {
            equipElement.reset();
            if(equipElement.equipSlot == equipSlot)
            {
               return true;
            }
            this.equipPotionOnCurrentAvatar(equipElement.stackableInfo,equipSlot,true,function():void
            {
            },mEquipResponseCallback);
            return true;
         }
         return false;
      }
   }
}

