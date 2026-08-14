package Events
{
   import flash.events.Event;
   
   public class FriendshipEvent extends Event
   {
      
      public var id:uint;
      
      public function FriendshipEvent(type:String, id:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         this.id = id;
      }
   }
}

