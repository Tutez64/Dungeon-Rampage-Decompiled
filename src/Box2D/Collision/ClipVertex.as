package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class ClipVertex
   {
      
      public var v:b2Vec2;
      
      public var id:b2ContactID;
      
      public function ClipVertex()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         v = new b2Vec2();
         id = new b2ContactID();
      }
      
      public function set(other:ClipVertex) : void
      {
         Set(other);
      }
      
      public function Set(other:ClipVertex) : void
      {
         v.setV(other.v);
         id.set(other.id);
      }
   }
}

