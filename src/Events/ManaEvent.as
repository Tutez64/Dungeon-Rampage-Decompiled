package Events
{
   public class ManaEvent extends GameObjectEvent
   {
      
      public static const MANA_UPDATE:String = "ManaEvent_MANA_UPDATE";
      
      public var mana:uint;
      
      public var maxMana:uint;
      
      public function ManaEvent(inType:String, id:uint, mana:uint, maxMana:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.mana = mana;
         this.maxMana = maxMana;
         super(inType,id,bubbles,cancelable);
      }
   }
}

