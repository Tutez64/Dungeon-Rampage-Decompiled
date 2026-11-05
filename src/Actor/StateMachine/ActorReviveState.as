package Actor.StateMachine
{
   import Account.StackableInfo;
   import Account.StoreServicesController;
   import Actor.ActorView;
   import Box2D.Collision.Shapes.b2CircleShape;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Event.EventListeners;
   import Brain.GameObject.GameObject;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.Render.Tweens.TweenHandle;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UICircularProgressBar;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Collision.HeroReviveSensor;
   import DBGlobals.DBGlobal;
   import DistributedObjects.HeroGameObject;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMChest;
   import GameMasterDictionary.GMDoober;
   import GameMasterDictionary.GMOffer;
   import GeneratedCode.InfiniteRewardData;
   import Input.MenuNavigationController;
   import StateMachine.MainStateMachine.DungeonTutorial;
   import SteamInput.UnboundActionEvent;
   import UI.InfiniteIsland.II_UIExitDungeonPopUp;
   import UI.Popup.UILootLossPopup;
   import UI.UIChatLog;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.text.TextField;
   
   public class ActorReviveState extends ActorState
   {
      
      public static const NAME:String = "ActorReviveState";
      
      public static const CLEAR_REVIVE_EVENT:String = "CLEAR_REVIVE_EVENT";
      
      public static const ON_ENTER_STATE_SATURATE_VALUE:Number = 25;
      
      public static const ON_EXIT_STATE_SATURATE_VALUE:Number = 100;
      
      public static const REVIVE_DURATION:Number = 30;
      
      public static const REVIVE_CIRCULAR_BAR_INCREMENT_DURATION:Number = 0.5;
      
      public static const DEAD_PLAYER_EFFECT_Y_OFFSET:Number = -100;
      
      public static const TRIGGER_RANGE:Number = 100;
      
      public static const BOMB_BUTTON_LOCK_DURATION:Number = 2;
      
      private static const HUD_MENU_INDEX_OPTIONS:uint = 1;
      
      private static const CONTROLLER_ICON_POSITION_FOR_REVIVE:Vector3D = new Vector3D(15,26);
      
      private static const CONTROLLER_GLYPH_SCALE_REVIVE:Point = new Point(20,20);
      
      private static const CONTROLLER_ICON_POSITION_FOR_SPECTATE:Vector3D = new Vector3D(50,-60);
      
      private static const CONTROLLER_GLYPH_SCALE_SPECTATE:Point = new Point(50,50);
      
      private static const DISABLED_LOOK:ColorMatrixFilter = new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0]);
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mEventComponent:EventComponent;
      
      protected var mOffScreenBootTimer:UICircularProgressBar;
      
      protected var mPopupBootTimer:UICircularProgressBar;
      
      protected var mPopupBootTimerTask:Task;
      
      protected var mDestroyTimerTask:Task;
      
      protected var mSpaceBarTask:Task;
      
      private var mPanelTask:Task;
      
      private var mReviveMenuWanted:Boolean;
      
      private var mLinkedChatButtons:Array = [];
      
      private var mChatBarLocked:Boolean;
      
      protected var mLoadReviveTriggerTask:Task;
      
      protected var mBombButtonLockTask:Task;
      
      protected var mRevivePanel:MovieClip;
      
      protected var mSelfReviveMeButton:UIButton;
      
      protected var mSelfReviveAllButton:UIButton;
      
      protected var mReturnToTownButton:UIButton;
      
      protected var mReturnToTownButtonEnableTask:Task;
      
      protected var mDeadPlayerEffect:MovieClip;
      
      protected var mKeyBoardInput:MovieClip;
      
      private var mKeyBoardInputWanted:Boolean;
      
      private var mRevivePressed:Boolean;
      
      protected var mMouseInput:MovieClip;
      
      protected var mReviveTrigger:HeroReviveSensor;
      
      protected var mHeroGameObject:HeroGameObject;
      
      protected var mSpaceBarReviveDownFunction:Function;
      
      protected var mSpaceBarReviveUpFunction:Function;
      
      private var mDungeonReviveTutorial:DungeonTutorial;
      
      private var mDeathCount:uint = 0;
      
      private var mHitTabClip:MovieClip;
      
      private var mHitTabTween:TweenHandle;
      
      protected var mCloseButton:UIButton;
      
      public function ActorReviveState(dbFacade:DBFacade, heroGameObject:HeroGameObject, actorView:ActorView, finishedCallback:Function = null)
      {
         super(dbFacade,heroGameObject,actorView,"ActorReviveState",finishedCallback);
         mHeroGameObject = heroGameObject;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"ActorReviveState");
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"ActorReviveState");
         mDungeonReviveTutorial = new DungeonTutorial(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener("CLEAR_REVIVE_EVENT",function(param1:Event):void
         {
            deActivateReviveUI();
         });
         mEventComponent.addListener("DUNGEON_FAILED_EVENT",function(param1:Event):void
         {
            destroyUI();
         });
         mEventComponent.addListener("CLIENT_COUNTDOWN_FINISHED_EVENT",function(param1:Event):void
         {
            if(mRevivePanel)
            {
               hideRevivePanel();
            }
         });
         mEventComponent.addListener("UI_HIDE_TOGGLE_CHANGED",function(param1:Event):void
         {
            applyUiHidden();
         });
      }
      
      public function refreshHudControllerIcons() : void
      {
         if(!mDBFacade.steamInputManager.isSteamInputReady || !mDBFacade.hud)
         {
            return;
         }
         if(mKeyBoardInput)
         {
            mDBFacade.hud.initControllerIcon("revive_ally",mKeyBoardInput,CONTROLLER_ICON_POSITION_FOR_REVIVE,CONTROLLER_GLYPH_SCALE_REVIVE);
         }
         if(mHitTabClip)
         {
            mDBFacade.hud.initControllerIcon("revive_ally",mHitTabClip,CONTROLLER_ICON_POSITION_FOR_SPECTATE,CONTROLLER_GLYPH_SCALE_SPECTATE);
         }
      }
      
      override public function enterState() : void
      {
         var ownerHero:HeroGameObjectOwner;
         var ownerHeroId:uint;
         var go:GameObject;
         var ownerHeroGO:HeroGameObjectOwner;
         var reviveTutorialPopupPosition:String;
         super.enterState();
         mActorView.actionsForDeadState();
         mHeroGameObject.movementControllerType = "locked";
         mHeroGameObject.stopRunIdleMonitoring();
         mEventComponent.dispatchEvent(new Event("CLEAR_REVIVE_EVENT"));
         if(mActorView.hasAnimationRenderer())
         {
            mActorView.playAnim("death",0,false,false);
         }
         if(mActorView.currentWeapon && mActorView.currentWeapon.weaponRenderer)
         {
            mActorView.currentWeapon.weaponRenderer.stop();
         }
         if(mHeroGameObject is HeroGameObjectOwner)
         {
            ownerHero = mHeroGameObject as HeroGameObjectOwner;
            ownerHero.clearWeaponInput();
         }
         if(mHeroGameObject is HeroGameObjectOwner)
         {
            HeroGameObjectOwner(mHeroGameObject).startDeathCamInput();
         }
         if(mHeroGameObject.distributedDungeonFloor && mHeroGameObject.distributedDungeonFloor.isADefeat)
         {
            return;
         }
         mLoadReviveTriggerTask = mLogicalWorkComponent.doEverySeconds(0.5,checkIfHeroIsReadyAndInitReviveSensor);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),function(param1:SwfAsset):void
         {
            var alertText:TextField;
            var swfAsset:SwfAsset = param1;
            var assetClass:Class = swfAsset.getClass("UI_widget");
            mDeadPlayerEffect = new assetClass();
            mDeadPlayerEffect.y += -100;
            mDeadPlayerEffect.NametagText.text = "";
            alertText = mDeadPlayerEffect.AlertText;
            Locale.setText(alertText,"NAMETAG_RESCUE",null,1.64);
            TextUtil.fitToField(alertText);
            if(TextUtil.enabled)
            {
               alertText.autoSize = "center";
            }
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Avatars/db_icon_death.swf"),function(param1:SwfAsset):void
            {
               var _loc3_:Class = param1.getClass("death_icon");
               var _loc2_:MovieClip = new _loc3_();
               _loc2_.name = "revivePic";
               mDeadPlayerEffect.UI_avatar.addChild(_loc2_);
            });
            mDeadPlayerEffect.UI_arrow.visible = false;
            mDeadPlayerEffect.name = "deadEffect";
            mHeroGameObject.view.root.addChildAt(mDeadPlayerEffect,0);
            applyUiHidden();
         });
         if(mDBFacade.hud)
         {
            mDBFacade.hud.offScreenPicChange(mHeroGameObject.id,"REVIVE");
         }
         if(mHeroGameObject is HeroGameObjectOwner)
         {
            mDeathCount = mDeathCount + 1;
            saturate(25);
            mDBFacade.uiHideToggle.reveal();
            loadDeadPlayerUI();
         }
         else if(!mDBFacade.dbAccountInfo.dbAccountParams.hasReviveTutorialParam())
         {
            if(mHeroGameObject && mHeroGameObject.distributedDungeonFloor)
            {
               ownerHeroId = mDBFacade.dbAccountInfo.activeAvatarInfo.id;
               go = mDBFacade.gameObjectManager.getReferenceFromId(ownerHeroId);
               ownerHeroGO = go as HeroGameObjectOwner;
               if(ownerHeroGO)
               {
                  reviveTutorialPopupPosition = "TUTORIAL_PANEL_RIGHT";
                  if(ownerHeroGO.view.position.x < mHeroGameObject.view.position.x)
                  {
                     reviveTutorialPopupPosition = "TUTORIAL_PANEL_LEFT";
                  }
                  if(ownerHeroGO.heroStateMachine.currentStateName != "ActorReviveState")
                  {
                     destroyReviveTutorial();
                     mDungeonReviveTutorial = new DungeonTutorial(mDBFacade);
                     mDungeonReviveTutorial.showReviveTutorial(reviveTutorialPopupPosition);
                  }
               }
            }
         }
      }
      
      protected function checkIfHeroIsReadyAndInitReviveSensor(gameClock:GameClock) : void
      {
         var _loc2_:b2CircleShape = null;
         if(mHeroGameObject && mHeroGameObject.distributedDungeonFloor)
         {
            _loc2_ = new b2CircleShape(100 / 50);
            mReviveTrigger = new HeroReviveSensor(mDBFacade,mHeroGameObject.distributedDungeonFloor,_loc2_,mHeroGameObject.team);
            mReviveTrigger.position = mHeroGameObject.actorView.position;
            mReviveTrigger.callback = activateReviveUI;
            mReviveTrigger.finishedCallback = deActivateReviveUI;
            if(mLoadReviveTriggerTask)
            {
               mLoadReviveTriggerTask.destroy();
            }
            mLoadReviveTriggerTask = null;
         }
      }
      
      override public function exitState() : void
      {
         if(mHitTabTween)
         {
            mDBFacade.mTween.killTween(mHitTabTween);
         }
         mHitTabTween = null;
         if(mHitTabClip && mDBFacade.hud)
         {
            mDBFacade.hud.removeControllerIcons(mHitTabClip);
         }
         mSceneGraphComponent.removeChild(mHitTabClip);
         mHitTabClip = null;
         if(mHeroGameObject is HeroGameObjectOwner)
         {
            HeroGameObjectOwner(mHeroGameObject).stopDeathCamInput();
         }
         if(mActorView.hasAnimationRenderer() && mActorView.hasAnim("getUp"))
         {
            mActorView.playAnim("getUp",0,false,false);
            mActorGameObject.holdOneShotUntilMoving(mActorView.getAnimDurationInSeconds("getUp"));
         }
         mActorGameObject.playEffectAtActor("Resources/Art2D/FX/db_fx_library.swf","db_fx_revive",1,"foreground");
         mActorView.reviveHighlight();
         mLogicalWorkComponent.doLater(0.1,removeHighlight);
         mDBFacade.regainFocus();
         mActorView.actionsForExitDeadState();
         if(mDBFacade.hud)
         {
            mDBFacade.hud.offScreenPicChange(mHeroGameObject.id,"alive");
         }
         mLogicalWorkComponent.doLater(2,destroyReviveTutorial);
         this.destroyUI();
         super.exitState();
      }
      
      private function removeHighlight(gameClock:GameClock = null) : void
      {
         mActorView.reviveUnhighlight();
      }
      
      private function activateReviveUI(heroGameObjectOwner:HeroGameObjectOwner) : void
      {
         if(heroGameObjectOwner != mHeroGameObject)
         {
            mKeyBoardInputWanted = true;
            if(!mKeyBoardInput)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),function(param1:SwfAsset):void
               {
                  var _loc2_:Class = param1.getClass("db_fx_revive_spacebar");
                  mKeyBoardInput = new _loc2_();
                  refreshReviveKeyLabel();
                  if(mRevivePressed)
                  {
                     showRevivePressed(true);
                  }
                  mKeyBoardInput.x = mActorGameObject.position.x;
                  mKeyBoardInput.y = mActorGameObject.position.y;
                  mSceneGraphComponent.addChild(mKeyBoardInput,30);
                  applyUiHidden();
                  if(mDBFacade.steamInputManager.hasGlyphForAction("revive_ally"))
                  {
                     mKeyBoardInput.up.scaleX = 0.8;
                     mKeyBoardInput.over.scaleX = 0.8;
                     mKeyBoardInput.label.x += -15;
                     Locale.setText(mKeyBoardInput.label,"REVIVE_TRIGGER_BUTTON_CONTROLLER");
                     mDBFacade.hud.initControllerIcon("revive_ally",mKeyBoardInput,CONTROLLER_ICON_POSITION_FOR_REVIVE,CONTROLLER_GLYPH_SCALE_REVIVE);
                  }
               });
            }
            else
            {
               applyUiHidden();
            }
            if(mSpaceBarReviveDownFunction == null)
            {
               mSpaceBarReviveDownFunction = function(param1:Event):void
               {
                  reviveKeyEvent(param1,heroGameObjectOwner);
               };
            }
            if(mSpaceBarReviveUpFunction == null)
            {
               mSpaceBarReviveUpFunction = function(param1:Event):void
               {
                  reviveReleasedKeyEvent(param1,heroGameObjectOwner);
               };
            }
            mDBFacade.keyBindings.addChangeListener(onKeyBindingsChanged);
            removeReviveInputListeners();
            EventListeners.add(mDBFacade.stageRef,"keyDown",mSpaceBarReviveDownFunction);
            EventListeners.add(mDBFacade.stageRef,"UnboundActionEvent.PRESSED",mSpaceBarReviveDownFunction);
            EventListeners.add(mDBFacade.stageRef,"keyUp",mSpaceBarReviveUpFunction);
            EventListeners.add(mDBFacade.stageRef,"UnboundActionEvent.RELEASED",mSpaceBarReviveUpFunction);
         }
      }
      
      private function removeReviveInputListeners() : void
      {
         if(mSpaceBarReviveDownFunction != null)
         {
            EventListeners.remove(mDBFacade.stageRef,"keyDown",mSpaceBarReviveDownFunction);
            EventListeners.remove(mDBFacade.stageRef,"UnboundActionEvent.PRESSED",mSpaceBarReviveDownFunction);
         }
         if(mSpaceBarReviveUpFunction != null)
         {
            EventListeners.remove(mDBFacade.stageRef,"keyUp",mSpaceBarReviveUpFunction);
            EventListeners.remove(mDBFacade.stageRef,"UnboundActionEvent.RELEASED",mSpaceBarReviveUpFunction);
         }
      }
      
      private function refreshReviveKeyLabel() : void
      {
         if(mKeyBoardInput == null || mDBFacade.steamInputManager.hasGlyphForAction("revive_ally"))
         {
            return;
         }
         TextUtil.setText(mKeyBoardInput.label,Locale.getString("REVIVE_TRIGGER_BUTTON") + mDBFacade.keyBindings.displayNameFor("reviveAlly"));
      }
      
      private function onKeyBindingsChanged(action:String) : void
      {
         if(action != "reviveAlly")
         {
            return;
         }
         refreshReviveKeyLabel();
         showRevivePressed(false);
      }
      
      private function deActivateReviveUI() : void
      {
         mKeyBoardInputWanted = false;
         applyUiHidden();
         showRevivePressed(false);
         removeReviveInputListeners();
      }
      
      private function applyUiHidden() : void
      {
         var _loc1_:Boolean = mDBFacade.uiHideToggle.hidden;
         if(mDeadPlayerEffect)
         {
            mDeadPlayerEffect.visible = !_loc1_;
         }
         if(mKeyBoardInput)
         {
            mKeyBoardInput.visible = mKeyBoardInputWanted && !_loc1_;
         }
      }
      
      private function reviveKeyEvent(event:Event, heroOwner:HeroGameObjectOwner) : void
      {
         if(heroOwner != null && heroOwner.heroStateMachine != null && mHeroGameObject != null)
         {
            if(isReviveEvent(event) && didPressReviveAction() && heroOwner.heroStateMachine.currentSubState.name == "ActorNavigationState")
            {
               showRevivePressed(true);
               if(mSpaceBarTask)
               {
                  mSpaceBarTask.destroy();
               }
               mSpaceBarTask = null;
               heroOwner.attemptRevive(mHeroGameObject);
               if(!mDBFacade.dbAccountInfo.dbAccountParams.hasReviveTutorialParam() && mDungeonReviveTutorial)
               {
                  mEventComponent.dispatchEvent(new Event("REVIVE_SPACEBAR_PRESSED"));
               }
            }
         }
      }
      
      private function isReviveEvent(event:Event) : Boolean
      {
         var _loc2_:KeyboardEvent = event as KeyboardEvent;
         if(_loc2_ != null)
         {
            return mDBFacade.keyBindings.matches("reviveAlly",_loc2_.keyCode);
         }
         return UnboundActionEvent.isAction(event,"revive_ally");
      }
      
      private function reviveReleasedKeyEvent(event:Event, heroOwner:HeroGameObjectOwner) : void
      {
         if(!isReviveEvent(event))
         {
            return;
         }
         if(heroOwner != null && heroOwner.heroStateMachine != null && mHeroGameObject != null)
         {
            showRevivePressed(false);
         }
      }
      
      private function showRevivePressed(pressed:Boolean) : void
      {
         mRevivePressed = pressed;
         if(mKeyBoardInput == null)
         {
            return;
         }
         mKeyBoardInput.up.visible = !pressed;
         mKeyBoardInput.over.visible = pressed;
      }
      
      private function didPressReviveAction() : Boolean
      {
         return mDBFacade.keyBindings.wasPressed("reviveAlly") || mDBFacade.steamInputManager.pressedAction("revive_ally");
      }
      
      private function initRevive() : void
      {
      }
      
      private function loadDeadPlayerUI() : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_HUD.swf"),function(param1:SwfAsset):void
         {
            if(mHeroGameObject.distributedDungeonFloor.isInfiniteDungeon)
            {
               loadDeadPlayerUIStage2(param1);
            }
            else
            {
               buildOriginalPanel(param1);
            }
         });
      }
      
      private function loadDeadPlayerUIStage2(stage1Asset:SwfAsset) : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"),function(param1:SwfAsset):void
         {
            if(mHeroGameObject.distributedDungeonFloor.isInfiniteDungeon)
            {
               buildLimitedHealthBombUsageRevivePanel(stage1Asset,param1);
            }
            else
            {
               buildOriginalPanel(param1);
            }
         });
      }
      
      public function desaturate(obj:DisplayObject) : void
      {
         var _loc2_:Number = 0.212671;
         var _loc5_:Number = 0.71516;
         var _loc3_:Number = 0.072169;
         var _loc6_:Number = 0.7;
         var _loc4_:Number = 0.6;
         var _loc7_:Number = 0.5;
         var _loc8_:Array = [_loc2_ * _loc6_,_loc5_ * _loc6_,_loc3_ * _loc6_,0,0,_loc2_ * _loc4_,_loc5_ * _loc4_,_loc3_ * _loc4_,0,0,_loc2_ * _loc7_,_loc5_ * _loc7_,_loc3_ * _loc7_,0,0,0,0,0,1,0];
         obj.filters = [new ColorMatrixFilter(_loc8_)];
      }
      
      private function buildLimitedHealthBombUsageRevivePanel(swfAsset:SwfAsset, chestAsset:SwfAsset) : void
      {
         var reviveMeCallback:Function;
         var reviveAllCallback:Function;
         var partyBombsOwned:StackableInfo;
         var ownedHealthBombs:StackableInfo;
         var healthBombCount:uint;
         var partyBombCount:uint;
         var hitTabClass:Class;
         var rewardSlots:Vector.<MovieClip>;
         var myHero:HeroGameObjectOwner;
         var myRewards:Vector.<InfiniteRewardData>;
         var reward:InfiniteRewardData;
         var slotNumber:int;
         var alreadyReceived:Boolean;
         var dooberData:GMDoober;
         var gmChestItem:GMChest;
         var chestClass:Class;
         var dooberMC:MovieClip;
         var dooberController:MovieClipRenderController;
         var healthBombCostMultiplier:Number = 1;
         var offer:GMOffer = null;
         var assetClass:Class = swfAsset.getClass("revive_prompt");
         mRevivePanel = new assetClass();
         mRevivePanel.x = mDBFacade.viewWidth - mRevivePanel.width / 2.8;
         mRevivePanel.y += 169;
         mSceneGraphComponent.addChildAt(mRevivePanel,105,0);
         Locale.setText(mRevivePanel.prompt_heading,"REVIVE_PANEL_HEADER");
         if(mHeroGameObject.distributedDungeonFloor.remoteHeroes.size > 0)
         {
            Locale.setText(mRevivePanel.prompt_text_box,"REVIVE_PANEL_INNER_MULTI_PLAYER");
         }
         else
         {
            Locale.setText(mRevivePanel.prompt_text_box,"REVIVE_PANEL_INNER_SINGLE_PLAYER");
         }
         mSelfReviveMeButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_1_buy_me);
         mSelfReviveAllButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_1_buy_all);
         mReturnToTownButton = new UIButton(mDBFacade,mRevivePanel.prompt_button);
         mRevivePanel.prompt_button_1_buy_me.use_buy_me.text = "";
         mRevivePanel.prompt_button_1_buy_all.use_buy_me.text = "";
         Locale.setText(mRevivePanel.label_buy_me,"REVIVE_PANEL_SELF_REVIVE_BUTTON");
         Locale.setText(mRevivePanel.label_buy_all,"REVIVE_PANEL_PARTY_REVIVE_BUTTON");
         partyBombsOwned = mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(DBGlobal.PARTYBOMB_POTION_STACK_ID);
         offer = mDBFacade.gameMaster.offerById.itemFor(DBGlobal.PARTYBOMB_POTION_OFFER_ID);
         if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(DBGlobal.PARTYBOMB_POTION_STACK_ID) && partyBombsOwned)
         {
            mRevivePanel.prompt_button_1_buy_all.cost_text_buy_me.visible = false;
            mRevivePanel.prompt_button_1_buy_all.cash_icon_buy_me.visible = false;
            Locale.setText(mRevivePanel.prompt_button_1_buy_all.use_buy_me,"REVIVE_PANEL_USE");
            reviveAllCallback = function():void
            {
               hideRevivePanel();
               useRezAllPotion();
            };
         }
         else
         {
            mRevivePanel.prompt_button_1_buy_all.cost_text_buy_me.visible = true;
            Locale.setText(mRevivePanel.label_buy_all,"REVIVE_PANEL_PARTY_REVIVE_BUTTON_NO_REZ_FROG");
            healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
            if(healthBombCostMultiplier < 1 && 0)
            {
               mSelfReviveAllButton.destroy();
               mRevivePanel.prompt_button_1_buy_all.visible = false;
            }
            TextUtil.setText(mSelfReviveAllButton.root.cost_text_buy_me,offer.Price.toString());
            reviveAllCallback = function():void
            {
               if(offer.CurrencyType == GMOffer.PREMIUM_CURRENCY && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price)
               {
                  hideRevivePanel();
                  EventListeners.add(mRevivePanel,"purchaseReviveAll-failed",handleReviveAllPurchaseFail);
               }
               buyReviveAll();
            };
         }
         mSelfReviveAllButton.releaseCallback = reviveAllCallback;
         if(mHeroGameObject.canUsePartyBombs())
         {
            mSelfReviveAllButton.enabled = true;
            TextUtil.setText(mSelfReviveAllButton.root.cost_text_buy_me,offer.Price.toString());
         }
         else
         {
            mSelfReviveAllButton.enabled = false;
            Locale.setText(mSelfReviveAllButton.root.cost_text_buy_me,"REVIVE_PANEL_USED_MAX_PARTY_BOMBS_BUY_BUTTON_TEXT");
         }
         Locale.setText(mReturnToTownButton.label,"REVIVE_PANEL_FORFEIT_BUTTON");
         ownedHealthBombs = mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(DBGlobal.RESSURECTION_POTION_STACK_ID);
         healthBombCount = 0;
         if(ownedHealthBombs)
         {
            healthBombCount = ownedHealthBombs.count;
         }
         TextUtil.setText(mRevivePanel.quantity_hBomb,Locale.getString("LIMITED_REVIVES_PANEL_HBOMBS_OWNED") + ": " + healthBombCount.toString());
         partyBombCount = 0;
         if(partyBombsOwned)
         {
            partyBombCount = partyBombsOwned.count;
         }
         TextUtil.setText(mRevivePanel.quantity_pBomb,Locale.getString("LIMITED_REVIVES_PANEL_PBOMBS_OWNED") + ": " + partyBombCount.toString());
         offer = mDBFacade.gameMaster.offerById.itemFor(DBGlobal.RESSURECTION_POTION_OFFER_ID);
         if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(DBGlobal.RESSURECTION_POTION_STACK_ID) && ownedHealthBombs)
         {
            mRevivePanel.prompt_button_1_buy_me.cost_text_buy_me.visible = false;
            mRevivePanel.prompt_button_1_buy_me.cash_icon_buy_me.visible = false;
            Locale.setText(mRevivePanel.prompt_button_1_buy_me.use_buy_me,"REVIVE_PANEL_USE");
            reviveMeCallback = function():void
            {
               hideRevivePanel();
               useRezMePotion();
            };
         }
         else
         {
            mRevivePanel.prompt_button_1_buy_me.cost_text_buy_me.visible = true;
            Locale.setText(mRevivePanel.label_buy_me,"REVIVE_PANEL_SELF_REVIVE_BUTTON_NO_REZ_FROG");
            healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
            if(healthBombCostMultiplier < 1 && 0)
            {
               mSelfReviveMeButton.destroy();
               mRevivePanel.prompt_button_1_buy_me.visible = false;
               mSelfReviveMeButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_sale);
               TextUtil.setText(mSelfReviveMeButton.root.original_cost_text,Math.round(offer.Price / healthBombCostMultiplier).toString());
               mSelfReviveMeButton.root.strike.scaleX *= mSelfReviveMeButton.root.original_cost_text.text.length / 3;
            }
            TextUtil.setText(mSelfReviveMeButton.root.cost_text_buy_me,offer.Price.toString());
            reviveMeCallback = function():void
            {
               if(offer.CurrencyType == GMOffer.PREMIUM_CURRENCY && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price)
               {
                  hideRevivePanel();
               }
               buyReviveMe();
            };
         }
         mSelfReviveMeButton.releaseCallback = reviveMeCallback;
         if(mHeroGameObject.canUseHealthBombs())
         {
            mSelfReviveMeButton.enabled = true;
            TextUtil.setText(mSelfReviveMeButton.root.cost_text_buy_me,offer.Price.toString());
         }
         else
         {
            mSelfReviveMeButton.enabled = false;
            Locale.setText(mSelfReviveMeButton.root.cost_text_buy_me,"REVIVE_PANEL_USED_MAX_HEALTH_BOMBS_BUY_BUTTON_TEXT");
         }
         Locale.setText(mReturnToTownButton.label,"REVIVE_PANEL_FORFEIT_BUTTON");
         mReturnToTownButton.releaseCallback = function():void
         {
            var _loc2_:uint = mHeroGameObject.distributedDungeonFloor.completionXp;
            var _loc1_:II_UIExitDungeonPopUp = new II_UIExitDungeonPopUp(mDBFacade,onForfeitClick,null);
         };
         hitTabClass = swfAsset.getClass("popup_keyboard_tab");
         mHitTabClip = new hitTabClass() as MovieClip;
         mHitTabClip.x = -150;
         mHitTabClip.y = 250;
         Locale.setText(mHitTabClip.label,"HIT_TAB_TEXT");
         mSceneGraphComponent.addChildAt(mHitTabClip,105,0);
         mHitTabTween = mDBFacade.mTween.tweenMaxTo(mHitTabClip,0.5,{
            "x":20,
            "y":mHitTabClip.y
         });
         rewardSlots = new Vector.<MovieClip>();
         rewardSlots.push(mRevivePanel.current_reward.loot_01);
         rewardSlots.push(mRevivePanel.current_reward.loot_02);
         rewardSlots.push(mRevivePanel.current_reward.loot_03);
         rewardSlots.push(mRevivePanel.current_reward.loot_04);
         TextUtil.setText(mRevivePanel.current_reward.coin_count,mHeroGameObject.distributedDungeonFloor.parentArea.infiniteTotalGold.toString());
         myHero = mDBFacade.gameObjectManager.getReferenceFromId(mDBFacade.dbAccountInfo.activeAvatarInfo.id) as HeroGameObjectOwner;
         myRewards = myHero.distributedDungeonFloor.parentArea.infiniteRewardData;
         slotNumber = 0;
         for each(reward in myRewards)
         {
            if(slotNumber < rewardSlots.length)
            {
               alreadyReceived = false;
               if(reward.status == 1)
               {
                  alreadyReceived = true;
               }
               else
               {
                  if(reward.status == 0)
                  {
                     break;
                  }
                  if(reward.status == 3)
                  {
                     continue;
                  }
               }
               dooberData = mDBFacade.gameMaster.dooberById.itemFor(reward.dooberId);
               gmChestItem = mDBFacade.gameMaster.chestsById.itemFor(dooberData.ChestId);
               chestClass = chestAsset.getClass(gmChestItem.IconName);
               dooberMC = new chestClass();
               if(slotNumber == 0)
               {
                  dooberMC.scaleY = 0.4;
                  dooberMC.scaleX = 0.4;
                  dooberMC.x -= 2;
               }
               else
               {
                  dooberMC.scaleY = 0.51;
                  dooberMC.scaleX = 0.51;
               }
               if(alreadyReceived)
               {
                  desaturate(dooberMC);
               }
               dooberController = new MovieClipRenderController(mDBFacade,dooberMC);
               dooberController.loop = false;
               dooberController.stop();
               rewardSlots[slotNumber].addChild(dooberMC);
               rewardSlots[slotNumber].loot.visible = false;
            }
            slotNumber = slotNumber + 1;
         }
         if(mDBFacade.steamInputManager.hasGlyphForAction("revive_ally"))
         {
            mHitTabClip.tab.visible = false;
            mDBFacade.hud.initControllerIcon("revive_ally",mHitTabClip,CONTROLLER_ICON_POSITION_FOR_SPECTATE,CONTROLLER_GLYPH_SCALE_SPECTATE);
         }
         lockPanelButtons();
         mReviveMenuWanted = true;
         mSelfReviveMeButton.isAbove(mSelfReviveAllButton);
         mSelfReviveAllButton.isAbove(mReturnToTownButton);
         startPanelTask();
         setUpLimitedHealthBombGUI(mHeroGameObject.healthBombUsesRemaining,mRevivePanel);
         setUpLimitedPartyBombGUI(mHeroGameObject.partyBombUsesRemaining,mRevivePanel);
      }
      
      private function setUpLimitedHealthBombGUI(usageRemaining:uint, revivePanelClip:MovieClip) : void
      {
         revivePanelClip.hBomb01.visible = false;
         revivePanelClip.hBomb01_off.visible = true;
         revivePanelClip.hBomb02.visible = false;
         revivePanelClip.hBomb02_off.visible = true;
         revivePanelClip.hBomb03.visible = false;
         revivePanelClip.hBomb03_off.visible = true;
         switch(int(usageRemaining) - 1)
         {
            case 0:
               revivePanelClip.hBomb01.visible = true;
               revivePanelClip.hBomb01_off.visible = false;
               break;
            case 1:
               revivePanelClip.hBomb01.visible = true;
               revivePanelClip.hBomb01_off.visible = false;
               revivePanelClip.hBomb02.visible = true;
               revivePanelClip.hBomb02_off.visible = false;
               break;
            case 2:
               revivePanelClip.hBomb01.visible = true;
               revivePanelClip.hBomb01_off.visible = false;
               revivePanelClip.hBomb02.visible = true;
               revivePanelClip.hBomb02_off.visible = false;
               revivePanelClip.hBomb03.visible = true;
               revivePanelClip.hBomb03_off.visible = false;
         }
      }
      
      private function setUpLimitedPartyBombGUI(usageRemaining:uint, revivePanelClip:MovieClip) : void
      {
         revivePanelClip.pBomb01.visible = false;
         revivePanelClip.pBomb01_off.visible = true;
         revivePanelClip.pBomb02.visible = false;
         revivePanelClip.pBomb02_off.visible = true;
         revivePanelClip.pBomb03.visible = false;
         revivePanelClip.pBomb03_off.visible = true;
         switch(int(usageRemaining) - 1)
         {
            case 0:
               revivePanelClip.pBomb01.visible = true;
               revivePanelClip.pBomb01_off.visible = false;
               break;
            case 1:
               revivePanelClip.pBomb01.visible = true;
               revivePanelClip.pBomb01_off.visible = false;
               revivePanelClip.pBomb02.visible = true;
               revivePanelClip.pBomb02_off.visible = false;
               break;
            case 2:
               revivePanelClip.pBomb01.visible = true;
               revivePanelClip.pBomb01_off.visible = false;
               revivePanelClip.pBomb02.visible = true;
               revivePanelClip.pBomb02_off.visible = false;
               revivePanelClip.pBomb03.visible = true;
               revivePanelClip.pBomb03_off.visible = false;
         }
      }
      
      private function buildOriginalPanel(swfAsset:SwfAsset) : void
      {
         var healthBomb:StackableInfo;
         var REVIVE_MENU_SCALE:Number;
         var king:DisplayObject;
         var kingBounds:Rectangle;
         var reviveMeCallback:Function;
         var reviveAllCallback:Function;
         var partyBomb:StackableInfo;
         var hitTabClass:Class;
         var healthBombCostMultiplier:Number = 1;
         var offer:GMOffer = null;
         var assetClass:Class = swfAsset.getClass("DR_revive_prompt");
         mRevivePanel = new assetClass();
         mCloseButton = new UIButton(mDBFacade,mRevivePanel.revive_king.revive_chat_balloon.close);
         mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mCloseButton.releaseCallback = function():void
         {
            mRevivePanel.removeChild(mRevivePanel.revive_king);
         };
         mRevivePanel.revive_king.revive_chat_balloon.king_title = Locale.getString("KING_REVIVE_TITLE");
         mRevivePanel.revive_king.revive_chat_balloon.king_text = Locale.getString("KING_REVIVE_MESSAGE");
         mSceneGraphComponent.addChildAt(mRevivePanel,105,0);
         mRevivePanel.scaleX = mRevivePanel.scaleY = 1.8;
         mRevivePanel.x = mDBFacade.viewWidth - mRevivePanel.width / 2;
         mRevivePanel.y = mDBFacade.viewHeight - mRevivePanel.height / 2;
         king = mRevivePanel.revive_king as DisplayObject;
         king.scaleX = king.scaleY = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE / 1.8;
         kingBounds = king.getBounds(mRevivePanel.parent);
         king.x += (0 - kingBounds.left) / 1.8;
         king.y += (mDBFacade.viewHeight - kingBounds.bottom) / 1.8;
         Locale.setText(mRevivePanel.prompt_heading,"REVIVE_PANEL_HEADER");
         if(mHeroGameObject.distributedDungeonFloor.remoteHeroes.size > 0)
         {
            Locale.setText(mRevivePanel.prompt_text_box,"REVIVE_PANEL_INNER_MULTI_PLAYER");
         }
         else
         {
            Locale.setText(mRevivePanel.prompt_text_box,"REVIVE_PANEL_INNER_SINGLE_PLAYER");
         }
         mSelfReviveMeButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_1_buy_me);
         mSelfReviveAllButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_1_buy_all);
         mReturnToTownButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_2);
         mRevivePanel.prompt_button_1_buy_me.use_buy_me.text = "";
         mRevivePanel.prompt_button_1_buy_all.use_buy_all.text = "";
         mRevivePanel.prompt_button_1_buy_me.stackable_buy_me.text = "";
         Locale.setText(mRevivePanel.label_buy_me,"REVIVE_PANEL_SELF_REVIVE_BUTTON");
         Locale.setText(mRevivePanel.label_buy_all,"REVIVE_PANEL_PARTY_REVIVE_BUTTON");
         partyBomb = mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(DBGlobal.PARTYBOMB_POTION_STACK_ID);
         offer = mDBFacade.gameMaster.offerById.itemFor(DBGlobal.PARTYBOMB_POTION_OFFER_ID);
         if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(DBGlobal.PARTYBOMB_POTION_STACK_ID) && partyBomb)
         {
            TextUtil.setText(mRevivePanel.prompt_button_1_buy_all.stackable_buy_all,"X" + partyBomb.count.toString());
            mRevivePanel.prompt_button_1_buy_all.cost_text_buy_all.visible = false;
            mRevivePanel.prompt_button_1_buy_all.cash_icon_buy_me.visible = false;
            Locale.setText(mRevivePanel.prompt_button_1_buy_all.use_buy_all,"REVIVE_PANEL_USE");
            reviveAllCallback = function():void
            {
               hideRevivePanel();
               useRezAllPotion();
            };
         }
         else
         {
            mRevivePanel.prompt_button_1_buy_all.cost_text_buy_all.visible = true;
            mRevivePanel.prompt_button_1_buy_all.stackable_buy_all.visible = false;
            Locale.setText(mRevivePanel.label_buy_all,"REVIVE_PANEL_PARTY_REVIVE_BUTTON_NO_REZ_FROG");
            healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
            if(healthBombCostMultiplier < 1 && 0)
            {
               mSelfReviveAllButton.destroy();
               mRevivePanel.prompt_button_1_buy_all.visible = false;
            }
            TextUtil.setText(mRevivePanel.prompt_button_1_buy_all.stackable_buy_all,"0");
            TextUtil.setText(mSelfReviveAllButton.root.cost_text_buy_all,offer.Price.toString());
            reviveAllCallback = function():void
            {
               if(offer.CurrencyType == GMOffer.PREMIUM_CURRENCY && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price)
               {
                  hideRevivePanel();
                  EventListeners.add(mRevivePanel,"purchaseReviveAll-failed",handleReviveAllPurchaseFail);
               }
               buyReviveAll();
            };
         }
         mSelfReviveAllButton.releaseCallback = reviveAllCallback;
         if(mHeroGameObject.canUsePartyBombs())
         {
            mSelfReviveAllButton.enabled = true;
            TextUtil.setText(mSelfReviveAllButton.root.cost_text_buy_all,offer.Price.toString());
         }
         else
         {
            mSelfReviveAllButton.enabled = false;
            Locale.setText(mSelfReviveAllButton.root.cost_text_buy_all,"REVIVE_PANEL_USED_MAX_PARTY_BOMBS_BUY_BUTTON_TEXT");
         }
         Locale.setText(mReturnToTownButton.label,"REVIVE_PANEL_FORFEIT_BUTTON");
         healthBomb = mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(DBGlobal.RESSURECTION_POTION_STACK_ID);
         offer = mDBFacade.gameMaster.offerById.itemFor(DBGlobal.RESSURECTION_POTION_OFFER_ID);
         if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(DBGlobal.RESSURECTION_POTION_STACK_ID) && healthBomb)
         {
            TextUtil.setText(mRevivePanel.prompt_button_1_buy_me.stackable_buy_me,"X" + healthBomb.count.toString());
            mRevivePanel.prompt_button_1_buy_me.cost_text_buy_me.visible = false;
            mRevivePanel.prompt_button_1_buy_me.cash_icon_buy_me.visible = false;
            Locale.setText(mRevivePanel.prompt_button_1_buy_me.use_buy_me,"REVIVE_PANEL_USE");
            reviveMeCallback = function():void
            {
               hideRevivePanel();
               useRezMePotion();
            };
         }
         else
         {
            mRevivePanel.prompt_button_1_buy_me.cost_text_buy_me.visible = true;
            mRevivePanel.prompt_button_1_buy_me.stackable_buy_me.visible = false;
            Locale.setText(mRevivePanel.label_buy_me,"REVIVE_PANEL_SELF_REVIVE_BUTTON_NO_REZ_FROG");
            healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
            if(healthBombCostMultiplier < 1 && 0)
            {
               mSelfReviveMeButton.destroy();
               mRevivePanel.prompt_button_1_buy_me.visible = false;
               mSelfReviveMeButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_sale);
               TextUtil.setText(mSelfReviveMeButton.root.original_cost_text,Math.round(offer.Price / healthBombCostMultiplier).toString());
               mSelfReviveMeButton.root.strike.scaleX *= mSelfReviveMeButton.root.original_cost_text.text.length / 3;
            }
            TextUtil.setText(mRevivePanel.prompt_button_1_buy_me.stackable_buy_me,"0");
            TextUtil.setText(mSelfReviveMeButton.root.cost_text_buy_me,offer.Price.toString());
            reviveMeCallback = function():void
            {
               if(offer.CurrencyType == GMOffer.PREMIUM_CURRENCY && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price)
               {
                  hideRevivePanel();
               }
               buyReviveMe();
            };
         }
         mSelfReviveMeButton.releaseCallback = reviveMeCallback;
         if(mHeroGameObject.canUseHealthBombs())
         {
            mSelfReviveMeButton.enabled = true;
            TextUtil.setText(mSelfReviveMeButton.root.cost_text_buy_me,offer.Price.toString());
         }
         else
         {
            mSelfReviveMeButton.enabled = false;
            Locale.setText(mSelfReviveMeButton.root.cost_text_buy_me,"REVIVE_PANEL_USED_MAX_HEALTH_BOMBS_BUY_BUTTON_TEXT");
         }
         Locale.setText(mReturnToTownButton.label,"REVIVE_PANEL_FORFEIT_BUTTON");
         mReturnToTownButton.releaseCallback = function():void
         {
            var _loc2_:uint = mHeroGameObject.distributedDungeonFloor.completionXp;
            var _loc1_:UILootLossPopup = new UILootLossPopup(mDBFacade,_loc2_,mHeroGameObject.distributedDungeonFloor.treasureCollected,onForfeitClick,null);
            MemoryTracker.track(_loc1_,"UILootLossPopup - created in ActorReviveState.loadedAssets()");
         };
         hitTabClass = swfAsset.getClass("popup_keyboard_tab");
         mHitTabClip = new hitTabClass() as MovieClip;
         mHitTabClip.x = -150;
         mHitTabClip.y = 250;
         Locale.setText(mHitTabClip.label,"HIT_TAB_TEXT");
         mSceneGraphComponent.addChildAt(mHitTabClip,105,0);
         mHitTabTween = mDBFacade.mTween.tweenMaxTo(mHitTabClip,0.5,{
            "x":20,
            "y":mHitTabClip.y
         });
         if(mDBFacade.steamInputManager.hasGlyphForAction("revive_ally"))
         {
            mHitTabClip.tab.visible = false;
            mDBFacade.hud.initControllerIcon("revive_ally",mHitTabClip,CONTROLLER_ICON_POSITION_FOR_SPECTATE,CONTROLLER_GLYPH_SCALE_SPECTATE);
         }
         lockPanelButtons();
         mReviveMenuWanted = true;
         mSelfReviveMeButton.isToTheLeftOf(mSelfReviveAllButton);
         mSelfReviveMeButton.isAbove(mReturnToTownButton);
         startPanelTask();
      }
      
      private function get chatBarButtons() : Array
      {
         var _loc1_:UIChatLog = mDBFacade.hud != null ? mDBFacade.hud.chatLog : null;
         if(_loc1_ == null || _loc1_.chatLogButton == null || _loc1_.chatSendButton == null)
         {
            return [];
         }
         var _loc2_:Array = [_loc1_.chatLogButton,_loc1_.chatSendButton];
         if(_loc2_[1].root.localToGlobal(new Point()).x < _loc2_[0].root.localToGlobal(new Point()).x)
         {
            _loc2_.reverse();
         }
         return _loc2_;
      }
      
      private function linkChatBar() : void
      {
         var _loc3_:Array = chatBarButtons;
         if(_loc3_.length == mLinkedChatButtons.length && (_loc3_.length == 0 || _loc3_[0] == mLinkedChatButtons[0]))
         {
            return;
         }
         var _loc2_:MenuNavigationController = mDBFacade.menuNavigationController;
         var _loc4_:int = int(_loc2_.getTopUILayer() == "REVIVE_MENU" ? mLinkedChatButtons.indexOf(_loc2_.focusedUiObject) : -1);
         unlinkChatBar();
         if(_loc3_.length == 0 || mReturnToTownButton == null)
         {
            return;
         }
         var _loc5_:UIButton = _loc3_[0];
         var _loc6_:UIButton = _loc3_[1];
         for each(var _loc1_:UIButton in _loc3_)
         {
            _loc1_.clearNavigationAndInteractions();
         }
         mReturnToTownButton.isAbove(_loc5_);
         _loc6_.upNavigation = mReturnToTownButton;
         _loc5_.isToTheLeftOf(_loc6_);
         mLinkedChatButtons = _loc3_;
         if(mDBFacade.hud != null)
         {
            mDBFacade.hud.useFlashChatBar(true);
         }
         if(mBombButtonLockTask != null)
         {
            lockChatBar();
         }
         if(_loc4_ >= 0)
         {
            _loc2_.setFocusedUiObject(_loc3_[_loc4_]);
         }
      }
      
      private function unlinkChatBar() : void
      {
         unlockChatBar();
         if(mLinkedChatButtons.length > 0 && mDBFacade.hud != null)
         {
            mDBFacade.hud.useFlashChatBar(false);
         }
         for each(var _loc1_:UIButton in mLinkedChatButtons)
         {
            if(_loc1_.root != null)
            {
               _loc1_.clearNavigationAndInteractions();
            }
         }
         if(mReturnToTownButton != null && mReturnToTownButton.root != null)
         {
            mReturnToTownButton.clearDownNavigation();
         }
         mLinkedChatButtons = [];
      }
      
      private function setLockedLook(button:UIButton, locked:Boolean) : void
      {
         if(button == null || button.root == null)
         {
            return;
         }
         var _loc3_:DisplayObject = button.root.getChildByName("up");
         if(_loc3_ == null)
         {
            _loc3_ = button.root;
         }
         button.enabled = !locked;
         _loc3_.filters = locked ? [DISABLED_LOOK] : [];
      }
      
      private function lockChatBar() : void
      {
         for each(var _loc1_:UIButton in mLinkedChatButtons)
         {
            setLockedLook(_loc1_,true);
         }
         mChatBarLocked = true;
      }
      
      private function unlockChatBar() : void
      {
         if(!mChatBarLocked)
         {
            return;
         }
         mChatBarLocked = false;
         for each(var _loc1_:UIButton in mLinkedChatButtons)
         {
            setLockedLook(_loc1_,false);
         }
      }
      
      private function openExitConfirmation() : void
      {
         if(mDBFacade.inputManager.check(27) && !mDBFacade.inputManager.pressed(27))
         {
            return;
         }
         var _loc1_:Function = mReturnToTownButton != null ? mReturnToTownButton.releaseCallback : null;
         if(_loc1_ != null)
         {
            _loc1_();
         }
      }
      
      private function startPanelTask() : void
      {
         linkChatBar();
         pushReviveMenuWhenFree(false);
         if(mPanelTask)
         {
            mPanelTask.destroy();
         }
         mPanelTask = mLogicalWorkComponent.doEveryFrame(function(param1:GameClock):void
         {
            pushReviveMenuWhenFree(true);
            linkChatBar();
            if(mLinkedChatButtons.length > 0 && mDBFacade.hud != null)
            {
               mDBFacade.hud.useFlashChatBar(true);
            }
            if(mDBFacade.hud != null && mDBFacade.keyBindings != null && mDBFacade.keyBindings.wasReleased("openOptionsMenu"))
            {
               mDBFacade.hud.handleMenuButtonPressed(1);
            }
         });
      }
      
      private function pushReviveMenuWhenFree(deferred:Boolean) : void
      {
         if(!mReviveMenuWanted || mDBFacade.menuNavigationController.layerDepth > 0)
         {
            return;
         }
         mReviveMenuWanted = false;
         if(deferred && mBombButtonLockTask == null)
         {
            lockPanelButtons();
         }
         mDBFacade.menuNavigationController.pushNewLayer("REVIVE_MENU",openExitConfirmation,mSelfReviveMeButton);
      }
      
      private function hideRevivePanel() : void
      {
         mRevivePanel.visible = false;
         mReviveMenuWanted = false;
         removeReviveMenuLayer();
         unlinkChatBar();
      }
      
      private function removeReviveMenuLayer() : void
      {
         if(!(mHeroGameObject is HeroGameObjectOwner))
         {
            return;
         }
         mDBFacade.menuNavigationController.removeLayer("REVIVE_MENU");
      }
      
      private function lockPanelButtons() : void
      {
         var reviveMeEnabled:Boolean = mSelfReviveMeButton.enabled;
         var reviveAllEnabled:Boolean = mSelfReviveAllButton.enabled;
         mSelfReviveMeButton.enabled = false;
         mSelfReviveAllButton.enabled = false;
         setLockedLook(mReturnToTownButton,true);
         lockChatBar();
         if(mBombButtonLockTask)
         {
            mBombButtonLockTask.destroy();
         }
         mBombButtonLockTask = mLogicalWorkComponent.doLater(2,function(param1:GameClock = null):void
         {
            mBombButtonLockTask = null;
            if(mSelfReviveMeButton)
            {
               mSelfReviveMeButton.enabled = reviveMeEnabled;
            }
            if(mSelfReviveAllButton)
            {
               mSelfReviveAllButton.enabled = reviveAllEnabled;
            }
            setLockedLook(mReturnToTownButton,false);
            unlockChatBar();
         });
      }
      
      private function popForfeitConfirmLayer() : void
      {
         if(mDBFacade.menuNavigationController.getTopUILayer() == "EXIT_DUNGEON")
         {
            mDBFacade.menuNavigationController.popLayer("EXIT_DUNGEON");
         }
         if(mDBFacade.menuNavigationController.getTopUILayer() == "EXIT_INFINITE_DUNGEON")
         {
            mDBFacade.menuNavigationController.popLayer("EXIT_INFINITE_DUNGEON");
         }
      }
      
      protected function handleReviveAllPurchaseFail(event:Event) : void
      {
         hideRevivePanel();
      }
      
      private function getHealthBombSplitTestMultiplier() : Number
      {
         return mDBFacade.getSplitTestNumber("InDungeonHealthBombSale",1);
      }
      
      private function startLogMetrics(buttonText:String) : void
      {
         var _loc2_:Object = {};
         _loc2_.buttonDesc = buttonText;
         _loc2_.areaType = "Dungeon";
         logMetrics("ButtonClick",_loc2_);
      }
      
      private function onForfeitClick() : void
      {
         var metricsObject:Object = {};
         metricsObject.buttonDesc = "Revive Exit Button Clicked";
         metricsObject.areaType = "Dungeon";
         logMetrics("ButtonClick",metricsObject);
         popForfeitConfirmLayer();
         Logger.debug("ActorReviveState -- Starting Clean Shutdown");
         mLogicalWorkComponent.doLater(5,function():void
         {
            mDBFacade.mainStateMachine.enterReloadTownState();
         });
         mDBFacade.mDistributedObjectManager.mMatchMaker.RequestExit();
         if(mDBFacade.hud.chatLog != null)
         {
            mDBFacade.hud.chatLog.hideChatLog();
         }
         this.destroyUI();
      }
      
      public function useRezMePotion() : void
      {
         startLogMetrics("Rez Potion Button Clicked");
         (mHeroGameObject as HeroGameObjectOwner).proposeSelfRevive(0);
      }
      
      public function buyReviveMe() : void
      {
         startLogMetrics("Buy Revive Button Clicked");
         var _loc1_:GMOffer = mDBFacade.gameMaster.offerById.itemFor(DBGlobal.RESSURECTION_POTION_OFFER_ID);
         StoreServicesController.tryBuyOffer(mDBFacade,_loc1_,buyReviveMeSuccess);
      }
      
      public function buyReviveMeSuccess(details:*) : void
      {
         (mHeroGameObject as HeroGameObjectOwner).proposeSelfRevive(0);
      }
      
      public function useRezAllPotion() : void
      {
         startLogMetrics("Rez Potion Button Clicked");
         (mHeroGameObject as HeroGameObjectOwner).proposeSelfRevive(1);
      }
      
      public function buyReviveAll() : void
      {
         startLogMetrics("Buy Revive Button Clicked");
         var _loc1_:GMOffer = mDBFacade.gameMaster.offerById.itemFor(DBGlobal.PARTYBOMB_POTION_OFFER_ID);
         StoreServicesController.tryBuyOffer(mDBFacade,_loc1_,buyReviveAllSuccess);
      }
      
      public function buyReviveAllSuccess(details:*) : void
      {
         (mHeroGameObject as HeroGameObjectOwner).proposeSelfRevive(1);
      }
      
      public function destroyUI() : void
      {
         removeReviveMenuLayer();
         if(mHeroGameObject is HeroGameObjectOwner)
         {
            unlinkChatBar();
         }
         if(mHeroGameObject is HeroGameObjectOwner)
         {
            saturate(100);
         }
         if(mLoadReviveTriggerTask)
         {
            mLoadReviveTriggerTask.destroy();
            mLoadReviveTriggerTask = null;
         }
         if(mSpaceBarTask)
         {
            mSpaceBarTask.destroy();
            mSpaceBarTask = null;
         }
         if(mBombButtonLockTask)
         {
            mBombButtonLockTask.destroy();
            mBombButtonLockTask = null;
         }
         if(mPanelTask)
         {
            mPanelTask.destroy();
            mPanelTask = null;
         }
         mReviveMenuWanted = false;
         if(mDeadPlayerEffect)
         {
            if(mHeroGameObject.view.root.contains(mDeadPlayerEffect))
            {
               mHeroGameObject.view.root.removeChild(mDeadPlayerEffect);
            }
            mDeadPlayerEffect = null;
         }
         if(mKeyBoardInput)
         {
            if(mDBFacade.hud)
            {
               mDBFacade.hud.removeControllerIcons(mKeyBoardInput);
            }
            mSceneGraphComponent.removeChild(mKeyBoardInput);
            mKeyBoardInput = null;
         }
         mKeyBoardInputWanted = false;
         mRevivePressed = false;
         if(mDBFacade.keyBindings != null)
         {
            mDBFacade.keyBindings.removeChangeListener(onKeyBindingsChanged);
         }
         removeReviveInputListeners();
         mSpaceBarReviveDownFunction = null;
         mSpaceBarReviveUpFunction = null;
         if(mReviveTrigger)
         {
            mReviveTrigger.destroy();
            mReviveTrigger = null;
         }
         if(mRevivePanel)
         {
            mSceneGraphComponent.removeChild(mRevivePanel);
            if(mSelfReviveMeButton)
            {
               mSelfReviveMeButton.destroy();
               mSelfReviveMeButton = null;
            }
            if(mSelfReviveAllButton)
            {
               mSelfReviveAllButton.destroy();
               mSelfReviveAllButton = null;
            }
            if(mReturnToTownButton)
            {
               mReturnToTownButton.destroy();
               mReturnToTownButton = null;
            }
            if(mCloseButton)
            {
               mCloseButton.destroy();
               mCloseButton = null;
            }
            mRevivePanel = null;
         }
      }
      
      private function destroyReviveTutorial(gameClock:GameClock = null) : void
      {
         if(mDungeonReviveTutorial)
         {
            mDungeonReviveTutorial.destroy();
         }
         mDungeonReviveTutorial = null;
      }
      
      override public function destroy() : void
      {
         this.destroyUI();
         mHeroGameObject = null;
         destroyReviveTutorial();
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mEventComponent.destroy();
         mEventComponent = null;
         super.destroy();
      }
      
      public function logMetrics(eventName:String, metricsObject:Object) : void
      {
         metricsObject.areaId = mHeroGameObject.distributedDungeonFloor.id;
         mDBFacade.metrics.log(eventName,metricsObject);
      }
      
      private function saturate(value:Number) : void
      {
         var _loc2_:Array = [50,105];
         mSceneGraphComponent.saturateLayers(value,_loc2_);
      }
   }
}

