package Config
{
   import flash.events.Event;
   
   public class ServiceDiscoveryReadyEvent extends Event
   {
      
      public static const EVENT_NAME:String = "ServiceDiscoveryReadyEvent";
      
      public var serviceDiscoveryResult:Object;
      
      public var serviceDiscoveryErrorCode:int;
      
      public var serviceDiscoveryErrorText:String;
      
      public function ServiceDiscoveryReadyEvent(result:Object, errorCode:int, errorText:String = "")
      {
         super("ServiceDiscoveryReadyEvent",true);
         serviceDiscoveryResult = result;
         serviceDiscoveryErrorCode = errorCode;
         serviceDiscoveryErrorText = errorText;
      }
   }
}

