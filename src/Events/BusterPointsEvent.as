package Events
{
   public class BusterPointsEvent extends GameObjectEvent
   {
      
      public static const BUSTER_POINTS_UPDATE:String = "BusterPointEvent_BUSTER_POINTS_UPDATE";
      
      public var busterPoints:uint;
      
      public var maxBusterPoints:uint;
      
      public function BusterPointsEvent(type:String, id:uint, busterPoints:uint, maxBusterPoints:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.busterPoints = busterPoints;
         this.maxBusterPoints = maxBusterPoints;
         super(type,id,bubbles,cancelable);
      }
   }
}

