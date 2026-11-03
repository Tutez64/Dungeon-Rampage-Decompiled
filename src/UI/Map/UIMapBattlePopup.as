package UI.Map
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Render.MovieClipRenderController;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.UI.UIProgressBar;
   import Brain.Utils.TextUtil;
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
      
      private var mArrowCursorKey:uint = 0;
      
      private var mPopupNavigationLinkDelay:Task;
      
      private var mOwnsNavigationLayer:Boolean = false;
      
      public function UIMapBattlePopup(dbFacade:DBFacade, changeHeroReleaseCallback:Function, changeStatReleaseCallback:Function, changeShopReleaseCallback:Function, battleReleaseCallback:Function, titleText:String)
      {
         mBattleReleaseCallback = battleReleaseCallback;
         mChangeHeroReleaseCallback = changeHeroReleaseCallback;
         mChangeStatReleaseCallback = changeStatReleaseCallback;
         mChangeShopReleaseCallback = changeShopReleaseCallback;
         super(dbFacade,"",titleText,null,true,false);
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
         var currentXp:uint;
         var level:uint;
         var levelIndex:uint;
         var lastLevelExp:uint;
         var max:uint;
         var xpBar:UIProgressBar;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mPopup.visible = false;
         if(mPopup.text_activeBooster)
         {
            Locale.setText(mPopup.text_activeBooster,"WORLD_MAP_STATS");
         }
         if(mPopup.text_victorRewards)
         {
            Locale.setText(mPopup.text_victorRewards,"WORLD_MAP_VICTORY_REWARDS");
         }
         Locale.setText(mPopup.private_dungeon_label,"PRIVATE_DUNGEON_LABEL");
         Locale.setText(mPopup.population_label,"PLAYER_ACTIVITY_POPULATION");
         mPrivateButton = new UIButton(mDBFacade,mPopup.radio_button);
         mPrivateButton.releaseCallback = togglePrivate;
         mPrivateButton.selected = IsPrivate;
         activeHeroSkin = mDBFacade.gameMaster.getSkinByType(mDBFacade.dbAccountInfo.activeAvatarInfo.skinId);
         gmHero = mDBFacade.gameMaster.heroByConstant.itemFor(activeHeroSkin.ForHero);
         TextUtil.setText(mPopup.txt_avatar,GameMasterLocale.getGameMasterSubString("SKIN_NAME",gmHero.Constant).toUpperCase());
         mActiveHeroPortrait = mPopup.avatarContainer.avatar;
         currentXp = mDBFacade.dbAccountInfo.activeAvatarInfo.experience;
         level = gmHero.getLevelFromExp(currentXp,mDBFacade.dbAccountInfo.activeAvatarInfo.mAscensionLevel);
         levelIndex = uint(gmHero.getLevelIndex(currentXp,mDBFacade.dbAccountInfo.activeAvatarInfo.mAscensionLevel));
         lastLevelExp = uint(levelIndex > 0 ? gmHero.getExpFromIndex(levelIndex - 1) : 0);
         max = gmHero.getExpFromIndex(levelIndex);
         if(currentXp < max)
         {
            xpBar = new UIProgressBar(mFacade,mPopup.UI_XP.xp_bar);
            mPopup.UI_XP.xp_bar_delta.visible = false;
            TextUtil.setText(mPopup.UI_XP.xp_points,currentXp + "/" + max);
            xpBar.maximum = max;
            xpBar.minimum = lastLevelExp;
            xpBar.value = currentXp;
         }
         else
         {
            TextUtil.setText(mPopup.UI_XP.xp_points,currentXp.toString());
         }
         TextUtil.setText(mPopup.UI_XP.xp_level,String(level));
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(activeHeroSkin.PortraitName),function(param1:SwfAsset):void
         {
            var _loc5_:Class = param1.getClass(activeHeroSkin.BackgroundClassName);
            var _loc3_:Class = param1.getClass(activeHeroSkin.PortraitClassName);
            if(_loc5_ == null || _loc3_ == null)
            {
               return;
            }
            var _loc4_:MovieClip = new MovieClip();
            _loc4_.addChild(new _loc5_());
            _loc4_.addChild(new _loc3_());
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
            removeNavigationLayer();
            mChangeHeroReleaseCallback();
         };
         mChangeHeroButton.rollOverCursor = "POINT";
         Locale.setText(mChangeHeroButton.root.swap,"WORLD_MAP_CHANGE_HERO_BUTTON");
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
               removeNavigationLayer();
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
               removeNavigationLayer();
            };
            mCloseButton.rollOverCursor = "POINT";
         }
         if(mPopup.crewbonus)
         {
            mTeamBonusUI = new UIObject(mDBFacade,mPopup.crewbonus);
            Locale.setText(mTeamBonusUI.tooltip.title_label,"TEAM_BONUS_TOOLTIP_TITLE");
            Locale.setText(mTeamBonusUI.tooltip.description_label,"TEAM_BONUS_TOOLTIP_DESCRIPTION");
            Locale.setText(mTeamBonusUI.root.header_crew_bonus_txt1,"TEAM_BONUS_TITLE_CREW",null,0.82);
            Locale.setText(mTeamBonusUI.root.header_crew_bonus_txt2,"TEAM_BONUS_TITLE_BONUS",null,0.82);
            TextUtil.setText(mTeamBonusUI.root.header_crew_bonus_number,String(mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1),0.73);
            TextUtil.setText(mPopup.crewBonus_label,((mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1) * 5).toString() + Locale.getString("TEAM_BONUS_BATTLE_POPUP_TEXT"));
         }
         setDungeonDetails();
      }
      
      override protected function handleKeyDown(event:KeyboardEvent) : void
      {
      }
      
      private function pushArrowCursor() : void
      {
         if(mArrowCursorKey != 0)
         {
            return;
         }
         mArrowCursorKey = mDBFacade.mouseCursorManager.pushMouseCursor("ARROW");
      }
      
      private function popArrowCursor() : void
      {
         if(mArrowCursorKey == 0)
         {
            return;
         }
         mDBFacade.mouseCursorManager.popMouseCursor(mArrowCursorKey);
         mArrowCursorKey = 0;
      }
      
      private function pushNavigationLayer() : void
      {
         var depthBeforePush:uint;
         if(mOwnsNavigationLayer)
         {
            if(mDBFacade.menuNavigationController.getTopUILayer() == "UI_MAP_BATTLE_POPUP")
            {
               mDBFacade.menuNavigationController.setFocusedUiObject(mBattleButton);
            }
            return;
         }
         depthBeforePush = mDBFacade.menuNavigationController.layerDepth;
         mDBFacade.menuNavigationController.pushNewLayer("UI_MAP_BATTLE_POPUP",function():void
         {
            removeNavigationLayer();
            animatePopupOut();
         },mBattleButton,mBattleButton);
         mOwnsNavigationLayer = mDBFacade.menuNavigationController.layerDepth > depthBeforePush;
      }
      
      private function removeNavigationLayer() : void
      {
         if(!mOwnsNavigationLayer)
         {
            return;
         }
         mOwnsNavigationLayer = false;
         mDBFacade.menuNavigationController.removeLayer("UI_MAP_BATTLE_POPUP");
      }
      
      private function cancelNavigationLayerPush() : void
      {
         if(mPopupNavigationLinkDelay)
         {
            mPopupNavigationLinkDelay.destroy();
            mPopupNavigationLinkDelay = null;
         }
      }
      
      override public function destroy() : void
      {
         popArrowCursor();
         cancelNavigationLayerPush();
         removeNavigationLayer();
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
      }
      
      public function get battleButton() : UIButton
      {
         return mBattleButton;
      }
      
      public function setTitle(value:String) : void
      {
         if(mPopup && mPopup.title_label)
         {
            TextUtil.setText(mPopup.title_label,value);
         }
      }
      
      public function setDifficulty(value:String) : void
      {
         if(mPopup && mPopup.text_recommendedLevel)
         {
            TextUtil.setText(mPopup.text_recommendedLevel,value);
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
            TextUtil.setText(mPopup.dungeonXp_label,mCurrentDungeon.CompletionXPBonus.toString() + Locale.getString("WORLD_MAP_BONUS_XP"));
         }
         Locale.setText(mPopup.button_battle.battle_text.battle_text,"WORLD_MAP_UNLOCK");
         setTitle(GameMasterLocale.getGameMasterSubString("DUNGEON_NAME",mCurrentDungeon.Constant).toUpperCase());
         if(_loc4_.TotalFloors > 0 && mCurrentDungeon.NodeType != GMMapNode.BOSS_NODE_TYPE)
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
         TextUtil.setText(mPopup.activity_label,_loc1_);
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
         mDBFacade.mTween.killTweensOf(mPopup);
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mPopup,0.25,{
               "x":destX,
               "y":destY
            })],
            "align":"sequence"
         });
         isPopupActive = true;
         pushArrowCursor();
         cancelNavigationLayerPush();
         mPopupNavigationLinkDelay = mLogicalWorkComponent.doLater(0,function(param1:GameClock):void
         {
            mPopupNavigationLinkDelay = null;
            if(isPopupActive)
            {
               pushNavigationLayer();
            }
         });
         DBGlobal.highlightButton(mBattleButton);
      }
      
      public function animatePopupOut(keepCurtain:Boolean = false) : void
      {
         var destX:Number;
         var destY:Number;
         var startX:Number;
         var hidePopup:Function;
         cancelNavigationLayerPush();
         if(mPopup == null)
         {
            return;
         }
         isPopupActive = false;
         popArrowCursor();
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
         mDBFacade.mTween.killTweensOf(mPopup);
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mPopup,0.25,{
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

