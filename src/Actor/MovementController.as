package Actor
{
   import Brain.Clock.GameClock;
   import Brain.WorkLoop.PreRenderWorkComponent;
   import Brain.WorkLoop.Task;
   import Brain.WorkLoop.WorkComponent;
   import Facade.DBFacade;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
   public class MovementController
   {
      
      public static const IDLE_VELOCITY_THRESHOLD:Number = 1;
      
      public static const MIN_HEADING_SPEED:Number = 2;
      
      private static const DEFAULT_SMOOTH_FACTOR:Number = 0.8;
      
      public static const LOCKED_HERO_MOVEMENT_TYPE:String = "locked_hero";
      
      public static const LOCKED_XY_MOVEMENT_TYPE:String = "locked_xy";
      
      public static const LOCKED_R_MOVEMENT_TYPE:String = "locked_r";
      
      public static const LOCKED_MOVEMENT_TYPE:String = "locked";
      
      public static const NORMAL_MOVEMENT_TYPE:String = "normal";
      
      public static const ZERO_VECTOR:Vector3D = new Vector3D();
      
      private static const sNewPos:Vector3D = new Vector3D();
      
      private static const sActorPos:Vector3D = new Vector3D();
      
      protected var mTargetPosition:Point = new Point(0,0);
      
      protected var mActorGameObject:ActorGameObject;
      
      protected var mView:ActorView;
      
      protected var mPositionLerpTask:Task;
      
      private var mLerpResting:Boolean;
      
      protected var mMovementType:String = "normal";
      
      protected var mPreRenderWorkComponent:WorkComponent;
      
      protected var mWantSmoothTelemetry:Boolean;
      
      protected var mSmoothFactor:Number = 0.8;
      
      protected var mDBFacade:DBFacade;
      
      public function MovementController(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mView = actorView;
         mActorGameObject = actorGameObject;
         mPreRenderWorkComponent = new PreRenderWorkComponent(dbFacade,"MovementController");
         mWantSmoothTelemetry = mDBFacade.dbConfigManager.getConfigBoolean("smooth_telemetry",true);
         mSmoothFactor = mDBFacade.dbConfigManager.getConfigNumber("smooth_telemetry_factor",0.8);
      }
      
      public function set movementType(moveType:String) : void
      {
         mView.position = mActorGameObject.position;
         mView.heading = mActorGameObject.heading;
         mMovementType = moveType;
      }
      
      public function get movementType() : String
      {
         return mMovementType;
      }
      
      public function get canMoveHero() : Boolean
      {
         return mMovementType != "locked_hero";
      }
      
      public function get canMoveXY() : Boolean
      {
         return mMovementType != "locked" && mMovementType != "locked_xy";
      }
      
      public function get canMoveR() : Boolean
      {
         return mMovementType != "locked" && mMovementType != "locked_r";
      }
      
      public function stopLerp() : void
      {
         if(mPositionLerpTask)
         {
            mPositionLerpTask.destroy();
            mPositionLerpTask = null;
         }
      }
      
      public function move(targetPosition:Vector3D, targetHeading:Number) : void
      {
         if(!canMoveXY)
         {
            if(mPositionLerpTask)
            {
               mPositionLerpTask.destroy();
               mPositionLerpTask = null;
            }
         }
         if(mActorGameObject.actorData && mActorGameObject.actorData.isMover)
         {
            if(!mPositionLerpTask)
            {
               mPositionLerpTask = mPreRenderWorkComponent.doEveryFrame(positionLerp);
            }
            mLerpResting = false;
         }
         else
         {
            mView.position = targetPosition;
            mView.heading = targetHeading;
         }
      }
      
      public function moveBody(targetPosition:Vector3D, targetHeading:Number) : void
      {
         mView.body.x = targetPosition.x;
         mView.body.y = targetPosition.y;
      }
      
      protected function positionLerp(gameClock:GameClock) : void
      {
         if(mLerpResting)
         {
            return;
         }
         var _loc3_:Number = mView.positionX;
         var _loc4_:Number = mView.positionY;
         var _loc2_:Vector3D = sActorPos;
         _loc2_.x = mActorGameObject.positionX;
         _loc2_.y = mActorGameObject.positionY;
         _loc2_.z = mActorGameObject.positionZ;
         var _loc6_:Vector3D = _loc2_;
         var _loc5_:Number = (1 - mSmoothFactor) * gameClock.timeScale;
         if(mWantSmoothTelemetry)
         {
            _loc6_ = sNewPos;
            _loc6_.x = _loc3_ * (1 - _loc5_) + _loc2_.x * _loc5_;
            _loc6_.y = _loc4_ * (1 - _loc5_) + _loc2_.y * _loc5_;
         }
         mView.velocity = new Vector3D(_loc6_.x - _loc3_,_loc6_.y - _loc4_,_loc6_.z);
         if(mView.velocity.nearEquals(ZERO_VECTOR,1))
         {
            mLerpResting = true;
            mView.heading = mActorGameObject.heading;
            mView.position = _loc2_;
            mView.velocity.scaleBy(0);
         }
         else
         {
            mView.position = _loc6_;
            if(canMoveR && (mView.velocity.length >= 2 || !mDBFacade.featureFlags.getFlagValue("smooth-run-and-direction-states")))
            {
               mView.heading = Math.atan2(mView.velocity.y,mView.velocity.x) * 180 / 3.141592653589793;
            }
         }
      }
      
      public function destroy() : void
      {
         if(mPositionLerpTask)
         {
            mPositionLerpTask.destroy();
            mPositionLerpTask = null;
         }
         mPreRenderWorkComponent.destroy();
         mDBFacade = null;
      }
   }
}

