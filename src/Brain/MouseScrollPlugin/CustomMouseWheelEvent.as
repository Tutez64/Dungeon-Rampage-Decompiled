package Brain.MouseScrollPlugin
{
   import flash.display.InteractiveObject;
   import flash.events.MouseEvent;
   
   public class CustomMouseWheelEvent extends MouseEvent
   {
      
      public static const MOVE:String = "onMove";
      
      public function CustomMouseWheelEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, localX:Number = 0, localY:Number = 0, relatedObject:InteractiveObject = null, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, buttonDown:Boolean = false, delta:int = 0)
      {
         super(type,bubbles,cancelable,localX,localY,relatedObject,ctrlKey,altKey,shiftKey,buttonDown,delta);
      }
   }
}

