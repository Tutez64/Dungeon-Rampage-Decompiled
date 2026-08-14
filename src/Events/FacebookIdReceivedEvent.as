package Events
{
   public class FacebookIdReceivedEvent extends GameObjectEvent
   {
      
      public static const NAME:String = "FACEBOOK_ID_RECEIVED_EVENT";
      
      private var mFacebookId:String;
      
      public function FacebookIdReceivedEvent(type:String, id:uint, facebookId:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         mFacebookId = facebookId;
         super(type,id,bubbles,cancelable);
      }
      
      public function get facebookId() : String
      {
         return mFacebookId;
      }
   }
}

