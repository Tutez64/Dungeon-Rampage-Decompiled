package UI.EquipPicker
{
   import Account.AvatarInfo;
   import Account.Consumable;
   import Account.InventoryBaseInfo;
   import Account.StackableInfo;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.UI.UIPopup;
   import Brain.Utils.MemoryTracker;
   import Events.DBAccountResponseEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMStackable;
   import UI.Inventory.UIInventoryItem;
   import UI.Popup.DBUIOneButtonPopup;
   import flash.display.MovieClip;
   
   public class StacksWithEquipPicker extends UIObject
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mEventComponent:EventComponent;
      
      private var mHeroSlots:Vector.<HeroElement>;
      
      private var mEquipElements:Vector.<ConsumableEquipElement>;
      
      private var mEquipSlots:Vector.<EquipSlot>;
      
      private var mClickedEquippedWeaponCallback:Function;
      
      private var mCurrentStartIndex:uint = 0;
      
      private var mEquipResponseCallback:Function;
      
      private var mSetSelectedHeroCallback:Function;
      
      private var mGetSelectedHeroCallback:Function;
      
      private var mSelectedHeroIndex:int = -1;
      
      private var mTotalGMHeroes:uint;
      
      private var mShiftLeft:UIButton;
      
      private var mShiftRight:UIButton;
      
      public function StacksWithEquipPicker(dbFacade:DBFacade, root:MovieClip, weaponTooltipClass:Class, heroTooltipClass:Class, clickedEquippedWeaponCallback:Function = null, equipResponseFinishedCallback:Function = null, allowEquipmentSwapping:Boolean = false, getSelectedHeroIndexCallback:Function = null, setSelectedHeroIndexCallback:Function = null)
      {
         super(dbFacade,root);
         mSetSelectedHeroCallback = setSelectedHeroIndexCallback;
         mGetSelectedHeroCallback = getSelectedHeroIndexCallback;
         mRoot.label.text = Locale.getString("STACK_PICKER_LABEL");
         mDBFacade = dbFacade;
         mEventComponent = new EventComponent(mDBFacade);
         mClickedEquippedWeaponCallback = clickedEquippedWeaponCallback;
         mEquipResponseCallback = equipResponseFinishedCallback;
         mEquipElements = new Vector.<ConsumableEquipElement>();
         mEquipElements.push(new ConsumableEquipElement(mDBFacade,"1",mRoot.UI_potion.equip_slot_0,weaponTooltipClass,unequipPotion,handleItemDrop,0,equippedPotionClicked,equipResponseFinishedCallback,allowEquipmentSwapping));
         mEquipElements.push(new ConsumableEquipElement(mDBFacade,"2",mRoot.UI_potion.equip_slot_1,weaponTooltipClass,unequipPotion,handleItemDrop,1,equippedPotionClicked,equipResponseFinishedCallback,allowEquipmentSwapping));
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
         mShiftLeft.visible = false;
         mShiftRight.visible = false;
         mTotalGMHeroes = mDBFacade.gameMaster.Heroes.length;
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",function(param1:DBAccountResponseEvent):void
         {
            refresh();
         });
      }
      
      public function unequipPotion(info:StackableInfo, itemSlot:uint, responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var equippingModal:UIPopup;
         var equipServiceResponse:Function;
         var avatarInfo:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroSlots[selectedHeroIndex].gmHero.Id);
         if(avatarInfo)
         {
            equippingModal = UIPopup.show(mDBFacade,Locale.getString("EQUIPPING_MODAL"));
            equipServiceResponse = function():void
            {
               equippingModal.destroy();
               if(responseFinishedCallback != null)
               {
                  responseFinishedCallback();
               }
            };
            mDBFacade.dbAccountInfo.inventoryInfo.unequipConsumableOffAvatar(avatarInfo.id,info.gmStackable.Id,itemSlot,equipServiceResponse,errorCallback);
         }
      }
      
      public function equipPotionOnCurrentAvatar(info:StackableInfo, itemSlot:uint, swapping:Boolean = false, responseFinishedCallback:Function = null, errorCallback:Function = null) : Boolean
      {
         var equipServiceResponse:Function;
         var equippingModal:UIPopup;
         var avatarId:uint;
         var popup:DBUIOneButtonPopup;
         var avatarInfo:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroSlots[selectedHeroIndex].gmHero.Id);
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
               equippingModal = UIPopup.show(mDBFacade,Locale.getString("EQUIPPING_MODAL"));
               avatarId = avatarInfo.id;
               mDBFacade.dbAccountInfo.inventoryInfo.equipConsumableOnAvatar(avatarId,info.gmStackable.Id,itemSlot,swapping,equipServiceResponse,errorCallback);
               return true;
            }
            popup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("STACK_NOT_ALLOWED_TITLE"),Locale.getString("STACK_NOT_ALLOWED_MESSAGE"),Locale.getString("CANCEL"),null);
            MemoryTracker.track(popup,"DBUIOneButtonPopup - created in StacksWithEquipPicker.tryEquip()");
         }
         return false;
      }
      
      private function equippedPotionClicked(equipElement:ConsumableEquipElement) : void
      {
         deselectEquipment();
         if(mClickedEquippedWeaponCallback != null && equipElement.itemInfo != null)
         {
            equipElement.select();
            mClickedEquippedWeaponCallback(equipElement.itemInfo);
         }
      }
      
      private function populateHeroSlots() : void
      {
         var _loc2_:* = 0;
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
      
      override public function destroy() : void
      {
         mEventComponent.destroy();
         mDBFacade = null;
         super.destroy();
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
         var _loc1_:* = 0;
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
         var _loc2_:* = 0;
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
         var _loc5_:* = 0;
         var _loc3_:GMStackable = null;
         var _loc1_:* = undefined;
         var _loc2_:int = 0;
         if(mHeroSlots[selectedHeroIndex].gmHero == null)
         {
            return;
         }
         _loc5_ = 0;
         while(_loc5_ < mEquipElements.length)
         {
            mEquipElements[_loc5_].clear();
            _loc5_++;
         }
         var _loc4_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroSlots[selectedHeroIndex].gmHero.Id);
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
         var _loc3_:* = 0;
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
         var _loc1_:* = 0;
         _loc1_ = 0;
         while(_loc1_ < mEquipElements.length)
         {
            mEquipElements[_loc1_].deselect();
            _loc1_++;
         }
      }
      
      public function handleItemDrop(dropObject:UIObject, stackInfo:StackableInfo, equipSlot:uint) : Boolean
      {
         var equipElement:ConsumableEquipElement;
         var uiInvItem:UIInventoryItem = dropObject as UIInventoryItem;
         if(uiInvItem && uiInvItem.info != null && uiInvItem.info as StackableInfo)
         {
            if(uiInvItem.info.gmId == 60001 || uiInvItem.info.gmId == 60018)
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

