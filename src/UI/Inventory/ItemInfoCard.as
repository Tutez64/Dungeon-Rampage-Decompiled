package UI.Inventory
{
   import Account.AvatarInfo;
   import Account.InventoryBaseInfo;
   import Account.ItemInfo;
   import Account.PetInfo;
   import Account.StackableInfo;
   import Account.StoreServicesController;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.SceneGraph.SceneGraphManager;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.MemoryTracker;
   import DBGlobals.DBGlobal;
   import DistributedObjects.DistributedDungeonSummary;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMModifier;
   import GameMasterDictionary.GMWeaponItem;
   import GameMasterDictionary.GMWeaponMastertype;
   import UI.EquipPicker.HeroWithEquipPicker;
   import UI.EquipPicker.PetsWithEquipPicker;
   import UI.Modifiers.UIModifier;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class ItemInfoCard extends UIObject
   {
      
      private static const ITEM_CARD_LEVEL_REQUIREMENT:String = "ITEM_CARD_LEVEL_REQUIREMENT";
      
      private static const ITEM_CARD_UNLOCK_AT_LEVEL:String = "ITEM_CARD_UNLOCK_AT_LEVEL";
      
      protected var mDBFacade:DBFacade;
      
      protected var mInfo:InventoryBaseInfo;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mHoldIcon:UIObject;
      
      private var mHoldTooltip:UITapHoldTooltip;
      
      private var mTapIcon:UIObject;
      
      private var mTapTooltip:UITapHoldTooltip;
      
      private var mHoldManaIcon:MovieClip;
      
      private var mTapManaIcon:MovieClip;
      
      private var mDescription:TextField;
      
      private var mItemParent:UIObject;
      
      private var mIcon:MovieClip;
      
      private var mRenderer:MovieClipRenderController;
      
      private var mLabel:TextField;
      
      private var mPowerIcon:MovieClip;
      
      private var mPowerLabel:TextField;
      
      private var mLevelRequirement:TextField;
      
      private var mLevelRequirementNotMet:TextField;
      
      private var mSellPriceLabel:TextField;
      
      private var mSellButton:UIButton;
      
      private var mEquipButton:UIButton;
      
      private var mCloseButton:UIButton;
      
      private var mWeaponTypeLabel:TextField;
      
      private var mWeaponTypeUnequippableLabel:TextField;
      
      private var mModifierTitle:TextField;
      
      private var mModifiersList:Vector.<UIModifier>;
      
      private var mEquipPopup:EquipItemToSlotPopup;
      
      private var mSellItemCallback:Function;
      
      private var mTakeItemCallback:Function;
      
      private var mHeroEquipPicker:HeroWithEquipPicker;
      
      private var mPetEquipPicker:PetsWithEquipPicker;
      
      private var mRefreshInventoryCallback:Function;
      
      private var mDungeonSummary:DistributedDungeonSummary;
      
      private var mEventComponent:EventComponent;
      
      private var mWeaponDescTooltip:UIWeaponDescTooltip;
      
      private var mOriginalXValueForIcon:Number;
      
      private var mOriginalPosForEquipButton:Point;
      
      protected var mTitleY:Number;
      
      private var mEquipLimitTF:TextField;
      
      public function ItemInfoCard(dbFacade:DBFacade, root:MovieClip, chargeTooltipClass:Class, heroEquipPicker:HeroWithEquipPicker, petEquipPicker:PetsWithEquipPicker, refreshInventoryCallback:Function, dungeonSummary:DistributedDungeonSummary, allowCloseButton:Boolean = true, sellItemCallback:Function = null, takeItemCallback:Function = null, closeButtonCallback:Function = null)
      {
         super(dbFacade,root);
         mDBFacade = dbFacade;
         mHeroEquipPicker = heroEquipPicker;
         mPetEquipPicker = petEquipPicker;
         mRefreshInventoryCallback = refreshInventoryCallback;
         mDungeonSummary = dungeonSummary;
         mTakeItemCallback = takeItemCallback;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mRoot.pet_stats.visible = false;
         mRoot.ability.label_charge.text = Locale.getString("HOLD");
         mHoldIcon = new UIObject(mDBFacade,mRoot.ability.icon);
         mHoldManaIcon = mRoot.ability.mana_icon_hold;
         mHoldManaIcon.visible = false;
         mTapManaIcon = mRoot.ability.mana_icon_tap;
         mTapManaIcon.visible = false;
         mHoldTooltip = new UITapHoldTooltip(mDBFacade,chargeTooltipClass);
         mHoldIcon.tooltip = mHoldTooltip;
         mHoldIcon.tooltipPos = new Point(0,mHoldIcon.root.height * 0.5);
         mHoldTooltip.visible = false;
         mRoot.ability.label_tap.text = Locale.getString("TAP");
         mTapIcon = new UIObject(mDBFacade,mRoot.ability.tap_icon);
         mTapTooltip = new UITapHoldTooltip(mDBFacade,chargeTooltipClass);
         mTapIcon.tooltip = mTapTooltip;
         mTapIcon.tooltipPos = new Point(0,mTapIcon.root.height * 0.5);
         mTapTooltip.visible = false;
         mDescription = mRoot.description;
         mItemParent = new UIObject(mDBFacade,mRoot.item_icon);
         mOriginalXValueForIcon = mRoot.item_icon.x;
         mWeaponTypeLabel = mRoot.weapon_type_label;
         mWeaponTypeLabel.visible = false;
         mWeaponTypeUnequippableLabel = mRoot.weapon_type_label_unequippable;
         mWeaponTypeUnequippableLabel.visible = false;
         mLabel = mRoot.label;
         mTitleY = mLabel.y;
         mPowerIcon = mRoot.power;
         mPowerLabel = mRoot.power.label;
         mRoot.power.attack_label.text = Locale.getString("POWER");
         mLevelRequirement = mRoot.level_requirement;
         mLevelRequirementNotMet = mRoot.level_requirement_not_met;
         mModifierTitle = mRoot.ability.label_modifier;
         mModifiersList = new Vector.<UIModifier>();
         mSellButton = new UIButton(mDBFacade,mRoot.sell);
         mSellButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mSellButton.label.text = Locale.getString("ITEM_CARD_SELL");
         mSellPriceLabel = mRoot.sell.sell_text as TextField;
         mSellPriceLabel.text = "";
         mSellButton.enabled = false;
         mSellItemCallback = sellItemCallback;
         mSellButton.pressCallback = function():void
         {
            mSellItemCallback(mInfo);
         };
         mRoot.pet_stats.visible = false;
         mEquipButton = new UIButton(mDBFacade,mRoot.equip);
         mEquipButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mOriginalPosForEquipButton = new Point(mEquipButton.root.x,mEquipButton.root.y);
         mCloseButton = new UIButton(mDBFacade,mRoot.close);
         mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mCloseButton.releaseCallback = closeButtonCallback;
         mCloseButton.visible = allowCloseButton;
         mEquipLimitTF = mRoot.equipLimit;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass("weapon_desc_tooltip");
            mWeaponDescTooltip = new UIWeaponDescTooltip(mDBFacade,_loc2_);
            mWeaponDescTooltip.place(0,70);
            mItemParent.tooltip = mWeaponDescTooltip;
            mWeaponDescTooltip.visible = false;
         });
         this.visible = false;
      }
      
      public function enableCloseButton(callback:Function) : void
      {
         mCloseButton.visible = true;
         mCloseButton.releaseCallback = callback;
      }
      
      override public function destroy() : void
      {
         mTapTooltip.destroy();
         mTapIcon.destroy();
         mHoldTooltip.destroy();
         mHoldIcon.destroy();
         mTapTooltip = null;
         mTapIcon = null;
         mHoldTooltip = null;
         mHoldIcon = null;
         mWeaponDescTooltip.destroy();
         if(mModifiersList.length > 0)
         {
            for each(var _loc1_:UIModifier in mModifiersList)
            {
               _loc1_.destroy();
            }
         }
         mModifiersList = null;
         mDBFacade = null;
         mAssetLoadingComponent.destroy();
         mEventComponent.destroy();
         mSellButton.destroy();
         mEquipButton.destroy();
         mCloseButton.destroy();
         if(mRenderer)
         {
            mRenderer.destroy();
         }
         super.destroy();
      }
      
      public function set info(info:InventoryBaseInfo) : void
      {
         var _loc2_:ItemInfo = null;
         var _loc3_:StackableInfo = null;
         if(mEquipPopup != null)
         {
            mEquipPopup.destroy();
            mEquipPopup = null;
         }
         mInfo = info;
         if(mInfo == null)
         {
            mRoot.visible = false;
         }
         else if(mInfo is ItemInfo)
         {
            _loc2_ = mInfo as ItemInfo;
            setupWeaponItemInfoUI(_loc2_);
            setupWeaponItemUI(_loc2_,_loc2_.avatarId != 0);
            mRoot.visible = true;
         }
         else if(mInfo is StackableInfo)
         {
            _loc3_ = mInfo as StackableInfo;
            setupStackableItemInfoUI(_loc3_);
            setupStackableInfoUI(_loc3_.isEquipped);
            mRoot.visible = true;
         }
         else if(mInfo is PetInfo)
         {
            setupPetInfoUI();
            mRoot.visible = true;
         }
      }
      
      public function clear() : void
      {
         mInfo = null;
         mRoot.visible = false;
         if(mEquipPopup != null)
         {
            mEquipPopup.destroy();
            mEquipPopup = null;
         }
      }
      
      private function setupInventoryBaseUI(type:String) : void
      {
         var _loc2_:uint = uint(mInfo.sellCoins);
         mSellButton.enabled = true;
         mSellButton.visible = true;
         mSellPriceLabel.text = _loc2_.toString();
         mSellPriceLabel.visible = true;
         mRoot.pet_stats.visible = false;
         if(type == "weapon")
         {
            mLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",mInfo.weaponAestheticConstant).toUpperCase();
            mDescription.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",mInfo.weaponAestheticConstant);
         }
         else if(type == "stackable")
         {
            mLabel.text = GameMasterLocale.getGameMasterSubString("STACKABLE_NAME",mInfo.gmInventoryBase.Constant).toUpperCase();
            mDescription.text = GameMasterLocale.getGameMasterSubString("STACKABLE_DESCRIPTION",mInfo.gmInventoryBase.Constant);
         }
         else
         {
            mLabel.text = mInfo.Name.toUpperCase();
            mDescription.text = mInfo.Description;
         }
         mModifierTitle.visible = false;
         clearModifiers();
         loadIcon();
         mEquipButton.root.x = mOriginalPosForEquipButton.x;
         mEquipButton.root.y = mOriginalPosForEquipButton.y;
         mEquipLimitTF.visible = false;
      }
      
      private function setupStackableInfoUI(equipped:Boolean) : void
      {
         mRoot.ability.visible = false;
         mDescription.visible = true;
         mWeaponDescTooltip.visible = false;
         this.setupInventoryBaseUI("stackable");
         mRoot.icon_slot.x = mOriginalXValueForIcon + 55;
         mItemParent.root.x = mOriginalXValueForIcon + 55;
         var _loc2_:StackableInfo = mInfo as StackableInfo;
         if(_loc2_ == null)
         {
            return;
         }
         mSellButton.visible = false;
         mSellButton.enabled = false;
         mSellPriceLabel.visible = false;
         var _loc3_:uint = 1;
         mEquipButton.enabled = equipped ? true : _loc3_ == 1;
         mEquipButton.root.x = mOriginalPosForEquipButton.x - 60;
         mEquipButton.root.y = mOriginalPosForEquipButton.y - 10;
         mLevelRequirement.visible = false;
         mLevelRequirementNotMet.visible = false;
         mWeaponTypeUnequippableLabel.visible = false;
         mWeaponTypeLabel.visible = false;
         mPowerIcon.visible = false;
         mPowerLabel.visible = false;
         mRoot.unequippable.visible = false;
         if(mEquipButton.visible)
         {
            mEquipLimitTF.visible = true;
            mEquipLimitTF.y = 115;
            mEquipLimitTF.text = Locale.getString("EQUIP_LIMIT") + _loc2_.gmStackable.EquipLimit.toString();
         }
         else
         {
            mEquipLimitTF.visible = false;
         }
         this.greyOffer(false);
      }
      
      private function setupPetInfoUI() : void
      {
         var petInfo:PetInfo;
         var sellBackPrice:uint;
         mEquipButton.root.x = mOriginalPosForEquipButton.x;
         mEquipButton.root.y = mOriginalPosForEquipButton.y;
         mSellPriceLabel.visible = true;
         mEquipLimitTF.visible = false;
         mRoot.ability.visible = false;
         mDescription.visible = true;
         mWeaponDescTooltip.visible = false;
         mRoot.icon_slot.x = mOriginalXValueForIcon;
         mItemParent.root.x = mOriginalXValueForIcon;
         petInfo = mInfo as PetInfo;
         if(petInfo == null)
         {
            return;
         }
         mRoot.pet_stats.pet_stats_power.label.text = Locale.getString("TAVERN_ATTACK_LABEL");
         mRoot.pet_stats.pet_stats_speed.label.text = Locale.getString("TAVERN_SPEED_LABEL");
         mRoot.pet_stats.pet_stats_defense.label.text = Locale.getString("TAVERN_DEFENSE_LABEL");
         mRoot.pet_stats.petname_label.visible = false;
         mRoot.pet_stats.visible = true;
         mRoot.pet_stats.pet_stats_power.star1.visible = true;
         mRoot.pet_stats.pet_stats_power.star2.visible = true;
         mRoot.pet_stats.pet_stats_power.star3.visible = true;
         mRoot.pet_stats.pet_stats_power.star4.visible = true;
         mRoot.pet_stats.pet_stats_power.star5.visible = true;
         if(petInfo.attackRating < 5)
         {
            mRoot.pet_stats.pet_stats_power.star5.visible = false;
            if(petInfo.attackRating < 4)
            {
               mRoot.pet_stats.pet_stats_power.star4.visible = false;
               if(petInfo.attackRating < 3)
               {
                  mRoot.pet_stats.pet_stats_power.star3.visible = false;
                  if(petInfo.attackRating < 2)
                  {
                     mRoot.pet_stats.pet_stats_power.star2.visible = false;
                     if(petInfo.attackRating < 1)
                     {
                        mRoot.pet_stats.pet_stats_power.star1.visible = false;
                     }
                  }
               }
            }
         }
         mRoot.pet_stats.pet_stats_defense.star1.visible = true;
         mRoot.pet_stats.pet_stats_defense.star2.visible = true;
         mRoot.pet_stats.pet_stats_defense.star3.visible = true;
         mRoot.pet_stats.pet_stats_defense.star4.visible = true;
         mRoot.pet_stats.pet_stats_defense.star5.visible = true;
         if(petInfo.defenseRating < 5)
         {
            mRoot.pet_stats.pet_stats_defense.star5.visible = false;
            if(petInfo.defenseRating < 4)
            {
               mRoot.pet_stats.pet_stats_defense.star4.visible = false;
               if(petInfo.defenseRating < 3)
               {
                  mRoot.pet_stats.pet_stats_defense.star3.visible = false;
                  if(petInfo.defenseRating < 2)
                  {
                     mRoot.pet_stats.pet_stats_defense.star2.visible = false;
                     if(petInfo.defenseRating < 1)
                     {
                        mRoot.pet_stats.pet_stats_defense.star1.visible = false;
                     }
                  }
               }
            }
         }
         mRoot.pet_stats.pet_stats_speed.star1.visible = true;
         mRoot.pet_stats.pet_stats_speed.star2.visible = true;
         mRoot.pet_stats.pet_stats_speed.star3.visible = true;
         mRoot.pet_stats.pet_stats_speed.star4.visible = true;
         mRoot.pet_stats.pet_stats_speed.star5.visible = true;
         if(petInfo.speedRating < 5)
         {
            mRoot.pet_stats.pet_stats_speed.star5.visible = false;
            if(petInfo.speedRating < 4)
            {
               mRoot.pet_stats.pet_stats_speed.star4.visible = false;
               if(petInfo.speedRating < 3)
               {
                  mRoot.pet_stats.pet_stats_speed.star3.visible = false;
                  if(petInfo.speedRating < 2)
                  {
                     mRoot.pet_stats.pet_stats_speed.star2.visible = false;
                     if(petInfo.speedRating < 1)
                     {
                        mRoot.pet_stats.pet_stats_speed.star1.visible = false;
                     }
                  }
               }
            }
         }
         mSellButton.visible = true;
         mSellButton.enabled = true;
         sellBackPrice = uint(petInfo.gmNpc.SellCoins);
         mSellPriceLabel.text = sellBackPrice.toString();
         mLabel.text = GameMasterLocale.getGameMasterSubString("PET_NAME",petInfo.gmNpc.Constant).toUpperCase();
         mDescription.text = GameMasterLocale.getGameMasterSubString("PET_DESCRIPTION",petInfo.gmNpc.Constant);
         loadIcon();
         if(petInfo.EquippedHero == 0)
         {
            mEquipButton.visible = true;
            mEquipButton.enabled = true;
            mEquipButton.label.text = Locale.getString("ITEM_CARD_EQUIP");
            mEquipButton.releaseCallback = function():void
            {
               mPetEquipPicker.handleItemDrop(null,petInfo,1);
            };
         }
         else
         {
            mEquipButton.visible = true;
            mEquipButton.enabled = true;
            mEquipButton.label.text = Locale.getString("ITEM_CARD_UNEQUIP");
            mEquipButton.releaseCallback = function():void
            {
               mPetEquipPicker.unequipPet(petInfo);
            };
         }
         mLevelRequirement.visible = false;
         mLevelRequirementNotMet.visible = false;
         mWeaponTypeUnequippableLabel.visible = false;
         mWeaponTypeLabel.visible = false;
         mPowerIcon.visible = false;
         mPowerLabel.visible = false;
         mRoot.unequippable.visible = false;
         this.greyOffer(false);
         if(sellBackPrice == 0)
         {
            mSellButton.visible = false;
            mEquipButton.root.x = mOriginalPosForEquipButton.x - 60;
            mEquipButton.root.y = mOriginalPosForEquipButton.y - 10;
         }
      }
      
      private function setupWeaponItemUI(itemInfo:ItemInfo, equipped:Boolean) : void
      {
         var weaponName:String;
         var stagePos:Point;
         var gmWeaponItem:GMWeaponItem;
         var power:uint;
         var sellBackPrice:uint;
         var swfPath:String;
         var iconName:String;
         var swfPath1:String;
         var iconName1:String;
         var currentlySelectedAvatarInfo:AvatarInfo;
         var canEquip:uint;
         var preNameModifiers:String;
         var modifierList:Vector.<GMModifier>;
         var i:int;
         var format:TextFormat;
         var sizeMult:Number;
         this.setupInventoryBaseUI("weapon");
         mRoot.ability.visible = true;
         mDescription.visible = false;
         mRoot.icon_slot.x = mOriginalXValueForIcon;
         mItemParent.root.x = mOriginalXValueForIcon;
         weaponName = "";
         weaponName = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",itemInfo.gmWeaponAesthetic.Constant).toUpperCase();
         gmWeaponItem = itemInfo.gmWeaponItem;
         power = itemInfo.power;
         sellBackPrice = uint(gmWeaponItem.SellCoins);
         mWeaponDescTooltip.setWeaponItem(gmWeaponItem,itemInfo.requiredLevel,itemInfo.legendaryModifier > 0);
         mWeaponDescTooltip.visible = true;
         while(mTapIcon.root.numChildren > 1)
         {
            mTapIcon.root.removeChildAt(1);
            mTapIcon.visible = false;
            mTapTooltip.visible = false;
         }
         if(gmWeaponItem.TapIcon && gmWeaponItem.TapIcon != "")
         {
            mTapIcon.visible = true;
            swfPath = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
            iconName = gmWeaponItem.TapIcon;
            if(swfPath && iconName)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
               {
                  var _loc2_:MovieClip = null;
                  var _loc3_:Class = param1.getClass(iconName);
                  if(_loc3_)
                  {
                     _loc2_ = new _loc3_();
                     _loc2_.scaleX = _loc2_.scaleY = 0.5;
                     mTapIcon.root.addChild(_loc2_);
                     mTapTooltip.setValues(GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_TAP_TITLE",gmWeaponItem.Constant),GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_TAP_DESCRIPTION",gmWeaponItem.Constant));
                     mTapTooltip.visible = true;
                     stagePos = new Point();
                     stagePos.y += mHoldIcon.root.height * 0.5;
                     mHoldIcon.tooltipPos = stagePos;
                  }
               });
            }
         }
         while(mHoldIcon.root.numChildren > 1)
         {
            mHoldIcon.root.removeChildAt(1);
            mHoldTooltip.visible = false;
         }
         if(gmWeaponItem.HoldIcon && gmWeaponItem.HoldIcon != "")
         {
            mHoldIcon.visible = true;
            swfPath1 = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
            iconName1 = gmWeaponItem.HoldIcon;
            if(swfPath1 && iconName1)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath1),function(param1:SwfAsset):void
               {
                  var _loc2_:MovieClip = null;
                  var _loc4_:String = null;
                  var _loc3_:Class = param1.getClass(iconName1);
                  if(_loc3_)
                  {
                     _loc2_ = new _loc3_();
                     _loc2_.scaleX = _loc2_.scaleY = 0.5;
                     mHoldIcon.root.addChild(_loc2_);
                     _loc4_ = gmWeaponItem.WeaponController != null ? GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_CONTROLLER",gmWeaponItem.WeaponController) : gmWeaponItem.HoldTitle;
                     mHoldTooltip.setValues(_loc4_,GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_HOLD_DESCRIPTION",gmWeaponItem.Constant));
                     mHoldTooltip.visible = true;
                     stagePos = new Point();
                     stagePos.y += mHoldIcon.root.height * 0.5;
                     mHoldIcon.tooltipPos = stagePos;
                  }
               });
            }
         }
         loadItemType(gmWeaponItem);
         mPowerIcon.visible = true;
         mPowerLabel.visible = true;
         mPowerLabel.text = power.toString();
         mLevelRequirement.text = Locale.getString("ITEM_CARD_LEVEL_REQUIREMENT") + itemInfo.requiredLevel;
         mLevelRequirementNotMet.text = Locale.getString("ITEM_CARD_LEVEL_REQUIREMENT") + itemInfo.requiredLevel;
         if(!mHeroEquipPicker || !mHeroEquipPicker.currentlySelectedHero)
         {
            currentlySelectedAvatarInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
         }
         else
         {
            currentlySelectedAvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroEquipPicker.currentlySelectedHero.Id);
         }
         canEquip = 1;
         if(currentlySelectedAvatarInfo && currentlySelectedAvatarInfo.level >= itemInfo.requiredLevel)
         {
            mLevelRequirement.visible = true;
            mLevelRequirementNotMet.visible = false;
         }
         else
         {
            mLevelRequirement.visible = false;
            mLevelRequirementNotMet.visible = true;
            canEquip = 2;
         }
         if(currentlySelectedAvatarInfo && mDBFacade.dbAccountInfo.inventoryInfo.canAvatarEquipThisMasterType(currentlySelectedAvatarInfo,gmWeaponItem.MasterType))
         {
            mWeaponTypeUnequippableLabel.visible = false;
            mWeaponTypeLabel.visible = true;
         }
         else
         {
            mWeaponTypeUnequippableLabel.visible = true;
            mWeaponTypeLabel.visible = false;
            canEquip = 3;
         }
         mEquipButton.enabled = equipped ? true : canEquip == 1;
         switch(int(canEquip) - 1)
         {
            case 0:
               mRoot.unequippable.visible = false;
               this.mDescription.text = mInfo.Description;
               this.greyOffer(false);
               break;
            case 1:
               mRoot.unequippable.visible = true;
               this.mDescription.text = Locale.getString("ITEM_CARD_UNUSABLE_LEVEL");
               this.greyOffer(true);
               break;
            case 2:
               mRoot.unequippable.visible = true;
               this.mDescription.text = Locale.getString("ITEM_CARD_UNUSABLE_MASTERCLASS");
               this.greyOffer(true);
         }
         mModifierTitle.visible = true;
         mModifierTitle.text = Locale.getString("MODIFIERS");
         preNameModifiers = "";
         modifierList = itemInfo.modifiers;
         i = 0;
         while(i < modifierList.length)
         {
            mModifiersList.push(new UIModifier(mDBFacade,mRoot.ability.getChildByName("modifier_icon_" + (i + 1).toString()) as MovieClip,modifierList[i].Constant));
            preNameModifiers += GameMasterLocale.getGameMasterSubString("MODIFIER_NAME",modifierList[i].Constant).toUpperCase() + " ";
            i = i + 1;
         }
         weaponName = preNameModifiers + mLabel.text;
         if(itemInfo.legendaryModifier > 0)
         {
            mModifiersList.push(new UIModifier(mDBFacade,mRoot.ability.getChildByName("modifier_icon_3") as MovieClip,"",0,true,itemInfo.legendaryModifier));
            weaponName = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",gmWeaponItem.getWeaponAesthetic(0,true).Constant);
         }
         format = new TextFormat();
         sizeMult = 0.1;
         if(weaponName.length <= 34)
         {
            format.size = 13;
            sizeMult = weaponName.length < 17 ? 0.2 : 0.1;
            mLabel.y = mTitleY + mLabel.height * sizeMult;
         }
         else
         {
            format.size = 12;
            mLabel.y = mTitleY;
         }
         if(weaponName.indexOf("VINTAGE") >= 0)
         {
            mSellButton.visible = false;
            mEquipButton.root.x = mOriginalPosForEquipButton.x - 60;
            mEquipButton.root.y = mOriginalPosForEquipButton.y - 10;
         }
         mLabel.defaultTextFormat = format;
         mLabel.text = weaponName;
         mLabel.text = mLabel.text.toUpperCase();
      }
      
      protected function clearModifiers() : void
      {
         if(mModifiersList.length > 0)
         {
            for each(var _loc1_:UIModifier in mModifiersList)
            {
               _loc1_.destroy();
            }
            mModifiersList.splice(0,mModifiersList.length);
         }
      }
      
      protected function greyOffer(value:Boolean) : void
      {
         var _loc4_:Vector.<DisplayObject> = new <DisplayObject>[mRoot.bg,mRoot.icon_slot,mRoot.ribbon,mHoldIcon.root,mTapIcon.root,mPowerIcon,mItemParent.root,mRoot.unequippable,mRoot.ability.modifier_icon_1,mRoot.ability.modifier_icon_2,mRoot.ability.modifier_icon_3];
         var _loc2_:ColorMatrixFilter = SceneGraphManager.getGrayScaleSaturationFilter(5);
         for each(var _loc3_:DisplayObject in _loc4_)
         {
            if(_loc3_)
            {
               _loc3_.filters = value ? [_loc2_] : [];
            }
         }
         mLabel.textColor = value ? 8947848 : mInfo.getTextColor();
      }
      
      public function buttonsVisible(makeVisible:Boolean) : void
      {
         mEquipButton.visible = makeVisible;
         mSellButton.visible = makeVisible;
      }
      
      private function setupWeaponItemInfoUI(itemInfo:ItemInfo) : void
      {
         mEquipButton.enabled = false;
         mEquipButton.visible = false;
         if(itemInfo.avatarId == 0)
         {
            mEquipButton.visible = true;
            mEquipButton.releaseCallback = loadEquipOnAvatarPopup;
            mEquipButton.label.text = Locale.getString("ITEM_CARD_EQUIP");
         }
         else if(mDBFacade.dbAccountInfo.inventoryInfo.isThereEmptySpaceInWeaponStorage())
         {
            mEquipButton.visible = true;
            mEquipButton.enabled = true;
            mEquipButton.releaseCallback = function():void
            {
               if(mInfo is ItemInfo)
               {
                  mDBFacade.dbAccountInfo.inventoryInfo.unequipItemOffAvatar(mInfo as ItemInfo,mRefreshInventoryCallback);
               }
               else
               {
                  if(!(mInfo is PetInfo))
                  {
                     Logger.error("Item id: " + mInfo.databaseId + " being unequipped is not an ItemInfo.");
                     return;
                  }
                  mDBFacade.dbAccountInfo.inventoryInfo.unequipPet(mInfo as PetInfo,mRefreshInventoryCallback);
               }
            };
            mEquipButton.label.text = Locale.getString("ITEM_CARD_UNEQUIP");
         }
      }
      
      private function unEquipConsumable(itemInfo:StackableInfo, successCallback:Function) : void
      {
         var _loc3_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroEquipPicker.currentlySelectedHero.Id);
         if(_loc3_ == null)
         {
            Logger.error("No avatar info found for currently selected hero type: " + mHeroEquipPicker.currentlySelectedHero.Id);
            return;
         }
         mDBFacade.dbAccountInfo.inventoryInfo.unequipConsumableOffAvatar(_loc3_.id,itemInfo.gmStackable.Id,itemInfo.equipSlot,successCallback);
      }
      
      private function setupStackableItemInfoUI(itemInfo:StackableInfo) : void
      {
         mEquipButton.enabled = false;
         mEquipButton.visible = false;
         if(itemInfo.gmId == 60001 || itemInfo.gmId == 60018)
         {
            return;
         }
         if(itemInfo.gmStackable.AccountBooster)
         {
            mEquipButton.visible = true;
            mEquipButton.releaseCallback = tryActivateAccountBooster;
            mEquipButton.label.text = Locale.getString("ITEM_CARD_USE");
         }
         else if(itemInfo.isEquipped == 0)
         {
            mEquipButton.visible = true;
            mEquipButton.releaseCallback = function():void
            {
               loadEquipOnAvatarPopup(true);
            };
            mEquipButton.label.text = Locale.getString("ITEM_CARD_EQUIP");
         }
         else
         {
            mEquipButton.visible = true;
            mEquipButton.enabled = true;
            mEquipButton.releaseCallback = function():void
            {
               if(mInfo is StackableInfo)
               {
                  unEquipConsumable(mInfo as StackableInfo,mRefreshInventoryCallback);
                  return;
               }
               Logger.error("Item id: " + mInfo.databaseId + " being unequipped is not an ItemInfo.");
            };
            mEquipButton.label.text = Locale.getString("ITEM_CARD_UNEQUIP");
         }
      }
      
      private function loadIcon() : void
      {
         var swfPath:String = mInfo.uiSwfFilepath;
         var iconName:String = mInfo.iconName;
         while(mItemParent.root.numChildren > 0)
         {
            mItemParent.root.removeChildAt(0);
         }
         ItemInfo.loadItemIcon(swfPath,iconName,mItemParent.root,mDBFacade,70,mInfo.iconScale,mAssetLoadingComponent,function():void
         {
            var bgColoredExists:Boolean = mInfo.hasColoredBackground;
            var bgSwfPath:String = mInfo.backgroundSwfPath;
            var bgIconName:String = mInfo.backgroundIconName;
            var bgIconBorderName:String = mInfo.backgroundIconBorderName;
            if(bgColoredExists)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset):void
               {
                  var _loc2_:MovieClip = null;
                  var _loc4_:MovieClip = null;
                  var _loc5_:Class = param1.getClass(bgIconBorderName);
                  if(_loc5_)
                  {
                     _loc2_ = new _loc5_() as MovieClip;
                     mItemParent.root.addChildAt(_loc2_,0);
                  }
                  var _loc3_:Class = param1.getClass(bgIconName);
                  if(_loc3_)
                  {
                     _loc4_ = new _loc3_() as MovieClip;
                     mItemParent.root.addChildAt(_loc4_,1);
                  }
               });
            }
         });
      }
      
      private function loadItemType(gmWeaponItem:GMWeaponItem) : void
      {
         var _loc3_:String = null;
         var _loc2_:GMWeaponMastertype = null;
         if(gmWeaponItem)
         {
            _loc3_ = gmWeaponItem.MasterType;
            _loc2_ = mDBFacade.gameMaster.weaponSubtypeByConstant.itemFor(_loc3_);
            if(_loc2_ != null)
            {
               mWeaponTypeLabel.visible = true;
               mWeaponTypeUnequippableLabel.visible = true;
               mWeaponTypeLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_NAME",gmWeaponItem.Constant).toUpperCase();
               mWeaponTypeUnequippableLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_NAME",gmWeaponItem.Constant).toUpperCase();
            }
            else
            {
               mWeaponTypeLabel.visible = false;
               mWeaponTypeUnequippableLabel.visible = false;
               Logger.error("Weapon master type not found: " + _loc3_);
            }
         }
      }
      
      public function loadEquipOnAvatarPopup(isConsumable:Boolean = false) : void
      {
         if(mEquipPopup != null)
         {
            mEquipPopup.destroy();
         }
         var _loc4_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroEquipPicker.currentlySelectedHero.Id);
         if(_loc4_ == null)
         {
            Logger.error("No avatar info found for currently selected hero type: " + mHeroEquipPicker.currentlySelectedHero.Id);
            return;
         }
         var _loc2_:ItemInfo = mInfo as ItemInfo;
         var _loc3_:StackableInfo = mInfo as StackableInfo;
         if(_loc2_ == null && _loc3_ == null)
         {
            if(_loc3_ == null)
            {
               Logger.error("Current stackable info on ItemInfoCard is not an ItemInfo.  info databaseId: " + _loc3_.databaseId);
               return;
            }
            Logger.error("Current item info on ItemInfoCard is not an ItemInfo.  info databaseId: " + mInfo.databaseId);
            return;
         }
         mEquipPopup = new EquipItemToSlotPopup(mDBFacade,_loc4_.id,closeEquipCallback,isConsumable ? _loc3_ : _loc2_,null,isConsumable);
         MemoryTracker.track(mEquipPopup,"EquipItemToSlotPopup - created in ItemInfoCard.loadEquipOnAvatarPopup()");
      }
      
      public function tryActivateAccountBooster() : void
      {
         var _loc1_:StackableInfo = mInfo as StackableInfo;
         StoreServicesController.useAccountBooster(mDBFacade,_loc1_);
      }
      
      public function loadEquipOnAccountPopup() : void
      {
         if(mEquipPopup != null)
         {
            mEquipPopup.destroy();
         }
         var _loc1_:StackableInfo = mInfo as StackableInfo;
         if(_loc1_ == null)
         {
            Logger.error("Current item info on ItemInfoCard is not an StackableInfo.  info databaseId: " + mInfo.databaseId);
            return;
         }
         mEquipPopup = new EquipItemToSlotPopup(mDBFacade,-1,closeEquipCallback,_loc1_,clear);
         MemoryTracker.track(mEquipPopup,"EquipItemToSlotPopup - created in ItemInfoCard.loadEquipOnAccountPopup()");
      }
      
      private function closeEquipCallback() : void
      {
         if(mEquipPopup)
         {
            mEquipPopup.destroy();
            mEquipPopup = null;
         }
      }
   }
}

