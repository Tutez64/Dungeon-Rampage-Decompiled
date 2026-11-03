package Box2D.Collision
{
   import flash.Boot;
   
   public class Features
   {
      
      public var _referenceEdge:int;
      
      public var _m_id:b2ContactID;
      
      public var _incidentVertex:int;
      
      public var _incidentEdge:int;
      
      public var _flip:int;
      
      public function Features()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _flip = 0;
         _incidentVertex = 0;
         _incidentEdge = 0;
         _referenceEdge = 0;
      }
      
      public function set_referenceEdge(value:int) : int
      {
         _referenceEdge = value;
         _m_id._key = _m_id._key & -256 | _referenceEdge & 0xFF;
         return value;
      }
      
      public function set_incidentVertex(value:int) : int
      {
         _incidentVertex = value;
         _m_id._key = _m_id._key & -16711681 | _incidentVertex << 16 & 0xFF0000;
         return value;
      }
      
      public function set_incidentEdge(value:int) : int
      {
         _incidentEdge = value;
         _m_id._key = _m_id._key & -65281 | _incidentEdge << 8 & 0xFF00;
         return value;
      }
      
      public function set_flip(value:int) : int
      {
         _flip = value;
         _m_id._key = _m_id._key & 0xFFFFFF | _flip << 24 & -16777216;
         return value;
      }
      
      public function get_referenceEdge() : int
      {
         return _referenceEdge;
      }
      
      public function get_incidentVertex() : int
      {
         return _incidentVertex;
      }
      
      public function get_incidentEdge() : int
      {
         return _incidentEdge;
      }
      
      public function get_flip() : int
      {
         return _flip;
      }
   }
}

