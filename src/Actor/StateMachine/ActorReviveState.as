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
   import Brain.GameObject.GameObject;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UICircularProgressBar;
   import Brain.Utils.MemoryTracker;
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
   import StateMachine.MainStateMachine.DungeonTutorial;
   import UI.InfiniteIsland.II_UIExitDungeonPopUp;
   import UI.Popup.UILootLossPopup;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.filters.ColorMatrixFilter;
   
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
      
      private static const REVIVE_KEYCODE:int = 32;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mEventComponent:EventComponent;
      
      protected var mOffScreenBootTimer:UICircularProgressBar;
      
      protected var mPopupBootTimer:UICircularProgressBar;
      
      protected var mPopupBootTimerTask:Task;
      
      protected var mDestroyTimerTask:Task;
      
      protected var mSpaceBarTask:Task;
      
      protected var mLoadReviveTriggerTask:Task;
      
      protected var mRevivePanel:MovieClip;
      
      protected var mSelfReviveMeButton:UIButton;
      
      protected var mSelfReviveAllButton:UIButton;
      
      protected var mReturnToTownButton:UIButton;
      
      protected var mDeadPlayerEffect:MovieClip;
      
      protected var mKeyBoardInput:MovieClip;
      
      protected var mMouseInput:MovieClip;
      
      protected var mReviveTrigger:HeroReviveSensor;
      
      protected var mHeroGameObject:HeroGameObject;
      
      protected var mSpaceBarReviveFunction:Function;
      
      private var mDungeonReviveTutorial:DungeonTutorial;
      
      private var mDeathCount:uint = 0;
      
      private var mHitTabClip:MovieClip;
      
      private var mHitTabTween:TweenMax;
      
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
               mRevivePanel.visible = false;
            }
         });
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
            var swfAsset:SwfAsset = param1;
            var assetClass:Class = swfAsset.getClass("UI_widget");
            mDeadPlayerEffect = new assetClass();
            mDeadPlayerEffect.y += -100;
            mDeadPlayerEffect.NametagText.text = "";
            mDeadPlayerEffect.AlertText.text = Locale.getString("NAMETAG_RESCUE");
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Avatars/db_icons_avatars.swf"),function(param1:SwfAsset):void
            {
               var _loc3_:Class = param1.getClass("death_icon");
               var _loc2_:MovieClip = new _loc3_();
               _loc2_.name = "revivePic";
               mDeadPlayerEffect.UI_avatar.addChild(_loc2_);
            });
            mDeadPlayerEffect.UI_arrow.visible = false;
            mDeadPlayerEffect.name = "deadEffect";
            mHeroGameObject.view.root.addChildAt(mDeadPlayerEffect,0);
         });
         if(mDBFacade.hud.offScreenPlayerManager)
         {
            mDBFacade.hud.offScreenPlayerManager.handlePicChange(mHeroGameObject.id,"REVIVE");
         }
         if(mHeroGameObject is HeroGameObjectOwner)
         {
            mDeathCount = mDeathCount + 1;
            if(mDBFacade.facebookController && mDeathCount >= 10 && !mDBFacade.dbConfigManager.getConfigBoolean("FUFB",false))
            {
               mDBFacade.facebookController.updateGuestAchievement(6);
            }
            saturate(25);
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
            mHitTabTween.kill();
         }
         mHitTabTween = null;
         mSceneGraphComponent.removeChild(mHitTabClip);
         mHitTabClip = null;
         if(mHeroGameObject is HeroGameObjectOwner)
         {
            HeroGameObjectOwner(mHeroGameObject).stopDeathCamInput();
         }
         mActorView.playAnim("revive",0,false,false);
         mActorGameObject.playEffectAtActor("Resources/Art2D/FX/db_fx_library.swf","db_fx_revive",1,"foreground");
         mActorView.reviveHighlight();
         mLogicalWorkComponent.doLater(0.1,removeHighlight);
         mDBFacade.regainFocus();
         mActorView.actionsForExitDeadState();
         if(mDBFacade.hud.offScreenPlayerManager)
         {
            mDBFacade.hud.offScreenPlayerManager.handlePicChange(mHeroGameObject.id,"alive");
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
            if(!mKeyBoardInput)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),function(param1:SwfAsset):void
               {
                  var _loc2_:Class = param1.getClass("db_fx_revive_spacebar");
                  mKeyBoardInput = new _loc2_();
                  mKeyBoardInput.label.text = Locale.getString("REVIVE_TRIGGER_BUTTON");
                  mKeyBoardInput.x = mActorGameObject.position.x;
                  mKeyBoardInput.y = mActorGameObject.position.y;
                  mSceneGraphComponent.addChild(mKeyBoardInput,30);
               });
            }
            else
            {
               mKeyBoardInput.visible = true;
            }
            if(mSpaceBarReviveFunction == null)
            {
               mSpaceBarReviveFunction = function(param1:KeyboardEvent):void
               {
                  reviveKeyEvent(param1,heroGameObjectOwner);
               };
            }
            mDBFacade.stageRef.removeEventListener("keyDown",mSpaceBarReviveFunction);
            mDBFacade.stageRef.addEventListener("keyDown",mSpaceBarReviveFunction);
         }
      }
      
      private function deActivateReviveUI() : void
      {
         if(mKeyBoardInput)
         {
            mKeyBoardInput.visible = false;
         }
         if(mSpaceBarReviveFunction != null)
         {
            mDBFacade.stageRef.removeEventListener("keyDown",mSpaceBarReviveFunction);
         }
      }
      
      private function reviveKeyEvent(event:KeyboardEvent, heroOwner:HeroGameObjectOwner) : void
      {
         if(heroOwner != null && heroOwner.heroStateMachine != null && mHeroGameObject != null)
         {
            if(event.keyCode == 32 && didPressReviveAction() && heroOwner.heroStateMachine.currentSubState.name == "ActorNavigationState")
            {
               if(mSpaceBarTask)
               {
                  mSpaceBarTask.destroy();
               }
               mSpaceBarTask = null;
               heroOwner.attemptRevive(mHeroGameObject);
               if(mDBFacade.facebookController && heroOwner.playerID == mDBFacade.accountId)
               {
                  mDBFacade.facebookController.updateGuestAchievement(3);
               }
               if(!mDBFacade.dbAccountInfo.dbAccountParams.hasReviveTutorialParam() && mDungeonReviveTutorial)
               {
                  mEventComponent.dispatchEvent(new Event("REVIVE_SPACEBAR_PRESSED"));
               }
            }
         }
      }
      
      private function didPressReviveAction() : Boolean
      {
         return mDBFacade.inputManager.pressed(32) || mDBFacade.steamInputManager.pressedAction("revive_ally");
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
         var assetClass:Class = null;
         assetClass = swfAsset.getClass("revive_prompt");
         mRevivePanel = new assetClass();
         mRevivePanel.x = mDBFacade.stageRef.stageWidth - mRevivePanel.width / 2.8;
         mRevivePanel.y += 169;
         mSceneGraphComponent.addChildAt(mRevivePanel,105,0);
         mRevivePanel.prompt_heading.text = Locale.getString("REVIVE_PANEL_HEADER");
         if(mHeroGameObject.distributedDungeonFloor.remoteHeroes.size > 0)
         {
            mRevivePanel.prompt_text_box.text = Locale.getString("REVIVE_PANEL_INNER_MULTI_PLAYER");
         }
         else
         {
            mRevivePanel.prompt_text_box.text = Locale.getString("REVIVE_PANEL_INNER_SINGLE_PLAYER");
         }
         mSelfReviveMeButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_1_buy_me);
         mSelfReviveAllButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_1_buy_all);
         mReturnToTownButton = new UIButton(mDBFacade,mRevivePanel.prompt_button);
         mRevivePanel.prompt_button_1_buy_me.use_buy_me.text = "";
         mRevivePanel.prompt_button_1_buy_all.use_buy_me.text = "";
         mRevivePanel.label_buy_me.text = Locale.getString("REVIVE_PANEL_SELF_REVIVE_BUTTON");
         mRevivePanel.label_buy_all.text = Locale.getString("REVIVE_PANEL_PARTY_REVIVE_BUTTON");
         partyBombsOwned = mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(60018);
         offer = mDBFacade.gameMaster.offerById.itemFor(51369);
         if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(60018) && partyBombsOwned)
         {
            mRevivePanel.prompt_button_1_buy_all.cost_text_buy_me.visible = false;
            mRevivePanel.prompt_button_1_buy_all.cash_icon_buy_me.visible = false;
            mRevivePanel.prompt_button_1_buy_all.use_buy_me.text = Locale.getString("REVIVE_PANEL_USE");
            reviveAllCallback = function():void
            {
               mRevivePanel.visible = false;
               useRezAllPotion();
            };
         }
         else
         {
            mRevivePanel.prompt_button_1_buy_all.cost_text_buy_me.visible = true;
            mRevivePanel.label_buy_all.text = Locale.getString("REVIVE_PANEL_PARTY_REVIVE_BUTTON_NO_REZ_FROG");
            healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
            if(healthBombCostMultiplier < 1 && 0)
            {
               mSelfReviveAllButton.destroy();
               mRevivePanel.prompt_button_1_buy_all.visible = false;
            }
            mSelfReviveAllButton.root.cost_text_buy_me.text = offer.Price.toString();
            reviveAllCallback = function():void
            {
               if(offer.CurrencyType == "PREMIUM" && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price)
               {
                  mRevivePanel.visible = false;
                  mRevivePanel.addEventListener("purchaseReviveAll-failed",handleReviveAllPurchaseFail);
               }
               buyReviveAll();
            };
         }
         mSelfReviveAllButton.releaseCallback = reviveAllCallback;
         if(mHeroGameObject.canUsePartyBombs())
         {
            mSelfReviveAllButton.enabled = true;
            mSelfReviveAllButton.root.cost_text_buy_me.text = offer.Price.toString();
         }
         else
         {
            mSelfReviveAllButton.enabled = false;
            mSelfReviveAllButton.root.cost_text_buy_me.text = Locale.getString("REVIVE_PANEL_USED_MAX_PARTY_BOMBS_BUY_BUTTON_TEXT");
         }
         mReturnToTownButton.label.text = Locale.getString("REVIVE_PANEL_FORFEIT_BUTTON");
         ownedHealthBombs = null;
         ownedHealthBombs = mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(60001);
         healthBombCount = 0;
         if(ownedHealthBombs)
         {
            healthBombCount = ownedHealthBombs.count;
         }
         mRevivePanel.quantity_hBomb.text = Locale.getString("LIMITED_REVIVES_PANEL_HBOMBS_OWNED") + ": " + healthBombCount.toString();
         partyBombCount = 0;
         if(partyBombsOwned)
         {
            partyBombCount = partyBombsOwned.count;
         }
         mRevivePanel.quantity_pBomb.text = Locale.getString("LIMITED_REVIVES_PANEL_PBOMBS_OWNED") + ": " + partyBombCount.toString();
         offer = mDBFacade.gameMaster.offerById.itemFor(51304);
         if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(60001) && ownedHealthBombs)
         {
            mRevivePanel.prompt_button_1_buy_me.cost_text_buy_me.visible = false;
            mRevivePanel.prompt_button_1_buy_me.cash_icon_buy_me.visible = false;
            mRevivePanel.prompt_button_1_buy_me.use_buy_me.text = Locale.getString("REVIVE_PANEL_USE");
            reviveMeCallback = function():void
            {
               mRevivePanel.visible = false;
               useRezMePotion();
            };
         }
         else
         {
            mRevivePanel.prompt_button_1_buy_me.cost_text_buy_me.visible = true;
            mRevivePanel.label_buy_me.text = Locale.getString("REVIVE_PANEL_SELF_REVIVE_BUTTON_NO_REZ_FROG");
            healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
            if(healthBombCostMultiplier < 1 && 0)
            {
               mSelfReviveMeButton.destroy();
               mRevivePanel.prompt_button_1_buy_me.visible = false;
               mSelfReviveMeButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_sale);
               mSelfReviveMeButton.root.original_cost_text.text = Math.round(offer.Price / healthBombCostMultiplier).toString();
               mSelfReviveMeButton.root.strike.scaleX *= mSelfReviveMeButton.root.original_cost_text.text.length / 3;
            }
            mSelfReviveMeButton.root.cost_text_buy_me.text = offer.Price.toString();
            reviveMeCallback = function():void
            {
               if(offer.CurrencyType == "PREMIUM" && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price)
               {
                  mRevivePanel.visible = false;
               }
               buyReviveMe();
            };
         }
         mSelfReviveMeButton.releaseCallback = reviveMeCallback;
         if(mHeroGameObject.canUseHealthBombs())
         {
            mSelfReviveMeButton.enabled = true;
            mSelfReviveMeButton.root.cost_text_buy_me.text = offer.Price.toString();
         }
         else
         {
            mSelfReviveMeButton.enabled = false;
            mSelfReviveMeButton.root.cost_text_buy_me.text = Locale.getString("REVIVE_PANEL_USED_MAX_HEALTH_BOMBS_BUY_BUTTON_TEXT");
         }
         mReturnToTownButton.label.text = Locale.getString("REVIVE_PANEL_FORFEIT_BUTTON");
         mReturnToTownButton.releaseCallback = function():void
         {
            var _loc2_:uint = mHeroGameObject.distributedDungeonFloor.completionXp;
            var _loc1_:II_UIExitDungeonPopUp = new II_UIExitDungeonPopUp(mDBFacade,onForfeitClick,null);
         };
         hitTabClass = swfAsset.getClass("popup_keyboard_tab");
         mHitTabClip = new hitTabClass() as MovieClip;
         mHitTabClip.x = -150;
         mHitTabClip.y = 250;
         mHitTabClip.label.text = Locale.getString("HIT_TAB_TEXT");
         mSceneGraphComponent.addChildAt(mHitTabClip,105,0);
         mHitTabTween = TweenMax.to(mHitTabClip,0.5,{
            "x":20,
            "y":mHitTabClip.y
         });
         rewardSlots = new Vector.<MovieClip>();
         rewardSlots.push(mRevivePanel.current_reward.loot_01);
         rewardSlots.push(mRevivePanel.current_reward.loot_02);
         rewardSlots.push(mRevivePanel.current_reward.loot_03);
         rewardSlots.push(mRevivePanel.current_reward.loot_04);
         mRevivePanel.current_reward.coin_count.text = mHeroGameObject.distributedDungeonFloor.parentArea.infiniteTotalGold.toString();
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
         var reviveMeCallback:Function;
         var reviveAllCallback:Function;
         var partyBomb:StackableInfo;
         var hitTabClass:Class;
         var healthBombCostMultiplier:Number = 1;
         var offer:GMOffer = null;
         var assetClass:Class = null;
         var healthBomb:StackableInfo = null;
         assetClass = swfAsset.getClass("DR_revive_prompt");
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
         mRevivePanel.x = mDBFacade.viewWidth - mRevivePanel.width / 2;
         mRevivePanel.y = mDBFacade.viewHeight - mRevivePanel.height / 2;
         mRevivePanel.revive_king.scaleX = mRevivePanel.revive_king.scaleY = 1.8;
         mRevivePanel.revive_king.x = -1350;
         mRevivePanel.revive_king.y = -100;
         mRevivePanel.prompt_heading.text = Locale.getString("REVIVE_PANEL_HEADER");
         if(mHeroGameObject.distributedDungeonFloor.remoteHeroes.size > 0)
         {
            mRevivePanel.prompt_text_box.text = Locale.getString("REVIVE_PANEL_INNER_MULTI_PLAYER");
         }
         else
         {
            mRevivePanel.prompt_text_box.text = Locale.getString("REVIVE_PANEL_INNER_SINGLE_PLAYER");
         }
         mSelfReviveMeButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_1_buy_me);
         mSelfReviveAllButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_1_buy_all);
         mReturnToTownButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_2);
         mRevivePanel.prompt_button_1_buy_me.use_buy_me.text = "";
         mRevivePanel.prompt_button_1_buy_all.use_buy_all.text = "";
         mRevivePanel.prompt_button_1_buy_me.stackable_buy_me.text = "";
         mRevivePanel.label_buy_me.text = Locale.getString("REVIVE_PANEL_SELF_REVIVE_BUTTON");
         mRevivePanel.label_buy_all.text = Locale.getString("REVIVE_PANEL_PARTY_REVIVE_BUTTON");
         partyBomb = mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(60018);
         offer = mDBFacade.gameMaster.offerById.itemFor(51369);
         if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(60018) && partyBomb)
         {
            mRevivePanel.prompt_button_1_buy_all.stackable_buy_all.text = "X" + partyBomb.count.toString();
            mRevivePanel.prompt_button_1_buy_all.cost_text_buy_all.visible = false;
            mRevivePanel.prompt_button_1_buy_all.cash_icon_buy_me.visible = false;
            mRevivePanel.prompt_button_1_buy_all.use_buy_all.text = Locale.getString("REVIVE_PANEL_USE");
            reviveAllCallback = function():void
            {
               mRevivePanel.visible = false;
               useRezAllPotion();
            };
         }
         else
         {
            mRevivePanel.prompt_button_1_buy_all.cost_text_buy_all.visible = true;
            mRevivePanel.prompt_button_1_buy_all.stackable_buy_all.visible = false;
            mRevivePanel.label_buy_all.text = Locale.getString("REVIVE_PANEL_PARTY_REVIVE_BUTTON_NO_REZ_FROG");
            healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
            if(healthBombCostMultiplier < 1 && 0)
            {
               mSelfReviveAllButton.destroy();
               mRevivePanel.prompt_button_1_buy_all.visible = false;
            }
            mRevivePanel.prompt_button_1_buy_all.stackable_buy_all.text = "0";
            mSelfReviveAllButton.root.cost_text_buy_all.text = offer.Price.toString();
            reviveAllCallback = function():void
            {
               if(offer.CurrencyType == "PREMIUM" && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price)
               {
                  mRevivePanel.visible = false;
                  mRevivePanel.addEventListener("purchaseReviveAll-failed",handleReviveAllPurchaseFail);
               }
               buyReviveAll();
            };
         }
         mSelfReviveAllButton.releaseCallback = reviveAllCallback;
         if(mHeroGameObject.canUsePartyBombs())
         {
            mSelfReviveAllButton.enabled = true;
            mSelfReviveAllButton.root.cost_text_buy_all.text = offer.Price.toString();
         }
         else
         {
            mSelfReviveAllButton.enabled = false;
            mSelfReviveAllButton.root.cost_text_buy_all.text = Locale.getString("REVIVE_PANEL_USED_MAX_PARTY_BOMBS_BUY_BUTTON_TEXT");
         }
         mReturnToTownButton.label.text = Locale.getString("REVIVE_PANEL_FORFEIT_BUTTON");
         healthBomb = mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(60001);
         offer = mDBFacade.gameMaster.offerById.itemFor(51304);
         if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(60001) && healthBomb)
         {
            mRevivePanel.prompt_button_1_buy_me.stackable_buy_me.text = "X" + healthBomb.count.toString();
            mRevivePanel.prompt_button_1_buy_me.cost_text_buy_me.visible = false;
            mRevivePanel.prompt_button_1_buy_me.cash_icon_buy_me.visible = false;
            mRevivePanel.prompt_button_1_buy_me.use_buy_me.text = Locale.getString("REVIVE_PANEL_USE");
            reviveMeCallback = function():void
            {
               mRevivePanel.visible = false;
               useRezMePotion();
            };
         }
         else
         {
            mRevivePanel.prompt_button_1_buy_me.cost_text_buy_me.visible = true;
            mRevivePanel.prompt_button_1_buy_me.stackable_buy_me.visible = false;
            mRevivePanel.label_buy_me.text = Locale.getString("REVIVE_PANEL_SELF_REVIVE_BUTTON_NO_REZ_FROG");
            healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
            if(healthBombCostMultiplier < 1 && 0)
            {
               mSelfReviveMeButton.destroy();
               mRevivePanel.prompt_button_1_buy_me.visible = false;
               mSelfReviveMeButton = new UIButton(mDBFacade,mRevivePanel.prompt_button_sale);
               mSelfReviveMeButton.root.original_cost_text.text = Math.round(offer.Price / healthBombCostMultiplier).toString();
               mSelfReviveMeButton.root.strike.scaleX *= mSelfReviveMeButton.root.original_cost_text.text.length / 3;
            }
            mRevivePanel.prompt_button_1_buy_me.stackable_buy_me.text = "0";
            mSelfReviveMeButton.root.cost_text_buy_me.text = offer.Price.toString();
            reviveMeCallback = function():void
            {
               if(offer.CurrencyType == "PREMIUM" && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price)
               {
                  mRevivePanel.visible = false;
               }
               buyReviveMe();
            };
         }
         mSelfReviveMeButton.releaseCallback = reviveMeCallback;
         if(mHeroGameObject.canUseHealthBombs())
         {
            mSelfReviveMeButton.enabled = true;
            mSelfReviveMeButton.root.cost_text_buy_me.text = offer.Price.toString();
         }
         else
         {
            mSelfReviveMeButton.enabled = false;
            mSelfReviveMeButton.root.cost_text_buy_me.text = Locale.getString("REVIVE_PANEL_USED_MAX_HEALTH_BOMBS_BUY_BUTTON_TEXT");
         }
         mReturnToTownButton.label.text = Locale.getString("REVIVE_PANEL_FORFEIT_BUTTON");
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
         mHitTabClip.label.text = Locale.getString("HIT_TAB_TEXT");
         mSceneGraphComponent.addChildAt(mHitTabClip,105,0);
         mHitTabTween = TweenMax.to(mHitTabClip,0.5,{
            "x":20,
            "y":mHitTabClip.y
         });
      }
      
      protected function handleReviveAllPurchaseFail(event:Event) : void
      {
         mRevivePanel.visible = false;
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
         Logger.debug("ActorReviveState -- Starting Clean Shutdown");
         mLogicalWorkComponent.doLater(5,function():void
         {
            mDBFacade.mainStateMachine.enterReloadTownState();
         });
         mDBFacade.mDistributedObjectManager.mMatchMaker.RequestExit();
         mDBFacade.hud.chatLog.hideChatLog();
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
         var _loc1_:GMOffer = mDBFacade.gameMaster.offerById.itemFor(51304);
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
         var _loc1_:GMOffer = mDBFacade.gameMaster.offerById.itemFor(51369);
         StoreServicesController.tryBuyOffer(mDBFacade,_loc1_,buyReviveAllSuccess);
      }
      
      public function buyReviveAllSuccess(details:*) : void
      {
         (mHeroGameObject as HeroGameObjectOwner).proposeSelfRevive(1);
      }
      
      public function destroyUI() : void
      {
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
            mSceneGraphComponent.removeChild(mKeyBoardInput);
            mKeyBoardInput = null;
         }
         if(mSpaceBarReviveFunction != null)
         {
            mDBFacade.stageRef.removeEventListener("keyDown",mSpaceBarReviveFunction);
            mSpaceBarReviveFunction = null;
         }
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
         var _loc2_:Array = new Array(50,105);
         mSceneGraphComponent.saturateLayers(value,_loc2_);
      }
   }
}

