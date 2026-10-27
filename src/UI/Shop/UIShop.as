package UI.Shop
{
   import Account.AvatarInfo;
   import Account.StoreServices;
   import Account.StoreServicesController;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UIRadioButton;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.TimeSpan;
   import Brain.WorkLoop.LogicalWorkComponent;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import FacebookAPI.DBFacebookBragFeedPost;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMOfferDetail;
   import GameMasterDictionary.GMSkin;
   import GameMasterDictionary.GMWeaponItem;
   import Town.TownHeader;
   import UI.*;
   import UI.EquipPicker.HeroWithEquipPicker;
   import UI.Popup.DBUIPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class UIShop
   {
      
      public static const WEAPON_LEVEL_DISPLAY_RANGE:uint = 10;
      
      private static const SELECTED_TAB_SCALE:Number = 1.15;
      
      public static const SPECIAL_CATEGORY:String = "SPECIAL";
      
      public static const CHEST_CATEGORY:String = "CHEST";
      
      public static const KEY_CATEGORY:String = "KEY";
      
      public static const HERO_CATEGORY:String = "HERO";
      
      public static const WEAPON_CATEGORY:String = "WEAPON";
      
      public static const STUFF_CATEGORY:String = "STUFF";
      
      public static const PET_CATEGORY:String = "PET";
      
      public static const SKIN_CATEGORY:String = "SKIN";
      
      private static const DEFAULT_CATEGORY:String = "SPECIAL";
      
      private static const NUM_OFFERS_PER_PAGE:uint = 6;
      
      private static const NUM_WEAPON_OFFERS_PER_PAGE:uint = 3;
      
      private static const TEMPLATE_CLASSNAME:String = "shop_offer_template";
      
      private static const KEY_TEMPLATE_CLASSNAME:String = "shop_offer_key_template";
      
      private static const PREMIUM_TEMPLATE_CLASSNAME:String = "shop_offer_premium_template";
      
      private static const NEW_WEAPONS_TEMPLATE_CLASSNAME:String = "shop_offer_weapon_template";
      
      private static const DLC_TEMPLATE_CLASSNAME:String = "shop_offer_dlc_template";
      
      private static const LIMITED_OFFER_REFRESH_TIME:Number = 60000;
      
      private static const CATEGORIES:Vector.<String> = new <String>["SPECIAL","CHEST","KEY","HERO","STUFF","WEAPON","PET","SKIN"];
      
      private var mDBFacade:DBFacade;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mRoot:MovieClip;
      
      private var mSwfAsset:SwfAsset;
      
      private var mOfferTemplateClass:Class;
      
      private var mKeyOfferTemplateClass:Class;
      
      private var mPremiumOfferTemplateClass:Class;
      
      private var mWeaponOfferTemplateClass:Class;
      
      private var mDLCOfferTemplateClass:Class;
      
      private var mTownHeader:TownHeader;
      
      private var mSelectedHero:GMHero;
      
      private var mCurrentPage:uint = 0;
      
      private var mCurrentTab:String;
      
      private var mNextLimitedOfferRefreshTime:Number;
      
      private var mUIOffers:Vector.<UIShopOffer>;
      
      private var mEmptyOffers:Vector.<MovieClip>;
      
      private var mZeroOfferClip:MovieClip;
      
      private var mCategorizedGMOffers:Map;
      
      private var mFilteredGMOffers:Map;
      
      private var mTabButtons:Map;
      
      private var mPagination:UIPagingPanel;
      
      private var mHeroWithEquipPicker:HeroWithEquipPicker;
      
      private var mEventComponent:EventComponent;
      
      private var mWeaponsLogicalWorkComponent:LogicalWorkComponent;
      
      private var mWeaponTabEndDate:Date;
      
      public function UIShop(dbFacade:DBFacade, swfAsset:SwfAsset, rootClip:MovieClip, townHeader:TownHeader)
      {
         super();
         mDBFacade = dbFacade;
         mSwfAsset = swfAsset;
         mTownHeader = townHeader;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIShop");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIShop");
         mEventComponent = new EventComponent(mDBFacade);
         mWeaponsLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIShop");
         mUIOffers = new Vector.<UIShopOffer>();
         mEmptyOffers = new Vector.<MovieClip>();
         mTabButtons = new Map();
         mFilteredGMOffers = new Map();
         this.processGMOffers();
         this.sortOffers();
         this.filterOffers();
         this.setupUI(rootClip);
         mNextLimitedOfferRefreshTime = GameClock.getWebServerTime();
      }
      
      public function regenerateOffers() : void
      {
         mDBFacade.regenerateGameMaster();
         this.processGMOffers();
         this.sortOffers();
         this.filterOffers();
         displayCategoryPage();
      }
      
      public function destroy() : void
      {
         var _loc2_:UIRadioButton = null;
         cleanUpTodaysShopTimerUI();
         mWeaponsLogicalWorkComponent.destroy();
         mWeaponsLogicalWorkComponent = null;
         mLogicalWorkComponent.destroy();
         mDBFacade = null;
         mSwfAsset = null;
         var _loc1_:IMapIterator = mTabButtons.iterator() as IMapIterator;
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next();
            _loc2_.destroy();
         }
         mTabButtons.clear();
         mTabButtons = null;
         mUIOffers = null;
         mEmptyOffers = null;
         mZeroOfferClip = null;
         mCategorizedGMOffers.clear();
         if(mFilteredGMOffers)
         {
            mFilteredGMOffers.clear();
         }
         mPagination.destroy();
         mHeroWithEquipPicker.destroy();
         mSceneGraphComponent.destroy();
         mAssetLoadingComponent.destroy();
         if(mEventComponent)
         {
            mEventComponent.destroy();
         }
      }
      
      public function get root() : MovieClip
      {
         return mRoot;
      }
      
      public function refresh(startAtCategoryTab:String = "") : void
      {
         var owned:Boolean;
         var popup:DBUIPopup;
         mTownHeader.title = Locale.getString("SHOP_HEADER");
         if(!mCurrentTab)
         {
            mCurrentTab = "SPECIAL";
         }
         if(startAtCategoryTab != "")
         {
            mCurrentTab = startAtCategoryTab;
            startAtCategoryTab = "";
         }
         mHeroWithEquipPicker.refresh(true);
         mSelectedHero = mDBFacade.gameMaster.heroById.itemFor(mDBFacade.dbAccountInfo.activeAvatarInfo.avatarType);
         owned = mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(mSelectedHero.Id);
         this.heroSelected(mSelectedHero,owned);
         if(mDBFacade.gameClock.realTime >= mNextLimitedOfferRefreshTime && !mDBFacade.mInDailyReward)
         {
            mNextLimitedOfferRefreshTime = GameClock.getWebServerTime() + 60000;
            popup = new DBUIPopup(mDBFacade,Locale.getString("SHOP_UPDATING"),null,false);
            MemoryTracker.track(popup,"DBUIPopup - created in UIShop.refresh()");
            StoreServices.getLimitedOfferUsage(mDBFacade,null,function(param1:*):void
            {
               popup.destroy();
               showTab(mCurrentTab);
            },function(param1:Error):void
            {
               StoreServicesController.showErrorPopup(mDBFacade,param1);
            });
         }
         else
         {
            showTab(mCurrentTab);
         }
         if(mTownHeader != null)
         {
            mTownHeader.refreshKeyPanel();
         }
      }
      
      private function processGMOffers() : void
      {
         var _loc6_:String = null;
         var _loc2_:* = undefined;
         var _loc7_:GMOffer = null;
         var _loc4_:* = null;
         var _loc5_:* = 0;
         mCategorizedGMOffers = new Map();
         for each(_loc6_ in CATEGORIES)
         {
            mCategorizedGMOffers.add(_loc6_,new Vector.<GMOffer>());
         }
         var _loc1_:Vector.<GMOffer> = mDBFacade.gameMaster.Offers;
         var _loc3_:Vector.<GMOffer> = mCategorizedGMOffers.itemFor("SPECIAL");
         _loc5_ = 0;
         while(_loc5_ < _loc1_.length)
         {
            _loc7_ = _loc1_[_loc5_];
            if(_loc7_.Location == "STORE")
            {
               if(!_loc7_.Gift)
               {
                  _loc6_ = _loc7_.Tab;
                  _loc2_ = mCategorizedGMOffers.itemFor(_loc6_);
                  if(_loc2_)
                  {
                     _loc2_.push(_loc7_);
                  }
                  else
                  {
                     Logger.debug("Categoryoffers are null for category: " + _loc6_);
                  }
                  if(_loc7_.Special && _loc3_.indexOf(_loc7_) == -1)
                  {
                     _loc3_.push(_loc7_);
                  }
               }
            }
            _loc5_++;
         }
      }
      
      private function specialSortComparator(gmOfferA:GMOffer, gmOfferB:GMOffer) : int
      {
         var _loc4_:Boolean = gmOfferA.isOnSaleNow != null;
         var _loc3_:Boolean = gmOfferB.isOnSaleNow != null;
         if(_loc4_ && _loc3_)
         {
            return gmOfferA.Id - gmOfferB.Id;
         }
         if(_loc4_ && !_loc3_)
         {
            return -1;
         }
         if(_loc3_ && !_loc4_)
         {
            return 1;
         }
         if(gmOfferA.isNew && !gmOfferB.isNew)
         {
            return -1;
         }
         if(gmOfferB.isNew && !gmOfferA.isNew)
         {
            return 1;
         }
         return gmOfferA.Id - gmOfferB.Id;
      }
      
      private function potionSortComparator(gmOfferA:GMOffer, gmOfferB:GMOffer) : int
      {
         return gmOfferA.Price - gmOfferB.Price;
      }
      
      private function keySortComparator(gmOfferA:GMOffer, gmOfferB:GMOffer) : int
      {
         var _loc6_:GMOfferDetail = gmOfferA.Details[0];
         var _loc5_:GMOfferDetail = gmOfferB.Details[0];
         var _loc7_:uint = _loc6_.BasicKeys + _loc6_.UncommonKeys + _loc6_.RareKeys + _loc6_.LegendaryKeys;
         var _loc8_:uint = _loc5_.BasicKeys + _loc5_.UncommonKeys + _loc5_.RareKeys + _loc5_.LegendaryKeys;
         var _loc4_:Boolean = gmOfferA.isAvailableTime();
         var _loc3_:Boolean = gmOfferB.isAvailableTime();
         if(_loc4_ && !_loc3_)
         {
            return -1;
         }
         if(_loc3_ && !_loc4_)
         {
            return 1;
         }
         if(_loc7_ == _loc8_)
         {
            return gmOfferA.Price - gmOfferB.Price;
         }
         return _loc7_ - _loc8_;
      }
      
      private function weaponSortComparator(gmOfferA:GMOffer, gmOfferB:GMOffer) : int
      {
         if(gmOfferA.IsBundle && gmOfferB.IsBundle)
         {
            return gmOfferA.Price - gmOfferB.Price;
         }
         if(gmOfferA.IsBundle && !gmOfferB.IsBundle)
         {
            return -1;
         }
         if(gmOfferB.IsBundle && !gmOfferA.IsBundle)
         {
            return 1;
         }
         var _loc4_:GMOfferDetail = gmOfferA.Details[0];
         var _loc3_:GMOfferDetail = gmOfferB.Details[0];
         var _loc6_:GMWeaponItem = mDBFacade.gameMaster.weaponItemById.itemFor(_loc4_.WeaponId);
         var _loc7_:GMWeaponItem = mDBFacade.gameMaster.weaponItemById.itemFor(_loc3_.WeaponId);
         var _loc5_:int = GMWeaponItem.ALL_WEAPON_SORT.indexOf(_loc6_.MasterType);
         var _loc8_:int = GMWeaponItem.ALL_WEAPON_SORT.indexOf(_loc7_.MasterType);
         if(_loc5_ == -1)
         {
            Logger.error("Mastertype not found: " + _loc6_.MasterType);
         }
         if(_loc8_ == -1)
         {
            Logger.error("Mastertype not found: " + _loc7_.MasterType);
         }
         if(gmOfferA.Details[0].Level == gmOfferB.Details[0].Level)
         {
            return _loc5_ - _loc8_;
         }
         return gmOfferA.Details[0].Level - gmOfferB.Details[0].Level;
      }
      
      private function sortOffers() : void
      {
         var _loc4_:Vector.<GMOffer> = mCategorizedGMOffers.itemFor("WEAPON");
         _loc4_.sort(weaponSortComparator);
         var _loc2_:Vector.<GMOffer> = mCategorizedGMOffers.itemFor("KEY");
         _loc2_.sort(keySortComparator);
         var _loc3_:Vector.<GMOffer> = mCategorizedGMOffers.itemFor("STUFF");
         _loc3_.sort(potionSortComparator);
         var _loc1_:Vector.<GMOffer> = mCategorizedGMOffers.itemFor("SPECIAL");
         _loc1_.sort(specialSortComparator);
      }
      
      private function setupUI(rootClip:MovieClip) : void
      {
         var group:String;
         var tabButton:UIRadioButton;
         var iter:IMapIterator;
         var weaponTooltipClass:Class;
         var heroTooltipClass:Class;
         mRoot = rootClip;
         mPagination = new UIPagingPanel(mDBFacade,0,mRoot.pagination,mSwfAsset.getClass("pagination_button"),this.setCurrentPage);
         MemoryTracker.track(mPagination,"UIPagingPanel - created in UIShop.setupUI()");
         mRoot.UI_town_shop_timer.visible = false;
         group = "UIShopTabGroup";
         mTabButtons.add("SPECIAL",new UIRadioButton(mDBFacade,mRoot.tab_special,group));
         mTabButtons.add("CHEST",new UIRadioButton(mDBFacade,mRoot.tab_chests,group));
         mTabButtons.add("KEY",new UIRadioButton(mDBFacade,mRoot.tab_keys,group));
         mTabButtons.add("HERO",new UIRadioButton(mDBFacade,mRoot.tab_heroes,group));
         mTabButtons.add("SKIN",new UIRadioButton(mDBFacade,mRoot.tab_skins,group));
         mTabButtons.add("STUFF",new UIRadioButton(mDBFacade,mRoot.tab_stuff,group));
         mTabButtons.add("WEAPON",new UIRadioButton(mDBFacade,mRoot.tab_melee,group));
         mTabButtons.add("PET",new UIRadioButton(mDBFacade,mRoot.tab_pets,group));
         iter = mTabButtons.iterator() as IMapIterator;
         while(iter.hasNext())
         {
            tabButton = iter.next();
            tabButton.root.new_label.text = Locale.getString("SHOP_NEW");
            tabButton.root.new_label.visible = this.categoryHasAnyNewOffers(iter.key);
            tabButton.root.category = iter.key;
            tabButton.releaseCallbackThis = function(param1:UIButton):void
            {
               showTab(param1.root.category);
            };
            tabButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            tabButton.selectedFilter = DBGlobal.UI_SELECTED_FILTER;
         }
         mEmptyOffers.push(mRoot.shop_empty_slot_0);
         mEmptyOffers.push(mRoot.shop_empty_slot_1);
         mEmptyOffers.push(mRoot.shop_empty_slot_2);
         mEmptyOffers.push(mRoot.shop_empty_slot_3);
         mEmptyOffers.push(mRoot.shop_empty_slot_4);
         mEmptyOffers.push(mRoot.shop_empty_slot_5);
         mOfferTemplateClass = mSwfAsset.getClass("shop_offer_template");
         mKeyOfferTemplateClass = mSwfAsset.getClass("shop_offer_key_template");
         mPremiumOfferTemplateClass = mSwfAsset.getClass("shop_offer_premium_template");
         mDLCOfferTemplateClass = mSwfAsset.getClass("shop_offer_dlc_template");
         mWeaponOfferTemplateClass = mSwfAsset.getClass("shop_offer_weapon_template");
         weaponTooltipClass = mSwfAsset.getClass("DR_weapon_tooltip");
         heroTooltipClass = mSwfAsset.getClass("avatar_tooltip");
         mHeroWithEquipPicker = new HeroWithEquipPicker(mDBFacade,mRoot.hero_picker,weaponTooltipClass,heroTooltipClass,heroSelected);
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",accountInfoUpdated);
      }
      
      private function accountInfoUpdated(evt:Event) : void
      {
         refresh();
      }
      
      public function animateEntry() : void
      {
         if(mDBFacade.featureFlags.getFlagValue("want-town-animations"))
         {
            mTownHeader.rootMovieClip.visible = false;
            mLogicalWorkComponent.doLater(0.20833333333333334,function(param1:GameClock):void
            {
               mTownHeader.animateHeader();
            });
            mHeroWithEquipPicker.visible = false;
            mLogicalWorkComponent.doLater(0.5,function(param1:GameClock):void
            {
               UITownTweens.footerTweenSequence(mHeroWithEquipPicker.root,mDBFacade);
            });
         }
      }
      
      private function numOffersInCurrentCategory() : uint
      {
         var _loc1_:Vector.<GMOffer> = mFilteredGMOffers.itemFor(mCurrentTab);
         if(_loc1_)
         {
            return _loc1_.length;
         }
         return 0;
      }
      
      private function numPagesInCurrentCategory() : uint
      {
         var _loc1_:uint = 1;
         if(mCurrentTab == "WEAPON")
         {
            return Math.ceil(numOffersInCurrentCategory() / 3);
         }
         return Math.ceil(numOffersInCurrentCategory() / 6);
      }
      
      private function displayCategoryPage() : void
      {
         var gmOffer:GMOffer;
         var uiShopOffer:UIShopOffer;
         var onscreenIndex:uint;
         var emptyOffer:MovieClip;
         var chargeTooltipClass:Class;
         var weaponDescTooltipClass:Class;
         var numOffersPerPage:uint;
         var startIndex:uint;
         var templateClass:Class;
         var successCallback:Function;
         var categoryOffers:Vector.<GMOffer> = mFilteredGMOffers.itemFor(mCurrentTab);
         var i:uint = 0;
         while(i < 6)
         {
            if(i < mUIOffers.length)
            {
               uiShopOffer = mUIOffers[i];
               uiShopOffer.detach();
               uiShopOffer.destroy();
            }
            mEmptyOffers[i].visible = false;
            i = i + 1;
         }
         mUIOffers.length = 0;
         if(mZeroOfferClip)
         {
            mEmptyOffers[1].parent.removeChild(mZeroOfferClip);
            mZeroOfferClip = null;
         }
         if(categoryOffers.length == 0)
         {
            emptyOffer = mEmptyOffers[1];
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
            {
               var _loc2_:Class = param1.getClass("shop_offer_inventory_empty");
               mZeroOfferClip = new _loc2_() as MovieClip;
               emptyOffer.parent.addChild(mZeroOfferClip);
               mZeroOfferClip.x = emptyOffer.x;
               mZeroOfferClip.y = emptyOffer.y;
               mZeroOfferClip.scaleX = mZeroOfferClip.scaleY = 1.8;
               mZeroOfferClip.title.text = Locale.getString("ZERO_OFFER_TITLE");
               mZeroOfferClip.description.text = Locale.getString("ZERO_OFFER_DESCRIPTION");
            });
            return;
         }
         chargeTooltipClass = mSwfAsset.getClass("DR_charge_tooltip");
         weaponDescTooltipClass = mSwfAsset.getClass("weapon_desc_tooltip");
         numOffersPerPage = mCurrentTab == "WEAPON" ? 3 : 6;
         startIndex = mCurrentPage * numOffersPerPage;
         i = startIndex;
         while(i < startIndex + numOffersPerPage)
         {
            if(i >= categoryOffers.length)
            {
               break;
            }
            gmOffer = categoryOffers[i];
            onscreenIndex = i % numOffersPerPage;
            if(gmOffer.CurrencyType == "PREMIUM" && gmOffer.Price)
            {
               templateClass = mPremiumOfferTemplateClass;
            }
            else if(gmOffer.CurrencyType == "DLC")
            {
               templateClass = mDLCOfferTemplateClass;
            }
            else
            {
               templateClass = mOfferTemplateClass;
            }
            templateClass = gmOffer.Tab == "KEY" || gmOffer.Tab == "CHEST" ? mKeyOfferTemplateClass : templateClass;
            templateClass = gmOffer.Tab == "WEAPON" ? mWeaponOfferTemplateClass : templateClass;
            if(gmOffer.Details[0].ChestId)
            {
               uiShopOffer = new UIChestOffer(mDBFacade,templateClass,this.mHeroWithEquipPicker.currentlySelectedAvatarInfo,chestRevealResponse);
            }
            else if(gmOffer.IsBundle)
            {
               uiShopOffer = new UIShopBundleOffer(mDBFacade,templateClass);
            }
            else if(gmOffer.Details[0].WeaponId)
            {
               uiShopOffer = new UIShopWeaponOffer(mDBFacade,templateClass,weaponDescTooltipClass,chargeTooltipClass);
               UIShopWeaponOffer(uiShopOffer).setRolloverCallbacks(onWeaponRollOver,onWeaponRollOut);
            }
            else if(gmOffer.Details[0].HeroId)
            {
               successCallback = function(param1:uint):Function
               {
                  var heroId:uint = param1;
                  return function():void
                  {
                     if(!mDBFacade)
                     {
                        return;
                     }
                     var _loc1_:GMHero = mDBFacade.gameMaster.heroById.itemFor(heroId);
                     if(!_loc1_)
                     {
                        return;
                     }
                     DBFacebookBragFeedPost.buyHeroSuccess(mTownHeader,_loc1_,mDBFacade,mAssetLoadingComponent);
                  };
               };
               uiShopOffer = new UIShopHeroOffer(mTownHeader,mDBFacade,templateClass,successCallback(gmOffer.Details[0].HeroId));
            }
            else if(gmOffer.Details[0].PetId)
            {
               successCallback = function(param1:uint):Function
               {
                  var petId:uint = param1;
                  return function():void
                  {
                     if(!mDBFacade)
                     {
                        return;
                     }
                     var _loc1_:GMNpc = mDBFacade.gameMaster.npcById.itemFor(petId);
                     if(!_loc1_)
                     {
                        return;
                     }
                     DBFacebookBragFeedPost.buyPetSuccess(_loc1_,mDBFacade,mAssetLoadingComponent);
                  };
               };
               uiShopOffer = new UIShopPetOffer(mDBFacade,templateClass,successCallback(gmOffer.Details[0].PetId));
            }
            else if(gmOffer.Details[0].SkinId)
            {
               successCallback = function(param1:uint):Function
               {
                  var skinId:uint = param1;
                  return function():void
                  {
                     if(!mDBFacade)
                     {
                        return;
                     }
                     var _loc1_:GMSkin = mDBFacade.gameMaster.getSkinByType(skinId);
                     if(!_loc1_)
                     {
                        return;
                     }
                     DBFacebookBragFeedPost.buySkinSuccess(_loc1_,mDBFacade,mAssetLoadingComponent);
                  };
               };
               uiShopOffer = new UIShopSkinOffer(mDBFacade,templateClass,successCallback(gmOffer.Details[0].SkinId));
            }
            else
            {
               uiShopOffer = new UIShopOffer(mDBFacade,templateClass);
            }
            emptyOffer = mEmptyOffers[onscreenIndex];
            emptyOffer.parent.addChild(uiShopOffer.root);
            uiShopOffer.root.x = emptyOffer.x;
            uiShopOffer.root.y = emptyOffer.y;
            mUIOffers[onscreenIndex] = uiShopOffer;
            uiShopOffer.showOffer(gmOffer,mSelectedHero);
            uiShopOffer.root.visible = true;
            uiShopOffer.root.scaleX = uiShopOffer.root.scaleY = 1.8;
            mEmptyOffers[onscreenIndex].visible = false;
            if(mCurrentTab == "WEAPON")
            {
               uiShopOffer.root.y += 72;
            }
            i = i + 1;
         }
         if(mCurrentTab == "WEAPON")
         {
            mRoot.UI_town_shop_timer.visible = true;
            createTodaysShopTimerUI(gmOffer);
         }
         else
         {
            mRoot.UI_town_shop_timer.visible = false;
            cleanUpTodaysShopTimerUI();
         }
      }
      
      private function createTodaysShopTimerUI(gmOffer:GMOffer) : void
      {
         mRoot.UI_town_shop_timer.offer_title.text = Locale.getString("TODAYS_WEAPONS");
         mRoot.UI_town_shop_timer.label_date.text = getDate();
         if(gmOffer)
         {
            mRoot.UI_town_shop_timer.label_timer.visible = true;
            mRoot.UI_town_shop_timer.label_remaining.visible = true;
            mRoot.UI_town_shop_timer.label_remaining.text = Locale.getString("TODAYS_WEAPONS_REMAINING");
            mWeaponTabEndDate = gmOffer.EndDate;
            mWeaponsLogicalWorkComponent.doEverySeconds(1,updateRemainingTimeText);
         }
         else
         {
            mRoot.UI_town_shop_timer.label_timer.visible = false;
            mRoot.UI_town_shop_timer.label_remaining.visible = false;
            cleanUpTodaysShopTimerUI();
         }
      }
      
      private function cleanUpTodaysShopTimerUI() : void
      {
         mWeaponsLogicalWorkComponent.clear();
      }
      
      private function updateRemainingTimeText(clock:GameClock = null) : void
      {
         var _loc6_:TimeSpan = null;
         var _loc2_:String = null;
         var _loc4_:String = null;
         var _loc3_:String = null;
         var _loc5_:Date = GameClock.getWebServerDate();
         if(_loc5_.time > mWeaponTabEndDate.time)
         {
            mRoot.UI_town_shop_timer.label_timer.text = "00:00:00";
            regenerateOffers();
         }
         else
         {
            _loc6_ = new TimeSpan(mWeaponTabEndDate.time - _loc5_.time);
            _loc2_ = _loc6_.hours.toString();
            if(_loc2_.length == 1)
            {
               _loc2_ = "0" + _loc2_;
            }
            _loc4_ = _loc6_.minutes.toString();
            if(_loc4_.length == 1)
            {
               _loc4_ = "0" + _loc4_;
            }
            _loc3_ = _loc6_.seconds.toString();
            if(_loc3_.length == 1)
            {
               _loc3_ = "0" + _loc3_;
            }
            mRoot.UI_town_shop_timer.label_timer.text = _loc2_ + ":" + _loc4_ + ":" + _loc3_;
         }
      }
      
      private function chestRevealResponse(obj:Object) : void
      {
      }
      
      private function getDate() : String
      {
         var _loc4_:String = null;
         var _loc2_:String = null;
         var _loc5_:Date = GameClock.getWebServerDate();
         var _loc3_:String = String(_loc5_.getFullYear());
         switch(_loc5_.getDay())
         {
            case 0:
               _loc4_ = "Sunday";
               break;
            case 1:
               _loc4_ = "Monday";
               break;
            case 2:
               _loc4_ = "Tuesday";
               break;
            case 3:
               _loc4_ = "Wednesday";
               break;
            case 4:
               _loc4_ = "Thursday";
               break;
            case 5:
               _loc4_ = "Friday";
               break;
            case 6:
               _loc4_ = "Saturday";
         }
         switch(_loc5_.getMonth())
         {
            case 0:
               _loc2_ = "January";
               break;
            case 1:
               _loc2_ = "February";
               break;
            case 2:
               _loc2_ = "March";
               break;
            case 3:
               _loc2_ = "April";
               break;
            case 4:
               _loc2_ = "May";
               break;
            case 5:
               _loc2_ = "June";
               break;
            case 6:
               _loc2_ = "July";
               break;
            case 7:
               _loc2_ = "August";
               break;
            case 8:
               _loc2_ = "September";
               break;
            case 9:
               _loc2_ = "October";
               break;
            case 10:
               _loc2_ = "November";
               break;
            case 11:
               _loc2_ = "December";
         }
         var _loc1_:String = String(_loc5_.getDate());
         return _loc4_ + " " + _loc2_ + " " + _loc1_;
      }
      
      private function onWeaponRollOver(gmWeaponItem:GMWeaponItem, power:uint) : void
      {
         mHeroWithEquipPicker.showWeaponComparison(gmWeaponItem,power);
      }
      
      private function onWeaponRollOut(gmWeaponItem:GMWeaponItem, power:uint) : void
      {
         mHeroWithEquipPicker.hideWeaponComparison();
      }
      
      public function showTab(category:String, page:uint = 0) : void
      {
         var _loc3_:UIRadioButton = null;
         mCurrentTab = category;
         var _loc4_:IMapIterator = mTabButtons.iterator() as IMapIterator;
         while(_loc4_.hasNext())
         {
            _loc3_ = _loc4_.next();
            _loc3_.enabled = true;
         }
         _loc3_ = mTabButtons.itemFor(mCurrentTab);
         _loc3_.selected = true;
         _loc3_.enabled = false;
         _loc3_.label.visible = true;
         if(mCurrentTab == "WEAPON")
         {
            page = this.firstWeaponPageForActiveHero();
         }
         this.refreshPagination(page);
         mDBFacade.metrics.log("ShopDisplay",{
            "category":mCurrentTab,
            "page":mCurrentPage
         });
         displayCategoryPage();
      }
      
      private function firstWeaponPageForActiveHero() : uint
      {
         var _loc1_:* = 0;
         var _loc5_:* = undefined;
         var _loc3_:* = 0;
         var _loc6_:* = 0;
         var _loc8_:GMOffer = null;
         var _loc2_:GMWeaponItem = null;
         var _loc7_:uint = 0;
         var _loc4_:AvatarInfo = mSelectedHero ? mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mSelectedHero.Id) : null;
         if(_loc4_)
         {
            _loc1_ = _loc4_.level;
            _loc5_ = mFilteredGMOffers.itemFor(mCurrentTab);
            _loc3_ = uint(mCurrentTab == "WEAPON" ? 3 : 6);
            _loc6_ = 0;
            while(_loc6_ < _loc5_.length)
            {
               _loc8_ = _loc5_[_loc6_];
               if(_loc8_.Details[0].WeaponId)
               {
                  _loc2_ = mDBFacade.gameMaster.weaponItemById.itemFor(_loc8_.Details[0].WeaponId);
                  _loc7_ = Math.floor(_loc6_ / _loc3_);
                  if(_loc8_.Details[0].Level >= _loc1_)
                  {
                     return _loc7_;
                  }
                  return 0;
               }
               _loc6_++;
            }
         }
         return _loc7_;
      }
      
      private function refreshPagination(page:uint) : void
      {
         var _loc2_:uint = this.numPagesInCurrentCategory();
         mPagination.currentPage = mCurrentPage = _loc2_ ? Math.min(_loc2_ - 1,page) : 0;
         mPagination.numPages = _loc2_;
         mPagination.visible = _loc2_ > 1;
      }
      
      private function setCurrentPage(page:uint) : void
      {
         this.refreshPagination(page);
         mDBFacade.metrics.log("ShopDisplay",{
            "category":mCurrentTab,
            "page":mCurrentPage
         });
         displayCategoryPage();
      }
      
      public function jumpToOffer(offerId:uint) : Boolean
      {
         var _loc6_:GMOffer = mDBFacade.gameMaster.offerById.itemFor(offerId);
         if(_loc6_ == null)
         {
            return false;
         }
         var _loc5_:String = _loc6_.Tab;
         var _loc2_:Vector.<GMOffer> = mFilteredGMOffers.itemFor(_loc5_);
         var _loc3_:int = _loc2_.indexOf(_loc6_);
         if(_loc3_ == -1)
         {
            return false;
         }
         var _loc4_:uint = Math.floor(_loc3_ / 6);
         this.showTab(_loc5_,_loc4_);
         return true;
      }
      
      private function categoryHasAnyNewOffers(category:String) : Boolean
      {
         var _loc2_:* = null;
         var _loc3_:Vector.<GMOffer> = mFilteredGMOffers.itemFor(category);
         if(_loc3_ == null)
         {
            Logger.error("invalid category: " + category);
         }
         for each(_loc2_ in _loc3_)
         {
            if(_loc2_.isNew)
            {
               return true;
            }
         }
         return false;
      }
      
      private function filterOffers() : void
      {
         var _loc10_:* = null;
         var _loc1_:* = undefined;
         var _loc2_:* = null;
         var _loc8_:* = 0;
         var _loc9_:* = 0;
         var _loc11_:* = 0;
         var _loc7_:* = 0;
         var _loc4_:String = null;
         var _loc3_:* = 0;
         var _loc6_:GMHero = null;
         var _loc5_:AvatarInfo = mSelectedHero ? mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mSelectedHero.Id) : null;
         mFilteredGMOffers.clear();
         for each(_loc10_ in CATEGORIES)
         {
            _loc1_ = new Vector.<GMOffer>();
            mFilteredGMOffers.add(_loc10_,_loc1_);
            for each(_loc2_ in mCategorizedGMOffers.itemFor(_loc10_))
            {
               if(!_loc2_.SaleTargetOffer)
               {
                  if(!_loc2_.IsCoinAltOffer)
                  {
                     if(!(_loc10_ == "SPECIAL" && StoreServicesController.alreadyOwns(mDBFacade,_loc2_)))
                     {
                        if(!(_loc2_.IsBundle && StoreServicesController.alreadyOwns(mDBFacade,_loc2_)))
                        {
                           if(mSelectedHero)
                           {
                              _loc11_ = StoreServicesController.requiredHeroForWeapon(mDBFacade,_loc2_);
                              if(_loc11_ && _loc11_ != mSelectedHero.Id)
                              {
                                 continue;
                              }
                              _loc7_ = StoreServicesController.getOfferLevelReq(mDBFacade,_loc2_);
                              _loc3_ = uint(_loc5_ ? _loc5_.level : 1);
                              _loc4_ = StoreServicesController.getWeaponMastertype(mDBFacade,_loc2_);
                              if(_loc4_ && !mSelectedHero.AllowedWeapons.hasKey(_loc4_))
                              {
                                 continue;
                              }
                           }
                           _loc8_ = StoreServicesController.getHeroId(mDBFacade,_loc2_);
                           _loc6_ = mDBFacade.gameMaster.heroById.itemFor(_loc8_);
                           if(!(_loc6_ != null && _loc6_.Hidden && !mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes",false)))
                           {
                              if(!(_loc8_ && mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(_loc8_)))
                              {
                                 _loc9_ = StoreServicesController.getSkinId(mDBFacade,_loc2_);
                                 if(!(_loc9_ && mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(_loc9_)))
                                 {
                                    _loc1_.push(_loc2_);
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function heroSelected(gmHero:GMHero, owned:Boolean) : void
      {
         mSelectedHero = gmHero;
         this.filterOffers();
         if(mCurrentTab == "WEAPON")
         {
            this.refreshPagination(this.firstWeaponPageForActiveHero());
         }
         this.displayCategoryPage();
      }
      
      public function processChosenAvatar() : void
      {
         var _loc1_:uint = mHeroWithEquipPicker.currentlySelectedHero.Id;
         if(mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero.Id != _loc1_)
         {
            mDBFacade.dbAccountInfo.changeActiveAvatarRPC(_loc1_);
         }
      }
   }
}

