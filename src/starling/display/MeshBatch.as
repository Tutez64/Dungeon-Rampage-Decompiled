package starling.display
{
   import flash.geom.Matrix;
   import starling.rendering.IndexData;
   import starling.rendering.MeshEffect;
   import starling.rendering.Painter;
   import starling.rendering.VertexData;
   import starling.styles.MeshStyle;
   import starling.utils.MatrixUtil;
   import starling.utils.MeshSubset;
   
   public class MeshBatch extends Mesh
   {
      
      public static const MAX_NUM_VERTICES:int = 65535;
      
      private static var sFullMeshSubset:MeshSubset = new MeshSubset();
      
      private var _effect:MeshEffect;
      
      private var _batchable:Boolean;
      
      private var _vertexSyncRequired:Boolean;
      
      private var _indexSyncRequired:Boolean;
      
      public function MeshBatch()
      {
         var _loc1_:VertexData = new VertexData();
         var _loc2_:IndexData = new IndexData();
         super(_loc1_,_loc2_);
      }
      
      override public function dispose() : void
      {
         if(_effect)
         {
            _effect.dispose();
         }
         super.dispose();
      }
      
      override public function setVertexDataChanged() : void
      {
         _vertexSyncRequired = true;
         super.setVertexDataChanged();
      }
      
      override public function setIndexDataChanged() : void
      {
         _indexSyncRequired = true;
         super.setIndexDataChanged();
      }
      
      private function setVertexAndIndexDataChanged() : void
      {
         _vertexSyncRequired = _indexSyncRequired = true;
      }
      
      private function syncVertexBuffer() : void
      {
         _effect.uploadVertexData(_vertexData);
         _vertexSyncRequired = false;
      }
      
      private function syncIndexBuffer() : void
      {
         _effect.uploadIndexData(_indexData);
         _indexSyncRequired = false;
      }
      
      public function clear() : void
      {
         if(_parent)
         {
            setRequiresRedraw();
         }
         _vertexData.numVertices = 0;
         _indexData.numIndices = 0;
         _vertexSyncRequired = true;
         _indexSyncRequired = true;
      }
      
      public function addMesh(mesh:Mesh, matrix:Matrix = null, alpha:Number = 1, subset:MeshSubset = null, ignoreTransformations:Boolean = false) : void
      {
         addMeshAt(mesh,-1,-1,matrix,alpha,subset,ignoreTransformations);
      }
      
      public function addMeshAt(mesh:Mesh, indexID:int = -1, vertexID:int = -1, matrix:Matrix = null, alpha:Number = 1, subset:MeshSubset = null, ignoreTransformations:Boolean = false) : void
      {
         if(ignoreTransformations)
         {
            matrix = null;
         }
         else if(matrix == null)
         {
            matrix = mesh.transformationMatrix;
         }
         if(subset == null)
         {
            subset = sFullMeshSubset;
         }
         var _loc10_:int = _vertexData.numVertices;
         var _loc9_:int = vertexID >= 0 ? vertexID : _loc10_;
         var _loc11_:int = indexID >= 0 ? indexID : _indexData.numIndices;
         var _loc8_:MeshStyle = mesh._style;
         if(_loc10_ == 0)
         {
            setupFor(mesh);
         }
         _loc8_.batchVertexData(_style,_loc9_,matrix,subset.vertexID,subset.numVertices);
         _loc8_.batchIndexData(_style,_loc11_,_loc9_ - subset.vertexID,subset.indexID,subset.numIndices);
         if(alpha != 1)
         {
            _vertexData.scaleAlphas("color",alpha,_loc9_,subset.numVertices);
         }
         if(_parent)
         {
            setRequiresRedraw();
         }
         _indexSyncRequired = _vertexSyncRequired = true;
      }
      
      private function setupFor(mesh:Mesh) : void
      {
         var _loc4_:MeshStyle = null;
         var _loc3_:MeshStyle = mesh._style;
         var _loc2_:Class = _loc3_.type;
         if(_style.type != _loc2_)
         {
            _loc4_ = new _loc2_() as MeshStyle;
            _loc4_.copyFrom(_loc3_);
            setStyle(_loc4_,false);
         }
         else
         {
            _style.copyFrom(_loc3_);
         }
      }
      
      public function canAddMesh(mesh:Mesh, numVertices:int = -1) : Boolean
      {
         var _loc3_:int = _vertexData.numVertices;
         if(_loc3_ == 0)
         {
            return true;
         }
         if(numVertices < 0)
         {
            numVertices = mesh.numVertices;
         }
         if(numVertices == 0)
         {
            return true;
         }
         if(numVertices + _loc3_ > 65535)
         {
            return false;
         }
         return _style.canBatchWith(mesh._style);
      }
      
      override public function render(painter:Painter) : void
      {
         if(_vertexData.numVertices == 0)
         {
            return;
         }
         if(_pixelSnapping)
         {
            MatrixUtil.snapToPixels(painter.state.modelviewMatrix,painter.pixelSize);
         }
         if(_batchable)
         {
            painter.batchMesh(this);
         }
         else
         {
            painter.finishMeshBatch();
            painter.drawCount += 1;
            painter.prepareToDraw();
            painter.excludeFromCache(this);
            if(_vertexSyncRequired)
            {
               syncVertexBuffer();
            }
            if(_indexSyncRequired)
            {
               syncIndexBuffer();
            }
            _style.updateEffect(_effect,painter.state);
            _effect.render(0,_indexData.numTriangles);
         }
      }
      
      override public function setStyle(meshStyle:MeshStyle = null, mergeWithPredecessor:Boolean = true) : void
      {
         super.setStyle(meshStyle,mergeWithPredecessor);
         if(_effect)
         {
            _effect.dispose();
         }
         _effect = style.createEffect();
         _effect.onRestore = setVertexAndIndexDataChanged;
         setVertexAndIndexDataChanged();
      }
      
      public function set numVertices(value:int) : void
      {
         if(_vertexData.numVertices != value)
         {
            _vertexData.numVertices = value;
            _vertexSyncRequired = true;
            setRequiresRedraw();
         }
      }
      
      public function set numIndices(value:int) : void
      {
         if(_indexData.numIndices != value)
         {
            _indexData.numIndices = value;
            _indexSyncRequired = true;
            setRequiresRedraw();
         }
      }
      
      public function get batchable() : Boolean
      {
         return _batchable;
      }
      
      public function set batchable(value:Boolean) : void
      {
         if(_batchable != value)
         {
            _batchable = value;
            setRequiresRedraw();
         }
      }
   }
}

