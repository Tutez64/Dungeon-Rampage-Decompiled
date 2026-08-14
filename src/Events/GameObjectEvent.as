package Events
{
   import flash.events.Event;
   
   public class GameObjectEvent extends Event
   {
      
      public var id:uint;
      
      public function GameObjectEvent(type:String, id:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.id = id;
         super(uniqueEvent(type,id),bubbles,cancelable);
      }
      
      public static function uniqueEvent(type:String, id:uint) : String
      {
         return type + "_" + id.toString();
      }
   }
}

