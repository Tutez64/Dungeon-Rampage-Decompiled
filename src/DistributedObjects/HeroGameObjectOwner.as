package DistributedObjects
{
   import Account.StackableInfo;
   import Actor.ActorGameObject;
   import Actor.Player.HeroOwnerView;
   import Actor.Player.InputController;
   import Box2D.Dynamics.b2Body;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.GameObject.GameObject;
   import Brain.Logger.Logger;
   import Brain.Render.Layer;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.Task;
   import Camera.FollowTargetCameraStrategy;
   import Combat.Attack.PlayerOwnerAttackController;
   import Combat.Attack.TavernPlayerOwnerAttackController;
   import Combat.Weapon.WeaponController;
   import Combat.Weapon.WeaponGameObject;
   import Dungeon.NavCollider;
   import Dungeon.Tile;
   import Events.HpEvent;
   import Events.ManaEvent;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import Floor.FloorView;
   import GameMasterDictionary.GMAttack;
   import GeneratedCode.AttackChoreography;
   import GeneratedCode.CombatResult;
   import GeneratedCode.HeroGameObjectOwnerNetworkComponent;
   import GeneratedCode.IHeroGameObjectOwner;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class HeroGameObjectOwner extends HeroGameObject implements IHeroGameObjectOwner
   {
      
      public static const BROADCAST_INTERVAL:Number = 0.2;
      
      public static const DEFAULT_CAMERA_ZOOM:Number = 1;
      
      public static const CAMERA_ZOOM_DELTA:Number = 0.05;
      
      public static const CAMERA_ZOOM_TWEEN_DURATION:Number = 0.5;
      
      public static const COLLISION_CIRCLE_RADIUS:Number = 20;
      
      public static var HERO_OWNER_READY:String = "HERO_OWNER_READY";
      
      public static var currentHeroOwnerId:uint = 0;
      
      private static const FOLLOW_NEXT_ALLY_KEYCODE:int = 32;
      
      protected var mBroadcastTask:Task;
      
      protected var mInputTask:Task;
      
      private var mVisibleTiles:Vector.<Tile>;
      
      protected var mFollowCamera:FollowTargetCameraStrategy;
      
      protected var mButtonsDown:Set;
      
      protected var mPlayerOwnerAttackController:PlayerOwnerAttackController;
      
      protected var mHeroGameObjectOwnerNetworkComponent:HeroGameObjectOwnerNetworkComponent;
      
      protected var mCurrentWeaponIndex:int = -1;
      
      private var mBroadcastLastPosition:Vector3D = new Vector3D();
      
      private var mBroadcastLastHeading:Number = 0;
      
      protected var mInputHeading:Number = 0;
      
      private var mInputController:InputController;
      
      public var autoAimEnabled:Boolean;
      
      public var actorClickedToAttack:ActorGameObject;
      
      private var mInputVelocity:Vector3D;
      
      public var autoMoveVelocity:Vector3D;
      
      protected var mEventComponent:EventComponent;
      
      private var mFromNetAttackChoreography:AttackChoreography;
      
      protected var mCanSuffer:Boolean;
      
      private var mSelectedTargets:Map;
      
      private var mCurrentAttemptedRevivee:HeroGameObject;
      
      public var mTeleportDestination:Vector3D;
      
      public function HeroGameObjectOwner(dbFacade:DBFacade, remoteId:uint)
      {
         Logger.debug("New  HeroGameObjectOwner******************************");
         super(dbFacade,remoteId);
         mWantNavCollisions = true;
         mVisibleTiles = new Vector.<Tile>();
         mButtonsDown = new Set();
         mEventComponent = new EventComponent(dbFacade);
         mInputController = new InputController(this,dbFacade);
         MemoryTracker.track(mInputController,"InputController - created in HeroGameObjectOwner.constructor()");
         mInputVelocity = new Vector3D(0,0,0);
         autoMoveVelocity = new Vector3D(0,0,0);
         HeroGameObjectOwner.currentHeroOwnerId = this.id;
         autoAimEnabled = true;
         mCanSuffer = true;
         actorClickedToAttack = null;
      }
      
      override public function get isOwner() : Boolean
      {
         return true;
      }
      
      public function clearWeaponInput() : void
      {
         mPlayerOwnerAttackController.clearInput();
      }
      
      public function get weaponControllers() : Vector.<WeaponController>
      {
         return mPlayerOwnerAttackController.weaponControllers;
      }
      
      override protected function buildView() : void
      {
         var _loc1_:HeroOwnerView = new HeroOwnerView(mDBFacade,this);
         MemoryTracker.track(_loc1_,"HeroOwnerView - created in HeroGameObjectOwner.buildView()");
         view = _loc1_;
      }
      
      override public function set view(actorView:FloorView) : void
      {
         super.view = actorView;
      }
      
      override public function addNavCollision(value:NavCollider) : void
      {
         value.type = b2Body.b2_dynamicBody;
         super.addNavCollision(value);
      }
      
      public function set canSuffer(has:Boolean) : void
      {
         mCanSuffer = has;
      }
      
      override public function get canSuffer() : Boolean
      {
         return mCanSuffer;
      }
      
      override protected function initializeToFirstValidWeapon() : void
      {
         var _loc3_:WeaponController = null;
         var _loc1_:WeaponGameObject = null;
         var _loc2_:* = 0;
         if(weaponControllers.length > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < weaponControllers.length)
            {
               _loc3_ = weaponControllers[_loc2_];
               if(_loc3_ != null)
               {
                  _loc1_ = _loc3_.weapon;
                  if(_loc1_ != null)
                  {
                     mCurrentWeaponIndex = _loc2_;
                     this.currentWeapon = _loc1_;
                     return;
                  }
               }
               _loc2_++;
            }
         }
      }
      
      public function startUserInput() : void
      {
         mBroadcastTask = mLogicalWorkComponent.doEverySeconds(0.2,broadcastTelemetry);
         mInputController.init();
         mInputTask = mLogicalWorkComponent.doEveryFrame(inputUpCall);
      }
      
      protected function inputUpCall(gameClock:GameClock) : void
      {
         mInputController.perFrameUpCall();
      }
      
      public function stopUserInput() : void
      {
         mInputController.stop();
         mInputTask.destroy();
         mInputTask = null;
      }
      
      override public function init() : void
      {
         super.init();
         mDBFacade.camera.targetObject = mDBFacade.sceneGraphManager.worldTransformNode;
         mDBFacade.sceneGraphManager.worldTransformNode.parent.x = mDBFacade.viewWidth * 0.5;
         mDBFacade.sceneGraphManager.worldTransformNode.parent.y = mDBFacade.viewHeight * 0.5;
         mDBFacade.camera.defaultZoom = 1;
         mDBFacade.camera.zoom = mDBFacade.camera.defaultZoom;
         mDBFacade.camera.centerCameraOnPoint(position);
         mFollowCamera = new FollowTargetCameraStrategy(mDBFacade.camera,mHeroView.root);
         MemoryTracker.track(mFollowCamera,"FollowTargetCameraStrategy - created in HeroGameObjectOwner.init()");
         mFollowCamera.start(mPreRenderWorkComponent);
         autoAimEnabled = true;
         actorClickedToAttack = null;
         mPreRenderWorkComponent.doEveryFrame(this.doVisibility);
         mDBFacade.hud.initializeHud(this);
         mDBFacade.stageRef.addEventListener("keyDown",this.debugKey,false,0,true);
         Logger.debug(" Sending HERO_OWNER_READY ");
         mEventComponent.dispatchEvent(new Event(HERO_OWNER_READY));
         if(this.actorData.movment > 250)
         {
            mDBFacade.iamaCheater("test_fbcheats");
         }
      }
      
      private function debugKey(event:KeyboardEvent) : void
      {
         var _loc7_:Layer = null;
         var _loc3_:Boolean = false;
         var _loc2_:IMapIterator = null;
         var _loc5_:HeroGameObject = null;
         var _loc8_:String = mDBFacade.dbConfigManager.getConfigString("test_effect_swf","");
         var _loc6_:String = mDBFacade.dbConfigManager.getConfigString("test_effect_name","");
         var _loc4_:FloorObject = this;
         switch(event.keyCode)
         {
            case 98:
               _loc7_ = mDBFacade.sceneGraphManager.getLayer(50);
               _loc3_ = !_loc7_.visible;
               _loc7_.visible = _loc3_;
               if(actorNametag)
               {
                  actorNametag.visible = _loc3_;
               }
               _loc2_ = distributedDungeonFloor.remoteHeroes.iterator() as IMapIterator;
               while(_loc2_.hasNext())
               {
                  _loc5_ = _loc2_.next();
                  _loc5_.actorNametag.visible = _loc3_;
               }
               break;
            case 69:
               if(_loc8_ && _loc6_ && distributedDungeonFloor)
               {
                  distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(_loc8_),_loc6_,new Vector3D(Math.random() * 100,Math.random() * 100,0),_loc4_);
               }
         }
      }
      
      public function get visibleTiles() : Vector.<Tile>
      {
         return mVisibleTiles;
      }
      
      private function doVisibility(gameClock:GameClock) : void
      {
         var _loc3_:Rectangle = null;
         var _loc2_:* = undefined;
         var _loc4_:* = null;
         if(mDistributedDungeonFloor && mDistributedDungeonFloor.tileGrid)
         {
            _loc3_ = mFacade.camera.visibleRectangle;
            _loc2_ = mDistributedDungeonFloor.tileGrid.getVisibleTiles(_loc3_);
            for each(_loc4_ in mVisibleTiles)
            {
               if(_loc2_.indexOf(_loc4_) < 0)
               {
                  _loc4_.removeFromStage();
               }
            }
            for each(_loc4_ in _loc2_)
            {
               if(mVisibleTiles.indexOf(_loc4_) < 0)
               {
                  _loc4_.addToStage();
               }
            }
            mVisibleTiles = _loc2_;
         }
      }
      
      private function get canMoveXY() : Boolean
      {
         return this.mMovementController.canMoveXY && !mFacade.inputManager.check(16);
      }
      
      public function set inputVelocity(val:Vector3D) : void
      {
         mInputVelocity = val;
      }
      
      public function set inputHeading(angle:Number) : void
      {
         mInputHeading = angle;
      }
      
      public function get inputHeading() : Number
      {
         return mInputHeading;
      }
      
      override protected function move() : void
      {
         this.actorView.position = this.position;
         this.actorView.heading = this.heading;
      }
      
      public function broadcastTelemetry(gameClock:GameClock = null) : void
      {
         if(Vector3D.distance(mBroadcastLastPosition,position) > 0.5)
         {
            mHeroGameObjectOwnerNetworkComponent.send_position(position);
            mBroadcastLastPosition = position;
         }
         if(mBroadcastLastHeading != heading)
         {
            mHeroGameObjectOwnerNetworkComponent.send_heading(heading);
            mBroadcastLastHeading = heading;
         }
      }
      
      public function getNextFramePosition() : Vector3D
      {
         var _loc1_:Vector3D = this.position;
         _loc1_.x += this.actorView.velocity.x * 0.04;
         _loc1_.y += this.actorView.velocity.y * 0.04;
         return _loc1_;
      }
      
      override protected function setupWeapons() : void
      {
         if(mPlayerOwnerAttackController)
         {
            mPlayerOwnerAttackController.destroy();
         }
         super.setupWeapons();
         var _loc1_:Boolean = mDistributedDungeonFloor.gmMapNode.NodeType == "TAVERN";
         if(_loc1_)
         {
            mPlayerOwnerAttackController = new TavernPlayerOwnerAttackController(this,mHeroView,mDBFacade);
            MemoryTracker.track(mPlayerOwnerAttackController,"TavernPlayerOwnerAttackController - created in HeroGameObjectOwner.setupWeapons()");
         }
         else
         {
            mPlayerOwnerAttackController = new PlayerOwnerAttackController(this,mHeroView,mDBFacade);
            MemoryTracker.track(mPlayerOwnerAttackController,"PlayerOwnerAttackController - created in HeroGameObjectOwner.setupWeapons()");
         }
         initializeToFirstValidWeapon();
      }
      
      public function get currentWeaponRange() : uint
      {
         Logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!TODO!!!!!!!!!!!!!!!!!!!!!111: Make this make sense with the new weaponControllers code!");
         return mPlayerOwnerAttackController.weaponControllers[mCurrentWeaponIndex].weaponRange;
      }
      
      public function setViewVelocity() : void
      {
         this.mHeroView.velocity = mInputVelocity.add(autoMoveVelocity);
         this.navCollisions[0].velocity = this.mHeroView.velocity;
      }
      
      override public function set movementControllerType(value:String) : void
      {
         super.movementControllerType = value;
         if(!canMoveXY)
         {
            mInputVelocity.scaleBy(0);
         }
      }
      
      public function forceHeading(tv:Vector3D) : void
      {
         tv.normalize();
         var _loc2_:Number = Math.atan2(tv.y,tv.x) * 180 / 3.141592653589793;
         this.heading = _loc2_;
         this.mHeroView.heading = _loc2_;
      }
      
      public function placeAt(pos:Vector3D) : void
      {
         mMovementController.stopLerp();
         position = pos;
         mInputVelocity.x = 0;
         mInputVelocity.y = 0;
         this.navCollisions[0].position = pos;
         this.navCollisions[0].velocity = mInputVelocity;
         mMovementController.move(pos,this.heading);
         mInputVelocity.x = 0;
         mInputVelocity.y = 0;
      }
      
      public function setTeleDest(pos:Vector3D) : void
      {
         mTeleportDestination = pos;
      }
      
      public function doAttackOnHit(newAttack:String, weaponFromAttack:WeaponGameObject) : void
      {
         for each(var _loc3_:WeaponController in weaponControllers)
         {
            if(_loc3_ && _loc3_.weapon == weaponFromAttack)
            {
               _loc3_.queueAttack(newAttack);
               _loc3_.doQueue();
            }
         }
      }
      
      public function moveBodyTo(cameraPos:Vector3D) : void
      {
         mMovementController.moveBody(cameraPos,this.heading);
      }
      
      public function stopMovement() : void
      {
         mMovementController.stopLerp();
      }
      
      public function moveToTeleDest() : void
      {
         mMovementController.stopLerp();
         position = mTeleportDestination;
         this.navCollisions[0].position = mTeleportDestination;
         this.navCollisions[0].velocity = mInputVelocity;
         mMovementController.move(mTeleportDestination,this.heading);
      }
      
      override public function set position(pos:Vector3D) : void
      {
         super.position = pos;
      }
      
      public function set currentWeaponIndex(val:int) : void
      {
         mCurrentWeaponIndex = val;
         if(weaponControllers[mCurrentWeaponIndex] != null && weaponControllers[mCurrentWeaponIndex].weapon != null)
         {
            this.currentWeapon = weaponControllers[mCurrentWeaponIndex].weapon;
            mDBFacade.hud.setWeaponHighlight(val);
         }
      }
      
      public function get currentWeaponIndex() : int
      {
         return mCurrentWeaponIndex;
      }
      
      public function get PlayerAttack() : PlayerOwnerAttackController
      {
         return mPlayerOwnerAttackController;
      }
      
      public function set ActorClickedToAttack(value:ActorGameObject) : void
      {
         actorClickedToAttack = value;
      }
      
      public function sendChat(message:String) : void
      {
         var _loc2_:GameObject = mFacade.gameObjectManager.getReferenceFromId(mPlayerID);
         var _loc3_:PlayerGameObjectOwner = _loc2_ as PlayerGameObjectOwner;
         if(_loc3_)
         {
            _loc3_.sendChat(message);
         }
      }
      
      public function showPlayerIsTyping(value:Boolean) : void
      {
         var _loc2_:GameObject = mFacade.gameObjectManager.getReferenceFromId(mPlayerID);
         var _loc3_:PlayerGameObjectOwner = _loc2_ as PlayerGameObjectOwner;
         if(_loc3_)
         {
            _loc3_.sendPlayerIsTyping(value);
         }
      }
      
      override public function destroy() : void
      {
         mDBFacade.stageRef.removeEventListener("keyDown",this.debugKey);
         if(mPlayerOwnerAttackController)
         {
            mPlayerOwnerAttackController.destroy();
         }
         mVisibleTiles = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mDBFacade.hud.detachHero();
         mFollowCamera.destroy();
         mFollowCamera = null;
         mHeroGameObjectOwnerNetworkComponent = null;
         HeroGameObjectOwner.currentHeroOwnerId = 0;
         mInputController.destroy();
         mInputController = null;
         mEventComponent.destroy();
         mEventComponent = null;
         super.destroy();
      }
      
      public function setOwnerNetworkComponentHeroGameObject(iface:HeroGameObjectOwnerNetworkComponent) : void
      {
         mHeroGameObjectOwnerNetworkComponent = iface;
      }
      
      public function sendChoreography(attackChoreography:AttackChoreography) : void
      {
         if(mFromNetAttackChoreography == null || mFromNetAttackChoreography.attack.attackType != attackChoreography.attack.attackType)
         {
            if(mHeroGameObjectOwnerNetworkComponent != null)
            {
               mHeroGameObjectOwnerNetworkComponent.send_ProposeAttackChoreography(attackChoreography);
            }
         }
      }
      
      public function sendStopChoreography() : void
      {
         StopChoreography();
         if(mHeroGameObjectOwnerNetworkComponent != null)
         {
            mHeroGameObjectOwnerNetworkComponent.send_StopChoreography();
         }
      }
      
      public function attemptRevive(revivee:HeroGameObject) : void
      {
         var _loc2_:* = 0;
         mCurrentAttemptedRevivee = revivee;
         if(mDBFacade.dbConfigManager.getConfigBoolean("use_long_revive",true))
         {
            _loc2_ = 910900;
         }
         else
         {
            _loc2_ = 910901;
         }
         attack(_loc2_,revivee,1,mAttemptReviveScript,this.stateMachine.enterNavigationState,sendStopChoreography);
      }
      
      public function proposeCombatResults(combatResults:Vector.<CombatResult>) : void
      {
         if(mHeroGameObjectOwnerNetworkComponent != null)
         {
            mHeroGameObjectOwnerNetworkComponent.send_ProposeCombatResults(combatResults);
         }
      }
      
      public function proposeRevive() : void
      {
         if(mCurrentAttemptedRevivee != null && mCurrentAttemptedRevivee.isInReviveState())
         {
            if(mHeroGameObjectOwnerNetworkComponent != null)
            {
               mHeroGameObjectOwnerNetworkComponent.send_ProposeRevive(mCurrentAttemptedRevivee.id);
            }
         }
      }
      
      public function proposeSelfRevive(isParty:uint) : void
      {
         if(mHeroGameObjectOwnerNetworkComponent != null)
         {
            mHeroGameObjectOwnerNetworkComponent.send_ProposeSelfRevive(isParty);
         }
      }
      
      public function ProposeSelfRevive_Resp(yesno:uint, isParty:uint) : void
      {
         var _loc6_:Map = null;
         var _loc5_:Array = null;
         var _loc7_:* = 0;
         var _loc3_:StackableInfo = null;
         var _loc4_:* = 0;
         if(yesno)
         {
            _loc6_ = mDBFacade.dbAccountInfo.inventoryInfo.stackables;
            _loc5_ = _loc6_.keysToArray();
            _loc7_ = 60001;
            if(isParty)
            {
               _loc7_ = 60018;
            }
            for each(var _loc8_:uint in _loc5_)
            {
               _loc3_ = _loc6_.itemFor(_loc8_);
               if(_loc3_.gmId == _loc7_)
               {
                  _loc4_ = uint(_loc6_.itemFor(_loc8_).count);
                  _loc6_.itemFor(_loc8_).count--;
               }
            }
         }
         else
         {
            mEventComponent.dispatchEvent(new Event("purchaseReviveAll-failed"));
         }
      }
      
      public function ProposeCreateNPC(npcId:uint, weaponSlot:uint, x:int, y:int) : void
      {
         if(mHeroGameObjectOwnerNetworkComponent != null)
         {
            mHeroGameObjectOwnerNetworkComponent.send_ProposeCreateNPC(npcId,weaponSlot,x,y);
         }
      }
      
      public function get weaponRange() : uint
      {
         var _loc1_:GMAttack = mDBFacade.gameMaster.attackById.itemFor(30);
         return _loc1_.Range;
      }
      
      public function get inputController() : InputController
      {
         return mInputController;
      }
      
      override public function ReceiveAttackChoreography(attackChoreography:AttackChoreography) : void
      {
         super.ReceiveAttackChoreography(attackChoreography);
      }
      
      override public function set state(value:String) : void
      {
         super.state = value;
         if(value == "down")
         {
            if(this.view is HeroOwnerView)
            {
               (this.view as HeroOwnerView).stopHeartbeatSound();
            }
            this.mHeroView.velocity.scaleBy(0);
            this.navCollisions[0].velocity = this.mHeroView.velocity;
         }
      }
      
      override public function setStateAndAttackChoreography(targetState:String, attackChoreography:AttackChoreography) : void
      {
         mFromNetAttackChoreography = attackChoreography;
         state = targetState;
         ReceiveAttackChoreography(attackChoreography);
         mFromNetAttackChoreography = null;
      }
      
      override public function ponderBuffChanges() : void
      {
         mFacade.eventManager.dispatchEvent(new ManaEvent("ManaEvent_MANA_UPDATE",id,mMana,this.maxManaPoints));
         mFacade.eventManager.dispatchEvent(new HpEvent("HpEvent_HP_UPDATE",id,mHitPoints,this.maxHitPoints));
      }
      
      public function ReportBuffEffect(byWho:uint, amount:int, buffId:uint, effectiveness:int) : void
      {
         var _loc5_:ActorGameObject = mDistributedDungeonFloor.getActor(byWho);
         if(_loc5_ != null)
         {
            if(amount < 0)
            {
               _loc5_.actorView.spawnDamageFloater(false,amount,true,true,effectiveness,buffId,"BUFF_DAMAGE_MOVEMENT_TYPE");
            }
            else
            {
               _loc5_.actorView.spawnHealFloater(amount,true,true,effectiveness,buffId,"BUFF_DAMAGE_MOVEMENT_TYPE");
            }
         }
      }
      
      public function ReceivedBuffEffect(amount:int, buffId:uint, effectiveness:int) : void
      {
         if(amount < 0)
         {
            this.actorView.spawnDamageFloater(false,amount,true,true,effectiveness,buffId,"BUFF_DAMAGE_MOVEMENT_TYPE");
         }
         else
         {
            this.actorView.spawnHealFloater(amount,true,true,effectiveness,buffId,"BUFF_DAMAGE_MOVEMENT_TYPE");
         }
      }
      
      public function pauseMovement() : void
      {
         inputController.inputType = "lock_xy";
      }
      
      public function unPauseMovement() : void
      {
         inputController.inputType = "free";
      }
      
      public function TooFullForDoober(isHealthDoober:uint) : void
      {
         if(isHealthDoober == true)
         {
            mDBFacade.hud.showHealthFullMessage();
         }
         else
         {
            mDBFacade.hud.showManaFullMessage();
         }
      }
      
      public function tryToUseConsumable(num:uint) : void
      {
         mPlayerOwnerAttackController.tryToDoConsumableAttack(num);
      }
      
      public function startDeathCamInput() : void
      {
         mSelectedTargets = new Map();
         mDBFacade.stageRef.addEventListener("keyDown",checkDeathCamKeyEvent);
      }
      
      protected function checkDeathCamKeyEvent(kEvt:KeyboardEvent) : void
      {
         if(kEvt.keyCode == 32)
         {
            followNextAlly();
         }
      }
      
      public function stopDeathCamInput() : void
      {
         mDBFacade.stageRef.removeEventListener("keyDown",checkDeathCamKeyEvent);
         if(mSelectedTargets)
         {
            mSelectedTargets.clear();
         }
         mSelectedTargets = null;
         resetCamera();
      }
      
      public function followNextAlly() : void
      {
         var _loc2_:ActorGameObject = null;
         if(mSelectedTargets == null || mFollowCamera == null)
         {
            return;
         }
         if(mDistributedDungeonFloor == null || mDistributedDungeonFloor.remoteHeroes == null)
         {
            return;
         }
         var _loc3_:ActorGameObject = null;
         var _loc1_:IMapIterator = mDistributedDungeonFloor.remoteHeroes.iterator() as IMapIterator;
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next() as ActorGameObject;
            if(!(_loc2_ == null || mSelectedTargets.itemFor(_loc2_)))
            {
               _loc3_ = _loc2_;
               if(!(_loc3_.actorView == null || _loc3_.actorView.root == null))
               {
                  mFollowCamera.changeTarget(_loc3_.actorView.root);
               }
            }
         }
         if(_loc3_ == null)
         {
            mSelectedTargets.clear();
            resetCamera();
         }
         else
         {
            mSelectedTargets.add(_loc3_,true);
         }
      }
      
      public function resetCamera() : void
      {
         mFollowCamera.changeTarget(mHeroView.root);
      }
   }
}

