package UI.Inventory.Chests
{
   import Account.AvatarInfo;
   import Account.ItemInfo;
   import Account.StoreServices;
   import Actor.Revealer;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderer;
   import Brain.Sound.SoundAsset;
   import Brain.Sound.SoundHandle;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Collections.IMapIterator;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMAttack;
   import GameMasterDictionary.GMChest;
   import GameMasterDictionary.GMModifier;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMOfferDetail;
   import GameMasterDictionary.GMRarity;
   import GameMasterDictionary.GMStackable;
   import GameMasterDictionary.GMWeaponAesthetic;
   import GameMasterDictionary.GMWeaponItem;
   import GameMasterDictionary.GMWeaponMastertype;
   import Sound.DBSoundComponent;
   import UI.Hud.UIHud;
   import UI.Inventory.UITapHoldTooltip;
   import UI.Modifiers.UIModifier;
   import UI.Popup.DBUIPopup;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class ChestRevealPopUp extends DBUIPopup
   {
      
      public static const popUpName:String = "reveal_chest_popup";
      
      private static const DESCRIPTION_MAX_LINES:int = 2;
      
      public static const SLOT_MACHINE_ANIMATION_WEAPON_NAME:String = "reveal_chest_slotMachine";
      
      public static const SLOT_MACHINE_ANIMATION_CONSUMABLE_NAME:String = "reveal_itemBox_slotMachine";
      
      public static const weaponMCName:String = "reveal_chest_weapon_total";
      
      public static const REVEALED_ITEM_WEAPON:uint = 1;
      
      public static const REVEALED_ITEM_STACKABLE:uint = 2;
      
      public static const REVEALED_ITEM_PET:uint = 3;
      
      private var mChestGM:GMChest;
      
      private var mSoundComponent:DBSoundComponent;
      
      private var mPopUpMC:MovieClip;
      
      private var mAnimationMC:MovieClip;
      
      private var mSlotMachineAnimationMC:MovieClip;
      
      private var mItemMC:MovieClip;
      
      private var mChestRenderer:MovieClipRenderer;
      
      private var mSlotMachineRenderer:MovieClipRenderer;
      
      private var mItemRenderer:MovieClipRenderer;
      
      private var mWeaponTextField:TextField;
      
      private var mItemName:String;
      
      private var mItemDesc:String;
      
      private var mRevealedItemIcon:MovieClip;
      
      private var mWeaponRevealer:Revealer;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mItemOfferId:uint;
      
      private var mRevealCloseCallback:Function;
      
      private var mWaitForWeaponFromServerPopUp:DBUIPopup;
      
      private var mUpdateToInventoryDone:Boolean;
      
      private var mItemType:uint;
      
      private var mRevealedItemId:uint;
      
      private var mRevealedItemLevel:uint;
      
      private var mRevealedGMOffer:GMOffer;
      
      private var mRevealedGMWeapon:GMWeaponItem;
      
      private var mRevealedItemInfo:ItemInfo;
      
      private var mModifiersList:Vector.<UIModifier>;
      
      private var mGoToStorageCallback:Function;
      
      private var mItemInfoCardMC:MovieClip;
      
      private var mItemInfoCardSellButton:UIButton;
      
      private var mItemInfoCardStoreButton:UIButton;
      
      private var mItemInfoCardEquipButton:UIButton;
      
      private var mTapIcon:UIObject;
      
      private var mTapTooltip:UITapHoldTooltip;
      
      private var mHoldIcon:UIObject;
      
      private var mHoldTooltip:UITapHoldTooltip;
      
      private var mSound1:SoundAsset;
      
      private var mSound2:SoundAsset;
      
      private var mSound2Handle:SoundHandle;
      
      private var mSound3:SoundAsset;
      
      private var mSound4:SoundAsset;
      
      private var mChestOpenSfx:SoundAsset;
      
      private var mNewWeaponDBID:Number;
      
      public function ChestRevealPopUp(dbFacade:DBFacade, chestGM:GMChest, closeCallback:Function, goToStorageCallback:Function)
      {
         mChestGM = chestGM;
         mRevealCloseCallback = closeCallback;
         mGoToStorageCallback = goToStorageCallback;
         mSoundComponent = new DBSoundComponent(dbFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(dbFacade,"ChestRevealPopUp");
         super(dbFacade,"","",null,false,true,null,false,false);
         mItemOfferId = 0;
         mUpdateToInventoryDone = false;
         mNewWeaponDBID = 0;
         mModifiersList = new Vector.<UIModifier>();
         loadSounds();
      }
      
      private static function growUpToFit(field:TextField) : void
      {
         var _loc2_:Number = (field.textHeight + 4) * field.scaleY;
         if(_loc2_ > field.height)
         {
            field.y -= _loc2_ - field.height;
            field.height = _loc2_;
         }
      }
      
      override protected function getSwfPath() : String
      {
         return mChestGM.InventoryRevealSwf;
      }
      
      private function loadSounds() : void
      {
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH),"guitar_wank07",function(param1:SoundAsset):void
         {
            mSound1 = param1;
         });
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH),"guitar_wank18",function(param1:SoundAsset):void
         {
            mSound2 = param1;
         });
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH),"guitar_wank21",function(param1:SoundAsset):void
         {
            mSound3 = param1;
         });
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH),"guitar_wank26",function(param1:SoundAsset):void
         {
            mSound4 = param1;
         });
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH),"chestKeyOpen",function(param1:SoundAsset):void
         {
            mChestOpenSfx = param1;
         });
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         var bounds:Rectangle;
         var rarity:GMRarity;
         var openAnimation:Class;
         var slotMachineAnimation:Class;
         var weaponClass:Class;
         var itemInfoCardSwfClass:Class;
         mSwfAsset = swfAsset;
         var backgroundSwfClass:Class = swfAsset.getClass("reveal_chest_popup");
         mPopUpMC = new backgroundSwfClass() as MovieClip;
         mPopup = mPopUpMC;
         mRoot.addChild(mPopUpMC);
         TextUtil.setText(mPopUpMC.title_label,GameMasterLocale.getGameMasterSubString("CHEST_NAME",mChestGM.Rarity));
         mPopUpMC.scaleX = mPopUpMC.scaleY = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
         bounds = mPopUpMC.getBounds(mDBFacade.scalingRoot);
         mPopUpMC.x = mDBFacade.viewWidth / 2 - bounds.width / 2 - bounds.x;
         mPopUpMC.y = mDBFacade.viewHeight / 2 - bounds.height / 2 - bounds.y;
         TextUtil.setText(mPopUpMC.title_label,mChestGM.Name);
         rarity = mDBFacade.gameMaster.rarityByConstant.itemFor(mChestGM.Rarity);
         if(rarity != null && rarity.TextColor)
         {
            mPopUpMC.title_label.textColor = rarity.TextColor;
         }
         openAnimation = swfAsset.getClass(mChestGM.InventoryRevealName);
         mAnimationMC = new openAnimation() as MovieClip;
         slotMachineAnimation = swfAsset.getClass(UIHud.isThisAConsumbleChestId(mChestGM.Id) ? "reveal_itemBox_slotMachine" : "reveal_chest_slotMachine");
         mSlotMachineAnimationMC = new slotMachineAnimation() as MovieClip;
         weaponClass = swfAsset.getClass("reveal_chest_weapon_total");
         mItemMC = new weaponClass() as MovieClip;
         mWeaponTextField = mItemMC.reveal_chest_weaponTextField;
         if(mSlotMachineAnimationMC.reveal_chest_forgeTextField)
         {
            mSlotMachineAnimationMC.reveal_chest_forgeTextField.visible = false;
         }
         mCloseButton = new UIButton(mDBFacade,mPopUpMC.close);
         mCloseButton.visible = false;
         mCloseButton.enabled = false;
         mCloseButton.releaseCallback = preCloseCallback;
         itemInfoCardSwfClass = swfAsset.getClass("item_card");
         mItemInfoCardMC = new itemInfoCardSwfClass() as MovieClip;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass("DR_charge_tooltip");
            mTapIcon = new UIObject(mDBFacade,mItemInfoCardMC.ability.tap_icon);
            mTapTooltip = new UITapHoldTooltip(mDBFacade,_loc2_);
            mTapIcon.tooltip = mTapTooltip;
            mTapIcon.tooltipPos = new Point(0,mTapIcon.root.height * 0.5);
            mTapTooltip.visible = false;
            mHoldIcon = new UIObject(mDBFacade,mItemInfoCardMC.ability.icon);
            mHoldTooltip = new UITapHoldTooltip(mDBFacade,_loc2_);
            mHoldIcon.tooltip = mHoldTooltip;
            mHoldIcon.tooltipPos = new Point(0,mHoldIcon.root.height * 0.5);
            mHoldTooltip.visible = false;
         });
         mPopUpMC.addChild(mItemInfoCardMC);
         mItemInfoCardMC.visible = false;
         revealChest();
      }
      
      private function revealChest() : void
      {
         var startRevealTime:Number;
         mPopUpMC.reveal_chest_slot.addChild(mAnimationMC);
         mChestRenderer = new MovieClipRenderer(mDBFacade,mAnimationMC);
         mChestRenderer.play(0,false);
         mLogicalWorkComponent.doLater(1.25,function(param1:GameClock):void
         {
            if(mChestOpenSfx)
            {
               mSoundComponent.playSfxOneShot(mChestOpenSfx);
            }
         });
         startRevealTime = UIHud.isThisAConsumbleChestId(mChestGM.Id) ? 0.125 : 2.2916666666666665;
         mLogicalWorkComponent.doLater(startRevealTime,revealSlotMachine);
      }
      
      private function revealSlotMachine(gameClock:GameClock = null) : void
      {
         mPopUpMC.reveal_chest_slot.removeChild(mAnimationMC);
         mChestRenderer.destroy();
         mChestRenderer = null;
         if(mSound2)
         {
            mSound2Handle = mSoundComponent.playSfxManaged(mSound2);
            mSound2Handle.play(10);
         }
         mPopUpMC.reveal_chest_slot.addChild(mSlotMachineAnimationMC);
         mSlotMachineRenderer = new MovieClipRenderer(mDBFacade,mSlotMachineAnimationMC);
         mSlotMachineRenderer.play(0,true);
         mLogicalWorkComponent.doLater(UIHud.isThisAConsumbleChestId(mChestGM.Id) ? 1.375 : 2,startCheckForRevealWeapon);
      }
      
      public function updateRevealLoot(details:*) : void
      {
         var offerId:uint;
         var weaponId:uint;
         var swfPath:String;
         var iconClass:String;
         var name:String;
         var unlockMetricsDetails:Object;
         var offerDetail:GMOfferDetail;
         var gmStackable:GMStackable;
         var gmPet:GMNpc;
         var aesthetic:GMWeaponAesthetic;
         mDBFacade.steamAchievementsHelper.addValueToStatInt(1,"CHESTS_OPENED");
         unlockMetricsDetails = {};
         unlockMetricsDetails.isWeapon = false;
         mNewWeaponDBID = 0;
         if(details.hasOwnProperty("NewWeaponDetails"))
         {
            if(details.NewWeaponDetails != null)
            {
               mNewWeaponDBID = details.NewWeaponDetails.id;
               unlockMetricsDetails.isWeapon = true;
            }
            offerId = details.OfferId as uint;
            weaponId = details.WeaponId as uint;
         }
         else if(details.hasOwnProperty("customResult"))
         {
            if(details.customResult.hasOwnProperty("purchasedChestResults"))
            {
               if(details.customResult.purchasedChestResults.NewWeaponDetails != null)
               {
                  mNewWeaponDBID = details.customResult.purchasedChestResults.NewWeaponDetails.id;
                  unlockMetricsDetails.isWeapon = true;
               }
               offerId = details.customResult.purchasedChestResults.OfferId as uint;
               weaponId = details.customResult.purchasedChestResults.WeaponId as uint;
            }
         }
         mRevealedGMOffer = mDBFacade.gameMaster.offerById.itemFor(offerId);
         if(!mRevealedGMOffer)
         {
            mRevealedItemInfo = mDBFacade.dbAccountInfo.inventoryInfo.items.itemFor(weaponId);
            if(!mRevealedItemInfo)
            {
               Logger.warn("Can\'t find gmOffer or itemInfo for loot with offerId: " + offerId.toString() + " and weaponId: " + weaponId.toString());
               return;
            }
            unlockMetricsDetails.lootLevel = mRevealedItemInfo.requiredLevel;
            unlockMetricsDetails.lootPower = mRevealedItemInfo.power;
            if(mRevealedItemInfo.modifiers.length > 0)
            {
               unlockMetricsDetails.lootMod1 = mRevealedItemInfo.modifiers[0].Constant;
            }
            if(mRevealedItemInfo.modifiers.length > 1)
            {
               unlockMetricsDetails.lootMod2 = mRevealedItemInfo.modifiers[1].Constant;
            }
            if(mRevealedItemInfo.legendaryModifier > 0)
            {
               unlockMetricsDetails.legendaryModifier = mRevealedItemInfo.legendaryModifier;
            }
            mRevealedGMWeapon = mRevealedItemInfo.gmWeaponItem;
            mItemType = 1;
            mItemOfferId = mRevealedGMWeapon.Id;
         }
         else
         {
            mItemType = 2;
            mItemOfferId = mRevealedGMOffer.Id;
         }
         if(mItemType == 2)
         {
            if(mRevealedGMOffer.IsBundle)
            {
               swfPath = mRevealedGMOffer.BundleSwfFilepath;
               iconClass = mRevealedGMOffer.BundleIcon;
               name = GameMasterLocale.getGameMasterSubString("BUNDLE_OFFER_NAME",mRevealedGMOffer.Id.toString());
               mItemType = 2;
               mRevealedItemId = offerId;
            }
            else if(mRevealedGMOffer.Details && mRevealedGMOffer.Details.length > 0)
            {
               for each(offerDetail in mRevealedGMOffer.Details)
               {
                  if(offerDetail.StackableId)
                  {
                     gmStackable = mDBFacade.gameMaster.stackableById.itemFor(offerDetail.StackableId);
                     swfPath = gmStackable.UISwfFilepath;
                     iconClass = gmStackable.IconName;
                     name = GameMasterLocale.getGameMasterSubString("STACKABLE_NAME",gmStackable.Constant);
                     mItemType = 2;
                     mRevealedItemId = offerDetail.StackableId;
                  }
                  else if(offerDetail.PetId)
                  {
                     gmPet = mDBFacade.gameMaster.npcById.itemFor(offerDetail.PetId);
                     swfPath = gmPet.IconSwfFilepath;
                     iconClass = gmPet.IconName;
                     name = GameMasterLocale.getGameMasterSubString("PET_NAME",gmPet.Constant);
                     mItemType = 3;
                     mRevealedItemId = offerDetail.PetId;
                  }
               }
            }
         }
         else
         {
            mRevealedItemId = mItemOfferId;
            mRevealedItemLevel = mRevealedItemInfo.requiredLevel;
            aesthetic = mRevealedGMWeapon.getWeaponAesthetic(mRevealedItemLevel,mRevealedItemInfo.legendaryModifier > 0);
            swfPath = aesthetic.IconSwf;
            iconClass = aesthetic.IconName;
            name = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",aesthetic.Constant);
            mItemType = 1;
         }
         mItemName = name;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass(iconClass);
            mRevealedItemIcon = new _loc2_() as MovieClip;
         });
         unlockMetricsDetails.chestId = mChestGM.Id;
         unlockMetricsDetails.rarity = mChestGM.Rarity;
         unlockMetricsDetails.chestName = mChestGM.Name;
         unlockMetricsDetails.lootName = mItemName;
         unlockMetricsDetails.lootId = mRevealedItemId;
         mDBFacade.metrics.log("ChestUnlockResult",unlockMetricsDetails);
      }
      
      private function startCheckForRevealWeapon(gameClock:GameClock = null) : void
      {
         mLogicalWorkComponent.doEveryFrame(checkForRevealWeapon);
      }
      
      private function checkForRevealWeapon(gameClock:GameClock = null) : void
      {
         if(mItemOfferId > 0)
         {
            revealWeapon();
         }
      }
      
      private function revealWeapon() : void
      {
         if(mSound2Handle)
         {
            mSound2Handle.destroy();
            mSound2Handle = null;
         }
         if(UIHud.isThisAConsumbleChestId(mChestGM.Id))
         {
            if(mSound4)
            {
               mSoundComponent.playSfxOneShot(mSound4);
            }
         }
         else if(mSound1)
         {
            mSoundComponent.playSfxOneShot(mSound1);
         }
         mLogicalWorkComponent.clear();
         mSlotMachineRenderer.destroy();
         mPopUpMC.reveal_chest_slot.removeChild(mSlotMachineAnimationMC);
         mCloseButton.visible = true;
         mCloseButton.enabled = true;
         mItemInfoCardMC.visible = true;
         mItemRenderer = new MovieClipRenderer(mDBFacade,mItemMC);
         mItemRenderer.play(0,false);
         setupRevealedItemUI();
         mUpdateToInventoryDone = true;
      }
      
      private function setupRevealedItemUI() : void
      {
         var weaponType:String;
         var levelRequirement:String;
         var power:String;
         var chargeAttack:GMAttack;
         var chargeAttackName:String;
         var gmWeaponItem:GMWeaponItem;
         var gmMasterTypeVector:Vector.<GMWeaponMastertype>;
         var vi:int;
         var weaponRequiredLevel:uint;
         var bgColoredExists:Boolean;
         var bgSwfPath:String;
         var bgIconName:String;
         var gmStackable:GMStackable;
         var gmOffer:GMOffer;
         var gmPet:GMNpc;
         var j:uint;
         var powerStarMC:MovieClip;
         var defenseStarMC:MovieClip;
         var speedStarMC:MovieClip;
         var stagePos:Point;
         var swfPath:String;
         var iconName:String;
         var swfPath1:String;
         var iconName1:String;
         var preNameModifiers:String;
         var modifierList:Vector.<GMModifier>;
         var i:int;
         var isWeapon:Boolean = false;
         var isEquippable:Boolean = true;
         var typeOfUnequippable:uint = 0;
         var currentlySelectedAvatarInfo:AvatarInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
         var price:uint = 0;
         var isSellable:Boolean = false;
         mItemInfoCardMC.number_label.visible = false;
         if(mItemType == 1)
         {
            mItemInfoCardMC.ability.visible = true;
            mItemInfoCardMC.pet_stats.visible = false;
            mRevealedItemIcon.scaleX = mRevealedItemIcon.scaleY = 0.5;
            gmWeaponItem = mDBFacade.gameMaster.weaponItemById.itemFor(mRevealedItemId);
            mItemDesc = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_DESCRIPTION",gmWeaponItem.getWeaponAesthetic(mRevealedItemLevel,mRevealedItemInfo.legendaryModifier > 0).WeaponItemConstant);
            isWeapon = isSellable = true;
            mItemName = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",gmWeaponItem.getWeaponAesthetic(mRevealedItemLevel,mRevealedItemInfo.legendaryModifier > 0).Constant);
            gmMasterTypeVector = mDBFacade.gameMaster.WeaponMastertypes;
            vi = 0;
            while(vi < gmMasterTypeVector.length)
            {
               if(gmMasterTypeVector[vi].Constant == gmWeaponItem.MasterType)
               {
                  weaponType = GameMasterLocale.getGameMasterSubString("WEAPON_MASTERTYPE",gmMasterTypeVector[vi].Constant).toUpperCase();
               }
               vi = vi + 1;
            }
            weaponRequiredLevel = mRevealedItemLevel;
            levelRequirement = Locale.getString("REQUIRES_LEVEL") + weaponRequiredLevel.toString();
            power = mRevealedItemInfo.power.toString();
            if(gmWeaponItem.ChargeAttack)
            {
               chargeAttack = mDBFacade.gameMaster.attackByConstant.itemFor(gmWeaponItem.ChargeAttack);
               if(chargeAttack)
               {
                  chargeAttackName = "MAKO" + chargeAttack.Name.toUpperCase();
               }
            }
            if(currentlySelectedAvatarInfo && currentlySelectedAvatarInfo.levelForWeaponComparison >= weaponRequiredLevel)
            {
               isEquippable = true;
            }
            else
            {
               isEquippable = false;
               typeOfUnequippable = 1;
            }
            if(isEquippable)
            {
               if(currentlySelectedAvatarInfo && mDBFacade.dbAccountInfo.inventoryInfo.canAvatarEquipThisMasterType(currentlySelectedAvatarInfo,gmWeaponItem.MasterType))
               {
                  isEquippable = true;
               }
               else
               {
                  isEquippable = false;
                  typeOfUnequippable = 2;
               }
            }
            bgColoredExists = mRevealedItemInfo.rarity.HasColoredBackground;
            bgSwfPath = mRevealedItemInfo.rarity.BackgroundSwf;
            bgIconName = mRevealedItemInfo.rarity.BackgroundIcon;
            if(bgColoredExists)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset):void
               {
                  var _loc3_:MovieClip = null;
                  var _loc2_:Class = param1.getClass(bgIconName);
                  if(_loc2_)
                  {
                     _loc3_ = new _loc2_() as MovieClip;
                     mItemInfoCardMC.item_icon.addChildAt(_loc3_,0);
                  }
               });
            }
            price = uint(mRevealedItemInfo.sellCoins);
         }
         else if(mItemType == 2)
         {
            mItemInfoCardMC.ability.visible = false;
            mItemInfoCardMC.pet_stats.visible = false;
            mItemInfoCardMC.icon_slot.x += 100;
            mItemInfoCardMC.item_icon.x += 100;
            mItemInfoCardMC.item_card_frame.x += 100;
            mRevealedItemIcon.scaleX = mRevealedItemIcon.scaleY = 0.6;
            gmStackable = mDBFacade.gameMaster.stackableById.itemFor(mRevealedItemId);
            if(gmStackable == null)
            {
               gmOffer = mDBFacade.gameMaster.offerById.itemFor(mRevealedItemId);
               mItemDesc = GameMasterLocale.getGameMasterSubString("BUNDLE_OFFER_DESCRIPTION",gmOffer.Id.toString());
               if(gmOffer.Details.length > 0)
               {
                  if(gmOffer.Details[0].StackableId)
                  {
                     mItemInfoCardMC.number_label.visible = true;
                     TextUtil.setText(mItemInfoCardMC.number_label,"x" + gmOffer.Details[0].StackableCount.toString());
                     mItemInfoCardMC.number_label.x += 100;
                  }
               }
            }
            else
            {
               mItemDesc = GameMasterLocale.getGameMasterSubString("STACKABLE_DESCRIPTION",gmStackable.Constant);
            }
         }
         else if(mItemType == 3)
         {
            mItemInfoCardMC.ability.visible = false;
            mItemInfoCardMC.pet_stats.visible = true;
            mRevealedItemIcon.scaleX = mRevealedItemIcon.scaleY = 1;
            gmPet = mDBFacade.gameMaster.npcById.itemFor(mRevealedItemId);
            mItemDesc = GameMasterLocale.getGameMasterSubString("PET_DESCRIPTION",gmPet.Constant);
            j = 1;
            while(j <= 5)
            {
               powerStarMC = mItemInfoCardMC.pet_stats.pet_stats_power.getChildByName("star" + j.toString());
               defenseStarMC = mItemInfoCardMC.pet_stats.pet_stats_power.getChildByName("star" + j.toString());
               speedStarMC = mItemInfoCardMC.pet_stats.pet_stats_power.getChildByName("star" + j.toString());
               powerStarMC.visible = gmPet.AttackRating >= j;
               defenseStarMC.visible = gmPet.DefenseRating >= j;
               speedStarMC.visible = gmPet.SpeedRating >= j;
               j = j + 1;
            }
         }
         mItemInfoCardMC.item_icon.addChildAt(mRevealedItemIcon,1);
         mItemInfoCardMC.weapon_type_label_unequippable.visible = false;
         mItemInfoCardMC.weapon_type_label.visible = false;
         mItemInfoCardMC.level_requirement_not_met.visible = false;
         mItemInfoCardMC.level_requirement.visible = false;
         if(isWeapon)
         {
            mItemInfoCardMC.weapon_type_label_unequippable.visible = typeOfUnequippable == 2;
            mItemInfoCardMC.weapon_type_label.visible = typeOfUnequippable != 2;
            mItemInfoCardMC.level_requirement_not_met.visible = typeOfUnequippable == 1;
            mItemInfoCardMC.level_requirement.visible = typeOfUnequippable != 1;
            TextUtil.setText(mItemInfoCardMC.weapon_type_label,weaponType);
            TextUtil.setText(mItemInfoCardMC.level_requirement,levelRequirement);
            TextUtil.setText(mItemInfoCardMC.weapon_type_label_unequippable,weaponType);
            TextUtil.setText(mItemInfoCardMC.level_requirement_not_met,levelRequirement);
         }
         switch(int(typeOfUnequippable))
         {
            case 0:
               setDescription(mItemDesc);
               break;
            case 1:
               setDescription(Locale.getString("ITEM_CARD_UNUSABLE_LEVEL"));
               break;
            case 2:
               setDescription(Locale.getString("ITEM_CARD_UNUSABLE_MASTERCLASS"));
         }
         Locale.setText(mItemInfoCardMC.ability.label_tap,"TAP");
         Locale.setText(mItemInfoCardMC.ability.label,"HOLD");
         if(isWeapon)
         {
            mPopUpMC.title_label.textColor = mRevealedItemInfo.getTextColor();
            mItemInfoCardMC.description.textColor = mRevealedItemInfo.getTextColor();
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
                        stagePos.y += mTapIcon.root.height * 0.5;
                        mTapIcon.tooltipPos = stagePos;
                     }
                  });
               }
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
         }
         if(isWeapon)
         {
            Locale.setText(mItemInfoCardMC.power.attack_label,"POWER");
            TextUtil.setText(mItemInfoCardMC.power.label,power);
         }
         else
         {
            mItemInfoCardMC.power.visible = false;
         }
         mItemInfoCardMC.unequippable.visible = !isEquippable;
         mItemInfoCardSellButton = new UIButton(mDBFacade,mItemInfoCardMC.sell);
         Locale.setText(mItemInfoCardSellButton.label,"ITEM_CARD_SELL");
         mItemInfoCardSellButton.visible = isSellable;
         mItemInfoCardSellButton.enabled = isSellable;
         if(isSellable)
         {
            TextUtil.setText(mItemInfoCardMC.sell.sell_text,price.toString());
         }
         mItemInfoCardSellButton.releaseCallback = sellRevealedItem;
         mItemInfoCardStoreButton = new UIButton(mDBFacade,mItemInfoCardMC.store);
         Locale.setText(mItemInfoCardStoreButton.label,"KEEP");
         mItemInfoCardStoreButton.releaseCallback = function():void
         {
            preCloseCallback(true);
         };
         mItemInfoCardEquipButton = new UIButton(mDBFacade,mItemInfoCardMC.equip);
         Locale.setText(mItemInfoCardEquipButton.label,"ITEM_CARD_EQUIP");
         if(isEquippable)
         {
            mItemInfoCardEquipButton.releaseCallback = goToStorage;
         }
         else
         {
            mItemInfoCardEquipButton.releaseCallback = function():void
            {
               goToStorage(false);
            };
         }
         mItemInfoCardEquipButton.visible = isWeapon;
         mItemInfoCardEquipButton.enabled = isWeapon && isEquippable;
         if(isWeapon)
         {
            preNameModifiers = "";
            modifierList = mRevealedItemInfo.modifiers;
            Locale.setText(mItemInfoCardMC.ability.label_modifier,"MODIFIERS");
            i = 0;
            while(i < modifierList.length)
            {
               mModifiersList.push(new UIModifier(mDBFacade,mItemInfoCardMC.ability.getChildByName("modifier_icon_" + (i + 1).toString()) as MovieClip,modifierList[i].Constant));
               preNameModifiers += GameMasterLocale.getGameMasterSubString("MODIFIER_NAME",modifierList[i].Constant) + " ";
               i = i + 1;
            }
            mItemName = preNameModifiers + mItemName;
            if(mRevealedItemInfo.legendaryModifier > 0)
            {
               mModifiersList.push(new UIModifier(mDBFacade,mItemInfoCardMC.ability.getChildByName("modifier_icon_3") as MovieClip,"",0,true,mRevealedItemInfo.legendaryModifier));
               mItemName = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",mRevealedItemInfo.gmWeaponItem.getWeaponAesthetic(0,true).Constant);
            }
         }
         TextUtil.setText(mPopUpMC.title_label,mItemName.toUpperCase());
         if(mItemType == 1 || mItemType == 3)
         {
            mDBFacade.menuNavigationController.pushNewLayer("POPUP_WEAPON_CHEST_REVEALER",closeFromNavigationCallback,mItemInfoCardStoreButton,mItemInfoCardEquipButton);
            mItemInfoCardSellButton.isToTheLeftOf(mItemInfoCardStoreButton);
            mItemInfoCardStoreButton.isToTheLeftOf(mItemInfoCardEquipButton);
            mCloseButton.isAbove(mItemInfoCardEquipButton);
            mItemInfoCardSellButton.upNavigation = mCloseButton;
            mItemInfoCardStoreButton.upNavigation = mCloseButton;
         }
         else if(mItemType == 2)
         {
            mDBFacade.menuNavigationController.pushNewLayer("POPUP_WEAPON_CHEST_REVEALER",closeFromNavigationCallback,mItemInfoCardStoreButton,mItemInfoCardStoreButton);
            mCloseButton.isAbove(mItemInfoCardStoreButton);
         }
      }
      
      private function setDescription(text:String) : void
      {
         var _loc2_:TextField = mItemInfoCardMC.description;
         TextUtil.setText(_loc2_,text,1.55);
         if(_loc2_.numLines > 2)
         {
            TextUtil.setText(_loc2_,text);
         }
         growUpToFit(_loc2_);
      }
      
      private function sellRevealedItem() : void
      {
         var _loc1_:GMWeaponItem = null;
         var _loc3_:uint = 0;
         var _loc2_:IMapIterator = null;
         var _loc4_:ItemInfo = null;
         if(mItemType == 1)
         {
            _loc1_ = mDBFacade.gameMaster.weaponItemById.itemFor(mRevealedItemId);
            _loc3_ = mNewWeaponDBID;
            if(_loc3_ == 0)
            {
               Logger.error(" sellRevealedItem  had to find a weapon .. arg  Somethign is rong ");
               _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.items.iterator() as IMapIterator;
               while(_loc2_.hasNext() && _loc3_ == 0)
               {
                  _loc2_.next();
                  _loc4_ = _loc2_.current as ItemInfo;
                  if(_loc4_.gmWeaponItem.Id == _loc1_.Id)
                  {
                     _loc3_ = _loc4_.databaseId;
                     break;
                  }
               }
            }
            else
            {
               Logger.info("sellRevealedItem  Selling Weapon id :" + _loc3_.toString());
            }
            StoreServices.sellWeapon(mDBFacade,_loc3_,sellSuccessFunction,sellFailureFunction);
         }
         mItemInfoCardSellButton.enabled = false;
      }
      
      private function sellSuccessFunction(details:*) : void
      {
         preCloseCallback();
      }
      
      private function sellFailureFunction(e:Error) : void
      {
         Logger.error("Trying to sell revealed item but failed");
      }
      
      private function closeFromNavigationCallback() : void
      {
         preCloseCallback();
      }
      
      private function preCloseCallback(keptItem:Boolean = false) : void
      {
         mUpdateToInventoryDone = true;
         if(mRevealCloseCallback != null)
         {
            mRevealCloseCallback(mItemType,mItemOfferId,keptItem);
         }
         else
         {
            this.destroy();
         }
      }
      
      private function goToStorage(callEquip:Boolean = true) : void
      {
         mUpdateToInventoryDone = true;
         if(mGoToStorageCallback != null)
         {
            mGoToStorageCallback(mItemType,mItemOfferId,callEquip);
         }
         else
         {
            mDBFacade.mainStateMachine.enterTownInventoryState(mItemType,mItemOfferId,callEquip);
            preCloseCallback();
         }
      }
      
      override public function destroy() : void
      {
         if(mDBFacade == null)
         {
            return;
         }
         if(mHoldTooltip)
         {
            mHoldTooltip.destroy();
         }
         if(mHoldIcon)
         {
            mHoldIcon.destroy();
         }
         mDBFacade.menuNavigationController.popLayer("POPUP_WEAPON_CHEST_REVEALER");
         mHoldTooltip = null;
         mHoldIcon = null;
         if(mModifiersList.length > 0)
         {
            for each(var _loc1_:UIModifier in mModifiersList)
            {
               _loc1_.destroy();
            }
         }
         mModifiersList = null;
         mChestGM = null;
         if(mChestRenderer)
         {
            mChestRenderer.destroy();
         }
         mChestRenderer = null;
         if(mSlotMachineRenderer)
         {
            mSlotMachineRenderer.destroy();
         }
         mSlotMachineRenderer = null;
         if(mItemRenderer)
         {
            mItemRenderer.destroy();
         }
         mItemRenderer = null;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mWeaponRevealer)
         {
            mWeaponRevealer.destroy();
            mWeaponRevealer = null;
         }
         mAnimationMC = null;
         mSlotMachineAnimationMC = null;
         mPopUpMC = null;
         mSoundComponent.destroy();
         mSoundComponent = null;
         mSound1 = null;
         mSound2 = null;
         if(mSound2Handle)
         {
            mSound2Handle.destroy();
         }
         mSound3 = null;
         mChestOpenSfx = null;
         super.destroy();
      }
   }
}

