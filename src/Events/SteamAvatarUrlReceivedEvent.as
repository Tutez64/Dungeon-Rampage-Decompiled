package Events
{
   public class SteamAvatarUrlReceivedEvent extends GameObjectEvent
   {
      
      public static const NAME:String = "STEAM_AVATAR_URL_RECEIVED_EVENT";
      
      private var mSteamAvatarUrl:String;
      
      public function SteamAvatarUrlReceivedEvent(steamAvatarUrlReceivedEventType:String, id:uint, steamAvatarUrl:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         mSteamAvatarUrl = steamAvatarUrl;
         super(steamAvatarUrlReceivedEventType,id,bubbles,cancelable);
      }
      
      public function get steamAvatarUrl() : String
      {
         return mSteamAvatarUrl;
      }
   }
}

