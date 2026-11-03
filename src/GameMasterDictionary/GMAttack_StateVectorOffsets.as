package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMAttack_StateVectorOffsets
   {
      
      public var type:Number;
      
      public var speed:Number;
      
      public var offence:Number;
      
      public var defence:Number;
      
      public function GMAttack_StateVectorOffsets(sp:Number = 0, off:Number = 0, def:Number = 0, tp:Number = 0)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         speed = sp;
         offence = off;
         defence = def;
         type = tp;
      }
   }
}

