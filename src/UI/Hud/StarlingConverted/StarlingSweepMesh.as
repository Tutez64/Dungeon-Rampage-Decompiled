package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedCell;
   import starling.display.Mesh;
   import starling.rendering.IndexData;
   import starling.rendering.Painter;
   import starling.rendering.VertexData;
   
   internal class StarlingSweepMesh extends Mesh
   {
      
      private static const sDeg:Number = 0.017453292519943295;
      
      private var mCell:BakedCell;
      
      private var mArcs:Vector.<Number>;
      
      private var mCx:Number;
      
      private var mCy:Number;
      
      private var mDirty:Boolean = true;
      
      private var mTint:uint = 16777215;
      
      private var mCorners:Vector.<Number> = new Vector.<Number>(8,true);
      
      public function StarlingSweepMesh(cx:Number, cy:Number, capacity:int)
      {
         super(new VertexData(null,capacity),new IndexData(capacity * 3));
         indexData.addTriangle(0,2,1);
         indexData.numIndices = 0;
         touchable = false;
         mCx = cx;
         mCy = cy;
      }
      
      private static function sortFour(v:Vector.<Number>) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Number = NaN;
         var _loc4_:int = 0;
         _loc3_ = 1;
         while(_loc3_ < 4)
         {
            _loc2_ = v[_loc3_];
            _loc4_ = _loc3_ - 1;
            while(_loc4_ >= 0 && v[_loc4_] > _loc2_)
            {
               v[_loc4_ + 1] = v[_loc4_];
               _loc4_--;
            }
            v[_loc4_ + 1] = _loc2_;
            _loc3_++;
         }
      }
      
      public function get cell() : BakedCell
      {
         return mCell;
      }
      
      public function set cell(value:BakedCell) : void
      {
         mCell = value;
         if(value != null && value.alive)
         {
            texture = value.texture;
         }
         mDirty = true;
         setRequiresRedraw();
      }
      
      override public function get color() : uint
      {
         return mTint;
      }
      
      override public function set color(value:uint) : void
      {
         if(value == mTint)
         {
            return;
         }
         mTint = value;
         mDirty = true;
         setRequiresRedraw();
      }
      
      public function setArcs(arcs:Vector.<Number>) : void
      {
         if(arcs == mArcs)
         {
            return;
         }
         mArcs = arcs;
         mDirty = true;
         setRequiresRedraw();
      }
      
      override public function render(painter:Painter) : void
      {
         if(mCell == null || !mCell.alive)
         {
            return;
         }
         if(mDirty)
         {
            rebuild();
         }
         if(numIndices == 0)
         {
            return;
         }
         super.render(painter);
      }
      
      private function rebuild() : void
      {
         var _loc4_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc2_:int = 0;
         var _loc11_:int = 0;
         var _loc1_:int = 0;
         var _loc16_:Number = NaN;
         var _loc7_:int = 0;
         var _loc19_:* = 0;
         var _loc13_:Number = NaN;
         var _loc8_:* = 0;
         mDirty = false;
         var _loc10_:VertexData = vertexData;
         var _loc17_:IndexData = indexData;
         _loc10_.numVertices = 0;
         _loc17_.numIndices = 0;
         if(mArcs != null && mArcs.length > 0 && texture != null)
         {
            _loc4_ = mCell.pivotX;
            var _loc6_:Number = mCell.pivotY;
            _loc15_ = texture.width;
            var _loc5_:Number = texture.height;
            _loc14_ = -_loc4_;
            var _loc12_:Number = -_loc6_;
            var _loc9_:Number = _loc15_ - _loc4_;
            var _loc3_:Number = _loc5_ - _loc6_;
            mCorners[0] = angleTo(_loc14_,_loc12_);
            mCorners[1] = angleTo(_loc9_,_loc12_);
            mCorners[2] = angleTo(_loc9_,_loc3_);
            mCorners[3] = angleTo(_loc14_,_loc3_);
            sortFour(mCorners);
            _loc2_ = 0;
            while(_loc2_ < 4)
            {
               mCorners[_loc2_ + 4] = mCorners[_loc2_] + 360;
               _loc2_++;
            }
            _loc11_ = 0;
            _loc1_ = 0;
            while(_loc1_ + 1 < mArcs.length)
            {
               _loc16_ = mArcs[_loc1_];
               var _loc18_:Number = mArcs[_loc1_ + 1];
               _loc7_ = _loc11_;
               addVertex(_loc11_++,mCx,mCy,_loc4_,_loc6_,_loc15_,_loc5_);
               _loc19_ = _loc11_;
               _loc11_ = addEdge(_loc11_,_loc16_,_loc14_,_loc12_,_loc9_,_loc3_,_loc4_,_loc6_,_loc15_,_loc5_);
               _loc2_ = 0;
               while(_loc2_ < 8)
               {
                  _loc13_ = mCorners[_loc2_];
                  if(_loc13_ > _loc16_ && _loc13_ < _loc18_)
                  {
                     _loc11_ = addEdge(_loc11_,_loc13_,_loc14_,_loc12_,_loc9_,_loc3_,_loc4_,_loc6_,_loc15_,_loc5_);
                  }
                  _loc2_++;
               }
               _loc11_ = addEdge(_loc11_,_loc18_,_loc14_,_loc12_,_loc9_,_loc3_,_loc4_,_loc6_,_loc15_,_loc5_);
               _loc8_ = _loc19_;
               while(_loc8_ < _loc11_ - 1)
               {
                  _loc17_.addTriangle(_loc7_,_loc8_,_loc8_ + 1);
                  _loc8_++;
               }
               _loc1_ += 2;
            }
            _loc10_.colorize("color",mTint,1,0,_loc11_);
         }
         setVertexDataChanged();
         setIndexDataChanged();
      }
      
      private function angleTo(x:Number, y:Number) : Number
      {
         var _loc3_:Number = Math.atan2(x - mCx,mCy - y) / 0.017453292519943295;
         return _loc3_ < 0 ? _loc3_ + 360 : _loc3_;
      }
      
      private function addEdge(n:int, deg:Number, left:Number, top:Number, right:Number, bottom:Number, px:Number, py:Number, w:Number, h:Number) : int
      {
         var _loc11_:Number = Math.sin(deg * 0.017453292519943295);
         var _loc13_:Number = -Math.cos(deg * 0.017453292519943295);
         var _loc12_:Number = 1.7976931348623157e+308;
         if(_loc11_ > 1e-9)
         {
            _loc12_ = Math.min(_loc12_,(right - mCx) / _loc11_);
         }
         else if(_loc11_ < -1e-9)
         {
            _loc12_ = Math.min(_loc12_,(left - mCx) / _loc11_);
         }
         if(_loc13_ > 1e-9)
         {
            _loc12_ = Math.min(_loc12_,(bottom - mCy) / _loc13_);
         }
         else if(_loc13_ < -1e-9)
         {
            _loc12_ = Math.min(_loc12_,(top - mCy) / _loc13_);
         }
         if(_loc12_ < 0 || _loc12_ == 1.7976931348623157e+308)
         {
            _loc12_ = 0;
         }
         addVertex(n,mCx + _loc11_ * _loc12_,mCy + _loc13_ * _loc12_,px,py,w,h);
         return n + 1;
      }
      
      private function addVertex(n:int, x:Number, y:Number, px:Number, py:Number, w:Number, h:Number) : void
      {
         var _loc8_:VertexData = vertexData;
         _loc8_.setPoint(n,"position",x,y);
         texture.setTexCoords(_loc8_,n,"texCoords",(x + px) / w,(y + py) / h);
      }
      
      override public function dispose() : void
      {
         mCell = null;
         super.dispose();
      }
   }
}

