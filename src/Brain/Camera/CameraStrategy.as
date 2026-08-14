package Brain.Camera
{
   import Brain.WorkLoop.WorkComponent;
   
   public class CameraStrategy
   {
      
      protected var mCamera:Camera;
      
      public function CameraStrategy(camera:Camera)
      {
         super();
         mCamera = camera;
      }
      
      public function destroy() : void
      {
         mCamera = null;
         stop();
      }
      
      public function start(workComponent:WorkComponent) : void
      {
         throw new Error("Override this start function in the camera strategy sub-class.");
      }
      
      public function stop() : void
      {
         throw new Error("Override this stop function in the camera strategy sub-class.");
      }
   }
}

