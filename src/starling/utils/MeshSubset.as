package starling.utils
{
   public class MeshSubset
   {
      
      public var vertexID:int;
      
      public var numVertices:int;
      
      public var indexID:int;
      
      public var numIndices:int;
      
      public function MeshSubset(vertexID:int = 0, numVertices:int = -1, indexID:int = 0, numIndices:int = -1)
      {
         super();
         setTo(vertexID,numVertices,indexID,numIndices);
      }
      
      public function setTo(vertexID:int = 0, numVertices:int = -1, indexID:int = 0, numIndices:int = -1) : void
      {
         this.vertexID = vertexID;
         this.numVertices = numVertices;
         this.indexID = indexID;
         this.numIndices = numIndices;
      }
   }
}

