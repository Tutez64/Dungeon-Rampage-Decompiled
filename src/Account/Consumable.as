package Account
{
   public class Consumable
   {
      
      public var stackId:uint;
      
      public var stackCount:uint;
      
      public var stackSlot:uint;
      
      public function Consumable(slot:uint, id:uint, count:uint)
      {
         super();
         stackId = id;
         stackCount = count;
         stackSlot = slot;
      }
   }
}

