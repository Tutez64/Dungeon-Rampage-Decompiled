package Brain.MouseScrollPlugin
{
   import flash.display.InteractiveObject;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.utils.getTimer;
   
   public class MouseWheelEnabler
   {
      
      private static var initialised:Boolean = false;
      
      private static var currentItem:InteractiveObject;
      
      private static var browserMouseEvent:MouseEvent;
      
      private static var lastEventTime:uint = 0;
      
      public static var useRawValues:Boolean;
      
      public static var eventTimeout:Number = 50;
      
      public function MouseWheelEnabler()
      {
         super();
      }
      
      public static function init(stage:Stage, useRawDelta:Boolean = false) : void
      {
         if(!initialised)
         {
            initialised = true;
            registerListenerForMouseMove(stage);
            registerJS();
         }
         useRawValues = useRawDelta;
      }
      
      private static function registerListenerForMouseMove(stage:Stage) : void
      {
         stage.addEventListener("mouseMove",function(param1:MouseEvent):void
         {
            currentItem = InteractiveObject(param1.target);
            browserMouseEvent = MouseEvent(param1);
         });
      }
      
      private static function registerJS() : void
      {
         var id:String;
         if(ExternalInterface.available)
         {
            id = "mws_" + Math.floor(Math.random() * 1000000);
            ExternalInterface.addCallback(id,function():void
            {
            });
            ExternalInterface.call("mws.InitMouseWheelSupport",id);
            ExternalInterface.addCallback("externalMouseEvent",handleExternalMouseEvent);
         }
      }
      
      private static function handleExternalMouseEvent(rawDelta:Number, scaledDelta:Number) : void
      {
         var _loc4_:Number = NaN;
         var _loc3_:uint = uint(getTimer());
         if(_loc3_ >= eventTimeout + lastEventTime)
         {
            if(useRawValues)
            {
               _loc4_ = rawDelta;
            }
            else
            {
               _loc4_ = scaledDelta;
            }
            if(currentItem && browserMouseEvent)
            {
               currentItem.dispatchEvent(new CustomMouseWheelEvent("onMove",true,false,browserMouseEvent.localX,browserMouseEvent.localY,browserMouseEvent.relatedObject,browserMouseEvent.ctrlKey,browserMouseEvent.altKey,browserMouseEvent.shiftKey,browserMouseEvent.buttonDown,int(_loc4_)));
            }
            lastEventTime = _loc3_;
         }
      }
      
      public static function getBrowserInfo() : BrowserInfo
      {
         var _loc3_:Object = null;
         var _loc2_:Object = null;
         var _loc1_:String = null;
         if(ExternalInterface.available)
         {
            _loc3_ = ExternalInterface.call("mws.getBrowserInfo");
            _loc2_ = ExternalInterface.call("mws.getPlatformInfo");
            _loc1_ = ExternalInterface.call("mws.getAgentInfo");
            return new BrowserInfo(_loc3_,_loc2_,_loc1_);
         }
         return null;
      }
   }
}

