package Config
{
   import flash.events.Event;
   
   public class ConfigFileLoadedEvent extends Event
   {
      
      public static const EVENT_NAME:String = "ConfigFileLoadedEvent";
      
      protected var mDBConfigManager:DBConfigManager;
      
      public function ConfigFileLoadedEvent(configManager:DBConfigManager, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("ConfigFileLoadedEvent",bubbles,cancelable);
         mDBConfigManager = configManager;
      }
      
      public function get dbConfigManager() : DBConfigManager
      {
         return mDBConfigManager;
      }
   }
}

