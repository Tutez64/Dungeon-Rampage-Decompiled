package UI.Hud
{
   import Account.BoosterInfo;
   import Account.CurrencyUpdatedAccountEvent;
   import Actor.Buffs.BuffGameObject;
   import Actor.Buffs.BuffHandler;
   import Actor.FloatingMessage;
   import Actor.Pets.PetPortraitUI;
   import Actor.Player.Input.DungeonBusterControlActivatedEvent;
   import Actor.Revealer;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.ImageAsset;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Event.EventListeners;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.Render.MovieClipRenderer;
   import Brain.Render.Tweens.TweenHandle;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.UI.UIProgressBar;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.TextUtil;
   import Brain.Utils.Timers;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Combat.Weapon.ConsumableWeaponGameObject;
   import Combat.Weapon.WeaponGameObject;
   import DBGlobals.DBGlobal;
   import DistributedObjects.HeroGameObjectOwner;
   import DistributedObjects.NPCGameObject;
   import Events.ActorInvulnerableEvent;
   import Events.BusterPointsEvent;
   import Events.ExperienceEvent;
   import Events.GameObjectEvent;
   import Events.HpEvent;
   import Events.ManaEvent;
   import Events.UIHudChangeEvent;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import Floor.DungeonModifierHelper;
   import GameMasterDictionary.GMAttack;
   import GameMasterDictionary.GMRarity;
   import GameMasterDictionary.GMSkin;
   import GameMasterDictionary.GMStackable;
   import GameMasterDictionary.GMWeaponAesthetic;
   import GameMasterDictionary.GMWeaponItem;
   import Input.KeyBindings.KeyBindings;
   import Settings.Model.SettingsModel;
   import Settings.SettingsPopup;
   import SteamInput.OnSteamInputButtonReleasedEvent;
   import UI.*;
   import UI.Hud.StarlingConverted.IGameHud;
   import UI.InfiniteIsland.II_UIExitDungeonPopUp;
   import UI.Inventory.UIWeaponTooltip;
   import UI.Popup.UILootLossPopup;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class UIHud implements IGameHud
   {
      
      private static const CONDENSEDHUD_BUFF_ICON_X_STARTPOS:int = 455;
      
      private static const CONDENSEDHUD_BUFF_ICON_Y_STARTPOS:int = 865;
      
      private static const CONDENSEDHUD_BUFF_ICON_X_DISPLACEMENT:int = 63;
      
      private static const OLDHUD_BUFF_ICON_X_STARTPOS:int = 424;
      
      private static const OLDHUD_BUFF_ICON_Y_STARTPOS:int = 980;
      
      private static const OLDHUD_BUFF_ICON_X_DISPLACEMENT:int = 63;
      
      private static const MAX_CHAT_CHARS:uint = 44;
      
      private static const TEAMLOOT_POS:int = -550;
      
      private static const TEAMLOOT_VISIBLE_TIME:Number = 2;
      
      private static const TEAMLOOT_TWEEN_TIME:Number = 0.5;
      
      public static const UI_HUD_SWF_PATH:String = "Resources/Art2D/UI/db_UI_HUD.swf";
      
      public static const UI_HUD_CHANGE_EVENT:String = "UI_HUD_CHANGE_EVENT";
      
      private static const PET_PORTRAIT_SPACING:uint = 69;
      
      private static const PET_PORTRAIT_YPOS:uint = 85;
      
      private static const PET_PORTRAIT_START_XPOS:uint = 20;
      
      private static const ORIGINAL_COOLDOWN_ANIM_PLAY_TIME:Number = 4.1;
      
      public static const COMMON_CHEST_ID:uint = 60001;
      
      public static const UNCOMMON_CHEST_ID:uint = 60002;
      
      public static const RARE_CHEST_ID:uint = 60003;
      
      public static const LEGENDARY_CHEST_ID:uint = 60004;
      
      public static const SMALL_ITEM_BOX_ID:uint = 60005;
      
      public static const ROYAL_ITEM_BOX_ID:uint = 60006;
      
      private static const BUSTER_PRESS_TEXT_CONTROLLER_OFFSET_X:Number = -5;
      
      private static const TEAM_DEFAULT:Vector3D = new Vector3D(45,150);
      
      private static const PROFILE_DEFAULT:Vector3D = new Vector3D(112,95);
      
      private static const COINS_DEFAULT:Vector3D = new Vector3D(813,57);
      
      private static const CASH_DEFAULT:Vector3D = new Vector3D(1032,57);
      
      private static const EXP_DEFAULT:Vector3D = new Vector3D(1584,78);
      
      private static const CROWD_DEFAULT:Vector3D = new Vector3D(1869,1041);
      
      private static const TEAM_CONDENSED:Vector3D = new Vector3D(45,150);
      
      private static const PROFILE_CONDENSED:Vector3D = new Vector3D(1550,980);
      
      private static const COINS_CONDENSED:Vector3D = new Vector3D(60,980);
      
      private static const CASH_CONDENSED:Vector3D = new Vector3D(53,1031);
      
      private static const EXP_CONDENSED:Vector3D = new Vector3D(54,915);
      
      private static const CROWD_CONDENSED:Vector3D = new Vector3D(1555,920);
      
      private static const CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS:Vector3D = new Vector3D(13,-50);
      
      private static const CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS:Point = new Point(25,25);
      
      private static const CONTROLLER_ICON_POSITION_FOR_CLOSE_BUTTON:Vector3D = new Vector3D(-5,-27);
      
      private static const CONTROLLER_GLYPH_SCALE_CLOSE_BUTTON:Point = new Point(25,25);
      
      private static const CONTROLLER_ICON_POSITION_FOR_CHAT_SEND_BUTTON:Vector3D = new Vector3D(32,-10);
      
      private static const CONTROLLER_ICON_POSITION_FOR_CHAT_LOG_BUTTON:Vector3D = new Vector3D(25,-10);
      
      private static const CONTROLLER_GLYPH_SCALE_CHAT_BUTTONS:Point = new Point(20,20);
      
      private static const CONTROLLER_ICON_POSITION_FOR_DUNGEON_BUSTER:Vector3D = new Vector3D(8,-8);
      
      private static const CONTROLLER_GLYPH_SCALE_DUNGEON_BUSTER:Point = new Point(25,25);
      
      private var mDBFacade:DBFacade;
      
      private var mHeroOwner:HeroGameObjectOwner;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mWantPets:Boolean = false;
      
      private var mAssetsLoaded:Boolean = false;
      
      private var mRoot:Sprite;
      
      private var mUIRoot:MovieClip;
      
      private var mProfileBox:MovieClip;
      
      private var mProfileBulgeTask:Task;
      
      private var mProfileRestScale:Number;
      
      private var mBuffDisplayTask:Task;
      
      private var mFloaterTextClass:Class;
      
      private var mHpBar:UIProgressBar;
      
      private var mHpText:TextField;
      
      private var mFlashingHpBar:UIProgressBar;
      
      private var mHealthFullClip:TextField;
      
      private var mManaFullClip:TextField;
      
      private var mManaBar:UIProgressBar;
      
      private var mManaText:TextField;
      
      private var mBusterBar:UIProgressBar;
      
      private var mBusterValue:uint;
      
      private var mBusterRoot:MovieClip;
      
      private var mBasicCurrency:uint;
      
      private var mPremiumCurrency:uint;
      
      private var mBasicCurrencyUI:UIObject;
      
      private var mPremiumCurrencyUI:UIObject;
      
      private var mBasicCurrencyText:TextField;
      
      private var mPremiumCurrencyText:TextField;
      
      private var mLevelText:TextField;
      
      private var mXpObject:UIObject;
      
      private var mXpBar:UIProgressBar;
      
      private var mXpText:TextField;
      
      private var mXpGotInitialUpdate:Boolean;
      
      private var mXpBulgeTask:Task;
      
      private var mXpRestScale:Number;
      
      private var mXpValue:uint;
      
      private var mTeamLootMC:MovieClipRenderController;
      
      private var mLootTween:TweenHandle;
      
      private var mLootTask:Task;
      
      private var mLootMouseArea:Sprite;
      
      private var mCloseButton:UIButton;
      
      private var mWeaponZButton:UIButton;
      
      private var mWeaponXButton:UIButton;
      
      private var mWeaponCButton:UIButton;
      
      private var mWeaponButtons:Vector.<UIButton>;
      
      private var mConsumable1Button:UIButton;
      
      private var mConsumable2Button:UIButton;
      
      private var mConsumableWeaponButtons:Vector.<UIButton>;
      
      private var mCooldowns:Vector.<MovieClipRenderer>;
      
      private var mConsumableCooldowns:Vector.<MovieClipRenderer>;
      
      private var mDungeonBusterButton:UIButton;
      
      private var mBusterLabel:TextField;
      
      private var mBusterLabelOver:TextField;
      
      private var mBusterGlowMc:MovieClipRenderController;
      
      private var mBusterPulseMc:MovieClipRenderController;
      
      private var mXPBonusText:TextField;
      
      private var mCoinBonusText:TextField;
      
      private var mSettingsPopup:SettingsPopup;
      
      private var mSettingsModel:SettingsModel;
      
      private var mStacksHud:UIStacksHud;
      
      private var mEventComponent:EventComponent;
      
      protected var mUITask:Task;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mSwfAsset:SwfAsset;
      
      protected var mOffScreenPlayerManager:UIOffScreenPlayerManager;
      
      private var mMaxBusterPoints:uint;
      
      private var mUIChatLog:UIChatLog;
      
      private var mHealthFullRevealer:Revealer;
      
      private var mManaFullRevealer:Revealer;
      
      private var mHealthFullFloater:FloatingMessage;
      
      private var mManaFullFloater:FloatingMessage;
      
      private var mPetPortraitRoot:MovieClip;
      
      private var mPetPortraitNoneRoot:MovieClip;
      
      private var mPetPortrait:PetPortraitUI;
      
      private var mPetCarriedAcrossRebuild:NPCGameObject;
      
      private var mFloorLabel:TextField;
      
      private var mDungeonModifer1:UIButton;
      
      private var mDungeonModifer2:UIButton;
      
      private var mDungeonModifer3:UIButton;
      
      private var mDungeonModifer4:UIButton;
      
      private var mTeamLootDestination:Vector3D;
      
      private var mProfileDestination:Vector3D;
      
      private var mCoinsDestination:Vector3D;
      
      private var mCashDestination:Vector3D;
      
      private var mExpDestination:Vector3D;
      
      private var mCrowdDestination:Vector3D;
      
      private var mBoosterTimer:Timer;
      
      private var mHudType:uint;
      
      private var mVerticalYClipping:Number;
      
      private var mBuffs:Vector.<BuffGameObject>;
      
      private var mBuffIconButtons:Vector.<UIButton>;
      
      private var mBuffCooldowns:Vector.<MovieClipRenderer>;
      
      private var mHudControllerIcons:Vector.<ControllerIconData>;
      
      private var mExternalControllerIcons:Vector.<ControllerIconData>;
      
      private var mBusterPressTextOriginals:Dictionary;
      
      private var mInitControllerIconsLater:Task;
      
      private var mControllerIconLoadDelay:int = 1;
      
      private var mLootLossPopup:UILootLossPopup;
      
      private var mInfiniteExitPopup:II_UIExitDungeonPopUp;
      
      private var mSuppressNextExitMenuToggle:Boolean;
      
      public function UIHud(facade:DBFacade)
      {
         var settingsModel:SettingsModel;
         mHudControllerIcons = new Vector.<ControllerIconData>();
         mExternalControllerIcons = new Vector.<ControllerIconData>();
         mBusterPressTextOriginals = new Dictionary(true);
         super();
         mDBFacade = facade;
         mRoot = new Sprite();
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIHud");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIHud");
         mMaxBusterPoints = 4294967295;
         settingsModel = mDBFacade.settingsModel;
         mStacksHud = new UIStacksHud(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mDBFacade.keyBindings.addChangeListener(onKeyBindingsChanged);
         mSettingsModel = settingsModel;
         mSettingsModel.addChangeListener(onSettingChanged);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_HUD.swf"),function(param1:SwfAsset):void
         {
            setupUI(param1,uint(settingsModel.getValue("hudStyle")));
         });
         mXpBulgeTask = null;
         mProfileBulgeTask = null;
         mBuffs = new Vector.<BuffGameObject>();
         mBuffIconButtons = new Vector.<UIButton>();
         mBuffCooldowns = new Vector.<MovieClipRenderer>();
      }
      
      private static function setButtonLabel(button:UIButton, text:String) : void
      {
         if(button == null || button.label == null)
         {
            return;
         }
         button.label.text = text;
      }
      
      private static function hideControllerIcon(iconData:ControllerIconData) : void
      {
         iconData.mIsHidden = true;
         if(iconData.mOwner != null && iconData.mControllerGlyph != null && iconData.mOwner.contains(iconData.mControllerGlyph))
         {
            iconData.mOwner.removeChild(iconData.mControllerGlyph);
         }
      }
      
      private static function hideControllerIcons(icons:Vector.<ControllerIconData>) : void
      {
         for each(var _loc2_:ControllerIconData in icons)
         {
            hideControllerIcon(_loc2_);
         }
      }
      
      private static function unloadControllerIcons(icons:Vector.<ControllerIconData>) : void
      {
         for each(var _loc2_:ControllerIconData in icons)
         {
            hideControllerIcon(_loc2_);
            _loc2_.destroy();
         }
         icons.length = 0;
      }
      
      public static function isThisAConsumbleChestId(chestId:int) : Boolean
      {
         return chestId == 60005 || chestId == 60006;
      }
      
      private function switchHudEvent(event:UIHudChangeEvent) : void
      {
         this.setupUI(mSwfAsset,event.hudType);
         resetBuffButtonPositions();
         if(mAssetsLoaded && mHeroOwner != null)
         {
            setupStatsForResourceBars();
         }
      }
      
      public function get chatLogContainer() : MovieClip
      {
         return mUIRoot.chatLogContainer;
      }
      
      public function offScreenPicChange(playerId:int, picType:String) : void
      {
         if(mOffScreenPlayerManager)
         {
            mOffScreenPlayerManager.handlePicChange(playerId,picType);
         }
      }
      
      public function get ownedHero() : HeroGameObjectOwner
      {
         return mHeroOwner;
      }
      
      public function get swfAsset() : SwfAsset
      {
         return mSwfAsset;
      }
      
      private function setDooberLocations(hudType:uint) : void
      {
         switch(int(hudType))
         {
            case 0:
               mTeamLootDestination = TEAM_DEFAULT;
               mProfileDestination = PROFILE_DEFAULT;
               mCoinsDestination = COINS_DEFAULT;
               mCashDestination = CASH_DEFAULT;
               mExpDestination = EXP_DEFAULT;
               mCrowdDestination = CROWD_DEFAULT;
               break;
            case 1:
               mTeamLootDestination = TEAM_CONDENSED;
               mProfileDestination = PROFILE_CONDENSED;
               mCoinsDestination = COINS_CONDENSED;
               mCashDestination = CASH_CONDENSED;
               mExpDestination = EXP_CONDENSED;
               mCrowdDestination = CROWD_CONDENSED;
               break;
            default:
               mTeamLootDestination = TEAM_DEFAULT;
               mProfileDestination = PROFILE_DEFAULT;
               mCoinsDestination = COINS_DEFAULT;
               mCashDestination = CASH_DEFAULT;
               mExpDestination = EXP_DEFAULT;
               mCrowdDestination = CROWD_DEFAULT;
         }
      }
      
      private function setupUI(swfAsset:SwfAsset, hudType:uint = 0) : void
      {
         var cooldownIndex:int;
         var hudClassName:String;
         var hudClass:Class;
         var i:uint;
         var tooltipOffsset:Point;
         mHudType = hudType;
         if(mUIRoot && mRoot.contains(mUIRoot))
         {
            mRoot.removeChild(mUIRoot);
         }
         mPetCarriedAcrossRebuild = mPetPortrait ? mPetPortrait.petNPCGameObject : null;
         if(mHpBar)
         {
            mHpBar.destroy();
         }
         mHpBar = null;
         if(mFlashingHpBar)
         {
            mFlashingHpBar.destroy();
         }
         mFlashingHpBar = null;
         if(mManaBar)
         {
            mManaBar.destroy();
         }
         mManaBar = null;
         if(mBusterBar)
         {
            mBusterBar.destroy();
         }
         mBusterBar = null;
         if(mXpBar)
         {
            mXpBar.destroy();
         }
         mXpBar = null;
         if(mPetPortrait)
         {
            mPetPortrait.destroy();
         }
         mPetPortrait = null;
         if(mBasicCurrencyUI)
         {
            mBasicCurrencyUI.destroy();
         }
         mBasicCurrencyUI = null;
         if(mPremiumCurrencyUI)
         {
            mPremiumCurrencyUI.destroy();
         }
         mPremiumCurrencyUI = null;
         if(mXpObject)
         {
            mXpObject.destroy();
         }
         mXpObject = null;
         if(mCloseButton)
         {
            mCloseButton.destroy();
         }
         mCloseButton = null;
         if(mWeaponZButton)
         {
            mWeaponZButton.destroy();
         }
         mWeaponZButton = null;
         if(mWeaponXButton)
         {
            mWeaponXButton.destroy();
         }
         mWeaponXButton = null;
         if(mWeaponCButton)
         {
            mWeaponCButton.destroy();
         }
         mWeaponCButton = null;
         mWeaponButtons = null;
         if(mConsumable1Button)
         {
            mConsumable1Button.destroy();
         }
         mConsumable1Button = null;
         if(mConsumable2Button)
         {
            mConsumable2Button.destroy();
         }
         mConsumable2Button = null;
         mConsumableWeaponButtons = null;
         if(mDungeonModifer1)
         {
            mDungeonModifer1.destroy();
         }
         mDungeonModifer1 = null;
         if(mDungeonModifer2)
         {
            mDungeonModifer2.destroy();
         }
         mDungeonModifer2 = null;
         if(mDungeonModifer3)
         {
            mDungeonModifer3.destroy();
         }
         mDungeonModifer3 = null;
         if(mDungeonModifer4)
         {
            mDungeonModifer4.destroy();
         }
         mDungeonModifer4 = null;
         if(mCooldowns)
         {
            cooldownIndex = 0;
            while(cooldownIndex < mCooldowns.length)
            {
               if(mCooldowns[cooldownIndex])
               {
                  mCooldowns[cooldownIndex].destroy();
               }
               cooldownIndex = cooldownIndex + 1;
            }
            mCooldowns = null;
         }
         if(mConsumableCooldowns)
         {
            cooldownIndex = 0;
            while(cooldownIndex < mConsumableCooldowns.length)
            {
               if(mConsumableCooldowns[cooldownIndex])
               {
                  mConsumableCooldowns[cooldownIndex].destroy();
               }
               cooldownIndex = cooldownIndex + 1;
            }
            mConsumableCooldowns = null;
         }
         if(mInitControllerIconsLater)
         {
            mInitControllerIconsLater.destroy();
         }
         mInitControllerIconsLater = null;
         destroyTeamLoot();
         mSwfAsset = swfAsset;
         switch(int(hudType))
         {
            case 0:
               hudClassName = "ui_hud_old";
               mDBFacade.camera.offset = new Point(0,45);
               mVerticalYClipping = 0;
               break;
            case 1:
               hudClassName = "ui_hud";
               mDBFacade.camera.offset = new Point(0,0);
               mVerticalYClipping = 90;
               break;
            default:
               hudClassName = "ui_hud_old";
               mDBFacade.camera.offset = new Point(0,45);
               mVerticalYClipping = 0;
               Logger.warn("Unable to determine hud with type: " + hudType);
         }
         setDooberLocations(mHudType);
         mDBFacade.camera.yCilppingFromBottom = mVerticalYClipping;
         mDBFacade.camera.forceRedraw();
         hudClass = swfAsset.getClass(hudClassName);
         mUIRoot = new hudClass();
         mRoot.addChild(mUIRoot);
         mFloaterTextClass = swfAsset.getClass("floater_text");
         mStacksHud.initializeHud(swfAsset.getClass("stacks_hud"));
         if(mUIChatLog)
         {
            mUIChatLog.destroy();
         }
         mUIChatLog = new UIChatLog(mDBFacade,mUIRoot.chatLogContainer,mUIRoot.UI_chat,mUIRoot.UI_chat.log_btn,mUIRoot.UI_chat.chat_btn);
         if(mHudType != 1)
         {
            mUIChatLog.textSizeModifier = 1.18;
         }
         mCloseButton = new UIButton(mDBFacade,mUIRoot.close);
         mCloseButton.releaseCallback = function():void
         {
            closeButtonReleaseCallback();
         };
         if(mDBFacade.dbConfigManager.getConfigBoolean("want_pets",true))
         {
            mWantPets = true;
         }
         mProfileBox = mUIRoot.UI_profile;
         mProfileRestScale = mProfileBox.scaleX;
         mHpBar = new UIProgressBar(mDBFacade,mUIRoot.UI_profile.HP_bar,mUIRoot.UI_profile.HP_bar_delta);
         mHpText = mUIRoot.UI_profile.HP_text;
         mHpText.visible = false;
         mFlashingHpBar = new UIProgressBar(mDBFacade,mUIRoot.UI_profile.HP_bar_invincible);
         mFlashingHpBar.visible = false;
         mFlashingHpBar.root.mouseEnabled = false;
         mManaBar = new UIProgressBar(mDBFacade,mUIRoot.UI_profile.mana_bar,mUIRoot.UI_profile.mana_bar_delta);
         mManaText = mUIRoot.UI_profile.mana_text;
         mManaText.visible = false;
         mHealthFullClip = mUIRoot.UI_profile.HP_full_text;
         mManaFullClip = mUIRoot.UI_profile.mana_full_text;
         mHealthFullClip.mouseEnabled = false;
         mManaFullClip.mouseEnabled = false;
         mHealthFullClip.visible = false;
         mManaFullClip.visible = false;
         mBusterRoot = mUIRoot.UI_buster;
         mBusterBar = new UIProgressBar(mDBFacade,mUIRoot.UI_buster.buster_bar);
         hideBustSign();
         mBasicCurrencyUI = new UIObject(mDBFacade,mUIRoot.UI_currency_coin);
         mBasicCurrencyUI.setRootMovieClipAsBitMap();
         mPremiumCurrencyUI = new UIObject(mDBFacade,mUIRoot.UI_currency_cash);
         mPremiumCurrencyUI.setRootMovieClipAsBitMap();
         mBasicCurrencyText = mUIRoot.UI_currency_coin.game_currency_text;
         mBasicCurrencyText.mouseEnabled = false;
         mPremiumCurrencyText = mUIRoot.UI_currency_cash.cash_text;
         mPremiumCurrencyText.mouseEnabled = false;
         if(mDBFacade.dbAccountInfo)
         {
            setCurrency(mDBFacade.dbAccountInfo.basicCurrency,mDBFacade.dbAccountInfo.premiumCurrency);
         }
         mLevelText = mUIRoot.UI_XP.xp_level;
         mXpObject = new UIObject(mDBFacade,mUIRoot.UI_XP);
         mXpRestScale = mXpObject.root.scaleX;
         mXpBar = new UIProgressBar(mDBFacade,mUIRoot.UI_XP.xp_bar,mUIRoot.UI_XP.xp_bar_delta);
         mUIRoot.UI_XP.xp_bar_delta.alpha = 0.3;
         mXpText = mUIRoot.UI_XP.xp_points;
         mXpText.visible = false;
         mUIRoot.UI_XP.xp_level_title.visible = false;
         mXPBonusText = mUIRoot.UI_XP.doublexp_text;
         mCoinBonusText = mUIRoot.UI_currency_coin.doublecoin_text;
         mCoinBonusText.visible = false;
         mWeaponZButton = new UIButton(mDBFacade,mUIRoot.UI_weapons.weapon_z);
         mWeaponXButton = new UIButton(mDBFacade,mUIRoot.UI_weapons.weapon_x);
         mWeaponCButton = new UIButton(mDBFacade,mUIRoot.UI_weapons.weapon_c);
         mWeaponButtons = new <UIButton>[mWeaponZButton,mWeaponXButton,mWeaponCButton];
         if(!mDBFacade.featureFlags.getFlagValue("want-dynamic-rarity-backgrounds"))
         {
            mWeaponZButton.setRootMovieClipAsBitMap();
            mWeaponXButton.setRootMovieClipAsBitMap();
            mWeaponCButton.setRootMovieClipAsBitMap();
         }
         i = 0;
         while(i < mWeaponButtons.length)
         {
            this.createWeaponTooltip(mWeaponButtons[i],i);
            i = i + 1;
         }
         mCooldowns = new Vector.<MovieClipRenderer>();
         mCooldowns.push(new MovieClipRenderer(mDBFacade,mUIRoot.UI_weapons.weapon_z.cooldown));
         mUIRoot.UI_weapons.weapon_z.cooldown.visible = false;
         mCooldowns.push(new MovieClipRenderer(mDBFacade,mUIRoot.UI_weapons.weapon_x.cooldown));
         mUIRoot.UI_weapons.weapon_x.cooldown.visible = false;
         mCooldowns.push(new MovieClipRenderer(mDBFacade,mUIRoot.UI_weapons.weapon_c.cooldown));
         mUIRoot.UI_weapons.weapon_c.cooldown.visible = false;
         mConsumable1Button = new UIButton(mDBFacade,mUIRoot.consumables_01);
         mConsumable2Button = new UIButton(mDBFacade,mUIRoot.consumables_02);
         mConsumableWeaponButtons = new <UIButton>[mConsumable1Button,mConsumable2Button];
         mConsumable1Button.setRootMovieClipAsBitMap();
         mConsumable2Button.setRootMovieClipAsBitMap();
         refreshKeyboardLabels();
         mConsumableCooldowns = new Vector.<MovieClipRenderer>();
         mConsumableCooldowns.push(new MovieClipRenderer(mDBFacade,mUIRoot.consumables_01.cooldown));
         mUIRoot.consumables_01.cooldown.visible = false;
         mConsumableCooldowns.push(new MovieClipRenderer(mDBFacade,mUIRoot.consumables_02.cooldown));
         mUIRoot.consumables_02.cooldown.visible = false;
         mUIRoot.UI_center_message.visible = false;
         mPetPortraitRoot = mUIRoot.pet;
         if(mUIRoot.pet_none)
         {
            mPetPortraitNoneRoot = mUIRoot.pet_none;
         }
         mAssetsLoaded = true;
         mFloorLabel = mUIRoot.label_floor;
         mFloorLabel.cacheAsBitmap = true;
         tooltipOffsset = new Point(0,-15);
         mDungeonModifer1 = new UIButton(mDBFacade,mUIRoot.floor_modifier01);
         mDungeonModifer1.tooltip = mUIRoot.tooltip_modifier01;
         mDungeonModifer1.tooltipPos = tooltipOffsset;
         mDungeonModifer2 = new UIButton(mDBFacade,mUIRoot.floor_modifier02);
         mDungeonModifer2.tooltip = mUIRoot.tooltip_modifier02;
         mDungeonModifer2.tooltipPos = tooltipOffsset;
         mDungeonModifer3 = new UIButton(mDBFacade,mUIRoot.floor_modifier03);
         mDungeonModifer3.tooltip = mUIRoot.tooltip_modifier03;
         mDungeonModifer3.tooltipPos = tooltipOffsset;
         mDungeonModifer4 = new UIButton(mDBFacade,mUIRoot.floor_modifier04);
         mDungeonModifer4.tooltip = mUIRoot.tooltip_modifier04;
         mDungeonModifer4.tooltipPos = tooltipOffsset;
         if(mDBFacade.steamInputManager.wantsControllerPrompts)
         {
            setAllKeyboardIconsVisibility(false);
         }
         if(mDBFacade.steamInputManager.isSteamInputReady)
         {
            mInitControllerIconsLater = mLogicalWorkComponent.doLater(mControllerIconLoadDelay,initAllControllerIconsTask);
         }
         if(mHeroOwner)
         {
            this.initializeHud(mHeroOwner);
         }
      }
      
      private function closeButtonReleaseCallback() : void
      {
         var xpLoss:uint;
         var closeCallback:Function = function():void
         {
            var _loc1_:Object = {};
            _loc1_.buttonDesc = "UIHud Exit Button Clicked";
            _loc1_.areaType = "Dungeon";
            mDBFacade.metrics.log("ButtonClick",_loc1_);
            mUIChatLog.hideChatLog();
            mInfiniteExitPopup = null;
            mLootLossPopup = null;
            mDBFacade.mDistributedObjectManager.mMatchMaker.RequestExit();
            mDBFacade.dbAccountInfo.dbAccountParams.flushParams();
         };
         if(mHeroOwner.distributedDungeonFloor.isInfiniteDungeon)
         {
            if(mInfiniteExitPopup == null)
            {
               mInfiniteExitPopup = new II_UIExitDungeonPopUp(mDBFacade,closeCallback,null,openSettingsPopup);
               MemoryTracker.track(mInfiniteExitPopup,"II_UIExitDungeonPopup - created in UIHud.setupUI()");
            }
            else
            {
               mInfiniteExitPopup.destroy();
               mInfiniteExitPopup = null;
            }
         }
         else if(mLootLossPopup == null)
         {
            xpLoss = mHeroOwner.distributedDungeonFloor.completionXp;
            mLootLossPopup = new UILootLossPopup(mDBFacade,xpLoss,mHeroOwner.distributedDungeonFloor.treasureCollected,closeCallback,null,openSettingsPopup);
            MemoryTracker.track(mLootLossPopup,"UILootLossPopup - created in UIHud.setupUI()");
         }
         else
         {
            mLootLossPopup.destroy();
            mLootLossPopup = null;
         }
      }
      
      private function initAllControllerIconsTask(inClock:GameClock) : void
      {
         mInitControllerIconsLater = null;
         initAllControllerIcons();
      }
      
      private function initAllControllerIcons() : void
      {
         if(!mDBFacade.steamInputManager.isSteamInputReady)
         {
            Logger.warn("Attempted to display Controller Icons but no controllers are connected. Aborting.");
            return;
         }
         unloadControllerIcons(mHudControllerIcons);
         initControllerIconOn("attack_weapon_1",mWeaponZButton,CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS,CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS);
         initControllerIconOn("attack_weapon_2",mWeaponXButton,CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS,CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS);
         initControllerIconOn("attack_weapon_3",mWeaponCButton,CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS,CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS);
         initControllerIconOn("use_consumable_one",mConsumable1Button,CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS,CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS);
         initControllerIconOn("use_consumable_two",mConsumable2Button,CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS,CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS);
         initControllerIconOn("use_dungeon_buster",mDungeonBusterButton,CONTROLLER_ICON_POSITION_FOR_DUNGEON_BUSTER,CONTROLLER_GLYPH_SCALE_DUNGEON_BUSTER);
         initControllerIconOn("toggle_menu",mCloseButton,CONTROLLER_ICON_POSITION_FOR_CLOSE_BUTTON,CONTROLLER_GLYPH_SCALE_CLOSE_BUTTON);
         initControllerIconOn("toggle_chat_log",mUIChatLog ? mUIChatLog.chatLogButton : null,CONTROLLER_ICON_POSITION_FOR_CHAT_LOG_BUTTON,CONTROLLER_GLYPH_SCALE_CHAT_BUTTONS);
         if(mDBFacade.steamInputManager.usesSteamOnScreenKeyboard)
         {
            initControllerIconOn("open_chat_keyboard",mUIChatLog ? mUIChatLog.chatSendButton : null,CONTROLLER_ICON_POSITION_FOR_CHAT_SEND_BUTTON,CONTROLLER_GLYPH_SCALE_CHAT_BUTTONS);
         }
      }
      
      private function onSettingChanged(id:String) : void
      {
         if(id != "numbersOnBars")
         {
            return;
         }
         if(mAssetsLoaded && mHeroOwner != null)
         {
            setupStatsForResourceBars();
         }
      }
      
      private function onKeyBindingsChanged(action:String) : void
      {
         refreshKeyboardLabels();
      }
      
      private function refreshKeyboardLabels() : void
      {
         var _loc2_:KeyBindings = mDBFacade != null ? mDBFacade.keyBindings : null;
         if(_loc2_ == null || mUIRoot == null)
         {
            return;
         }
         setButtonLabel(mWeaponZButton,_loc2_.displayNameFor("attackWeapon1"));
         setButtonLabel(mWeaponXButton,_loc2_.displayNameFor("attackWeapon2"));
         setButtonLabel(mWeaponCButton,_loc2_.displayNameFor("attackWeapon3"));
         setButtonLabel(mConsumable1Button,_loc2_.displayNameFor("useConsumable1"));
         setButtonLabel(mConsumable2Button,_loc2_.displayNameFor("useConsumable2"));
         if(mDungeonBusterButton == null || mDBFacade.steamInputManager.hasGlyphForAction("use_dungeon_buster"))
         {
            return;
         }
         var _loc1_:String = Locale.getString("PRESS_BUSTER_BUTTON_KEYBOARD") + _loc2_.displayNameFor("useDungeonBuster");
         TextUtil.setText(mUIRoot.UI_buster_active.buster_activated.up.db_pressbutton_text,_loc1_);
         TextUtil.setText(mUIRoot.UI_buster_active.buster_activated.over.mc.db_pressbutton_text,_loc1_);
      }
      
      private function initControllerIconOn(inActionName:String, inButton:UIButton, iconPosition:Vector3D, iconScale:Point) : void
      {
         if(inButton == null || inButton.root == null)
         {
            return;
         }
         addControllerIcon(mHudControllerIcons,inActionName,inButton.root,iconPosition,iconScale);
      }
      
      private function setAllKeyboardIconsVisibility(isVisible:Boolean) : void
      {
         mWeaponZButton.label.visible = keepsKeyboardLabel(isVisible,"attack_weapon_1");
         mWeaponXButton.label.visible = keepsKeyboardLabel(isVisible,"attack_weapon_2");
         mWeaponCButton.label.visible = keepsKeyboardLabel(isVisible,"attack_weapon_3");
         mConsumable1Button.label.visible = keepsKeyboardLabel(isVisible,"use_consumable_one");
         mConsumable2Button.label.visible = keepsKeyboardLabel(isVisible,"use_consumable_two");
         if(mUIChatLog)
         {
            mUIChatLog.setChatPromptVisible(isVisible);
         }
         setBusterPressText(keepsKeyboardLabel(isVisible,"use_dungeon_buster"));
      }
      
      private function keepsKeyboardLabel(isVisible:Boolean, actionName:String) : Boolean
      {
         return isVisible || !mDBFacade.steamInputManager.hasGlyphForAction(actionName);
      }
      
      private function setBusterPressText(isKeyboard:Boolean) : void
      {
         var _loc2_:Object = null;
         if(mUIRoot == null || mUIRoot.UI_buster_active == null)
         {
            return;
         }
         var _loc4_:MovieClip = mUIRoot.UI_buster_active.buster_activated;
         if(_loc4_ == null)
         {
            return;
         }
         for each(var _loc3_:TextField in [_loc4_.up.db_pressbutton_text,_loc4_.over.mc.db_pressbutton_text])
         {
            if(_loc3_ != null)
            {
               _loc2_ = mBusterPressTextOriginals[_loc3_];
               if(_loc2_ == null)
               {
                  _loc2_ = {
                     "text":_loc3_.text,
                     "x":_loc3_.x
                  };
                  mBusterPressTextOriginals[_loc3_] = _loc2_;
               }
               if(isKeyboard)
               {
                  _loc3_.x = _loc2_.x;
                  TextUtil.setText(_loc3_,_loc2_.text);
               }
               else
               {
                  _loc3_.x = _loc2_.x + -5;
                  Locale.setText(_loc3_,"PRESS_BUSTER_BUTTON_CONTROLLER");
               }
            }
         }
         if(isKeyboard)
         {
            refreshKeyboardLabels();
         }
      }
      
      public function initControllerIcon(inActionName:String, inOwner:MovieClip, iconPosition:Vector3D, iconScale:Point) : void
      {
         addControllerIcon(mExternalControllerIcons,inActionName,inOwner,iconPosition,iconScale);
      }
      
      public function removeControllerIcons(inOwner:MovieClip) : void
      {
         var _loc2_:int = 0;
         var _loc3_:ControllerIconData = null;
         _loc2_ = mExternalControllerIcons.length - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = mExternalControllerIcons[_loc2_];
            if(_loc3_.mOwner == inOwner)
            {
               hideControllerIcon(_loc3_);
               _loc3_.destroy();
               mExternalControllerIcons.removeAt(_loc2_);
            }
            _loc2_--;
         }
      }
      
      private function addControllerIcon(icons:Vector.<ControllerIconData>, inActionName:String, inOwner:MovieClip, iconPosition:Vector3D, iconScale:Point) : void
      {
         if(inOwner == null)
         {
            return;
         }
         var _loc7_:ControllerIconData = null;
         for each(var _loc6_:ControllerIconData in icons)
         {
            if(_loc6_.mActionName == inActionName && _loc6_.mOwner == inOwner)
            {
               _loc7_ = _loc6_;
               break;
            }
         }
         if(_loc7_ == null)
         {
            _loc7_ = new ControllerIconData(null,inOwner,false);
            _loc7_.mActionName = inActionName;
            icons.push(_loc7_);
         }
         _loc7_.mPosition = iconPosition;
         _loc7_.mScale = iconScale;
         if(!mDBFacade.steamInputManager.isSteamInputReady)
         {
            _loc7_.mIsHidden = true;
            return;
         }
         showControllerIcon(_loc7_);
      }
      
      private function showControllerIcon(iconData:ControllerIconData) : void
      {
         var glyphFilePath:String;
         iconData.mIsHidden = false;
         glyphFilePath = mDBFacade.steamInputManager.getGlyphFilePathForAction(iconData.mActionName);
         if(glyphFilePath == "error1" || glyphFilePath == "")
         {
            glyphFilePath = null;
         }
         if(glyphFilePath == iconData.mGlyphFilePath)
         {
            if(iconData.mControllerGlyph != null && !iconData.mOwner.contains(iconData.mControllerGlyph))
            {
               iconData.mOwner.addChild(iconData.mControllerGlyph);
            }
            return;
         }
         if(iconData.mControllerGlyph != null && iconData.mOwner.contains(iconData.mControllerGlyph))
         {
            iconData.mOwner.removeChild(iconData.mControllerGlyph);
         }
         iconData.mControllerGlyph = null;
         iconData.mGlyphFilePath = glyphFilePath;
         if(glyphFilePath == null)
         {
            Logger.warnch("Input","UIHud: no controller glyph for action \'" + iconData.mActionName + "\'");
            return;
         }
         mAssetLoadingComponent.getImageAsset(glyphFilePath,function(param1:ImageAsset):void
         {
            if(iconData.mOwner == null || iconData.mGlyphFilePath != glyphFilePath || iconData.mControllerGlyph != null)
            {
               return;
            }
            var _loc2_:Bitmap = new Bitmap(param1.image.bitmapData,param1.image.pixelSnapping,param1.image.smoothing);
            _loc2_.x = iconData.mPosition.x;
            _loc2_.y = iconData.mPosition.y;
            _loc2_.width = iconData.mScale.x;
            _loc2_.height = iconData.mScale.y;
            iconData.mControllerGlyph = _loc2_;
            if(!iconData.mIsHidden)
            {
               iconData.mOwner.addChild(_loc2_);
            }
         });
      }
      
      private function refreshControllerIcons(icons:Vector.<ControllerIconData>) : void
      {
         for each(var _loc2_:ControllerIconData in icons)
         {
            showControllerIcon(_loc2_);
         }
      }
      
      private function hideAndUnloadControllerIcons() : void
      {
         unloadControllerIcons(mHudControllerIcons);
         unloadControllerIcons(mExternalControllerIcons);
      }
      
      private function syncControllerPrompts() : void
      {
         if(mDBFacade.steamInputManager.isSteamInputReady)
         {
            initAllControllerIcons();
            refreshControllerIcons(mExternalControllerIcons);
         }
         else
         {
            hideControllerIcons(mHudControllerIcons);
            hideControllerIcons(mExternalControllerIcons);
         }
         setAllKeyboardIconsVisibility(!mDBFacade.steamInputManager.wantsControllerPrompts);
      }
      
      private function openSettingsPopup() : void
      {
         if(mSettingsPopup || mDBFacade == null)
         {
            return;
         }
         mSettingsPopup = new SettingsPopup(mDBFacade,onSettingsPopupClosed);
         MemoryTracker.track(mSettingsPopup,"SettingsPopup - created in UIHud.openSettingsPopup()");
      }
      
      private function toggleSettingsPopup() : void
      {
         if(!mSettingsPopup)
         {
            openSettingsPopup();
         }
         else if(SettingsPopup.isTopMenu(mDBFacade))
         {
            mSettingsPopup.destroy();
            mSettingsPopup = null;
         }
      }
      
      private function onSteamInputButtonReleased(event:OnSteamInputButtonReleasedEvent) : void
      {
         if(event.actionName == "menu_options" && mSettingsPopup)
         {
            toggleSettingsPopup();
         }
      }
      
      private function onSettingsPopupClosed() : void
      {
         mSettingsPopup = null;
         mSuppressNextExitMenuToggle = mDBFacade.inputManager.check(27);
      }
      
      private function mouseOverXpListener(e:Event) : void
      {
         mUIRoot.UI_XP.xp_level_title.visible = false;
         mXpText.visible = true;
      }
      
      private function mouseOutXpListener(e:Event) : void
      {
         if(!mDBFacade.featureFlags.getFlagValue("want-numbered-hud"))
         {
            mUIRoot.UI_XP.xp_level_title.visible = true;
            mXpText.visible = false;
         }
      }
      
      public function showHealthFullMessage() : void
      {
         if(mHealthFullRevealer || mHealthFullFloater)
         {
            return;
         }
         mHealthFullClip.visible = true;
         mHealthFullClip.scaleX = 1;
         mHealthFullClip.scaleY = 1;
         mHealthFullRevealer = new Revealer(mHealthFullClip,mDBFacade,8,function():void
         {
            if(mHealthFullRevealer)
            {
               mHealthFullRevealer = null;
            }
            mHealthFullFloater = new FloatingMessage(mHealthFullClip,mDBFacade,2,16,1.125,0,null,function():void
            {
               mHealthFullClip.scaleX = 1;
               mHealthFullClip.scaleY = 1;
               mHealthFullFloater = null;
            },"DAMAGE_MOVEMENT_TYPE",true);
         },1);
      }
      
      public function showManaFullMessage() : void
      {
         if(mManaFullRevealer || mManaFullFloater)
         {
            return;
         }
         mManaFullClip.visible = true;
         mManaFullClip.scaleX = 1;
         mManaFullClip.scaleY = 1;
         mManaFullRevealer = new Revealer(mManaFullClip,mDBFacade,8,function():void
         {
            if(mManaFullRevealer)
            {
               mManaFullRevealer = null;
            }
            mManaFullFloater = new FloatingMessage(mManaFullClip,mDBFacade,2,16,1.125,0,null,function():void
            {
               mManaFullClip.scaleX = 1;
               mManaFullClip.scaleY = 1;
               mManaFullFloater = null;
            },"DAMAGE_MOVEMENT_TYPE",true);
         },1);
      }
      
      public function handleBoosterTimeUp(event:TimerEvent) : void
      {
         if(mBoosterTimer != null)
         {
            mBoosterTimer.stop();
            mBoosterTimer = null;
         }
         showBonusXPEffects(null);
         showBonusCoinEffects(null);
         var _loc2_:int = mDBFacade.dbAccountInfo.inventoryInfo.timeTillNextBoosterExpire();
         if(_loc2_ >= 0)
         {
            mBoosterTimer = Timers.create(_loc2_,0,"UIHud.mBoosterTimer");
            EventListeners.add(mBoosterTimer,"timer",handleBoosterTimeUp);
            mBoosterTimer.start();
         }
      }
      
      private function handleBoostersParsedEvent(event:Event) : void
      {
         showBonusXPEffects(event);
         showBonusCoinEffects(event);
      }
      
      private function showBonusXPEffects(event:Event) : void
      {
         var _loc2_:BoosterInfo = mDBFacade.dbAccountInfo.inventoryInfo.findHighestBoosterXP();
         if(mDBFacade.accountBonus.isXPBonusActive)
         {
            mXPBonusText.visible = true;
            TextUtil.setText(mXPBonusText,mDBFacade.accountBonus.xpBonusText);
         }
         else if(_loc2_ != null && _loc2_.BuffInfo.Exp > 1)
         {
            mXPBonusText.visible = true;
            TextUtil.setText(mXPBonusText,_loc2_.BuffInfo.Exp + Locale.getString("BOOSTER_XP"));
         }
         else
         {
            mXPBonusText.visible = false;
         }
      }
      
      private function showBonusCoinEffects(event:Event) : void
      {
         var _loc2_:BoosterInfo = mDBFacade.dbAccountInfo.inventoryInfo.findHighestBoosterGold();
         if(mDBFacade.accountBonus.isCoinBonusActive)
         {
            mCoinBonusText.visible = true;
            TextUtil.setText(mCoinBonusText,mDBFacade.accountBonus.coinBonusText);
         }
         else if(_loc2_ != null && _loc2_.BuffInfo.Gold > 1)
         {
            mCoinBonusText.visible = true;
            TextUtil.setText(mCoinBonusText,_loc2_.BuffInfo.Gold + Locale.getString("BOOSTER_GOLD"));
         }
         else
         {
            mCoinBonusText.visible = false;
         }
      }
      
      public function registerPet(petNPC:NPCGameObject) : void
      {
         if(mPetPortrait)
         {
            mPetPortrait.destroy();
         }
         if(mWantPets)
         {
            mPetPortrait = new PetPortraitUI(mDBFacade,mPetPortraitRoot,mPetPortraitNoneRoot,petNPC);
         }
      }
      
      public function unregisterPet(petNPC:NPCGameObject) : void
      {
         if(mPetPortrait)
         {
            if(mPetPortrait.petNPCGameObject == petNPC)
            {
               mPetPortrait.petDeath();
            }
            if(mPetPortrait.petNPCGameObject == null && petNPC.gmNpc.RespawnT <= 0)
            {
               mPetPortrait.destroy();
               mPetPortrait = null;
            }
         }
      }
      
      private function createWeaponTooltip(button:UIButton, num:uint) : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            if(!button.root)
            {
               return;
            }
            var _loc2_:Class = num == 0 ? param1.getClass("DR_weapon_tooltip_z") : param1.getClass("DR_weapon_tooltip");
            var _loc4_:UIWeaponTooltip = new UIWeaponTooltip(mDBFacade,_loc2_);
            button.tooltip = _loc4_;
            var _loc3_:Point = new Point();
            _loc3_.y -= button.root.height * 0.5;
            button.tooltipPos = _loc3_;
            button.tooltipDelay = 0.4;
         });
      }
      
      private function destroyTeamLoot() : void
      {
         if(mLootTween)
         {
            mDBFacade.mTween.killTween(mLootTween);
            mLootTween = null;
         }
         if(mLootTask)
         {
            mLootTask.destroy();
            mLootTask = null;
         }
         if(mTeamLootMC)
         {
            mTeamLootMC.clip.visible = false;
            if(mTeamLootMC.clip.parent)
            {
               mTeamLootMC.clip.parent.removeChild(mTeamLootMC.clip);
            }
            mTeamLootMC.destroy();
            mTeamLootMC = null;
         }
      }
      
      public function openTeamLoot(chestId:uint) : void
      {
         destroyTeamLoot();
         var _loc4_:String = "";
         switch(int(chestId) - 60001)
         {
            case 0:
               _loc4_ = "UI_teamloot_basic";
               break;
            case 1:
               _loc4_ = "UI_teamloot_uncommon";
               break;
            case 2:
               _loc4_ = "UI_teamloot_rare";
               break;
            case 3:
               _loc4_ = "UI_teamloot_legendary";
               break;
            case 4:
               _loc4_ = "UI_teamloot_box_small";
               break;
            case 5:
               _loc4_ = "UI_teamloot_box_royal";
         }
         var _loc3_:Class = mSwfAsset.getClass(_loc4_);
         var _loc2_:MovieClip = new _loc3_() as MovieClip;
         mTeamLootMC = new MovieClipRenderController(mDBFacade,_loc2_);
         mUIRoot.addChild(mTeamLootMC.clip);
         mTeamLootMC.clip.scaleX = mTeamLootMC.clip.scaleY = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
         mTeamLootMC.clip.x = -550;
         mTeamLootMC.clip.y = -150;
         if(mLootTween)
         {
            mDBFacade.mTween.killTween(mLootTween);
         }
         mTeamLootMC.play(0,true);
         mLootTween = mDBFacade.mTween.tweenMaxTo(mTeamLootMC.clip,0.5,{"x":-550});
         if(mLootTask)
         {
            mLootTask.destroy();
         }
         mLootTask = mLogicalWorkComponent.doLater(2,closeTeamLoot);
      }
      
      public function closeTeamLoot(gameClock:GameClock = null) : void
      {
         var cleanupFunc:Function;
         if(!mTeamLootMC)
         {
            return;
         }
         cleanupFunc = function():void
         {
            if(!mTeamLootMC)
            {
               return;
            }
            mTeamLootMC.stop();
            mTeamLootMC.clip.visible = false;
         };
         if(mLootTask)
         {
            mLootTask.destroy();
         }
         mLootTask = null;
         if(mLootTween)
         {
            mDBFacade.mTween.killTween(mLootTween);
         }
         mLootTween = mDBFacade.mTween.tweenMaxTo(mTeamLootMC.clip,0.5,{
            "x":-250,
            "onComplete":cleanupFunc
         });
      }
      
      public function detachHero() : void
      {
         var _loc1_:int = 0;
         hide();
         hideBustSign();
         if(mOffScreenPlayerManager)
         {
            mOffScreenPlayerManager.destroy();
         }
         mOffScreenPlayerManager = null;
         mHeroOwner = null;
         if(mUIChatLog)
         {
            mUIChatLog.heroOwner = null;
         }
         mEventComponent.removeAllListeners();
         EventListeners.remove(mUIRoot.UI_XP,"mouseOver",mouseOverXpListener);
         EventListeners.remove(mUIRoot.UI_XP,"mouseOut",mouseOutXpListener);
         if(mProfileBox)
         {
            EventListeners.remove(mProfileBox,"mouseOver",mouseOverProfileBox);
            EventListeners.remove(mProfileBox,"mouseOut",mouseOutProfileBox);
         }
         if(mBuffDisplayTask)
         {
            mBuffDisplayTask.destroy();
         }
         mBuffDisplayTask = null;
         if(mBuffs)
         {
            mBuffs.splice(0,mBuffs.length);
         }
         if(mBuffIconButtons)
         {
            _loc1_ = 0;
            while(_loc1_ < mBuffIconButtons.length)
            {
               if(mBuffIconButtons[_loc1_])
               {
                  mBuffIconButtons[_loc1_].destroy();
               }
               _loc1_++;
            }
            mBuffIconButtons.splice(0,mBuffIconButtons.length);
         }
         if(mBuffCooldowns)
         {
            _loc1_ = 0;
            while(_loc1_ < mBuffCooldowns.length)
            {
               if(mBuffCooldowns[_loc1_])
               {
                  mBuffCooldowns[_loc1_].destroy();
               }
               _loc1_++;
            }
            mBuffCooldowns.splice(0,mBuffCooldowns.length);
         }
         if(mBoosterTimer)
         {
            mBoosterTimer.stop();
            EventListeners.remove(mBoosterTimer,"timer",handleBoosterTimeUp);
            mBoosterTimer = null;
         }
         if(mDungeonBusterButton)
         {
            mDungeonBusterButton.destroy();
         }
         mDungeonBusterButton = null;
         if(mBusterGlowMc)
         {
            mBusterGlowMc.destroy();
         }
         mBusterGlowMc = null;
         if(mBusterPulseMc)
         {
            mBusterPulseMc.destroy();
         }
         mBusterPulseMc = null;
         if(mLootLossPopup)
         {
            mLootLossPopup.destroy();
         }
         mLootLossPopup = null;
         if(mInfiniteExitPopup)
         {
            mInfiniteExitPopup.destroy();
         }
         mInfiniteExitPopup = null;
         destroyTeamLoot();
      }
      
      public function initializeHud(heroOwner:HeroGameObjectOwner) : void
      {
         var boosterTime:int;
         var equippedWeapons:Vector.<WeaponGameObject>;
         var i:int;
         var equippedConsumableWeapons:Vector.<ConsumableWeaponGameObject>;
         var j:int;
         var gmSkin:GMSkin;
         var busterConstant:String;
         var busterAttack:GMAttack;
         var busterName:String;
         show();
         mHeroOwner = heroOwner;
         if(mAssetsLoaded && mHeroOwner != null)
         {
            mUIChatLog.heroOwner = mHeroOwner;
            mUIChatLog.enable();
            hideInvulnerable();
            setHp(mHeroOwner.hitPoints,mHeroOwner.maxHitPoints);
            setMana(mHeroOwner.manaPoints,mHeroOwner.maxManaPoints);
            setXp(mHeroOwner.experiencePoints);
            bulgeXpBar();
            bulgeProfileBox();
            this.addListeners();
            if(mBoosterTimer != null)
            {
               mBoosterTimer.stop();
               mBoosterTimer.removeEventListener("timer",handleBoosterTimeUp);
               mBoosterTimer = null;
            }
            boosterTime = mDBFacade.dbAccountInfo.inventoryInfo.timeTillNextBoosterExpire();
            if(boosterTime >= 0)
            {
               mBoosterTimer = Timers.create(boosterTime,0,"UIHud.mBoosterTimer");
               EventListeners.add(mBoosterTimer,"timer",handleBoosterTimeUp);
               mBoosterTimer.start();
            }
            if(mOffScreenPlayerManager)
            {
               mOffScreenPlayerManager.destroy();
               mOffScreenPlayerManager = null;
            }
            mOffScreenPlayerManager = new UIOffScreenPlayerManager(mDBFacade,mUIRoot,mHeroOwner);
            equippedWeapons = new Vector.<WeaponGameObject>();
            i = 0;
            while(i < mHeroOwner.weaponControllers.length)
            {
               equippedWeapons.push(mHeroOwner.weaponControllers[i] ? mHeroOwner.weaponControllers[i].weapon : null);
               i = i + 1;
            }
            this.setupWeaponUI(equippedWeapons);
            equippedConsumableWeapons = new Vector.<ConsumableWeaponGameObject>();
            j = 0;
            while(j < 2)
            {
               equippedConsumableWeapons.push(mHeroOwner.consumables[j] ? mHeroOwner.consumables[j] : null);
               j = j + 1;
            }
            this.setupConsumableWeaponUI(equippedConsumableWeapons);
            gmSkin = mHeroOwner.gmSkin;
            if(gmSkin == null)
            {
               Logger.error("GMSkin on hero is null.  HeroType: " + mHeroOwner.type + " AccountId: " + mDBFacade.accountId);
            }
            else
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.UISwfFilepath),function(param1:SwfAsset):void
               {
                  var _loc3_:Class = param1.getClass(gmSkin.IconName);
                  var _loc2_:MovieClip = new _loc3_();
                  if(mUIRoot.UI_profile.avatar)
                  {
                     mUIRoot.UI_profile.avatar.addChild(_loc2_);
                  }
                  if(mUIRoot.avatar)
                  {
                     mUIRoot.avatar.addChild(_loc2_);
                  }
               });
            }
            mStacksHud.setupStacksUI();
            if(mDungeonBusterButton)
            {
               mDungeonBusterButton.destroy();
            }
            mDungeonBusterButton = new UIButton(mDBFacade,mUIRoot.UI_buster_active.buster_activated);
            mDungeonBusterButton.releaseCallback = handleBusterBarClickEvent;
            mBusterLabel = mUIRoot.UI_buster_active.buster_activated.up.name_mc.name_label;
            mBusterLabelOver = mUIRoot.UI_buster_active.buster_activated.over.mc.name_label;
            busterConstant = mHeroOwner.gMHero.DBuster1;
            busterAttack = mDBFacade.gameMaster.attackByConstant.itemFor(busterConstant);
            busterName = busterAttack ? GameMasterLocale.getGameMasterSubString("ATTACK_BUSTER_NAME",busterAttack.Constant) : "BUSTER!";
            TextUtil.setText(mBusterLabel,busterName.toUpperCase());
            TextUtil.setText(mBusterLabelOver,busterName.toUpperCase());
            if(mBusterGlowMc)
            {
               mBusterGlowMc.destroy();
            }
            mBusterGlowMc = new MovieClipRenderController(mDBFacade,mUIRoot.UI_buster_glow);
            if(mBusterPulseMc)
            {
               mBusterPulseMc.destroy();
            }
            mBusterPulseMc = new MovieClipRenderController(mDBFacade,mUIRoot.UI_buster.buster_activated_glow);
            if(mUIRoot.UI_buster.buster_activated_glow.visible)
            {
               mBusterPulseMc.play(0,true);
            }
            TextUtil.setText(mUIRoot.UI_buster_glow.buster_text.buster_text_label.name_label,busterName.toUpperCase());
            refreshKeyboardLabels();
            if(mDBFacade.dbAccountInfo)
            {
               setCurrency(mDBFacade.dbAccountInfo.basicCurrency,mDBFacade.dbAccountInfo.premiumCurrency);
            }
            mMaxBusterPoints = mHeroOwner.maxBusterPoints;
            setBusterPoints(mHeroOwner.dungeonBusterPoints);
            initializePetPortraits();
            setCurrentFloorLabel();
            setDungeonModifiers();
            mUIChatLog.heroOwner = mHeroOwner;
            if(mBuffDisplayTask)
            {
               mBuffDisplayTask.destroy();
            }
            mBuffDisplayTask = mLogicalWorkComponent.doEveryFrame(updateBuffDisplay);
            setupStatsForResourceBars();
         }
      }
      
      private function setCurrentFloorLabel() : void
      {
         TextUtil.setText(mFloorLabel,Locale.getString("UI_HUD_FLOOR_LABEL") + mHeroOwner.distributedDungeonFloor.getCurrentFloorNum().toString());
      }
      
      private function setDungeonModifiers() : void
      {
         var _loc1_:UIButton = null;
         var _loc2_:uint = 0;
         mDungeonModifer1.visible = false;
         mDungeonModifer2.visible = false;
         mDungeonModifer3.visible = false;
         mDungeonModifer4.visible = false;
         _loc2_ = 0;
         while(_loc2_ < mHeroOwner.distributedDungeonFloor.activeGMDungeonModifiers.length)
         {
            switch(int(_loc2_))
            {
               case 0:
                  _loc1_ = mDungeonModifer1;
                  break;
               case 1:
                  _loc1_ = mDungeonModifer2;
                  break;
               case 2:
                  _loc1_ = mDungeonModifer3;
                  break;
               case 3:
                  _loc1_ = mDungeonModifer4;
            }
            setupModifiers(_loc1_,mHeroOwner.distributedDungeonFloor.activeGMDungeonModifiers[_loc2_]);
            _loc2_++;
         }
      }
      
      private function setupModifiers(dungeonModButton:UIButton, gmDungeonModifier:DungeonModifierHelper) : void
      {
         TextUtil.setText(dungeonModButton.tooltip.title_label,GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_NAME",gmDungeonModifier.GMDungeonMod.Constant));
         TextUtil.setText(dungeonModButton.tooltip.description_label,GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_DESCRIPTION",gmDungeonModifier.GMDungeonMod.Constant));
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmDungeonModifier.GMDungeonMod.IconFilepath),function(param1:SwfAsset):void
         {
            if(!dungeonModButton.root)
            {
               return;
            }
            var _loc2_:Class = param1.getClass(gmDungeonModifier.GMDungeonMod.IconName);
            if(_loc2_ == null)
            {
               return;
            }
            var _loc3_:MovieClip = new _loc2_();
            UIObject.scaleToFit(_loc3_,dungeonModButton.root.width);
            _loc3_.x += 10;
            _loc3_.y += 10;
            dungeonModButton.root.removeChildren();
            dungeonModButton.root.addChild(_loc3_);
            dungeonModButton.root.visible = true;
         });
      }
      
      private function initializePetPortraits() : void
      {
         var _loc1_:NPCGameObject = null;
         if(mPetPortrait)
         {
            _loc1_ = mPetPortrait.petNPCGameObject;
         }
         else
         {
            _loc1_ = mPetCarriedAcrossRebuild;
         }
         mPetCarriedAcrossRebuild = null;
         registerPet(_loc1_);
      }
      
      public function show() : void
      {
         mSceneGraphComponent.addChild(mRoot,50);
         mStacksHud.show();
         mDBFacade.camera.yCilppingFromBottom = mVerticalYClipping;
         initializePetPortraits();
      }
      
      public function hide() : void
      {
         mSceneGraphComponent.removeChild(mRoot);
         mDBFacade.camera.yCilppingFromBottom = 0;
         mDBFacade.camera.forceRedraw();
         if(mSettingsPopup)
         {
            mSettingsPopup.destroy();
            mSettingsPopup = null;
         }
         mStacksHud.hide();
         if(mUIChatLog)
         {
            mUIChatLog.disable();
            mUIChatLog.hideChatLog();
         }
         if(mPetPortrait)
         {
            mPetPortrait.destroy();
         }
         mPetPortrait = null;
         mPetCarriedAcrossRebuild = null;
      }
      
      public function showStacks() : void
      {
         mStacksHud.show();
      }
      
      public function hideStacks() : void
      {
         mStacksHud.hide();
      }
      
      private function resetButtons(buttons:Vector.<UIButton>) : void
      {
         var _loc3_:DisplayObject = null;
         for each(var _loc2_:UIButton in buttons)
         {
            _loc2_.pressCallback = null;
            _loc2_.pressRollOutCallback = null;
            if(_loc2_.tooltip)
            {
               _loc2_.tooltip.visible = false;
            }
            if(_loc2_.root.graphic.numChildren > 0)
            {
               _loc2_.root.graphic.removeChildAt(0);
            }
            _loc3_ = _loc2_.root.getChildByName("rarityIcon");
            if(_loc3_)
            {
               _loc2_.root.removeChild(_loc3_);
            }
            _loc2_.root.selectionFrame.visible = false;
            _loc2_.enabled = true;
            _loc2_.root.filters = [];
         }
      }
      
      private function setupWeaponUI(equippedWeapons:Vector.<WeaponGameObject>) : void
      {
         var weaponGameObject:WeaponGameObject;
         var gmWeapon:GMWeaponItem;
         var gmWeaponAesthetic:GMWeaponAesthetic;
         var weapon:MovieClip;
         var button:UIButton;
         var tooltip:UIWeaponTooltip;
         var i:uint;
         var makeCallback:Function;
         var slotSize:Number = 56;
         resetButtons(mWeaponButtons);
         i = 0;
         while(i < equippedWeapons.length)
         {
            if(equippedWeapons[i])
            {
               weaponGameObject = equippedWeapons[i];
               gmWeapon = weaponGameObject.weaponData;
               gmWeaponAesthetic = weaponGameObject.weaponAesthetic;
               button = mWeaponButtons[i];
               button.root.weaponIndex = i;
               tooltip = UIWeaponTooltip(button.tooltip);
               tooltip.setWeaponItemFromWeaponGameObject(weaponGameObject);
               tooltip.visible = true;
               button.pressCallbackThis = function(param1:UIButton):void
               {
                  if(mHeroOwner.currentWeaponIndex != param1.root.weaponIndex)
                  {
                     mHeroOwner.currentWeaponIndex = param1.root.weaponIndex;
                  }
                  else
                  {
                     mHeroOwner.PlayerAttack.addToPotentialWeaponInputQueue(param1.root.weaponIndex,true,true);
                  }
               };
               button.releaseCallbackThis = function(param1:UIButton):void
               {
                  if(mHeroOwner.currentWeaponIndex == param1.root.weaponIndex)
                  {
                     mHeroOwner.PlayerAttack.addToPotentialWeaponInputQueue(param1.root.weaponIndex,false,true);
                  }
               };
               button.pressRollOutCallback = function():void
               {
                  mDBFacade.inputManager.onMouseDown(null);
               };
               makeCallback = function(param1:UIButton, param2:GMWeaponAesthetic, param3:GMRarity):Function
               {
                  var weaponButton:UIButton = param1;
                  var weaponAesthetic:GMWeaponAesthetic = param2;
                  var rarity:GMRarity = param3;
                  return function(param1:SwfAsset):void
                  {
                     var weaponClass:Class;
                     var bgColoredExists:Boolean;
                     var bgSwfPath:String;
                     var bgIconName:String;
                     var swfAsset:SwfAsset = param1;
                     if(!weaponButton.root)
                     {
                        return;
                     }
                     weaponClass = swfAsset.getClass(weaponAesthetic.IconName);
                     if(weaponClass == null)
                     {
                        return;
                     }
                     weapon = new weaponClass();
                     weapon.name = "weaponIcon";
                     weapon.scaleX = weapon.scaleY = 60 / DBGlobal.WEAPON_ICON_NATIVE_SIZE;
                     weaponButton.root.graphic.addChildAt(weapon,0);
                     bgColoredExists = rarity.HasColoredBackground;
                     bgSwfPath = rarity.BackgroundSwf;
                     bgIconName = rarity.BackgroundIcon;
                     if(bgColoredExists && mDBFacade.featureFlags.getFlagValue("want-dynamic-rarity-backgrounds"))
                     {
                        mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset):void
                        {
                           var _loc3_:MovieClip = null;
                           if(!weaponButton.root)
                           {
                              return;
                           }
                           var _loc2_:Class = param1.getClass(bgIconName);
                           if(_loc2_)
                           {
                              _loc3_ = new _loc2_() as MovieClip;
                              _loc3_.name = "rarityIcon";
                              weaponButton.root.addChildAt(_loc3_,2);
                              _loc3_.scaleX = _loc3_.scaleY = 0.85;
                              _loc3_.y -= 6;
                           }
                        });
                     }
                  };
               };
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmWeaponAesthetic.IconSwf),makeCallback(button,gmWeaponAesthetic,weaponGameObject.gmRarity));
            }
            i = i + 1;
         }
      }
      
      private function setupConsumableWeaponUI(equippedConsumableWeapons:Vector.<ConsumableWeaponGameObject>) : void
      {
         var consumableWeaponGameObject:ConsumableWeaponGameObject;
         var gmWeapon:GMWeaponItem;
         var gmWeaponAesthetic:GMWeaponAesthetic;
         var weapon:MovieClip;
         var button:UIButton;
         var tooltip:MovieClip;
         var i:uint;
         var makeCallback:Function;
         var slotSize:Number = 56;
         resetButtons(mConsumableWeaponButtons);
         mUIRoot.consumable_tooltip01.visible = false;
         mUIRoot.consumable_tooltip02.visible = false;
         i = 0;
         while(i < equippedConsumableWeapons.length)
         {
            button = mConsumableWeaponButtons[i];
            button.root.quantity.visible = false;
            button.root.textx.visible = false;
            if(equippedConsumableWeapons[i])
            {
               consumableWeaponGameObject = equippedConsumableWeapons[i];
               gmWeapon = consumableWeaponGameObject.weaponData;
               button.root.weaponIndex = i;
               button.root.quantity.visible = true;
               button.root.textx.visible = true;
               TextUtil.setText(button.root.quantity,consumableWeaponGameObject.getConsumableCount().toString());
               switch(int(i))
               {
                  case 0:
                     tooltip = mUIRoot.consumable_tooltip01;
                     break;
                  case 1:
                     tooltip = mUIRoot.consumable_tooltip02;
               }
               button.tooltip = tooltip;
               TextUtil.setText(button.tooltip.description_label,GameMasterLocale.getGameMasterSubString("STACKABLE_DESCRIPTION",consumableWeaponGameObject.getGMStackable().Constant));
               tooltip.visible = true;
               button.setTooltipToBeParentedToStage();
               button.tooltipPos = new Point(button.root.x,button.root.y);
               button.releaseCallbackThis = function(param1:UIButton):void
               {
                  mHeroOwner.tryToUseConsumable(param1.root.weaponIndex);
               };
               makeCallback = function(param1:UIButton, param2:GMStackable):Function
               {
                  var weaponButton:UIButton = param1;
                  var gmStackable:GMStackable = param2;
                  return function(param1:SwfAsset):void
                  {
                     if(!weaponButton.root)
                     {
                        return;
                     }
                     var _loc2_:Class = param1.getClass(gmStackable.IconName);
                     if(_loc2_ == null)
                     {
                        return;
                     }
                     weapon = new _loc2_();
                     weapon.name = "weaponIcon";
                     weapon.scaleX = weapon.scaleY = 60 / DBGlobal.WEAPON_ICON_NATIVE_SIZE;
                     weaponButton.root.graphic.addChildAt(weapon,0);
                  };
               };
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(consumableWeaponGameObject.getGMStackable().UISwfFilepath),makeCallback(button,consumableWeaponGameObject.getGMStackable()));
            }
            i = i + 1;
         }
      }
      
      private function addListeners() : void
      {
         var heroOwnerId:uint;
         mEventComponent.removeAllListeners();
         heroOwnerId = mHeroOwner.id;
         mEventComponent.addListener("BONUS_XP_CHANGED_EVENT",showBonusXPEffects);
         showBonusXPEffects(new Event("BONUS_XP_CHANGED_EVENT"));
         mEventComponent.addListener("BONUS_COIN_CHANGED_EVENT",showBonusCoinEffects);
         showBonusCoinEffects(new Event("BONUS_COIN_CHANGED_EVENT"));
         mEventComponent.addListener("BoostersParsedEvent_BOOSTERS_PARSED_UPDATE",this.handleBoostersParsedEvent);
         mEventComponent.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE",heroOwnerId),function(param1:HpEvent):void
         {
            setHp(param1.hp,param1.maxHp);
         });
         mEventComponent.addListener(GameObjectEvent.uniqueEvent("ManaEvent_MANA_UPDATE",heroOwnerId),function(param1:ManaEvent):void
         {
            setMana(param1.mana,param1.maxMana);
         });
         mEventComponent.addListener(GameObjectEvent.uniqueEvent("ExperienceEvent_EXPERIENCE_UPDATE",heroOwnerId),function(param1:ExperienceEvent):void
         {
            setXp(param1.experience);
         });
         mEventComponent.addListener(GameObjectEvent.uniqueEvent("BusterPointEvent_BUSTER_POINTS_UPDATE",heroOwnerId),handleBusterPointsEvent);
         mEventComponent.addListener("CurrencyUpdatedAccountEvent",function(param1:CurrencyUpdatedAccountEvent):void
         {
            setCurrency(param1.basicCurrency,param1.premiumCurrency);
         });
         mEventComponent.addListener(GameObjectEvent.uniqueEvent(BuffHandler.ACTOR_INVULNERABLE,heroOwnerId),function(param1:ActorInvulnerableEvent):void
         {
            if(param1.mIsInvulnerable)
            {
               showInvulnerable();
            }
            else
            {
               hideInvulnerable();
            }
         });
         mEventComponent.addListener("UI_HUD_CHANGE_EVENT",switchHudEvent);
         mEventComponent.addListener("OnSteamInputGlyphsChanged",onSteamInputGlyphsChanged);
         mEventComponent.addListener("ControllerConnectionChangedEvent",onControllerConnectionChanged);
         mEventComponent.addListener("OnSteamInputButtonReleasedEvent",onSteamInputButtonReleased);
         EventListeners.add(mProfileBox,"mouseOver",mouseOverProfileBox);
         EventListeners.add(mProfileBox,"mouseOut",mouseOutProfileBox);
         EventListeners.add(mUIRoot.UI_XP,"mouseOver",mouseOverXpListener);
         EventListeners.add(mUIRoot.UI_XP,"mouseOut",mouseOutXpListener);
         setAllKeyboardIconsVisibility(!mDBFacade.steamInputManager.wantsControllerPrompts);
         if(mDBFacade.steamInputManager.isSteamInputReady && mInitControllerIconsLater == null)
         {
            mInitControllerIconsLater = mLogicalWorkComponent.doLater(mControllerIconLoadDelay,initAllControllerIconsTask);
         }
      }
      
      private function onControllerConnectionChanged(inEvent:Event) : void
      {
         syncControllerPrompts();
      }
      
      private function mouseOutProfileBox(e:Event) : void
      {
         if(!mDBFacade.featureFlags.getFlagValue("want-numbered-hud"))
         {
            mHpText.visible = false;
            mManaText.visible = false;
         }
      }
      
      private function mouseOverProfileBox(e:Event) : void
      {
         mHpText.visible = true;
         mManaText.visible = true;
      }
      
      private function setupStatsForResourceBars() : void
      {
         if(mDBFacade.featureFlags.getFlagValue("want-numbered-hud"))
         {
            mHpText.visible = true;
            mManaText.visible = true;
            mXpText.visible = true;
            mUIRoot.UI_XP.xp_level_title.visible = false;
         }
         else
         {
            mHpText.visible = false;
            mManaText.visible = false;
            mXpText.visible = false;
            mUIRoot.UI_XP.xp_level_title.visible = true;
         }
      }
      
      private function handleBusterPointsEvent(event:BusterPointsEvent) : void
      {
         mMaxBusterPoints = event.maxBusterPoints;
         setBusterPoints(event.busterPoints);
      }
      
      private function showInvulnerable() : void
      {
         mFlashingHpBar.value = mHpBar.value;
         mFlashingHpBar.visible = true;
         mHpBar.visible = false;
      }
      
      private function hideInvulnerable() : void
      {
         mFlashingHpBar.visible = false;
         mHpBar.visible = true;
      }
      
      public function get floaterTextClass() : Class
      {
         return mFloaterTextClass;
      }
      
      private function floaterCallback(clip:MovieClip) : Function
      {
         return function():void
         {
            mDBFacade.sceneGraphManager.removeChild(clip);
         };
      }
      
      private function spawnFloater(text:String, x:Number, y:Number, color:uint, scale:Number, holdTime:uint, fadeTime:uint, scaleDampening:Number, speed:Number) : void
      {
         var _loc10_:MovieClip = new mFloaterTextClass() as MovieClip;
         _loc10_.label.text = text;
         _loc10_.label.textColor = color;
         _loc10_.x = x;
         _loc10_.y = y;
         _loc10_.scaleX = scale;
         _loc10_.scaleY = scale;
         var _loc11_:FloatingMessage = new FloatingMessage(_loc10_,mDBFacade,holdTime,fadeTime,scaleDampening,speed,null,floaterCallback(_loc10_));
         mDBFacade.sceneGraphManager.addChild(_loc10_,50);
      }
      
      public function setHp(current:uint, max:uint) : void
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         var _loc3_:Number = current / max;
         mHpBar.value = _loc3_;
         mFlashingHpBar.value = _loc3_;
         TextUtil.setText(mHpText,current.toString() + " / " + max.toString());
      }
      
      public function setMana(current:uint, max:uint) : void
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         mManaBar.value = current / max;
         TextUtil.setText(mManaText,current.toString() + " / " + max.toString());
      }
      
      private function spawnBusterFloater(delta:int, offset:Number) : void
      {
      }
      
      public function setBusterPoints(current:uint) : void
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         mBusterBar.value = current / mMaxBusterPoints;
         var _loc2_:int = current - mBusterValue;
         if(_loc2_ > 0)
         {
            spawnBusterFloater(_loc2_,mBusterBar.value * 75);
         }
         mBusterValue = current;
         if(mBusterValue >= mMaxBusterPoints)
         {
            this.showBustSign();
         }
         else
         {
            this.hideBustSign();
         }
      }
      
      public function setCurrency(basicCurrency:int, premiumCurrency:int) : void
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         TextUtil.setText(mBasicCurrencyText,basicCurrency.toString());
         TextUtil.setText(mPremiumCurrencyText,premiumCurrency.toString());
      }
      
      private function spawnCoinFloater(delta:int) : void
      {
      }
      
      public function setBasicCurrency(basicCurrency:int) : void
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         var _loc2_:int = basicCurrency - mBasicCurrency;
         if(_loc2_ > 0)
         {
            spawnCoinFloater(_loc2_);
         }
         TextUtil.setText(mBasicCurrencyText,basicCurrency.toString());
         mBasicCurrency = basicCurrency;
      }
      
      private function spawnCashFloater(delta:int) : void
      {
      }
      
      public function setPremiumCurrency(premiumCurrency:int) : void
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         var _loc2_:int = premiumCurrency - mPremiumCurrency;
         if(_loc2_ > 0)
         {
            spawnCashFloater(_loc2_);
         }
         TextUtil.setText(mPremiumCurrencyText,premiumCurrency.toString());
         mPremiumCurrency = premiumCurrency;
      }
      
      private function spawnXpFloater(delta:int, offset:Number) : void
      {
      }
      
      public function setXp(xp:uint) : void
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         var _loc5_:uint = mHeroOwner.level;
         var _loc4_:uint = xp;
         var _loc2_:uint = uint(mHeroOwner.gMHero.getLevelIndex(xp,mHeroOwner.ascensionLevel));
         var _loc7_:uint = uint(_loc2_ > 0 ? mHeroOwner.gMHero.getExpFromIndex(_loc2_ - 1) : 0);
         var _loc6_:uint = mHeroOwner.gMHero.getExpFromIndex(_loc2_);
         TextUtil.setText(mLevelText,_loc5_.toString());
         var _loc3_:Number = (_loc4_ - _loc7_) / (_loc6_ - _loc7_);
         mXpBar.value = _loc3_;
         TextUtil.setText(mXpText,_loc4_.toString() + " / " + _loc6_.toString());
         spawnXpFloater(xp - mXpValue,_loc3_ * 100);
         mXpValue = xp;
         if(!mXpGotInitialUpdate)
         {
            mXpGotInitialUpdate = true;
            bulgeXpBar();
         }
      }
      
      private function updateXpBulge(clock:GameClock) : void
      {
         var _loc3_:MovieClip = mXpObject.root;
         var _loc2_:Number = _loc3_.scaleX - mXpRestScale;
         _loc2_ *= 0.75;
         _loc3_.scaleX = mXpRestScale + _loc2_;
         _loc3_.scaleY = mXpRestScale + _loc2_;
         if(Math.abs(_loc2_) <= 0.01)
         {
            _loc3_.scaleX = mXpRestScale;
            _loc3_.scaleY = mXpRestScale;
            mXpBulgeTask.destroy();
            mXpBulgeTask = null;
         }
      }
      
      public function bulgeXpBar() : void
      {
         if(!mDBFacade.featureFlags.getFlagValue("want-pickup-ui-pop"))
         {
            return;
         }
         mXpObject.root.scaleX *= 1.08;
         mXpObject.root.scaleY *= 1.08;
         if(mXpBulgeTask == null)
         {
            mXpBulgeTask = mLogicalWorkComponent.doEveryFrame(updateXpBulge);
         }
      }
      
      private function updateProfileBulge(clock:GameClock) : void
      {
         var _loc2_:Number = mProfileBox.scaleX - mProfileRestScale;
         _loc2_ *= 0.75;
         mProfileBox.scaleX = mProfileRestScale + _loc2_;
         mProfileBox.scaleY = mProfileRestScale + _loc2_;
         if(Math.abs(_loc2_) <= 0.01)
         {
            mProfileBox.scaleX = mProfileRestScale;
            mProfileBox.scaleY = mProfileRestScale;
            mProfileBulgeTask.destroy();
            mProfileBulgeTask = null;
         }
      }
      
      public function bulgeProfileBox() : void
      {
         if(!mDBFacade.featureFlags.getFlagValue("want-pickup-ui-pop"))
         {
            return;
         }
         mProfileBox.scaleX *= 1.08;
         mProfileBox.scaleY *= 1.08;
         if(mProfileBulgeTask == null)
         {
            mProfileBulgeTask = mLogicalWorkComponent.doEveryFrame(updateProfileBulge);
         }
      }
      
      public function destroy() : void
      {
         var _loc2_:int = 0;
         var _loc1_:UIButton = null;
         if(mDBFacade != null && mDBFacade.keyBindings != null)
         {
            mDBFacade.keyBindings.removeChangeListener(onKeyBindingsChanged);
         }
         if(mSettingsModel != null)
         {
            mSettingsModel.removeChangeListener(onSettingChanged);
            mSettingsModel = null;
         }
         if(mProfileBox)
         {
            EventListeners.remove(mProfileBox,"mouseOver",mouseOverProfileBox);
            EventListeners.remove(mProfileBox,"mouseOut",mouseOutProfileBox);
         }
         if(mBuffs)
         {
            mBuffs.splice(0,mBuffs.length);
            mBuffs = null;
         }
         if(mBuffIconButtons)
         {
            _loc2_ = 0;
            while(_loc2_ < mBuffIconButtons.length)
            {
               if(mBuffIconButtons[_loc2_])
               {
                  mBuffIconButtons[_loc2_].destroy();
               }
               _loc2_++;
            }
            mBuffIconButtons = null;
         }
         if(mBuffCooldowns)
         {
            _loc2_ = 0;
            while(_loc2_ < mBuffCooldowns.length)
            {
               if(mBuffCooldowns[_loc2_])
               {
                  mBuffCooldowns[_loc2_].destroy();
               }
               _loc2_++;
            }
            mBuffCooldowns = null;
         }
         if(mBoosterTimer != null)
         {
            mBoosterTimer.stop();
            mBoosterTimer = null;
         }
         mDBFacade = null;
         if(mSettingsPopup)
         {
            mSettingsPopup.destroy();
            mSettingsPopup = null;
         }
         mStacksHud.destroy();
         mStacksHud = null;
         if(mOffScreenPlayerManager)
         {
            mOffScreenPlayerManager.destroy();
            mOffScreenPlayerManager = null;
         }
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mEventComponent.destroy();
         mEventComponent = null;
         mHeroOwner = null;
         mRoot = null;
         mUIRoot = null;
         if(mInitControllerIconsLater)
         {
            mInitControllerIconsLater.destroy();
         }
         mInitControllerIconsLater = null;
         if(mProfileBulgeTask)
         {
            mProfileBulgeTask.destroy();
         }
         mProfileBulgeTask = null;
         if(mBuffDisplayTask)
         {
            mBuffDisplayTask.destroy();
         }
         mBuffDisplayTask = null;
         if(mHpBar)
         {
            mHpBar.destroy();
         }
         mHpBar = null;
         if(mFlashingHpBar)
         {
            mFlashingHpBar.destroy();
         }
         mFlashingHpBar = null;
         if(mManaBar)
         {
            mManaBar.destroy();
         }
         mManaBar = null;
         if(mBusterBar)
         {
            mBusterBar.destroy();
         }
         mBusterBar = null;
         if(mXpBar)
         {
            mXpBar.destroy();
         }
         mXpBar = null;
         if(mXpBulgeTask)
         {
            mXpBulgeTask.destroy();
         }
         mXpBulgeTask = null;
         if(mLootTask)
         {
            mLootTask.destroy();
         }
         mLootTask = null;
         if(mCloseButton)
         {
            mCloseButton.destroy();
         }
         mCloseButton = null;
         if(mWeaponZButton)
         {
            mWeaponZButton.destroy();
         }
         mWeaponZButton = null;
         if(mWeaponXButton)
         {
            mWeaponXButton.destroy();
         }
         mWeaponXButton = null;
         if(mWeaponCButton)
         {
            mWeaponCButton.destroy();
         }
         mWeaponCButton = null;
         if(mConsumable1Button)
         {
            mConsumable1Button.destroy();
         }
         mConsumable1Button = null;
         if(mConsumable2Button)
         {
            mConsumable2Button.destroy();
         }
         mConsumable2Button = null;
         if(mDungeonBusterButton)
         {
            mDungeonBusterButton.destroy();
         }
         mDungeonBusterButton = null;
         if(mBusterGlowMc)
         {
            mBusterGlowMc.destroy();
         }
         mBusterGlowMc = null;
         if(mBusterPulseMc)
         {
            mBusterPulseMc.destroy();
         }
         mBusterPulseMc = null;
         if(mSettingsPopup)
         {
            mSettingsPopup.destroy();
         }
         mSettingsPopup = null;
         if(mStacksHud)
         {
            mStacksHud.destroy();
         }
         mStacksHud = null;
         if(mUITask)
         {
            mUITask.destroy();
         }
         mUITask = null;
         if(mUIChatLog)
         {
            mUIChatLog.destroy();
         }
         mUIChatLog = null;
         if(mPetPortrait)
         {
            mPetPortrait.destroy();
         }
         mPetPortrait = null;
         for each(_loc1_ in mWeaponButtons)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
            _loc1_ = null;
         }
         for each(_loc1_ in mConsumableWeaponButtons)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
            _loc1_ = null;
         }
         hideAndUnloadControllerIcons();
         mProfileBox = null;
         mFloaterTextClass = null;
         mHpText = null;
         mManaText = null;
         mBusterRoot = null;
         mBasicCurrencyText = null;
         mPremiumCurrencyText = null;
         mLevelText = null;
         mXpObject = null;
         mXpText = null;
         mTeamLootMC.destroy();
         mTeamLootMC = null;
         mLootTween = null;
         mLootMouseArea = null;
         mBusterLabel = null;
         mBusterLabelOver = null;
         mSwfAsset = null;
         if(mLootLossPopup)
         {
            mLootLossPopup.destroy();
         }
         mLootLossPopup = null;
         if(mInfiniteExitPopup)
         {
            mInfiniteExitPopup.destroy();
         }
         mInfiniteExitPopup = null;
      }
      
      public function get offScreenPlayerManager() : UIOffScreenPlayerManager
      {
         return mOffScreenPlayerManager;
      }
      
      public function showBustSign() : void
      {
         mUIRoot.UI_buster_glow.visible = true;
         mBusterGlowMc.play(1,false,function():void
         {
            mUIRoot.UI_buster_glow.visible = false;
            mUIRoot.UI_buster_active.visible = true;
            mUIRoot.UI_buster.buster_activated_glow.visible = true;
            if(mBusterPulseMc && !mBusterPulseMc.isPlaying)
            {
               mBusterPulseMc.play(0,true);
            }
         });
      }
      
      public function hideBustSign() : void
      {
         mUIRoot.UI_buster_glow.visible = false;
         mUIRoot.UI_buster_active.visible = false;
         mUIRoot.UI_buster.buster_activated_glow.visible = false;
         if(mBusterPulseMc)
         {
            mBusterPulseMc.stop();
         }
      }
      
      public function handleBusterBarClickEvent() : void
      {
         if(mHeroOwner && mHeroOwner.dungeonBusterPoints >= mHeroOwner.maxBusterPoints)
         {
            mEventComponent.dispatchEvent(new DungeonBusterControlActivatedEvent());
         }
      }
      
      public function setWeaponHighlight(currentWeaponIndex:int) : void
      {
         for each(var _loc2_:UIButton in mWeaponButtons)
         {
            _loc2_.root.selectionFrame.visible = false;
         }
         mWeaponButtons[currentWeaponIndex].root.selectionFrame.visible = true;
      }
      
      public function hideNotEnoughMana() : void
      {
         mUIRoot.UI_center_message.visible = false;
      }
      
      public function showNotEnoughMana() : void
      {
         mUIRoot.UI_center_message.visible = true;
         Locale.setText(mUIRoot.UI_center_message,"NOT_ENOUGH_MANA");
      }
      
      public function get chatLog() : UIChatLog
      {
         return mUIChatLog;
      }
      
      public function isInCooldown() : void
      {
         showText("IS_IN_COOLDOWN");
      }
      
      public function startCooldown(currentWeaponIndex:int, cooldownTime:Number) : void
      {
         mCooldowns[currentWeaponIndex].clip.visible = true;
         mCooldowns[currentWeaponIndex].playRate = 1 / cooldownTime * 4.1;
         mCooldowns[currentWeaponIndex].play();
         mWeaponButtons[currentWeaponIndex].root.graphic.alpha = 0.5;
      }
      
      public function stopCooldown(currentWeaponIndex:int) : void
      {
         mCooldowns[currentWeaponIndex].stop();
         mCooldowns[currentWeaponIndex].clip.visible = false;
         mWeaponButtons[currentWeaponIndex].root.graphic.alpha = 1;
         mDBFacade.mTween.tweenMaxTo(mWeaponButtons[currentWeaponIndex].root.graphic,0.25,{
            "scaleX":1.25,
            "scaleY":1.25,
            "tint":16777215,
            "onComplete":function():void
            {
               mDBFacade.mTween.tweenMaxTo(mWeaponButtons[currentWeaponIndex].root.graphic,0.25,{
                  "scaleX":1,
                  "scaleY":1,
                  "removeTint":true
               });
            }
         });
      }
      
      public function startConsumableCooldown(currentWeaponIndex:int, cooldownTime:Number) : void
      {
         mConsumableCooldowns[currentWeaponIndex].clip.visible = true;
         mConsumableCooldowns[currentWeaponIndex].playRate = 1 / cooldownTime * 4.1;
         mConsumableCooldowns[currentWeaponIndex].play();
         mConsumableWeaponButtons[currentWeaponIndex].root.graphic.alpha = 0.5;
      }
      
      public function stopConsumableCooldown(currentWeaponIndex:int) : void
      {
         mConsumableCooldowns[currentWeaponIndex].stop();
         mConsumableCooldowns[currentWeaponIndex].clip.visible = false;
         mConsumableWeaponButtons[currentWeaponIndex].root.graphic.alpha = 1;
         mDBFacade.mTween.tweenMaxTo(mConsumableWeaponButtons[currentWeaponIndex].root.graphic,0.25,{
            "scaleX":1.25,
            "scaleY":1.25,
            "tint":16777215,
            "onComplete":function():void
            {
               mDBFacade.mTween.tweenMaxTo(mConsumableWeaponButtons[currentWeaponIndex].root.graphic,0.25,{
                  "scaleX":1,
                  "scaleY":1,
                  "removeTint":true
               });
            }
         });
      }
      
      public function decrementConsumableCount(slot:uint) : void
      {
         TextUtil.setText(mConsumableWeaponButtons[slot].root.quantity,String(int(mConsumableWeaponButtons[slot].root.quantity.text) - 1));
      }
      
      public function totalConsumableCountReached(slot:uint) : void
      {
         mConsumableWeaponButtons[slot].enabled = false;
         mConsumableWeaponButtons[slot].root.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
      }
      
      public function showText(localeTextName:String) : void
      {
         if(mUIRoot.UI_center_message.visible == false)
         {
            mUIRoot.UI_center_message.visible = true;
            Locale.setText(mUIRoot.UI_center_message,localeTextName);
            mLogicalWorkComponent.doLater(0.35,function():void
            {
               mUIRoot.UI_center_message.visible = false;
            });
         }
         else
         {
            Locale.setText(mUIRoot.UI_center_message,localeTextName);
         }
      }
      
      public function get teamLootDestination() : Vector3D
      {
         return mTeamLootDestination;
      }
      
      public function get profileDestination() : Vector3D
      {
         return mProfileDestination;
      }
      
      public function get coinsDestination() : Vector3D
      {
         return mCoinsDestination;
      }
      
      public function get cashDestination() : Vector3D
      {
         return mCashDestination;
      }
      
      public function get expDestination() : Vector3D
      {
         return mExpDestination;
      }
      
      public function get crowdDestination() : Vector3D
      {
         return mCrowdDestination;
      }
      
      public function showBuffDisplay(buffGO:BuffGameObject) : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(buffGO.buffData.IconSwf),function(param1:SwfAsset):void
         {
            if(buffGO.isDestroyed)
            {
               return;
            }
            var _loc6_:Class = param1.getClass(buffGO.buffData.IconName);
            var _loc5_:MovieClip = new _loc6_() as MovieClip;
            var _loc2_:Class = mSwfAsset.getClass("buff_cooldown_icon");
            var _loc4_:MovieClip = new _loc2_() as MovieClip;
            var _loc7_:MovieClipRenderer = new MovieClipRenderer(mDBFacade,_loc4_.cooldown);
            _loc5_.alpha = 0.75;
            _loc5_.scaleX = _loc5_.scaleY = 0.75;
            _loc4_.graphic.addChild(_loc5_);
            mRoot.addChild(_loc4_);
            var _loc3_:UIButton = new UIButton(mDBFacade,_loc4_);
            _loc3_.tooltip = _loc4_.tooltip;
            TextUtil.setText(_loc4_.tooltip.title_label,GameMasterLocale.getGameMasterSubString("BUFF_NAME",buffGO.buffData.Constant));
            TextUtil.setText(_loc4_.tooltip.description_label,GameMasterLocale.getGameMasterSubString("BUFF_DESCRIPTION",buffGO.buffData.Constant) + buffGO.buffData.getStacksDescription(buffGO.instanceCount));
            mBuffIconButtons.push(_loc3_);
            mBuffs.push(buffGO);
            mBuffCooldowns.push(_loc7_);
            TextUtil.setText(_loc4_.quantity,String(buffGO.instanceCount));
            resetBuffButtonPositions();
            startBuffCooldown(mBuffIconButtons.length - 1,buffGO.buffData.Duration);
         });
      }
      
      public function startBuffCooldown(currentBuffIndex:int, cooldownTime:Number) : void
      {
         mBuffCooldowns[currentBuffIndex].playRate = 1 / cooldownTime * 4.1;
         mBuffCooldowns[currentBuffIndex].play();
      }
      
      public function updateBuffDisplay(gameClock:GameClock) : void
      {
         var _loc3_:int = 0;
         var _loc2_:BuffGameObject = null;
         _loc3_ = 0;
         while(_loc3_ < mBuffs.length)
         {
            _loc2_ = mBuffs[_loc3_];
            if(_loc2_.isDestroyed)
            {
               mRoot.removeChild(mBuffIconButtons[_loc3_].root);
               mBuffIconButtons[_loc3_].destroy();
               mBuffCooldowns[_loc3_].destroy();
               mBuffs.splice(_loc3_,1);
               mBuffIconButtons.splice(_loc3_,1);
               mBuffCooldowns.splice(_loc3_,1);
            }
            _loc3_++;
         }
      }
      
      public function updateBuffInstance(updatedBuffGO:BuffGameObject) : void
      {
         var _loc2_:BuffGameObject = null;
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < mBuffs.length)
         {
            _loc2_ = mBuffs[_loc3_];
            if(_loc2_ == updatedBuffGO)
            {
               TextUtil.setText(mBuffIconButtons[_loc3_].root.quantity,String(_loc2_.instanceCount));
               TextUtil.setText(mBuffIconButtons[_loc3_].root.tooltip.description_label,GameMasterLocale.getGameMasterSubString("BUFF_DESCRIPTION",_loc2_.buffData.Constant) + _loc2_.buffData.getStacksDescription(_loc2_.instanceCount));
               startBuffCooldown(_loc3_,_loc2_.buffData.Duration);
               return;
            }
            _loc3_++;
         }
      }
      
      public function resetBuffButtonPositions() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < mBuffs.length)
         {
            if(mHudType == 1)
            {
               mBuffIconButtons[_loc1_].root.x = 455 + _loc1_ * 63;
               mBuffIconButtons[_loc1_].root.y = 865;
            }
            else
            {
               mBuffIconButtons[_loc1_].root.x = 424 + _loc1_ * 63;
               mBuffIconButtons[_loc1_].root.y = 980;
            }
            _loc1_++;
         }
      }
      
      public function refreshHUD() : void
      {
         this.setupUI(mSwfAsset,mHudType);
      }
      
      private function onSteamInputGlyphsChanged(event:Event) : void
      {
         if(mDBFacade.steamInputManager.isSteamInputReady)
         {
            syncControllerPrompts();
         }
      }
      
      public function handleMenuButtonPressed(index:uint) : void
      {
         if(index == 0)
         {
            if(mSuppressNextExitMenuToggle)
            {
               mSuppressNextExitMenuToggle = false;
               return;
            }
            if(mSettingsPopup)
            {
               return;
            }
            closeButtonReleaseCallback();
         }
         else if(index == 1)
         {
            toggleSettingsPopup();
         }
         else if(index == 2)
         {
            mUIChatLog.tryToggleChatLog();
         }
         else if(index == 3)
         {
            if(mDBFacade.steamInputManager.usesSteamOnScreenKeyboard)
            {
               mUIChatLog.focusChatInput();
            }
         }
      }
      
      public function clearExitMenu() : void
      {
         mLootLossPopup = null;
         mInfiniteExitPopup = null;
      }
      
      public function suppressNextExitMenuToggle() : void
      {
         mSuppressNextExitMenuToggle = mDBFacade.inputManager.check(27) || mDBFacade.steamInputManager.pressedAction("menu_cancel");
      }
   }
}

