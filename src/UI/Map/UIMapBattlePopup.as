package UI.Map
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Render.MovieClipRenderController;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.UI.UIProgressBar;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMColiseumTier;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMMapNode;
   import GameMasterDictionary.GMSkin;
   import UI.Popup.DBUIPopup;
   import com.greensock.TimelineMax;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   
   public class UIMapBattlePopup extends DBUIPopup
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      protected static const POPUP_CLASS_NAME:String = "battle_popup";
      
      protected static const POPUP_CLASS_NAME_CONSUMABLES:String = "battle_popup_consumables";
      
      private static var sPersistedPrivateToggle:Boolean = false;
      
      private static const DELAY_AMOUNT_FOR_TRANSITIONING_BACK_TO_MAP_MENU_FROM_TAVERN:uint = 0;
      
      private static const BATTLE_POPUP_POSITION:Point = new Point(250,0);
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mActiveStacks:Vector.<UIButton>;
      
      private var mActiveHeroPortrait:MovieClip;
      
      private var mMapNodeOpen:Boolean = false;
      
      protected var mCurrentDungeon:GMMapNode;
      
      private var mBattleButton:UIButton;
      
      private var mChangeHeroButton:UIButton;
      
      private var mChangeStatButton:UIButton;
      
      private var mChangeStatReleaseCallback:Function;
      
      private var mChangeHeroReleaseCallback:Function;
      
      private var mChangeShopReleaseCallback:Function;
      
      private var mBattleReleaseCallback:Function;
      
      private var mPrivateButton:UIButton;
      
      public var IsPrivate:Boolean = sPersistedPrivateToggle;
      
      private var mTeamBonusUI:UIObject;
      
      private var isPopupActive:Boolean;
      
      private var mPopupNavigationLinkDelay:Task;
      
      public function UIMapBattlePopup(dbFacade:DBFacade, changeHeroReleaseCallback:Function, changeStatReleaseCallback:Function, changeShopReleaseCallback:Function, battleReleaseCallback:Function, titleText:String)
      {
         mBattleReleaseCallback = battleReleaseCallback;
         mChangeHeroReleaseCallback = changeHeroReleaseCallback;
         mChangeStatReleaseCallback = changeStatReleaseCallback;
         mChangeShopReleaseCallback = changeShopReleaseCallback;
         super(dbFacade,titleText,null,true,false);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIMapBattlePopup");
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override protected function getClassName() : String
      {
         return "battle_popup_consumables";
      }
      
      private function togglePrivate() : void
      {
         IsPrivate = !IsPrivate;
         sPersistedPrivateToggle = IsPrivate;
         mPrivateButton.selected = IsPrivate;
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         var activeHeroSkin:GMSkin;
         var gmHero:GMHero;
         var currentXp:int;
         var level:uint;
         var levelIndex:uint;
         var lastLevelExp:uint;
         var max:uint;
         var xpBar:UIProgressBar;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mPopup.visible = false;
         if(mPopup.text_activeBooster)
         {
            mPopup.text_activeBooster.text = Locale.getString("WORLD_MAP_STATS");
         }
         if(mPopup.text_victorRewards)
         {
            mPopup.text_victorRewards.text = Locale.getString("WORLD_MAP_VICTORY_REWARDS");
         }
         mPopup.private_dungeon_label.text = Locale.getString("PRIVATE_DUNGEON_LABEL");
         mPopup.population_label.text = Locale.getString("PLAYER_ACTIVITY_POPULATION");
         mPrivateButton = new UIButton(mDBFacade,mPopup.radio_button);
         mPrivateButton.releaseCallback = togglePrivate;
         mPrivateButton.selected = IsPrivate;
         activeHeroSkin = mDBFacade.gameMaster.getSkinByType(mDBFacade.dbAccountInfo.activeAvatarInfo.skinId);
         gmHero = mDBFacade.gameMaster.heroByConstant.itemFor(activeHeroSkin.ForHero);
         mPopup.txt_avatar.text = GameMasterLocale.getGameMasterSubString("SKIN_NAME",gmHero.Constant).toUpperCase();
         mActiveHeroPortrait = mPopup.avatarContainer.avatar;
         currentXp = int(mDBFacade.dbAccountInfo.activeAvatarInfo.experience);
         level = gmHero.getLevelFromExp(currentXp);
         levelIndex = uint(gmHero.getLevelIndex(currentXp));
         lastLevelExp = uint(levelIndex > 0 ? gmHero.getExpFromIndex(levelIndex - 1) : 0);
         max = gmHero.getExpFromIndex(levelIndex);
         if(currentXp < max)
         {
            xpBar = new UIProgressBar(mFacade,mPopup.UI_XP.xp_bar);
            mPopup.UI_XP.xp_bar_delta.visible = false;
            mPopup.UI_XP.xp_points.text = currentXp + "/" + max;
            xpBar.maximum = max;
            xpBar.minimum = lastLevelExp;
            xpBar.value = currentXp;
         }
         else
         {
            mPopup.UI_XP.xp_points.text = currentXp.toString();
         }
         mPopup.UI_XP.xp_level.text = level;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(activeHeroSkin.PortraitName),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass(activeHeroSkin.CardName);
            if(_loc3_ == null)
            {
               return;
            }
            var _loc4_:MovieClip = new _loc3_();
            var _loc2_:MovieClipRenderController = new MovieClipRenderController(mDBFacade,_loc4_);
            _loc2_.play();
            if(mActiveHeroPortrait.numChildren > 0)
            {
               mActiveHeroPortrait.removeChildAt(0);
            }
            mActiveHeroPortrait.addChildAt(_loc4_,0);
         });
         mChangeHeroButton = new UIButton(mDBFacade,mPopup.button_swapAvatar);
         mChangeHeroButton.dontKillMyChildren = true;
         mChangeHeroButton.releaseCallback = function():void
         {
            mDBFacade.menuNavigationController.popLayer("UI_MAP_BATTLE_POPUP");
            mChangeHeroReleaseCallback();
         };
         mChangeHeroButton.rollOverCursor = "POINT";
         mChangeHeroButton.root.swap.text = Locale.getString("WORLD_MAP_CHANGE_HERO_BUTTON");
         mPopup.button_battle.battle_text.mouseChildren = false;
         mPopup.button_battle.battle_text.mouseEnabled = false;
         mBattleButton = new UIButton(mDBFacade,mPopup.button_battle);
         mBattleButton.dontKillMyChildren = true;
         if(mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id).length == 0)
         {
            mBattleButton.releaseCallback = function():void
            {
               mDBFacade.errorPopup("Warning","Cannot enter dungeon with no weapons equipped.","NO_WEAPONS_DUNGEON_ERROR_POPUP");
               mDBFacade.metrics.log("NoWeaponsEquippedWarning");
            };
         }
         else
         {
            mBattleButton.releaseCallback = function():void
            {
               mDBFacade.menuNavigationController.popLayer("UI_MAP_BATTLE_POPUP");
               mBattleReleaseCallback();
            };
         }
         mBattleButton.rollOverCursor = "POINT";
         if(mCloseButton)
         {
            mCloseButton.dontKillMyChildren = true;
            mCloseButton.releaseCallback = function():void
            {
               animatePopupOut();
               mDBFacade.menuNavigationController.popLayer("UI_MAP_BATTLE_POPUP");
            };
            mCloseButton.rollOverCursor = "POINT";
         }
         if(mPopup.crewbonus)
         {
            mTeamBonusUI = new UIObject(mDBFacade,mPopup.crewbonus);
            mTeamBonusUI.tooltip.title_label.text = Locale.getString("TEAM_BONUS_TOOLTIP_TITLE");
            mTeamBonusUI.tooltip.description_label.text = Locale.getString("TEAM_BONUS_TOOLTIP_DESCRIPTION");
            mTeamBonusUI.root.header_crew_bonus_txt1.text = Locale.getString("TEAM_BONUS_TITLE_CREW");
            mTeamBonusUI.root.header_crew_bonus_txt2.text = Locale.getString("TEAM_BONUS_TITLE_BONUS");
            mTeamBonusUI.root.header_crew_bonus_number.text = mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1;
            mPopup.crewBonus_label.text = ((mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1) * 5).toString() + Locale.getString("TEAM_BONUS_BATTLE_POPUP_TEXT");
         }
         setDungeonDetails();
         setupMenuNavigation();
      }
      
      override protected function handleKeyDown(event:KeyboardEvent) : void
      {
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(mTeamBonusUI)
         {
            mTeamBonusUI.destroy();
         }
         if(mBattleButton)
         {
            mBattleButton.destroy();
            mBattleButton = null;
         }
         if(mChangeHeroButton)
         {
            mChangeHeroButton.destroy();
            mChangeHeroButton = null;
         }
         if(mChangeStatButton)
         {
            mChangeStatButton.destroy();
            mChangeStatButton = null;
         }
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
            mLogicalWorkComponent = null;
         }
         if(mPopupNavigationLinkDelay)
         {
            mPopupNavigationLinkDelay.destroy();
            mPopupNavigationLinkDelay = null;
         }
      }
      
      public function get battleButton() : UIButton
      {
         return mBattleButton;
      }
      
      public function setTitle(value:String) : void
      {
         if(mPopup && mPopup.title_label)
         {
            mPopup.title_label.text = value;
         }
      }
      
      public function setDifficulty(value:String) : void
      {
         if(mPopup && mPopup.text_recommendedLevel)
         {
            mPopup.text_recommendedLevel.text = value;
         }
      }
      
      public function set mapNodeOpen(value:Boolean) : void
      {
         mMapNodeOpen = value;
      }
      
      public function set currentDungeon(value:GMMapNode) : void
      {
         mCurrentDungeon = value;
      }
      
      public function setDungeonDetails() : void
      {
         var _loc4_:GMColiseumTier = null;
         var _loc2_:String = null;
         if(mCurrentDungeon == null || mPopup == null)
         {
            return;
         }
         if(mDBFacade && mDBFacade.gameMaster && mDBFacade.gameMaster.coliseumTierByConstant)
         {
            _loc4_ = mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mCurrentDungeon.TierRank);
         }
         if(_loc4_ && mPopup.dungeonXp_label)
         {
            mPopup.dungeonXp_label.text = mCurrentDungeon.CompletionXPBonus.toString() + Locale.getString("WORLD_MAP_BONUS_XP");
         }
         mPopup.button_battle.battle_text.battle_text.text = Locale.getString("WORLD_MAP_UNLOCK");
         setTitle(GameMasterLocale.getGameMasterSubString("DUNGEON_NAME",mCurrentDungeon.Constant).toUpperCase());
         if(_loc4_.TotalFloors > 0 && mCurrentDungeon.NodeType != "BOSS")
         {
            _loc2_ = _loc4_.TotalFloors > 1 ? Locale.getString("FLOORS").toUpperCase() : Locale.getString("FLOOR").toUpperCase();
            if(_loc4_.TotalFloors >= 50)
            {
               setDifficulty("INFINITE " + _loc2_);
            }
            else
            {
               setDifficulty(_loc4_.TotalFloors.toString() + " " + _loc2_);
            }
         }
         else
         {
            setDifficulty(GameMasterLocale.getGameMasterSubString("DUNGEON_DIFFICULTY_NAME",mCurrentDungeon.Constant));
         }
         var _loc1_:String = mDBFacade.playerActivityCount.getActivityString(mCurrentDungeon.Id);
         mPopup.activity_label.text = _loc1_;
         var _loc3_:GlowFilter = mDBFacade.playerActivityCount.getPopulationGlow(_loc1_);
         if(_loc3_)
         {
            mPopup.activity_label.filters = [_loc3_];
         }
      }
      
      public function get keyCostClip() : MovieClip
      {
         if(mPopup)
         {
            return mPopup.basic_key_icon;
         }
         return null;
      }
      
      public function animatePopupIn() : void
      {
         var destX:Number;
         var destY:Number;
         if(mPopup == null)
         {
            return;
         }
         mPopup.visible = true;
         if(!mCurtainActive)
         {
            makeCurtain();
         }
         destX = BATTLE_POPUP_POSITION.x;
         destY = BATTLE_POPUP_POSITION.y;
         mPopup.x = 730;
         mPopup.y = destY;
         TweenMax.killTweensOf(mPopup);
         new TimelineMax({
            "tweens":[TweenMax.to(mPopup,0.25,{
               "x":destX,
               "y":destY
            })],
            "align":"sequence"
         });
         isPopupActive = true;
         if(mPopupNavigationLinkDelay)
         {
            mPopupNavigationLinkDelay.destroy();
         }
         mPopupNavigationLinkDelay = mLogicalWorkComponent.doLater(0,function(param1:GameClock):void
         {
            var gameclock:GameClock = param1;
            mDBFacade.menuNavigationController.pushNewLayer("UI_MAP_BATTLE_POPUP",function():void
            {
               mDBFacade.menuNavigationController.popLayer("UI_MAP_BATTLE_POPUP");
               animatePopupOut();
            },mBattleButton,mBattleButton);
         });
         DBGlobal.highlightButton(mBattleButton);
      }
      
      public function animatePopupOut(keepCurtain:Boolean = false) : void
      {
         var destX:Number;
         var destY:Number;
         var startX:Number;
         var hidePopup:Function;
         if(mPopup == null)
         {
            return;
         }
         isPopupActive = false;
         if(mCurtainActive && !keepCurtain)
         {
            removeCurtain();
         }
         destX = 1440;
         destY = BATTLE_POPUP_POSITION.y;
         startX = BATTLE_POPUP_POSITION.x;
         mPopup.x = startX;
         mPopup.y = destY;
         hidePopup = function():void
         {
            if(mPopup)
            {
               mPopup.visible = false;
            }
         };
         TweenMax.killTweensOf(mPopup);
         new TimelineMax({
            "tweens":[TweenMax.to(mPopup,0.25,{
               "x":destX,
               "y":destY,
               "onComplete":hidePopup
            })],
            "align":"sequence"
         });
         removeButtonFilters();
      }
      
      override protected function setupMenuNavigation() : void
      {
         mPrivateButton.isAbove(mBattleButton);
         mCloseButton.isAbove(mPrivateButton);
         mChangeHeroButton.isToTheLeftOf(mBattleButton);
         setButtonFilters();
      }
      
      public function setButtonFilters() : void
      {
         DBGlobal.highlightButton(mBattleButton);
         mBattleButton.upNavigationAdditionalInteraction = function():void
         {
            DBGlobal.highlightButton(mPrivateButton);
            DBGlobal.unHighlightButton(mBattleButton);
         };
         mPrivateButton.downNavigationAdditionalInteraction = function():void
         {
            DBGlobal.unHighlightButton(mPrivateButton);
            DBGlobal.highlightButton(mBattleButton);
         };
         mPrivateButton.upNavigationAdditionalInteraction = function():void
         {
            DBGlobal.unHighlightButton(mPrivateButton);
         };
         mBattleButton.leftNavigationAdditionalInteraction = function():void
         {
            DBGlobal.unHighlightButton(mBattleButton);
            DBGlobal.highlightButton(mChangeHeroButton);
         };
         mChangeHeroButton.rightNavigationAdditionalInteraction = function():void
         {
            DBGlobal.unHighlightButton(mChangeHeroButton);
            DBGlobal.highlightButton(mBattleButton);
         };
         mCloseButton.downNavigationAdditionalInteraction = function():void
         {
            DBGlobal.highlightButton(mPrivateButton);
         };
      }
      
      public function removeButtonFilters() : void
      {
         mBattleButton.setFocused(false);
         mPrivateButton.setFocused(false);
         mChangeHeroButton.setFocused(false);
         mCloseButton.setFocused(false);
      }
   }
}

