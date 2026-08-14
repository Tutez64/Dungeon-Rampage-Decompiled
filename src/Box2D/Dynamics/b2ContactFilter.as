package Box2D.Dynamics
{
   import Box2D.Common.b2internal;
   
   use namespace b2internal;
   
   public class b2ContactFilter
   {
      
      b2internal static var b2_defaultFilter:b2ContactFilter = new b2ContactFilter();
      
      public function b2ContactFilter()
      {
         super();
      }
      
      public function ShouldCollide(fixtureA:b2Fixture, fixtureB:b2Fixture) : Boolean
      {
         var _loc3_:b2FilterData = fixtureA.GetFilterData();
         var _loc4_:b2FilterData = fixtureB.GetFilterData();
         if(_loc3_.groupIndex == _loc4_.groupIndex && _loc3_.groupIndex != 0)
         {
            return _loc3_.groupIndex > 0;
         }
         return (_loc3_.maskBits & _loc4_.categoryBits) != 0 && (_loc3_.categoryBits & _loc4_.maskBits) != 0;
      }
      
      public function RayCollide(userData:*, fixture:b2Fixture) : Boolean
      {
         if(!userData)
         {
            return true;
         }
         return this.ShouldCollide(userData as b2Fixture,fixture);
      }
   }
}

