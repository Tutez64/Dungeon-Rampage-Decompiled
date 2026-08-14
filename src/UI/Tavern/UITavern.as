package UI.Tavern
{
   import Account.AvatarInfo;
   import Account.StoreServicesController;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.UI.UIProgressBar;
   import Brain.Utils.ColorMatrix;
   import Brain.WorkLoop.LogicalWorkComponent;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import FacebookAPI.DBFacebookBragFeedPost;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMSkin;
   import GameMasterDictionary.GMWeaponMastertype;
   import Town.TownHeader;
   import UI.*;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class UITavern
   {
      
      protected static const ONE_DAY_MS:Number = 86400000;
      
      protected static const ONE_HOUR_MS:Number = 3600000;
      
      private var mRootMovieClip:MovieClip;
      
      private var mDBFacade:DBFacade;
      
      private var mHeroSlots:Vector.<UIButton>;
      
      private var mWeaponIconsVector:Vector.<UIObject>;
      
      private var mWeaponIcons3:Vector.<UIObject>;
      
      private var mWeaponIcons4:Vector.<UIObject>;
      
      private var mSkinVector:Vector.<UITavernSkinButton>;
      
      private var mAvatarSelectorStartIndex:int = 0;
      
      private var mSelectorRightScroll:UIButton;
      
      private var mSelectorLeftScroll:UIButton;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mBuyButton:UIButton;
      
      private var mBuyButtonCoin:UIButton;
      
      private var mBuyButtonCash:UIButton;
      
      private var mHeroRequiredForSkinPurchase:MovieClip;
      
      private var mChosenAvatarID:uint;
      
      private var mAvatarIdToMakeActiveAvatar:uint;
      
      private var mCurrentChosenIndex:int;
      
      private var mActiveAvatar:AvatarInfo;
      
      private var mXPBar:UIProgressBar;
      
      private var mXPText:TextField;
      
      private var mXPLevelText:TextField;
      
      private var mXPParentObject:UIObject;
      
      private var mSaleLabel:TextField;
      
      private var mTavernInfoClip:MovieClip;
      
      private var mCharacterInfoClip:MovieClip;
      
      private var mSkinInfoClip:MovieClip;
      
      private var mSkinNameLabel:TextField;
      
      private var mSkinNotAvailableLabel:TextField;
      
      private var mStoryInfoClip:MovieClip;
      
      private var mAttackStars:Vector.<MovieClip>;
      
      private var mDefenseStars:Vector.<MovieClip>;
      
      private var mSpeedStars:Vector.<MovieClip>;
      
      private var mAvatarSelector:MovieClip;
      
      private var mHeroPic:MovieClip;
      
      private var mHeroSelectionsToFlush:Map;
      
      private var mTownHeader:TownHeader;
      
      private var mHeroOffers:Map;
      
      private var mSkinOffers:Map;
      
      private var mScaledSlotIndex:int;
      
      private var mHeroIds:Vector.<uint>;
      
      private var mScrollSkinsLeftButton:UIButton;
      
      private var mScrollSkinsRightButton:UIButton;
      
      private var mSkinStartIndex:uint;
      
      private var mSelectedSkin:GMSkin;
      
      private var mChosenSkin:GMSkin;
      
      private var mWantSkins:Boolean;
      
      private var mRecruitButton:UIButton;
      
      public function UITavern(dbFacade:DBFacade, root:MovieClip, townHeader:TownHeader)
      {
         super();
         mHeroSlots = new Vector.<UIButton>();
         mHeroSelectionsToFlush = new Map();
         mWeaponIcons3 = new Vector.<UIObject>();
         mWeaponIcons4 = new Vector.<UIObject>();
         mHeroIds = new Vector.<uint>();
         mHeroOffers = new Map();
         mSkinOffers = new Map();
         mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(dbFacade,"UITavern");
         mRootMovieClip = root;
         mRootMovieClip.select_hero.visible = false;
         mDBFacade = dbFacade;
         mTownHeader = townHeader;
         mWantSkins = mDBFacade.dbConfigManager.getConfigBoolean("want_skins",true);
         loadHeroOffers();
         loadSkinOffers();
         mChosenAvatarID = 0;
         loadTavernInfo();
         loadAvatarChoiceArray();
      }
      
      private function loadTavernInfo() : void
      {
         mHeroPic = mRootMovieClip.UI_town_tavern_body.UI_town_tavern_avatar_pic;
         var noSkinsMovieClip:MovieClip = mRootMovieClip.UI_town_tavern_body.UI_town_tavern_avatar_info;
         var skinsMovieClip:MovieClip = mRootMovieClip.UI_town_tavern_body.UI_town_tavern_avatar_info_skin;
         if(mWantSkins)
         {
            mTavernInfoClip = skinsMovieClip;
            noSkinsMovieClip.visible = false;
         }
         else
         {
            mRootMovieClip.select_hero.visible = false;
            mRootMovieClip.skin_frame.visible = false;
            mTavernInfoClip = noSkinsMovieClip;
            skinsMovieClip.visible = false;
            mRootMovieClip.UI_town_tavern_body.skin_frame.visible = false;
         }
         mWeaponIcons3.push(new UIObject(mDBFacade,mTavernInfoClip.character_info.weapons_3.weapon_icon_slot_0));
         mWeaponIcons3.push(new UIObject(mDBFacade,mTavernInfoClip.character_info.weapons_3.weapon_icon_slot_1));
         mWeaponIcons3.push(new UIObject(mDBFacade,mTavernInfoClip.character_info.weapons_3.weapon_icon_slot_2));
         mWeaponIcons4.push(new UIObject(mDBFacade,mTavernInfoClip.character_info.weapons_4.weapon_icon_slot_0));
         mWeaponIcons4.push(new UIObject(mDBFacade,mTavernInfoClip.character_info.weapons_4.weapon_icon_slot_1));
         mWeaponIcons4.push(new UIObject(mDBFacade,mTavernInfoClip.character_info.weapons_4.weapon_icon_slot_2));
         mWeaponIcons4.push(new UIObject(mDBFacade,mTavernInfoClip.character_info.weapons_4.weapon_icon_slot_3));
         mStoryInfoClip = mTavernInfoClip.story_info;
         mStoryInfoClip.visible = true;
         mAttackStars = new Vector.<MovieClip>();
         mAttackStars.push(mStoryInfoClip.attack_star_0,mStoryInfoClip.attack_star_1,mStoryInfoClip.attack_star_2,mStoryInfoClip.attack_star_3,mStoryInfoClip.attack_star_4);
         mDefenseStars = new Vector.<MovieClip>();
         mDefenseStars.push(mStoryInfoClip.defense_star_0,mStoryInfoClip.defense_star_1,mStoryInfoClip.defense_star_2,mStoryInfoClip.defense_star_3,mStoryInfoClip.defense_star_4);
         mSpeedStars = new Vector.<MovieClip>();
         mSpeedStars.push(mStoryInfoClip.speed_star_0,mStoryInfoClip.speed_star_1,mStoryInfoClip.speed_star_2,mStoryInfoClip.speed_star_3,mStoryInfoClip.speed_star_4);
         mStoryInfoClip.likes_text.text = Locale.getString("TAVERN_LIKES_LABEL");
         mStoryInfoClip.dislikes_text.text = Locale.getString("TAVERN_DISLIKES_LABEL");
         mStoryInfoClip.attack_label.text = Locale.getString("TAVERN_ATTACK_LABEL");
         mStoryInfoClip.defense_label.text = Locale.getString("TAVERN_DEFENSE_LABEL");
         mStoryInfoClip.speed_label.text = Locale.getString("TAVERN_SPEED_LABEL");
         mCharacterInfoClip = mTavernInfoClip.character_info;
         mCharacterInfoClip.visible = true;
         mCharacterInfoClip.weapon_types_text.text = Locale.getString("TAVERN_USABLE_WEAPON_TYPES_LABEL");
         mSkinInfoClip = mRootMovieClip.UI_town_tavern_body.UI_town_tavern_skin;
         mSkinNameLabel = mSkinInfoClip.skin_name_text;
         mSkinNotAvailableLabel = mSkinInfoClip.label_not_available;
         mSkinNotAvailableLabel.text = Locale.getString("TAVERN_SKIN_NOT_AVAILABLE");
         mSkinNotAvailableLabel.mouseEnabled = false;
         mSkinNotAvailableLabel.visible = false;
         mSkinVector = new Vector.<UITavernSkinButton>();
         mSkinVector.push(new UITavernSkinButton(mDBFacade,mSkinInfoClip.skin_slot_0,skinSelected));
         mSkinVector.push(new UITavernSkinButton(mDBFacade,mSkinInfoClip.skin_slot_1,skinSelected));
         mSkinVector.push(new UITavernSkinButton(mDBFacade,mSkinInfoClip.skin_slot_2,skinSelected));
         mScrollSkinsLeftButton = new UIButton(mDBFacade,mSkinInfoClip.moveLeft);
         mScrollSkinsLeftButton.releaseCallback = function():void
         {
            scrollSkins(-1);
         };
         mScrollSkinsRightButton = new UIButton(mDBFacade,mSkinInfoClip.moveRight);
         mScrollSkinsRightButton.releaseCallback = function():void
         {
            scrollSkins(1);
         };
         mBuyButton = new UIButton(mDBFacade,mSkinInfoClip.skin_buy_button);
         mBuyButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonCoin = new UIButton(mDBFacade,mSkinInfoClip.buy_button_coins);
         mBuyButtonCoin.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonCoin.root.icons_bundle.cash.visible = false;
         mBuyButtonCoin.root.icons_bundle.gift_icon.visible = false;
         mBuyButtonCoin.root.original_price.visible = false;
         mBuyButtonCoin.root.strike.visible = false;
         mBuyButtonCash = new UIButton(mDBFacade,mSkinInfoClip.buy_button_gems);
         mBuyButtonCash.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonCash.root.icons_bundle.coin.visible = false;
         mBuyButtonCash.root.icons_bundle.gift_icon.visible = false;
         mBuyButtonCash.root.original_price.visible = false;
         mBuyButtonCash.root.strike.visible = false;
         mRecruitButton = new UIButton(mDBFacade,mSkinInfoClip.exclusive_offer);
         mRecruitButton.releaseCallback = function():void
         {
            StoreServicesController.showCashPage(mDBFacade,"tavernBuyButtonExclusiveOfferDragonKnight");
         };
         mRecruitButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mRecruitButton.visible = false;
         mHeroRequiredForSkinPurchase = mSkinInfoClip.hero_required_label;
         mHeroRequiredForSkinPurchase.hero_label.text = Locale.getString("PURCHASE_HERO_BEFORE_BUYING_SYTLE_TAVERN_LABEL");
         mSaleLabel = mTavernInfoClip.sale_label;
         mSaleLabel.visible = false;
         mXPParentObject = new UIObject(mDBFacade,mTavernInfoClip.character_info.UI_XP);
         mXPBar = new UIProgressBar(mDBFacade,mTavernInfoClip.character_info.UI_XP.xp_bar);
         mXPText = mTavernInfoClip.character_info.UI_XP.xp_points;
         mXPText.scaleY = mXPText.scaleX = 1.8;
         mXPText.x = 80;
         mXPText.y = 25;
         mXPParentObject.setTooltip(mXPText);
         mXPParentObject.tooltipDelay = 0;
         mXPBar.value = 0;
         mXPLevelText = mTavernInfoClip.character_info.UI_XP.xp_level;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass("weapon_tavern_tooltip");
            var _loc3_:Class = param1.getClass("tavern_gloat");
            for each(var _loc4_:UIObject in mWeaponIcons3)
            {
               _loc4_.tooltip = new _loc2_();
               _loc4_.tooltipPos = new Point(0,0);
            }
            for each(_loc4_ in mWeaponIcons4)
            {
               _loc4_.tooltip = new _loc2_();
               _loc4_.tooltipPos = new Point(0,0);
            }
         });
      }
      
      private function loadAvatarChoiceArray() : void
      {
         var i:int;
         var makeCallbackFunc:Function;
         var keys:Array;
         var avatarStartIndex:uint;
         mAvatarSelector = mRootMovieClip.UI_town_tavern_body.UI_town_tavern_avatar_selector;
         mHeroSlots.push(new UIButton(mDBFacade,mAvatarSelector.slot_0));
         mHeroSlots.push(new UIButton(mDBFacade,mAvatarSelector.slot_1));
         mHeroSlots.push(new UIButton(mDBFacade,mAvatarSelector.slot_2));
         mHeroSlots.push(new UIButton(mDBFacade,mAvatarSelector.slot_3));
         mHeroSlots.push(new UIButton(mDBFacade,mAvatarSelector.slot_4));
         mHeroSlots.push(new UIButton(mDBFacade,mAvatarSelector.slot_5));
         mHeroSlots.push(new UIButton(mDBFacade,mAvatarSelector.slot_6));
         mHeroSlots.push(new UIButton(mDBFacade,mAvatarSelector.slot_7));
         i = 0;
         while(i < mHeroSlots.length)
         {
            if(mHeroSlots[i].root.chosen)
            {
               mHeroSlots[i].root.chosen.visible = false;
            }
            mHeroSlots[i].rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            makeCallbackFunc = function(param1:int):Function
            {
               var value:int = param1;
               return function():void
               {
                  populateAvatarInfo(value);
               };
            };
            mHeroSlots[i].releaseCallback = makeCallbackFunc(i);
            i = i + 1;
         }
         mSelectorLeftScroll = new UIButton(mDBFacade,mAvatarSelector.moveLeft);
         mSelectorRightScroll = new UIButton(mDBFacade,mAvatarSelector.moveRight);
         mSelectorLeftScroll.releaseCallback = scrollLeft;
         mSelectorRightScroll.releaseCallback = scrollRight;
         mActiveAvatar = mDBFacade.dbAccountInfo.activeAvatarInfo;
         if(!mActiveAvatar && mDBFacade.dbAccountInfo.inventoryInfo.avatars.size > 0)
         {
            keys = mDBFacade.dbAccountInfo.inventoryInfo.avatars.keysToArray();
            mActiveAvatar = mDBFacade.dbAccountInfo.inventoryInfo.avatars.itemFor(keys[0]);
         }
         avatarStartIndex = getActiveAvatarIndex();
         if(mHeroIds.length <= mHeroSlots.length)
         {
            mSelectorRightScroll.visible = false;
         }
         if(mAvatarSelectorStartIndex == 0)
         {
            mSelectorLeftScroll.visible = false;
         }
         mCurrentChosenIndex = avatarStartIndex;
         populateAvatarSelector();
         populateAvatarInfo(avatarStartIndex);
      }
      
      private function getActiveAvatarIndex() : uint
      {
         var _loc2_:int = 0;
         var _loc1_:uint = 0;
         if(mActiveAvatar)
         {
            _loc2_ = 0;
            while(_loc2_ < mHeroIds.length)
            {
               if(mHeroIds[_loc2_] == mActiveAvatar.avatarType)
               {
                  _loc1_ = uint(_loc2_);
                  if(_loc2_ >= mHeroSlots.length)
                  {
                     mAvatarSelectorStartIndex = _loc2_ - mHeroSlots.length + 1;
                     _loc1_ = mHeroSlots.length - 1;
                  }
                  break;
               }
               _loc2_++;
            }
         }
         return _loc1_;
      }
      
      private function loadHeroOffers() : void
      {
         var _loc2_:GMOffer = null;
         var _loc3_:int = 0;
         var _loc1_:Vector.<GMOffer> = mDBFacade.gameMaster.Offers;
         for each(var _loc4_:GMHero in mDBFacade.gameMaster.Heroes)
         {
            if(!(_loc4_.Hidden && !mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes",false)))
            {
               mHeroIds.push(_loc4_.Id);
               _loc3_ = 0;
               while(_loc3_ < _loc1_.length)
               {
                  _loc2_ = _loc1_[_loc3_];
                  if(_loc2_.Tab == "HERO" && _loc2_.Location == "STORE" && !_loc2_.IsBundle && !_loc2_.SaleTargetOffer && !_loc2_.IsCoinAltOffer)
                  {
                     if(_loc2_.Details[0].HeroId == _loc4_.Id)
                     {
                        mHeroOffers.add(_loc4_.Id,_loc2_);
                        break;
                     }
                  }
                  _loc3_++;
               }
            }
         }
         mHeroIds.sort(heroIdSort);
      }
      
      private function loadSkinOffers() : void
      {
         var _loc2_:GMOffer = null;
         var _loc4_:int = 0;
         var _loc1_:Vector.<GMOffer> = mDBFacade.gameMaster.Offers;
         _loc4_ = 0;
         while(_loc4_ < _loc1_.length)
         {
            _loc2_ = _loc1_[_loc4_];
            if(_loc2_.Tab == "SKIN" && _loc2_.Location == "STORE" && !_loc2_.IsBundle && !_loc2_.IsCoinAltOffer && _loc2_.isVisible())
            {
               for each(var _loc3_:GMSkin in mDBFacade.gameMaster.Skins)
               {
                  if(_loc2_.Details[0].SkinId == _loc3_.Id)
                  {
                     mSkinOffers.add(_loc3_.Id,_loc2_);
                     break;
                  }
               }
            }
            _loc4_++;
         }
      }
      
      private function getSkinsToDisplay(gmHero:GMHero) : Vector.<GMSkin>
      {
         return mDBFacade.dbAccountInfo.inventoryInfo.getSkinsForHero(gmHero,mSkinOffers);
      }
      
      private function heroIdSort(id1:uint, id2:uint) : int
      {
         if(id1 < id2)
         {
            return -1;
         }
         return 1;
      }
      
      public function animateEntry() : void
      {
         if(mDBFacade.featureFlags.getFlagValue("want-town-animations"))
         {
            UITownTweens.avatarFadeInTweenSequence(mHeroPic);
            mTownHeader.rootMovieClip.visible = false;
            mLogicalWorkComponent.doLater(0.20833333333333334,function(param1:GameClock):void
            {
               mTownHeader.animateHeader();
            });
            mTavernInfoClip.visible = false;
            mLogicalWorkComponent.doLater(0.16666666666666666,function(param1:GameClock):void
            {
               UITownTweens.rightPanelTweenSequence(mTavernInfoClip,mDBFacade);
            });
            mAvatarSelector.visible = false;
            mLogicalWorkComponent.doLater(0.5,function(param1:GameClock):void
            {
               UITownTweens.footerTweenSequence(mAvatarSelector,mDBFacade);
            });
         }
      }
      
      public function refresh() : void
      {
         var _loc2_:int = 0;
         setupNavigationLinks();
         setupHeaderLinks();
         setupHeroSlotsNavigationLinks();
         setupUsableWeaponsMenuNavigations();
         _loc2_ = 0;
         while(_loc2_ < mHeroSlots.length)
         {
            if(mHeroSlots[_loc2_].root.chosen)
            {
               mHeroSlots[_loc2_].root.chosen.visible = false;
            }
            _loc2_++;
         }
         mActiveAvatar = mDBFacade.dbAccountInfo.activeAvatarInfo;
         var _loc1_:uint = getActiveAvatarIndex();
         mCurrentChosenIndex = _loc1_;
         if(mHeroSlots[mCurrentChosenIndex].root.chosen)
         {
            mHeroSlots[mCurrentChosenIndex].root.chosen.visible = true;
         }
         populateAvatarInfo(_loc1_);
         mTownHeader.title = Locale.getString("TAVERN_HEADER");
         populateAvatarSelector();
      }
      
      private function populateAvatarSelector() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < mHeroSlots.length)
         {
            if(mHeroIds.length > _loc1_ + mAvatarSelectorStartIndex)
            {
               loadAvatarHolderAtPosition(_loc1_ + mAvatarSelectorStartIndex,_loc1_);
            }
            else
            {
               mHeroSlots[_loc1_].root.xp_star.visible = false;
            }
            _loc1_++;
         }
      }
      
      private function loadAvatarHolderAtPosition(heroIndex:int, vectorIndex:int) : void
      {
         var gmSkin:GMSkin;
         var iconName:String;
         var swfFilePath:String;
         var gmHero:GMHero = mDBFacade.gameMaster.heroById.itemFor(mHeroIds[heroIndex]);
         var avatarID:uint = gmHero.Id;
         var avatarInfo:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(gmHero.Id);
         if(avatarInfo == null)
         {
            mHeroSlots[heroIndex].root.xp_star.visible = false;
            gmSkin = mDBFacade.gameMaster.getSkinByConstant(gmHero.DefaultSkin);
         }
         else
         {
            mHeroSlots[heroIndex].root.xp_star.visible = true;
            mHeroSlots[heroIndex].root.xp_star.xp_text.text = avatarInfo.level;
            gmSkin = mDBFacade.gameMaster.getSkinByType(avatarInfo.skinId);
         }
         iconName = gmSkin.IconName;
         swfFilePath = gmSkin.UISwfFilepath;
         mHeroSlots[vectorIndex].root.coming_soon.visible = false;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfFilePath),function(param1:SwfAsset):void
         {
            var _loc3_:ColorMatrix = null;
            var _loc4_:Class = param1.getClass(iconName);
            if(_loc4_ == null)
            {
               return;
            }
            var _loc2_:MovieClip = new _loc4_();
            _loc2_.scaleX *= 0.86;
            _loc2_.scaleY *= 0.86;
            if(mHeroSlots[vectorIndex].root.avatar_icon.numChildren > 0)
            {
               mHeroSlots[vectorIndex].root.avatar_icon.removeChildAt(0);
            }
            mHeroSlots[vectorIndex].root.avatar_icon.addChildAt(_loc2_,0);
            mHeroSlots[vectorIndex].root.avatar_mask.visible = false;
            if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(avatarID))
            {
               mHeroSlots[vectorIndex].root.avatar_icon.filters = [];
            }
            else
            {
               _loc3_ = new ColorMatrix();
               _loc3_.adjustSaturation(0.1);
               _loc3_.adjustBrightness(-64);
               _loc3_.adjustContrast(-0.5);
               mHeroSlots[vectorIndex].root.avatar_icon.filters = [_loc3_.filter];
            }
         });
      }
      
      private function scrollLeft() : void
      {
         currentChosenIndex = mCurrentChosenIndex + 1;
         avatarSelectorStartIndex = mAvatarSelectorStartIndex - 1;
         handleScaledSlotIndex(1);
      }
      
      private function scrollRight() : void
      {
         currentChosenIndex = mCurrentChosenIndex - 1;
         avatarSelectorStartIndex = mAvatarSelectorStartIndex + 1;
         handleScaledSlotIndex(-1);
      }
      
      private function scrollSkins(scrollAmount:int) : void
      {
         var _loc3_:GMHero = mDBFacade.gameMaster.heroById.itemFor(mHeroIds[mCurrentChosenIndex]);
         var _loc2_:Vector.<GMSkin> = this.getSkinsToDisplay(_loc3_);
         var _loc4_:uint = mSkinStartIndex + scrollAmount;
         if(_loc4_ >= 0 && _loc4_ + mSkinVector.length <= _loc2_.length)
         {
            mSkinStartIndex = _loc4_;
            setUpSkinSelector();
         }
      }
      
      private function handleScaledSlotIndex(count:int) : void
      {
         mScaledSlotIndex += count;
         if(mScaledSlotIndex < 0)
         {
            mScaledSlotIndex = 0;
            populateAvatarInfo(0);
         }
         if(mScaledSlotIndex >= mHeroSlots.length)
         {
            mScaledSlotIndex = mHeroSlots.length - 1;
            populateAvatarInfo(mScaledSlotIndex);
         }
         resizeHeroSlots(mScaledSlotIndex);
      }
      
      private function populateAvatarInfo(index:int) : void
      {
         resizeHeroSlots(index);
         index += mAvatarSelectorStartIndex;
         if(index >= mHeroIds.length)
         {
            return;
         }
         var _loc3_:GMHero = mDBFacade.gameMaster.heroById.itemFor(mHeroIds[index]);
         chooseThisHero(_loc3_.Id,index - mAvatarSelectorStartIndex);
         mTavernInfoClip.avatar_name_text.text = GameMasterLocale.getGameMasterSubString("SKIN_NAME",_loc3_.Constant).toUpperCase();
         var _loc2_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc3_.Id);
         if(_loc2_ != null)
         {
            setXP(_loc2_.experience,_loc3_);
            mDBFacade.steamAchievementsManager.setHeroLevelStat(_loc2_.level,_loc2_.gmHero);
         }
         mXPParentObject.visible = _loc2_ != null;
         populateWeaponIcons(index);
         populateHeroStars(_loc3_);
         var _loc4_:GMSkin = determineSkinForHero(_loc3_);
         determineSkinSelectorStartIndex(_loc4_);
         skinSelected(_loc4_);
      }
      
      private function populateHeroStars(gmHero:GMHero) : void
      {
         var _loc2_:* = 0;
         _loc2_ = 0;
         while(_loc2_ < mAttackStars.length)
         {
            mAttackStars[_loc2_].visible = gmHero.AttackRating - 1 >= _loc2_;
            mDefenseStars[_loc2_].visible = gmHero.DefenseRating - 1 >= _loc2_;
            mSpeedStars[_loc2_].visible = gmHero.SpeedRating - 1 >= _loc2_;
            _loc2_++;
         }
      }
      
      private function setupSkin(gmSkin:GMSkin) : void
      {
         var playerOwnsSelectedSkin:Boolean;
         var avatarInfo:AvatarInfo;
         var playerOwnsAvatar:Boolean;
         var gmHero:GMHero;
         mSkinNotAvailableLabel.visible = false;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass(gmSkin.CardName);
            var _loc4_:MovieClip = new _loc3_();
            var _loc2_:MovieClipRenderController = new MovieClipRenderController(mDBFacade,_loc4_);
            _loc2_.play();
            if(mHeroPic.numChildren > 0)
            {
               mHeroPic.removeChildAt(0);
            }
            mHeroPic.addChildAt(_loc4_,0);
         });
         playerOwnsSelectedSkin = mDBFacade.dbAccountInfo.inventoryInfo.doesPlayerOwnSkin(gmSkin.Id);
         avatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mChosenAvatarID);
         playerOwnsAvatar = avatarInfo != null;
         if(playerOwnsAvatar)
         {
            setupBuyButtonWithSkin(gmSkin,true);
         }
         else
         {
            gmHero = mDBFacade.gameMaster.heroByConstant.itemFor(gmSkin.ForHero);
            if(gmHero.DefaultSkin == gmSkin.Constant)
            {
               setupBuyButtonForHero(gmHero);
            }
            else
            {
               setupBuyButtonWithSkin(gmSkin,false);
            }
         }
         mSkinNameLabel.text = GameMasterLocale.getGameMasterSubString("SKIN_NAME",gmSkin.Constant).toUpperCase();
         setUpSkinSelector();
      }
      
      private function setupBuyButtonWithSkin(gmSkin:GMSkin, ownsHero:Boolean) : void
      {
         var nowTime:Number;
         var offer:GMOffer;
         var comingSoonText:String;
         var timeRemaining:Number;
         var daysRemaining:Number;
         var hoursRemaining:Number;
         var saleOffer:GMOffer;
         var currentOffer:GMOffer;
         mBuyButtonCoin.visible = false;
         mBuyButtonCash.visible = false;
         mRecruitButton.visible = false;
         mSkinInfoClip.label_or.visible = false;
         mSkinNotAvailableLabel.visible = false;
         if(mDBFacade.dbAccountInfo.inventoryInfo.doesPlayerOwnSkin(gmSkin.Id))
         {
            mBuyButton.visible = false;
            mHeroRequiredForSkinPurchase.visible = false;
            return;
         }
         nowTime = GameClock.date.getTime();
         offer = mSkinOffers.itemFor(gmSkin.Id);
         if(offer)
         {
            if(offer.StartDate && offer.StartDate.getTime() >= nowTime)
            {
               mBuyButton.visible = false;
               mHeroRequiredForSkinPurchase.visible = false;
               mSkinNotAvailableLabel.visible = true;
               comingSoonText = Locale.getString("TAVERN_SKIN_COMING_SOON");
               timeRemaining = offer.StartDate.getTime() - nowTime;
               daysRemaining = timeRemaining / 86400000;
               if(daysRemaining > 1)
               {
                  comingSoonText += Math.ceil(daysRemaining).toString() + Locale.getString("SKIN_DAYS_LEFT");
               }
               else
               {
                  hoursRemaining = timeRemaining / 3600000;
                  if(hoursRemaining > 1)
                  {
                     comingSoonText += Math.floor(hoursRemaining).toString() + Locale.getString("SKIN_HOURS_LEFT");
                  }
                  else
                  {
                     comingSoonText += Math.floor(hoursRemaining).toString() + Locale.getString("SKIN_MINS_LEFT");
                  }
               }
               mSkinNotAvailableLabel.text = comingSoonText;
               return;
            }
            if(offer.EndDate && offer.EndDate.getTime() <= nowTime)
            {
               mBuyButton.visible = false;
               mHeroRequiredForSkinPurchase.visible = false;
               mSkinNotAvailableLabel.visible = true;
               mSkinNotAvailableLabel.text = Locale.getString("TAVERN_SKIN_SOLD_OUT");
               return;
            }
         }
         if(offer == null)
         {
            mBuyButton.visible = false;
            mHeroRequiredForSkinPurchase.visible = false;
            mSkinNotAvailableLabel.visible = true;
            mSkinNotAvailableLabel.text = Locale.getString("TAVERN_SKIN_NOT_AVAILABLE");
            return;
         }
         mBuyButton.visible = true;
         mBuyButton.enabled = true;
         mBuyButton.label.text = Locale.getString("SKIN_BUY_BUTTON_BUY_TEXT");
         saleOffer = offer.isOnSaleNow;
         currentOffer = saleOffer ? saleOffer : offer;
         mBuyButton.root.cost_text.visible = true;
         mBuyButton.root.cost_text.text = currentOffer.Price;
         mBuyButton.root.cash_icon.visible = currentOffer.CurrencyType == "PREMIUM";
         mBuyButton.root.coin_icon.visible = currentOffer.CurrencyType == "BASIC";
         mBuyButton.root.dlc_cash_icon.visible = currentOffer.CurrencyType == "DLC";
         mBuyButton.releaseCallback = function():void
         {
            buySkin(gmSkin.Id);
         };
         if(currentOffer.CurrencyType == "DLC")
         {
            mBuyButton.visible = true;
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            mSkinInfoClip.label_or.visible = false;
            mRecruitButton.visible = false;
            mBuyButton.root.cost_text.visible = false;
            mBuyButton.root.cash_icon.visible = currentOffer.CurrencyType == "PREMIUM";
            mBuyButton.root.coin_icon.visible = currentOffer.CurrencyType == "BASIC";
            mBuyButton.root.dlc_cash_icon.visible = currentOffer.CurrencyType == "DLC";
            mBuyButton.releaseCallback = function():void
            {
               mDBFacade.overlaySteamBasedOnAppId(offer.SteamAppId);
            };
         }
         if(ownsHero)
         {
            mBuyButton.enabled = true;
            mHeroRequiredForSkinPurchase.visible = false;
         }
         else
         {
            mBuyButton.enabled = false;
            mHeroRequiredForSkinPurchase.visible = true;
         }
         if(offer && offer.SaleStartDate && offer.SaleEndDate && offer.SaleStartDate.getTime() <= nowTime && offer.SaleEndDate.getTime() > nowTime)
         {
            mBuyButton.label.text = Locale.getString("TAVERN_SKIN_ON_SALE");
         }
      }
      
      private function setupBuyButtonForHero(gmHero:GMHero) : void
      {
         var offer:GMOffer;
         var saleOffer:GMOffer;
         var coinOffer:GMOffer;
         var coinSaleOffer:GMOffer;
         var currentOffer:GMOffer;
         var currentCoinOffer:GMOffer;
         mSkinNotAvailableLabel.visible = false;
         mBuyButton.visible = true;
         mBuyButton.enabled = true;
         mBuyButton.label.text = Locale.getString("TAVERN_BUY_HERO_BUTTON_TEXT");
         offer = mHeroOffers.itemFor(gmHero.Id);
         saleOffer = offer.isOnSaleNow;
         coinOffer = offer.CoinOffer;
         coinSaleOffer = coinOffer ? coinOffer.isOnSaleNow : null;
         currentOffer = saleOffer ? saleOffer : offer;
         currentCoinOffer = coinSaleOffer ? coinSaleOffer : coinOffer;
         mHeroRequiredForSkinPurchase.visible = false;
         if(gmHero.IsExclusive)
         {
            mRecruitButton.visible = true;
            mBuyButton.visible = false;
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            mSkinInfoClip.label_or.visible = false;
            return;
         }
         if(coinOffer)
         {
            mBuyButton.visible = false;
            mBuyButtonCoin.visible = true;
            mBuyButtonCash.visible = true;
            mSkinInfoClip.label_or.visible = true;
            mRecruitButton.visible = false;
            mBuyButtonCash.label.text = currentOffer.Price.toString();
            mBuyButtonCoin.label.text = currentCoinOffer.Price.toString();
            mBuyButtonCash.releaseCallback = function():void
            {
               buyThisHero(currentOffer,mCurrentChosenIndex);
            };
            mBuyButtonCoin.releaseCallback = function():void
            {
               buyThisHero(currentCoinOffer,mCurrentChosenIndex);
            };
         }
         else
         {
            mBuyButton.visible = true;
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            mSkinInfoClip.label_or.visible = false;
            mRecruitButton.visible = false;
            mBuyButton.root.cost_text.visible = true;
            mBuyButton.root.cost_text.text = currentOffer.Price.toString();
            mBuyButton.root.cash_icon.visible = currentOffer.CurrencyType == "PREMIUM";
            mBuyButton.root.coin_icon.visible = currentOffer.CurrencyType == "BASIC";
            mBuyButton.root.dlc_cash_icon.visible = currentOffer.CurrencyType == "DLC";
            mBuyButton.releaseCallback = function():void
            {
               buyThisHero(currentOffer,mCurrentChosenIndex);
            };
         }
      }
      
      private function determineSkinForHero(gmHero:GMHero) : GMSkin
      {
         var _loc3_:GMSkin = null;
         var _loc2_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(gmHero.Id);
         if(_loc2_ != null)
         {
            if(mHeroSelectionsToFlush.hasKey(gmHero.Id))
            {
               _loc3_ = mDBFacade.gameMaster.getSkinByType(mHeroSelectionsToFlush.itemFor(gmHero.Id));
            }
            else
            {
               _loc3_ = mDBFacade.gameMaster.getSkinByType(_loc2_.skinId);
            }
            if(_loc3_ == null)
            {
               Logger.warn("Unable to get gmSKin for skinId: " + _loc2_.skinId);
            }
         }
         if(_loc3_ == null)
         {
            _loc3_ = mDBFacade.dbAccountInfo.inventoryInfo.getDefaultSkinForHero(gmHero);
         }
         return _loc3_;
      }
      
      private function determineSkinSelectorStartIndex(gmSkin:GMSkin) : void
      {
         var _loc4_:* = 0;
         var _loc3_:GMHero = mDBFacade.gameMaster.heroById.itemFor(mHeroIds[mCurrentChosenIndex]);
         var _loc2_:Vector.<GMSkin> = this.getSkinsToDisplay(_loc3_);
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            if(_loc2_[_loc4_].Id == gmSkin.Id)
            {
               if(_loc4_ < mSkinVector.length)
               {
                  mSkinStartIndex = 0;
               }
               else
               {
                  mSkinStartIndex = _loc4_ - mSkinVector.length + 1;
               }
               return;
            }
            _loc4_++;
         }
         mSkinStartIndex = 0;
      }
      
      private function skinSelected(gmSkin:GMSkin) : void
      {
         mSelectedSkin = gmSkin;
         if(gmSkin != null)
         {
            mStoryInfoClip.avatar_description_text.text = GameMasterLocale.getGameMasterSubString("SKIN_DESCRIPTION",gmSkin.Constant);
            mStoryInfoClip.avatar_likes_text.text = GameMasterLocale.getGameMasterSubString("SKIN_LIKES",gmSkin.Constant).toUpperCase();
            mStoryInfoClip.avatar_dislikes_text.text = GameMasterLocale.getGameMasterSubString("SKIN_DISLIKES",gmSkin.Constant).toUpperCase();
            mStoryInfoClip.avatar_nickname_text.text = GameMasterLocale.getGameMasterSubString("SKIN_NICKNAME",gmSkin.Constant).toUpperCase();
         }
         var _loc4_:Boolean = mDBFacade.dbAccountInfo.inventoryInfo.doesPlayerOwnSkin(gmSkin.Id);
         var _loc3_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mChosenAvatarID);
         var _loc2_:Boolean = _loc3_ != null;
         if(_loc2_)
         {
            if(_loc4_)
            {
               if(mHeroSelectionsToFlush.hasKey(_loc3_.gmHero.Id))
               {
                  mHeroSelectionsToFlush.replaceFor(_loc3_.gmHero.Id,gmSkin.Id);
               }
               else
               {
                  mHeroSelectionsToFlush.add(_loc3_.gmHero.Id,gmSkin.Id);
               }
               mChosenSkin = gmSkin;
            }
         }
         else
         {
            mChosenSkin = null;
         }
         setupSkin(mSelectedSkin);
      }
      
      private function setHeroAndSkin() : void
      {
         var _loc4_:* = 0;
         var _loc3_:* = 0;
         var _loc2_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mAvatarIdToMakeActiveAvatar);
         if(_loc2_ == null)
         {
            Logger.error("Trying to set active avatar to an avatar the user does no own.");
            return;
         }
         if(mActiveAvatar.id != _loc2_.id)
         {
            changeActiveAvatarRPC(mAvatarIdToMakeActiveAvatar);
         }
         var _loc1_:IMapIterator = mHeroSelectionsToFlush.iterator() as IMapIterator;
         while(_loc1_.next())
         {
            _loc3_ = uint(_loc1_.key);
            _loc4_ = _loc1_.current as uint;
            setSkinOnAvatar(_loc3_,_loc4_);
         }
         mHeroSelectionsToFlush.clear();
      }
      
      private function setSkinOnAvatar(heroId:uint, skinId:uint) : void
      {
         var _loc4_:Boolean = false;
         var _loc3_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(heroId);
         if(_loc3_ != null)
         {
            _loc4_ = mDBFacade.dbAccountInfo.inventoryInfo.doesPlayerOwnSkin(skinId);
            if(!_loc4_)
            {
               Logger.error("Trying to set skin as active that the user does no own.");
               return;
            }
            if(_loc3_.skinId != skinId)
            {
               _loc3_.skinId = skinId;
               if(mActiveAvatar.id == _loc3_.id)
               {
                  mActiveAvatar.skinId = skinId;
               }
               _loc3_.RPC_updateAvatarSkin();
               mDBFacade.metrics.log("StyleSet",{
                  "heroType":heroId,
                  "styleType":skinId
               });
            }
         }
      }
      
      private function setUpSkinSelector() : void
      {
         var _loc3_:* = 0;
         var _loc2_:GMHero = mDBFacade.gameMaster.heroById.itemFor(mHeroIds[mCurrentChosenIndex]);
         var _loc1_:Vector.<GMSkin> = this.getSkinsToDisplay(_loc2_);
         _loc3_ = 0;
         while(_loc3_ < mSkinVector.length)
         {
            if(_loc1_.length > _loc3_ + mSkinStartIndex)
            {
               mSkinVector[_loc3_].selected = false;
               if(mSelectedSkin && mSelectedSkin.Id == _loc1_[_loc3_ + mSkinStartIndex].Id)
               {
                  mSkinVector[_loc3_].selected = true;
               }
               mSkinVector[_loc3_].chosen = false;
               if(mChosenSkin && mChosenSkin.Id == _loc1_[_loc3_ + mSkinStartIndex].Id)
               {
                  mSkinVector[_loc3_].chosen = true;
               }
               mSkinVector[_loc3_].gmSkin = _loc1_[_loc3_ + mSkinStartIndex];
               mSkinVector[_loc3_].visible = true;
            }
            else
            {
               mSkinVector[_loc3_].visible = false;
            }
            _loc3_++;
         }
         mScrollSkinsLeftButton.enabled = false;
         mScrollSkinsRightButton.enabled = false;
         if(_loc1_.length > mSkinVector.length)
         {
            if(mSkinStartIndex > 0)
            {
               mScrollSkinsLeftButton.enabled = true;
            }
            if(mSkinStartIndex + mSkinVector.length < _loc1_.length)
            {
               mScrollSkinsRightButton.enabled = true;
            }
         }
      }
      
      private function resizeHeroSlots(selectedIndex:uint) : void
      {
         var _loc2_:* = 0;
         mScaledSlotIndex = selectedIndex;
         _loc2_ = 0;
         while(_loc2_ < mHeroSlots.length)
         {
            if(_loc2_ == selectedIndex)
            {
               select(mHeroSlots[_loc2_].root);
            }
            else
            {
               deselect(mHeroSlots[_loc2_].root);
            }
            _loc2_++;
         }
      }
      
      public function select(root:MovieClip) : void
      {
         root.scaleX = 1.25;
         root.scaleY = 1.25;
      }
      
      public function deselect(root:MovieClip) : void
      {
         root.scaleX = 1;
         root.scaleY = 1;
      }
      
      private function setXP(xp:uint, gmHero:GMHero) : void
      {
         mXPBar.value = xp;
         var _loc5_:uint = gmHero.getLevelFromExp(xp);
         var _loc4_:uint = xp;
         var _loc3_:uint = uint(gmHero.getLevelIndex(xp));
         var _loc7_:uint = uint(_loc3_ > 0 ? gmHero.getExpFromIndex(_loc3_ - 1) : 0);
         var _loc6_:uint = gmHero.getExpFromIndex(_loc3_);
         mXPLevelText.text = _loc5_.toString();
         mXPBar.value = (_loc4_ - _loc7_) / (_loc6_ - _loc7_);
         mXPText.text = _loc4_.toString() + " / " + _loc6_.toString();
      }
      
      public function populateWeaponIcons(index:int) : void
      {
         var masterType:GMWeaponMastertype;
         var masterTypeString:String;
         var weaponIconIndex:uint;
         var weaponIconCallback:Function = function(param1:int, param2:GMWeaponMastertype):Function
         {
            var index:int = param1;
            var subType:GMWeaponMastertype = param2;
            if(subType.DontShowInTavern)
            {
               return null;
            }
            return function(param1:SwfAsset):void
            {
               var _loc5_:Class = param1.getClass(subType.Icon);
               var _loc4_:MovieClip = new _loc5_();
               var _loc6_:MovieClip = mWeaponIconsVector[index].root.bg_slot;
               var _loc3_:uint = _loc6_.width <= _loc6_.height ? _loc6_.width * (1 / _loc6_.scaleX) : _loc6_.height * (1 / _loc6_.scaleY);
               UIObject.scaleToFit(_loc4_,_loc3_);
               var _loc2_:MovieClip = mWeaponIconsVector[index].root.bg_slot.getChildByName("weaponIcon");
               if(mWeaponIconsVector[index].root.bg_slot.numChildren > 0 && _loc2_)
               {
                  mWeaponIconsVector[index].root.bg_slot.removeChild(_loc2_);
               }
               mWeaponIconsVector[index].visible = true;
               mWeaponIconsVector[index].root.bg_slot.addChild(_loc4_);
               _loc4_.name = "weaponIcon";
               mWeaponIconsVector[index].tooltip.title_label.text = GameMasterLocale.getGameMasterSubString("WEAPON_MASTERTYPE",subType.Constant).toUpperCase();
            };
         };
         var allowedWeaponSubTypes:Vector.<String> = mDBFacade.gameMaster.heroById.itemFor(mHeroIds[index]).getAllowedWeaponSubTypes();
         var masterTypeVector:Vector.<GMWeaponMastertype> = new Vector.<GMWeaponMastertype>();
         for each(masterTypeString in allowedWeaponSubTypes)
         {
            masterType = mDBFacade.gameMaster.weaponSubtypeByConstant.itemFor(masterTypeString);
            if(masterType != null)
            {
               if(!masterType.DontShowInTavern)
               {
                  masterTypeVector.push(masterType);
               }
            }
         }
         if(masterTypeVector.length == 3)
         {
            mWeaponIconsVector = mWeaponIcons3;
            mTavernInfoClip.character_info.weapons_3.visible = true;
            mTavernInfoClip.character_info.weapons_4.visible = false;
            mScrollSkinsRightButton.clearRightNavigation();
            mWeaponIcons3[0].clearLeftNavigation();
            mScrollSkinsRightButton.isToTheLeftOf(mWeaponIcons3[0]);
         }
         else if(masterTypeVector.length == 4)
         {
            mWeaponIconsVector = mWeaponIcons4;
            mTavernInfoClip.character_info.weapons_3.visible = false;
            mTavernInfoClip.character_info.weapons_4.visible = true;
            mScrollSkinsRightButton.clearRightNavigation();
            mWeaponIcons4[0].clearLeftNavigation();
            mScrollSkinsRightButton.isToTheLeftOf(mWeaponIcons4[0]);
         }
         else
         {
            Logger.warn("UITavern is not set up to deal with anything but 3 or 4 weaponSubTypes.");
            mWeaponIconsVector = mWeaponIcons3;
            mTavernInfoClip.character_info.weapons_3.visible = true;
            mTavernInfoClip.character_info.weapons_4.visible = false;
         }
         weaponIconIndex = 0;
         for each(masterType in masterTypeVector)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(masterType.UISwfFilepath),weaponIconCallback(weaponIconIndex,masterType));
            weaponIconIndex = weaponIconIndex + 1;
            if(weaponIconIndex == mWeaponIconsVector.length)
            {
               break;
            }
         }
      }
      
      public function processChosenAvatar() : void
      {
         setHeroAndSkin();
      }
      
      private function chooseThisHero(avatarID:uint, index:int) : void
      {
         var _loc4_:* = 0;
         var _loc3_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(avatarID);
         if(_loc3_ != null)
         {
            if(_loc3_ != null && mCurrentChosenIndex < mHeroSlots.length && mCurrentChosenIndex >= 0)
            {
               if(mHeroSlots[mCurrentChosenIndex].root.chosen)
               {
                  mHeroSlots[mCurrentChosenIndex].root.chosen.visible = false;
               }
            }
            _loc4_ = 0;
            while(_loc4_ < mHeroSlots.length)
            {
               if(mHeroSlots[_loc4_].root.chosen)
               {
                  mHeroSlots[_loc4_].root.chosen.visible = false;
               }
               _loc4_++;
            }
            mAvatarIdToMakeActiveAvatar = _loc3_.gmHero.Id;
            if(mHeroSlots[index].root.chosen)
            {
               mHeroSlots[index].root.chosen.visible = true;
            }
         }
         mCurrentChosenIndex = index;
         mChosenAvatarID = avatarID;
      }
      
      private function buyThisHero(offer:GMOffer, index:uint) : void
      {
         StoreServicesController.tryBuyOffer(mDBFacade,offer,function(param1:*):void
         {
            var _loc2_:uint = offer.Details[0].HeroId;
            DBFacebookBragFeedPost.buyHeroSuccess(mTownHeader,mDBFacade.gameMaster.heroById.itemFor(_loc2_),mDBFacade,mAssetLoadingComponent);
            populateAvatarInfo(index);
            populateAvatarSelector();
         });
      }
      
      private function buySkin(skinId:uint) : void
      {
         var offer:GMOffer = mSkinOffers.itemFor(skinId);
         var saleOffer:GMOffer = offer.isOnSaleNow;
         var currentOffer:GMOffer = saleOffer ? saleOffer : offer;
         StoreServicesController.tryBuyOffer(mDBFacade,currentOffer,function(param1:*):void
         {
            var _loc3_:GMSkin = mDBFacade.gameMaster.getSkinByType(skinId);
            DBFacebookBragFeedPost.buySkinSuccess(_loc3_,mDBFacade,mAssetLoadingComponent);
            var _loc2_:GMHero = mDBFacade.gameMaster.heroByConstant.itemFor(_loc3_.ForHero);
            if(_loc2_ == null)
            {
               Logger.error("Unable to find gmHero by constant: " + _loc3_.ForHero);
            }
            if(_loc2_ && mHeroSelectionsToFlush.hasKey(_loc2_.Id))
            {
               mHeroSelectionsToFlush.removeKey(_loc2_.Id);
            }
            populateAvatarInfo(mCurrentChosenIndex);
            populateAvatarSelector();
         });
      }
      
      public function set avatarSelectorStartIndex(value:int) : void
      {
         if(value == mAvatarSelectorStartIndex)
         {
            return;
         }
         mAvatarSelectorStartIndex = value;
         populateAvatarSelector();
         if(mSelectorRightScroll.visible && mAvatarSelectorStartIndex + mHeroSlots.length >= mHeroIds.length)
         {
            mSelectorRightScroll.visible = false;
         }
         else if(!mSelectorRightScroll.visible && mAvatarSelectorStartIndex + mHeroSlots.length < mHeroIds.length)
         {
            mSelectorRightScroll.visible = true;
         }
         if(mSelectorLeftScroll.visible && mAvatarSelectorStartIndex == 0)
         {
            mSelectorLeftScroll.visible = false;
         }
         else if(!mSelectorLeftScroll.visible && mAvatarSelectorStartIndex > 0)
         {
            mSelectorLeftScroll.visible = true;
         }
      }
      
      public function set currentChosenIndex(value:int) : void
      {
         mCurrentChosenIndex = value;
      }
      
      public function get avatarSelectorStartIndex() : int
      {
         return mAvatarSelectorStartIndex;
      }
      
      private function changeActiveAvatarRPC(heroId:uint) : void
      {
         mDBFacade.dbAccountInfo.changeActiveAvatarRPC(heroId);
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
            mLogicalWorkComponent = null;
         }
         mAssetLoadingComponent.destroy();
         _loc1_ = 0;
         while(_loc1_ < mHeroSlots.length)
         {
            if(mHeroSlots[_loc1_])
            {
               mHeroSlots[_loc1_].destroy();
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < mWeaponIcons3.length)
         {
            if(mWeaponIcons3[_loc1_])
            {
               mWeaponIcons3[_loc1_].destroy();
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < mWeaponIcons4.length)
         {
            if(mWeaponIcons4[_loc1_])
            {
               mWeaponIcons4[_loc1_].destroy();
            }
            _loc1_++;
         }
         if(mSelectorRightScroll)
         {
            mSelectorRightScroll.destroy();
         }
         if(mSelectorLeftScroll)
         {
            mSelectorLeftScroll.destroy();
         }
         if(mXPBar)
         {
            mXPBar.destroy();
         }
         if(mXPParentObject)
         {
            mXPParentObject.destroy();
         }
         mTavernInfoClip = null;
      }
      
      public function setupHeaderLinks() : void
      {
         mTownHeader.addCoinButton.isAbove(mSkinVector[0]);
         mTownHeader.addGemButton.isAbove(mSkinVector[1]);
         mTownHeader.closeButton.isAbove(mSkinVector[2]);
      }
      
      private function setupNavigationLinks() : void
      {
         mScrollSkinsLeftButton.isToTheLeftOf(mSkinVector[0]);
         mSkinVector[0].isToTheLeftOf(mSkinVector[1]);
         mSkinVector[1].isToTheLeftOf(mSkinVector[2]);
         mSkinVector[2].isToTheLeftOf(mScrollSkinsRightButton);
         mSkinVector[0].downNavigation = mBuyButton;
         mSkinVector[1].downNavigation = mBuyButton;
         mSkinVector[2].downNavigation = mBuyButton;
         mBuyButton.upNavigation = mSkinVector[0];
         mBuyButton.downNavigation = mHeroSlots[0];
         mHeroSlots[0].upNavigation = mBuyButton;
      }
      
      public function setupHeroSlotsNavigationLinks() : void
      {
         mHeroSlots[0].isToTheLeftOf(mHeroSlots[1]);
         mHeroSlots[1].isToTheLeftOf(mHeroSlots[2]);
         mHeroSlots[2].isToTheLeftOf(mHeroSlots[3]);
         mHeroSlots[3].isToTheLeftOf(mHeroSlots[4]);
         mHeroSlots[4].isToTheLeftOf(mHeroSlots[5]);
         mHeroSlots[5].isToTheLeftOf(mHeroSlots[6]);
         mHeroSlots[6].isToTheLeftOf(mHeroSlots[7]);
         mHeroSlots[1].upNavigation = mBuyButton;
         mHeroSlots[2].upNavigation = mBuyButton;
         mHeroSlots[3].upNavigation = mBuyButton;
         mHeroSlots[4].upNavigation = mBuyButton;
         mHeroSlots[5].upNavigation = mBuyButton;
         mHeroSlots[6].upNavigation = mBuyButton;
         mHeroSlots[7].upNavigation = mBuyButton;
      }
      
      public function resetHeaderLinks() : void
      {
         mScrollSkinsLeftButton.clearNavigationAndInteractions();
         mScrollSkinsRightButton.clearNavigationAndInteractions();
         mSkinVector[0].clearNavigationAndInteractions();
         mSkinVector[1].clearNavigationAndInteractions();
         mSkinVector[2].clearNavigationAndInteractions();
         mBuyButton.clearNavigationAndInteractions();
         mHeroSlots[0].clearNavigationAndInteractions();
         mHeroSlots[1].clearNavigationAndInteractions();
         mHeroSlots[2].clearNavigationAndInteractions();
         mHeroSlots[3].clearNavigationAndInteractions();
         mHeroSlots[4].clearNavigationAndInteractions();
         mHeroSlots[5].clearNavigationAndInteractions();
         mHeroSlots[6].clearNavigationAndInteractions();
         mHeroSlots[7].clearNavigationAndInteractions();
         mWeaponIcons3[0].clearNavigationAndInteractions();
         mWeaponIcons3[1].clearNavigationAndInteractions();
         mWeaponIcons3[2].clearNavigationAndInteractions();
         mWeaponIcons4[0].clearNavigationAndInteractions();
         mWeaponIcons4[1].clearNavigationAndInteractions();
         mWeaponIcons4[2].clearNavigationAndInteractions();
         mWeaponIcons4[3].clearNavigationAndInteractions();
      }
      
      public function setupUsableWeaponsMenuNavigations() : void
      {
         mWeaponIcons3[0].isToTheLeftOf(mWeaponIcons3[1]);
         mWeaponIcons3[1].isToTheLeftOf(mWeaponIcons3[2]);
         mWeaponIcons4[0].isToTheLeftOf(mWeaponIcons4[1]);
         mWeaponIcons4[1].isToTheLeftOf(mWeaponIcons4[2]);
         mWeaponIcons4[2].isToTheLeftOf(mWeaponIcons4[3]);
      }
      
      public function getDefaultMenuNavigationObject() : UIObject
      {
         return mSkinVector[0];
      }
   }
}

