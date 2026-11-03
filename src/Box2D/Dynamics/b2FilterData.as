package Box2D.Dynamics
{
   import flash.Boot;
   
   public class b2FilterData
   {
      
      public var maskBits:int;
      
      public var groupIndex:int;
      
      public var categoryBits:int;
      
      public function b2FilterData()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         categoryBits = 1;
         maskBits = 65535;
         groupIndex = 0;
      }
      
      public function copy() : b2FilterData
      {
         return Copy();
      }
      
      public function Copy() : b2FilterData
      {
         var _loc1_:b2FilterData = new b2FilterData();
         _loc1_.categoryBits = categoryBits;
         _loc1_.maskBits = maskBits;
         _loc1_.groupIndex = groupIndex;
         return _loc1_;
      }
   }
}

