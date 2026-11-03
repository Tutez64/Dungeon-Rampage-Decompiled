package starling.rendering
{
   import flash.geom.Matrix;
   import starling.display.Mesh;
   import starling.display.MeshBatch;
   import starling.utils.MeshSubset;
   
   internal class BatchProcessor
   {
      
      private static var sMeshSubset:MeshSubset = new MeshSubset();
      
      private var _batches:Vector.<MeshBatch>;
      
      private var _batchPool:BatchPool;
      
      private var _currentBatch:MeshBatch;
      
      private var _currentStyleType:Class;
      
      private var _onBatchComplete:Function;
      
      private var _cacheToken:BatchToken;
      
      private var _frameFinished:Boolean;
      
      public function BatchProcessor(onBatchComplete:Function)
      {
         super();
         _onBatchComplete = onBatchComplete;
         _batches = new Vector.<MeshBatch>(0);
         _batchPool = new BatchPool();
         _cacheToken = new BatchToken();
      }
      
      public function dispose() : void
      {
         for each(var _loc1_:MeshBatch in _batches)
         {
            _loc1_.dispose();
         }
         _batches.length = 0;
         _batchPool.purge();
         _currentBatch = null;
         _onBatchComplete = null;
      }
      
      public function addMesh(mesh:Mesh, state:RenderState, subset:MeshSubset = null, ignoreTransformations:Boolean = false) : void
      {
         var _loc6_:Matrix = null;
         var _loc5_:Number = NaN;
         if(subset == null)
         {
            subset = sMeshSubset;
            subset.vertexID = subset.indexID = 0;
            subset.numVertices = mesh.numVertices;
            subset.numIndices = mesh.numIndices;
         }
         else
         {
            if(subset.numVertices < 0)
            {
               subset.numVertices = mesh.numVertices - subset.vertexID;
            }
            if(subset.numIndices < 0)
            {
               subset.numIndices = mesh.numIndices - subset.indexID;
            }
         }
         if(subset.numVertices > 0)
         {
            if(_currentBatch == null || !_currentBatch.canAddMesh(mesh,subset.numVertices))
            {
               finishBatch();
               _currentStyleType = mesh.style.type;
               _currentBatch = _batchPool.get(_currentStyleType);
               _currentBatch.blendMode = state ? state.blendMode : mesh.blendMode;
               _cacheToken.setTo(_batches.length);
               _batches[_batches.length] = _currentBatch;
            }
            _loc6_ = state ? state._modelviewMatrix : null;
            _loc5_ = state ? state._alpha : 1;
            _currentBatch.addMeshAt(mesh,-1,-1,_loc6_,_loc5_,subset,ignoreTransformations);
            _cacheToken.vertexID += subset.numVertices;
            _cacheToken.indexID += subset.numIndices;
         }
      }
      
      public function finishBatch() : void
      {
         var _loc1_:MeshBatch = _currentBatch;
         if(_loc1_)
         {
            _currentBatch = null;
            _currentStyleType = null;
            if(_onBatchComplete != null)
            {
               _onBatchComplete(_loc1_);
            }
         }
      }
      
      public function finishFrame() : void
      {
         finishBatch();
         _frameFinished = true;
      }
      
      public function clear() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = int(_batches.length);
         _loc1_ = 0;
         while(_loc1_ < _loc2_)
         {
            _batchPool.put(_batches[_loc1_]);
            _loc1_++;
         }
         _batches.length = 0;
         _currentBatch = null;
         _currentStyleType = null;
         _cacheToken.reset();
         _frameFinished = false;
      }
      
      public function getBatchAt(batchID:int) : MeshBatch
      {
         return _batches[batchID];
      }
      
      public function trim() : void
      {
         _batchPool.purge();
      }
      
      public function fillToken(token:BatchToken) : BatchToken
      {
         token.batchID = _cacheToken.batchID;
         token.vertexID = _cacheToken.vertexID;
         token.indexID = _cacheToken.indexID;
         return token;
      }
      
      public function get numBatches() : int
      {
         return _batches.length;
      }
      
      public function get frameFinished() : Boolean
      {
         return _frameFinished;
      }
      
      public function get onBatchComplete() : Function
      {
         return _onBatchComplete;
      }
      
      public function set onBatchComplete(value:Function) : void
      {
         _onBatchComplete = value;
      }
   }
}

import flash.utils.Dictionary;
import starling.display.MeshBatch;

class BatchPool
{
   
   private var _batchLists:Dictionary;
   
   public function BatchPool()
   {
      super();
      _batchLists = new Dictionary();
   }
   
   public function purge() : void
   {
      var _loc1_:int = 0;
      for each(var _loc2_:Array in _batchLists)
      {
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            _loc2_[_loc1_].dispose();
            _loc1_++;
         }
         _loc2_.length = 0;
      }
   }
   
   public function get(styleType:Class) : MeshBatch
   {
      var _loc2_:Array = _batchLists[styleType];
      if(_loc2_ == null)
      {
         _loc2_ = [];
         _batchLists[styleType] = _loc2_;
      }
      if(_loc2_.length > 0)
      {
         return _loc2_.pop();
      }
      return new MeshBatch();
   }
   
   public function put(meshBatch:MeshBatch) : void
   {
      var _loc2_:Class = meshBatch.style.type;
      var _loc3_:Array = _batchLists[_loc2_];
      if(_loc3_ == null)
      {
         _loc3_ = [];
         _batchLists[_loc2_] = _loc3_;
      }
      meshBatch.clear();
      _loc3_[_loc3_.length] = meshBatch;
   }
}
