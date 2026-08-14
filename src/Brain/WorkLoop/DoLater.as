package Brain.WorkLoop
{
   public class DoLater extends Task implements IPrioritizable
   {
      
      public var delay:Number = 0;
      
      public var dueTime:uint = 0;
      
      protected var mRepeat:Boolean = true;
      
      public function DoLater(repeating:Boolean = true)
      {
         super();
         mRepeat = repeating;
      }
      
      public function get repeat() : Boolean
      {
         return mRepeat;
      }
      
      public function get priority() : int
      {
         return -dueTime;
      }
      
      public function set priority(value:int) : void
      {
         throw new Error("Not implemented, set dueTime and requeue");
      }
   }
}

