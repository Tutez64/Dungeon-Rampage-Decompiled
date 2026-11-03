package UI.Hud.StarlingConverted
{
   import Account.BoosterInfo;
   import Account.CurrencyUpdatedAccountEvent;
   import Actor.Buffs.BuffGameObject;
   import Actor.Buffs.BuffHandler;
   import Actor.Player.Input.DungeonBusterControlActivatedEvent;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.ImageAsset;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Render.Tweens.TweenHandle;
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedImage;
   import Brain.Starling.SwfConverter.BakedPages;
   import Brain.Utils.TextUtil;
   import Brain.Utils.Timers;
   import Brain.WorkLoop.LayerWorkComponent;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
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
   import GameMasterDictionary.GMSkin;
   import Input.KeyBindings.KeyBindings;
   import Settings.SettingsPopup;
   import SteamInput.OnSteamInputButtonReleasedEvent;
   import SteamInput.SteamInputGlyphsChangedEvent;
   import UI.InfiniteIsland.II_UIExitDungeonPopUp;
   import UI.Popup.UILootLossPopup;
   import UI.UIChatLog;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class StarlingHud implements IGameHud
   {
      
      private static var sCurrent:StarlingHud;
      
      private static var sErrorCount:uint = 0;
      
      private static var sFirstError:String;
      
      private static var sFirstErrorStack:String;
      
      private static var sLastError:String;
      
      private var mFacade:DBFacade;
      
      private var mHeroOwner:HeroGameObjectOwner;
      
      private var mRoot:starling.display.Sprite;
      
      private var mView:ArtView;
      
      private var mSettingsPopup:SettingsPopup;
      
      private var mInput:StarlingInput;
      
      private var mCut:StarlingWorldCut;
      
      private var mTicker:HudTicker;
      
      private var mWork:LogicalWorkComponent;
      
      private var mFadeWork:LayerWorkComponent;
      
      private var mEvents:EventComponent;
      
      private var mAssets:AssetLoadingComponent;
      
      private var mChatHolder:flash.display.Sprite;
      
      private var mChat:UIChatLog;
      
      private var mChatClip:MovieClip;
      
      private var mChatContainer:MovieClip;
      
      private var mChatPrompt:StarlingChatPrompt;
      
      private var mChatPromptFailed:Boolean;
      
      private var mTooltips:Vector.<StarlingTooltip> = new Vector.<StarlingTooltip>(0);
      
      private var mHp:StarlingBar;
      
      private var mInvulnerable:StarlingBar;
      
      private var mMana:StarlingBar;
      
      private var mXp:StarlingBar;
      
      private var mHealthFull:StarlingFullMessage;
      
      private var mManaFull:StarlingFullMessage;
      
      private var mProfile:DisplayObject;
      
      private var mXpRoot:DisplayObject;
      
      private var mCenterMessage:ArtDisplay;
      
      private var mProfileRest:Number;
      
      private var mXpRest:Number;
      
      private var mProfileBulging:Boolean;
      
      private var mXpBulging:Boolean;
      
      private var mXpInitial:Boolean;
      
      private var mShown:Boolean;
      
      private var mDestroyed:Boolean;
      
      private var mGeneration:uint;
      
      private var mHudType:uint;
      
      private var mBuiltHudType:int = -1;
      
      private var mWeapons:Vector.<StarlingHudSlot> = new Vector.<StarlingHudSlot>(0);
      
      private var mHighlightIndex:int = -1;
      
      private var mConsumables:Vector.<StarlingHudSlot> = new Vector.<StarlingHudSlot>(0);
      
      private var mCooldownStarts:Vector.<Number> = new <Number>[0,0,0,0,0];
      
      private var mCooldownDurations:Vector.<Number> = new <Number>[0,0,0,0,0];
      
      private var mBoosterTimer:Timer;
      
      private var mGlyphs:Dictionary = new Dictionary();
      
      private var mGlyphGeneration:uint;
      
      private var mGlyphTextures:Dictionary = new Dictionary();
      
      private var mStarlingGlyphs:Dictionary = new Dictionary();
      
      private var mGlyphPaths:Dictionary = new Dictionary();
      
      private var mGlyphPixels:Dictionary = new Dictionary();
      
      private var mGrayGlyphPixels:Dictionary = new Dictionary();
      
      private var mGlyphTask:Task;
      
      private var mPortrait:BakedImage;
      
      private var mPortraitArt:ArtNode;
      
      private var mPortraitKey:String;
      
      private var mPortraitSource:MovieClip;
      
      private var mPortraitRetry:Function;
      
      private var mLootLossPopup:UILootLossPopup;
      
      private var mInfiniteExitPopup:II_UIExitDungeonPopUp;
      
      private var mSuppressNextExitMenuToggle:Boolean;
      
      private var mPet:NPCGameObject;
      
      private var mBuffs:Vector.<BuffGameObject> = new Vector.<BuffGameObject>(0);
      
      private var mDestinations:Vector.<Vector3D>;
      
      private var mBuster:StarlingBar;
      
      private var mBusterButton:StarlingButton;
      
      private var mBusterBanner:TimelineView;
      
      private var mBusterPulse:TimelineView;
      
      private var mBusterMax:uint = 4294967295;
      
      private var mBusterReady:Boolean;
      
      private var mStacks:ArtView;
      
      private var mStacksShown:Boolean = true;
      
      private var mStackButtons:Vector.<StarlingButton> = new Vector.<StarlingButton>(0);
      
      private var mTeamLoot:ArtView;
      
      private var mLootTask:Task;
      
      private var mLootTween:TweenHandle;
      
      private var mLootGeneration:uint;
      
      private var mLootMoving:Boolean;
      
      private var mPetPortrait:StarlingPetPortrait;
      
      private var mPetModel:MovieClip;
      
      private var mOffScreen:StarlingOffScreenManager;
      
      private var mBuffViews:Vector.<StarlingBuff> = new Vector.<StarlingBuff>(0);
      
      private var mModifierButtons:Vector.<StarlingButton> = new Vector.<StarlingButton>(0);
      
      private var mModifierModels:Vector.<MovieClip> = new Vector.<MovieClip>(0);
      
      private var mModifierIcons:Vector.<StarlingHudIcon> = new Vector.<StarlingHudIcon>(0);
      
      private var mModifierWidths:Vector.<Number> = new Vector.<Number>(0);
      
      private var mBusterPromptOffset:Number;
      
      private var mUiHidden:Boolean;
      
      private var mUiHideEvents:EventComponent;
      
      public function StarlingHud(facade:DBFacade)
      {
         super();
         try
         {
            mFacade = facade;
            sCurrent = this;
            mRoot = new StarlingHudRoot();
            mRoot.visible = false;
            mRoot.touchable = false;
            HudTransform.sync(facade,mRoot);
            mTicker = new HudTicker(facade.gameClock);
            mTicker.onError = failed;
            mWork = new LogicalWorkComponent(facade,"StarlingHud");
            mEvents = new EventComponent(facade);
            mUiHideEvents = new EventComponent(facade);
            mUiHideEvents.addListener("UI_HIDE_TOGGLE_CHANGED",uiHideChanged);
            mUiHidden = facade.uiHideToggle != null && facade.uiHideToggle.hidden;
            if(facade.keyBindings != null)
            {
               facade.keyBindings.addChangeListener(keyBindingsChanged);
            }
            if(facade.settingsModel != null)
            {
               facade.settingsModel.addChangeListener(settingChanged);
            }
            mAssets = new AssetLoadingComponent(facade);
            mHudType = uint(facade.settingsModel.getValue("hudStyle")) == 1 ? 1 : 0;
            setDestinations();
            mWork.doEveryFrame(update);
            mFadeWork = new LayerWorkComponent(facade,"StarlingHud.fade");
            mFadeWork.doEveryFrame(syncFade);
            HudArt.onRebaked(rebuild);
            HudArt.onReady(artReady);
         }
         catch(error:*)
         {
            HudArt.fatal("HUD construction failed: " + String(error),true);
         }
      }
      
      private static function drawn(display:DisplayObject) : Boolean
      {
         while(display != null)
         {
            if(!display.visible || display.alpha <= 0)
            {
               return false;
            }
            display = display.parent;
         }
         return true;
      }
      
      internal static function giveUp() : void
      {
         if(sCurrent != null)
         {
            sCurrent.hide();
         }
      }
      
      public static function reportError(error:Error) : void
      {
         if(error is HudFatalError)
         {
            HudArt.fatal(error.message);
         }
         sErrorCount = sErrorCount + 1;
         sLastError = error.errorID + " " + error.message;
         if(sFirstError == null)
         {
            sFirstError = sLastError;
            sFirstErrorStack = error.getStackTrace();
         }
      }
      
      public static function get errorCount() : uint
      {
         return sErrorCount;
      }
      
      public static function get firstError() : String
      {
         return sFirstError;
      }
      
      public static function get firstErrorStack() : String
      {
         return sFirstErrorStack;
      }
      
      public static function get lastError() : String
      {
         return sLastError;
      }
      
      internal static function disposeResource(resource:Object, method:String = "dispose") : void
      {
         try
         {
            if(resource != null)
            {
               resource[method]();
            }
         }
         catch(error:Error)
         {
            reportError(error);
         }
      }
      
      private static function placeGlyph(bitmap:Bitmap, owner:MovieClip, position:Vector3D, scale:Point) : void
      {
         bitmap.x = position.x;
         bitmap.y = position.y;
         bitmap.width = scale.x;
         bitmap.height = scale.y;
         owner.addChild(bitmap);
      }
      
      private function artReady() : void
      {
         if(!mDestroyed)
         {
            refreshHUD();
         }
      }
      
      public function refreshHUD() : void
      {
         mHighlightIndex = -1;
         rebuild();
      }
      
      private function rebuild() : void
      {
         var generation:uint;
         var type:uint;
         try
         {
            if(mDestroyed || !HudArt.ready)
            {
               return;
            }
            generation = ++mGeneration;
            type = mHudType;
            HudArt.convertLayout(type,function(param1:ArtNode):void
            {
               try
               {
                  if(mDestroyed || generation != mGeneration)
                  {
                     return;
                  }
                  build(param1);
               }
               catch(error:*)
               {
                  HudArt.fatal("HUD build failed: " + String(error),true);
               }
            });
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function build(art:ArtNode) : void
      {
         var _loc3_:String = null;
         var _loc9_:StarlingButton = null;
         var _loc10_:StarlingBuff = null;
         var _loc2_:BuffGameObject = null;
         var _loc4_:int = 0;
         HudTransform.sync(mFacade,mRoot);
         if(art == null)
         {
            throw new Error("HUD layout unavailable");
         }
         var _loc5_:Boolean = mBuiltHudType != int(mHudType);
         var _loc6_:ArtView = ArtView.build(art,mTicker);
         mBuiltHudType = int(mHudType);
         disposeView();
         mView = _loc6_;
         visible("UI_XP.xp_points",false);
         visible("UI_XP.xp_level_title",false);
         ArtDisplay(mView.root).advanceHiddenTimelines(true);
         mRoot.addChild(mView.root);
         mFacade.starlingLayerManager.hudLayer.addChild(mRoot);
         mRoot.visible = mShown && !mUiHidden;
         mTicker.attachStage(mRoot.visible ? mFacade.stageRef : null);
         mProfile = node("UI_profile");
         mXpRoot = node("UI_XP");
         mCenterMessage = node("UI_center_message") as ArtDisplay;
         mProfileRest = mProfile != null ? mProfile.scaleX : 1;
         mXpRest = mXpRoot != null ? mXpRoot.scaleX : 1;
         mHp = new StarlingBar(node("UI_profile.HP_bar"),node("UI_profile.HP_bar_delta"),mTicker);
         mInvulnerable = new StarlingBar(node("UI_profile.HP_bar_invincible"),null,mTicker);
         mMana = new StarlingBar(node("UI_profile.mana_bar"),node("UI_profile.mana_bar_delta"),mTicker);
         mXp = new StarlingBar(node("UI_XP.xp_bar"),node("UI_XP.xp_bar_delta"),mTicker);
         visible("UI_XP.xp_bar_delta",true);
         var _loc7_:DisplayObject = node("UI_XP.xp_bar_delta");
         if(_loc7_ != null)
         {
            _loc7_.alpha = 0.3;
         }
         mHealthFull = new StarlingFullMessage(mFacade,node("UI_profile.HP_full_text"),mTicker);
         mManaFull = new StarlingFullMessage(mFacade,node("UI_profile.mana_full_text"),mTicker);
         mHealthFull.changed = mManaFull.changed = invalidateBounds;
         mInput = new StarlingInput(mFacade);
         mInput.onError = failed;
         var _loc8_:StarlingButton = new StarlingButton(mView,"close",mRoot);
         _loc8_.releaseCallback = closeButtonReleased;
         mInput.add(_loc8_);
         buildSlots();
         mBuster = new StarlingBar(node("UI_buster.buster_bar"),null,mTicker);
         mBusterButton = new StarlingButton(mView,"UI_buster_active.buster_activated",mRoot);
         mBusterButton.releaseCallback = handleBusterBarClickEvent;
         mInput.add(mBusterButton);
         mBusterBanner = node("UI_buster_glow") as TimelineView;
         mBusterPulse = node("UI_buster.buster_activated_glow") as TimelineView;
         if(mBusterBanner != null)
         {
            mBusterBanner.stop();
            mBusterBanner.stageRate = false;
         }
         if(mBusterPulse != null)
         {
            mBusterPulse.stop();
         }
         mStacks = ArtView.build(HudArt.art("stacks_hud"),mTicker);
         mStacks.root.x = 480;
         mStacks.root.y = 55;
         mRoot.addChild(mStacks.root);
         for each(_loc3_ in new <String>["potion_slot_A","potion_slot_B","potion_slot_C"])
         {
            _loc9_ = new StarlingButton(mStacks,_loc3_,mRoot);
            _loc9_.enabled = false;
            mStackButtons.push(_loc9_);
         }
         addHover("UI_profile",profileOver,profileOut);
         addHover("UI_XP",xpOver,xpOut);
         buildFlashParts(_loc8_);
         hideDeferredParts();
         hideBuster();
         updateStacks();
         _loc4_ = 0;
         while(_loc4_ < mBuffViews.length)
         {
            _loc10_ = mBuffViews[_loc4_];
            if(_loc10_.art != HudArt.art("buff_cooldown_icon"))
            {
               mBuffViews[_loc4_] = _loc10_.rebuild(mFacade,mTicker,mInput,mRoot);
            }
            else
            {
               _loc10_.rebindInput(mInput);
            }
            _loc4_++;
         }
         for each(_loc2_ in mBuffs)
         {
            if(buffView(_loc2_) == null)
            {
               createBuff(_loc2_);
            }
         }
         if(_loc5_)
         {
            resetBuffButtonPositions();
         }
         profileOut();
         xpOut();
         visible("UI_profile.HP_bar_invincible",false);
         mCut = new StarlingWorldCut(mFacade.sceneGraphManager.worldLayerGroup,mFacade.scalingRoot,mRoot,mFacade.sceneGraphManager.getLayer(42));
         bindBounds(mRoot);
         mInput.boundsChanged = invalidateBounds;
         applyCamera();
         setDestinations();
         setCurrency(mFacade.dbAccountInfo.basicCurrency,mFacade.dbAccountInfo.premiumCurrency);
         if(mHeroOwner != null)
         {
            populateHero();
         }
         restoreSlotCooldowns();
         if(mShown)
         {
            show();
         }
         else
         {
            hide();
         }
      }
      
      private function buildFlashParts(close:StarlingButton) : void
      {
         var _loc2_:Class = HudArt.swfClass(mHudType == 1 ? "ui_hud" : "ui_hud_old");
         var _loc3_:MovieClip = new _loc2_() as MovieClip;
         mChatHolder = new flash.display.Sprite();
         mChatHolder.name = "StarlingHud.chat";
         mChatHolder.transform.matrix = _loc3_.transform.matrix;
         mChatClip = _loc3_.UI_chat;
         mChatContainer = _loc3_.chatLogContainer;
         mChatHolder.addChild(mChatContainer);
         mChatHolder.addChild(mChatClip);
         mChat = new UIChatLog(mFacade,mChatContainer,mChatClip,mChatClip.log_btn,mChatClip.chat_btn);
         if(mHudType != 1)
         {
            mChat.textSizeModifier = 1.18;
         }
         mChat.disable();
         mConsumables[0].consumableTooltip = _loc3_.consumable_tooltip01;
         mConsumables[1].consumableTooltip = _loc3_.consumable_tooltip02;
         mPetModel = new MovieClip();
         mPetModel.pet = _loc3_.pet;
         mPetModel.pet_none = _loc3_.hasOwnProperty("pet_none") ? _loc3_.pet_none : null;
         buildModifiers(_loc3_);
         visible("UI_currency_coin.coin.add_coin_button",false);
         visible("UI_currency_cash.cash.add_cash_button",false);
         buttonTooltip(_loc3_.close,close,mView,"close");
         HudArtConverter.stopTree(_loc3_);
         _loc3_.removeChildren();
         visible("UI_chat",false);
         visible("chatLogContainer",false);
         setAllKeyboardIconsVisibility(!mFacade.steamInputManager.wantsControllerPrompts);
         if(mFacade.steamInputManager.isSteamInputReady)
         {
            mGlyphTask = mWork.doLater(1,delayedControllerIcons);
         }
         syncChatPrompt();
      }
      
      private function syncChatPrompt() : void
      {
         var _loc1_:Boolean = mChat != null && mFacade.featureFlags.getFlagValue("starling-chat-prompt");
         if(_loc1_ == (mChatPrompt != null))
         {
            return;
         }
         if(_loc1_)
         {
            if(mChatPromptFailed)
            {
               return;
            }
            try
            {
               mChatPrompt = new StarlingChatPrompt(mFacade,mTicker,mRoot,mInput,mChatHolder,mChatClip,HudArt.swfClass(mHudType == 1 ? "ui_hud" : "ui_hud_old"),mChat,Locale.getString("DEFAULT_CHAT_PROMPT"),mChat.promptColor,mHudType,invalidateBounds,chatButtonsReady);
            }
            catch(error:Error)
            {
               mChatPromptFailed = true;
               failed(error);
               return;
            }
            mChat.starlingPrompt = mChatPrompt.show;
            if(mChatPrompt.logButton != null)
            {
               chatButtonsReady();
            }
         }
         else
         {
            if(mChat != null)
            {
               mChat.starlingPrompt = null;
            }
            disposeResource(mChatPrompt);
            mChatPrompt = null;
            invalidateBounds();
            chatButtonsReady();
         }
      }
      
      private function chatButtonsReady() : void
      {
         try
         {
            if(mGlyphTask == null && mFacade.steamInputManager.isSteamInputReady)
            {
               updateControllerIcons();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function buildSlots() : void
      {
         var _loc2_:int = 0;
         var _loc3_:StarlingHudSlot = null;
         var _loc1_:Vector.<String> = new <String>["UI_weapons.weapon_z","UI_weapons.weapon_x","UI_weapons.weapon_c","consumables_01","consumables_02"];
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = new StarlingHudSlot(mFacade,mTicker,mView,_loc1_[_loc2_],mRoot,_loc2_ < 3 ? _loc2_ : _loc2_ - 3,invalidateBounds);
            if(_loc2_ < 3)
            {
               mWeapons.push(_loc3_);
            }
            else
            {
               mConsumables.push(_loc3_);
            }
            mInput.add(_loc3_.button);
            _loc2_++;
         }
         visible("consumable_tooltip01",false);
         visible("consumable_tooltip02",false);
      }
      
      private function buttonTooltip(model:MovieClip, button:StarlingButton, view:ArtView, path:String = "") : void
      {
         if(!model.hasOwnProperty("tooltip") || !(model.tooltip is MovieClip))
         {
            return;
         }
         var _loc7_:MovieClip = model.tooltip;
         HudArtConverter.stopTree(_loc7_);
         var _loc6_:StarlingTooltip = new StarlingTooltip(mFacade,button.root,mRoot,_loc7_);
         mTooltips.push(_loc6_);
         button.rollOverCallback = _loc6_.rollOver;
         button.rollOutCallback = _loc6_.hide;
         var _loc5_:ArtDisplay = view.node(path.length > 0 ? path + ".tooltip" : "tooltip") as ArtDisplay;
         if(_loc5_ != null)
         {
            _loc5_.setHudVisibility(false);
         }
      }
      
      private function addHover(path:String, over:Function, out:Function) : void
      {
         var _loc4_:StarlingButton = new StarlingButton(mView,path,mRoot);
         _loc4_.rollOverCallback = over;
         _loc4_.rollOutCallback = out;
         mInput.add(_loc4_,false,true);
      }
      
      private function hideDeferredParts() : void
      {
         var _loc1_:String = null;
         var _loc2_:Vector.<String> = new <String>["UI_buster_active","UI_buster_glow","UI_buster_pulse","UI_team_loot","pet","pet_none","floor_modifier01","floor_modifier02","floor_modifier03","floor_modifier04","tooltip_modifier01","tooltip_modifier02","tooltip_modifier03","tooltip_modifier04","UI_center_message","UI_weapons.weapon_z.cooldown","UI_weapons.weapon_x.cooldown","UI_weapons.weapon_c.cooldown","UI_weapons.weapon_z.selectionFrame","UI_weapons.weapon_x.selectionFrame","UI_weapons.weapon_c.selectionFrame","consumables_01.cooldown","consumables_02.cooldown"];
         for each(_loc1_ in _loc2_)
         {
            visible(_loc1_,false);
         }
      }
      
      private function node(path:String) : DisplayObject
      {
         return mView != null ? mView.node(path) : null;
      }
      
      private function visible(path:String, value:Boolean) : void
      {
         var _loc3_:DisplayObject = node(path);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:Boolean = _loc3_.visible != value;
         if(_loc3_ is ArtDisplay)
         {
            ArtDisplay(_loc3_).setHudVisibility(value);
         }
         if(_loc3_.visible != value)
         {
            _loc3_.visible = value;
         }
         if(_loc4_)
         {
            invalidateBounds();
         }
      }
      
      private function text(path:String, value:String, baked:Boolean = false) : void
      {
         var _loc4_:StarlingText = node(path) as StarlingText;
         if(_loc4_ == null)
         {
            return;
         }
         if(_loc4_.text == value && (!baked || _loc4_.mode == "baked"))
         {
            return;
         }
         try
         {
            _loc4_.setContent(value,baked ? "baked" : "glyphs");
         }
         catch(error:Error)
         {
            failed(error);
         }
         if(drawn(_loc4_))
         {
            invalidateBounds();
         }
      }
      
      private function profileOver() : void
      {
         visible("UI_profile.HP_text",true);
         visible("UI_profile.mana_text",true);
      }
      
      private function profileOut() : void
      {
         var _loc1_:Boolean = mFacade.featureFlags.getFlagValue("want-numbered-hud");
         visible("UI_profile.HP_text",_loc1_);
         visible("UI_profile.mana_text",_loc1_);
      }
      
      private function xpOver() : void
      {
         visible("UI_XP.xp_points",true);
         visible("UI_XP.xp_level_title",false);
      }
      
      private function xpOut() : void
      {
         var _loc1_:Boolean = mFacade.featureFlags.getFlagValue("want-numbered-hud");
         visible("UI_XP.xp_points",_loc1_);
         visible("UI_XP.xp_level_title",!_loc1_);
      }
      
      public function initializeHud(heroOwner:HeroGameObjectOwner) : void
      {
         try
         {
            if(mDestroyed)
            {
               return;
            }
            if(HudTransform.sync(mFacade,mRoot))
            {
               invalidateBounds();
            }
            cancelPortrait();
            if(mHeroOwner != heroOwner)
            {
               clearCooldowns();
            }
            mHeroOwner = heroOwner;
            addListeners();
            show();
            mHighlightIndex = -1;
            if(mView != null && heroOwner != null)
            {
               populateHero();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function populateHero() : void
      {
         if(mChat != null)
         {
            mChat.heroOwner = mHeroOwner;
            if(mShown)
            {
               mChat.enable();
            }
         }
         visible("UI_profile.HP_bar_invincible",false);
         visible("UI_profile.HP_bar",true);
         setHp(mHeroOwner.hitPoints,mHeroOwner.maxHitPoints);
         setMana(mHeroOwner.manaPoints,mHeroOwner.maxManaPoints);
         setXp(mHeroOwner.experiencePoints);
         bulgeXpBar();
         bulgeProfileBox();
         profileOut();
         xpOut();
         refreshBonuses();
         scheduleBooster();
         text("label_floor",Locale.getString("UI_HUD_FLOOR_LABEL") + mHeroOwner.distributedDungeonFloor.getCurrentFloorNum().toString(),true);
         loadPortrait();
         initializeBuster();
         refreshKeyboardLabels();
         updatePet();
         updateOffScreen();
         setDungeonModifiers();
         updateWeapons();
         updateConsumables();
         var _loc2_:int = mHeroOwner.currentWeaponIndex;
         var _loc1_:Boolean = _loc2_ >= 0 && _loc2_ < mHeroOwner.weaponControllers.length && mHeroOwner.weaponControllers[_loc2_] != null && mHeroOwner.weaponControllers[_loc2_].weapon != null;
         setWeaponHighlight(mHighlightIndex >= 0 ? mHighlightIndex : (_loc1_ ? _loc2_ : -1));
      }
      
      private function addListeners() : void
      {
         mEvents.removeAllListeners();
         if(mHeroOwner == null)
         {
            return;
         }
         var _loc1_:uint = mHeroOwner.id;
         mEvents.addListener(GameObjectEvent.uniqueEvent("BusterPointEvent_BUSTER_POINTS_UPDATE",_loc1_),busterChanged);
         mEvents.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE",_loc1_),hpChanged);
         mEvents.addListener(GameObjectEvent.uniqueEvent("ManaEvent_MANA_UPDATE",_loc1_),manaChanged);
         mEvents.addListener(GameObjectEvent.uniqueEvent("ExperienceEvent_EXPERIENCE_UPDATE",_loc1_),xpChanged);
         mEvents.addListener(GameObjectEvent.uniqueEvent(BuffHandler.ACTOR_INVULNERABLE,_loc1_),invulnerabilityChanged);
         mEvents.addListener("CurrencyUpdatedAccountEvent",currencyChanged);
         mEvents.addListener("BONUS_XP_CHANGED_EVENT",bonusChanged);
         mEvents.addListener("BONUS_COIN_CHANGED_EVENT",bonusChanged);
         mEvents.addListener("BoostersParsedEvent_BOOSTERS_PARSED_UPDATE",bonusChanged);
         mEvents.addListener("UI_HUD_CHANGE_EVENT",layoutChanged);
         mEvents.addListener("OnSteamInputGlyphsChanged",controllerChanged);
         mEvents.addListener("ControllerConnectionChangedEvent",controllerChanged);
         mEvents.addListener("OnSteamInputButtonReleasedEvent",steamButtonReleased);
         setAllKeyboardIconsVisibility(!mFacade.steamInputManager.wantsControllerPrompts);
         if(mFacade.steamInputManager.isSteamInputReady && mGlyphTask == null && mView != null)
         {
            mGlyphTask = mWork.doLater(1,delayedControllerIcons);
         }
      }
      
      private function keyBindingsChanged(action:String) : void
      {
         try
         {
            if(!mDestroyed && !HudArt.fatalFailure)
            {
               refreshKeyboardLabels();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function settingChanged(id:String) : void
      {
         try
         {
            if(mDestroyed || HudArt.fatalFailure || id != "numbersOnBars" || mView == null || mHeroOwner == null)
            {
               return;
            }
            profileOut();
            xpOut();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function refreshKeyboardLabels() : void
      {
         var _loc1_:KeyBindings = mFacade.keyBindings;
         if(_loc1_ == null || mView == null)
         {
            return;
         }
         text("UI_weapons.weapon_z.label",_loc1_.displayNameFor("attackWeapon1"),true);
         text("UI_weapons.weapon_x.label",_loc1_.displayNameFor("attackWeapon2"),true);
         text("UI_weapons.weapon_c.label",_loc1_.displayNameFor("attackWeapon3"),true);
         text("consumables_01.label",_loc1_.displayNameFor("useConsumable1"),true);
         text("consumables_02.label",_loc1_.displayNameFor("useConsumable2"),true);
         if(mHeroOwner != null)
         {
            syncBusterPrompt();
         }
      }
      
      private function hpChanged(event:HpEvent) : void
      {
         try
         {
            setHp(event.hp,event.maxHp);
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function manaChanged(event:ManaEvent) : void
      {
         try
         {
            setMana(event.mana,event.maxMana);
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function xpChanged(event:ExperienceEvent) : void
      {
         try
         {
            setXp(event.experience);
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function currencyChanged(event:CurrencyUpdatedAccountEvent) : void
      {
         try
         {
            setCurrency(event.basicCurrency,event.premiumCurrency);
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function bonusChanged(event:Event) : void
      {
         try
         {
            refreshBonuses();
            scheduleBooster();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function controllerChanged(event:Event) : void
      {
         try
         {
            if(event is SteamInputGlyphsChangedEvent && !mFacade.steamInputManager.isSteamInputReady)
            {
               return;
            }
            updateControllerIcons();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function layoutChanged(event:UIHudChangeEvent) : void
      {
         try
         {
            mHudType = event.hudType == 1 ? 1 : 0;
            refreshHUD();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function invulnerabilityChanged(event:ActorInvulnerableEvent) : void
      {
         try
         {
            if(mHp == null)
            {
               return;
            }
            if(event.mIsInvulnerable)
            {
               mInvulnerable.value = mHp.value;
            }
            visible("UI_profile.HP_bar_invincible",event.mIsInvulnerable);
            visible("UI_profile.HP_bar",!event.mIsInvulnerable);
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function setHp(current:uint, max:uint) : void
      {
         try
         {
            if(mHp == null)
            {
               return;
            }
            mHp.value = mInvulnerable.value = max > 0 ? current / max : 0;
            text("UI_profile.HP_text",current.toString() + " / " + max.toString());
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function setMana(current:uint, max:uint) : void
      {
         try
         {
            if(mMana == null)
            {
               return;
            }
            mMana.value = max > 0 ? current / max : 0;
            text("UI_profile.mana_text",current.toString() + " / " + max.toString());
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function setXp(xp:uint) : void
      {
         var _loc4_:uint = 0;
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         try
         {
            if(mXp == null || mHeroOwner == null)
            {
               return;
            }
            _loc4_ = uint(mHeroOwner.gMHero.getLevelIndex(xp,mHeroOwner.ascensionLevel));
            _loc2_ = uint(_loc4_ > 0 ? mHeroOwner.gMHero.getExpFromIndex(_loc4_ - 1) : 0);
            _loc3_ = mHeroOwner.gMHero.getExpFromIndex(_loc4_);
            mXp.value = _loc3_ > _loc2_ ? (xp - _loc2_) / (_loc3_ - _loc2_) : 0;
            text("UI_XP.xp_level",mHeroOwner.level.toString());
            text("UI_XP.xp_points",xp.toString() + " / " + _loc3_.toString());
            if(!mXpInitial)
            {
               mXpInitial = true;
               bulgeXpBar();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function setCurrency(basicCurrency:int, premiumCurrency:int) : void
      {
         try
         {
            setBasicCurrency(basicCurrency);
            setPremiumCurrency(premiumCurrency);
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function setBasicCurrency(basicCurrency:int) : void
      {
         try
         {
            text("UI_currency_coin.game_currency_text",basicCurrency.toString());
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function setPremiumCurrency(premiumCurrency:int) : void
      {
         try
         {
            text("UI_currency_cash.cash_text",premiumCurrency.toString());
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function refreshBonuses() : void
      {
         if(mView == null)
         {
            return;
         }
         var _loc3_:BoosterInfo = mFacade.dbAccountInfo.inventoryInfo.findHighestBoosterXP();
         var _loc4_:BoosterInfo = mFacade.dbAccountInfo.inventoryInfo.findHighestBoosterGold();
         var _loc1_:Boolean = mFacade.accountBonus.isXPBonusActive;
         var _loc2_:Boolean = mFacade.accountBonus.isCoinBonusActive;
         visible("UI_XP.doublexp_text",_loc1_ || _loc3_ != null && _loc3_.BuffInfo.Exp > 1);
         visible("UI_currency_coin.doublecoin_text",_loc2_ || _loc4_ != null && _loc4_.BuffInfo.Gold > 1);
         if(_loc1_)
         {
            text("UI_XP.doublexp_text",mFacade.accountBonus.xpBonusText,true);
         }
         else if(_loc3_ != null && _loc3_.BuffInfo.Exp > 1)
         {
            text("UI_XP.doublexp_text",_loc3_.BuffInfo.Exp + Locale.getString("BOOSTER_XP"),true);
         }
         if(_loc2_)
         {
            text("UI_currency_coin.doublecoin_text",mFacade.accountBonus.coinBonusText,true);
         }
         else if(_loc4_ != null && _loc4_.BuffInfo.Gold > 1)
         {
            text("UI_currency_coin.doublecoin_text",_loc4_.BuffInfo.Gold + Locale.getString("BOOSTER_GOLD"),true);
         }
      }
      
      private function stopBooster() : void
      {
         if(mBoosterTimer == null)
         {
            return;
         }
         mBoosterTimer.stop();
         mBoosterTimer.removeEventListener("timer",boosterExpired);
         mBoosterTimer = null;
      }
      
      private function scheduleBooster() : void
      {
         stopBooster();
         var _loc1_:int = mFacade.dbAccountInfo.inventoryInfo.timeTillNextBoosterExpire();
         if(_loc1_ >= 0 && mHeroOwner != null)
         {
            mBoosterTimer = Timers.create(_loc1_,0,"StarlingHud.mBoosterTimer");
            mBoosterTimer.addEventListener("timer",boosterExpired);
            mBoosterTimer.start();
         }
      }
      
      private function boosterExpired(event:TimerEvent) : void
      {
         try
         {
            refreshBonuses();
            scheduleBooster();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function loadPortrait() : void
      {
         var skin:GMSkin;
         var avatar:DisplayObjectContainer;
         var portraitPath:String;
         var pixelScale:Number;
         var key:String;
         var known:ArtNode;
         var generation:uint;
         var hero:HeroGameObjectOwner;
         cancelPortrait();
         if(mPortrait != null)
         {
            mPortrait.removeFromParent(true);
         }
         mPortrait = null;
         skin = mHeroOwner.gmSkin;
         if(skin == null)
         {
            return;
         }
         avatar = (node("avatar") || node("UI_profile.avatar")) as DisplayObjectContainer;
         if(avatar == null)
         {
            return;
         }
         portraitPath = node("avatar") != null ? "avatar" : "UI_profile.avatar";
         pixelScale = BakeScale.forArt(mView.artNode(""),portraitPath) * HudArt.pixelScale;
         key = skin.UISwfFilepath + "|" + skin.IconName + "|" + BakedPages.scaleKey(pixelScale);
         mPortraitKey = key;
         known = HudArt.content("hudStarlingPortrait|" + key);
         if(known != null)
         {
            mPortraitArt = known;
            known.retainView();
            attachPortrait(known.cell);
            return;
         }
         generation = mGeneration;
         hero = mHeroOwner;
         HudArt.loadRuntimeSwf(mAssets,skin.UISwfFilepath,skin.IconName,function(param1:SwfAsset):void
         {
            var definition:Class;
            var asset:SwfAsset = param1;
            if(mDestroyed || generation != mGeneration || hero != mHeroOwner || key != mPortraitKey)
            {
               return;
            }
            definition = HudIconBake.symbol(asset,skin.UISwfFilepath,skin.IconName);
            mPortraitSource = new definition() as MovieClip;
            if(mPortraitSource == null)
            {
               HudArt.fatal("Required HUD portrait is not a MovieClip: " + skin.UISwfFilepath + " " + skin.IconName);
            }
            HudArtConverter.stopTree(mPortraitSource);
            attachPortrait(null);
            mPortraitRetry = function():Boolean
            {
               var _loc1_:BakedCell = null;
               try
               {
                  if(mPortraitSource == null)
                  {
                     return true;
                  }
                  if(Starling.current == null || !Starling.current.contextValid)
                  {
                     return false;
                  }
                  _loc1_ = HudArt.bakeContent("hudStarlingPortrait|" + key,mPortraitSource,pixelScale);
                  if(_loc1_ == null)
                  {
                     return false;
                  }
                  mPortraitArt = new ArtNode();
                  mPortraitArt.cell = mPortraitArt.hold(_loc1_,HudArt.pages);
                  HudArt.storeContent("hudStarlingPortrait|" + key,mPortraitArt);
                  mPortraitArt.retainView();
                  mPortraitSource = null;
                  if(mPortrait != null)
                  {
                     mPortrait.cell = _loc1_;
                  }
                  invalidateBounds();
                  return true;
               }
               catch(error:Error)
               {
                  failed(error);
                  var _loc7_:Boolean = true;
               }
               return _loc7_;
            };
            if(!mPortraitRetry())
            {
               mTicker.deferBake(mPortraitRetry);
            }
         });
      }
      
      private function attachPortrait(cell:BakedCell) : void
      {
         var _loc2_:DisplayObjectContainer = (node("avatar") || node("UI_profile.avatar")) as DisplayObjectContainer;
         if(_loc2_ == null)
         {
            return;
         }
         mPortrait = new BakedImage(cell);
         _loc2_.addChild(mPortrait);
         invalidateBounds();
      }
      
      private function cancelPortrait() : void
      {
         if(mPortraitArt != null)
         {
            mPortraitArt.releaseView();
         }
         mPortraitArt = null;
         if(mPortraitRetry != null)
         {
            mTicker.cancelBake(mPortraitRetry);
         }
         mPortraitRetry = null;
         mPortraitSource = null;
         mPortraitKey = null;
      }
      
      public function bulgeXpBar() : void
      {
         try
         {
            if(mXpRoot == null || !mFacade.featureFlags.getFlagValue("want-pickup-ui-pop"))
            {
               return;
            }
            mXpRoot.scaleX *= 1.08;
            mXpRoot.scaleY *= 1.08;
            mXpBulging = true;
            invalidateBounds();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function bulgeProfileBox() : void
      {
         try
         {
            if(mProfile == null || !mFacade.featureFlags.getFlagValue("want-pickup-ui-pop"))
            {
               return;
            }
            mProfile.scaleX *= 1.08;
            mProfile.scaleY *= 1.08;
            mProfileBulging = true;
            invalidateBounds();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function decayBulge(root:DisplayObject, rest:Number) : Boolean
      {
         var _loc3_:Number = (root.scaleX - rest) * 0.75;
         if(Math.abs(_loc3_) <= 0.01)
         {
            _loc3_ = 0;
         }
         root.scaleX = root.scaleY = rest + _loc3_;
         invalidateBounds();
         return _loc3_ != 0;
      }
      
      private function update(clock:GameClock) : void
      {
         try
         {
            if(!mDestroyed && HudTransform.sync(mFacade,mRoot))
            {
               invalidateBounds();
            }
         }
         catch(transformError:Error)
         {
            failed(transformError);
         }
         if(HudArtConverter.busy)
         {
            return;
         }
         try
         {
            if(mDestroyed)
            {
               return;
            }
            if(!mShown || mUiHidden || mView == null)
            {
               return;
            }
            mTicker.tick(clock.tickLength);
            if(mChatPrompt != null != mFacade.featureFlags.getFlagValue("starling-chat-prompt"))
            {
               syncChatPrompt();
            }
            if(mProfileBulging)
            {
               mProfileBulging = decayBulge(mProfile,mProfileRest);
            }
            if(mXpBulging)
            {
               mXpBulging = decayBulge(mXpRoot,mXpRest);
            }
            updateBuffs();
            if(mOffScreen != null)
            {
               mOffScreen.update();
            }
            if(mLootMoving)
            {
               invalidateBounds();
            }
            if(mCut != null)
            {
               mCut.update();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function syncFade(clock:GameClock) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:uint = 0;
         try
         {
            if(mCut != null)
            {
               _loc3_ = mFacade.camera != null ? mFacade.camera.backgroundFadeAlpha : 0;
               _loc2_ = uint(mFacade.camera != null ? mFacade.camera.backgroundFadeColor : 0);
               mCut.syncChatOverlay(_loc3_,_loc2_);
               mCut.fade(_loc3_,_loc2_);
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function failed(error:Error) : void
      {
         reportError(error);
      }
      
      private function invalidateBounds() : void
      {
         if(mCut != null)
         {
            mCut.invalidate();
         }
      }
      
      private function invalidateArrowBounds() : void
      {
         if(mCut != null)
         {
            mCut.invalidateDynamic();
         }
      }
      
      private function cleanupCall(callback:Function) : void
      {
         try
         {
            callback();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function bindBounds(display:DisplayObject) : void
      {
         var _loc3_:int = 0;
         if(display is ArtDisplay)
         {
            ArtDisplay(display).contentBoundsChanged = invalidateBounds;
         }
         var _loc2_:DisplayObjectContainer = display as DisplayObjectContainer;
         if(_loc2_ != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.numChildren)
            {
               bindBounds(_loc2_.getChildAt(_loc3_));
               _loc3_++;
            }
         }
      }
      
      private function applyCamera() : void
      {
         mFacade.camera.offset = new Point(0,mHudType == 1 ? 0 : 45);
         mFacade.camera.yCilppingFromBottom = mHudType == 1 ? 90 : 0;
         mFacade.camera.forceRedraw();
      }
      
      private function openSettingsPopup() : void
      {
         if(mSettingsPopup != null || mDestroyed)
         {
            return;
         }
         mSettingsPopup = new SettingsPopup(mFacade,onSettingsPopupClosed);
      }
      
      private function onSettingsPopupClosed() : void
      {
         mSettingsPopup = null;
         try
         {
            mSuppressNextExitMenuToggle = mFacade.inputManager.check(27);
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function closeSettingsPopup() : void
      {
         var _loc1_:SettingsPopup = mSettingsPopup;
         mSettingsPopup = null;
         if(_loc1_ != null)
         {
            disposeResource(_loc1_,"destroy");
         }
      }
      
      private function toggleSettingsPopup() : void
      {
         if(mSettingsPopup == null)
         {
            openSettingsPopup();
         }
         else if(SettingsPopup.isTopMenu(mFacade))
         {
            closeSettingsPopup();
         }
      }
      
      private function steamButtonReleased(event:OnSteamInputButtonReleasedEvent) : void
      {
         try
         {
            if(event.actionName == "menu_options" && mSettingsPopup != null)
            {
               toggleSettingsPopup();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function setDestinations() : void
      {
         mDestinations = mHudType == 1 ? new <Vector3D>[new Vector3D(45,150),new Vector3D(1550,980),new Vector3D(60,980),new Vector3D(53,1031),new Vector3D(54,915),new Vector3D(1555,920)] : new <Vector3D>[new Vector3D(45,150),new Vector3D(112,95),new Vector3D(813,57),new Vector3D(1032,57),new Vector3D(1584,78),new Vector3D(1869,1041)];
      }
      
      public function show() : void
      {
         try
         {
            if(mDestroyed || HudArt.fatalFailure)
            {
               return;
            }
            mShown = true;
            mStacksShown = true;
            if(mView == null)
            {
               return;
            }
            mRoot.visible = !mUiHidden;
            mTicker.attachStage(mUiHidden ? null : mFacade.stageRef);
            if(mChatHolder != null)
            {
               mFacade.sceneGraphManager.addChild(mChatHolder,50);
               mChatHolder.visible = !mUiHidden;
            }
            if(mChat != null)
            {
               mChat.enable();
            }
            if(!mUiHidden)
            {
               mInput.attach();
            }
            updateStacks();
            if(mPetPortrait == null)
            {
               updatePet();
            }
            if(mCut != null)
            {
               mCut.invalidate();
               mCut.enabled = !mUiHidden;
            }
            mFacade.camera.yCilppingFromBottom = mHudType == 1 ? 90 : 0;
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function hide() : void
      {
         var _loc3_:StarlingBuff = null;
         var _loc1_:StarlingTooltip = null;
         var _loc2_:StarlingHudSlot = null;
         try
         {
            mShown = false;
            mRoot.visible = false;
            mTicker.attachStage(null);
            if(mInput != null)
            {
               mInput.detach();
            }
            if(mPetPortrait != null)
            {
               mPetPortrait.dispose();
               mPetPortrait = null;
            }
            mPet = null;
            for each(_loc3_ in mBuffViews)
            {
               _loc3_.hideTooltip();
            }
            if(mStacks != null)
            {
               mStacks.root.visible = false;
            }
            for each(_loc1_ in mTooltips)
            {
               _loc1_.hide();
            }
            for each(_loc2_ in mWeapons)
            {
               _loc2_.hideTooltip();
            }
            for each(_loc2_ in mConsumables)
            {
               _loc2_.hideTooltip();
            }
            if(mCut != null)
            {
               mCut.enabled = false;
            }
            if(mChatHolder != null && mChatHolder.parent != null)
            {
               mChatHolder.parent.removeChild(mChatHolder);
            }
            if(mChat != null)
            {
               mChat.disable();
               mChat.hideChatLog();
            }
            closeSettingsPopup();
            mFacade.camera.yCilppingFromBottom = 0;
            mFacade.camera.forceRedraw();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function detachHero() : void
      {
         var _loc2_:StarlingBuff = null;
         var _loc1_:StarlingHudSlot = null;
         try
         {
            hide();
            cleanupCall(hideBuster);
            cleanupCall(destroyTeamLoot);
            disposeResource(mOffScreen,"dispose");
            mOffScreen = null;
            for each(_loc2_ in mBuffViews)
            {
               disposeResource(_loc2_,"dispose");
            }
            mBuffViews.length = 0;
            disposeResource(mEvents,"removeAllListeners");
            cleanupCall(stopBooster);
            cleanupCall(cancelPortrait);
            cleanupCall(destroyExitMenus);
            disposeResource(mHealthFull,"stop");
            disposeResource(mManaFull,"stop");
            try
            {
               if(mPortrait != null)
               {
                  mPortrait.removeFromParent(true);
               }
            }
            catch(portraitError:Error)
            {
               failed(portraitError);
            }
            mPortrait = null;
            mHeroOwner = null;
            clearCooldowns();
            mPet = null;
            mBuffs.length = 0;
            for each(_loc1_ in mWeapons)
            {
               disposeResource(_loc1_,"reset");
            }
            for each(_loc1_ in mConsumables)
            {
               disposeResource(_loc1_,"reset");
            }
            if(mChat != null)
            {
               mChat.heroOwner = null;
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function disposeView() : void
      {
         var _loc5_:StarlingBuff = null;
         var _loc2_:StarlingHudIcon = null;
         var _loc1_:StarlingButton = null;
         var _loc4_:StarlingHudSlot = null;
         var _loc3_:StarlingTooltip = null;
         for each(_loc5_ in mBuffViews)
         {
            disposeResource(_loc5_,"detachInput");
         }
         cleanupCall(destroyTeamLoot);
         if(mPetPortrait != null)
         {
            disposeResource(mPetPortrait);
            mPetPortrait = null;
         }
         disposeResource(mOffScreen,"dispose");
         mOffScreen = null;
         disposeResource(mBuster,"dispose");
         disposeResource(mBusterButton,"dispose");
         mBuster = null;
         mBusterButton = null;
         mBusterBanner = mBusterPulse = null;
         mBusterPromptOffset = 0;
         for each(_loc2_ in mModifierIcons)
         {
            disposeResource(_loc2_);
         }
         for each(_loc1_ in mModifierButtons)
         {
            disposeResource(_loc1_);
         }
         for each(_loc1_ in mStackButtons)
         {
            disposeResource(_loc1_);
         }
         mModifierIcons.length = mModifierButtons.length = mModifierModels.length = mModifierWidths.length = mStackButtons.length = 0;
         disposeResource(mStacks,"dispose");
         mStacks = null;
         mPetModel = null;
         cleanupCall(cancelPortrait);
         mPortrait = null;
         mProfileBulging = mXpBulging = false;
         for each(_loc4_ in mWeapons)
         {
            disposeResource(_loc4_);
         }
         for each(_loc4_ in mConsumables)
         {
            disposeResource(_loc4_);
         }
         mWeapons.length = mConsumables.length = 0;
         disposeResource(mInput);
         mInput = null;
         disposeResource(mCut,"dispose");
         mCut = null;
         for each(_loc3_ in mTooltips)
         {
            disposeResource(_loc3_);
         }
         mTooltips.length = 0;
         disposeResource(mChatPrompt);
         mChatPrompt = null;
         mChatPromptFailed = false;
         disposeResource(mChat,"destroy");
         mChat = null;
         if(mChatHolder != null && mChatHolder.parent != null)
         {
            mChatHolder.parent.removeChild(mChatHolder);
         }
         mChatHolder = null;
         mChatClip = mChatContainer = null;
         disposeResource(mGlyphTask,"destroy");
         mGlyphTask = null;
         cleanupCall(clearGlyphs);
         disposeResource(mHealthFull,"dispose");
         disposeResource(mManaFull,"dispose");
         mHealthFull = mManaFull = null;
         disposeResource(mHp,"dispose");
         disposeResource(mInvulnerable,"dispose");
         disposeResource(mMana,"dispose");
         disposeResource(mXp,"dispose");
         mHp = mInvulnerable = mMana = mXp = null;
         disposeResource(mView,"dispose");
         mView = null;
         mProfile = mXpRoot = null;
         mCenterMessage = null;
      }
      
      public function destroy() : void
      {
         try
         {
            if(mDestroyed)
            {
               return;
            }
            detachHero();
            mDestroyed = true;
            mGeneration = mGeneration + 1;
            HudArt.removeReady(artReady);
            HudArt.removeRebaked(rebuild);
            disposeView();
            closeSettingsPopup();
            mTicker.dispose();
            mWork.destroy();
            mFadeWork.destroy();
            mEvents.destroy();
            mUiHideEvents.destroy();
            if(mFacade.keyBindings != null)
            {
               mFacade.keyBindings.removeChangeListener(keyBindingsChanged);
            }
            if(mFacade.settingsModel != null)
            {
               mFacade.settingsModel.removeChangeListener(settingChanged);
            }
            mAssets.destroy();
            mRoot.removeFromParent(true);
            if(sCurrent == this)
            {
               sCurrent = null;
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function uiHideChanged(event:Event) : void
      {
         try
         {
            mUiHidden = mFacade.uiHideToggle != null && mFacade.uiHideToggle.hidden;
            if(mDestroyed || !mShown || mView == null)
            {
               return;
            }
            mRoot.visible = !mUiHidden;
            if(mChatHolder != null)
            {
               mChatHolder.visible = !mUiHidden;
            }
            if(mCut != null)
            {
               mCut.enabled = !mUiHidden;
               mCut.invalidate();
            }
            if(mInput != null)
            {
               if(mUiHidden)
               {
                  mInput.detach();
               }
               else
               {
                  mInput.attach();
               }
            }
            mTicker.attachStage(mUiHidden ? null : mFacade.stageRef);
            if(!mUiHidden)
            {
               restoreSlotCooldowns();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function showHealthFullMessage() : void
      {
         try
         {
            if(mHealthFull != null)
            {
               mHealthFull.show();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function showManaFullMessage() : void
      {
         try
         {
            if(mManaFull != null)
            {
               mManaFull.show();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function showText(localeTextName:String) : void
      {
         var _loc2_:DisplayObject = null;
         try
         {
            _loc2_ = node("UI_center_message");
            if(_loc2_ == null)
            {
               return;
            }
            if(!_loc2_.visible)
            {
               visible("UI_center_message",true);
               mWork.doLater(0.35,hideCenterMessage);
            }
            text("UI_center_message",Locale.getString(localeTextName),true);
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function isInCooldown() : void
      {
         showText("IS_IN_COOLDOWN");
      }
      
      private function hideCenterMessage(clock:GameClock) : void
      {
         try
         {
            if(mCenterMessage != null)
            {
               mCenterMessage.setHudVisibility(false);
               invalidateBounds();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function showNotEnoughMana() : void
      {
         try
         {
            visible("UI_center_message",true);
            text("UI_center_message",Locale.getString("NOT_ENOUGH_MANA"),true);
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function hideNotEnoughMana() : void
      {
         try
         {
            visible("UI_center_message",false);
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function closeButtonReleased() : void
      {
         if(mHeroOwner == null)
         {
            return;
         }
         if(mHeroOwner.distributedDungeonFloor.isInfiniteDungeon)
         {
            if(mInfiniteExitPopup == null)
            {
               mInfiniteExitPopup = new II_UIExitDungeonPopUp(mFacade,confirmExit,null,openSettingsPopup);
            }
            else
            {
               mInfiniteExitPopup.destroy();
               mInfiniteExitPopup = null;
            }
         }
         else if(mLootLossPopup == null)
         {
            mLootLossPopup = new UILootLossPopup(mFacade,mHeroOwner.distributedDungeonFloor.completionXp,mHeroOwner.distributedDungeonFloor.treasureCollected,confirmExit,null,openSettingsPopup);
         }
         else
         {
            mLootLossPopup.destroy();
            mLootLossPopup = null;
         }
      }
      
      private function confirmExit() : void
      {
         try
         {
            mFacade.metrics.log("ButtonClick",{
               "buttonDesc":"UIHud Exit Button Clicked",
               "areaType":"Dungeon"
            });
            if(mChat != null)
            {
               mChat.hideChatLog();
            }
            clearExitMenu();
            mFacade.mDistributedObjectManager.mMatchMaker.RequestExit();
            mFacade.dbAccountInfo.dbAccountParams.flushParams();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function destroyExitMenus() : void
      {
         disposeResource(mLootLossPopup,"destroy");
         disposeResource(mInfiniteExitPopup,"destroy");
         clearExitMenu();
      }
      
      public function clearExitMenu() : void
      {
         mLootLossPopup = null;
         mInfiniteExitPopup = null;
      }
      
      public function suppressNextExitMenuToggle() : void
      {
         try
         {
            mSuppressNextExitMenuToggle = mFacade.inputManager.check(27) || mFacade.steamInputManager.pressedAction("menu_cancel");
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function handleMenuButtonPressed(index:uint) : void
      {
         try
         {
            if(index == 0)
            {
               if(mSuppressNextExitMenuToggle)
               {
                  mSuppressNextExitMenuToggle = false;
                  return;
               }
               if(mSettingsPopup != null)
               {
                  return;
               }
               closeButtonReleased();
            }
            else if(index == 1)
            {
               toggleSettingsPopup();
            }
            else if(index == 2 && mChat != null)
            {
               mChat.tryToggleChatLog();
            }
            else if(index == 3 && mChat != null && mFacade.steamInputManager.usesSteamOnScreenKeyboard)
            {
               mChat.focusChatInput();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function initControllerIcon(inActionName:String, inOwner:MovieClip, iconPosition:Vector3D, iconScale:Point) : void
      {
         var path:String;
         var ownerGlyphs:Object;
         var stored:Bitmap;
         var generation:uint;
         try
         {
            if(mDestroyed || inOwner == null || !mFacade.steamInputManager.isSteamInputReady)
            {
               return;
            }
            path = mFacade.steamInputManager.getGlyphFilePathForAction(inActionName);
            if(path == null || path.length == 0 || path == "error1")
            {
               return;
            }
            ownerGlyphs = mGlyphs[inOwner];
            if(ownerGlyphs == null)
            {
               ownerGlyphs = {};
               mGlyphs[inOwner] = ownerGlyphs;
            }
            stored = ownerGlyphs[inActionName] as Bitmap;
            if(stored != null && stored.parent != null && stored.parent != inOwner)
            {
               stored = null;
            }
            if(stored != null)
            {
               placeGlyph(stored,inOwner,iconPosition,iconScale);
               return;
            }
            generation = mGlyphGeneration;
            mAssets.getImageAsset(path,function(param1:ImageAsset):void
            {
               var _loc2_:Bitmap = null;
               var _loc3_:Bitmap = null;
               try
               {
                  if(mDestroyed || generation != mGlyphGeneration || mGlyphs[inOwner] != ownerGlyphs)
                  {
                     return;
                  }
                  _loc2_ = ownerGlyphs[inActionName] as Bitmap;
                  if(_loc2_ != null && _loc2_.parent == inOwner)
                  {
                     inOwner.removeChild(_loc2_);
                  }
                  _loc3_ = new Bitmap(param1.image.bitmapData,param1.image.pixelSnapping,param1.image.smoothing);
                  ownerGlyphs[inActionName] = _loc3_;
                  placeGlyph(_loc3_,inOwner,iconPosition,iconScale);
               }
               catch(error:Error)
               {
                  failed(error);
               }
            });
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function removeControllerIcons(inOwner:MovieClip) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Bitmap = null;
         try
         {
            _loc3_ = mGlyphs[inOwner];
            if(_loc3_ == null)
            {
               return;
            }
            for each(_loc2_ in _loc3_)
            {
               if(_loc2_.parent == inOwner)
               {
                  inOwner.removeChild(_loc2_);
               }
            }
            delete mGlyphs[inOwner];
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function clearGlyphs() : void
      {
         var _loc4_:Bitmap = null;
         var _loc5_:Object = null;
         var _loc1_:Image = null;
         var _loc3_:Texture = null;
         var _loc2_:BitmapData = null;
         mGlyphGeneration = mGlyphGeneration + 1;
         for each(_loc5_ in mGlyphs)
         {
            for each(_loc4_ in _loc5_)
            {
               if(_loc4_.parent != null)
               {
                  _loc4_.parent.removeChild(_loc4_);
               }
            }
         }
         mGlyphs = new Dictionary();
         for each(_loc1_ in mStarlingGlyphs)
         {
            _loc1_.removeFromParent(true);
         }
         for each(_loc3_ in mGlyphTextures)
         {
            _loc3_.dispose();
         }
         for each(_loc2_ in mGrayGlyphPixels)
         {
            _loc2_.dispose();
         }
         mStarlingGlyphs = new Dictionary();
         mGlyphTextures = new Dictionary();
         mGlyphPaths = new Dictionary();
         mGlyphPixels = new Dictionary();
         mGrayGlyphPixels = new Dictionary();
      }
      
      private function delayedControllerIcons(clock:GameClock) : void
      {
         try
         {
            mGlyphTask = null;
            updateControllerIcons();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function updateControllerIcons() : void
      {
         clearGlyphs();
         if(mHeroOwner != null)
         {
            syncBusterPrompt();
         }
         if(mChat == null)
         {
            return;
         }
         var _loc1_:Boolean = mFacade.steamInputManager.isSteamInputReady;
         setAllKeyboardIconsVisibility(!mFacade.steamInputManager.wantsControllerPrompts);
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:Boolean = mChatPrompt != null && mChatPrompt.logButton != null;
         if(_loc2_)
         {
            initStarlingGlyph("toggle_chat_log",mChatPrompt.logButton.root,25,-10,20);
         }
         else
         {
            initControllerIcon("toggle_chat_log",mChatClip.log_btn,new Vector3D(25,-10),new Point(20,20));
         }
         if(mFacade.steamInputManager.usesSteamOnScreenKeyboard)
         {
            if(_loc2_)
            {
               initStarlingGlyph("open_chat_keyboard",mChatPrompt.sendButton.root,32,-10,20);
            }
            else
            {
               initControllerIcon("open_chat_keyboard",mChatClip.chat_btn,new Vector3D(32,-10),new Point(20,20));
            }
         }
         initStarlingControllerIcons();
         HudReviveBridge.refresh(mFacade,this,mHeroOwner);
      }
      
      private function setAllKeyboardIconsVisibility(value:Boolean) : void
      {
         visible("UI_weapons.weapon_z.label",keepsKeyboardLabel(value,"attack_weapon_1"));
         visible("UI_weapons.weapon_x.label",keepsKeyboardLabel(value,"attack_weapon_2"));
         visible("UI_weapons.weapon_c.label",keepsKeyboardLabel(value,"attack_weapon_3"));
         visible("consumables_01.label",keepsKeyboardLabel(value,"use_consumable_one"));
         visible("consumables_02.label",keepsKeyboardLabel(value,"use_consumable_two"));
         if(mChat != null)
         {
            mChat.setChatPromptVisible(value);
         }
      }
      
      private function keepsKeyboardLabel(value:Boolean, action:String) : Boolean
      {
         return value || !mFacade.steamInputManager.hasGlyphForAction(action);
      }
      
      private function initStarlingControllerIcons() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Vector.<String> = new <String>["attack_weapon_1","attack_weapon_2","attack_weapon_3"];
         _loc1_ = 0;
         while(_loc1_ < mWeapons.length)
         {
            initStarlingGlyph(_loc2_[_loc1_],mWeapons[_loc1_].button.root,13,-50);
            _loc1_++;
         }
         if(mConsumables.length > 0)
         {
            initStarlingGlyph("use_consumable_one",mConsumables[0].button.root,13,-50);
         }
         if(mConsumables.length > 1)
         {
            initStarlingGlyph("use_consumable_two",mConsumables[1].button.root,13,-50);
         }
         initStarlingGlyph("toggle_menu",node("close"),-5,-27);
         initStarlingGlyph("use_dungeon_buster",node("UI_buster_active.buster_activated"),8,-8);
      }
      
      private function initStarlingGlyph(action:String, owner:DisplayObject, x:Number, y:Number, size:Number = 25) : void
      {
         var path:String;
         var generation:uint;
         var container:DisplayObjectContainer = owner as DisplayObjectContainer;
         if(container == null)
         {
            return;
         }
         path = mFacade.steamInputManager.getGlyphFilePathForAction(action);
         if(path == null || path.length == 0 || path == "error1")
         {
            return;
         }
         generation = mGlyphGeneration;
         mAssets.getImageAsset(path,function(param1:ImageAsset):void
         {
            var _loc4_:Texture = null;
            var _loc3_:Image = null;
            var _loc2_:Image = null;
            try
            {
               if(mDestroyed || generation != mGlyphGeneration)
               {
                  return;
               }
               _loc4_ = mGlyphTextures[path] as Texture;
               if(_loc4_ == null)
               {
                  _loc4_ = Texture.fromBitmapData(param1.image.bitmapData);
                  mGlyphTextures[path] = _loc4_;
               }
               mGlyphPixels[path] = param1.image.bitmapData;
               mGlyphPaths[action] = path;
               _loc3_ = mStarlingGlyphs[action] as Image;
               if(_loc3_ != null)
               {
                  _loc3_.removeFromParent(true);
               }
               _loc2_ = new Image(_loc4_);
               _loc2_.touchable = false;
               _loc2_.x = x;
               _loc2_.y = y;
               _loc2_.width = _loc2_.height = size;
               container.addChild(_loc2_);
               mStarlingGlyphs[action] = _loc2_;
               if(action == "use_consumable_one" && mConsumables.length > 0 && !mConsumables[0].button.enabled || action == "use_consumable_two" && mConsumables.length > 1 && !mConsumables[1].button.enabled)
               {
                  grayscaleGlyph(action);
               }
               invalidateBounds();
            }
            catch(error:Error)
            {
               failed(error);
            }
         });
      }
      
      private function grayscaleGlyph(action:String) : void
      {
         var _loc4_:BitmapData = null;
         var _loc3_:Image = mStarlingGlyphs[action] as Image;
         var _loc2_:String = mGlyphPaths[action];
         var _loc6_:BitmapData = mGlyphPixels[_loc2_] as BitmapData;
         if(_loc3_ == null || _loc6_ == null)
         {
            return;
         }
         var _loc7_:String = _loc2_ + "|gray";
         var _loc5_:Texture = mGlyphTextures[_loc7_] as Texture;
         if(_loc5_ == null)
         {
            _loc4_ = _loc6_.clone();
            _loc4_.applyFilter(_loc4_,_loc4_.rect,new Point(),HudArtConverter.grayscaleFilter());
            _loc5_ = Texture.fromBitmapData(_loc4_);
            mGlyphTextures[_loc7_] = _loc5_;
            mGrayGlyphPixels[_loc7_] = _loc4_;
         }
         _loc3_.texture = _loc5_;
      }
      
      public function get ownedHero() : HeroGameObjectOwner
      {
         return mHeroOwner;
      }
      
      public function get chatLog() : UIChatLog
      {
         return mChat;
      }
      
      public function get floaterTextClass() : Class
      {
         try
         {
            return HudArt.ready || HudArt.fatalFailure ? HudArt.swfClass("floater_text") : null;
         }
         catch(error:Error)
         {
            failed(error);
            var _loc3_:* = null;
         }
         return _loc3_;
      }
      
      public function get teamLootDestination() : Vector3D
      {
         return mDestinations[0];
      }
      
      public function get profileDestination() : Vector3D
      {
         return mDestinations[1];
      }
      
      public function get coinsDestination() : Vector3D
      {
         return mDestinations[2];
      }
      
      public function get expDestination() : Vector3D
      {
         return mDestinations[4];
      }
      
      public function get crowdDestination() : Vector3D
      {
         return mDestinations[5];
      }
      
      public function hideBustSign() : void
      {
         try
         {
            hideBuster();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function setWeaponHighlight(currentWeaponIndex:int) : void
      {
         var _loc2_:int = 0;
         try
         {
            mHighlightIndex = currentWeaponIndex;
            _loc2_ = 0;
            while(_loc2_ < mWeapons.length)
            {
               mWeapons[_loc2_].highlight(_loc2_ == currentWeaponIndex);
               _loc2_++;
            }
            invalidateBounds();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function startCooldown(currentWeaponIndex:int, cooldownTime:Number) : void
      {
         try
         {
            if(currentWeaponIndex < 0 || currentWeaponIndex >= 3)
            {
               return;
            }
            recordCooldown(currentWeaponIndex,cooldownTime);
            if(currentWeaponIndex < mWeapons.length)
            {
               mWeapons[currentWeaponIndex].startCooldown(cooldownTime);
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function stopCooldown(currentWeaponIndex:int) : void
      {
         try
         {
            if(currentWeaponIndex < 0 || currentWeaponIndex >= 3)
            {
               return;
            }
            mCooldownDurations[currentWeaponIndex] = 0;
            if(currentWeaponIndex < mWeapons.length)
            {
               mWeapons[currentWeaponIndex].stopCooldown();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function startConsumableCooldown(currentWeaponIndex:int, cooldownTime:Number) : void
      {
         try
         {
            if(currentWeaponIndex < 0 || currentWeaponIndex >= 2)
            {
               return;
            }
            recordCooldown(currentWeaponIndex + 3,cooldownTime);
            if(currentWeaponIndex < mConsumables.length)
            {
               mConsumables[currentWeaponIndex].startCooldown(cooldownTime);
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function stopConsumableCooldown(currentWeaponIndex:int) : void
      {
         try
         {
            if(currentWeaponIndex < 0 || currentWeaponIndex >= 2)
            {
               return;
            }
            mCooldownDurations[currentWeaponIndex + 3] = 0;
            if(currentWeaponIndex < mConsumables.length)
            {
               mConsumables[currentWeaponIndex].stopCooldown();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function recordCooldown(slot:int, seconds:Number) : void
      {
         mCooldownStarts[slot] = mFacade.gameClock.gameTime;
         mCooldownDurations[slot] = seconds;
      }
      
      private function clearCooldowns() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < mCooldownDurations.length)
         {
            mCooldownDurations[_loc1_] = 0;
            _loc1_++;
         }
      }
      
      private function restoreSlotCooldowns() : void
      {
         var _loc3_:int = 0;
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc4_:StarlingHudSlot = null;
         _loc3_ = 0;
         while(_loc3_ < mCooldownDurations.length)
         {
            _loc2_ = mCooldownDurations[_loc3_];
            if(_loc2_ > 0)
            {
               _loc1_ = Math.max(0,(mFacade.gameClock.gameTime - mCooldownStarts[_loc3_]) / 1000);
               if(_loc1_ >= _loc2_)
               {
                  mCooldownDurations[_loc3_] = 0;
               }
               else
               {
                  _loc4_ = _loc3_ < 3 ? (_loc3_ < mWeapons.length ? mWeapons[_loc3_] : null) : (_loc3_ - 3 < mConsumables.length ? mConsumables[_loc3_ - 3] : null);
                  if(_loc4_ != null)
                  {
                     _loc4_.startCooldown(_loc2_,_loc1_);
                  }
               }
            }
            _loc3_++;
         }
      }
      
      public function decrementConsumableCount(slot:uint) : void
      {
         try
         {
            if(slot < mConsumables.length)
            {
               mConsumables[slot].decrement();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function totalConsumableCountReached(slot:uint) : void
      {
         try
         {
            if(slot >= mConsumables.length)
            {
               return;
            }
            mConsumables[slot].exhaust();
            grayscaleGlyph(slot == 0 ? "use_consumable_one" : "use_consumable_two");
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function openTeamLoot(chestId:uint) : void
      {
         var symbol:String;
         var generation:uint;
         try
         {
            destroyTeamLoot();
            if(mView == null)
            {
               return;
            }
            switch(int(chestId) - 60001)
            {
               case 0:
                  symbol = "UI_teamloot_basic";
                  break;
               case 1:
                  symbol = "UI_teamloot_uncommon";
                  break;
               case 2:
                  symbol = "UI_teamloot_rare";
                  break;
               case 3:
                  symbol = "UI_teamloot_legendary";
                  break;
               case 4:
                  symbol = "UI_teamloot_box_small";
                  break;
               case 5:
                  symbol = "UI_teamloot_box_royal";
                  break;
               default:
                  return;
            }
            generation = mLootGeneration;
            HudArt.convertSymbol(symbol,function(param1:ArtNode):void
            {
               try
               {
                  if(mDestroyed || generation != mLootGeneration || param1 == null || mView == null)
                  {
                     return;
                  }
                  mTeamLoot = ArtView.build(param1,mTicker);
                  DisplayObjectContainer(mView.root).addChild(mTeamLoot.root);
                  mTeamLoot.root.scaleX = mTeamLoot.root.scaleY = 1.8;
                  mTeamLoot.root.x = -550;
                  mTeamLoot.root.y = -150;
                  TimelineView(mTeamLoot.root).stageRate = false;
                  TimelineView(mTeamLoot.root).play(0,true);
                  bindBounds(mTeamLoot.root);
                  mLootMoving = true;
                  mLootTween = mFacade.mTween.tweenMaxTo(mTeamLoot.root,0.5,{
                     "x":-550,
                     "onComplete":lootOpened
                  });
                  mLootTask = mWork.doLater(2,closeTeamLoot);
                  invalidateBounds();
               }
               catch(error:Error)
               {
                  failed(error);
               }
            });
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function lootOpened() : void
      {
         mLootTween = null;
         mLootMoving = false;
         invalidateBounds();
      }
      
      private function closeTeamLoot(clock:GameClock) : void
      {
         try
         {
            mLootTask = null;
            if(mTeamLoot == null)
            {
               return;
            }
            if(mLootTween != null)
            {
               mFacade.mTween.killTween(mLootTween);
            }
            mLootMoving = true;
            mLootTween = mFacade.mTween.tweenMaxTo(mTeamLoot.root,0.5,{
               "x":-250,
               "onComplete":lootClosed
            });
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function lootClosed() : void
      {
         try
         {
            mLootMoving = false;
            mLootTween = null;
            if(mTeamLoot != null)
            {
               TimelineView(mTeamLoot.root).stop();
               mTeamLoot.root.visible = false;
            }
            invalidateBounds();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function destroyTeamLoot() : void
      {
         mLootGeneration = mLootGeneration + 1;
         if(mLootTween != null)
         {
            mFacade.mTween.killTween(mLootTween);
         }
         if(mLootTask != null)
         {
            mLootTask.destroy();
         }
         mLootTask = null;
         mLootTween = null;
         mLootMoving = false;
         if(mTeamLoot != null)
         {
            mTeamLoot.dispose();
         }
         mTeamLoot = null;
         invalidateBounds();
      }
      
      public function showStacks() : void
      {
         try
         {
            mStacksShown = true;
            updateStacks();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function hideStacks() : void
      {
         try
         {
            mStacksShown = false;
            updateStacks();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function offScreenPicChange(playerId:int, picType:String) : void
      {
         try
         {
            if(mOffScreen != null)
            {
               mOffScreen.handlePicChange(playerId,picType);
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function showBuffDisplay(buffGO:BuffGameObject) : void
      {
         try
         {
            if(buffGO == null || buffGO.isDestroyed || mBuffs.indexOf(buffGO) >= 0)
            {
               return;
            }
            mBuffs.push(buffGO);
            if(mView != null)
            {
               createBuff(buffGO);
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function updateBuffInstance(updatedBuffGO:BuffGameObject) : void
      {
         var _loc2_:StarlingBuff = null;
         try
         {
            _loc2_ = buffView(updatedBuffGO);
            if(_loc2_ != null)
            {
               _loc2_.updateInstance();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function registerPet(petNPC:NPCGameObject) : void
      {
         try
         {
            mPet = petNPC;
            updatePet();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function unregisterPet(petNPC:NPCGameObject) : void
      {
         try
         {
            if(petNPC == null || mPet != petNPC)
            {
               return;
            }
            mPet = null;
            if(mPetPortrait != null)
            {
               mPetPortrait.petDeath();
               if(petNPC.gmNpc.RespawnT <= 0)
               {
                  mPetPortrait.dispose();
                  mPetPortrait = null;
               }
            }
            invalidateBounds();
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function syncBusterPrompt() : void
      {
         var _loc1_:String = null;
         var _loc3_:StarlingText = null;
         var _loc2_:Boolean = mFacade.steamInputManager.hasGlyphForAction("use_dungeon_buster");
         mBusterPromptOffset = _loc2_ ? -5 : 0;
         for each(_loc1_ in new <String>["UI_buster_active.buster_activated.up.db_pressbutton_text","UI_buster_active.buster_activated.over.mc.db_pressbutton_text"])
         {
            if(node(_loc1_) is ArtDisplay)
            {
               ArtDisplay(node(_loc1_)).setHudOffset(mBusterPromptOffset,0);
            }
            if(_loc2_)
            {
               text(_loc1_,Locale.getString("PRESS_BUSTER_BUTTON_CONTROLLER"),true);
            }
            else if(mFacade.keyBindings != null)
            {
               text(_loc1_,Locale.getString("PRESS_BUSTER_BUTTON_KEYBOARD") + mFacade.keyBindings.displayNameFor("useDungeonBuster"),true);
            }
            else
            {
               _loc3_ = node(_loc1_) as StarlingText;
               if(_loc3_ != null)
               {
                  _loc3_.mode = "baked";
                  _loc3_.setText(_loc3_.art.initialText);
               }
            }
         }
      }
      
      private function initializeBuster() : void
      {
         hideBuster();
         mBusterButton.setHover(false);
         mBusterButton.setPressed(false);
         var _loc1_:GMAttack = mFacade.gameMaster.attackByConstant.itemFor(mHeroOwner.gMHero.DBuster1);
         var _loc2_:String = _loc1_ != null ? GameMasterLocale.getGameMasterSubString("ATTACK_BUSTER_NAME",_loc1_.Constant).toUpperCase() : "BUSTER!";
         text("UI_buster_active.buster_activated.up.name_mc.name_label",_loc2_,true);
         text("UI_buster_active.buster_activated.over.mc.name_label",_loc2_,true);
         text("UI_buster_glow.buster_text.buster_text_label.name_label",_loc2_,true);
         syncBusterPrompt();
         mBusterMax = mHeroOwner.maxBusterPoints;
         applyBusterPulse();
         setBusterPoints(mHeroOwner.dungeonBusterPoints);
      }
      
      private function busterChanged(event:BusterPointsEvent) : void
      {
         var _loc2_:uint = 0;
         try
         {
            mBusterMax = event.maxBusterPoints;
            _loc2_ = event.busterPoints;
            setBusterPoints(_loc2_);
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function setBusterPoints(current:uint) : void
      {
         try
         {
            if(mBuster == null)
            {
               return;
            }
            mBuster.value = mBusterMax > 0 ? current / mBusterMax : 0;
            if(current >= mBusterMax)
            {
               showBustSign();
            }
            else
            {
               hideBuster();
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      public function showBustSign() : void
      {
         try
         {
            mBusterReady = true;
            if(mBusterBanner == null)
            {
               busterReady();
               return;
            }
            visible("UI_buster_glow",true);
            mBusterBanner.stageRate = false;
            mBusterBanner.play(1,false,busterReady);
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function busterReady() : void
      {
         try
         {
            if(!mBusterReady)
            {
               return;
            }
            visible("UI_buster_glow",false);
            visible("UI_buster_active",true);
            visible("UI_buster_active.buster_activated",true);
            if(mBusterButton != null)
            {
               mBusterButton.restartState();
            }
            visible("UI_buster.buster_activated_glow",true);
            if(mBusterPulse != null && !mBusterPulse.isPlaying)
            {
               mBusterPulse.play(0,true);
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function applyBusterPulse() : void
      {
         if(mBusterPulse == null)
         {
            return;
         }
         mBusterPulse.stageRate = false;
         pulseHiddenTiming(mBusterPulse);
         if(mBusterPulse.visible)
         {
            mBusterPulse.play(0,true);
         }
      }
      
      private function pulseHiddenTiming(display:DisplayObject) : void
      {
         var _loc3_:int = 0;
         if(display is TimelineView)
         {
            TimelineView(display).advanceWhileHidden = false;
         }
         var _loc2_:DisplayObjectContainer = display as DisplayObjectContainer;
         if(_loc2_ != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.numChildren)
            {
               pulseHiddenTiming(_loc2_.getChildAt(_loc3_));
               _loc3_++;
            }
         }
      }
      
      private function hideBuster() : void
      {
         mBusterReady = false;
         if(mBusterBanner != null)
         {
            mBusterBanner.stop();
         }
         visible("UI_buster_glow",false);
         visible("UI_buster_active",false);
         visible("UI_buster.buster_activated_glow",false);
         if(mBusterPulse != null)
         {
            mBusterPulse.stop();
         }
      }
      
      public function handleBusterBarClickEvent() : void
      {
         try
         {
            if(mHeroOwner != null && mHeroOwner.dungeonBusterPoints >= mHeroOwner.maxBusterPoints)
            {
               mEvents.dispatchEvent(new DungeonBusterControlActivatedEvent());
            }
         }
         catch(error:Error)
         {
            failed(error);
         }
      }
      
      private function updateWeapons() : void
      {
         var _loc1_:int = 0;
         if(mHeroOwner == null)
         {
            return;
         }
         _loc1_ = 0;
         while(_loc1_ < mWeapons.length)
         {
            mWeapons[_loc1_].equipWeapon(mHeroOwner,_loc1_ < mHeroOwner.weaponControllers.length && mHeroOwner.weaponControllers[_loc1_] != null ? mHeroOwner.weaponControllers[_loc1_].weapon : null);
            _loc1_++;
         }
      }
      
      private function updateConsumables() : void
      {
         var _loc1_:int = 0;
         if(mHeroOwner == null)
         {
            return;
         }
         _loc1_ = 0;
         while(_loc1_ < mConsumables.length)
         {
            mConsumables[_loc1_].equipConsumable(mHeroOwner,_loc1_ < mHeroOwner.consumables.length ? mHeroOwner.consumables[_loc1_] : null);
            _loc1_++;
         }
         restoreGlyph("use_consumable_one");
         restoreGlyph("use_consumable_two");
      }
      
      private function restoreGlyph(action:String) : void
      {
         if(action == "use_consumable_one" && mConsumables.length > 0 && !mConsumables[0].button.enabled || action == "use_consumable_two" && mConsumables.length > 1 && !mConsumables[1].button.enabled)
         {
            grayscaleGlyph(action);
            return;
         }
         var _loc2_:Image = mStarlingGlyphs[action] as Image;
         var _loc3_:Texture = mGlyphTextures[mGlyphPaths[action]] as Texture;
         if(_loc2_ != null && _loc3_ != null)
         {
            _loc2_.texture = _loc3_;
         }
      }
      
      private function updateStacks() : void
      {
         if(mStacks != null)
         {
            mStacks.root.visible = mShown && mStacksShown;
         }
         invalidateBounds();
      }
      
      private function updateOffScreen() : void
      {
         if(mOffScreen != null)
         {
            mOffScreen.dispose();
         }
         mOffScreen = mView != null && mHeroOwner != null ? new StarlingOffScreenManager(mFacade,mTicker,mView.root as DisplayObjectContainer,mHeroOwner,invalidateArrowBounds,mCut) : null;
         if(mOffScreen != null)
         {
            bindBounds(mRoot);
         }
      }
      
      private function buffView(buffGO:BuffGameObject) : StarlingBuff
      {
         var _loc2_:StarlingBuff = null;
         for each(_loc2_ in mBuffViews)
         {
            if(_loc2_.buff == buffGO)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function createBuff(buffGO:BuffGameObject) : void
      {
         if(buffGO == null || buffGO.isDestroyed)
         {
            return;
         }
         var _loc2_:StarlingBuff = new StarlingBuff(mFacade,mTicker,mInput,mRoot,buffGO,invalidateBounds);
         mBuffViews.push(_loc2_);
         bindBounds(_loc2_.root);
         resetBuffButtonPositions();
      }
      
      private function resetBuffButtonPositions() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < mBuffViews.length)
         {
            mBuffViews[_loc1_].position(_loc1_,mHudType == 1);
            _loc1_++;
         }
      }
      
      private function updateBuffs() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < mBuffViews.length)
         {
            if(mBuffViews[_loc1_].buff.isDestroyed)
            {
               _loc2_ = mBuffs.indexOf(mBuffViews[_loc1_].buff);
               if(_loc2_ >= 0)
               {
                  mBuffs.removeAt(_loc2_);
               }
               mBuffViews[_loc1_].dispose();
               mBuffViews.removeAt(_loc1_--);
            }
            _loc1_++;
         }
      }
      
      private function updatePet() : void
      {
         if(mPetPortrait != null)
         {
            mPetPortrait.dispose();
            mPetPortrait = null;
         }
         if(mView == null || !mShown || mPetModel == null || !mFacade.dbConfigManager.getConfigBoolean("want_pets",true))
         {
            return;
         }
         mPetPortrait = new StarlingPetPortrait(mFacade,mView,mTicker,mInput,mRoot,mPetModel,mPet,invalidateBounds);
      }
      
      private function buildModifiers(model:MovieClip) : void
      {
         var _loc5_:int = 0;
         var _loc3_:String = null;
         var _loc2_:StarlingButton = null;
         var _loc6_:MovieClip = null;
         var _loc4_:StarlingTooltip = null;
         _loc5_ = 1;
         while(_loc5_ <= 4)
         {
            _loc3_ = "floor_modifier0" + _loc5_;
            _loc2_ = new StarlingButton(mView,_loc3_,mRoot);
            mModifierButtons.push(_loc2_);
            mModifierWidths.push(_loc2_.root.width);
            _loc2_.clearStateArt();
            _loc6_ = model["tooltip_modifier0" + _loc5_];
            mModifierModels.push(_loc6_);
            _loc4_ = new StarlingTooltip(mFacade,_loc2_.root,mRoot,_loc6_,0,new Point(0,-15));
            mTooltips.push(_loc4_);
            _loc2_.rollOverCallback = _loc4_.rollOver;
            _loc2_.rollOutCallback = _loc4_.hide;
            mInput.add(_loc2_,false);
            _loc5_++;
         }
      }
      
      private function setDungeonModifiers() : void
      {
         var _loc2_:int = 0;
         var _loc1_:StarlingHudIcon = null;
         for each(_loc1_ in mModifierIcons)
         {
            _loc1_.dispose();
         }
         mModifierIcons.length = 0;
         _loc2_ = 0;
         while(_loc2_ < mModifierButtons.length)
         {
            visible("floor_modifier0" + (_loc2_ + 1),false);
            _loc2_++;
         }
         var _loc3_:Vector.<DungeonModifierHelper> = mHeroOwner.distributedDungeonFloor.activeGMDungeonModifiers;
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length && _loc2_ < mModifierButtons.length)
         {
            setupModifier(_loc2_,_loc3_[_loc2_]);
            _loc2_++;
         }
      }
      
      private function setupModifier(index:int, modifier:DungeonModifierHelper) : void
      {
         var root:DisplayObjectContainer;
         var child:DisplayObject;
         var i:int;
         var icon:StarlingHudIcon;
         var button:StarlingButton = mModifierButtons[index];
         var tooltip:MovieClip = mModifierModels[index];
         TextUtil.setText(tooltip.title_label,GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_NAME",modifier.GMDungeonMod.Constant));
         TextUtil.setText(tooltip.description_label,GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_DESCRIPTION",modifier.GMDungeonMod.Constant));
         root = button.root as DisplayObjectContainer;
         i = 0;
         while(i < root.numChildren)
         {
            child = root.getChildAt(i);
            if(child is ArtDisplay)
            {
               ArtDisplay(child).setHudVisibility(false);
            }
            else
            {
               child.visible = false;
            }
            i = i + 1;
         }
         icon = new StarlingHudIcon(mFacade,mTicker,root,function():void
         {
            try
            {
               visible("floor_modifier0" + (index + 1),true);
            }
            catch(error:Error)
            {
               failed(error);
            }
         });
         mModifierIcons.push(icon);
         icon.load(modifier.GMDungeonMod.IconFilepath,modifier.GMDungeonMod.IconName,1,1,mModifierWidths[index]);
      }
      
      public function petPortraitState() : Object
      {
         var _loc1_:NPCGameObject = null;
         try
         {
            _loc1_ = mPetPortrait != null ? mPetPortrait.petNPCGameObject : null;
            return {
               "present":mPetPortrait != null,
               "hasPet":_loc1_ != null,
               "npcId":(_loc1_ != null ? _loc1_.id : 0),
               "isDead":mPetPortrait != null && mPetPortrait.isDead
            };
         }
         catch(error:Error)
         {
            failed(error);
            var _loc4_:* = null;
         }
         return _loc4_;
      }
   }
}

