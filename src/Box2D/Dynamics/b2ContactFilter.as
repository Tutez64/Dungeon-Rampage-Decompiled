package Box2D.Dynamics
{
   public class b2ContactFilter
   {
      
      public static var b2_defaultFilter:b2ContactFilter = new b2ContactFilter();
      
      public function b2ContactFilter()
      {
      }
      
      public function shouldCollide(fixtureA:b2Fixture, fixtureB:b2Fixture) : Boolean
      {
         return ShouldCollide(fixtureA,fixtureB);
      }
      
      public function rayCollide(userData:*, fixture:b2Fixture) : Boolean
      {
         return RayCollide(userData,fixture);
      }
      
      public function ShouldCollide(fixtureA:b2Fixture, fixtureB:b2Fixture) : Boolean
      {
         var _loc3_:b2FilterData = fixtureA.getFilterData();
         var _loc4_:b2FilterData = fixtureB.getFilterData();
         if(_loc3_.groupIndex == _loc4_.groupIndex && _loc3_.groupIndex != 0)
         {
            return _loc3_.groupIndex > 0;
         }
         return (_loc3_.maskBits & _loc4_.categoryBits) != 0 && (_loc3_.categoryBits & _loc4_.maskBits) != 0;
      }
      
      public function RayCollide(userData:*, fixture:b2Fixture) : Boolean
      {
         if(userData == null)
         {
            return true;
         }
         return shouldCollide(userData,fixture);
      }
   }
}

