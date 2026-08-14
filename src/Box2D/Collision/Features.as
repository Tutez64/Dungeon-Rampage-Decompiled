package Box2D.Collision
{
   import Box2D.Common.b2internal;
   
   use namespace b2internal;
   
   public class Features
   {
      
      b2internal var _referenceEdge:int;
      
      b2internal var _incidentEdge:int;
      
      b2internal var _incidentVertex:int;
      
      b2internal var _flip:int;
      
      b2internal var _m_id:b2ContactID;
      
      public function Features()
      {
         super();
      }
      
      public function get referenceEdge() : int
      {
         return this._referenceEdge;
      }
      
      public function set referenceEdge(value:int) : void
      {
         this._referenceEdge = value;
         this._m_id._key = this._m_id._key & 0xFFFFFF00 | this._referenceEdge & 0xFF;
      }
      
      public function get incidentEdge() : int
      {
         return this._incidentEdge;
      }
      
      public function set incidentEdge(value:int) : void
      {
         this._incidentEdge = value;
         this._m_id._key = this._m_id._key & 0xFFFF00FF | this._incidentEdge << 8 & 0xFF00;
      }
      
      public function get incidentVertex() : int
      {
         return this._incidentVertex;
      }
      
      public function set incidentVertex(value:int) : void
      {
         this._incidentVertex = value;
         this._m_id._key = this._m_id._key & 0xFF00FFFF | this._incidentVertex << 16 & 0xFF0000;
      }
      
      public function get flip() : int
      {
         return this._flip;
      }
      
      public function set flip(value:int) : void
      {
         this._flip = value;
         this._m_id._key = this._m_id._key & 0xFFFFFF | this._flip << 24 & 0xFF000000;
      }
   }
}

