package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Clock.GameClock;
   import Brain.WorkLoop.Task;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   
   public class TeleportTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "teleport";
      
      private var mFramesElapsed:uint;
      
      private var mDuration:uint;
      
      private var mMovementTask:Task;
      
      private var mStartPos:Vector3D;
      
      private var mEndPos:Vector3D;
      
      private var mOffset:Vector3D;
      
      public function TeleportTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, duration:uint)
      {
         mDuration = duration;
         super(actorGameObject,actorView,dbFacade);
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : TeleportTimelineAction
      {
         var _loc5_:Number = Number(actionObj.duration);
         return new TeleportTimelineAction(actorGameObject,actorView,dbFacade,_loc5_);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         if(mFramesElapsed != 0)
         {
            ResetMovement();
         }
         mFramesElapsed = 0;
         if(mMovementTask)
         {
            mMovementTask.destroy();
            mMovementTask = null;
         }
         if(mWorkComponent)
         {
            mMovementTask = mWorkComponent.doEveryFrame(UpdateMovement);
         }
      }
      
      public function initMovementData() : void
      {
         var _loc1_:HeroGameObjectOwner = null;
         if(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) is HeroGameObjectOwner)
         {
            _loc1_ = mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) as HeroGameObjectOwner;
            mStartPos = _loc1_.position;
            mEndPos = _loc1_.mTeleportDestination;
            mOffset = new Vector3D(mEndPos.x - mStartPos.x,mEndPos.y - mStartPos.y);
         }
      }
      
      public function moveHero() : void
      {
         var _loc1_:HeroGameObjectOwner = null;
         if(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) is HeroGameObjectOwner)
         {
            _loc1_ = mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) as HeroGameObjectOwner;
            mStartPos = _loc1_.position;
            _loc1_.moveToTeleDest();
            mEndPos = _loc1_.mTeleportDestination;
            mOffset = new Vector3D(mEndPos.x - mStartPos.x,mEndPos.y - mStartPos.y);
         }
      }
      
      public function stopHeroMovement() : void
      {
         var _loc1_:HeroGameObjectOwner = null;
         if(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) is HeroGameObjectOwner)
         {
            _loc1_ = mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) as HeroGameObjectOwner;
            _loc1_.stopMovement();
         }
      }
      
      public function easeInOutQuad(t:Number, b:Number, c:Number, d:Number) : Number
      {
         t /= d / 2;
         if(t < 1)
         {
            return c / 2 * t * t + b;
         }
         t--;
         return -c / 2 * (t * (t - 2) - 1) + b;
      }
      
      public function updateView() : void
      {
         var _loc5_:HeroGameObjectOwner = null;
         var _loc4_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc2_:Vector3D = null;
         var _loc3_:Vector3D = null;
         if(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) is HeroGameObjectOwner)
         {
            _loc5_ = mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) as HeroGameObjectOwner;
            _loc4_ = mFramesElapsed / mDuration;
            _loc4_ = easeInOutQuad(mFramesElapsed,0,1,mDuration);
            _loc1_ = 1 - _loc4_;
            _loc2_ = new Vector3D(mStartPos.x * _loc1_ + mEndPos.x * _loc4_,mStartPos.y * _loc1_ + mEndPos.y * _loc4_);
            _loc5_.placeAt(_loc2_);
            _loc3_ = new Vector3D(mOffset.x * _loc1_,mOffset.y * _loc1_);
            _loc5_.moveBodyTo(_loc3_);
         }
      }
      
      public function UpdateMovement(clock:GameClock) : void
      {
         if(mActorView && mActorView.body)
         {
            mFramesElapsed = mFramesElapsed + 1;
            if(mFramesElapsed == 1)
            {
               stopHeroMovement();
               initMovementData();
            }
            else if(mFramesElapsed <= mDuration)
            {
               updateView();
            }
            else if(mFramesElapsed > mDuration)
            {
               ResetMovement();
               return;
            }
            return;
         }
         ResetMovement();
      }
      
      private function ResetMovement() : void
      {
         var _loc1_:HeroGameObjectOwner = null;
         mFramesElapsed = 0;
         if(mActorView && mActorView.body)
         {
         }
         if(mMovementTask)
         {
            mMovementTask.destroy();
            mMovementTask = null;
         }
         if(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) is HeroGameObjectOwner)
         {
            _loc1_ = mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) as HeroGameObjectOwner;
         }
      }
      
      override public function destroy() : void
      {
         if(mMovementTask)
         {
            mMovementTask.destroy();
            mMovementTask = null;
         }
         super.destroy();
      }
   }
}

