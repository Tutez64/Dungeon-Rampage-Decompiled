package UI.Inventory
{
   import Account.AvatarInfo;
   import Account.ChestInfo;
   import Account.DBInventoryInfo;
   import Account.InventoryBaseInfo;
   import Account.ItemInfo;
   import Account.PetInfo;
   import Account.StackableInfo;
   import Account.StoreServicesController;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.UI.UIRadioButton;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Collections.IMapIterator;
   import Collections.Map;
   import DBGlobals.DBGlobal;
   import DistributedObjects.DistributedDungeonSummary;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMChest;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMInventoryBase;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMOfferDetail;
   import GameMasterDictionary.GMStackable;
   import GameMasterDictionary.GMWeaponItem;
   import Town.TownHeader;
   import UI.EquipPicker.HeroWithEquipPicker;
   import UI.EquipPicker.PetsWithEquipPicker;
   import UI.EquipPicker.StacksWithEquipPicker;
   import UI.EquipPicker.StuffWithEquipPicker;
   import UI.Hud.UIHud;
   import UI.Inventory.Chests.ChestInfoCard;
   import UI.Popup.DBUIOneButtonPopup;
   import UI.UIPagingPanel;
   import UI.UITownTweens;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class UIInventory
   {
      
      private static const SELECTED_TAB_SCALE:Number = 1.15;
      
      private static const NUM_GRID_ELEMENTS:uint = 15;
      
      private static const INV_SLOT_CLASS_NAME:String = "inv_slot";
      
      private static const WEAPON_TOOLTIP_CLASS_NAME:String = "DR_weapon_tooltip";
      
      public static const CHARGE_TOOLTIP_CLASS_NAME:String = "DR_charge_tooltip";
      
      public static const EQUIPPABLE_TRUE:uint = 1;
      
      public static const EQUIPPABLE_NOT_YET:uint = 2;
      
      public static const EQUIPPABLE_NEVER:uint = 3;
      
      private static const CATEGORY_ARRAY:Array = [GMInventoryBase.WEAPON_CATEGORY,GMInventoryBase.POWERUP_CATEGORY,GMInventoryBase.PET_CATEGORY,GMInventoryBase.STUFF_CATEGORY];
      
      private var mDBFacade:DBFacade;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mRoot:Sprite;
      
      private var mInventoryRoot:MovieClip;
      
      private var mSwfAsset:SwfAsset;
      
      private var mTownHeader:TownHeader;
      
      private var mDungeonRewardPanel:DungeonRewardPanel;
      
      private var mTabButtons:Map;
      
      private var mPagination:UIPagingPanel;
      
      private var mCurrentPage:uint = 0;
      
      private var mCurrentTab:String;
      
      private var mNextTab:String;
      
      private var mWantPets:Boolean = false;
      
      private var mItems:Vector.<UIInventoryItem>;
      
      private var mInventoryGridElements:Vector.<MovieClip>;
      
      private var mCategorizedItems:Map;
      
      private var mAddStorageButton:UIButton;
      
      private var mInfoCard:ItemInfoCard;
      
      private var mDungeonSummary:DistributedDungeonSummary;
      
      private var mDungeonSummaryInitialFocusSet:Boolean;
      
      private var mNewItemIds:Array;
      
      private var mNewChestIds:Array;
      
      private var mLastActedChestGmId:uint = 0;
      
      private var mNewStackableIds:Array;
      
      private var mNewPetIds:Array;
      
      private var mHeroWithEquipPicker:HeroWithEquipPicker;
      
      private var mStacksWithEquipPicker:StacksWithEquipPicker;
      
      private var mPetsWithEquipPicker:PetsWithEquipPicker;
      
      private var mStuffWithEquipPicker:StuffWithEquipPicker;
      
      private var mSelectedItemInfo:InventoryBaseInfo;
      
      private var mSelectedItemNavigationSource:UIObject;
      
      private var mBoosterNavigationItem:UIInventoryItem;
      
      private var mSelectedAvatar:uint;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mChestCard:ChestInfoCard;
      
      private var mAbandonChestPopUp:UIAbandonChestPopup;
      
      private var mChestOpenFullPopUp:DBUIOneButtonPopup;
      
      private var mEventComponent:EventComponent;
      
      private var mRevealedItemType:uint;
      
      private var mRevealedItemOfferId:uint;
      
      private var mRevealedShowEquip:Boolean;
      
      private var mConsumableChestCard:ChestInfoCard;
      
      private var mBoosterCard:BoosterInfoCard;
      
      private var mWeaponTabButton:UIRadioButton;
      
      private var mPotionsTabButton:UIRadioButton;
      
      private var mPetsTabButton:UIRadioButton;
      
      private var mStuffTabButton:UIRadioButton;
      
      private var mIsActiveCallback:Function;
      
      public function UIInventory(dbFacade:DBFacade, townHeader:TownHeader = null, dungeonSummary:DistributedDungeonSummary = null, isActiveCallback:Function = null)
      {
         super();
         mDBFacade = dbFacade;
         mTownHeader = townHeader;
         mDungeonSummary = dungeonSummary;
         mIsActiveCallback = isActiveCallback;
         mRevealedItemType = 0;
         mRevealedItemOfferId = 0;
         mRoot = new Sprite();
         if(mDBFacade.dbConfigManager.getConfigBoolean("want_pets",true))
         {
            mWantPets = true;
         }
         mTabButtons = new Map();
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIInventory");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIInventory");
         mInventoryGridElements = new Vector.<MovieClip>();
         mItems = new Vector.<UIInventoryItem>();
         mNewItemIds = [];
         mNewChestIds = [];
         mNewStackableIds = [];
         mNewPetIds = [];
         mEventComponent = new EventComponent(mDBFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),swfLoaded);
      }
      
      public function setRevealedState(type:uint, offerId:uint, showEquipOption:Boolean = false) : void
      {
         mRevealedItemType = type;
         mRevealedItemOfferId = offerId;
         mRevealedShowEquip = showEquipOption;
      }
      
      private function setSelectedAvatar(val:int) : void
      {
         mSelectedAvatar = val;
      }
      
      private function getSelectedAvatar() : int
      {
         return mSelectedAvatar;
      }
      
      public function get root() : Sprite
      {
         return mRoot;
      }
      
      private function swfLoaded(swfAsset:SwfAsset) : void
      {
         mSwfAsset = swfAsset;
         var _loc2_:Class = mSwfAsset.getClass("DR_UI_town_inventory");
         mInventoryRoot = new _loc2_() as MovieClip;
         mRoot.addChild(mInventoryRoot);
         var _loc3_:Class = swfAsset.getClass("DR_weapon_tooltip");
         var _loc4_:Class = swfAsset.getClass("avatar_tooltip");
         mInventoryRoot.pet_picker.visible = false;
         mInventoryRoot.potion_picker.visible = false;
         mInventoryRoot.stuff_picker.visible = false;
         mHeroWithEquipPicker = new HeroWithEquipPicker(mDBFacade,mInventoryRoot.weapon_picker,_loc3_,_loc4_,heroSelected,itemSelected,getSelectedAvatar,setSelectedAvatar,refresh,true,true,mIsActiveCallback);
         mStacksWithEquipPicker = new StacksWithEquipPicker(mDBFacade,mInventoryRoot.potion_picker,_loc3_,_loc4_,itemSelected,refresh,true,getSelectedAvatar,setSelectedAvatar,mIsActiveCallback);
         if(mWantPets)
         {
            mPetsWithEquipPicker = new PetsWithEquipPicker(mDBFacade,mInventoryRoot.pet_picker,_loc3_,_loc4_,itemSelected,getSelectedAvatar,setSelectedAvatar,refresh,true,mIsActiveCallback);
         }
         mStuffWithEquipPicker = new StuffWithEquipPicker(mDBFacade,mInventoryRoot.stuff_picker,_loc4_,getSelectedAvatar,setSelectedAvatar,mIsActiveCallback);
         mInventoryRoot.close.visible = false;
         var _loc5_:MovieClip = mInventoryRoot.treasure;
         if(mDungeonSummary)
         {
            mDungeonRewardPanel = new DungeonRewardPanel(mDBFacade,_loc5_,mDungeonSummary,itemSelected);
            Locale.setText(_loc5_.label,"LOOT");
         }
         else
         {
            _loc5_.visible = false;
         }
         buildCategories();
         setupUI(mInventoryRoot);
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",accountInfoUpdated);
      }
      
      private function accountInfoUpdated(evt:Event) : void
      {
         if(mIsActiveCallback == null || mIsActiveCallback())
         {
            refresh(false);
         }
      }
      
      public function hide() : void
      {
         mRoot.visible = false;
      }
      
      public function show(chestGM:GMChest) : void
      {
         mRoot.visible = true;
         mBoosterCard.hide();
         refresh(true);
         if(mDungeonSummary)
         {
            mDungeonRewardPanel.setChestAsSelected(chestGM);
         }
      }
      
      private function heroSelected(gmHero:GMHero, owned:Boolean) : void
      {
         if(gmHero == null)
         {
            return;
         }
         var _loc3_:GMHero = mDBFacade.gameMaster.Heroes[mSelectedAvatar];
         if(_loc3_.Id != gmHero.Id)
         {
            mDBFacade.dbAccountInfo.changeActiveAvatarRPC(gmHero.Id);
         }
         var _loc4_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(gmHero.Id);
         if(_loc4_ && mSelectedItemInfo is ChestInfo)
         {
            mChestCard.selectedHeroId = mSelectedAvatar;
            mChestCard.refreshHeroInfoUI();
            refresh(false,true);
         }
         else
         {
            refresh(false);
         }
      }
      
      private function determineEquippableItems(gmHero:GMHero) : void
      {
         var _loc7_:InventoryBaseInfo = null;
         var _loc6_:ItemInfo = null;
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:DBInventoryInfo = mDBFacade.dbAccountInfo.inventoryInfo;
         var _loc2_:AvatarInfo = _loc5_.getAvatarInfoForHeroType(gmHero.Id);
         _loc4_ = 0;
         while(_loc4_ < mItems.length)
         {
            _loc7_ = mItems[_loc4_].info;
            _loc6_ = _loc7_ as ItemInfo;
            if(_loc7_ && _loc6_ && _loc6_.gmWeaponItem)
            {
               _loc3_ = 1;
               if(_loc2_ == null)
               {
                  _loc3_ = 3;
               }
               else if(!_loc5_.canAvatarEquipThisMasterType(_loc2_,_loc6_.gmWeaponItem.MasterType))
               {
                  _loc3_ = 3;
               }
               else if(_loc2_.levelForWeaponComparison < _loc6_.requiredLevel)
               {
                  _loc3_ = 2;
               }
               mItems[_loc4_].equippable = _loc3_;
            }
            _loc4_++;
         }
      }
      
      private function sellItem(info:InventoryBaseInfo) : void
      {
         if(info != null)
         {
            if(info is ItemInfo || info is StackableInfo || info is PetInfo)
            {
               StoreServicesController.trySellItem(mDBFacade,info,function():void
               {
                  var _loc1_:int = 0;
                  if(info is ItemInfo)
                  {
                     _loc1_ = mNewItemIds.indexOf(info.databaseId);
                     if(_loc1_ != -1)
                     {
                        mNewItemIds.splice(_loc1_,1);
                     }
                  }
                  else if(info is StackableInfo)
                  {
                     _loc1_ = mNewStackableIds.indexOf(info.databaseId);
                     if(_loc1_ != -1)
                     {
                        mNewStackableIds.splice(_loc1_,1);
                     }
                  }
                  else if(info is PetInfo)
                  {
                     _loc1_ = mNewPetIds.indexOf(info.databaseId);
                     if(_loc1_ != -1)
                     {
                        mNewPetIds.splice(_loc1_,1);
                     }
                  }
                  refresh();
                  focusFirstInventoryItem();
               });
            }
            mSelectedItemInfo = null;
         }
         else
         {
            Logger.error("Trying to sell null item info.");
         }
      }
      
      private function takeItemCallback() : void
      {
         mSelectedItemInfo = null;
      }
      
      private function setupUI(root:MovieClip) : void
      {
         var chargeTooltipClass:Class;
         var group:String;
         var tabButton:UIRadioButton;
         var iter:IMapIterator;
         var itemTemplateClass:Class;
         var weaponTooltipClass:Class;
         var uiInventoryItem:UIInventoryItem;
         var i:uint;
         mInventoryRoot = root;
         if(mPagination)
         {
            mPagination.destroy();
            mPagination = null;
         }
         mPagination = new UIPagingPanel(mDBFacade,this.numPagesInCurrentCategory(),mInventoryRoot.grid_widget.pagination,mSwfAsset.getClass("pagination_button"),this.setCurrentPage);
         chargeTooltipClass = mSwfAsset.getClass("DR_charge_tooltip");
         mInfoCard = new ItemInfoCard(mDBFacade,root.item_card,chargeTooltipClass,mHeroWithEquipPicker,mPetsWithEquipPicker,refresh,mDungeonSummary,false,sellItem,takeItemCallback);
         mInfoCard.visible = false;
         if(mChestCard)
         {
            mChestCard.destroy();
            mChestCard = null;
         }
         mChestCard = new ChestInfoCard(mDBFacade,mSceneGraphComponent,root.inv_chests,abandonChest,openChest,abandonChestDS,openChestDS,keepChestDS,mIsActiveCallback);
         if(mConsumableChestCard)
         {
            mConsumableChestCard.destroy();
            mConsumableChestCard = null;
         }
         mConsumableChestCard = new ChestInfoCard(mDBFacade,mSceneGraphComponent,root.inv_consumable,abandonChest,openChest,abandonChestDS,openChestDS,keepChestDS,mIsActiveCallback);
         if(mBoosterCard)
         {
            mBoosterCard.destroy();
            mBoosterCard = null;
         }
         mBoosterCard = new BoosterInfoCard(mDBFacade,mSceneGraphComponent,root.booster_card,focusAfterBoosterActivation);
         group = "UIInventoryTabGroup";
         mWeaponTabButton = new UIRadioButton(mDBFacade,mInventoryRoot.grid_widget.tab_weapons,group);
         mPotionsTabButton = new UIRadioButton(mDBFacade,mInventoryRoot.grid_widget.tab_potions,group);
         mPetsTabButton = new UIRadioButton(mDBFacade,mInventoryRoot.grid_widget.tab_pets,group);
         mStuffTabButton = new UIRadioButton(mDBFacade,mInventoryRoot.grid_widget.tab_stuff,group);
         mTabButtons.add(GMInventoryBase.WEAPON_CATEGORY,mWeaponTabButton);
         Locale.setText(mInventoryRoot.grid_widget.tab_weapons.label,"TAB_LOOT");
         mTabButtons.add(GMInventoryBase.POWERUP_CATEGORY,mPotionsTabButton);
         Locale.setText(mInventoryRoot.grid_widget.tab_potions.label,"TAB_POWERUPS");
         if(mWantPets)
         {
            mTabButtons.add(GMInventoryBase.PET_CATEGORY,mPetsTabButton);
            Locale.setText(mInventoryRoot.grid_widget.tab_pets.label,"TAB_PETS");
         }
         mTabButtons.add(GMInventoryBase.STUFF_CATEGORY,mStuffTabButton);
         Locale.setText(mInventoryRoot.grid_widget.tab_stuff.label,"TAB_STUFF");
         iter = mTabButtons.iterator() as IMapIterator;
         while(iter.hasNext())
         {
            tabButton = iter.next();
            Locale.setText(tabButton.root.new_label,"INV_NEW");
            tabButton.root.new_label.visible = this.categoryHasAnyNewItems(iter.key);
            tabButton.root.category = iter.key;
            tabButton.releaseCallbackThis = function(param1:UIButton):void
            {
               showTab(param1.root.category);
            };
            tabButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            tabButton.selectedFilter = DBGlobal.UI_SELECTED_FILTER;
         }
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_0);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_1);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_2);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_3);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_4);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_5);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_6);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_7);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_8);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_9);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_10);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_11);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_12);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_13);
         mInventoryGridElements.push(mInventoryRoot.grid_widget.slot_14);
         itemTemplateClass = mSwfAsset.getClass("inv_slot");
         weaponTooltipClass = mSwfAsset.getClass("DR_weapon_tooltip");
         i = 0;
         while(i < mItems.length)
         {
            mItems[i].destroy();
            i = i + 1;
         }
         mItems.splice(0,mItems.length);
         i = 0;
         while(i < 15)
         {
            uiInventoryItem = new UIInventoryItem(mDBFacade,mInventoryGridElements[i],itemTemplateClass,weaponTooltipClass,itemSelected);
            mItems.push(uiInventoryItem);
            uiInventoryItem.visible = false;
            i = i + 1;
         }
         mAddStorageButton = new UIButton(mDBFacade,mInventoryRoot.grid_widget.add_storage_button);
         mAddStorageButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         Locale.setText(mAddStorageButton.label,"INV_ADD_STORAGE");
         mAddStorageButton.releaseCallback = function():void
         {
            StoreServicesController.showStoragePage(mDBFacade);
         };
         mAddStorageButton.visible = false;
      }
      
      private function closeEquipButton() : void
      {
      }
      
      private function currentChestStack(chestInfo:ChestInfo) : ChestInfo
      {
         if(chestInfo == null || chestInfo.isFromDungeonSummary())
         {
            return chestInfo;
         }
         var _loc3_:DBInventoryInfo = mDBFacade.dbAccountInfo.inventoryInfo;
         for each(var _loc2_:ChestInfo in _loc3_.chests)
         {
            if(_loc2_.containsDatabaseId(chestInfo.databaseId))
            {
               return _loc2_;
            }
         }
         return _loc3_.getChestStack(chestInfo.gmId);
      }
      
      private function abandonChest(chestInfo:ChestInfo) : void
      {
         var index:int;
         chestInfo = currentChestStack(chestInfo);
         if(chestInfo == null)
         {
            return;
         }
         if(mDBFacade.dbAccountInfo.inventoryInfo.isChestRequestPending(chestInfo.databaseId))
         {
            return;
         }
         if(!chestInfo.isFromDungeonSummary())
         {
            mLastActedChestGmId = chestInfo.gmId;
         }
         mAbandonChestPopUp = new UIAbandonChestPopup(mDBFacade,closeAbandonChestPopUp,function():void
         {
            mDBFacade.metrics.log("ChestAbandoned",{
               "chestId":chestInfo.gmChestInfo.Id,
               "rarity":chestInfo.rarity,
               "category":"storage"
            });
            mDBFacade.dbAccountInfo.inventoryInfo.dropChest(chestInfo.databaseId,dropChestSuccessfullCallback,abandonChestFailedPopUp);
            closeAbandonChestPopUp();
         });
         MemoryTracker.track(mAbandonChestPopUp,"UIAbandonChestPopup - created in UIInventory.abandonChest()");
         index = mNewChestIds.indexOf(chestInfo.databaseId);
         if(index != -1)
         {
            mNewChestIds.splice(index,1);
         }
      }
      
      private function closeAbandonChestPopUp() : void
      {
         mAbandonChestPopUp = null;
      }
      
      private function dropChestSuccessfullCallback(chestInstanceId:uint, details:*) : void
      {
         removeChestFromInventory(chestInstanceId);
         refresh(true);
         focusFirstInventoryItem();
      }
      
      private function returnFromOpenFullPopUp() : void
      {
         if(mChestOpenFullPopUp)
         {
            mChestOpenFullPopUp.destroy();
            mChestOpenFullPopUp = null;
         }
      }
      
      private function openChest(chestInfo:ChestInfo) : void
      {
         var _loc2_:DBInventoryInfo = null;
         var _loc5_:uint = 0;
         var _loc7_:uint = 0;
         var _loc3_:uint = 0;
         chestInfo = currentChestStack(chestInfo);
         if(chestInfo == null)
         {
            return;
         }
         if(!chestInfo.isFromDungeonSummary())
         {
            _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo;
            if(_loc2_.isChestRequestPending(chestInfo.databaseId))
            {
               return;
            }
            if(!_loc2_.hasRoomToOpenChest(chestInfo.gmId))
            {
               showChestOpenFullPopUp("UIInventory.openChest()");
               return;
            }
            mLastActedChestGmId = chestInfo.gmId;
         }
         var _loc4_:ChestInfoCard = mChestCard;
         if(UIHud.isThisAConsumbleChestId(chestInfo.gmChestInfo.Id))
         {
            _loc4_ = mConsumableChestCard;
         }
         if(_loc4_.canChestBeOpened())
         {
            if(chestInfo.isFromDungeonSummary())
            {
               mDungeonSummary.openChestFromInventory(chestInfo.gmChestInfo,true);
            }
            else
            {
               _loc4_.createRevealPopUp(closeRevealPopUp,goToStorage);
               _loc5_ = mHeroWithEquipPicker.currentlySelectedHero.Id;
               _loc7_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc5_).id;
               _loc3_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc5_).skinId;
               mDBFacade.dbAccountInfo.inventoryInfo.openChest(chestInfo.databaseId,_loc7_,_loc3_,updateRevealLoot,openChestFailedPopUp);
            }
         }
         else
         {
            _loc4_.showBuyKeysPopUp();
         }
         var _loc6_:int = mNewChestIds.indexOf(chestInfo.databaseId);
         if(_loc6_ != -1)
         {
            mNewChestIds.splice(_loc6_,1);
         }
      }
      
      public function goToStorage(itemType:uint, itemOfferId:uint, callEquip:Boolean) : void
      {
         mConsumableChestCard.closeChestRevealPopUp();
         mChestCard.closeChestRevealPopUp();
         mRevealedItemType = itemType;
         mRevealedItemOfferId = itemOfferId;
         mRevealedShowEquip = callEquip;
         refresh();
      }
      
      private function closeRevealPopUp(itemType:uint, itemOfferId:uint, keptItem:Boolean) : void
      {
         mRevealedItemType = itemType;
         mRevealedItemOfferId = itemOfferId;
         mConsumableChestCard.closeChestRevealPopUp();
         mChestCard.closeChestRevealPopUp();
         refresh();
         focusAfterChestReveal(itemType,keptItem);
      }
      
      private function focusAfterChestReveal(itemType:uint, keptItem:Boolean) : void
      {
         var _loc4_:UIObject = null;
         if(keptItem && itemType == 1)
         {
            for each(var _loc3_:UIInventoryItem in mItems)
            {
               if(_loc3_.info == mSelectedItemInfo && _loc3_.canBeFocused())
               {
                  _loc4_ = _loc3_;
                  break;
               }
            }
         }
         if(_loc4_ == null)
         {
            _loc4_ = getFirstFocusableInventoryItem();
         }
         if(_loc4_ != null)
         {
            mDBFacade.menuNavigationController.setFocusedUiObject(_loc4_);
         }
      }
      
      private function updateRevealLoot(chestInstanceId:uint, details:*) : void
      {
         mConsumableChestCard.updateRevealLoot(details);
         mChestCard.updateRevealLoot(details);
         removeChestFromInventory(chestInstanceId);
      }
      
      private function abandonChestDS(chestInfo:ChestInfo) : void
      {
         mAbandonChestPopUp = new UIAbandonChestPopup(mDBFacade,closeAbandonChestPopUp,function():void
         {
            mDBFacade.metrics.log("ChestAbandoned",{
               "chestId":chestInfo.gmChestInfo.Id,
               "rarity":chestInfo.rarity,
               "category":"storageFromDungeonSummary"
            });
            var _loc1_:uint = mDungeonSummary.findSlotForChest(chestInfo.gmChestInfo);
            mDungeonSummary.abandonChestFromInventory(_loc1_);
            focusFirstInventoryItem();
            closeAbandonChestPopUp();
         });
         MemoryTracker.track(mAbandonChestPopUp,"UIAbandonChestPopup - created in UIInventory.abandonChestDS()");
      }
      
      private function openChestDS(chestInfo:ChestInfo) : void
      {
         if(mDungeonSummary && !mDBFacade.dbAccountInfo.inventoryInfo.isThereEmptySpaceInWeaponStorage())
         {
            showChestOpenFullPopUp("UIInventory.openChestDS()");
            return;
         }
         openChest(chestInfo);
      }
      
      private function showChestOpenFullPopUp(createdIn:String) : void
      {
         if(mChestOpenFullPopUp)
         {
            return;
         }
         mChestOpenFullPopUp = new DBUIOneButtonPopup(mDBFacade,"POPUP_STORAGE_FULL",Locale.getString("STORAGE_FULL"),Locale.getString("CLEAR_INVENTORY"),Locale.getString("RETURN"),returnFromOpenFullPopUp,true,returnFromOpenFullPopUp);
         MemoryTracker.track(mChestOpenFullPopUp,"DBUIOneButtonPopup - created in " + createdIn);
         mSceneGraphComponent.addChild(mChestOpenFullPopUp.root,105);
      }
      
      private function keepChestDS(chestInfo:ChestInfo) : void
      {
         if(mDungeonSummary && !mDBFacade.dbAccountInfo.inventoryInfo.hasRoomForChest(chestInfo.gmId))
         {
            mChestOpenFullPopUp = new DBUIOneButtonPopup(mDBFacade,"POPUP_STORAGE_FULL",Locale.getString("STORAGE_FULL"),Locale.getString("CLEAR_INVENTORY"),Locale.getString("RETURN"),returnFromOpenFullPopUp,true,returnFromOpenFullPopUp);
            MemoryTracker.track(mChestOpenFullPopUp,"DBUIOneButtonPopup - created in UIInventory.keepChestDS()");
            mSceneGraphComponent.addChild(mChestOpenFullPopUp.root,105);
            return;
         }
         var _loc2_:uint = mDungeonSummary.findSlotForChest(chestInfo.gmChestInfo);
         mDungeonSummary.keepChestFromInventory(_loc2_,true);
      }
      
      private function abandonChestFailedPopUp() : void
      {
         mConsumableChestCard.closeChestRevealPopUp();
         mChestCard.closeChestRevealPopUp();
      }
      
      private function openChestFailedPopUp() : void
      {
         mConsumableChestCard.closeChestRevealPopUp();
         mChestCard.closeChestRevealPopUp();
         refresh();
      }
      
      private function removeChestFromInventory(chestInstanceId:uint) : void
      {
         mDBFacade.dbAccountInfo.inventoryInfo.removeChestRow(chestInstanceId);
         takeItemCallback();
      }
      
      private function categoryHasAnyNewItems(category:String) : Boolean
      {
         var _loc2_:Vector.<InventoryBaseInfo> = mCategorizedItems.itemFor(category);
         if(_loc2_ == null)
         {
            Logger.error("categoryHasAnyNewItems invalid category: " + category);
         }
         for each(var _loc3_:InventoryBaseInfo in _loc2_)
         {
            if(_loc3_.isNew)
            {
               return true;
            }
         }
         return false;
      }
      
      public function animateEntry() : void
      {
         if(mDBFacade.featureFlags.getFlagValue("want-town-animations"))
         {
            if(mTownHeader != null)
            {
               mTownHeader.rootMovieClip.visible = false;
               mLogicalWorkComponent.doLater(0.20833333333333334,function(param1:GameClock):void
               {
                  mTownHeader.animateHeader();
               });
            }
            mInventoryRoot.grid_widget.visible = false;
            mLogicalWorkComponent.doLater(0.16666666666666666,function(param1:GameClock):void
            {
               UITownTweens.rightPanelTweenSequence(mInventoryRoot.grid_widget,mDBFacade);
            });
            if(mCurrentTab != GMInventoryBase.WEAPON_CATEGORY)
            {
               return;
            }
            mHeroWithEquipPicker.root.visible = false;
            mLogicalWorkComponent.doLater(0.5,function(param1:GameClock):void
            {
               UITownTweens.footerTweenSequence(mHeroWithEquipPicker.root,mDBFacade);
            });
         }
      }
      
      private function buildCategories() : void
      {
         var _loc7_:String = null;
         var _loc9_:Vector.<InventoryBaseInfo> = undefined;
         var _loc10_:InventoryBaseInfo = null;
         var _loc5_:IMapIterator = null;
         mCategorizedItems = new Map();
         for each(_loc7_ in CATEGORY_ARRAY)
         {
            mCategorizedItems.add(_loc7_,new Vector.<InventoryBaseInfo>());
         }
         var _loc8_:Map = mDBFacade.dbAccountInfo.inventoryInfo.items;
         var _loc6_:Vector.<ChestInfo> = mDBFacade.dbAccountInfo.inventoryInfo.chests;
         var _loc3_:Map = mDBFacade.dbAccountInfo.inventoryInfo.stackables;
         var _loc1_:Map = mDBFacade.dbAccountInfo.inventoryInfo.pets;
         for each(var _loc4_:Map in [_loc8_,_loc3_,_loc1_])
         {
            _loc5_ = _loc4_.iterator() as IMapIterator;
            while(_loc5_.hasNext())
            {
               _loc10_ = _loc5_.next();
               if(_loc10_.gmInventoryBase)
               {
                  _loc7_ = _loc10_.gmInventoryBase.ItemCategory;
               }
               else
               {
                  _loc7_ = "PET";
               }
               _loc9_ = mCategorizedItems.itemFor(_loc7_);
               if(_loc9_ == null)
               {
                  Logger.error("No inventory category exists for weapon class type: " + _loc7_);
               }
               else
               {
                  _loc9_.push(_loc10_);
               }
            }
         }
         for each(var _loc2_:ChestInfo in _loc6_)
         {
            if(_loc2_.gmChestInfo)
            {
               _loc7_ = GMInventoryBase.WEAPON_CATEGORY;
               _loc9_ = mCategorizedItems.itemFor(_loc7_);
               if(_loc9_ == null)
               {
                  Logger.error("No inventory category exists for weapon class type: " + _loc7_);
               }
               else
               {
                  _loc9_.push(_loc2_);
               }
            }
         }
         sortCategories();
      }
      
      private function inventorySortComparator(sortKeyVector:Vector.<String>, infoA:InventoryBaseInfo, infoB:InventoryBaseInfo) : int
      {
         var _loc4_:GMWeaponItem = null;
         var _loc5_:GMWeaponItem = null;
         var _loc6_:AvatarInfo = null;
         var _loc11_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc10_:int = 0;
         var _loc12_:int = 0;
         if(infoA.isEquipped && !infoB.isEquipped)
         {
            return 1;
         }
         if(infoB.isEquipped && !infoA.isEquipped)
         {
            return -1;
         }
         if(infoA is ItemInfo && infoB is ItemInfo)
         {
            _loc4_ = ItemInfo(infoA).gmWeaponItem;
            _loc5_ = ItemInfo(infoB).gmWeaponItem;
            _loc6_ = this.mHeroWithEquipPicker.currentlySelectedAvatarInfo;
            if(_loc6_)
            {
               _loc11_ = mDBFacade.dbAccountInfo.inventoryInfo.canAvatarEquipThisMasterType(_loc6_,_loc4_.MasterType);
               _loc8_ = mDBFacade.dbAccountInfo.inventoryInfo.canAvatarEquipThisMasterType(_loc6_,_loc5_.MasterType);
               if(_loc11_ && !_loc8_)
               {
                  return -1;
               }
               if(_loc8_ && !_loc11_)
               {
                  return 1;
               }
               _loc9_ = mDBFacade.dbAccountInfo.inventoryInfo.canThisAvatarEquipThisItem(_loc6_,ItemInfo(infoA));
               _loc7_ = mDBFacade.dbAccountInfo.inventoryInfo.canThisAvatarEquipThisItem(_loc6_,ItemInfo(infoB));
               if(_loc9_ && !_loc7_)
               {
                  return -1;
               }
               if(_loc7_ && !_loc9_)
               {
                  return 1;
               }
            }
            if(sortKeyVector)
            {
               _loc10_ = sortKeyVector.indexOf(_loc4_.MasterType);
               _loc12_ = sortKeyVector.indexOf(_loc5_.MasterType);
               if(_loc10_ != _loc12_)
               {
                  return _loc10_ - _loc12_;
               }
            }
            return ItemInfo(infoB).requiredLevel - ItemInfo(infoA).requiredLevel;
         }
         if(infoA.gmId != infoB.gmId)
         {
            return infoB.gmId - infoA.gmId;
         }
         if(infoA is ChestInfo && infoB is ChestInfo)
         {
            return infoA.databaseId < infoB.databaseId ? -1 : (infoA.databaseId > infoB.databaseId ? 1 : 0);
         }
         return 0;
      }
      
      private function weaponSortComparator(infoA:InventoryBaseInfo, infoB:InventoryBaseInfo) : int
      {
         return this.inventorySortComparator(GMWeaponItem.ALL_WEAPON_SORT,infoA,infoB);
      }
      
      private function basicSortComparator(infoA:InventoryBaseInfo, infoB:InventoryBaseInfo) : int
      {
         return this.inventorySortComparator(null,infoA,infoB);
      }
      
      private function sortCategories() : void
      {
         var _loc2_:String = null;
         var _loc3_:Vector.<InventoryBaseInfo> = undefined;
         var _loc1_:IMapIterator = mCategorizedItems.iterator() as IMapIterator;
         while(_loc1_.hasNext())
         {
            _loc3_ = _loc1_.next();
            _loc2_ = _loc1_.key;
            var _loc4_:String = _loc2_;
            if(GMInventoryBase.WEAPON_CATEGORY !== _loc4_)
            {
               _loc3_.sort(basicSortComparator);
            }
            else
            {
               _loc3_.sort(weaponSortComparator);
            }
         }
      }
      
      public function refresh(resync:Boolean = false, dontRefreshChestSelection:Boolean = false) : void
      {
         var currentTabIsValidCategory:Boolean;
         var tabButton:UIRadioButton;
         var iter:IMapIterator;
         var gmHero:GMHero;
         var itemInfo:ItemInfo;
         var canEquip:Boolean;
         if(resync)
         {
            mBoosterCard.hide();
         }
         if(mTownHeader != null)
         {
            mTownHeader.title = Locale.getString("INVENTORY_HEADER");
         }
         mHeroWithEquipPicker.refresh(resync);
         mStacksWithEquipPicker.refresh(resync);
         if(mWantPets)
         {
            mPetsWithEquipPicker.refresh(resync);
         }
         mStuffWithEquipPicker.refresh(resync);
         buildCategories();
         if(mDungeonRewardPanel)
         {
            mDungeonRewardPanel.refresh();
         }
         currentTabIsValidCategory = CATEGORY_ARRAY.some(function(param1:*, param2:uint, param3:Array):Boolean
         {
            if(mCurrentTab == param1 as String)
            {
               return true;
            }
            return false;
         });
         if(!currentTabIsValidCategory)
         {
            mCurrentTab = GMInventoryBase.WEAPON_CATEGORY;
         }
         if(!dontRefreshChestSelection)
         {
            mSelectedItemInfo = checkIfRevealedWeaponExists();
            if(mSelectedItemInfo != null)
            {
               mLastActedChestGmId = 0;
            }
            else if(mLastActedChestGmId != 0)
            {
               mSelectedItemInfo = mDBFacade.dbAccountInfo.inventoryInfo.getChestStack(mLastActedChestGmId);
               if(mSelectedItemInfo == null)
               {
                  mLastActedChestGmId = 0;
               }
            }
         }
         if(mSelectedItemInfo != null && mSelectedItemInfo is ItemInfo)
         {
            jumpToWeaponOffer(mSelectedItemInfo);
         }
         else
         {
            this.showTab(mCurrentTab,mCurrentPage);
         }
         if(!dontRefreshChestSelection)
         {
            this.populateDetailInfoCard();
            this.populateDetailChestCard();
            this.highLightSelectedItem();
         }
         this.lookForNewEquippedItems();
         iter = mTabButtons.iterator() as IMapIterator;
         while(iter.hasNext())
         {
            tabButton = iter.next();
            tabButton.root.new_label.visible = this.categoryHasAnyNewItems(iter.key);
         }
         if(mSelectedItemInfo != null && !dontRefreshChestSelection)
         {
            itemSelected(mSelectedItemInfo);
            if(mRevealedShowEquip && mSelectedItemInfo is ItemInfo)
            {
               gmHero = mDBFacade.gameMaster.Heroes[mSelectedAvatar];
               itemInfo = mSelectedItemInfo as ItemInfo;
               canEquip = gmHero.AllowedWeapons.hasKey(itemInfo.gmWeaponItem.MasterType);
               if(canEquip)
               {
                  mInfoCard.loadEquipOnAvatarPopup();
               }
               mRevealedShowEquip = false;
            }
         }
      }
      
      public function jumpToWeaponOffer(info:InventoryBaseInfo) : void
      {
         var _loc4_:String = GMInventoryBase.WEAPON_CATEGORY;
         var _loc5_:Vector.<InventoryBaseInfo> = mCategorizedItems.itemFor(GMInventoryBase.WEAPON_CATEGORY);
         var _loc2_:int = _loc5_.indexOf(info);
         if(_loc2_ == -1)
         {
            Logger.warn("Index not found for item in Storage");
         }
         var _loc3_:uint = Math.floor(_loc2_ / 15);
         this.showTab(_loc4_,_loc3_);
      }
      
      private function checkIfRevealedWeaponExists() : InventoryBaseInfo
      {
         var _loc6_:InventoryBaseInfo = null;
         var _loc1_:GMWeaponItem = null;
         var _loc4_:uint = 0;
         var _loc5_:GMOffer = null;
         var _loc3_:GMStackable = null;
         if(mRevealedItemType == 0)
         {
            return null;
         }
         if(mRevealedItemType == 1)
         {
            mCurrentTab = GMInventoryBase.WEAPON_CATEGORY;
            mRevealedItemOfferId %= 100000;
            _loc1_ = mDBFacade.gameMaster.weaponItemById.itemFor(mRevealedItemOfferId);
            for each(_loc6_ in mCategorizedItems.itemFor(mCurrentTab))
            {
               if(_loc6_ is ItemInfo)
               {
                  _loc4_ = (_loc6_ as ItemInfo).gmWeaponItem.Id;
                  if(_loc4_ == _loc1_.Id && _loc6_.isNew)
                  {
                     mRevealedItemType = mRevealedItemOfferId = 0;
                     return _loc6_;
                  }
               }
            }
         }
         else if(mRevealedItemType == 2)
         {
            _loc5_ = mDBFacade.gameMaster.offerById.itemFor(mRevealedItemOfferId);
            var _loc10_:int = 0;
            var _loc9_:Vector.<GMOfferDetail> = _loc5_.Details;
            for each(var _loc2_:GMOfferDetail in _loc9_)
            {
               _loc3_ = mDBFacade.gameMaster.stackableById.itemFor(_loc2_.StackableId);
            }
            if(_loc3_ != null)
            {
               mCurrentTab = GMInventoryBase.POWERUP_CATEGORY;
               for each(_loc6_ in mCategorizedItems.itemFor(mCurrentTab))
               {
                  if(_loc6_.gmId == _loc3_.Id)
                  {
                     mRevealedItemType = mRevealedItemOfferId = 0;
                     return _loc6_;
                  }
               }
            }
         }
         mRevealedItemType = mRevealedItemOfferId = 0;
         return null;
      }
      
      private function lookForNewEquippedItems() : void
      {
         var _loc2_:IMapIterator = null;
         var _loc3_:ItemInfo = null;
         var _loc4_:StackableInfo = null;
         var _loc1_:PetInfo = null;
         _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.items.iterator() as IMapIterator;
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next();
            if(_loc3_.isEquipped && _loc3_.isNew && mNewItemIds.indexOf(_loc3_.databaseId) == -1)
            {
               mNewItemIds.push(_loc3_.databaseId);
            }
         }
         _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.stackables.iterator() as IMapIterator;
         while(_loc2_.hasNext())
         {
            _loc4_ = _loc2_.next();
            if(_loc4_.isEquipped && _loc4_.isNew && mNewStackableIds.indexOf(_loc4_.databaseId) == -1)
            {
               mNewStackableIds.push(_loc4_.databaseId);
            }
         }
         _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.pets.iterator() as IMapIterator;
         while(_loc2_.hasNext())
         {
            _loc1_ = _loc2_.next();
            if(_loc1_.isEquipped && _loc1_.isNew && mNewPetIds.indexOf(_loc1_.databaseId) == -1)
            {
               mNewPetIds.push(_loc1_.databaseId);
            }
         }
      }
      
      private function markItemsNotNew() : void
      {
         if(mNewChestIds.length || mNewItemIds.length || mNewStackableIds.length || mNewPetIds.length)
         {
            mDBFacade.dbAccountInfo.inventoryInfo.markItemsNotNew();
            mNewItemIds.length = 0;
            mNewStackableIds.length = 0;
            mNewPetIds.length = 0;
            mNewChestIds.length = 0;
         }
      }
      
      public function exitState() : void
      {
         this.markItemsNotNew();
         this.processChosenAvatar();
      }
      
      private function numElementsInCurrentCategory() : uint
      {
         var _loc1_:uint = 0;
         switch(mCurrentTab)
         {
            case GMInventoryBase.WEAPON_CATEGORY:
               _loc1_ = mDBFacade.dbAccountInfo.inventoryLimitWeapons;
               break;
            case GMInventoryBase.POWERUP_CATEGORY:
               _loc1_ = mDBFacade.dbAccountInfo.stackableCount;
               if(_loc1_ % 15 != 0)
               {
                  _loc1_ += 15 - _loc1_ % 15;
               }
               break;
            default:
               _loc1_ = 0;
         }
         return _loc1_;
      }
      
      private function numPagesInCurrentCategory() : uint
      {
         return Math.ceil(numElementsInCurrentCategory() / 15);
      }
      
      private function displayCategoryPage() : void
      {
         var _loc11_:InventoryBaseInfo = null;
         var _loc3_:UIInventoryItem = null;
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc9_:int = 0;
         resetItemGridMenuNavigation();
         var _loc10_:Vector.<InventoryBaseInfo> = mCategorizedItems.itemFor(mCurrentTab);
         if(mDungeonRewardPanel)
         {
            mDungeonRewardPanel.hide();
         }
         if(mCurrentTab == GMInventoryBase.WEAPON_CATEGORY)
         {
            mStacksWithEquipPicker.hide();
            if(mWantPets)
            {
               mPetsWithEquipPicker.hide();
            }
            mStuffWithEquipPicker.hide();
            mAddStorageButton.visible = true;
            mHeroWithEquipPicker.refresh(false);
            mHeroWithEquipPicker.show();
            if(mDungeonRewardPanel)
            {
               mDungeonRewardPanel.show();
            }
         }
         else if(mCurrentTab == GMInventoryBase.POWERUP_CATEGORY)
         {
            mHeroWithEquipPicker.hide();
            if(mWantPets)
            {
               mPetsWithEquipPicker.hide();
            }
            mStuffWithEquipPicker.hide();
            mAddStorageButton.visible = false;
            mStacksWithEquipPicker.refresh(false);
            mStacksWithEquipPicker.show();
         }
         else if(mWantPets && mCurrentTab == GMInventoryBase.PET_CATEGORY)
         {
            mHeroWithEquipPicker.hide();
            mStacksWithEquipPicker.hide();
            mStuffWithEquipPicker.hide();
            mAddStorageButton.visible = false;
            mPetsWithEquipPicker.refresh(false);
            mPetsWithEquipPicker.show();
         }
         else if(mWantPets && mCurrentTab == GMInventoryBase.STUFF_CATEGORY)
         {
            mHeroWithEquipPicker.hide();
            mStacksWithEquipPicker.hide();
            if(mWantPets)
            {
               mPetsWithEquipPicker.hide();
            }
            mAddStorageButton.visible = false;
            mStuffWithEquipPicker.refresh(false);
            mStuffWithEquipPicker.show();
         }
         _loc7_ = 0;
         while(_loc7_ < 15)
         {
            _loc3_ = mItems[_loc7_];
            _loc3_.deSelect();
            _loc3_.visible = false;
            _loc7_++;
         }
         var _loc1_:uint = mCurrentPage * 15;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         _loc7_ = 0;
         while(_loc7_ < mInventoryGridElements.length)
         {
            mInventoryGridElements[_loc7_].visible = true;
            _loc7_++;
         }
         var _loc2_:Boolean = false;
         var _loc8_:uint = numElementsInCurrentCategory();
         if(_loc1_ + 15 > _loc8_ && numElementsInCurrentCategory())
         {
            _loc4_ = _loc1_ + 15 - numElementsInCurrentCategory();
            _loc9_ = mInventoryGridElements.length - _loc4_;
            _loc7_ = mInventoryGridElements.length - 1;
            while(_loc7_ >= _loc9_)
            {
               if(_loc7_ < mInventoryGridElements.length)
               {
                  mInventoryGridElements[_loc7_].visible = false;
               }
               else
               {
                  _loc2_ = true;
               }
               _loc7_--;
            }
         }
         _loc7_ = 0;
         while(_loc7_ < _loc1_ && _loc5_ < _loc10_.length)
         {
            _loc11_ = _loc10_[_loc5_];
            if(!_loc11_.isEquipped)
            {
               _loc7_++;
            }
            _loc5_++;
         }
         while(_loc6_ < 15 && _loc5_ < _loc10_.length)
         {
            _loc11_ = _loc10_[_loc5_];
            if(!_loc11_.isEquipped && _loc11_.hasGMPropertySetup())
            {
               _loc3_ = mItems[_loc6_];
               _loc3_.info = _loc11_;
               _loc3_.root.visible = true;
               if(_loc11_.isNew)
               {
                  if(_loc11_ is ChestInfo && mNewChestIds.indexOf(_loc11_.databaseId) == -1)
                  {
                     mNewChestIds.push(_loc11_.databaseId);
                  }
                  else if(_loc11_ is ItemInfo && mNewItemIds.indexOf(_loc11_.databaseId) == -1)
                  {
                     mNewItemIds.push(_loc11_.databaseId);
                  }
                  else if(_loc11_ is StackableInfo && mNewStackableIds.indexOf(_loc11_.databaseId) == -1)
                  {
                     mNewStackableIds.push(_loc11_.databaseId);
                  }
                  else if(_loc11_ is PetInfo && mNewPetIds.indexOf(_loc11_.databaseId) == -1)
                  {
                     mNewPetIds.push(_loc11_.databaseId);
                  }
               }
               _loc6_++;
            }
            _loc5_++;
         }
         determineEquippableItems(mHeroWithEquipPicker.currentlySelectedHero);
         setupNavigationLinks();
      }
      
      private function showTab(category:String, page:uint = 0) : void
      {
         var _loc4_:UIRadioButton = null;
         setNextTab(category);
         mCurrentTab = category;
         var _loc5_:IMapIterator = mTabButtons.iterator() as IMapIterator;
         while(_loc5_.hasNext())
         {
            _loc4_ = _loc5_.next();
            _loc4_.enabled = true;
         }
         _loc4_ = mTabButtons.itemFor(mCurrentTab);
         _loc4_.selected = true;
         _loc4_.enabled = false;
         _loc4_.label.visible = true;
         var _loc3_:uint = this.numPagesInCurrentCategory();
         page = _loc3_ == 0 ? 0 : Math.min(_loc3_ - 1,page);
         mPagination.numPages = _loc3_;
         mPagination.currentPage = mCurrentPage = page;
         mPagination.visible = _loc3_ > 1;
         displayCategoryPage();
      }
      
      private function setCurrentPage(value:uint) : void
      {
         mCurrentPage = value;
         displayCategoryPage();
         focusNextPageButton();
      }
      
      private function focusNextPageButton() : void
      {
         var _loc1_:UIButton = mPagination.getNextPageButton();
         if(_loc1_ != null)
         {
            mDBFacade.menuNavigationController.setFocusedUiObject(_loc1_);
         }
      }
      
      public function get infoCard() : ItemInfoCard
      {
         return mInfoCard;
      }
      
      public function get chestCard() : ChestInfoCard
      {
         return mChestCard;
      }
      
      public function set currentTab(category:String) : void
      {
         mCurrentTab = category;
      }
      
      private function itemSelected(info:InventoryBaseInfo, navigationSource:UIObject = null) : void
      {
         var _loc3_:StackableInfo = null;
         restoreBoosterItemNavigation();
         mSelectedItemInfo = info;
         mSelectedItemNavigationSource = navigationSource;
         if(!(info is ChestInfo) || info.gmId != mLastActedChestGmId)
         {
            mLastActedChestGmId = 0;
         }
         var _loc4_:Boolean = false;
         if(info is StackableInfo)
         {
            _loc3_ = info as StackableInfo;
            if(_loc3_.gmStackable.AccountBooster)
            {
               populateDetailBoosterCard();
               _loc4_ = true;
            }
         }
         if(!_loc4_)
         {
            mBoosterCard.hide();
            if(mSelectedItemInfo.gmChestInfo)
            {
               populateDetailChestCard();
            }
            else
            {
               populateDetailInfoCard();
            }
         }
         highLightSelectedItem();
      }
      
      private function highLightSelectedItem() : void
      {
         if(mSelectedItemInfo as ChestInfo)
         {
            highLightSelectedChestItem();
         }
         else if(mSelectedItemInfo as ItemInfo)
         {
            highLightSelectedAvatarItem();
         }
         else if(mSelectedItemInfo as StackableInfo)
         {
            highLightSelectedAccountItem();
         }
         else if(mWantPets && mSelectedItemInfo as PetInfo)
         {
            highLightSelectedPet();
         }
      }
      
      private function highLightSelectedChestItem() : void
      {
         var _loc2_:UIInventoryItem = null;
         var _loc3_:uint = 0;
         if(mDungeonRewardPanel)
         {
            mDungeonRewardPanel.clearHighlights();
         }
         var _loc1_:ChestInfo = mSelectedItemInfo as ChestInfo;
         if(_loc1_.isFromDungeonSummary())
         {
            _loc3_ = 0;
            while(_loc3_ < 15)
            {
               mItems[_loc3_].deSelect();
               _loc3_++;
            }
            mDungeonRewardPanel.highlightChest(_loc1_);
            return;
         }
         _loc3_ = 0;
         while(_loc3_ < 15)
         {
            _loc2_ = mItems[_loc3_];
            if(mSelectedItemInfo && _loc2_.info == mSelectedItemInfo)
            {
               _loc2_.select();
            }
            else
            {
               _loc2_.deSelect();
            }
            _loc3_++;
         }
      }
      
      private function highLightSelectedAvatarItem() : void
      {
         var _loc2_:GMWeaponItem = null;
         var _loc4_:uint = 0;
         var _loc1_:UIInventoryItem = null;
         var _loc3_:uint = 0;
         if(mDungeonRewardPanel)
         {
            mDungeonRewardPanel.clearHighlights();
         }
         var _loc5_:ItemInfo = mSelectedItemInfo as ItemInfo;
         mHeroWithEquipPicker.deselectEquipment();
         if(mHeroWithEquipPicker.highlightItem(mSelectedItemInfo))
         {
            _loc2_ = _loc5_.gmWeaponItem;
            _loc4_ = _loc5_.power;
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < 15)
            {
               _loc1_ = mItems[_loc3_];
               if(mSelectedItemInfo && _loc1_.info == mSelectedItemInfo)
               {
                  _loc1_.select();
                  if(_loc5_)
                  {
                     _loc2_ = _loc5_.gmWeaponItem;
                     _loc4_ = _loc5_.power;
                  }
               }
               else
               {
                  _loc1_.deSelect();
               }
               _loc3_++;
            }
         }
         if(_loc2_ != null)
         {
            mHeroWithEquipPicker.showWeaponComparison(_loc2_,_loc4_);
         }
      }
      
      private function highLightSelectedAccountItem() : void
      {
         var _loc4_:GMStackable = null;
         var _loc5_:int = 0;
         var _loc2_:UIInventoryItem = null;
         var _loc3_:uint = 0;
         var _loc1_:StackableInfo = mSelectedItemInfo as StackableInfo;
         mStacksWithEquipPicker.deselectEquipment();
         if(mStacksWithEquipPicker.highlightItem(mSelectedItemInfo))
         {
            _loc4_ = _loc1_.gmStackable;
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < 15)
            {
               _loc2_ = mItems[_loc3_];
               if(mSelectedItemInfo && _loc2_.info == mSelectedItemInfo)
               {
                  _loc2_.select();
                  if(_loc1_)
                  {
                     _loc4_ = _loc1_.gmStackable;
                  }
               }
               else
               {
                  _loc2_.deSelect();
               }
               _loc3_++;
            }
         }
         if(_loc4_ != null)
         {
         }
      }
      
      private function highLightSelectedPet() : void
      {
         var _loc1_:GMNpc = null;
         var _loc3_:UIInventoryItem = null;
         var _loc4_:uint = 0;
         var _loc2_:PetInfo = mSelectedItemInfo as PetInfo;
         mPetsWithEquipPicker.deselectEquipment();
         if(mPetsWithEquipPicker.highlightItem(mSelectedItemInfo))
         {
            _loc1_ = _loc2_.gmNpc;
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < 15)
            {
               _loc3_ = mItems[_loc4_];
               if(mSelectedItemInfo && _loc3_.info == mSelectedItemInfo)
               {
                  _loc3_.select();
                  if(_loc2_)
                  {
                     _loc1_ = _loc2_.gmNpc;
                  }
               }
               else
               {
                  _loc3_.deSelect();
               }
               _loc4_++;
            }
         }
      }
      
      private function populateDetailBoosterCard() : void
      {
         mConsumableChestCard.hide();
         mChestCard.hide();
         mInfoCard.visible = false;
         mBoosterCard.info = mSelectedItemInfo as StackableInfo;
         setupBoosterCardMenuNavigation();
      }
      
      private function setupBoosterCardMenuNavigation() : void
      {
         restoreBoosterItemNavigation();
         var _loc2_:UIButton = mBoosterCard.visibleActivationButton;
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.clearNavigationAndInteractions();
         if(mSelectedItemNavigationSource != null && mSelectedItemNavigationSource.canBeFocused())
         {
            mSelectedItemNavigationSource.clearUpNavigation();
            mSelectedItemNavigationSource.upNavigation = _loc2_;
            _loc2_.downNavigation = mSelectedItemNavigationSource;
            return;
         }
         var _loc1_:UIInventoryItem = getFirstFocusableInventoryItem() as UIInventoryItem;
         if(_loc1_ == null)
         {
            return;
         }
         mBoosterNavigationItem = _loc1_;
         _loc2_.rightNavigation = _loc1_;
         _loc1_.clearLeftNavigation();
         _loc1_.leftNavigation = _loc2_;
      }
      
      private function focusAfterBoosterActivation() : void
      {
         if(mLogicalWorkComponent == null)
         {
            return;
         }
         mLogicalWorkComponent.doLater(0,function(param1:GameClock):void
         {
            completeBoosterActivationFocus();
         });
      }
      
      private function completeBoosterActivationFocus() : void
      {
         var _loc1_:UIButton = null;
         if(mBoosterCard != null && mBoosterCard.isShowing())
         {
            setupBoosterCardMenuNavigation();
            _loc1_ = mBoosterCard.visibleActivationButton;
            if(_loc1_ != null && _loc1_.canBeFocused())
            {
               mDBFacade.menuNavigationController.setFocusedUiObject(_loc1_);
               return;
            }
         }
         focusFirstInventoryItem();
      }
      
      private function restoreBoosterItemNavigation() : void
      {
         if(mBoosterNavigationItem == null)
         {
            return;
         }
         var _loc1_:int = mItems.indexOf(mBoosterNavigationItem);
         mBoosterNavigationItem.clearLeftNavigation();
         if(_loc1_ > 0 && _loc1_ % 5 != 0)
         {
            mBoosterNavigationItem.leftNavigation = mItems[_loc1_ - 1];
         }
         mBoosterNavigationItem = null;
      }
      
      private function populateDetailInfoCard() : void
      {
         mConsumableChestCard.hide();
         mChestCard.hide();
         mInfoCard.info = mSelectedItemInfo;
         if(mSelectedItemInfo)
         {
            setupInfoCardMenuNavigation();
         }
      }
      
      private function populateDetailChestCard() : void
      {
         var _loc1_:ChestInfo = mSelectedItemInfo as ChestInfo;
         if(_loc1_ == null)
         {
            mConsumableChestCard.hide();
            mChestCard.hide();
            mChestCard.selectedHeroId = mSelectedAvatar;
            return;
         }
         mInfoCard.info = null;
         if(UIHud.isThisAConsumbleChestId(_loc1_.gmId))
         {
            mConsumableChestCard.info = _loc1_;
            mChestCard.hide();
            mBoosterCard.hide();
            setupChestInfoCardMenuNavigation(mConsumableChestCard);
         }
         else
         {
            mChestCard.selectedHeroId = mSelectedAvatar;
            mChestCard.info = _loc1_;
            mConsumableChestCard.hide();
            mBoosterCard.hide();
            setupChestInfoCardMenuNavigation(mChestCard);
         }
      }
      
      private function getSelectedItemPosition() : int
      {
         var _loc1_:UIInventoryItem = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < 15)
         {
            _loc1_ = mItems[_loc2_];
            if(mSelectedItemInfo && _loc1_.info == mSelectedItemInfo)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function destroy() : void
      {
         var _loc4_:UIRadioButton = null;
         var _loc1_:UIInventoryItem = null;
         var _loc5_:uint = 0;
         var _loc2_:MovieClip = null;
         var _loc6_:uint = 0;
         mDBFacade = null;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         mRoot = null;
         mInventoryRoot = null;
         mSwfAsset = null;
         resetMenuNavigation();
         mTownHeader = null;
         if(mDungeonRewardPanel)
         {
            mDungeonRewardPanel.destroy();
         }
         mDungeonRewardPanel = null;
         var _loc3_:IMapIterator = mTabButtons.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            _loc4_.destroy();
         }
         mTabButtons.clear();
         mTabButtons = null;
         if(mPagination)
         {
            mPagination.destroy();
         }
         mPagination = null;
         _loc5_ = 0;
         while(_loc5_ < mItems.length)
         {
            _loc1_ = mItems[_loc5_];
            _loc1_.destroy();
            _loc5_++;
         }
         mItems = null;
         if(mInventoryGridElements)
         {
            _loc6_ = 0;
            while(_loc5_ < mInventoryGridElements.length)
            {
               _loc2_ = mInventoryGridElements[_loc6_];
               _loc2_ = null;
               _loc5_++;
            }
         }
         mInventoryGridElements.length = 0;
         mInventoryGridElements = null;
         mCategorizedItems.clear();
         mCategorizedItems = null;
         if(mAddStorageButton)
         {
            mAddStorageButton.destroy();
         }
         mAddStorageButton = null;
         if(mInfoCard)
         {
            mInfoCard.destroy();
         }
         mInfoCard = null;
         if(mDungeonSummary)
         {
            mDungeonSummary.loadNextChestPopUp();
         }
         mDungeonSummary = null;
         mNewItemIds.length = 0;
         mNewItemIds = null;
         mNewChestIds.length = 0;
         mNewChestIds = null;
         mNewStackableIds.length = 0;
         mNewStackableIds = null;
         mNewPetIds.length = 0;
         mNewPetIds = null;
         if(mHeroWithEquipPicker)
         {
            mHeroWithEquipPicker.destroy();
         }
         mHeroWithEquipPicker = null;
         if(mStacksWithEquipPicker)
         {
            mStacksWithEquipPicker.destroy();
         }
         mStacksWithEquipPicker = null;
         if(mPetsWithEquipPicker)
         {
            mPetsWithEquipPicker.destroy();
         }
         mPetsWithEquipPicker = null;
         if(mStuffWithEquipPicker)
         {
            mStuffWithEquipPicker.destroy();
         }
         mStuffWithEquipPicker = null;
         mSelectedItemInfo = null;
         if(mSceneGraphComponent)
         {
            mSceneGraphComponent.destroy();
         }
         mSceneGraphComponent = null;
         if(mChestCard)
         {
            mChestCard.destroy();
         }
         mChestCard = null;
         if(mAbandonChestPopUp)
         {
            mAbandonChestPopUp.destroy();
         }
         mAbandonChestPopUp = null;
         if(mChestOpenFullPopUp)
         {
            mChestOpenFullPopUp.destroy();
         }
         mChestOpenFullPopUp = null;
         if(mEventComponent)
         {
            mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
            mEventComponent.destroy();
         }
         mEventComponent = null;
         if(mConsumableChestCard)
         {
            mConsumableChestCard.destroy();
         }
         mConsumableChestCard = null;
         if(mBoosterCard)
         {
            mBoosterCard.destroy();
         }
         mBoosterCard = null;
      }
      
      private function processChosenAvatar() : void
      {
         if(mHeroWithEquipPicker.currentlySelectedHero == null)
         {
            return;
         }
         var _loc1_:uint = mHeroWithEquipPicker.currentlySelectedHero.Id;
         if(mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero.Id != _loc1_)
         {
            mDBFacade.dbAccountInfo.changeActiveAvatarRPC(_loc1_);
         }
      }
      
      private function setNextTab(category:String) : void
      {
         if(category == GMInventoryBase.WEAPON_CATEGORY)
         {
            mNextTab = GMInventoryBase.POWERUP_CATEGORY;
         }
         else if(category == GMInventoryBase.POWERUP_CATEGORY)
         {
            mNextTab = mWantPets ? GMInventoryBase.PET_CATEGORY : GMInventoryBase.STUFF_CATEGORY;
         }
         else if(category == GMInventoryBase.PET_CATEGORY)
         {
            mNextTab = GMInventoryBase.STUFF_CATEGORY;
         }
         else if(category == GMInventoryBase.STUFF_CATEGORY)
         {
            mNextTab = GMInventoryBase.WEAPON_CATEGORY;
         }
      }
      
      public function setupCategoryNavigation(ownerLayer:String) : void
      {
         mDBFacade.menuNavigationController.setLayerCategoryCallbacks(selectPreviousHero,selectNextHero,ownerLayer);
         mWeaponTabButton.clearNavigationAndInteractions();
         mPotionsTabButton.clearNavigationAndInteractions();
         mPetsTabButton.clearNavigationAndInteractions();
         mStuffTabButton.clearNavigationAndInteractions();
         if(mTownHeader != null)
         {
            mTownHeader.addCoinButton.clearDownNavigation();
            mTownHeader.addGemButton.clearDownNavigation();
            mTownHeader.closeButton.clearDownNavigation();
            mTownHeader.addCoinButton.downNavigation = mTabButtons.itemFor(mNextTab);
            mTownHeader.addGemButton.downNavigation = mTabButtons.itemFor(mNextTab);
            mTownHeader.closeButton.downNavigation = mTabButtons.itemFor(mNextTab);
            mWeaponTabButton.upNavigation = mTownHeader.addCoinButton;
            mPotionsTabButton.upNavigation = mTownHeader.addCoinButton;
            mStuffTabButton.upNavigation = mTownHeader.addCoinButton;
            if(mWantPets)
            {
               mPetsTabButton.upNavigation = mTownHeader.addCoinButton;
            }
         }
         mWeaponTabButton.isToTheLeftOf(mPotionsTabButton);
         if(mWantPets)
         {
            mPotionsTabButton.isToTheLeftOf(mPetsTabButton);
            mPetsTabButton.isToTheLeftOf(mStuffTabButton);
            mPetsTabButton.downNavigation = mItems[0];
         }
         else
         {
            mPotionsTabButton.isToTheLeftOf(mStuffTabButton);
         }
         mStuffTabButton.isToTheLeftOf(mWeaponTabButton);
         mWeaponTabButton.downNavigation = mItems[0];
         mPotionsTabButton.downNavigation = mItems[0];
         mStuffTabButton.downNavigation = mItems[0];
      }
      
      private function selectPreviousHero() : void
      {
         selectAdjacentHero(-1);
      }
      
      private function selectNextHero() : void
      {
         selectAdjacentHero(1);
      }
      
      private function selectAdjacentHero(direction:int) : void
      {
         var _loc3_:Vector.<GMHero> = mDBFacade.gameMaster.Heroes;
         if(_loc3_.length == 0)
         {
            return;
         }
         var _loc2_:int = int(mSelectedAvatar < _loc3_.length ? mSelectedAvatar : 0);
         var _loc4_:int = _loc2_;
         do
         {
            _loc4_ = (_loc4_ + direction + _loc3_.length) % _loc3_.length;
         }
         while(_loc3_[_loc4_].Hidden && !mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes",false) && _loc4_ != _loc2_);
         if(_loc4_ == mSelectedAvatar)
         {
            return;
         }
         mSelectedAvatar = _loc4_;
         heroSelected(_loc3_[_loc4_],mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(_loc3_[_loc4_].Id));
      }
      
      private function resetMenuNavigation() : void
      {
         if(mTownHeader == null)
         {
            return;
         }
         mTownHeader.addCoinButton.clearDownNavigation();
         mTownHeader.addGemButton.clearDownNavigation();
         mTownHeader.closeButton.clearDownNavigation();
      }
      
      private function resetItemGridMenuNavigation() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < 15)
         {
            mItems[_loc1_].clearNavigationAndInteractions();
            _loc1_++;
         }
      }
      
      private function setupNavigationLinks() : void
      {
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:UIButton = mPagination.getNextPageButton();
         var _loc3_:UIObject = getFirstFocusableInventoryItem();
         mAddStorageButton.clearUpNavigation();
         mAddStorageButton.clearDownNavigation();
         mItems[0].clearUpNavigation();
         mItems[1].clearUpNavigation();
         mItems[2].clearUpNavigation();
         mItems[3].clearUpNavigation();
         mItems[4].clearUpNavigation();
         mItems[0].upNavigation = mTabButtons.itemFor(mNextTab);
         mItems[1].upNavigation = mTabButtons.itemFor(mNextTab);
         mItems[2].upNavigation = mTabButtons.itemFor(mNextTab);
         mItems[3].upNavigation = mTabButtons.itemFor(mNextTab);
         mItems[4].upNavigation = mTabButtons.itemFor(mNextTab);
         resetEquipPickerMenuNavigation();
         setupCurrentEquipPickerMenuNavigation();
         _loc4_ = 0;
         while(_loc4_ < 15)
         {
            if(_loc4_ % 5 < 4 && _loc4_ + 1 < 15)
            {
               mItems[_loc4_].isToTheLeftOf(mItems[_loc4_ + 1]);
            }
            if(_loc4_ + 5 < 15)
            {
               mItems[_loc4_].isAbove(mItems[_loc4_ + 5]);
            }
            if(_loc4_ >= 10)
            {
               mItems[_loc4_].downNavigation = _loc2_ ?? mAddStorageButton;
               if(_loc2_ != null)
               {
                  mItems[_loc4_].downNavigationAdditionalInteraction = createPaginationReturnCallback(mItems[_loc4_]);
               }
            }
            _loc4_++;
         }
         if(mPagination.numPages > 1)
         {
            _loc1_ = 0;
            while(_loc1_ < mPagination.numPageButtons)
            {
               if(_loc1_ > 0)
               {
                  mPagination.getPageButton(_loc1_ - 1).isToTheLeftOf(mPagination.getPageButton(_loc1_));
               }
               if(_loc3_ != null)
               {
                  mPagination.getPageButton(_loc1_).upNavigation = _loc3_;
               }
               mPagination.getPageButton(_loc1_).downNavigation = mAddStorageButton;
               _loc1_++;
            }
            mAddStorageButton.upNavigation = _loc2_;
         }
         else
         {
            mAddStorageButton.upNavigation = mItems[15 - 1];
         }
      }
      
      private function getFirstFocusableInventoryItem() : UIObject
      {
         for each(var _loc1_:UIInventoryItem in mItems)
         {
            if(_loc1_.canBeFocused())
            {
               return _loc1_;
            }
         }
         return null;
      }
      
      private function focusFirstInventoryItem() : void
      {
         var _loc1_:UIObject = getFirstFocusableInventoryItem();
         if(_loc1_ == null && mTownHeader != null)
         {
            _loc1_ = mTownHeader.closeButton;
         }
         if(_loc1_ != null && _loc1_.canBeFocused())
         {
            mDBFacade.menuNavigationController.setFocusedUiObject(_loc1_);
         }
      }
      
      private function resetEquipPickerMenuNavigation() : void
      {
         mHeroWithEquipPicker.resetHeroWithEquipPickerMenuNavigation();
         mStacksWithEquipPicker.resetMenuNavigation();
         if(mWantPets)
         {
            mPetsWithEquipPicker.resetMenuNavigation();
         }
         mStuffWithEquipPicker.resetMenuNavigation();
      }
      
      private function setupCurrentEquipPickerMenuNavigation() : void
      {
         var _loc1_:UIObject = null;
         if(mCurrentTab == GMInventoryBase.POWERUP_CATEGORY)
         {
            mStacksWithEquipPicker.setupMenuNavigation(mAddStorageButton);
            _loc1_ = mStacksWithEquipPicker.getFirstUIObject();
         }
         else if(mWantPets && mCurrentTab == GMInventoryBase.PET_CATEGORY)
         {
            mPetsWithEquipPicker.setupMenuNavigation(mAddStorageButton);
            _loc1_ = mPetsWithEquipPicker.getFirstUIObject();
         }
         else if(mCurrentTab == GMInventoryBase.STUFF_CATEGORY)
         {
            mStuffWithEquipPicker.setupMenuNavigation(mAddStorageButton);
            _loc1_ = mStuffWithEquipPicker.getFirstUIObject();
         }
         else
         {
            mHeroWithEquipPicker.setupHeroWithEquipPickerMenuNavigation(mAddStorageButton);
            _loc1_ = mHeroWithEquipPicker.getFirstHeroSlotUIObject();
         }
         mAddStorageButton.downNavigation = _loc1_;
      }
      
      private function createPaginationReturnCallback(returnObject:UIObject) : Function
      {
         return function():void
         {
            setPaginationReturnObject(returnObject);
         };
      }
      
      private function setPaginationReturnObject(returnObject:UIObject) : void
      {
         var _loc3_:uint = 0;
         var _loc2_:UIButton = null;
         _loc3_ = 0;
         while(_loc3_ < mPagination.numPageButtons)
         {
            _loc2_ = mPagination.getPageButton(_loc3_);
            _loc2_.clearUpNavigation();
            _loc2_.upNavigation = returnObject;
            _loc3_++;
         }
      }
      
      private function setupInfoCardMenuNavigation() : void
      {
         mItems[0].clearLeftNavigation();
         mItems[5].clearLeftNavigation();
         mItems[10].clearLeftNavigation();
         mInfoCard.mEquipButton.clearRightNavigation();
         mInfoCard.setupMenuNavigation();
         if(mSelectedItemNavigationSource != null && mSelectedItemNavigationSource.canBeFocused())
         {
            mSelectedItemNavigationSource.clearUpNavigation();
            mSelectedItemNavigationSource.upNavigation = mInfoCard.mEquipButton;
            mInfoCard.mEquipButton.downNavigation = mSelectedItemNavigationSource;
            return;
         }
         var _loc1_:int = getSelectedItemPosition();
         if(_loc1_ != -1)
         {
            mInfoCard.mEquipButton.rightNavigation = mItems[_loc1_];
         }
         mItems[0].leftNavigation = mInfoCard.mEquipButton;
         mItems[5].leftNavigation = mInfoCard.mEquipButton;
         mItems[10].leftNavigation = mInfoCard.mEquipButton;
      }
      
      private function setupChestInfoCardMenuNavigation(chestCard:ChestInfoCard) : void
      {
         var _loc3_:UIObject = null;
         var _loc4_:int = 0;
         var _loc2_:UIObject = null;
         mItems[0].clearLeftNavigation();
         mItems[5].clearLeftNavigation();
         mItems[10].clearLeftNavigation();
         var _loc5_:ChestInfo = mSelectedItemInfo as ChestInfo;
         if(_loc5_.isFromDungeonSummary() && mDungeonRewardPanel != null)
         {
            _loc3_ = mDungeonRewardPanel.getNavigationEntry(_loc5_);
         }
         else
         {
            _loc4_ = getSelectedItemPosition();
            if(_loc4_ != -1)
            {
               _loc3_ = mItems[_loc4_];
            }
         }
         chestCard.setupMenuNavigation(_loc3_);
         if(_loc5_.isFromDungeonSummary())
         {
            _loc2_ = getFirstFocusableInventoryItem();
            mDungeonRewardPanel.setupChestCardNavigation(chestCard.dungeonSummaryAbandonButton,chestCard.dungeonSummaryKeepButton,_loc5_);
            if(_loc2_ != null)
            {
               chestCard.dungeonSummaryUnlockButton.rightNavigation = _loc2_;
               _loc2_.clearLeftNavigation();
               _loc2_.leftNavigation = chestCard.dungeonSummaryUnlockButton;
            }
            mItems[5].leftNavigation = chestCard.dungeonSummaryUnlockButton;
            mItems[10].leftNavigation = chestCard.dungeonSummaryUnlockButton;
            if(!mDungeonSummaryInitialFocusSet && chestCard.dungeonSummaryUnlockButton.canBeFocused())
            {
               mDungeonSummaryInitialFocusSet = true;
               mDBFacade.menuNavigationController.setFocusedUiObject(chestCard.dungeonSummaryUnlockButton);
            }
         }
         else
         {
            mItems[0].leftNavigation = chestCard.menuEntryButton;
            mItems[5].leftNavigation = chestCard.menuEntryButton;
            mItems[10].leftNavigation = chestCard.menuEntryButton;
            if(mDungeonSummary != null && mDungeonRewardPanel != null)
            {
               mDungeonRewardPanel.setupInventoryChestNavigation(chestCard.inventoryAbandonButton);
            }
         }
      }
   }
}

