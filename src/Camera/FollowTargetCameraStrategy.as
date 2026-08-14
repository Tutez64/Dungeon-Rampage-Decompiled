package Camera
{
   import Brain.Camera.Camera;
   import Brain.Camera.CameraStrategy;
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.WorkLoop.Task;
   import Brain.WorkLoop.WorkComponent;
   import flash.display.Sprite;
   import flash.geom.Vector3D;
   
   public class FollowTargetCameraStrategy extends CameraStrategy
   {
      
      private var mFacade:Facade;
      
      private var mTarget:Sprite;
      
      private var mUpdateTask:Task;
      
      private var mCameraVel:Vector3D = new Vector3D();
      
      private var mForce:Number = 4;
      
      private var mMaxSpeed:Number = 20.833333333333332;
      
      public function FollowTargetCameraStrategy(camera:Camera, target:Sprite)
      {
         mTarget = target;
         super(camera);
      }
      
      override public function destroy() : void
      {
         stop();
         super.destroy();
         mTarget = null;
         mFacade = null;
      }
      
      override public function start(workComponent:WorkComponent) : void
      {
         if(mUpdateTask)
         {
            mUpdateTask.destroy();
         }
         mUpdateTask = workComponent.doEveryFrame(update);
      }
      
      override public function stop() : void
      {
         if(mUpdateTask)
         {
            mUpdateTask.destroy();
            mUpdateTask = null;
         }
      }
      
      private function update(gameClock:GameClock) : void
      {
         mCameraVel = mCamera.getDeltaToPoint(mTarget.x,mTarget.y);
         if(mCameraVel.lengthSquared > 0.5)
         {
            mCamera.translateBy(mCameraVel.x,mCameraVel.y);
         }
         mCamera.update(gameClock);
      }
      
      public function changeTarget(newTarget:Sprite) : void
      {
         mTarget = newTarget;
      }
   }
}

