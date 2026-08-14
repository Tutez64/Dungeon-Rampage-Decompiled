package StateMachine.MainStateMachine
{
   import Actor.Player.Input.DungeonBusterControlActivatedEvent;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Render.MovieClipRenderer;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Facade.DBFacade;
   import Facade.Locale;
   import com.greensock.TimelineMax;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class DungeonTutorial
   {
      
      public static const MOVEMENT_TUTORIAL:String = "MOVEMENT_TUTORIAL";
      
      public static const BUSTER_TUTORIAL:String = "BUSTER_TUTORIAL";
      
      public static const CHARGE_TUTORIAL:String = "CHARGE_TUTORIAL";
      
      public static const REVIVE_TUTORIAL:String = "REVIVE_TUTORIAL";
      
      public static const LOOT_SHARING_TUTORIAL:String = "LOOT_SHARING_TUTORIAL";
      
      public static const SUPER_WEAK_TUTORIAL:String = "SUPER_WEAK_TUTORIAL";
      
      public static const TUTORIAL_PANEL_LEFT:String = "TUTORIAL_PANEL_LEFT";
      
      public static const TUTORIAL_PANEL_RIGHT:String = "TUTORIAL_PANEL_RIGHT";
      
      public static const REVIVE_SPACEBAR_PRESSED_EVENT:String = "REVIVE_SPACEBAR_PRESSED";
      
      public static const CHEST_TUTORIAL_NEARBY:String = "CHEST_TUTORIAL_NEARBY";
      
      public static const CHEST_TUTORIAL_COLLECTED:String = "CHEST_TUTORIAL_COLLECTED";
      
      public static const COOLDOWN_TUTORIAL:String = "COOLDOWN_TUTORIAL";
      
      public static const SCALING_TUTORIAL:String = "SCALING_TUTORIAL";
      
      public static const REPEATER_TUTORIAL:String = "REPEATER_TUTORIAL";
      
      private static const ATTACK_POPUP_DELAY:Number = 1;
      
      private static const TUTORIAL_SWF:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      protected var mDBFacade:DBFacade;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mEventComponent:EventComponent;
      
      private var mMovementTutorialDone:Boolean = false;
      
      private var mMovementPopup:MovieClip;
      
      private var mAttackTutorialDone:Boolean = false;
      
      private var mAttackPopup:MovieClip;
      
      private var mChestTutorialDone:Boolean = false;
      
      private var mChestCloseButton:UIButton;
      
      private var mChestPopup:MovieClip;
      
      private var mCooldownRenderer:MovieClipRenderer;
      
      private var mCooldownTutorialReadyToClose:Boolean = false;
      
      private var mScalingTutorialReadyToClose:Boolean = false;
      
      private var mRepeaterTutorialReadyToClose:Boolean = false;
      
      private var mChargeTutorialReadyToClose:Boolean = false;
      
      private var mCooldownTutorialDone:Boolean = false;
      
      private var mScalingTutorialDone:Boolean = false;
      
      private var mRepeaterTutorialDone:Boolean = false;
      
      private var mChargeTutorialDone:Boolean = false;
      
      private var mBusterTutorialDone:Boolean = false;
      
      private var mBusterCloseButton:UIButton;
      
      private var mBusterPopup:MovieClip;
      
      private var mChargeCloseButton:UIButton;
      
      private var mChargePopup:MovieClip;
      
      private var mReviveTutorialDone:Boolean = false;
      
      private var mReviveCloseButton:UIButton;
      
      private var mRevivePopup:MovieClip;
      
      private var mRevivePopupPosition:String;
      
      private var mLootSharingTutorialDone:Boolean = false;
      
      private var mLootSharingCloseButton:UIButton;
      
      private var mLootSharingPopup:MovieClip;
      
      private var mSuperWeakTutorialDone:Boolean = false;
      
      private var mSuperWeakCloseButton:UIButton;
      
      private var mSuperWeakPopup:MovieClip;
      
      private var mTutorialComplete:Boolean = false;
      
      public function DungeonTutorial(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"DungeonTutorial");
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"DungeonTutorial");
         mEventComponent = new EventComponent(mDBFacade);
         mDBFacade.stageRef.addEventListener("keyDown",handleKeyDown);
         mDBFacade.stageRef.addEventListener("mouseDown",handleMouseDown);
         mEventComponent.addListener("DungeonBusterControlActivatedEvent",handleBuster);
         mEventComponent.addListener("REVIVE_SPACEBAR_PRESSED",handleRevive);
         if(mDBFacade.dbAccountInfo.dbAccountParams.hasMovementTutorialParam())
         {
            mMovementTutorialDone = true;
         }
      }
      
      public function destroy() : void
      {
         mDBFacade.stageRef.removeEventListener("keyDown",handleKeyDown);
         mDBFacade.stageRef.removeEventListener("mouseDown",handleMouseDown);
         this.destroyChestTutorial();
         this.destroyMovementTutorial();
         this.destroyAttackTutorial();
         this.destroyBusterTutorial();
         this.destroyChargeTutorial();
         this.destroyReviveTutorial();
         this.destroyLootSharingTutorial();
         this.destroySuperWeakTutorial();
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mEventComponent.destroy();
         mEventComponent = null;
         mDBFacade = null;
      }
      
      private function handleMouseDown(event:MouseEvent) : void
      {
         if(mMovementPopup && !mMovementTutorialDone)
         {
            this.advanceToAttackTutorial();
         }
      }
      
      private function handleKeyDown(event:KeyboardEvent) : void
      {
         switch(event.keyCode)
         {
            case 27:
               if(mAttackPopup && !mAttackTutorialDone)
               {
                  this.finishAttackTutorial();
               }
               if(mMovementPopup && !mMovementTutorialDone)
               {
                  this.advanceToAttackTutorial();
               }
               if(mChestPopup && !mChestTutorialDone)
               {
                  this.finishChestTutorial();
               }
               if(mChestPopup && !mCooldownTutorialDone)
               {
                  this.finishCooldownTutorial();
               }
               if(mChestPopup && !mScalingTutorialDone)
               {
                  this.finishScalingTutorial();
               }
               if(mChestPopup && !mRepeaterTutorialDone)
               {
                  this.finishRepeaterTutorial();
               }
               if(mBusterPopup && !mBusterTutorialDone)
               {
                  this.finishBusterTutorial();
               }
               if(mChargePopup && !mChargeTutorialDone)
               {
                  this.finishChargeTutorial();
               }
               break;
            case 90:
            case 88:
            case 67:
            case 74:
            case 75:
            case 76:
               if(mAttackPopup && !mAttackTutorialDone)
               {
                  this.finishAttackTutorial();
               }
               if(mChestPopup && !mCooldownTutorialDone)
               {
                  this.finishCooldownTutorial();
               }
               if(mChestPopup && !mScalingTutorialDone)
               {
                  this.finishScalingTutorial();
               }
               if(mChestPopup && !mRepeaterTutorialDone)
               {
                  this.finishRepeaterTutorial();
               }
               if(mChargePopup && !mChargeTutorialDone)
               {
                  this.finishChargeTutorial();
               }
               break;
            case 66:
               if(mBusterPopup && !mBusterTutorialDone)
               {
                  this.finishBusterTutorial();
               }
               break;
            case 38:
            case 40:
            case 39:
            case 87:
            case 83:
            case 68:
            case 65:
            case 37:
               if(mMovementPopup && !mMovementTutorialDone)
               {
                  this.advanceToAttackTutorial();
               }
         }
      }
      
      private function handleBuster(event:DungeonBusterControlActivatedEvent) : void
      {
         if(mBusterPopup && !mBusterTutorialDone)
         {
            this.finishBusterTutorial();
         }
      }
      
      private function handleRevive(event:Event) : void
      {
         if(mRevivePopup && !mReviveTutorialDone)
         {
            this.finishReviveTutorial();
         }
      }
      
      private function timelineAttackAdvance() : void
      {
         destroyMovementTutorial();
         showAttackTutorial();
      }
      
      public function advanceToAttackTutorial() : void
      {
         mMovementTutorialDone = true;
         mMovementPopup.check.visible = true;
         var _loc1_:Number = mMovementPopup.x;
         var _loc3_:Number = mDBFacade.viewWidth + mMovementPopup.width;
         var _loc2_:Number = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mMovementPopup,0.08333333333333333,{
               "delay":1,
               "x":_loc1_ - 20,
               "y":_loc2_
            }),TweenMax.to(mMovementPopup,0.3333333333333333,{
               "x":_loc3_,
               "y":_loc2_
            }),TweenMax.delayedCall(1.5,timelineAttackAdvance)],
            "align":"sequence"
         });
      }
      
      private function destroyMovementTutorial() : void
      {
         if(mMovementPopup)
         {
            TweenMax.killDelayedCallsTo(timelineAttackAdvance);
            TweenMax.killTweensOf(mMovementPopup);
            mSceneGraphComponent.removeChild(mMovementPopup);
            mMovementPopup = null;
         }
      }
      
      public function showMovementTutorial() : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass("tutorial_movement");
            if(_loc3_ == null)
            {
               return;
            }
            mMovementPopup = new _loc3_();
            mMovementPopup.title.text = Locale.getString("TUTORIAL_MOVEMENT_TITLE");
            mMovementPopup.check.visible = false;
            mSceneGraphComponent.addChild(mMovementPopup,105);
            mMovementPopup.scaleX = mMovementPopup.scaleY = 0.85;
            var _loc2_:Number = mDBFacade.viewWidth - mMovementPopup.width * 0.5 - 50;
            var _loc4_:Number = mDBFacade.viewHeight * 0.5;
            mMovementPopup.x = mDBFacade.viewWidth + mMovementPopup.width;
            mMovementPopup.y = _loc4_;
            new TimelineMax({
               "tweens":[TweenMax.to(mMovementPopup,0.3333333333333333,{
                  "x":_loc2_ - 20,
                  "y":_loc4_
               }),TweenMax.to(mMovementPopup,0.08333333333333333,{
                  "x":_loc2_,
                  "y":_loc4_
               })],
               "align":"sequence"
            });
         });
      }
      
      private function finishAttackTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         if(!mAttackTutorialDone)
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setMovementTutorialParam();
         }
         mAttackTutorialDone = true;
         mAttackPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyAttackTutorial();
         };
         curX = mAttackPopup.x;
         offscreenX = -mAttackPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mAttackPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mAttackPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function destroyAttackTutorial() : void
      {
         if(mAttackPopup)
         {
            TweenMax.killTweensOf(mAttackPopup);
            mSceneGraphComponent.removeChild(mAttackPopup);
            mAttackPopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showAttackTutorial() : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass("tutorial_attack");
            if(_loc3_ == null)
            {
               return;
            }
            mAttackPopup = new _loc3_();
            mAttackPopup.title.text = Locale.getString("TUTORIAL_ATTACK_TITLE");
            mAttackPopup.check.visible = false;
            mSceneGraphComponent.addChild(mAttackPopup,105);
            mAttackPopup.scaleX = mAttackPopup.scaleY = 0.85;
            var _loc2_:Number = mAttackPopup.width * 0.5 + 10;
            var _loc4_:Number = mDBFacade.viewHeight * 0.5;
            mAttackPopup.x = -mAttackPopup.width;
            mAttackPopup.y = _loc4_;
            new TimelineMax({
               "tweens":[TweenMax.to(mAttackPopup,0.3333333333333333,{
                  "x":_loc2_ + 20,
                  "y":_loc4_
               }),TweenMax.to(mAttackPopup,0.08333333333333333,{
                  "x":_loc2_,
                  "y":_loc4_
               })],
               "align":"sequence"
            });
         });
      }
      
      private function finishReviveTutorial() : void
      {
         var advanceFunc:Function;
         var destX:Number;
         var bounceOffset:Number;
         var curX:Number;
         mReviveTutorialDone = true;
         mRevivePopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyReviveTutorial();
         };
         curX = mRevivePopup.x;
         if(mRevivePopupPosition == "TUTORIAL_PANEL_RIGHT")
         {
            destX = mDBFacade.viewWidth + mRevivePopup.width;
            bounceOffset = -20;
         }
         else
         {
            destX = -mRevivePopup.width;
            bounceOffset = 20;
         }
         new TimelineMax({
            "tweens":[TweenMax.to(mRevivePopup,0.08333333333333333,{
               "delay":1,
               "x":curX + bounceOffset
            }),TweenMax.to(mRevivePopup,0.3333333333333333,{
               "x":destX,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function destroyReviveTutorial() : void
      {
         if(mRevivePopup)
         {
            TweenMax.killTweensOf(mRevivePopup);
            mSceneGraphComponent.removeChild(mRevivePopup);
            mRevivePopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showReviveTutorial(popupPosition:String) : void
      {
         if(mRevivePopup)
         {
            return;
         }
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasReviveTutorialParam())
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setReviveTutorialParam();
         }
         mRevivePopupPosition = popupPosition;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var _loc3_:Number = NaN;
            var _loc2_:Number = NaN;
            var _loc4_:Class = param1.getClass("tutorial_revive");
            if(_loc4_ == null)
            {
               return;
            }
            mRevivePopup = new _loc4_();
            mRevivePopup.title.text = Locale.getString("TUTORIAL_REVIVE_TITLE");
            mRevivePopup.description.text = Locale.getString("TUTORIAL_REVIVE_DESCRIPTION");
            mRevivePopup.check.visible = false;
            mReviveCloseButton = new UIButton(mDBFacade,mRevivePopup.close);
            mReviveCloseButton.releaseCallback = finishReviveTutorial;
            mSceneGraphComponent.addChild(mRevivePopup,105);
            mRevivePopup.scaleX = mRevivePopup.scaleY = 0.85;
            mRevivePopup.y = mDBFacade.viewHeight * 0.5;
            if(mRevivePopupPosition == "TUTORIAL_PANEL_RIGHT")
            {
               mRevivePopup.x = mDBFacade.viewWidth + mRevivePopup.width / 2;
               _loc3_ = mDBFacade.viewWidth - mRevivePopup.width / 2 + 25;
               _loc2_ = -20;
            }
            else
            {
               mRevivePopup.x = 0 - mRevivePopup.width / 2;
               _loc3_ = mRevivePopup.width / 2;
               _loc2_ = 20;
            }
            new TimelineMax({
               "tweens":[TweenMax.to(mRevivePopup,0.3333333333333333,{"x":_loc3_ + _loc2_}),TweenMax.to(mRevivePopup,0.08333333333333333,{"x":_loc3_})],
               "align":"sequence"
            });
         });
      }
      
      private function finishLootSharingTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         mLootSharingTutorialDone = true;
         mLootSharingPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyLootSharingTutorial();
         };
         curX = mLootSharingPopup.x;
         offscreenX = mDBFacade.stageRef.stageWidth;
         offscreenY = mDBFacade.viewHeight * 0.3;
         new TimelineMax({
            "tweens":[TweenMax.to(mLootSharingPopup,0.08333333333333333,{
               "delay":1,
               "x":curX - 40,
               "y":offscreenY
            }),TweenMax.to(mLootSharingPopup,0.3333333333333333,{
               "x":offscreenX - 40,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function destroyLootSharingTutorial() : void
      {
         if(mLootSharingPopup)
         {
            TweenMax.killTweensOf(mLootSharingPopup);
            mSceneGraphComponent.removeChild(mLootSharingPopup);
            mLootSharingPopup = null;
         }
         mTutorialComplete = true;
      }
      
      private function finishSuperWeakTutorial(className:String, isRight:Boolean = true) : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var sign:int;
         var offscreenX:Number;
         var offscreenY:Number;
         mSuperWeakPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroySuperWeakTutorial();
            if(className == "tutorial_enemy_defense1")
            {
               showSuperWeakTutorial("tutorial_enemy_defense2",false);
            }
            else if(className == "tutorial_enemy_defense2")
            {
               showSuperWeakTutorial("tutorial_enemy_defense3");
            }
            else if(className == "tutorial_enemy_defense3")
            {
               showSuperWeakTutorial("tutorial_enemy_defense4",false);
            }
            else
            {
               mSuperWeakTutorialDone = true;
            }
         };
         curX = mSuperWeakPopup.x;
         sign = isRight ? 1 : -1;
         offscreenX = isRight ? 900 : -100;
         offscreenY = mSuperWeakPopup.y;
         new TimelineMax({
            "tweens":[TweenMax.to(mSuperWeakPopup,0.08333333333333333,{
               "delay":1,
               "x":curX - sign * 40,
               "y":offscreenY
            }),TweenMax.to(mSuperWeakPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function destroySuperWeakTutorial() : void
      {
         if(mSuperWeakPopup)
         {
            TweenMax.killTweensOf(mSuperWeakPopup);
            mSceneGraphComponent.removeChild(mSuperWeakPopup);
            mSuperWeakPopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showLootSharingTutorial() : void
      {
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasLootSharingTutorialParam())
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setLootSharingTutorialParam();
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var swfAsset:SwfAsset = param1;
            var popupClass:Class = swfAsset.getClass("tutorial_loot_alt");
            if(popupClass == null)
            {
               return;
            }
            mLootSharingPopup = new popupClass();
            mLootSharingPopup.title.text = Locale.getString("TUTORIAL_LOOT_TITLE");
            mLootSharingPopup.shared_text.text = Locale.getString("TUTORIAL_LOOT_SHARED");
            mLootSharingPopup.not_shared_text.text = Locale.getString("TUTORIAL_LOOT_NOT_SHARED");
            mLootSharingPopup.check.visible = false;
            mLootSharingCloseButton = new UIButton(mDBFacade,mLootSharingPopup.close);
            mLootSharingCloseButton.releaseCallback = finishLootSharingTutorial;
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),function(param1:SwfAsset):void
            {
               var xpStar:MovieClip;
               var dbStar:MovieClip;
               var food:MovieClip;
               var treasureMC:MovieClip;
               var destX:Number;
               var destY:Number;
               var swfAsset2:SwfAsset = param1;
               var gold3:Class = swfAsset2.getClass("doober_currency_coin");
               var xp:Class = swfAsset2.getClass("doober_xp_star");
               var db:Class = swfAsset2.getClass("doober_db_star");
               var treasure:Class = swfAsset2.getClass("db_doobers_treasure_chest_basic_static");
               var foodClass:Class = swfAsset2.getClass("doober_health_burger");
               var gold:MovieClip = new gold3();
               gold.scaleX = gold.scaleY = 0.75;
               xpStar = new xp();
               xpStar.scaleX = xpStar.scaleY = 1;
               xpStar.x += 10;
               xpStar.y -= 10;
               dbStar = new db();
               dbStar.scaleX = dbStar.scaleY = 1.75;
               dbStar.x += 10;
               dbStar.y -= 10;
               food = new foodClass();
               food.scaleX = food.scaleY = 0.9;
               treasureMC = new treasure();
               treasureMC.scaleX = treasureMC.scaleY = 0.65;
               treasureMC.x += 10;
               treasureMC.y += 5;
               mLootSharingPopup.gold3.addChild(gold);
               mLootSharingPopup.xp.addChild(xpStar);
               mLootSharingPopup.db.addChild(dbStar);
               mLootSharingPopup.treasure.addChild(treasureMC);
               mLootSharingPopup.food.addChild(food);
               mSceneGraphComponent.addChild(mLootSharingPopup,105);
               destX = mDBFacade.stageRef.stageWidth - mLootSharingPopup.width;
               destY = mDBFacade.viewHeight * 0.3;
               mLootSharingPopup.x = destX;
               mLootSharingPopup.y = destY;
               new TimelineMax({
                  "tweens":[TweenMax.to(mLootSharingPopup,0.3333333333333333,{
                     "x":destX + 20,
                     "y":destY
                  }),TweenMax.to(mLootSharingPopup,0.08333333333333333,{
                     "x":destX,
                     "y":destY
                  })],
                  "align":"sequence"
               });
               mLogicalWorkComponent.doLater(10,function(param1:GameClock):void
               {
                  if(!mLootSharingTutorialDone)
                  {
                     finishLootSharingTutorial();
                  }
               });
            });
         });
      }
      
      public function showSuperWeakTutorial(className:String, isRight:Boolean = true) : void
      {
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasSuperWeakParam())
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setSuperWeakParam();
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var swfAsset:SwfAsset = param1;
            var popupClass:Class = swfAsset.getClass(className);
            if(popupClass == null)
            {
               return;
            }
            mSuperWeakPopup = new popupClass();
            mSuperWeakPopup.title.text = Locale.getString("TUTORIAL_SUPER_WEAK_TITLE");
            mSuperWeakPopup.check.visible = false;
            mSuperWeakCloseButton = new UIButton(mDBFacade,mSuperWeakPopup.close);
            mSuperWeakCloseButton.releaseCallback = function():void
            {
               mLogicalWorkComponent.clear();
               finishSuperWeakTutorial(className,isRight);
            };
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),function(param1:SwfAsset):void
            {
               var destXCaseRight:Number;
               var destXCaseLeft:Number;
               var destX:Number;
               var destY:Number;
               var swfAsset2:SwfAsset = param1;
               mSceneGraphComponent.addChild(mSuperWeakPopup,105);
               destXCaseRight = mDBFacade.stageRef.stageWidth - mSuperWeakPopup.width / 1.6;
               destXCaseLeft = mSuperWeakPopup.width / 3;
               destX = isRight ? destXCaseRight : destXCaseLeft;
               destY = mDBFacade.viewHeight * 0.5;
               mSuperWeakPopup.x = destX;
               mSuperWeakPopup.y = destY;
               new TimelineMax({
                  "tweens":[TweenMax.to(mSuperWeakPopup,0.3333333333333333,{
                     "x":destX + 20,
                     "y":destY
                  }),TweenMax.to(mSuperWeakPopup,0.08333333333333333,{
                     "x":destX,
                     "y":destY
                  })],
                  "align":"sequence"
               });
               mLogicalWorkComponent.clear();
               mLogicalWorkComponent.doLater(5,function(param1:GameClock):void
               {
                  if(!mSuperWeakTutorialDone)
                  {
                     finishSuperWeakTutorial(className,isRight);
                  }
               });
            });
         });
      }
      
      public function finishChestTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         mDBFacade.dbAccountInfo.dbAccountParams.setChestCollectedTutorialParam();
         mChestTutorialDone = true;
         if(mChestPopup == null)
         {
            return;
         }
         mChestPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyChestTutorial();
         };
         curX = mChestPopup.x;
         offscreenX = mDBFacade.viewWidth + mChestPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mChestPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mChestPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      public function finishCooldownTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         if(!mCooldownTutorialReadyToClose)
         {
            return;
         }
         mCooldownTutorialDone = true;
         mChestPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyChestTutorial();
         };
         curX = mChestPopup.x;
         offscreenX = mDBFacade.viewWidth + mChestPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mChestPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mChestPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      public function finishScalingTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         if(!mScalingTutorialReadyToClose)
         {
            return;
         }
         mScalingTutorialDone = true;
         mChestPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyChestTutorial();
         };
         curX = mChestPopup.x;
         offscreenX = mDBFacade.viewWidth + mChestPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mChestPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mChestPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      public function finishRepeaterTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         if(!mRepeaterTutorialReadyToClose)
         {
            return;
         }
         mRepeaterTutorialDone = true;
         mChestPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyChestTutorial();
         };
         curX = mChestPopup.x;
         offscreenX = mDBFacade.viewWidth + mChestPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mChestPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mChestPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function finishBusterTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         if(!mBusterTutorialDone)
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setDungeonBusterTutorialParam();
         }
         mBusterTutorialDone = true;
         mBusterPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyBusterTutorial();
         };
         curX = mBusterPopup.x;
         offscreenX = mDBFacade.viewWidth + mBusterPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mBusterPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mBusterPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function destroyChestTutorial() : void
      {
         if(mChestPopup)
         {
            mLogicalWorkComponent.clear();
            if(mCooldownRenderer)
            {
               mCooldownRenderer.destroy();
               mCooldownRenderer = null;
            }
            TweenMax.killTweensOf(mChestPopup);
            mSceneGraphComponent.removeChild(mChestPopup);
            mChestCloseButton.destroy();
            mChestCloseButton = null;
            mChestPopup = null;
         }
         mTutorialComplete = true;
      }
      
      private function destroyBusterTutorial() : void
      {
         if(mBusterPopup)
         {
            TweenMax.killTweensOf(mBusterPopup);
            mSceneGraphComponent.removeChild(mBusterPopup);
            mBusterCloseButton.destroy();
            mBusterCloseButton = null;
            mBusterPopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showChestTutorial() : void
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setChestNearbyTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass("tutorial_chest");
            if(_loc3_ == null)
            {
               return;
            }
            mChestPopup = new _loc3_();
            mChestPopup.title.text = Locale.getString("TUTORIAL_CHEST_TITLE");
            mChestPopup.title1.text = Locale.getString("TUTORIAL_CHEST_DESC").toUpperCase();
            mChestPopup.check.visible = false;
            mChestCloseButton = new UIButton(mDBFacade,mChestPopup.close);
            mChestCloseButton.releaseCallback = finishChestTutorial;
            mSceneGraphComponent.addChild(mChestPopup,105);
            mChestPopup.scaleX = mChestPopup.scaleY = 0.85;
            var _loc2_:Number = mDBFacade.viewWidth - mChestPopup.width / 1.6;
            var _loc4_:Number = mDBFacade.viewHeight * 0.5;
            mChestPopup.x = _loc2_;
            mChestPopup.y = _loc4_;
            new TimelineMax({
               "tweens":[TweenMax.to(mChestPopup,0.3333333333333333,{
                  "x":_loc2_ + 20,
                  "y":_loc4_
               }),TweenMax.to(mChestPopup,0.08333333333333333,{
                  "x":_loc2_,
                  "y":_loc4_
               })],
               "align":"sequence"
            });
         });
      }
      
      public function showCooldownTutorial() : void
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setCooldownTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var destX:Number;
            var destY:Number;
            var swfAsset:SwfAsset = param1;
            var popupClass:Class = swfAsset.getClass("tutorial_cooldown");
            if(popupClass == null)
            {
               return;
            }
            mChestPopup = new popupClass();
            mChestPopup.title.text = Locale.getString("TUTORIAL_COOLDOWN_TITLE");
            mChestPopup.description.text = Locale.getString("TUTORIAL_COOLDOWN_DESC").toUpperCase();
            mChestPopup.check.visible = false;
            mChestCloseButton = new UIButton(mDBFacade,mChestPopup.close);
            mChestCloseButton.releaseCallback = finishCooldownTutorial;
            mSceneGraphComponent.addChild(mChestPopup,105);
            mChestPopup.scaleX = mChestPopup.scaleY = 0.85;
            destX = mDBFacade.viewWidth - mChestPopup.width / 1.6;
            destY = mDBFacade.viewHeight * 0.5;
            mChestPopup.x = destX;
            mChestPopup.y = destY;
            new TimelineMax({
               "tweens":[TweenMax.to(mChestPopup,0.3333333333333333,{
                  "x":destX + 20,
                  "y":destY
               }),TweenMax.to(mChestPopup,0.08333333333333333,{
                  "x":destX,
                  "y":destY
               })],
               "align":"sequence"
            });
            mLogicalWorkComponent.doLater(3,function(param1:GameClock):void
            {
               mCooldownTutorialReadyToClose = true;
            });
            mLogicalWorkComponent.doLater(6.5,function(param1:GameClock):void
            {
               if(mCooldownTutorialReadyToClose && !mCooldownTutorialDone)
               {
                  finishCooldownTutorial();
               }
            });
            mCooldownRenderer = new MovieClipRenderer(mDBFacade,mChestPopup.icon);
            mCooldownRenderer.play();
         });
      }
      
      public function showScalingTutorial() : void
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setScalingTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var destX:Number;
            var destY:Number;
            var swfAsset:SwfAsset = param1;
            var popupClass:Class = swfAsset.getClass("tutorial_scaling");
            if(popupClass == null)
            {
               return;
            }
            mChestPopup = new popupClass();
            mChestPopup.title.text = Locale.getString("TUTORIAL_SCALING_TITLE");
            mChestPopup.description.text = Locale.getString("TUTORIAL_SCALING_DESC").toUpperCase();
            mChestPopup.check.visible = false;
            mChestCloseButton = new UIButton(mDBFacade,mChestPopup.close);
            mChestCloseButton.releaseCallback = finishScalingTutorial;
            mSceneGraphComponent.addChild(mChestPopup,105);
            mChestPopup.scaleX = mChestPopup.scaleY = 0.85;
            destX = mDBFacade.viewWidth - mChestPopup.width / 1.6;
            destY = mDBFacade.viewHeight * 0.5;
            mChestPopup.x = destX;
            mChestPopup.y = destY;
            new TimelineMax({
               "tweens":[TweenMax.to(mChestPopup,0.3333333333333333,{
                  "x":destX + 20,
                  "y":destY
               }),TweenMax.to(mChestPopup,0.08333333333333333,{
                  "x":destX,
                  "y":destY
               })],
               "align":"sequence"
            });
            mLogicalWorkComponent.doLater(3,function(param1:GameClock):void
            {
               mScalingTutorialReadyToClose = true;
            });
            mLogicalWorkComponent.doLater(6.5,function(param1:GameClock):void
            {
               if(mScalingTutorialReadyToClose && !mScalingTutorialDone)
               {
                  finishScalingTutorial();
               }
            });
         });
      }
      
      public function showRepeaterTutorial() : void
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setRepeaterTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var destX:Number;
            var destY:Number;
            var swfAsset:SwfAsset = param1;
            var popupClass:Class = swfAsset.getClass("tutorial_repeater");
            if(popupClass == null)
            {
               return;
            }
            mChestPopup = new popupClass();
            mChestPopup.title.text = Locale.getString("TUTORIAL_REPEATER_TITLE");
            mChestPopup.description.text = Locale.getString("TUTORIAL_REPEATER_DESC").toUpperCase();
            mChestPopup.check.visible = false;
            mChestCloseButton = new UIButton(mDBFacade,mChestPopup.close);
            mChestCloseButton.releaseCallback = finishRepeaterTutorial;
            mSceneGraphComponent.addChild(mChestPopup,105);
            mChestPopup.scaleX = mChestPopup.scaleY = 0.85;
            destX = mDBFacade.viewWidth - mChestPopup.width / 1.6;
            destY = mDBFacade.viewHeight * 0.5;
            mChestPopup.x = destX;
            mChestPopup.y = destY;
            new TimelineMax({
               "tweens":[TweenMax.to(mChestPopup,0.3333333333333333,{
                  "x":destX + 20,
                  "y":destY
               }),TweenMax.to(mChestPopup,0.08333333333333333,{
                  "x":destX,
                  "y":destY
               })],
               "align":"sequence"
            });
            mLogicalWorkComponent.doLater(3,function(param1:GameClock):void
            {
               mRepeaterTutorialReadyToClose = true;
            });
            mLogicalWorkComponent.doLater(6.5,function(param1:GameClock):void
            {
               if(mRepeaterTutorialReadyToClose && !mRepeaterTutorialDone)
               {
                  finishRepeaterTutorial();
               }
            });
         });
      }
      
      public function showBusterTutorial() : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass("tutorial_db");
            if(_loc3_ == null)
            {
               return;
            }
            mBusterPopup = new _loc3_();
            mBusterPopup.title.text = Locale.getString("TUTORIAL_BUSTER_TITLE");
            mBusterPopup.check.visible = false;
            mBusterCloseButton = new UIButton(mDBFacade,mBusterPopup.close);
            mBusterCloseButton.releaseCallback = finishBusterTutorial;
            mSceneGraphComponent.addChild(mBusterPopup,105);
            mBusterPopup.scaleX = mBusterPopup.scaleY = 0.85;
            var _loc2_:Number = mDBFacade.viewWidth - mBusterPopup.width * 0.5 - 50;
            var _loc4_:Number = mDBFacade.viewHeight * 0.5;
            mBusterPopup.x = mDBFacade.viewWidth;
            mBusterPopup.y = _loc4_;
            new TimelineMax({
               "tweens":[TweenMax.to(mBusterPopup,0.3333333333333333,{
                  "x":_loc2_ + 20,
                  "y":_loc4_
               }),TweenMax.to(mBusterPopup,0.08333333333333333,{
                  "x":_loc2_,
                  "y":_loc4_
               })],
               "align":"sequence"
            });
         });
      }
      
      private function finishChargeTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         if(!mChargeTutorialReadyToClose)
         {
            return;
         }
         mChargeTutorialDone = true;
         mChargePopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyChargeTutorial();
         };
         curX = mChargePopup.x;
         offscreenX = -mChargePopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mChargePopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mChargePopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function destroyChargeTutorial() : void
      {
         if(mChargePopup)
         {
            TweenMax.killTweensOf(mChargePopup);
            mSceneGraphComponent.removeChild(mChargePopup);
            mChargeCloseButton.destroy();
            mChargeCloseButton = null;
            mChargePopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showChargeTutorial() : void
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setChargeTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var destX:Number;
            var destY:Number;
            var swfAsset:SwfAsset = param1;
            var popupClass:Class = swfAsset.getClass("tutorial_charge");
            if(popupClass == null)
            {
               return;
            }
            mChargePopup = new popupClass();
            mChargePopup.title.text = Locale.getString("TUTORIAL_CHARGE_TITLE");
            mChargePopup.check.visible = false;
            mChargeCloseButton = new UIButton(mDBFacade,mChargePopup.close);
            mChargeCloseButton.releaseCallback = finishChargeTutorial;
            mSceneGraphComponent.addChild(mChargePopup,105);
            mChargePopup.scaleX = mChargePopup.scaleY = 0.85;
            destX = mChargePopup.width * 0.5 + 10;
            destY = mDBFacade.viewHeight * 0.5;
            mChargePopup.x = -mChargePopup.width;
            mChargePopup.y = destY;
            new TimelineMax({
               "tweens":[TweenMax.to(mChargePopup,0.3333333333333333,{
                  "x":destX + 20,
                  "y":destY
               }),TweenMax.to(mChargePopup,0.08333333333333333,{
                  "x":destX,
                  "y":destY
               })],
               "align":"sequence"
            });
            mLogicalWorkComponent.doLater(3,function(param1:GameClock):void
            {
               mChargeTutorialReadyToClose = true;
            });
            mLogicalWorkComponent.doLater(6.5,function(param1:GameClock):void
            {
               if(mChargeTutorialReadyToClose && !mChargeTutorialDone)
               {
                  finishChargeTutorial();
               }
            });
         });
      }
      
      public function get isTutorialComplete() : Boolean
      {
         return mTutorialComplete;
      }
   }
}

