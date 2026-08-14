package Actor.Player.Input
{
   import Actor.ActorGameObject;
   import Box2D.Collision.b2Distance;
   import Box2D.Collision.b2DistanceInput;
   import Box2D.Collision.b2DistanceOutput;
   import Box2D.Collision.b2DistanceProxy;
   import Box2D.Collision.b2SimplexCache;
   import Brain.Logger.Logger;
   import Brain.Utils.Tuple;
   import Combat.Weapon.WeaponGameObject;
   import DistributedObjects.HeroGameObjectOwner;
   import Dungeon.NavCollider;
   import Facade.DBFacade;
   import flash.events.MouseEvent;
   import flash.geom.Vector3D;
   
   public class GBS_ModernMouseController extends MouseController
   {
      
      private static const mLeftClickWeaponIndex:int = 0;
      
      private static const mRightClickWeaponIndex:int = 1;
      
      private static const mMiddleClickWeaponIndex:int = 2;
      
      private var mCurrentTarget:ActorGameObject;
      
      private var mClickedLocation:Vector3D;
      
      private var mIsStationaryAttack:Boolean = false;
      
      private var mHeroLocationPreviousFrame:Vector3D;
      
      private var mDistanceInputCache:b2DistanceInput;
      
      private var mDistanceOutputCache:b2DistanceOutput;
      
      private var mDistanceSimplexCache:b2SimplexCache;
      
      public function GBS_ModernMouseController(dbFacade:DBFacade, heroOwner:HeroGameObjectOwner)
      {
         super(dbFacade,heroOwner);
         mInputHeading = new Vector3D();
         mDistanceInputCache = new b2DistanceInput();
         mDistanceInputCache.proxyA = new b2DistanceProxy();
         mDistanceInputCache.proxyB = new b2DistanceProxy();
         mDistanceOutputCache = new b2DistanceOutput();
         mDistanceSimplexCache = new b2SimplexCache();
         mDistanceSimplexCache.count = 0;
         mHeroLocationPreviousFrame = mHeroGameObjectOwner.view.position;
      }
      
      override protected function handleMouseDown(mouseDownEvent:MouseEvent) : void
      {
         super.handleMouseDown(mouseDownEvent);
      }
      
      override protected function determineSelection() : void
      {
         checkStationaryKey();
         if(mMouseDownThisFrame)
         {
            faceLocation(getMouseWorldLocation());
            cancelMovementAction();
            clearCurrentTarget();
            if(mMouseDownActorThisFrame && isValidTarget(mMouseDownActorThisFrame))
            {
               mCurrentTarget = mMouseDownActorThisFrame;
            }
            else
            {
               mClickedLocation = getMouseWorldLocation();
               mHeroGameObjectOwner.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),"UI_pointer_click",mClickedLocation);
            }
         }
         if(mMouseUpThisFrame)
         {
            if(mCurrentTarget != null && mActorMousedOver != mCurrentTarget)
            {
               setCurrentTargetSelection(false);
            }
         }
         if(mCurrentTarget != null && mCurrentTarget.isDead())
         {
            handleCurrentTargetDied();
         }
      }
      
      private function checkStationaryKey() : void
      {
         if(!mIsStationaryAttack && mDBFacade.inputManager.check(16))
         {
            cancelMovementAction();
            mIsStationaryAttack = true;
         }
         else if(mIsStationaryAttack && !mDBFacade.inputManager.check(16))
         {
            mHeroGameObjectOwner.PlayerAttack.stopAttacking();
            mIsStationaryAttack = false;
         }
      }
      
      private function checkForAlternateWeaponAttacks() : void
      {
         if(mRightMouseDown)
         {
            handleAlternateWeaponAttack(1);
         }
         else if(mMiddleMouseDown)
         {
            handleAlternateWeaponAttack(2);
         }
      }
      
      private function handleAlternateWeaponAttack(weaponIndex:int) : void
      {
         clearMovement();
         faceLocation(getMouseWorldLocation());
         beginAttack(weaponIndex);
      }
      
      private function handleCurrentTargetDied() : void
      {
         if(mCurrentTarget.actorView != null)
         {
            mCurrentTarget.actorView.mouseOverUnhighlight();
         }
         setCurrentTargetSelection(false);
         mCurrentTarget = null;
         mHeroGameObjectOwner.PlayerAttack.stopAttacking();
      }
      
      override protected function determineMotion() : void
      {
         var _loc1_:Vector3D = null;
         var _loc2_:Vector3D = null;
         if(mCurrentTarget != null && mCurrentTarget.actorView != null)
         {
            attackMoveToTarget(mCurrentTarget);
         }
         else if(mClickedLocation != null)
         {
            if(mDBFacade.inputManager.mouseDown)
            {
               _loc1_ = getMouseWorldLocation();
               _loc2_ = _loc1_.subtract(mHeroGameObjectOwner.view.position);
               if(_loc2_.length > 50)
               {
                  mClickedLocation = _loc1_;
               }
            }
            walkToLocation();
         }
      }
      
      override protected function determineAttacks() : void
      {
         checkForAlternateWeaponAttacks();
         if(mIsStationaryAttack)
         {
            handleStationaryAttack();
         }
      }
      
      private function handleStationaryAttack() : void
      {
         if(mDBFacade.inputManager.mouseDown)
         {
            faceLocation(getMouseWorldLocation());
            beginAttack();
         }
         else
         {
            mHeroGameObjectOwner.PlayerAttack.stopAttacking();
         }
      }
      
      private function zeroVelocity() : void
      {
         mInputVelocity.x = 0;
         mInputVelocity.y = 0;
      }
      
      private function getMouseWorldLocation() : Vector3D
      {
         return mDBFacade.camera.getWorldCoordinateFromMouse(mDBFacade.inputManager.mouseX,mDBFacade.inputManager.mouseY);
      }
      
      private function setCurrentTargetSelection(isSelected:Boolean) : void
      {
         if(mCurrentTarget.actorView == null)
         {
            return;
         }
         if(isSelected)
         {
            mCurrentTarget.actorView.mouseSelectedHighlight();
         }
         else
         {
            mCurrentTarget.actorView.mouseSelectedUnhighlight();
         }
      }
      
      private function clearCurrentTarget() : void
      {
         if(mCurrentTarget == null)
         {
            return;
         }
         setCurrentTargetSelection(false);
         mCurrentTarget = null;
      }
      
      private function cancelMovementAction() : void
      {
         mClickedLocation = null;
      }
      
      private function isPrimaryWeaponRanged() : Boolean
      {
         if(mHeroGameObjectOwner.weapons.length == 0)
         {
            return false;
         }
         var _loc1_:WeaponGameObject = mHeroGameObjectOwner.weapons[0];
         if(_loc1_ == null)
         {
            return false;
         }
         return mHeroGameObjectOwner.weapons[0].weaponData.ClassType == "SHOOTING" || mHeroGameObjectOwner.weapons[0].weaponData.ClassType == "MAGIC";
      }
      
      private function isValidTarget(actor:ActorGameObject) : Boolean
      {
         return !actor.isDead();
      }
      
      private function walkToLocation() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Vector3D = null;
         var _loc1_:Number = NaN;
         if(mClickedLocation)
         {
            _loc2_ = 10;
            _loc3_ = mClickedLocation.subtract(mHeroGameObjectOwner.view.position);
            if(_loc3_.length > _loc2_)
            {
               _loc1_ = 50;
               moveTowardsLocation(mClickedLocation,_loc3_.length > _loc1_);
            }
            else
            {
               if(!mDBFacade.inputManager.mouseDown)
               {
                  mClickedLocation = null;
               }
               zeroVelocity();
            }
         }
      }
      
      private function attackMoveToTarget(inTarget:ActorGameObject) : void
      {
         setCurrentTargetSelection(true);
         if(isHeroInWeaponRange(inTarget))
         {
            beginAttack();
            zeroVelocity();
            if(!mDBFacade.inputManager.mouseDown)
            {
               clearCurrentTarget();
            }
         }
         else
         {
            moveTowardsLocation(inTarget.actorView.position,true);
         }
      }
      
      private function isHeroInWeaponRange(inTarget:ActorGameObject) : Boolean
      {
         if(isPrimaryWeaponRanged())
         {
            return true;
         }
         var _loc3_:Number = 0.25;
         var _loc2_:Number = getHeroDistanceToObject(inTarget);
         return _loc3_ >= _loc2_;
      }
      
      public function getHeroDistanceToObject(gameObject:ActorGameObject) : Number
      {
         if(mHeroGameObjectOwner.navCollisions.length == 0)
         {
            Logger.warn("getHeroDistanceToObject - Hero Game Object has no NavColliders");
            return 0;
         }
         if(gameObject.navCollisions.length == 0)
         {
            Logger.warn("getHeroDistanceToObject - GameObject has no NavColliders");
            return 0;
         }
         var _loc3_:NavCollider = mHeroGameObjectOwner.navCollisions[0];
         var _loc2_:NavCollider = gameObject.navCollisions[0];
         mDistanceInputCache.proxyA.Set(_loc3_.getShape());
         mDistanceInputCache.proxyB.Set(_loc2_.getShape());
         mDistanceInputCache.transformA = _loc3_.getBody().GetTransform();
         mDistanceInputCache.transformB = _loc2_.getBody().GetTransform();
         mDistanceInputCache.useRadii = true;
         mDistanceSimplexCache.count = 0;
         b2Distance.Distance(mDistanceOutputCache,mDistanceSimplexCache,mDistanceInputCache);
         return mDistanceOutputCache.distance;
      }
      
      public function beginAttack(weaponIndex:int = 0) : void
      {
         mPotentialAttacksThisFrame.push(new Tuple(weaponIndex,false));
      }
      
      public function moveTowardsLocation(location:Vector3D, faceMovementDirection:Boolean) : void
      {
         var _loc5_:Vector3D = mHeroGameObjectOwner.view.position;
         if(mDBFacade.inputManager.mouseUp)
         {
            if(mHeroLocationPreviousFrame.equals(_loc5_))
            {
               clearMovement();
               return;
            }
         }
         if(faceMovementDirection)
         {
            faceLocation(location);
         }
         var _loc3_:Number = mHeroGameObjectOwner.movementSpeed;
         var _loc4_:Vector3D = location.subtract(_loc5_);
         _loc4_.normalize();
         _loc4_.scaleBy(_loc3_);
         mInputVelocity = _loc4_;
         mHeroLocationPreviousFrame = _loc5_;
      }
      
      public function faceLocation(location:Vector3D) : void
      {
         var _loc2_:Vector3D = location.subtract(mHeroGameObjectOwner.worldCenter);
         _loc2_.normalize();
         mInputHeading = _loc2_;
      }
      
      override public function clearMovement() : void
      {
         if(mDBFacade.inputManager.mouseUp)
         {
            clearCurrentTarget();
            cancelMovementAction();
         }
         zeroVelocity();
         mInputHeading.setTo(0,0,0);
      }
   }
}

