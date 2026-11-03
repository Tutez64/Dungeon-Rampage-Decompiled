package starling.utils
{
   public final class Earcut
   {
      
      public function Earcut()
      {
         super();
      }
      
      public static function earcut(vertices:Vector.<Number>, holes:Vector.<uint> = null, dimensions:uint = 2) : Vector.<uint>
      {
         var _loc11_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc7_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc5_:Boolean = holes && holes.length;
         var _loc8_:Number = Number(_loc5_ ? holes[0] * dimensions : vertices.length);
         var _loc9_:Node = linkedList(vertices,0,_loc8_,dimensions,true);
         var _loc10_:Vector.<uint> = new Vector.<uint>(0);
         if(!_loc9_ || _loc9_.next === _loc9_.prev)
         {
            return _loc10_;
         }
         if(_loc5_)
         {
            _loc9_ = eliminateHoles(vertices,holes,_loc9_,dimensions);
         }
         if(vertices.length > 80 * dimensions)
         {
            _loc12_ = Infinity;
            _loc11_ = Infinity;
            _loc6_ = -Infinity;
            _loc4_ = -Infinity;
            _loc7_ = int(dimensions);
            while(_loc7_ < _loc8_)
            {
               _loc13_ = vertices[_loc7_];
               _loc14_ = vertices[_loc7_ + 1];
               if(_loc13_ < _loc12_)
               {
                  _loc12_ = _loc13_;
               }
               if(_loc14_ < _loc11_)
               {
                  _loc11_ = _loc14_;
               }
               if(_loc13_ > _loc6_)
               {
                  _loc6_ = _loc13_;
               }
               if(_loc14_ > _loc4_)
               {
                  _loc4_ = _loc14_;
               }
               _loc7_ += dimensions;
            }
            _loc15_ = Math.max(_loc6_ - _loc12_,_loc4_ - _loc11_);
            _loc15_ = _loc15_ !== 0 ? 32767 / _loc15_ : 0;
         }
         earcutLinked(_loc9_,_loc10_,dimensions,_loc12_,_loc11_,_loc15_,0);
         return _loc10_;
      }
      
      private static function linkedList(data:Vector.<Number>, start:Number, end:Number, dim:uint, clockwise:Boolean) : Node
      {
         var _loc6_:Node = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(clockwise === signedArea(data,start,end,dim) > 0)
         {
            _loc7_ = start;
            while(_loc7_ < end)
            {
               _loc6_ = insertNode(_loc7_ / dim | 0,data[_loc7_],data[_loc7_ + 1],_loc6_);
               _loc7_ += dim;
            }
         }
         else
         {
            _loc8_ = end - dim;
            while(_loc8_ >= start)
            {
               _loc6_ = insertNode(_loc8_ / dim | 0,data[_loc8_],data[_loc8_ + 1],_loc6_);
               _loc8_ -= dim;
            }
         }
         if(_loc6_ && equals(_loc6_,_loc6_.next))
         {
            removeNode(_loc6_);
            _loc6_ = _loc6_.next;
         }
         return _loc6_;
      }
      
      private static function filterPoints(start:Node = null, end:Node = null) : Node
      {
         var _loc4_:Boolean = false;
         if(!start)
         {
            return start;
         }
         if(!end)
         {
            end = start;
         }
         var _loc3_:Node = start;
         do
         {
            _loc4_ = false;
            if(!_loc3_.steiner && (equals(_loc3_,_loc3_.next) || area(_loc3_.prev,_loc3_,_loc3_.next) === 0))
            {
               removeNode(_loc3_);
               _loc3_ = end = _loc3_.prev;
               if(_loc3_ === _loc3_.next)
               {
                  break;
               }
               _loc4_ = true;
            }
            else
            {
               _loc3_ = _loc3_.next;
            }
         }
         while(_loc4_ || _loc3_ !== end);
         return end;
      }
      
      private static function earcutLinked(ear:Node, triangles:Vector.<uint>, dim:uint, minX:Number, minY:Number, invSize:Number, pass:Number) : void
      {
         var _loc10_:Node = null;
         var _loc8_:Node = null;
         if(!ear)
         {
            return;
         }
         if(!pass && invSize)
         {
            indexCurve(ear,minX,minY,invSize);
         }
         var _loc9_:Node = ear;
         while(ear.prev !== ear.next)
         {
            _loc10_ = ear.prev;
            _loc8_ = ear.next;
            if(invSize ? isEarHashed(ear,minX,minY,invSize) : isEar(ear))
            {
               triangles.push(_loc10_.i,ear.i,_loc8_.i);
               removeNode(ear);
               ear = _loc8_.next;
               _loc9_ = _loc8_.next;
            }
            else
            {
               ear = _loc8_;
               if(ear === _loc9_)
               {
                  if(!pass)
                  {
                     earcutLinked(filterPoints(ear),triangles,dim,minX,minY,invSize,1);
                  }
                  else
                  {
                     switch(pass)
                     {
                        case 1:
                           ear = cureLocalIntersections(filterPoints(ear),triangles);
                           earcutLinked(ear,triangles,dim,minX,minY,invSize,2);
                           break;
                        case 2:
                           splitEarcut(ear,triangles,dim,minX,minY,invSize);
                     }
                  }
                  break;
               }
            }
         }
      }
      
      private static function isEar(ear:Node) : Boolean
      {
         var _loc2_:Node = ear.prev;
         var _loc3_:Node = ear;
         var _loc4_:Node = ear.next;
         if(area(_loc2_,_loc3_,_loc4_) >= 0)
         {
            return false;
         }
         var _loc10_:Number = _loc2_.x;
         var _loc7_:Number = _loc3_.x;
         var _loc6_:Number = _loc4_.x;
         var _loc12_:Number = _loc2_.y;
         var _loc9_:Number = _loc3_.y;
         var _loc8_:Number = _loc4_.y;
         var _loc14_:Number = Math.min(_loc10_,_loc7_,_loc6_);
         var _loc11_:Number = Math.min(_loc12_,_loc9_,_loc8_);
         var _loc15_:Number = Math.max(_loc10_,_loc7_,_loc6_);
         var _loc13_:Number = Math.max(_loc12_,_loc9_,_loc8_);
         var _loc5_:Node = _loc4_.next;
         while(_loc5_ !== _loc2_)
         {
            if(_loc5_.x >= _loc14_ && _loc5_.x <= _loc15_ && _loc5_.y >= _loc11_ && _loc5_.y <= _loc13_ && pointInTriangleExceptFirst(_loc10_,_loc12_,_loc7_,_loc9_,_loc6_,_loc8_,_loc5_.x,_loc5_.y) && area(_loc5_.prev,_loc5_,_loc5_.next) >= 0)
            {
               return false;
            }
            _loc5_ = _loc5_.next;
         }
         return true;
      }
      
      private static function isEarHashed(ear:Node, minX:Number, minY:Number, invSize:Number) : Boolean
      {
         var _loc5_:Node = ear.prev;
         var _loc6_:Node = ear;
         var _loc7_:Node = ear.next;
         if(area(_loc5_,_loc6_,_loc7_) >= 0)
         {
            return false;
         }
         var _loc15_:Number = _loc5_.x;
         var _loc12_:Number = _loc6_.x;
         var _loc11_:Number = _loc7_.x;
         var _loc17_:Number = _loc5_.y;
         var _loc14_:Number = _loc6_.y;
         var _loc13_:Number = _loc7_.y;
         var _loc19_:Number = Math.min(_loc15_,_loc12_,_loc11_);
         var _loc16_:Number = Math.min(_loc17_,_loc14_,_loc13_);
         var _loc20_:Number = Math.max(_loc15_,_loc12_,_loc11_);
         var _loc18_:Number = Math.max(_loc17_,_loc14_,_loc13_);
         var _loc21_:Number = zOrder(_loc19_,_loc16_,minX,minY,invSize);
         var _loc8_:Number = zOrder(_loc20_,_loc18_,minX,minY,invSize);
         var _loc10_:Node = ear.prevZ;
         var _loc9_:Node = ear.nextZ;
         while(_loc10_ && _loc10_.z >= _loc21_ && _loc9_ && _loc9_.z <= _loc8_)
         {
            if(_loc10_.x >= _loc19_ && _loc10_.x <= _loc20_ && _loc10_.y >= _loc16_ && _loc10_.y <= _loc18_ && _loc10_ !== _loc5_ && _loc10_ !== _loc7_ && pointInTriangleExceptFirst(_loc15_,_loc17_,_loc12_,_loc14_,_loc11_,_loc13_,_loc10_.x,_loc10_.y) && area(_loc10_.prev,_loc10_,_loc10_.next) >= 0)
            {
               return false;
            }
            _loc10_ = _loc10_.prevZ;
            if(_loc9_.x >= _loc19_ && _loc9_.x <= _loc20_ && _loc9_.y >= _loc16_ && _loc9_.y <= _loc18_ && _loc9_ !== _loc5_ && _loc9_ !== _loc7_ && pointInTriangleExceptFirst(_loc15_,_loc17_,_loc12_,_loc14_,_loc11_,_loc13_,_loc9_.x,_loc9_.y) && area(_loc9_.prev,_loc9_,_loc9_.next) >= 0)
            {
               return false;
            }
            _loc9_ = _loc9_.nextZ;
         }
         while(_loc10_ && _loc10_.z >= _loc21_)
         {
            if(_loc10_.x >= _loc19_ && _loc10_.x <= _loc20_ && _loc10_.y >= _loc16_ && _loc10_.y <= _loc18_ && _loc10_ !== _loc5_ && _loc10_ !== _loc7_ && pointInTriangleExceptFirst(_loc15_,_loc17_,_loc12_,_loc14_,_loc11_,_loc13_,_loc10_.x,_loc10_.y) && area(_loc10_.prev,_loc10_,_loc10_.next) >= 0)
            {
               return false;
            }
            _loc10_ = _loc10_.prevZ;
         }
         while(_loc9_ && _loc9_.z <= _loc8_)
         {
            if(_loc9_.x >= _loc19_ && _loc9_.x <= _loc20_ && _loc9_.y >= _loc16_ && _loc9_.y <= _loc18_ && _loc9_ !== _loc5_ && _loc9_ !== _loc7_ && pointInTriangleExceptFirst(_loc15_,_loc17_,_loc12_,_loc14_,_loc11_,_loc13_,_loc9_.x,_loc9_.y) && area(_loc9_.prev,_loc9_,_loc9_.next) >= 0)
            {
               return false;
            }
            _loc9_ = _loc9_.nextZ;
         }
         return true;
      }
      
      private static function cureLocalIntersections(start:Node, triangles:Vector.<uint>) : Node
      {
         var _loc4_:Node = null;
         var _loc3_:Node = start;
         do
         {
            _loc4_ = _loc3_.prev;
            var _loc5_:Node = _loc3_.next.next;
            if(!equals(_loc4_,_loc5_) && intersects(_loc4_,_loc3_,_loc3_.next,_loc5_) && locallyInside(_loc4_,_loc5_) && locallyInside(_loc5_,_loc4_))
            {
               triangles.push(_loc4_.i,_loc3_.i,_loc5_.i);
               removeNode(_loc3_);
               removeNode(_loc3_.next);
               _loc3_ = start = _loc5_;
            }
            _loc3_ = _loc3_.next;
         }
         while(_loc3_ !== start);
         return filterPoints(_loc3_);
      }
      
      private static function splitEarcut(start:Node, triangles:Vector.<uint>, dim:uint, minX:Number, minY:Number, invSize:Number) : void
      {
         var _loc8_:Node = null;
         var _loc9_:Node = null;
         var _loc7_:Node = start;
         do
         {
            _loc8_ = _loc7_.next.next;
            while(_loc8_ !== _loc7_.prev)
            {
               if(_loc7_.i !== _loc8_.i && isValidDiagonal(_loc7_,_loc8_))
               {
                  _loc9_ = splitPolygon(_loc7_,_loc8_);
                  _loc7_ = filterPoints(_loc7_,_loc7_.next);
                  _loc9_ = filterPoints(_loc9_,_loc9_.next);
                  earcutLinked(_loc7_,triangles,dim,minX,minY,invSize,0);
                  earcutLinked(_loc9_,triangles,dim,minX,minY,invSize,0);
                  return;
               }
               _loc8_ = _loc8_.next;
            }
         }
         while(_loc7_ = _loc7_.next, _loc7_ !== start);
      }
      
      private static function eliminateHoles(data:Vector.<Number>, holeIndices:Vector.<uint>, outerNode:Node, dim:uint) : Node
      {
         var _loc7_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:Node = null;
         var _loc10_:uint = 0;
         var _loc11_:Vector.<Node> = new Vector.<Node>(0);
         _loc7_ = 0;
         _loc5_ = holeIndices.length;
         while(_loc7_ < _loc5_)
         {
            _loc6_ = holeIndices[_loc7_] * dim;
            _loc8_ = uint(_loc7_ < _loc5_ - 1 ? holeIndices[_loc7_ + 1] * dim : data.length);
            _loc9_ = linkedList(data,_loc6_,_loc8_,dim,false);
            if(_loc9_ === _loc9_.next)
            {
               _loc9_.steiner = true;
            }
            _loc11_.push(getLeftmost(_loc9_));
            _loc7_++;
         }
         _loc11_.sort(compareXYSlope);
         _loc10_ = 0;
         while(_loc10_ < _loc11_.length)
         {
            outerNode = eliminateHole(_loc11_[_loc10_],outerNode);
            _loc10_++;
         }
         return outerNode;
      }
      
      private static function compareXYSlope(a:Node, b:Node) : Number
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:Number = a.x - b.x;
         if(_loc3_ === 0)
         {
            _loc3_ = a.y - b.y;
            if(_loc3_ === 0)
            {
               _loc4_ = (a.next.y - a.y) / (a.next.x - a.x);
               _loc5_ = (b.next.y - b.y) / (b.next.x - b.x);
               _loc3_ = _loc4_ - _loc5_;
            }
         }
         return _loc3_;
      }
      
      private static function eliminateHole(hole:Node, outerNode:Node) : Node
      {
         var _loc3_:Node = findHoleBridge(hole,outerNode);
         if(!_loc3_)
         {
            return outerNode;
         }
         var _loc4_:Node = splitPolygon(_loc3_,hole);
         filterPoints(_loc4_,_loc4_.next);
         return filterPoints(_loc3_,_loc3_.next);
      }
      
      private static function findHoleBridge(hole:Node, outerNode:Node) : Node
      {
         var _loc7_:Node = null;
         var _loc13_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc9_:Node = outerNode;
         var _loc10_:Number = hole.x;
         var _loc11_:Number = hole.y;
         var _loc4_:Number = -Infinity;
         if(equals(hole,_loc9_))
         {
            return _loc9_;
         }
         while(!equals(hole,_loc9_.next))
         {
            if(_loc11_ <= _loc9_.y && _loc11_ >= _loc9_.next.y && _loc9_.next.y !== _loc9_.y)
            {
               _loc13_ = _loc9_.x + (_loc11_ - _loc9_.y) * (_loc9_.next.x - _loc9_.x) / (_loc9_.next.y - _loc9_.y);
               if(_loc13_ <= _loc10_ && _loc13_ > _loc4_)
               {
                  _loc4_ = _loc13_;
                  _loc7_ = _loc9_.x < _loc9_.next.x ? _loc9_ : _loc9_.next;
                  if(_loc13_ === _loc10_)
                  {
                     return _loc7_;
                  }
               }
            }
            _loc9_ = _loc9_.next;
            if(_loc9_ === outerNode)
            {
               if(!_loc7_)
               {
                  return null;
               }
               var _loc12_:Node = _loc7_;
               var _loc5_:Number = _loc7_.x;
               var _loc6_:Number = _loc7_.y;
               var _loc8_:Number = Infinity;
               _loc9_ = _loc7_;
               do
               {
                  if(_loc10_ >= _loc9_.x && _loc9_.x >= _loc5_ && _loc10_ !== _loc9_.x && pointInTriangle(_loc11_ < _loc6_ ? _loc10_ : _loc4_,_loc11_,_loc5_,_loc6_,_loc11_ < _loc6_ ? _loc4_ : _loc10_,_loc11_,_loc9_.x,_loc9_.y))
                  {
                     _loc3_ = Math.abs(_loc11_ - _loc9_.y) / (_loc10_ - _loc9_.x);
                     if(locallyInside(_loc9_,hole) && (_loc3_ < _loc8_ || _loc3_ === _loc8_ && (_loc9_.x > _loc7_.x || _loc9_.x === _loc7_.x && sectorContainsSector(_loc7_,_loc9_))))
                     {
                        _loc7_ = _loc9_;
                        _loc8_ = _loc3_;
                     }
                  }
               }
               while(_loc9_ = _loc9_.next, _loc9_ !== _loc12_);
               return _loc7_;
            }
         }
         return _loc9_.next;
      }
      
      private static function sectorContainsSector(m:Node, p:Node) : Boolean
      {
         return area(m.prev,m,p.prev) < 0 && area(p.next,m,m.next) < 0;
      }
      
      private static function indexCurve(start:Node, minX:Number, minY:Number, invSize:Number) : void
      {
         var _loc5_:Node = start;
         do
         {
            if(_loc5_.z === 0)
            {
               _loc5_.z = zOrder(_loc5_.x,_loc5_.y,minX,minY,invSize);
            }
            _loc5_.prevZ = _loc5_.prev;
            _loc5_.nextZ = _loc5_.next;
         }
         while(_loc5_ = _loc5_.next, _loc5_ !== start);
         _loc5_.prevZ.nextZ = null;
         _loc5_.prevZ = null;
         sortLinked(_loc5_);
      }
      
      private static function sortLinked(list:Node) : Node
      {
         var _loc5_:uint = 0;
         var _loc2_:Node = null;
         var _loc7_:Node = null;
         var _loc8_:Node = null;
         var _loc4_:Node = null;
         var _loc3_:int = 0;
         var _loc9_:uint = 0;
         var _loc10_:* = 0;
         var _loc6_:uint = 1;
         do
         {
            _loc2_ = list;
            list = null;
            _loc8_ = null;
            _loc5_ = 0;
            while(_loc2_)
            {
               _loc5_++;
               _loc4_ = _loc2_;
               _loc3_ = 0;
               _loc9_ = 0;
               while(_loc9_ < _loc6_)
               {
                  _loc3_++;
                  _loc4_ = _loc4_.nextZ;
                  if(!_loc4_)
                  {
                     break;
                  }
                  _loc9_++;
               }
               _loc10_ = _loc6_;
               while(_loc3_ > 0 || _loc10_ > 0 && _loc4_)
               {
                  if(_loc3_ !== 0 && (_loc10_ === 0 || !_loc4_ || _loc2_.z <= _loc4_.z))
                  {
                     _loc7_ = _loc2_;
                     _loc2_ = _loc2_.nextZ;
                     _loc3_--;
                  }
                  else
                  {
                     _loc7_ = _loc4_;
                     _loc4_ = _loc4_.nextZ;
                     _loc10_--;
                  }
                  if(_loc8_)
                  {
                     _loc8_.nextZ = _loc7_;
                  }
                  else
                  {
                     list = _loc7_;
                  }
                  _loc7_.prevZ = _loc8_;
                  _loc8_ = _loc7_;
               }
               _loc2_ = _loc4_;
            }
            _loc8_.nextZ = null;
            _loc6_ *= 2;
         }
         while(_loc5_ > 1);
         return list;
      }
      
      private static function zOrder(x:Number, y:Number, minX:Number, minY:Number, invSize:Number) : Number
      {
         x = (x - minX) * invSize | 0;
         y = (y - minY) * invSize | 0;
         x = (x | x << 8) & 0xFF00FF;
         x = (x | x << 4) & 0x0F0F0F0F;
         x = (x | x << 2) & 0x33333333;
         x = (x | x << 1) & 0x55555555;
         y = (y | y << 8) & 0xFF00FF;
         y = (y | y << 4) & 0x0F0F0F0F;
         y = (y | y << 2) & 0x33333333;
         y = (y | y << 1) & 0x55555555;
         return x | y << 1;
      }
      
      private static function getLeftmost(start:Node) : Node
      {
         var _loc2_:Node = start;
         var _loc3_:Node = start;
         do
         {
            if(_loc2_.x < _loc3_.x || _loc2_.x === _loc3_.x && _loc2_.y < _loc3_.y)
            {
               _loc3_ = _loc2_;
            }
            _loc2_ = _loc2_.next;
         }
         while(_loc2_ !== start);
         return _loc3_;
      }
      
      private static function pointInTriangle(ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number, px:Number, py:Number) : Boolean
      {
         return (cx - px) * (ay - py) >= (ax - px) * (cy - py) && (ax - px) * (by - py) >= (bx - px) * (ay - py) && (bx - px) * (cy - py) >= (cx - px) * (by - py);
      }
      
      private static function pointInTriangleExceptFirst(ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number, px:Number, py:Number) : Boolean
      {
         return !(ax === px && ay === py) && pointInTriangle(ax,ay,bx,by,cx,cy,px,py);
      }
      
      private static function isValidDiagonal(a:Node, b:Node) : Boolean
      {
         return a.next.i !== b.i && a.prev.i !== b.i && !intersectsPolygon(a,b) && (locallyInside(a,b) && locallyInside(b,a) && middleInside(a,b) && (area(a.prev,a,b.prev) || area(a,b.prev,b)) || equals(a,b) && area(a.prev,a,a.next) > 0 && area(b.prev,b,b.next) > 0);
      }
      
      private static function area(p:Node, q:Node, r:Node) : Number
      {
         return (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
      }
      
      private static function equals(p1:Node, p2:Node) : Boolean
      {
         return p1.x === p2.x && p1.y === p2.y;
      }
      
      private static function intersects(p1:Node, q1:Node, p2:Node, q2:Node) : Boolean
      {
         var _loc5_:Number = sign(area(p1,q1,p2));
         var _loc6_:Number = sign(area(p1,q1,q2));
         var _loc7_:Number = sign(area(p2,q2,p1));
         var _loc8_:Number = sign(area(p2,q2,q1));
         if(_loc5_ !== _loc6_ && _loc7_ !== _loc8_)
         {
            return true;
         }
         if(_loc5_ === 0 && onSegment(p1,p2,q1))
         {
            return true;
         }
         if(_loc6_ === 0 && onSegment(p1,q2,q1))
         {
            return true;
         }
         if(_loc7_ === 0 && onSegment(p2,p1,q2))
         {
            return true;
         }
         if(_loc8_ === 0 && onSegment(p2,q1,q2))
         {
            return true;
         }
         return false;
      }
      
      private static function onSegment(p:Node, q:Node, r:Node) : Boolean
      {
         return q.x <= Math.max(p.x,r.x) && q.x >= Math.min(p.x,r.x) && q.y <= Math.max(p.y,r.y) && q.y >= Math.min(p.y,r.y);
      }
      
      private static function sign(num:Number) : int
      {
         return num > 0 ? 1 : (num < 0 ? -1 : 0);
      }
      
      private static function intersectsPolygon(a:Node, b:Node) : Boolean
      {
         var _loc3_:Node = a;
         while(!(_loc3_.i !== a.i && _loc3_.next.i !== a.i && _loc3_.i !== b.i && _loc3_.next.i !== b.i && intersects(_loc3_,_loc3_.next,a,b)))
         {
            _loc3_ = _loc3_.next;
            if(_loc3_ === a)
            {
               return false;
            }
         }
         return true;
      }
      
      private static function locallyInside(a:Node, b:Node) : Boolean
      {
         return area(a.prev,a,a.next) < 0 ? area(a,b,a.next) >= 0 && area(a,a.prev,b) >= 0 : area(a,b,a.prev) < 0 || area(a,a.next,b) < 0;
      }
      
      private static function middleInside(a:Node, b:Node) : Boolean
      {
         var _loc3_:Node = a;
         var _loc6_:Boolean = false;
         var _loc4_:Number = (a.x + b.x) / 2;
         var _loc5_:Number = (a.y + b.y) / 2;
         do
         {
            if(_loc3_.y > _loc5_ !== _loc3_.next.y > _loc5_ && _loc3_.next.y !== _loc3_.y && _loc4_ < (_loc3_.next.x - _loc3_.x) * (_loc5_ - _loc3_.y) / (_loc3_.next.y - _loc3_.y) + _loc3_.x)
            {
               _loc6_ = !_loc6_;
            }
            _loc3_ = _loc3_.next;
         }
         while(_loc3_ !== a);
         return _loc6_;
      }
      
      private static function splitPolygon(a:Node, b:Node) : Node
      {
         var _loc4_:Node = createNode(a.i,a.x,a.y);
         var _loc3_:Node = createNode(b.i,b.x,b.y);
         var _loc5_:Node = a.next;
         var _loc6_:Node = b.prev;
         a.next = b;
         b.prev = a;
         _loc4_.next = _loc5_;
         _loc5_.prev = _loc4_;
         _loc3_.next = _loc4_;
         _loc4_.prev = _loc3_;
         _loc6_.next = _loc3_;
         _loc3_.prev = _loc6_;
         return _loc3_;
      }
      
      private static function insertNode(i:Number, x:Number, y:Number, last:Node) : Node
      {
         var _loc5_:Node = createNode(i,x,y);
         if(!last)
         {
            _loc5_.prev = _loc5_;
            _loc5_.next = _loc5_;
         }
         else
         {
            _loc5_.next = last.next;
            _loc5_.prev = last;
            last.next.prev = _loc5_;
            last.next = _loc5_;
         }
         return _loc5_;
      }
      
      private static function removeNode(p:Node) : void
      {
         p.next.prev = p.prev;
         p.prev.next = p.next;
         if(p.prevZ)
         {
            p.prevZ.nextZ = p.nextZ;
         }
         if(p.nextZ)
         {
            p.nextZ.prevZ = p.prevZ;
         }
      }
      
      private static function createNode(i:Number, x:Number, y:Number) : Node
      {
         return new Node(i,x,y);
      }
      
      public static function deviation(vertices:Vector.<Number>, holes:Vector.<Number>, dimensions:uint, triangles:Vector.<Number>) : Number
      {
         var _loc10_:uint = 0;
         var _loc15_:uint = 0;
         var _loc9_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc13_:uint = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Boolean = holes && holes.length;
         var _loc11_:Number = Number(_loc8_ ? holes[0] * dimensions : vertices.length);
         var _loc12_:Number = Math.abs(signedArea(vertices,0,_loc11_,dimensions));
         if(_loc8_)
         {
            _loc10_ = 0;
            _loc15_ = holes.length;
            while(_loc10_ < _loc15_)
            {
               _loc9_ = holes[_loc10_] * dimensions;
               _loc16_ = Number(_loc10_ < _loc15_ - 1 ? holes[_loc10_ + 1] * dimensions : vertices.length);
               _loc12_ -= Math.abs(signedArea(vertices,_loc9_,_loc16_,dimensions));
               _loc10_++;
            }
         }
         var _loc14_:Number = 0;
         _loc13_ = 0;
         while(_loc13_ < triangles.length)
         {
            _loc5_ = triangles[_loc13_] * dimensions;
            _loc6_ = triangles[_loc13_ + 1] * dimensions;
            _loc7_ = triangles[_loc13_ + 2] * dimensions;
            _loc14_ += Math.abs((triangles[_loc5_] - triangles[_loc7_]) * (triangles[_loc6_ + 1] - triangles[_loc5_ + 1]) - (triangles[_loc5_] - triangles[_loc6_]) * (triangles[_loc7_ + 1] - triangles[_loc5_ + 1]));
            _loc13_ += 3;
         }
         return _loc12_ === 0 && _loc14_ === 0 ? 0 : Math.abs((_loc14_ - _loc12_) / _loc12_);
      }
      
      private static function signedArea(data:Vector.<Number>, start:Number, end:Number, dim:uint) : Number
      {
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc6_:Number = 0;
         _loc5_ = start;
         _loc7_ = end - dim;
         while(_loc5_ < end)
         {
            _loc6_ += (data[_loc7_] - data[_loc5_]) * (data[_loc5_ + 1] + data[_loc7_ + 1]);
            _loc7_ = _loc5_;
            _loc5_ += dim;
         }
         return _loc6_;
      }
      
      public static function flatten(data:Vector.<Vector.<Vector.<Number>>>) : Object
      {
         var _loc4_:int = 0;
         var _loc5_:Vector.<Number> = new Vector.<Number>(0);
         var _loc8_:Vector.<Number> = new Vector.<Number>(0);
         var _loc9_:uint = data[0][0].length;
         var _loc2_:uint = 0;
         var _loc7_:uint = 0;
         for each(var _loc6_:Vector.<Vector.<Number>> in data)
         {
            for each(var _loc3_:Vector.<Number> in _loc6_)
            {
               _loc4_ = 0;
               while(_loc4_ < _loc9_)
               {
                  _loc5_.push(_loc3_[_loc4_]);
                  _loc4_++;
               }
            }
            if(_loc7_)
            {
               _loc2_ += _loc7_;
               _loc8_.push(_loc2_);
            }
            _loc7_ = _loc6_.length;
         }
         return {
            "vertices":_loc5_,
            "holes":_loc8_,
            "dimensions":_loc9_
         };
      }
   }
}

class Node
{
   
   public var i:Number;
   
   public var x:Number;
   
   public var y:Number;
   
   public var prev:Node;
   
   public var next:Node;
   
   public var z:Number;
   
   public var prevZ:Node;
   
   public var nextZ:Node;
   
   public var steiner:Boolean;
   
   public function Node(i:Number, x:Number, y:Number)
   {
      super();
      this.i = i;
      this.x = x;
      this.y = y;
      this.prev = null;
      this.next = null;
      this.z = 0;
      this.prevZ = null;
      this.nextZ = null;
      this.steiner = false;
   }
}
