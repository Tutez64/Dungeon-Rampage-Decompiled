package UI.Skills
{
   import Account.AvatarInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphManager;
   import Brain.UI.UIButton;
   import Brain.Utils.ColorMatrix;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.TextUtil;
   import Brain.jsonRPC.JSONRPCService;
   import Collections.Map;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMSkin;
   import Town.TownHeader;
   import UI.Popup.DBUIOneButtonPopup;
   import UI.Popup.DBUITwoButtonPopup;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class UISkills
   {
      
      private static const ASCEND_ERROR_NO_STORAGE_SPACE:int = -1605;
      
      private static const ASCEND_ERROR_REWARD_NO_STORAGE_SPACE:int = -1606;
      
      private var mDBFacade:DBFacade;
      
      private var mTownHeader:TownHeader;
      
      private var mRootMovieClip:MovieClip;
      
      private var mAscendButton:UIButton;
      
      private var mHeroPic:MovieClip;
      
      private var mLevelText:TextField;
      
      private var mHeroNameLabel:TextField;
      
      private var mAvatarSelector:MovieClip;
      
      private var mSelectorRightScroll:UIButton;
      
      private var mSelectorLeftScroll:UIButton;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mActiveAvatar:AvatarInfo;
      
      private var mAvatarIdToMakeActiveAvatar:uint;
      
      private var mCurrentChosenIndex:int;
      
      private var mChosenAvatarID:uint;
      
      private var mChosenAvatarIDFull:uint;
      
      private var mAvatarSelectorStartIndex:int = 0;
      
      private var mSelectedSkin:GMSkin;
      
      private var mChosenSkin:GMSkin;
      
      private var mHeroIds:Vector.<uint>;
      
      private var mHeroSelectionsToFlush:Map;
      
      private var mHeroOffers:Map;
      
      private var mScaledSlotIndex:int;
      
      private var mHeroSlots:Vector.<UIButton>;
      
      private var mIsActive:Boolean = false;
      
      private var mAscendRequestPending:Boolean = false;
      
      public function UISkills(dbFacade:DBFacade, root:MovieClip, townHeader:TownHeader)
      {
         super();
         mDBFacade = dbFacade;
         mRootMovieClip = root;
         mTownHeader = townHeader;
         mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mHeroSlots = new Vector.<UIButton>();
         mHeroSelectionsToFlush = new Map();
         mHeroOffers = new Map();
         mHeroIds = new Vector.<uint>();
         mAscendButton = new UIButton(mDBFacade,mRootMovieClip.ascend_circle.ascend_button);
         mAscendButton.releaseCallback = function():void
         {
            var _loc1_:DBUITwoButtonPopup = null;
            if(mAscendRequestPending)
            {
               return;
            }
            var _loc3_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mChosenAvatarID);
            var _loc4_:uint = uint(_loc3_ != null ? _loc3_.mAscensionLevel : 0);
            var _loc2_:uint = mDBFacade.gameMaster.maxAscensionCount;
            if(_loc2_ > 0 && _loc4_ >= _loc2_)
            {
               _loc1_ = new DBUITwoButtonPopup(mDBFacade,"ASCEND_CONFIRMATION_POPUP",Locale.getString("ASCEND_CONFIRMATION_POPUP_TITLE"),Locale.getString("ASCEND_CONFIRMATION_MAX_LEVEL_POPUP_BODY"),Locale.getString("NO"),null,Locale.getString("YES"),attemptAscend);
               MemoryTracker.track(_loc1_,"DBUITwoButtonPopup - created in UISkills ascend button");
            }
            else
            {
               _loc1_ = new DBUITwoButtonPopup(mDBFacade,"ASCEND_CONFIRMATION_POPUP",Locale.getString("ASCEND_CONFIRMATION_POPUP_TITLE"),Locale.getString("ASCEND_CONFIRMATION_POPUP_BODY"),Locale.getString("NO"),null,Locale.getString("YES"),attemptAscend);
               MemoryTracker.track(_loc1_,"DBUITwoButtonPopup - created in UISkills ascend button");
            }
         };
         Locale.setText(mAscendButton.label,"ASCEND_BUTTON");
         mHeroPic = mRootMovieClip.ascend_circle.avatar;
         mLevelText = mRootMovieClip.ascend_circle.level_text;
         mHeroNameLabel = mRootMovieClip.ascend_circle.hero_name_label;
         mChosenAvatarID = 0;
         loadHeroOffers();
         loadAvatarChoiceArray();
      }
      
      public function refresh(resetToActiveAvatar:Boolean = true) : void
      {
         var _loc3_:uint = 0;
         mActiveAvatar = mDBFacade.dbAccountInfo.activeAvatarInfo;
         var _loc2_:Boolean = mChosenAvatarID != 0 && mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mChosenAvatarID) != null;
         if(resetToActiveAvatar || !_loc2_)
         {
            _loc3_ = getActiveAvatarIndex();
            mCurrentChosenIndex = _loc3_;
         }
         else
         {
            _loc3_ = uint(mCurrentChosenIndex);
         }
         populateAvatarInfo(_loc3_);
         populateAvatarSelector();
      }
      
      public function setupHeaderLinks() : void
      {
         mTownHeader.closeButton.isAbove(mAscendButton);
      }
      
      public function activate() : void
      {
         mIsActive = true;
      }
      
      public function deactivate() : void
      {
         mIsActive = false;
      }
      
      public function processChosenAvatar() : void
      {
         var _loc1_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mAvatarIdToMakeActiveAvatar);
         if(_loc1_ == null)
         {
            Logger.error("Trying to set active avatar to an avatar the user does not own.");
            return;
         }
         if(mActiveAvatar == null || mActiveAvatar.id != _loc1_.id)
         {
            mDBFacade.dbAccountInfo.changeActiveAvatarRPC(mAvatarIdToMakeActiveAvatar);
         }
      }
      
      public function selectPreviousHero() : void
      {
         selectAdjacentHero(-1);
      }
      
      public function selectNextHero() : void
      {
         selectAdjacentHero(1);
      }
      
      private function loadAvatarChoiceArray() : void
      {
         var i:int;
         var makeCallbackFunc:Function;
         var keys:Array;
         var avatarStartIndex:uint;
         mAvatarSelector = mRootMovieClip.UI_town_tavern_avatar_selector;
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
      
      private function selectAdjacentHero(direction:int) : void
      {
         if(mHeroIds.length == 0)
         {
            return;
         }
         var _loc2_:int = mAvatarSelectorStartIndex + mCurrentChosenIndex;
         _loc2_ = (_loc2_ + direction + mHeroIds.length) % mHeroIds.length;
         if(_loc2_ < mAvatarSelectorStartIndex)
         {
            avatarSelectorStartIndex = _loc2_;
         }
         else if(_loc2_ >= mAvatarSelectorStartIndex + mHeroSlots.length)
         {
            avatarSelectorStartIndex = _loc2_ - mHeroSlots.length + 1;
         }
         populateAvatarInfo(_loc2_ - mAvatarSelectorStartIndex);
      }
      
      public function set currentChosenIndex(value:int) : void
      {
         mCurrentChosenIndex = value;
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
      
      private function populateAvatarInfo(index:int) : void
      {
         resizeHeroSlots(index);
         index += mAvatarSelectorStartIndex;
         if(index >= mHeroIds.length)
         {
            return;
         }
         var _loc2_:GMHero = mDBFacade.gameMaster.heroById.itemFor(mHeroIds[index]);
         chooseThisHero(_loc2_.Id,index - mAvatarSelectorStartIndex);
         TextUtil.setText(mHeroNameLabel,GameMasterLocale.getGameMasterSubString("SKIN_NAME",_loc2_.Constant).toUpperCase());
         var _loc3_:GMSkin = determineSkinForHero(_loc2_);
         skinSelected(_loc3_);
      }
      
      private function chooseThisHero(avatarID:uint, index:int) : void
      {
         var _loc4_:uint = 0;
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
            TextUtil.setText(mAscendButton.label,String(_loc3_.mNextAscensionGemCost));
            TextUtil.setText(mLevelText,String(_loc3_.mAscensionLevel));
            mChosenAvatarIDFull = _loc3_.id;
         }
         else
         {
            TextUtil.setText(mLevelText,"0");
         }
         setAscendButtonEnabled(_loc3_ != null && _loc3_.canAscend);
         mCurrentChosenIndex = index;
         mChosenAvatarID = avatarID;
      }
      
      private function setAscendButtonEnabled(value:Boolean) : void
      {
         mAscendButton.enabled = value;
         mAscendButton.root.filters = value ? [] : [SceneGraphManager.getGrayScaleSaturationFilter(5)];
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
      
      private function resizeHeroSlots(selectedIndex:uint) : void
      {
         var _loc2_:uint = 0;
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
            mHeroSlots[vectorIndex].root.xp_star.visible = false;
         }
         else
         {
            mHeroSlots[vectorIndex].root.xp_star.visible = true;
            TextUtil.setText(mHeroSlots[vectorIndex].root.xp_star.xp_text,String(avatarInfo.cloutLevel));
         }
         gmSkin = mDBFacade.dbAccountInfo.inventoryInfo.getDefaultSkinForHero(gmHero);
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
      
      private function attemptAscend() : void
      {
         var ascendingAvatar:AvatarInfo;
         var ascensionLevelReached:uint;
         var requestFunc:Function;
         if(mAscendRequestPending)
         {
            return;
         }
         mAscendRequestPending = true;
         ascendingAvatar = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mChosenAvatarID);
         ascensionLevelReached = ascendingAvatar != null ? ascendingAvatar.mAscensionLevel + 1 : 0;
         requestFunc = JSONRPCService.getFunction("ascendAvatar",mDBFacade.rpcRoot + "avatarrecord");
         requestFunc(mChosenAvatarIDFull,function(param1:*):void
         {
            mAscendRequestPending = false;
            Logger.log("AscendAvatar:" + param1);
            if(mIsActive)
            {
               showAscendSucceededPopup(ascensionLevelReached);
            }
            askForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            mAscendRequestPending = false;
            if(mIsActive)
            {
               showAscendFailedPopup(param1);
            }
         });
      }
      
      private function showAscendSucceededPopup(ascensionLevelReached:uint) : void
      {
         var _loc2_:DBUIOneButtonPopup = null;
         var _loc3_:uint = mDBFacade.gameMaster.maxAscensionCount;
         if(_loc3_ > 0 && ascensionLevelReached >= _loc3_)
         {
            _loc2_ = new DBUIOneButtonPopup(mDBFacade,"ASCEND_MAX_LEVEL_POPUP",Locale.getString("ASCEND_MAX_LEVEL_POPUP_TITLE"),Locale.getString("ASCEND_MAX_LEVEL_POPUP_BODY"),Locale.getString("OK"),null);
         }
         else
         {
            _loc2_ = new DBUIOneButtonPopup(mDBFacade,"ASCEND_CONGRATULATIONS_POPUP",Locale.getString("ASCEND_CONGRATULATIONS_POPUP_TITLE"),Locale.getString("ASCEND_CONGRATULATIONS_POPUP_BODY"),Locale.getString("OK"),null);
         }
      }
      
      private function showAscendFailedPopup(error:Error) : void
      {
         var _loc5_:String = null;
         var _loc4_:String = null;
         var _loc3_:String = null;
         switch(error.errorID - -1606)
         {
            case 0:
               _loc5_ = "ASCEND_REWARD_NO_STORAGE_SPACE_POPUP_TITLE";
               _loc4_ = "ASCEND_REWARD_NO_STORAGE_SPACE_POPUP_BODY";
               _loc3_ = "ASCEND_REWARD_NO_STORAGE_SPACE_POPUP";
               break;
            case 1:
               _loc5_ = "ASCEND_NO_STORAGE_SPACE_POPUP_TITLE";
               _loc4_ = "ASCEND_NO_STORAGE_SPACE_POPUP_BODY";
               _loc3_ = "ASCEND_NO_STORAGE_SPACE_POPUP";
               break;
            default:
               mDBFacade.errorPopup(Locale.getString("ASCEND_PROMPT_GENERAL_ERROR"),error.toString(),"ASCENSION_GENERAL_ERROR_POPUP");
               return;
         }
         var _loc2_:DBUIOneButtonPopup = new DBUIOneButtonPopup(mDBFacade,_loc3_,Locale.getString(_loc5_),Locale.getString(_loc4_),Locale.getString("OK"),null);
      }
      
      private function askForAccountDetailsRefresh() : void
      {
         var useAccountBoosterFunc:Function = JSONRPCService.getFunction("AskForAccountDetails",mDBFacade.rpcRoot + "webMagicWord");
         useAccountBoosterFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,mDBFacade.demographics,function(param1:*):void
         {
            Logger.log("Got new account details");
            mDBFacade.dbAccountInfo.parseResponse(param1);
            mDBFacade.steamAchievementsHelper.updateHeroProgressStats(mDBFacade.dbAccountInfo.inventoryInfo.avatars);
         },function(param1:Error):void
         {
            Logger.log("PhpTime: ERROR:" + param1.toString());
         });
      }
      
      private function determineSkinForHero(gmHero:GMHero) : GMSkin
      {
         return mDBFacade.dbAccountInfo.inventoryInfo.getDefaultSkinForHero(gmHero);
      }
      
      private function skinSelected(gmSkin:GMSkin) : void
      {
         mSelectedSkin = gmSkin;
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
      
      private function setupSkin(gmSkin:GMSkin) : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass(gmSkin.PortraitClassName);
            if(_loc2_ == null)
            {
               return;
            }
            var _loc3_:MovieClip = new MovieClip();
            _loc3_.addChild(new _loc2_());
            _loc3_.scaleX = _loc3_.scaleY = 0.45;
            if(mHeroPic.numChildren > 0)
            {
               mHeroPic.removeChildAt(0);
            }
            mHeroPic.addChildAt(_loc3_,0);
         });
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
      
      private function heroIdSort(id1:uint, id2:uint) : int
      {
         if(id1 < id2)
         {
            return -1;
         }
         return 1;
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
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
         if(mAscendButton)
         {
            mAscendButton.destroy();
         }
         if(mSelectorRightScroll)
         {
            mSelectorRightScroll.destroy();
         }
         if(mSelectorLeftScroll)
         {
            mSelectorLeftScroll.destroy();
         }
         mTownHeader = null;
      }
   }
}

