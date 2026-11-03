package UI.EquipPicker
{
   import Account.AvatarInfo;
   import Account.InventoryBaseInfo;
   import Account.ItemInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.ImageAsset;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Events.DBAccountResponseEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMWeaponItem;
   import UI.ControllerIconData;
   import UI.Inventory.UIInventoryItem;
   import UI.Popup.DBUIPopup;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   public class HeroWithEquipPicker extends UIObject
   {
      
      private static const CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS:Vector3D = new Vector3D(13,-50);
      
      private static const CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS:Point = new Point(25,25);
      
      protected var mDBFacade:DBFacade;
      
      protected var mEventComponent:EventComponent;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mHeroSlots:Vector.<HeroElement>;
      
      private var mEquipElements:Vector.<AvatarEquipElement>;
      
      private var mEquipSlots:Vector.<EquipSlot>;
      
      private var mShiftLeft:UIButton;
      
      private var mShiftRight:UIButton;
      
      private var mHeroSelectedCallback:Function;
      
      private var mClickedEquippedWeaponCallback:Function;
      
      private var mSetSelectedHeroCallback:Function;
      
      private var mGetSelectedHeroCallback:Function;
      
      private var mCurrentStartIndex:uint = 0;
      
      private var mTotalGMHeroes:uint;
      
      private var mEquipResponseCallback:Function;
      
      private var mAllowSelectingUnownedHeroes:Boolean = true;
      
      private var mFirstSlotLeftNavigation:UIObject;
      
      private var mAvatarAlertsOn:Boolean = false;
      
      private var mAlertDisabledHeroId:uint = 0;
      
      private var mComparisonWeapon:GMWeaponItem;
      
      private var mComparisonPower:uint;
      
      private var mSelectedHeroIndex:int = -1;
      
      private var mGlyphFilePathToControllerIconData:Dictionary = new Dictionary();
      
      public function HeroWithEquipPicker(dbFacade:DBFacade, root:MovieClip, weaponTooltipClass:Class, heroTooltipClass:Class, heroSelectedCallback:Function, clickedEquippedWeaponCallback:Function = null, getSelectedHeroIndexCallback:Function = null, setSelectedHeroIndexCallback:Function = null, equipResponseFinishedCallback:Function = null, allowEquipmentSwapping:Boolean = false, allowSelectingUnownedHeroes:Boolean = true, isActiveCallback:Function = null)
      {
         super(dbFacade,root);
         mDBFacade = dbFacade;
         mAllowSelectingUnownedHeroes = allowSelectingUnownedHeroes;
         mEventComponent = new EventComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mHeroSelectedCallback = heroSelectedCallback;
         mClickedEquippedWeaponCallback = clickedEquippedWeaponCallback;
         mEquipResponseCallback = equipResponseFinishedCallback;
         mSetSelectedHeroCallback = setSelectedHeroIndexCallback;
         mGetSelectedHeroCallback = getSelectedHeroIndexCallback;
         Locale.setText(mRoot.label,"WEAPON_PICKER_LABEL");
         mEquipElements = new Vector.<AvatarEquipElement>();
         mEquipElements.push(new AvatarEquipElement(mDBFacade,mDBFacade.keyBindings.displayNameFor("attackWeapon1"),mRoot.UI_weapons.equip_slot_0,weaponTooltipClass,unequipItem,handleItemDrop,0,equippedWeaponClicked,equipResponseFinishedCallback,allowEquipmentSwapping));
         mEquipElements.push(new AvatarEquipElement(mDBFacade,mDBFacade.keyBindings.displayNameFor("attackWeapon2"),mRoot.UI_weapons.equip_slot_1,weaponTooltipClass,unequipItem,handleItemDrop,1,equippedWeaponClicked,equipResponseFinishedCallback,allowEquipmentSwapping));
         mEquipElements.push(new AvatarEquipElement(mDBFacade,mDBFacade.keyBindings.displayNameFor("attackWeapon3"),mRoot.UI_weapons.equip_slot_2,weaponTooltipClass,unequipItem,handleItemDrop,2,equippedWeaponClicked,equipResponseFinishedCallback,allowEquipmentSwapping));
         mEventComponent.removeAllListeners();
         mEventComponent.addListener("OnSteamInputGlyphsChanged",onSteamInputGlyphsChanged);
         mEventComponent.addListener("ControllerConnectionChangedEvent",onControllerConnectionChanged);
         if(mDBFacade.steamInputManager.isSteamInputReady)
         {
            initControllerIcons();
         }
         mEquipSlots = new Vector.<EquipSlot>();
         mEquipSlots.push(new EquipSlot(mDBFacade,mRoot.empty_z,this.handleItemDrop,0));
         mEquipSlots.push(new EquipSlot(mDBFacade,mRoot.empty_x,this.handleItemDrop,1));
         mEquipSlots.push(new EquipSlot(mDBFacade,mRoot.empty_c,this.handleItemDrop,2));
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
      
      private function onSteamInputGlyphsChanged(inEvent:Event) : void
      {
         if(mDBFacade.steamInputManager.isSteamInputReady)
         {
            initControllerIcons();
         }
      }
      
      private function onControllerConnectionChanged(inEvent:Event) : void
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
         for each(var _loc1_:AvatarEquipElement in mEquipElements)
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
         var _loc1_:Vector.<String> = new Vector.<String>();
         _loc1_.push("attack_weapon_1");
         _loc1_.push("attack_weapon_2");
         _loc1_.push("attack_weapon_3");
         var _loc2_:Number = 0;
         for each(var _loc3_:AvatarEquipElement in mEquipElements)
         {
            initControllerIcon(_loc3_,_loc1_[_loc2_]);
            _loc2_++;
         }
      }
      
      private function initControllerIcon(equipElement:AvatarEquipElement, ActionName:String) : void
      {
         var iconData:ControllerIconData;
         var glyphFilePath:String = mDBFacade.steamInputManager.getGlyphFilePathForAction(ActionName);
         if(glyphFilePath == null || glyphFilePath == "" || glyphFilePath == "error1")
         {
            equipElement.setLabelAsText();
            return;
         }
         iconData = mGlyphFilePathToControllerIconData[glyphFilePath];
         if(iconData != null)
         {
            equipElement.setLabelAsControllerGlyph(iconData.mControllerGlyph);
         }
         else
         {
            mAssetLoadingComponent.getImageAsset(glyphFilePath,function(param1:ImageAsset):void
            {
               loadControllerIcon(param1,equipElement,glyphFilePath,CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS,CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS);
            },null,false);
         }
      }
      
      private function loadControllerIcon(asset:ImageAsset, equipElement:AvatarEquipElement, glyphFilePath:String, iconPosition:Vector3D, iconScale:Point) : void
      {
         var _loc6_:Bitmap = asset.image as Bitmap;
         var _loc7_:DisplayObject = new Bitmap(_loc6_.bitmapData);
         _loc7_.x = iconPosition.x;
         _loc7_.y = iconPosition.y;
         _loc7_.width = iconScale.x;
         _loc7_.height = iconScale.y;
         equipElement.setLabelAsControllerGlyph(_loc7_);
         var _loc8_:ControllerIconData = new ControllerIconData(_loc7_,equipElement.root,false);
         mGlyphFilePathToControllerIconData[glyphFilePath] = _loc8_;
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
      
      private function equippedWeaponClicked(equipElement:AvatarEquipElement) : void
      {
         deselectEquipment();
         if(mClickedEquippedWeaponCallback != null && equipElement.itemInfo != null)
         {
            equipElement.select();
            mClickedEquippedWeaponCallback(equipElement.itemInfo,equipElement);
         }
      }
      
      public function showWeaponComparison(gmWeaponItem:GMWeaponItem, power:uint) : void
      {
         mComparisonWeapon = gmWeaponItem;
         mComparisonPower = power;
         applyWeaponComparison();
      }
      
      public function hideWeaponComparison() : void
      {
         mComparisonWeapon = null;
         applyWeaponComparison();
      }
      
      private function applyWeaponComparison() : void
      {
         for each(var _loc1_:HeroElement in mHeroSlots)
         {
            _loc1_.hideWeaponComparison();
            if(mComparisonWeapon != null)
            {
               _loc1_.showWeaponComparison(mComparisonWeapon,mComparisonPower);
            }
         }
      }
      
      public function show() : void
      {
         mRoot.visible = true;
      }
      
      public function hide() : void
      {
         mRoot.visible = false;
      }
      
      public function get currentlySelectedHero() : GMHero
      {
         var _loc2_:Vector.<GMHero> = mDBFacade.gameMaster.Heroes;
         var _loc1_:int = selectedHeroIndex;
         return _loc1_ >= 0 && _loc1_ < _loc2_.length ? _loc2_[_loc1_] : null;
      }
      
      public function get currentlySelectedAvatarInfo() : AvatarInfo
      {
         var _loc1_:GMHero = this.currentlySelectedHero;
         return _loc1_ ? mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc1_.Id) : null;
      }
      
      public function selectPreviousHero() : void
      {
         selectAdjacentHero(-1);
      }
      
      public function selectNextHero() : void
      {
         selectAdjacentHero(1);
      }
      
      private function selectAdjacentHero(direction:int) : void
      {
         var _loc6_:Vector.<GMHero> = mDBFacade.gameMaster.Heroes;
         if(_loc6_.length == 0)
         {
            return;
         }
         var _loc5_:int = selectedHeroIndex;
         if(_loc5_ < 0 || _loc5_ >= _loc6_.length)
         {
            _loc5_ = 0;
         }
         var _loc2_:Boolean = mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes",false);
         var _loc4_:int = _loc5_;
         while(true)
         {
            _loc4_ = (_loc4_ + direction + _loc6_.length) % _loc6_.length;
            if(!(_loc4_ != _loc5_ && (_loc6_[_loc4_].Hidden && !_loc2_ || !mAllowSelectingUnownedHeroes && !mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(_loc6_[_loc4_].Id))))
            {
               break;
            }
         }
         if(_loc4_ == _loc5_)
         {
            return;
         }
         if(_loc4_ < mCurrentStartIndex)
         {
            mCurrentStartIndex = _loc4_;
         }
         else if(_loc4_ >= mCurrentStartIndex + mHeroSlots.length)
         {
            mCurrentStartIndex = _loc4_ - (mHeroSlots.length - 1);
         }
         populateHeroSlots();
         var _loc3_:HeroElement = mHeroSlots[_loc4_ - mCurrentStartIndex];
         heroClicked(_loc3_,mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(_loc3_.gmHero.Id));
         mDBFacade.menuNavigationController.setFocusedUiObject(_loc3_);
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
         mEventComponent.destroy();
         mAssetLoadingComponent.destroy();
         mDBFacade = null;
         mShiftLeft.destroy();
         mShiftRight.destroy();
         mHeroSelectedCallback = null;
         super.destroy();
      }
      
      private function setActiveAvatarAsCurrentSelection() : void
      {
         var _loc2_:Array = null;
         var _loc1_:AvatarInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
         if(_loc1_ == null)
         {
            Logger.warn("No active avatar set on account id: " + mDBFacade.accountId);
            if(mDBFacade.dbAccountInfo.inventoryInfo.avatars == null)
            {
               Logger.error("setActiveAvatarAsCurrentSelection() - mDBFacade.dbAccountInfo.inventoryInfo.avatars == null on account id: " + mDBFacade.accountId);
            }
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
      
      public function setAvatarAlert(val:Boolean) : void
      {
         mAvatarAlertsOn = val;
         mAlertDisabledHeroId = 0;
         applyAvatarAlerts();
      }
      
      public function disableAvatarAlertOnSelectedHero() : void
      {
         var _loc1_:GMHero = currentlySelectedHero;
         if(_loc1_)
         {
            mAlertDisabledHeroId = _loc1_.Id;
         }
         applyAvatarAlerts();
      }
      
      private function applyAvatarAlerts() : void
      {
         var _loc1_:AvatarInfo = null;
         var _loc3_:uint = 0;
         var _loc2_:GMHero = null;
         _loc3_ = 0;
         while(_loc3_ < mHeroSlots.length)
         {
            _loc2_ = mHeroSlots[_loc3_].gmHero;
            if(mAvatarAlertsOn && _loc2_ && _loc2_.Id != mAlertDisabledHeroId)
            {
               _loc1_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc2_.Id) as AvatarInfo;
               mHeroSlots[_loc3_].alert = _loc1_ && _loc1_.skillPointsAvailable > 0;
            }
            else
            {
               mHeroSlots[_loc3_].alert = false;
            }
            _loc3_++;
         }
      }
      
      public function refresh(resync:Boolean = false) : void
      {
         if(selectedHeroIndex == -1 || resync)
         {
            setActiveAvatarAsCurrentSelection();
         }
         hideWeaponComparison();
         if(selectedHeroIndex < mCurrentStartIndex || selectedHeroIndex >= mCurrentStartIndex + mHeroSlots.length)
         {
            setCurrentIndexToShowSelectedHero();
         }
         populateHeroSlots();
         setEquipWeaponSlots();
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
         applyAvatarAlerts();
         applyWeaponComparison();
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
      
      private function heroClicked(heroElement:HeroElement, owned:Boolean) : void
      {
         if(!mAllowSelectingUnownedHeroes && !owned)
         {
            return;
         }
         var _loc3_:uint = mHeroSlots.indexOf(heroElement) + mCurrentStartIndex;
         if(selectedHeroIndex == _loc3_)
         {
            return;
         }
         selectedHeroIndex = _loc3_;
         determineSelectedElement();
         setEquipWeaponSlots();
         if(mHeroSelectedCallback != null)
         {
            mHeroSelectedCallback(heroElement.gmHero,owned);
         }
      }
      
      public function setEquipWeaponSlots() : void
      {
         var _loc4_:uint = 0;
         var _loc1_:int = 0;
         if(selectedHeroIndex >= mDBFacade.gameMaster.Heroes.length)
         {
            return;
         }
         _loc4_ = 0;
         while(_loc4_ < mEquipElements.length)
         {
            mEquipElements[_loc4_].clear();
            _loc4_++;
         }
         var _loc2_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mDBFacade.gameMaster.Heroes[selectedHeroIndex].Id);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Vector.<ItemInfo> = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(_loc2_.id);
         if(_loc3_.length > 3)
         {
            Logger.warn("Avatar has more than three equipped items.  Equipping first three.");
         }
         mDBFacade.steamAchievementsHelper.unlockThreeLegendaryWeapons(_loc3_);
         _loc4_ = 0;
         while(_loc4_ < mEquipElements.length)
         {
            if(_loc4_ >= _loc3_.length)
            {
               break;
            }
            _loc1_ = int(_loc3_[_loc4_].avatarSlot);
            if(_loc1_ >= mEquipElements.length)
            {
               Logger.warn("Item instance id: " + _loc3_[_loc4_].databaseId + " is equipped to an invalid slot: " + _loc3_[_loc4_].avatarSlot);
            }
            else if(_loc3_.length > _loc4_)
            {
               if(mEquipElements[_loc1_].itemInfo != null)
               {
                  Logger.warn("Equipped items contains multiple items assigned to the same slot. First itemId: " + mEquipElements[_loc1_].itemInfo.gmId + ". Second itemId: " + _loc3_[_loc4_].gmId + ".  Slot: " + _loc3_[_loc4_].avatarSlot);
               }
               else
               {
                  mEquipElements[_loc1_].itemInfo = _loc3_[_loc4_];
               }
            }
            _loc4_++;
         }
      }
      
      public function equipItemOnCurrentAvatar(info:InventoryBaseInfo, itemSlot:uint, responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var equipServiceResponse:Function;
         var equippingModal:DBUIPopup;
         var avatarId:uint;
         var avatarInfo:AvatarInfo = currentlySelectedAvatarInfo;
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
            equippingModal = createEquippingModal();
            avatarId = avatarInfo.id;
            mDBFacade.dbAccountInfo.inventoryInfo.equipItemOnAvatar(avatarId,info.databaseId,itemSlot,equipServiceResponse,closeEquippingModalOnError(equippingModal,errorCallback));
         }
      }
      
      public function unequipItem(info:InventoryBaseInfo, responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var equippingModal:DBUIPopup = createEquippingModal();
         var equipServiceResponse:Function = function():void
         {
            equippingModal.destroy();
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         };
         mDBFacade.dbAccountInfo.inventoryInfo.unequipItemOffAvatar(info,equipServiceResponse,closeEquippingModalOnError(equippingModal,errorCallback));
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
      
      public function highlightItem(info:InventoryBaseInfo) : void
      {
         var _loc2_:AvatarEquipElement = null;
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
      
      public function handleItemDrop(dropObject:UIObject, itemInfo:InventoryBaseInfo, equipSlot:uint) : Boolean
      {
         var equipElement:AvatarEquipElement;
         var uiInvItem:UIInventoryItem = dropObject as UIInventoryItem;
         if(uiInvItem && uiInvItem.info != null && uiInvItem.info is ItemInfo)
         {
            this.equipItemOnCurrentAvatar(ItemInfo(uiInvItem.info),equipSlot,mEquipResponseCallback);
            uiInvItem.dragSwapItem(itemInfo);
            return true;
         }
         equipElement = dropObject as AvatarEquipElement;
         if(equipElement && equipElement.itemInfo != null)
         {
            equipElement.reset();
            if(equipElement.equipSlot == equipSlot)
            {
               return true;
            }
            this.equipItemOnCurrentAvatar(equipElement.itemInfo,equipSlot,function():void
            {
               if(itemInfo)
               {
                  equipItemOnCurrentAvatar(itemInfo,equipElement.equipSlot,mEquipResponseCallback);
               }
               else
               {
                  mEquipResponseCallback();
               }
            },mEquipResponseCallback);
            return true;
         }
         return false;
      }
      
      public function getFirstHeroSlotUIObject() : UIObject
      {
         return mHeroSlots[0];
      }
      
      public function setupHeroWithEquipPickerMenuNavigation(returnObject:*) : void
      {
         mHeroSlots[0].isToTheLeftOf(mHeroSlots[1]);
         mHeroSlots[1].isToTheLeftOf(mHeroSlots[2]);
         mHeroSlots[2].isToTheLeftOf(mHeroSlots[3]);
         mHeroSlots[3].isToTheLeftOf(mHeroSlots[4]);
         mHeroSlots[4].isToTheLeftOf(mHeroSlots[5]);
         mHeroSlots[5].isToTheLeftOf(mHeroSlots[6]);
         mHeroSlots[6].isToTheLeftOf(mHeroSlots[7]);
         mHeroSlots[0].leftNavigationAdditionalInteraction = rotateRosterLeft;
         mHeroSlots[7].rightNavigationAdditionalInteraction = rotateRosterRight;
         mHeroSlots[0].upNavigation = returnObject;
         mHeroSlots[1].upNavigation = returnObject;
         mHeroSlots[2].upNavigation = returnObject;
         mHeroSlots[3].upNavigation = returnObject;
         mHeroSlots[4].upNavigation = returnObject;
         mHeroSlots[5].upNavigation = returnObject;
         mHeroSlots[6].upNavigation = returnObject;
         mHeroSlots[7].upNavigation = returnObject;
         mEquipElements[0].upNavigation = returnObject;
         mEquipElements[1].upNavigation = returnObject;
         mEquipElements[2].upNavigation = returnObject;
         mEquipElements[0].isToTheLeftOf(mEquipElements[1]);
         mEquipElements[1].isToTheLeftOf(mEquipElements[2]);
         mEquipElements[2].isToTheLeftOf(mHeroSlots[0]);
         mFirstSlotLeftNavigation = mEquipElements[2];
         updateFirstSlotLeftNavigation();
      }
      
      public function resetHeroWithEquipPickerMenuNavigation() : void
      {
         mFirstSlotLeftNavigation = null;
         mHeroSlots[0].clearNavigationAndInteractions();
         mHeroSlots[1].clearNavigationAndInteractions();
         mHeroSlots[2].clearNavigationAndInteractions();
         mHeroSlots[3].clearNavigationAndInteractions();
         mHeroSlots[4].clearNavigationAndInteractions();
         mHeroSlots[5].clearNavigationAndInteractions();
         mHeroSlots[6].clearNavigationAndInteractions();
         mHeroSlots[7].clearNavigationAndInteractions();
         mEquipElements[0].clearNavigationAndInteractions();
         mEquipElements[1].clearNavigationAndInteractions();
         mEquipElements[2].clearNavigationAndInteractions();
      }
   }
}

