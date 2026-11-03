package Events
{
   import flash.events.Event;
   
   public class GameObjectEvent extends Event
   {
      
      public var id:uint;
      
      public function GameObjectEvent(gameObjectEventType:String, id:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.id = id;
         super(uniqueEvent(gameObjectEventType,id),bubbles,cancelable);
      }
      
      public static function uniqueEvent(inType:String, id:uint) : String
      {
         return inType + "_" + id.toString();
      }
   }
}

