package starling.geom
{
   import flash.geom.Point;
   import flash.utils.getQualifiedClassName;
   import starling.rendering.IndexData;
   import starling.rendering.VertexData;
   import starling.utils.Earcut;
   import starling.utils.MathUtil;
   import starling.utils.Pool;
   
   public class Polygon
   {
      
      public static var useEarcut:Boolean = true;
      
      private static var sRestIndices:Vector.<uint> = new Vector.<uint>(0);
      
      private var _coords:Vector.<Number>;
      
      public function Polygon(vertices:Array = null)
      {
         super();
         _coords = new Vector.<Number>(0);
         addVertices.apply(this,vertices);
      }
      
      public static function fromVector(vector:Vector.<Number>) : Polygon
      {
         var _loc2_:Polygon = new Polygon();
         _loc2_._coords = vector;
         return _loc2_;
      }
      
      public static function createEllipse(x:Number, y:Number, radiusX:Number, radiusY:Number, numSides:int = -1) : Polygon
      {
         return new Ellipse(x,y,radiusX,radiusY,numSides);
      }
      
      public static function createCircle(x:Number, y:Number, radius:Number, numSides:int = -1) : Polygon
      {
         return new Ellipse(x,y,radius,radius,numSides);
      }
      
      public static function createRectangle(x:Number, y:Number, width:Number, height:Number) : Polygon
      {
         return new Rectangle(x,y,width,height);
      }
      
      public static function createRoundRectangle(x:Number, y:Number, width:Number, height:Number, ellipseWidth:Number, ellipseHeight:Number = NaN) : Polygon
      {
         return new RoundRectangle(x,y,width,height,ellipseWidth,ellipseHeight);
      }
      
      private static function isConvexTriangle(ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number) : Boolean
      {
         return (ay - by) * (cx - bx) + (bx - ax) * (cy - by) >= 0;
      }
      
      private static function areVectorsIntersecting(ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number, dx:Number, dy:Number) : Boolean
      {
         if(ax == bx && ay == by || cx == dx && cy == dy)
         {
            return false;
         }
         var _loc12_:Number = bx - ax;
         var _loc14_:Number = by - ay;
         var _loc13_:Number = dx - cx;
         var _loc15_:Number = dy - cy;
         var _loc9_:Number = _loc15_ * _loc12_ - _loc13_ * _loc14_;
         if(_loc9_ == 0)
         {
            return false;
         }
         var _loc11_:Number = (_loc14_ * (cx - ax) - _loc12_ * (cy - ay)) / _loc9_;
         if(_loc11_ < 0 || _loc11_ > 1)
         {
            return false;
         }
         var _loc10_:Number = _loc14_ ? (cy - ay + _loc11_ * _loc15_) / _loc14_ : (cx - ax + _loc11_ * _loc13_) / _loc12_;
         return _loc10_ >= 0 && _loc10_ <= 1;
      }
      
      public function clone() : Polygon
      {
         var _loc3_:int = 0;
         var _loc1_:Polygon = new Polygon();
         var _loc2_:int = int(_coords.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_._coords[_loc3_] = _coords[_loc3_];
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function reverse() : void
      {
         var _loc2_:Number = NaN;
         var _loc4_:int = 0;
         var _loc3_:int = int(_coords.length);
         var _loc1_:int = _loc3_ / 2;
         _loc4_ = 0;
         while(_loc4_ < _loc1_)
         {
            _loc2_ = _coords[_loc4_];
            _coords[_loc4_] = _coords[_loc3_ - _loc4_ - 2];
            _coords[_loc3_ - _loc4_ - 2] = _loc2_;
            _loc2_ = _coords[_loc4_ + 1];
            _coords[_loc4_ + 1] = _coords[_loc3_ - _loc4_ - 1];
            _coords[_loc3_ - _loc4_ - 1] = _loc2_;
            _loc4_ += 2;
         }
      }
      
      public function addVertices(... rest) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(rest.length);
         var _loc4_:int = int(_coords.length);
         if(_loc2_ > 0)
         {
            if(rest[0] is Point)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  _coords[_loc4_ + _loc3_ * 2] = (rest[_loc3_] as Point).x;
                  _coords[_loc4_ + _loc3_ * 2 + 1] = (rest[_loc3_] as Point).y;
                  _loc3_++;
               }
            }
            else
            {
               if(!(rest[0] is Number))
               {
                  throw new ArgumentError("Invalid type: " + getQualifiedClassName(rest[0]));
               }
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  _coords[_loc4_ + _loc3_] = rest[_loc3_];
                  _loc3_++;
               }
            }
         }
      }
      
      public function setVertex(index:int, x:Number, y:Number) : void
      {
         if(index >= 0 && index <= numVertices)
         {
            _coords[index * 2] = x;
            _coords[index * 2 + 1] = y;
            return;
         }
         throw new RangeError("Invalid index: " + index);
      }
      
      public function getVertex(index:int, out:Point = null) : Point
      {
         if(index >= 0 && index < numVertices)
         {
            if(!out)
            {
               out = new Point();
            }
            out.setTo(_coords[index * 2],_coords[index * 2 + 1]);
            return out;
         }
         throw new RangeError("Invalid index: " + index);
      }
      
      public function contains(x:Number, y:Number) : Boolean
      {
         var _loc6_:int = 0;
         var _loc9_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc3_:int = this.numVertices;
         var _loc7_:int = _loc3_ - 1;
         var _loc5_:uint = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc3_)
         {
            _loc9_ = _coords[_loc6_ * 2];
            _loc4_ = _coords[_loc6_ * 2 + 1];
            _loc8_ = _coords[_loc7_ * 2];
            _loc10_ = _coords[_loc7_ * 2 + 1];
            if((_loc4_ < y && _loc10_ >= y || _loc10_ < y && _loc4_ >= y) && (_loc9_ <= x || _loc8_ <= x))
            {
               _loc5_ ^= uint(_loc9_ + (y - _loc4_) / (_loc10_ - _loc4_) * (_loc8_ - _loc9_) < x);
            }
            _loc7_ = _loc6_;
            _loc6_++;
         }
         return _loc5_ != 0;
      }
      
      public function containsPoint(point:Point) : Boolean
      {
         return contains(point.x,point.y);
      }
      
      public function triangulate(indexData:IndexData = null, offset:int = 0) : IndexData
      {
         var _loc17_:Vector.<uint> = undefined;
         var _loc19_:int = 0;
         var _loc18_:int = 0;
         var _loc16_:int = 0;
         var _loc13_:int = 0;
         var _loc11_:int = 0;
         var _loc9_:uint = 0;
         var _loc6_:Boolean = false;
         var _loc7_:uint = 0;
         var _loc10_:uint = 0;
         var _loc12_:uint = 0;
         if(useEarcut)
         {
            _loc17_ = Earcut.earcut(this._coords);
            if(indexData == null)
            {
               indexData = new IndexData(_loc17_.length);
            }
            if(_loc17_.length < 3)
            {
               return indexData;
            }
            _loc19_ = _loc17_.length / 3;
            _loc18_ = 0;
            while(_loc18_ < _loc19_)
            {
               indexData.addTriangle(_loc17_[_loc18_ * 3] + offset,_loc17_[_loc18_ * 3 + 1] + offset,_loc17_[_loc18_ * 3 + 2] + offset);
               _loc18_++;
            }
            return indexData;
         }
         var _loc14_:int = this.numVertices;
         var _loc8_:int = this.numTriangles;
         if(indexData == null)
         {
            indexData = new IndexData(_loc8_ * 3);
         }
         if(_loc8_ == 0)
         {
            return indexData;
         }
         sRestIndices.length = _loc14_;
         _loc11_ = 0;
         while(_loc11_ < _loc14_)
         {
            sRestIndices[_loc11_] = _loc11_;
            _loc11_++;
         }
         _loc16_ = 0;
         _loc13_ = _loc14_;
         var _loc3_:Point = Pool.getPoint();
         var _loc4_:Point = Pool.getPoint();
         var _loc5_:Point = Pool.getPoint();
         var _loc15_:Point = Pool.getPoint();
         while(_loc13_ > 3)
         {
            _loc6_ = false;
            _loc7_ = sRestIndices[_loc16_ % _loc13_];
            _loc10_ = sRestIndices[(_loc16_ + 1) % _loc13_];
            _loc12_ = sRestIndices[(_loc16_ + 2) % _loc13_];
            _loc3_.setTo(_coords[2 * _loc7_],_coords[2 * _loc7_ + 1]);
            _loc4_.setTo(_coords[2 * _loc10_],_coords[2 * _loc10_ + 1]);
            _loc5_.setTo(_coords[2 * _loc12_],_coords[2 * _loc12_ + 1]);
            if(isConvexTriangle(_loc3_.x,_loc3_.y,_loc4_.x,_loc4_.y,_loc5_.x,_loc5_.y))
            {
               _loc6_ = true;
               _loc11_ = 3;
               while(_loc11_ < _loc13_)
               {
                  _loc9_ = sRestIndices[(_loc16_ + _loc11_) % _loc13_];
                  _loc15_.setTo(_coords[2 * _loc9_],_coords[2 * _loc9_ + 1]);
                  if(MathUtil.isPointInTriangle(_loc15_,_loc3_,_loc4_,_loc5_))
                  {
                     _loc6_ = false;
                     break;
                  }
                  _loc11_++;
               }
            }
            if(_loc6_)
            {
               indexData.addTriangle(_loc7_ + offset,_loc10_ + offset,_loc12_ + offset);
               sRestIndices.removeAt((_loc16_ + 1) % _loc13_);
               _loc13_--;
               _loc16_ = 0;
            }
            else if(++_loc16_ == _loc13_)
            {
               break;
            }
         }
         Pool.putPoint(_loc3_);
         Pool.putPoint(_loc4_);
         Pool.putPoint(_loc5_);
         Pool.putPoint(_loc15_);
         indexData.addTriangle(sRestIndices[0] + offset,sRestIndices[1] + offset,sRestIndices[2] + offset);
         return indexData;
      }
      
      public function copyToVertexData(target:VertexData = null, targetVertexID:int = 0, attrName:String = "position") : void
      {
         var _loc6_:int = 0;
         var _loc4_:int = this.numVertices;
         var _loc5_:int = targetVertexID + _loc4_;
         if(target.numVertices < _loc5_)
         {
            target.numVertices = _loc5_;
         }
         _loc6_ = 0;
         while(_loc6_ < _loc4_)
         {
            target.setPoint(targetVertexID + _loc6_,attrName,_coords[_loc6_ * 2],_coords[_loc6_ * 2 + 1]);
            _loc6_++;
         }
      }
      
      public function toString() : String
      {
         var _loc3_:int = 0;
         var _loc1_:String = "[Polygon";
         var _loc2_:int = this.numVertices;
         if(_loc2_ > 0)
         {
            _loc1_ += "\n";
         }
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ += "  [Vertex " + _loc3_ + ": " + "x=" + _coords[_loc3_ * 2].toFixed(1) + ", " + "y=" + _coords[_loc3_ * 2 + 1].toFixed(1) + "]" + (_loc3_ == _loc2_ - 1 ? "\n" : ",\n");
            _loc3_++;
         }
         return _loc1_ + "]";
      }
      
      public function get isSimple() : Boolean
      {
         var _loc11_:int = 0;
         var _loc7_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc12_:int = 0;
         var _loc3_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc10_:int = int(_coords.length);
         if(_loc10_ <= 6)
         {
            return true;
         }
         _loc11_ = 0;
         while(_loc11_ < _loc10_)
         {
            _loc7_ = _coords[_loc11_];
            _loc9_ = _coords[_loc11_ + 1];
            _loc5_ = _coords[(_loc11_ + 2) % _loc10_];
            _loc8_ = _coords[(_loc11_ + 3) % _loc10_];
            _loc1_ = _loc11_ + _loc10_ - 2;
            _loc12_ = _loc11_ + 4;
            while(_loc12_ < _loc1_)
            {
               _loc3_ = _coords[_loc12_ % _loc10_];
               _loc6_ = _coords[(_loc12_ + 1) % _loc10_];
               _loc2_ = _coords[(_loc12_ + 2) % _loc10_];
               _loc4_ = _coords[(_loc12_ + 3) % _loc10_];
               if(areVectorsIntersecting(_loc7_,_loc9_,_loc5_,_loc8_,_loc3_,_loc6_,_loc2_,_loc4_))
               {
                  return false;
               }
               _loc12_ += 2;
            }
            _loc11_ += 2;
         }
         return true;
      }
      
      public function get isConvex() : Boolean
      {
         var _loc2_:int = 0;
         var _loc1_:int = int(_coords.length);
         if(_loc1_ < 6)
         {
            return true;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(!isConvexTriangle(_coords[_loc2_],_coords[_loc2_ + 1],_coords[(_loc2_ + 2) % _loc1_],_coords[(_loc2_ + 3) % _loc1_],_coords[(_loc2_ + 4) % _loc1_],_coords[(_loc2_ + 5) % _loc1_]))
            {
               return false;
            }
            _loc2_ += 2;
         }
         return true;
      }
      
      public function get area() : Number
      {
         var _loc3_:int = 0;
         var _loc1_:Number = 0;
         var _loc2_:int = int(_coords.length);
         if(_loc2_ >= 6)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc1_ += _coords[_loc3_] * _coords[(_loc3_ + 3) % _loc2_];
               _loc1_ -= _coords[_loc3_ + 1] * _coords[(_loc3_ + 2) % _loc2_];
               _loc3_ += 2;
            }
         }
         return _loc1_ / 2;
      }
      
      public function get numVertices() : int
      {
         return _coords.length / 2;
      }
      
      public function set numVertices(value:int) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = numVertices;
         _coords.length = value * 2;
         if(_loc2_ < value)
         {
            _loc3_ = _loc2_;
            while(_loc3_ < value)
            {
               _coords[_loc3_ * 2] = _coords[_loc3_ * 2 + 1] = 0;
               _loc3_++;
            }
         }
      }
      
      public function get numTriangles() : int
      {
         var _loc1_:int = this.numVertices;
         return _loc1_ >= 3 ? _loc1_ - 2 : 0;
      }
   }
}

import flash.errors.IllegalOperationError;
import flash.utils.getQualifiedClassName;
import starling.geom.Polygon;
import starling.rendering.IndexData;

class ImmutablePolygon extends Polygon
{
   
   private var _frozen:Boolean;
   
   public function ImmutablePolygon(vertices:Array)
   {
      super(vertices);
      _frozen = true;
   }
   
   override public function addVertices(... rest) : void
   {
      if(_frozen)
      {
         throw getImmutableError();
      }
      super.addVertices.apply(this,rest);
   }
   
   override public function setVertex(index:int, x:Number, y:Number) : void
   {
      if(_frozen)
      {
         throw getImmutableError();
      }
      super.setVertex(index,x,y);
   }
   
   override public function reverse() : void
   {
      if(_frozen)
      {
         throw getImmutableError();
      }
      super.reverse();
   }
   
   override public function set numVertices(value:int) : void
   {
      if(_frozen)
      {
         throw getImmutableError();
      }
      super.reverse();
   }
   
   private function getImmutableError() : Error
   {
      var _loc2_:String = getQualifiedClassName(this).split("::").pop();
      var _loc1_:String = _loc2_ + " cannot be modified. Call \'clone\' to create a mutable copy.";
      return new IllegalOperationError(_loc1_);
   }
}

class Ellipse extends ImmutablePolygon
{
   
   private var _x:Number;
   
   private var _y:Number;
   
   private var _radiusX:Number;
   
   private var _radiusY:Number;
   
   public function Ellipse(x:Number, y:Number, radiusX:Number, radiusY:Number, numSides:int = -1)
   {
      _x = x;
      _y = y;
      _radiusX = radiusX;
      _radiusY = radiusY;
      super(getVertices(numSides));
   }
   
   private function getVertices(numSides:int) : Array
   {
      var _loc5_:int = 0;
      if(numSides < 0)
      {
         numSides = 3.141592653589793 * (_radiusX + _radiusY) / 4;
      }
      if(numSides < 6)
      {
         numSides = 6;
      }
      var _loc2_:Array = [];
      var _loc3_:Number = 2 * 3.141592653589793 / numSides;
      var _loc4_:Number = 0;
      _loc5_ = 0;
      while(_loc5_ < numSides)
      {
         _loc2_[_loc5_ * 2] = Math.cos(_loc4_) * _radiusX + _x;
         _loc2_[_loc5_ * 2 + 1] = Math.sin(_loc4_) * _radiusY + _y;
         _loc4_ += _loc3_;
         _loc5_++;
      }
      return _loc2_;
   }
   
   override public function triangulate(indexData:IndexData = null, offset:int = 0) : IndexData
   {
      var _loc3_:int = 0;
      if(indexData == null)
      {
         indexData = new IndexData((numVertices - 2) * 3);
      }
      var _loc4_:uint = 1;
      var _loc5_:uint = numVertices - 1;
      _loc3_ = int(_loc4_);
      while(_loc3_ < _loc5_)
      {
         indexData.addTriangle(offset,offset + _loc3_,offset + _loc3_ + 1);
         _loc3_++;
      }
      return indexData;
   }
   
   override public function contains(x:Number, y:Number) : Boolean
   {
      var _loc4_:Number = x - _x;
      var _loc6_:Number = y - _y;
      var _loc3_:Number = _loc4_ / _radiusX;
      var _loc5_:Number = _loc6_ / _radiusY;
      return _loc3_ * _loc3_ + _loc5_ * _loc5_ <= 1;
   }
   
   override public function get area() : Number
   {
      return 3.141592653589793 * _radiusX * _radiusY;
   }
   
   override public function get isSimple() : Boolean
   {
      return true;
   }
   
   override public function get isConvex() : Boolean
   {
      return true;
   }
}

class Rectangle extends ImmutablePolygon
{
   
   private var _x:Number;
   
   private var _y:Number;
   
   private var _width:Number;
   
   private var _height:Number;
   
   public function Rectangle(x:Number, y:Number, width:Number, height:Number)
   {
      _x = x;
      _y = y;
      _width = width;
      _height = height;
      super([x,y,x + width,y,x + width,y + height,x,y + height]);
   }
   
   override public function triangulate(indexData:IndexData = null, offset:int = 0) : IndexData
   {
      if(indexData == null)
      {
         indexData = new IndexData(6);
      }
      indexData.addTriangle(offset,offset + 1,offset + 3);
      indexData.addTriangle(offset + 1,offset + 2,offset + 3);
      return indexData;
   }
   
   override public function contains(x:Number, y:Number) : Boolean
   {
      return x >= _x && x <= _x + _width && y >= _y && y <= _y + _height;
   }
   
   override public function get area() : Number
   {
      return _width * _height;
   }
   
   override public function get isSimple() : Boolean
   {
      return true;
   }
   
   override public function get isConvex() : Boolean
   {
      return true;
   }
}

class RoundRectangle extends ImmutablePolygon
{
   
   private var _x:Number;
   
   private var _y:Number;
   
   private var _width:Number;
   
   private var _height:Number;
   
   private var _radiusX:Number;
   
   private var _radiusY:Number;
   
   public function RoundRectangle(x:Number, y:Number, width:Number, height:Number, radiusX:Number, radiusY:Number)
   {
      _x = x;
      _y = y;
      _width = width;
      _height = height;
      _radiusX = radiusX;
      _radiusY = isNaN(radiusY) ? radiusX : radiusY;
      super(getVertices());
   }
   
   private function getNumVerticesPerCorner() : int
   {
      var _loc1_:int = Math.ceil(3.141592653589793 * (_radiusX + _radiusY) / 16);
      if(_loc1_ < 3)
      {
         _loc1_ = 3;
      }
      return _loc1_;
   }
   
   private function getVertices() : Array
   {
      var _loc10_:int = 0;
      var _loc6_:int = int(getNumVerticesPerCorner());
      var _loc1_:int = _loc6_ * 4;
      var _loc7_:Array = [];
      var _loc8_:Number = 3.141592653589793 / 2 / (_loc6_ - 1);
      var _loc9_:Number = 0;
      var _loc2_:Number = _width - _radiusX - _radiusX;
      var _loc4_:Number = _height - _radiusY - _radiusY;
      var _loc3_:Boolean = true;
      var _loc11_:int = 0;
      var _loc5_:int = _loc6_;
      _loc10_ = 0;
      while(_loc10_ < 4)
      {
         while(_loc11_ < _loc5_)
         {
            _loc7_[_loc11_ * 2] = _loc2_ + Math.cos(_loc9_) * _radiusX + _x + _radiusX;
            _loc7_[_loc11_ * 2 + 1] = _loc4_ + Math.sin(_loc9_) * _radiusY + _y + _radiusY;
            _loc9_ += _loc8_;
            _loc11_++;
         }
         _loc9_ -= _loc8_;
         if(_loc3_)
         {
            if(_loc2_ == 0)
            {
               _loc2_ = _width - _radiusX - _radiusX;
            }
            else
            {
               _loc2_ = 0;
            }
         }
         else if(_loc4_ == 0)
         {
            _loc4_ = _height - _radiusY - _radiusY;
         }
         else
         {
            _loc4_ = 0;
         }
         _loc3_ = !_loc3_;
         _loc5_ += _loc6_;
         _loc10_++;
      }
      return _loc7_;
   }
   
   override public function triangulate(indexData:IndexData = null, offset:int = 0) : IndexData
   {
      var _loc6_:int = 0;
      var _loc4_:int = int(getNumVerticesPerCorner());
      var _loc3_:int = _loc4_ * 4;
      var _loc5_:int = _loc3_ - 2;
      if(indexData == null)
      {
         indexData = new IndexData(_loc5_ * 3);
      }
      _loc6_ = 0;
      while(_loc6_ < _loc5_)
      {
         indexData.addTriangle(0,_loc6_ + 1,_loc6_ + 2);
         _loc6_++;
      }
      return indexData;
   }
   
   override public function contains(x:Number, y:Number) : Boolean
   {
      var _loc8_:Number = NaN;
      var _loc4_:Number = NaN;
      if(x < _x || y < _y || x > _x + _width || y > _y + _height)
      {
         return false;
      }
      if(x >= _x + _radiusX && x <= _x + _width - _radiusX)
      {
         return true;
      }
      if(y >= _y + _radiusY && y <= _y + _height - _radiusY)
      {
         return true;
      }
      if(x < _x + _radiusX)
      {
         _loc8_ = _x + _radiusX;
      }
      else
      {
         _loc8_ = _x + _width - _radiusX;
      }
      if(y < _y + _radiusY)
      {
         _loc4_ = _y + _radiusY;
      }
      else
      {
         _loc4_ = _y + _height - _radiusY;
      }
      var _loc5_:Number = x - _loc8_;
      var _loc7_:Number = y - _loc4_;
      var _loc3_:Number = _loc5_ / _radiusX;
      var _loc6_:Number = _loc7_ / _radiusY;
      return _loc3_ * _loc3_ + _loc6_ * _loc6_ <= 1;
   }
   
   override public function get area() : Number
   {
      return _width * _height - (4 - 3.141592653589793) * _radiusX * _radiusY;
   }
   
   override public function get isSimple() : Boolean
   {
      return true;
   }
   
   override public function get isConvex() : Boolean
   {
      return true;
   }
}
