package Brain.Event
{
   import flash.events.IEventDispatcher;
   
   public class EventListeners
   {
      
      public function EventListeners()
      {
         super();
      }
      
      public static function add(dispatcher:IEventDispatcher, type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
      {
         dispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }
      
      public static function remove(dispatcher:IEventDispatcher, type:String, listener:Function, useCapture:Boolean = false) : void
      {
         dispatcher.removeEventListener(type,listener,useCapture);
      }
   }
}

