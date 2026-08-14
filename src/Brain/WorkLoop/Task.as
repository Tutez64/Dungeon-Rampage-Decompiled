package Brain.WorkLoop
{
   public class Task
   {
      
      public var callback:Function = null;
      
      protected var mDestroyed:Boolean = false;
      
      public function Task()
      {
         super();
      }
      
      public function destroy() : void
      {
         mDestroyed = true;
         callback = null;
      }
      
      public function isDestroyed() : Boolean
      {
         return mDestroyed;
      }
   }
}

