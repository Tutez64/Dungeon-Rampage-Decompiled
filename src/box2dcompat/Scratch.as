package box2dcompat
{
   import Box2D.Collision.b2AABB;
   import Box2D.Common.Math.b2Vec2;
   
   public class Scratch
   {
      
      public static var aabbs:Array = [new b2AABB(),new b2AABB()];
      
      public static var difference:b2Vec2 = new b2Vec2();
      
      public static var centre:b2Vec2 = new b2Vec2();
      
      public static var spare:b2AABB = new b2AABB();
      
      public function Scratch()
      {
      }
      
      public static function aabb(slot:int) : b2AABB
      {
         return Scratch.aabbs[slot];
      }
      
      public static function center(box:b2AABB) : b2Vec2
      {
         Scratch.centre.x = (box.lowerBound.x + box.upperBound.x) / 2;
         Scratch.centre.y = (box.lowerBound.y + box.upperBound.y) / 2;
         return Scratch.centre;
      }
      
      public static function swap(retired:b2AABB) : b2AABB
      {
         var _loc2_:b2AABB = Scratch.spare;
         Scratch.spare = retired;
         return _loc2_;
      }
      
      public static function subtract(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         Scratch.difference.x = a.x - b.x;
         Scratch.difference.y = a.y - b.y;
         return Scratch.difference;
      }
   }
}

