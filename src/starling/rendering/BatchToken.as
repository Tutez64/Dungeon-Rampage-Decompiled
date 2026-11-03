package starling.rendering
{
   import starling.utils.StringUtil;
   
   public class BatchToken
   {
      
      public var batchID:int;
      
      public var vertexID:int;
      
      public var indexID:int;
      
      public function BatchToken(batchID:int = 0, vertexID:int = 0, indexID:int = 0)
      {
         super();
         setTo(batchID,vertexID,indexID);
      }
      
      public function copyFrom(token:BatchToken) : void
      {
         batchID = token.batchID;
         vertexID = token.vertexID;
         indexID = token.indexID;
      }
      
      public function setTo(batchID:int = 0, vertexID:int = 0, indexID:int = 0) : void
      {
         this.batchID = batchID;
         this.vertexID = vertexID;
         this.indexID = indexID;
      }
      
      public function reset() : void
      {
         batchID = vertexID = indexID = 0;
      }
      
      public function equals(other:BatchToken) : Boolean
      {
         return batchID == other.batchID && vertexID == other.vertexID && indexID == other.indexID;
      }
      
      public function toString() : String
      {
         return StringUtil.format("[BatchToken batchID={0} vertexID={1} indexID={2}]",batchID,vertexID,indexID);
      }
   }
}

