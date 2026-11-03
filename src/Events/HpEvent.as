package Events
{
   public class HpEvent extends GameObjectEvent
   {
      
      public static const HP_UPDATE:String = "HpEvent_HP_UPDATE";
      
      public var hp:uint;
      
      public var maxHp:uint;
      
      public function HpEvent(inType:String, id:uint, hp:uint, maxHp:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.hp = hp;
         this.maxHp = maxHp;
         super(inType,id,bubbles,cancelable);
      }
   }
}

