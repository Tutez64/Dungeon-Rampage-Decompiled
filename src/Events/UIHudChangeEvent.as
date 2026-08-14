package Events
{
   import flash.events.Event;
   
   public class UIHudChangeEvent extends Event
   {
      
      public static const UI_HUD_CHANGE_EVENT:String = "UI_HUD_CHANGE_EVENT";
      
      public static const DEFAULT_UI_HUD_TYPE:uint = 0;
      
      public static const CONDENSED_UI_HUD_TYPE:uint = 1;
      
      private var mHudType:uint;
      
      public function UIHudChangeEvent(hudType:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("UI_HUD_CHANGE_EVENT",bubbles,cancelable);
         mHudType = hudType;
      }
      
      public function get hudType() : uint
      {
         return mHudType;
      }
   }
}

