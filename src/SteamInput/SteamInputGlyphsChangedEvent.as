package SteamInput
{
   import flash.events.Event;
   
   public class SteamInputGlyphsChangedEvent extends Event
   {
      
      public static const TYPE:String = "OnSteamInputGlyphsChanged";
      
      public function SteamInputGlyphsChangedEvent()
      {
         super("OnSteamInputGlyphsChanged");
      }
   }
}

