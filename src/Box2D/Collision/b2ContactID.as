package Box2D.Collision
{
   import flash.Boot;
   
   public class b2ContactID
   {
      
      public var features:Features;
      
      public var _key:int;
      
      public function b2ContactID()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _key = 0;
         features = new Features();
         features._m_id = this;
      }
      
      public function set_key(value:int) : int
      {
         _key = value;
         features._referenceEdge = _key & 0xFF;
         features._incidentEdge = (_key & 0xFF00) >> 8 & 0xFF;
         features._incidentVertex = (_key & 0xFF0000) >> 16 & 0xFF;
         features._flip = (_key & -16777216) >> 24 & 0xFF;
         return _key;
      }
      
      public function set(id:b2ContactID) : void
      {
         Set(id);
      }
      
      public function get_key() : int
      {
         return _key;
      }
      
      public function copy() : b2ContactID
      {
         return Copy();
      }
      
      public function Set(id:b2ContactID) : void
      {
         set_key(id._key);
      }
      
      public function Copy() : b2ContactID
      {
         var _loc1_:b2ContactID = new b2ContactID();
         _loc1_.set_key(get_key());
         return _loc1_;
      }
   }
}

