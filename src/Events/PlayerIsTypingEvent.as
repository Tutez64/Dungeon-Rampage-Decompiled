package Events
{
   public class PlayerIsTypingEvent extends GameObjectEvent
   {
      
      public static const PLAYER_IS_TYPING:String = "PLAYER_IS_TYPING";
      
      public static const PLAYER_CHAT_FOCUS_IN:String = "CHAT_BOX_FOCUS_IN";
      
      public static const PLAYER_CHAT_FOCUS_OUT:String = "CHAT_BOX_FOCUS_OUT";
      
      public var subtype:String;
      
      public function PlayerIsTypingEvent(type:String, id:uint, subType:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         subtype = subType;
         super(type,id,bubbles,cancelable);
      }
   }
}

