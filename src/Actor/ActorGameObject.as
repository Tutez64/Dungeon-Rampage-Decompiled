package Actor
{
   import Actor.Buffs.BuffHandler;
   import Actor.StateMachine.ActorMacroStateMachine;
   import Box2D.Dynamics.b2FilterData;
   import Brain.Clock.GameClock;
   import Brain.GameObject.GameObject;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.PreRenderWorkComponent;
   import Brain.WorkLoop.Task;
   import Combat.Attack.AttackTimeline;
   import Combat.Attack.ScriptTimeline;
   import Combat.Weapon.WeaponGameObject;
   import DBGlobals.DBGlobal;
   import DistributedObjects.DistributedDungeonFloor;
   import Dungeon.Tile;
   import Events.HpEvent;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import Floor.FloorView;
   import GameMasterDictionary.GMAttack;
   import GameMasterDictionary.GMSkin;
   import GameMasterDictionary.StatVector;
   import GeneratedCode.AttackChoreography;
   import GeneratedCode.CombatResult;
   import GeneratedCode.WeaponDetails;
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
   public class ActorGameObject extends FloorObject
   {
      
      public static const PROP_CHAR_TYPE:String = "PROP";
      
      public static const PET_CHAR_TYPE:String = "PET";
      
      private static const SUFFER_TIMELINE_NAME:String = "GENERIC_STUN";
      
      private static const GENERIC_SUFFER_KNOCKBACK:String = "GENERIC_SUFFER_KNOCKBACK";
      
      private static const TELEPORT:String = "TELEPORT";
      
      public static const ATTEMPT_REVIVE_INSTANT_TIMELINE_NAME:String = "TM_ATTEMPT_REVIVE_INSTANT";
      
      public static const ATTEMPT_REVIVE_LONG_TIMELINE_NAME:String = "TM_ATTEMPT_REVIVE_LONG";
      
      protected static const ATTEMPT_REVIVE_LONG_ATTACK_ID:uint = 910900;
      
      protected static const ATTEMPT_REVIVE_INSTANT_ATTACK_ID:uint = 910901;
      
      protected var mScreenName:String = "";
      
      protected var mHeading:Number = 0;
      
      protected var mActorView:ActorView;
      
      protected var mActorStateMachine:ActorMacroStateMachine;
      
      protected var mMovementController:MovementController;
      
      protected var mMouseEventHandler:MouseEventHandler;
      
      protected var mPreRenderWorkComponent:PreRenderWorkComponent;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mRunIdleMonitorTask:Task;
      
      protected var mHitPoints:uint;
      
      private var mShowHitFloater:Boolean;
      
      protected var objPlayerDist:int;
      
      protected var mState:String;
      
      protected var mActorType:uint;
      
      protected var mActorData:ActorData;
      
      protected var mWeapons:Vector.<WeaponGameObject>;
      
      protected var mWeaponDetails:Vector.<WeaponDetails>;
      
      protected var mStats:StatVector;
      
      protected var mLevel:uint;
      
      public var buffHandler:BuffHandler;
      
      protected var mCurrentWeapon:WeaponGameObject;
      
      protected var mHasOwnership:Boolean;
      
      private var mTeam:int;
      
      protected var mFlip:uint = 0;
      
      private var mSufferTimeline:ScriptTimeline;
      
      private var mSufferKnockBackTimeline:ScriptTimeline;
      
      private var mTeleportInTimeline:ScriptTimeline;
      
      private var mTeleportOutTimeline:ScriptTimeline;
      
      protected var mAFK:Boolean;
      
      private var mIsBlocking:Boolean = false;
      
      private var mMaximumDotForBlock:Number = -1.1;
      
      public var effectivenessShown:Boolean = false;
      
      protected var mAttemptReviveScript:AttackTimeline;
      
      private var mCanBeKnockedBack:Boolean = true;
      
      public function ActorGameObject(dbFacade:DBFacade, remoteId:uint = 0)
      {
         super(dbFacade,remoteId);
         mStats = new StatVector();
         mTeam = 0;
         mAFK = false;
         mMovementController = new MovementController(this,mActorView,mDBFacade);
         mMouseEventHandler = new MouseEventHandler(this,mDBFacade);
         mPreRenderWorkComponent = new PreRenderWorkComponent(mDBFacade,"ActorGameObject");
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"ActorGameObject");
         buildStateMachine();
         mLevel = 0;
         this.layer = 20;
         buffHandler = new BuffHandler(dbFacade,this);
         mShowHitFloater = mDBFacade.dbConfigManager.getConfigBoolean("show_hit_floater",true);
      }
      
      public function get isOwner() : Boolean
      {
         return false;
      }
      
      public function get projectileLaunchOffset() : Vector3D
      {
         return new Vector3D(0,mActorData.gMActor.scaled_ProjEmitOffset);
      }
      
      override public function set tile(value:Tile) : void
      {
         if(value == mTile)
         {
            super.tile = value;
            return;
         }
         if(mHasOwnership && mTile)
         {
            mTile.removeOwnedFloorObject(this);
         }
         super.tile = value;
         if(mHasOwnership && mTile)
         {
            mTile.addOwnedFloorObject(this);
         }
      }
      
      public function set hasOwnership(value:Boolean) : void
      {
         mHasOwnership = value;
         if(mHasOwnership)
         {
            if(this.tile)
            {
               this.tile.addOwnedFloorObject(this);
            }
         }
         else if(this.tile)
         {
            this.tile.removeOwnedFloorObject(this);
         }
      }
      
      override public function newNetworkChild(child:GameObject) : void
      {
      }
      
      public function get isNavigable() : Boolean
      {
         return false;
      }
      
      public function get isAttackable() : Boolean
      {
         return true;
      }
      
      override public function init() : void
      {
         var _loc2_:String = null;
         super.init();
         this.createNavCollisions(this.actorData.constant);
         mMouseEventHandler.Init();
         setupWeapons();
         initializeToFirstValidWeapon();
         determineState();
         var _loc3_:String = this.actorData.gMActor.TeleportInTimeline;
         var _loc1_:String = this.actorData.gMActor.TeleportOutTimeline;
         if(_loc3_ && _loc1_)
         {
            mTeleportInTimeline = mDBFacade.timelineFactory.createScriptTimeline(_loc3_,this,mDistributedDungeonFloor);
            mTeleportOutTimeline = mDBFacade.timelineFactory.createScriptTimeline(_loc1_,this,mDistributedDungeonFloor);
         }
         if(!mAttemptReviveScript)
         {
            if(mDBFacade.dbConfigManager.getConfigBoolean("use_long_revive",true))
            {
               _loc2_ = "TM_ATTEMPT_REVIVE_LONG";
            }
            else
            {
               _loc2_ = "TM_ATTEMPT_REVIVE_INSTANT";
            }
            mAttemptReviveScript = mDBFacade.timelineFactory.createAttackTimeline(_loc2_,null,this,mDistributedDungeonFloor);
         }
      }
      
      public function get actorView() : ActorView
      {
         return mActorView;
      }
      
      public function set currentWeapon(weaponGameObject:WeaponGameObject) : void
      {
         mCurrentWeapon = weaponGameObject;
         if(mActorView)
         {
            if(weaponGameObject)
            {
               mActorView.currentWeapon = weaponGameObject.weaponView;
            }
            else
            {
               Logger.warn("Trying to equip a null weapon game object on actor.");
            }
         }
      }
      
      public function get currentWeapon() : WeaponGameObject
      {
         return mCurrentWeapon;
      }
      
      protected function buildStateMachine() : void
      {
      }
      
      public function set stateMachine(actorStateMachine:ActorMacroStateMachine) : void
      {
         mActorStateMachine = actorStateMachine;
      }
      
      public function get stateMachine() : ActorMacroStateMachine
      {
         return mActorStateMachine;
      }
      
      public function get actorData() : ActorData
      {
         return mActorData;
      }
      
      public function get actorNametag() : ActorNametag
      {
         return mActorView.nametag;
      }
      
      override public function set view(actorView:FloorView) : void
      {
         mActorView = actorView as ActorView;
         if(mCurrentWeapon)
         {
            mActorView.currentWeapon = mCurrentWeapon.weaponView;
         }
         super.view = actorView;
      }
      
      public function set screenName(value:String) : void
      {
         mScreenName = value;
         mActorView.screenName = screenName;
      }
      
      public function get AFK() : Boolean
      {
         return mAFK;
      }
      
      public function get screenName() : String
      {
         return mScreenName;
      }
      
      public function Chat(message:String) : void
      {
         mActorView.setChat(message);
      }
      
      public function ShowPlayerisTyping(value:Boolean) : void
      {
         if(mActorView && mActorView.nametag)
         {
            mActorView.nametag.showPlayerIsTypingNotification(value);
         }
      }
      
      public function get maxHitPoints() : Number
      {
         return mStats.maxHitPoints * this.buffHandler.multiplier.maxHitPoints;
      }
      
      public function get attackCooldownMultiplier() : Number
      {
         return buffHandler.attackCooldownMultiplier;
      }
      
      public function get maxManaPoints() : Number
      {
         return mStats.maxManaPoints * this.buffHandler.multiplier.maxManaPoints;
      }
      
      public function get movementSpeed() : Number
      {
         var _loc2_:Number = mStats.movementSpeed;
         var _loc3_:Number = this.buffHandler.multiplier.movementSpeed;
         return _loc2_ * _loc3_;
      }
      
      public function get heading() : Number
      {
         return mHeading;
      }
      
      public function set heading(value:Number) : void
      {
         mHeading = value;
         this.move();
      }
      
      override public function set position(pos:Vector3D) : void
      {
         super.position = pos;
         this.move();
      }
      
      protected function move() : void
      {
         mMovementController.move(this.position,this.heading);
      }
      
      public function getHeadingAsVector(degreesOffset:Number = 0) : Vector3D
      {
         var _loc4_:Vector3D = new Vector3D();
         var _loc2_:Number = (heading + degreesOffset) * 3.141592653589793 / 180;
         var _loc5_:Number = Math.cos(_loc2_);
         var _loc3_:Number = Math.sin(_loc2_);
         return new Vector3D(_loc5_,_loc3_);
      }
      
      public function set movementControllerType(value:String) : void
      {
         this.mMovementController.movementType = value;
      }
      
      public function get movementControllerType() : String
      {
         return this.mMovementController.movementType;
      }
      
      public function get canMoveR() : Boolean
      {
         return this.mMovementController.canMoveR;
      }
      
      public function postGenerate() : void
      {
         mActorData = buildActorData();
         refreshStatVector();
         checkIfReadyForInit();
         mActorView.position = position;
      }
      
      protected function buildActorData() : ActorData
      {
         return new ActorData(mDBFacade,this);
      }
      
      public function playEffectAtActor(effectPath:String, effectName:String, scale:Number, layer:String) : void
      {
         distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(effectPath),effectName,actorView.position,null,false,scale,0,0,0,0,false,layer);
      }
      
      override public function destroy() : void
      {
         if(mTile && mTile.hasOwnedFloorObject(this))
         {
            mTile.removeOwnedFloorObject(this);
         }
         if(mDistributedDungeonFloor)
         {
            mDistributedDungeonFloor.RemoveNetworkChild(this);
         }
         if(mSufferTimeline)
         {
            mSufferTimeline.destroy();
            mSufferTimeline = null;
         }
         if(mSufferKnockBackTimeline)
         {
            mSufferKnockBackTimeline.destroy();
            mSufferKnockBackTimeline = null;
         }
         if(mTeleportInTimeline)
         {
            mTeleportInTimeline.destroy();
            mTeleportInTimeline = null;
         }
         if(mTeleportOutTimeline)
         {
            mTeleportOutTimeline.destroy();
            mTeleportOutTimeline = null;
         }
         mPosition = null;
         mMovementController.destroy();
         mMovementController = null;
         mMouseEventHandler.destroy();
         mMouseEventHandler = null;
         mPreRenderWorkComponent.destroy();
         mPreRenderWorkComponent = null;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         mActorStateMachine = null;
         mStats.destroy();
         mStats = null;
         buffHandler.destroy();
         buffHandler = null;
         mActorView = null;
         if(mActorData)
         {
            mActorData.destroy();
            mActorData = null;
         }
         mCurrentWeapon = null;
         mWeaponDetails = null;
         for each(var _loc1_:WeaponGameObject in mWeapons)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         mWeapons = null;
         if(mRunIdleMonitorTask)
         {
            mRunIdleMonitorTask.destroy();
            mRunIdleMonitorTask = null;
         }
         super.destroy();
      }
      
      override public function set distributedDungeonFloor(value:DistributedDungeonFloor) : void
      {
         super.distributedDungeonFloor = value;
         checkIfReadyForInit();
      }
      
      private function checkIfReadyForInit() : void
      {
         if(mDistributedDungeonFloor != null && mActorData != null)
         {
            init();
         }
      }
      
      public function attack(attackType:uint, targetActor:ActorGameObject, attackSpeedMultiplier:Number, attackTimeline:AttackTimeline, finishedCallback:Function = null, stopCallback:Function = null, loop:Boolean = false, autoAim:Boolean = false) : void
      {
         attackTimeline.currentAttackType = attackType;
         mActorStateMachine.enterChoreographyState(attackSpeedMultiplier,targetActor,attackTimeline,finishedCallback,stopCallback,loop,autoAim);
      }
      
      public function set hitPoints(val:uint) : void
      {
         mHitPoints = val;
         mActorView.setHp(mHitPoints,this.maxHitPoints);
         mFacade.eventManager.dispatchEvent(new HpEvent("HpEvent_HP_UPDATE",id,mHitPoints,this.maxHitPoints));
      }
      
      public function get hitPoints() : uint
      {
         return mHitPoints;
      }
      
      public function get gmSkin() : GMSkin
      {
         return null;
      }
      
      public function ReceiveAttackChoreography(attackChoreography:AttackChoreography) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:ActorGameObject = null;
         var _loc2_:WeaponDetails = this.mWeaponDetails[attackChoreography.attack.weaponSlot];
         var _loc3_:WeaponGameObject = null;
         if(_loc2_.type != 0)
         {
            _loc3_ = getWeaponForId(_loc2_.type);
            if(_loc3_ == null)
            {
               Logger.error("Weapon type: " + _loc2_.type + " on incoming attackChoreography does not match any weapon type currently equipped on actor.");
               return;
            }
            currentWeapon = _loc3_;
         }
         else
         {
            _loc3_ = currentWeapon;
         }
         var _loc6_:GMAttack = mDBFacade.gameMaster.attackById.itemFor(attackChoreography.attack.attackType);
         if(_loc6_ == null)
         {
            Logger.error("Unable to find GMAttack for attacktype: " + attackChoreography.attack.attackType);
            return;
         }
         var _loc7_:AttackTimeline = _loc3_.getAttackTimeline(_loc6_.Id);
         if(_loc7_)
         {
            _loc4_ = attackChoreography.playSpeed;
            if(attackChoreography.attack.targetActorDoid != 0)
            {
               _loc5_ = mDBFacade.gameObjectManager.getReferenceFromId(attackChoreography.attack.targetActorDoid) as ActorGameObject;
            }
            mActorStateMachine.enterAttackChoreographyState(_loc4_,_loc5_,_loc7_,attackChoreography);
         }
      }
      
      public function ReceiveCombatResult(combatResult:CombatResult) : void
      {
         var _loc2_:GMAttack = mDBFacade.gameMaster.attackById.itemFor(combatResult.attack.attackType);
         if(_loc2_)
         {
            if(_loc2_.DamageMod > 0)
            {
               this.actorView.receiveHeal(combatResult,_loc2_);
            }
            else if(combatResult.blocked == 0)
            {
               this.actorView.receiveDamage(combatResult,_loc2_);
               receiveDamage(combatResult);
            }
         }
      }
      
      public function get canSuffer() : Boolean
      {
         return !this.hasAbility(1);
      }
      
      public function get canBeKnockedBack() : Boolean
      {
         return mCanBeKnockedBack;
      }
      
      public function set canBeKnockedBack(val:Boolean) : void
      {
         mCanBeKnockedBack = val;
      }
      
      private function receiveDamage(combatResult:CombatResult) : void
      {
         if(isHeroType && combatResult.attacker != combatResult.attackee)
         {
            mMouseEventHandler.sendGotHitEvent();
         }
         var _loc2_:Number = 1;
         if(combatResult.knockback == 1 && canBeKnockedBack)
         {
            if(!mSufferKnockBackTimeline)
            {
               mSufferKnockBackTimeline = mDBFacade.timelineFactory.createScriptTimeline("GENERIC_SUFFER_KNOCKBACK",this,mDistributedDungeonFloor);
            }
            mSufferKnockBackTimeline.currentAttackType = combatResult.attack.attackType;
            mActorStateMachine.enterCombatResultChoreographyState(_loc2_,null,mSufferKnockBackTimeline,combatResult,mDistributedDungeonFloor.getActor(combatResult.attacker));
         }
         else if(combatResult.suffer == 1 && canSuffer)
         {
            if(!mSufferTimeline)
            {
               mSufferTimeline = mDBFacade.timelineFactory.createScriptTimeline("GENERIC_STUN",this,mDistributedDungeonFloor);
            }
            mActorStateMachine.enterCombatResultChoreographyState(_loc2_,null,mSufferTimeline,combatResult,mDistributedDungeonFloor.getActor(combatResult.attacker));
         }
      }
      
      public function ReceiveTimelineAction(timelineAction:String) : void
      {
         if(mTeleportInTimeline && timelineAction == mTeleportInTimeline.attackName)
         {
            mActorStateMachine.enterChoreographyState(1,null,mTeleportInTimeline);
         }
         if(mTeleportOutTimeline && timelineAction == mTeleportOutTimeline.attackName)
         {
            mActorStateMachine.enterChoreographyState(1,null,mTeleportOutTimeline);
         }
      }
      
      protected function getWeaponForId(weaponType:uint) : WeaponGameObject
      {
         for each(var _loc2_:WeaponGameObject in mWeapons)
         {
            if(_loc2_ && _loc2_.weaponType == weaponType)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function get weapons() : Vector.<WeaponGameObject>
      {
         return mWeapons;
      }
      
      public function set type(value:uint) : void
      {
         mActorType = value;
      }
      
      public function get type() : uint
      {
         return mActorType;
      }
      
      public function get isHeroType() : Boolean
      {
         if(mActorType > 100 && mActorType < 200)
         {
            return true;
         }
         return false;
      }
      
      public function get isProp() : Boolean
      {
         return this.actorData.gMActor.CharType == "PROP";
      }
      
      public function get isPet() : Boolean
      {
         return this.actorData.gMActor.CharType == "PET";
      }
      
      public function get usePetUI() : Boolean
      {
         return false;
      }
      
      public function get hasShowHealNumbers() : Boolean
      {
         return false;
      }
      
      public function set state(value:String) : void
      {
         if(mState != value)
         {
            mState = value;
            determineState();
         }
      }
      
      public function set weaponDetails(val:Vector.<WeaponDetails>) : void
      {
         mWeaponDetails = val;
         if(mActorData && mDistributedDungeonFloor)
         {
            setupWeapons();
            initializeToFirstValidWeapon();
         }
      }
      
      protected function setupWeapons() : void
      {
         for each(var _loc1_:WeaponGameObject in mWeapons)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         var _loc2_:Number = 0;
         mWeapons = new Vector.<WeaponGameObject>();
         for each(var _loc3_:WeaponDetails in mWeaponDetails)
         {
            if(_loc3_.type != 0)
            {
               _loc1_ = new WeaponGameObject(_loc3_,this,mActorView,mDBFacade,mDistributedDungeonFloor,_loc2_);
               MemoryTracker.track(_loc1_,"WeaponGameObject - created in ActorGameObject.setupWeapons()");
               mWeapons.push(_loc1_);
            }
            else
            {
               mWeapons.push(null);
            }
            _loc2_++;
         }
         setupConsumables();
      }
      
      protected function setupConsumables() : void
      {
      }
      
      protected function initializeToFirstValidWeapon() : void
      {
         var _loc1_:WeaponGameObject = null;
         var _loc2_:* = 0;
         if(mWeapons.length > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < mWeapons.length)
            {
               _loc1_ = mWeapons[_loc2_];
               if(_loc1_ != null)
               {
                  this.currentWeapon = _loc1_;
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public function isDead() : Boolean
      {
         if(mActorStateMachine == null)
         {
            return false;
         }
         return mActorStateMachine.currentStateName == "ActorDeadState";
      }
      
      public function isInReviveState() : Boolean
      {
         if(mActorStateMachine == null)
         {
            return false;
         }
         return mActorStateMachine.currentStateName == "ActorReviveState";
      }
      
      public function localToGlobal(point:Point) : Point
      {
         return this.view.root.localToGlobal(point);
      }
      
      public function globalToLocal(point:Point) : Point
      {
         return this.view.root.globalToLocal(point);
      }
      
      public function hitTestObject(grobj:DisplayObject) : Boolean
      {
         return this.view.root.hitTestObject(grobj);
      }
      
      public function localCombatHit(combatResult:CombatResult) : void
      {
         mActorView.localCombatHit(combatResult);
      }
      
      public function set scale(val:Number) : void
      {
         this.view.root.scaleX = val;
         this.view.root.scaleY = val;
      }
      
      public function set flip(val:uint) : void
      {
         mFlip = val;
         if(mFlip)
         {
            this.actorView.body.scaleX = -Math.abs(this.actorView.body.scaleX);
         }
      }
      
      public function get flip() : uint
      {
         return mFlip;
      }
      
      public function set level(val:uint) : void
      {
         mLevel = val;
      }
      
      public function get level() : uint
      {
         return mLevel;
      }
      
      public function get stats() : StatVector
      {
         return mStats;
      }
      
      public function set stats(value:StatVector) : void
      {
         mStats = value;
         mActorView.setHp(mHitPoints,this.maxHitPoints);
         mDBFacade.eventManager.dispatchEvent(new HpEvent("HpEvent_HP_UPDATE",id,mHitPoints,this.maxHitPoints));
      }
      
      protected function determineState() : void
      {
         if(this.actorData != null)
         {
            switch(mState)
            {
               case "dead":
                  mActorStateMachine.enterDeadState(finishedDeathCallback);
                  break;
               case "":
                  mActorStateMachine.enterDefaultState();
                  break;
               default:
                  Logger.error("No case handled for state: " + mState + " for actorGameObject.");
            }
         }
      }
      
      protected function finishedDeathCallback(gameClock:GameClock = null) : void
      {
         if(mHasOwnership)
         {
            this.destroy();
         }
      }
      
      protected function refreshStatVector() : void
      {
         var _loc1_:* = 0;
         _loc1_ = 5;
         var _loc4_:Number = Number(mTeam == 5 ? mLevel : Math.pow(mLevel,1.5));
         var _loc3_:StatVector = StatVector.add(mActorData.baseValues,StatVector.multiplyScalar(mActorData.levelValues,_loc4_));
         var _loc2_:StatVector = StatVector.add(StatVector.multiply(_loc3_,mDBFacade.gameMaster.stat_BonusMultiplier),mDBFacade.gameMaster.stat_bias);
         _loc2_.values[0] = mActorData.hp + _loc2_.values[0];
         _loc2_.values[1] = mActorData.mp + _loc2_.values[1];
         _loc2_.values[13] = mActorData.gMActor.BaseMove + _loc2_.values[13];
         stats = _loc2_;
      }
      
      override protected function buildFilter() : b2FilterData
      {
         var _loc1_:b2FilterData = new b2FilterData();
         _loc1_.maskBits = 0;
         _loc1_.categoryBits = 0;
         _loc1_.categoryBits |= DBGlobal.b2dMaskForTeam(team);
         if(!this.isNavigable)
         {
            _loc1_.maskBits |= 1;
            _loc1_.maskBits |= DBGlobal.b2dMaskForAllTeamsBut(team);
            if(this.actorData.gMActor.CollideWithTeam || this.isOwner)
            {
               _loc1_.maskBits |= DBGlobal.b2dMaskForTeam(team);
            }
         }
         if(actorData.gMActor.Species != "TRAP")
         {
            _loc1_.maskBits |= 2;
         }
         return _loc1_;
      }
      
      public function set team(val:int) : void
      {
         mTeam = val;
      }
      
      public function get team() : int
      {
         return mTeam;
      }
      
      public function hasAbility(ability:uint) : Boolean
      {
         return (actorData.gMActor.Ability & ability) != 0 || buffHandler.HasAbility(ability);
      }
      
      public function startRunIdleMonitoring() : void
      {
         if(!mRunIdleMonitorTask)
         {
            mRunIdleMonitorTask = mPreRenderWorkComponent.doEveryFrame(runIdleMonitor);
         }
      }
      
      public function stopRunIdleMonitoring() : void
      {
         if(mRunIdleMonitorTask)
         {
            mRunIdleMonitorTask.destroy();
            mRunIdleMonitorTask = null;
         }
      }
      
      private function runIdleMonitor(gameClock:GameClock) : void
      {
         if(mActorView.velocity.lengthSquared == 0)
         {
            mActorView.playAnim("idle");
         }
         else
         {
            mActorView.playAnim("run");
         }
      }
      
      public function set setAFK(flag:uint) : void
      {
         this.mAFK = flag != 0;
         mActorView.AFK = this.mAFK;
      }
      
      public function get isBlocking() : Boolean
      {
         return mIsBlocking;
      }
      
      public function set isBlocking(blocking:Boolean) : void
      {
         mIsBlocking = blocking;
      }
      
      public function get maximumDotForBlocking() : Number
      {
         return mMaximumDotForBlock;
      }
      
      public function set maximumDotForBlocking(value:Number) : void
      {
         mMaximumDotForBlock = value;
      }
      
      public function ponderBuffChanges() : void
      {
      }
   }
}

