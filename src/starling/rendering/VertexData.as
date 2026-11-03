package starling.rendering
{
   import flash.display3D.Context3D;
   import flash.display3D.VertexBuffer3D;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.utils.ByteArray;
   import starling.core.Starling;
   import starling.errors.MissingContextError;
   import starling.styles.MeshStyle;
   import starling.utils.MathUtil;
   import starling.utils.MatrixUtil;
   import starling.utils.StringUtil;
   
   public class VertexData
   {
      
      private static var sHelperPoint:Point = new Point();
      
      private static var sHelperPoint3D:Vector3D = new Vector3D();
      
      private static var sBytes:ByteArray = new ByteArray();
      
      private var _rawData:ByteArray;
      
      private var _numVertices:int;
      
      private var _format:VertexDataFormat;
      
      private var _attributes:Vector.<VertexDataAttribute>;
      
      private var _numAttributes:int;
      
      private var _premultipliedAlpha:Boolean;
      
      private var _tinted:Boolean;
      
      private var _posOffset:int;
      
      private var _colOffset:int;
      
      private var _vertexSize:int;
      
      public function VertexData(format:* = null, initialCapacity:int = 32)
      {
         super();
         if(format == null)
         {
            _format = MeshStyle.VERTEX_FORMAT;
         }
         else if(format is VertexDataFormat)
         {
            _format = format;
         }
         else
         {
            if(!(format is String))
            {
               throw new ArgumentError("\'format\' must be String or VertexDataFormat");
            }
            _format = VertexDataFormat.fromString(format as String);
         }
         _attributes = _format.attributes;
         _numAttributes = _attributes.length;
         _posOffset = _format.hasAttribute("position") ? _format.getOffset("position") : 0;
         _colOffset = _format.hasAttribute("color") ? _format.getOffset("color") : 0;
         _vertexSize = _format.vertexSize;
         _numVertices = 0;
         _premultipliedAlpha = true;
         _rawData = new ByteArray();
         _rawData.endian = sBytes.endian = "littleEndian";
         _rawData.length = initialCapacity * _vertexSize;
         _rawData.length = 0;
      }
      
      private static function premultiplyAlpha(rgba:uint) : uint
      {
         var _loc6_:Number = NaN;
         var _loc2_:uint = 0;
         var _loc5_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:uint = uint(rgba & 0xFF);
         if(_loc4_ == 255)
         {
            return rgba;
         }
         _loc6_ = _loc4_ / 255;
         _loc2_ = (rgba >> 24 & 0xFF) * _loc6_;
         _loc5_ = (rgba >> 16 & 0xFF) * _loc6_;
         _loc3_ = (rgba >> 8 & 0xFF) * _loc6_;
         return (_loc2_ & 0xFF) << 24 | (_loc5_ & 0xFF) << 16 | (_loc3_ & 0xFF) << 8 | _loc4_;
      }
      
      private static function unmultiplyAlpha(rgba:uint) : uint
      {
         var _loc6_:Number = NaN;
         var _loc2_:uint = 0;
         var _loc5_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:uint = uint(rgba & 0xFF);
         if(_loc4_ == 255 || _loc4_ == 0)
         {
            return rgba;
         }
         _loc6_ = _loc4_ / 255;
         _loc2_ = (rgba >> 24 & 0xFF) / _loc6_;
         _loc5_ = (rgba >> 16 & 0xFF) / _loc6_;
         _loc3_ = (rgba >> 8 & 0xFF) / _loc6_;
         return (_loc2_ & 0xFF) << 24 | (_loc5_ & 0xFF) << 16 | (_loc3_ & 0xFF) << 8 | _loc4_;
      }
      
      public function clear() : void
      {
         _rawData.clear();
         _numVertices = 0;
         _tinted = false;
      }
      
      public function clone() : VertexData
      {
         var _loc1_:VertexData = new VertexData(_format,_numVertices);
         _loc1_._rawData.writeBytes(_rawData);
         _loc1_._numVertices = _numVertices;
         _loc1_._premultipliedAlpha = _premultipliedAlpha;
         _loc1_._tinted = _tinted;
         return _loc1_;
      }
      
      public function copyTo(target:VertexData, targetVertexID:int = 0, matrix:Matrix = null, vertexID:int = 0, numVertices:int = -1) : void
      {
         var _loc8_:ByteArray = null;
         var _loc13_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc11_:int = 0;
         var _loc9_:int = 0;
         var _loc7_:int = 0;
         var _loc10_:VertexDataAttribute = null;
         var _loc6_:VertexDataAttribute = null;
         if(numVertices < 0 || vertexID + numVertices > _numVertices)
         {
            numVertices = _numVertices - vertexID;
         }
         if(_format === target._format)
         {
            if(target._numVertices < targetVertexID + numVertices)
            {
               target._numVertices = targetVertexID + numVertices;
            }
            target._tinted ||= _tinted;
            _loc8_ = target._rawData;
            _loc8_.position = targetVertexID * _vertexSize;
            _loc8_.writeBytes(_rawData,vertexID * _vertexSize,numVertices * _vertexSize);
            if(matrix)
            {
               _loc11_ = targetVertexID * _vertexSize + _posOffset;
               _loc9_ = _loc11_ + numVertices * _vertexSize;
               while(_loc11_ < _loc9_)
               {
                  _loc8_.position = _loc11_;
                  _loc12_ = _loc8_.readFloat();
                  _loc13_ = _loc8_.readFloat();
                  _loc8_.position = _loc11_;
                  _loc8_.writeFloat(matrix.a * _loc12_ + matrix.c * _loc13_ + matrix.tx);
                  _loc8_.writeFloat(matrix.d * _loc13_ + matrix.b * _loc12_ + matrix.ty);
                  _loc11_ += _vertexSize;
               }
            }
         }
         else
         {
            if(target._numVertices < targetVertexID + numVertices)
            {
               target.numVertices = targetVertexID + numVertices;
            }
            _loc7_ = 0;
            while(_loc7_ < _numAttributes)
            {
               _loc10_ = _attributes[_loc7_];
               _loc6_ = target.getAttribute(_loc10_.name);
               if(_loc6_)
               {
                  if(_loc10_.offset == _posOffset)
                  {
                     copyAttributeTo_internal(target,targetVertexID,matrix,_loc10_,_loc6_,vertexID,numVertices);
                  }
                  else
                  {
                     copyAttributeTo_internal(target,targetVertexID,null,_loc10_,_loc6_,vertexID,numVertices);
                  }
               }
               _loc7_++;
            }
         }
      }
      
      public function copyAttributeTo(target:VertexData, targetVertexID:int, attrName:String, matrix:Matrix = null, vertexID:int = 0, numVertices:int = -1) : void
      {
         var _loc8_:VertexDataAttribute = getAttribute(attrName);
         var _loc7_:VertexDataAttribute = target.getAttribute(attrName);
         if(_loc8_ == null)
         {
            throw new ArgumentError("Attribute \'" + attrName + "\' not found in source data");
         }
         if(_loc7_ == null)
         {
            throw new ArgumentError("Attribute \'" + attrName + "\' not found in target data");
         }
         if(_loc8_.isColor)
         {
            target._tinted ||= _tinted;
         }
         copyAttributeTo_internal(target,targetVertexID,matrix,_loc8_,_loc7_,vertexID,numVertices);
      }
      
      private function copyAttributeTo_internal(target:VertexData, targetVertexID:int, matrix:Matrix, sourceAttribute:VertexDataAttribute, targetAttribute:VertexDataAttribute, vertexID:int, numVertices:int) : void
      {
         var _loc11_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc10_:int = 0;
         if(sourceAttribute.format != targetAttribute.format)
         {
            throw new IllegalOperationError("Attribute formats differ between source and target");
         }
         if(numVertices < 0 || vertexID + numVertices > _numVertices)
         {
            numVertices = _numVertices - vertexID;
         }
         if(target._numVertices < targetVertexID + numVertices)
         {
            target._numVertices = targetVertexID + numVertices;
         }
         var _loc16_:ByteArray = _rawData;
         var _loc8_:ByteArray = target._rawData;
         var _loc12_:int = _vertexSize - sourceAttribute.size;
         var _loc15_:int = target._vertexSize - targetAttribute.size;
         var _loc9_:int = sourceAttribute.size / 4;
         _loc16_.position = vertexID * _vertexSize + sourceAttribute.offset;
         _loc8_.position = targetVertexID * target._vertexSize + targetAttribute.offset;
         if(matrix)
         {
            _loc10_ = 0;
            while(_loc10_ < numVertices)
            {
               _loc13_ = _loc16_.readFloat();
               _loc14_ = _loc16_.readFloat();
               _loc8_.writeFloat(matrix.a * _loc13_ + matrix.c * _loc14_ + matrix.tx);
               _loc8_.writeFloat(matrix.d * _loc14_ + matrix.b * _loc13_ + matrix.ty);
               _loc16_.position += _loc12_;
               _loc8_.position += _loc15_;
               _loc10_++;
            }
         }
         else
         {
            _loc10_ = 0;
            while(_loc10_ < numVertices)
            {
               _loc11_ = 0;
               while(_loc11_ < _loc9_)
               {
                  _loc8_.writeUnsignedInt(_loc16_.readUnsignedInt());
                  _loc11_++;
               }
               _loc16_.position += _loc12_;
               _loc8_.position += _loc15_;
               _loc10_++;
            }
         }
      }
      
      public function trim() : void
      {
         var _loc1_:int = _numVertices * _vertexSize;
         sBytes.length = _loc1_;
         sBytes.position = 0;
         sBytes.writeBytes(_rawData,0,_loc1_);
         _rawData.clear();
         _rawData.length = _loc1_;
         _rawData.writeBytes(sBytes);
         sBytes.length = 0;
      }
      
      public function toString() : String
      {
         return StringUtil.format("[VertexData format=\"{0}\" numVertices={1}]",_format.formatString,_numVertices);
      }
      
      public function getUnsignedInt(vertexID:int, attrName:String) : uint
      {
         _rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
         return _rawData.readUnsignedInt();
      }
      
      public function setUnsignedInt(vertexID:int, attrName:String, value:uint) : void
      {
         if(_numVertices < vertexID + 1)
         {
            numVertices = vertexID + 1;
         }
         _rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
         _rawData.writeUnsignedInt(value);
      }
      
      public function getFloat(vertexID:int, attrName:String) : Number
      {
         _rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
         return _rawData.readFloat();
      }
      
      public function setFloat(vertexID:int, attrName:String, value:Number) : void
      {
         if(_numVertices < vertexID + 1)
         {
            numVertices = vertexID + 1;
         }
         _rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
         _rawData.writeFloat(value);
      }
      
      public function getPoint(vertexID:int, attrName:String, out:Point = null) : Point
      {
         if(out == null)
         {
            out = new Point();
         }
         var _loc4_:int = attrName == "position" ? _posOffset : getAttribute(attrName).offset;
         _rawData.position = vertexID * _vertexSize + _loc4_;
         out.x = _rawData.readFloat();
         out.y = _rawData.readFloat();
         return out;
      }
      
      public function setPoint(vertexID:int, attrName:String, x:Number, y:Number) : void
      {
         if(_numVertices < vertexID + 1)
         {
            numVertices = vertexID + 1;
         }
         var _loc5_:int = attrName == "position" ? _posOffset : getAttribute(attrName).offset;
         _rawData.position = vertexID * _vertexSize + _loc5_;
         _rawData.writeFloat(x);
         _rawData.writeFloat(y);
      }
      
      public function getPoint3D(vertexID:int, attrName:String, out:Vector3D = null) : Vector3D
      {
         if(out == null)
         {
            out = new Vector3D();
         }
         _rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
         out.x = _rawData.readFloat();
         out.y = _rawData.readFloat();
         out.z = _rawData.readFloat();
         return out;
      }
      
      public function setPoint3D(vertexID:int, attrName:String, x:Number, y:Number, z:Number) : void
      {
         if(_numVertices < vertexID + 1)
         {
            numVertices = vertexID + 1;
         }
         _rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
         _rawData.writeFloat(x);
         _rawData.writeFloat(y);
         _rawData.writeFloat(z);
      }
      
      public function getPoint4D(vertexID:int, attrName:String, out:Vector3D = null) : Vector3D
      {
         if(out == null)
         {
            out = new Vector3D();
         }
         _rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
         out.x = _rawData.readFloat();
         out.y = _rawData.readFloat();
         out.z = _rawData.readFloat();
         out.w = _rawData.readFloat();
         return out;
      }
      
      public function setPoint4D(vertexID:int, attrName:String, x:Number, y:Number, z:Number, w:Number = 1) : void
      {
         if(_numVertices < vertexID + 1)
         {
            numVertices = vertexID + 1;
         }
         _rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
         _rawData.writeFloat(x);
         _rawData.writeFloat(y);
         _rawData.writeFloat(z);
         _rawData.writeFloat(w);
      }
      
      public function getColor(vertexID:int, attrName:String = "color") : uint
      {
         var _loc4_:int = attrName == "color" ? _colOffset : getAttribute(attrName).offset;
         _rawData.position = vertexID * _vertexSize + _loc4_;
         _rawData.endian = "bigEndian";
         var _loc3_:uint = _rawData.readUnsignedInt();
         if(_premultipliedAlpha)
         {
            _loc3_ = unmultiplyAlpha(_loc3_);
         }
         _rawData.endian = "littleEndian";
         return _loc3_ >> 8 & 0xFFFFFF;
      }
      
      public function setColor(vertexID:int, attrName:String, color:uint) : void
      {
         if(_numVertices < vertexID + 1)
         {
            numVertices = vertexID + 1;
         }
         var _loc4_:Number = getAlpha(vertexID,attrName);
         colorize(attrName,color,_loc4_,vertexID,1);
      }
      
      public function getAlpha(vertexID:int, attrName:String = "color") : Number
      {
         var _loc3_:int = attrName == "color" ? _colOffset : getAttribute(attrName).offset;
         var _loc4_:int = vertexID * _vertexSize + _loc3_ + 3;
         return _rawData[_loc4_] / 255;
      }
      
      public function setAlpha(vertexID:int, attrName:String, alpha:Number) : void
      {
         if(_numVertices < vertexID + 1)
         {
            numVertices = vertexID + 1;
         }
         var _loc4_:uint = getColor(vertexID,attrName);
         colorize(attrName,_loc4_,alpha,vertexID,1);
      }
      
      public function getBounds(attrName:String = "position", matrix:Matrix = null, vertexID:int = 0, numVertices:int = -1, out:Rectangle = null) : Rectangle
      {
         var _loc11_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc6_:int = 0;
         var _loc14_:int = 0;
         var _loc13_:Number = NaN;
         var _loc9_:int = 0;
         var _loc12_:Number = NaN;
         if(out == null)
         {
            out = new Rectangle();
         }
         if(numVertices < 0 || vertexID + numVertices > _numVertices)
         {
            numVertices = _numVertices - vertexID;
         }
         if(numVertices == 0)
         {
            if(matrix == null)
            {
               out.setEmpty();
            }
            else
            {
               MatrixUtil.transformCoords(matrix,0,0,sHelperPoint);
               out.setTo(sHelperPoint.x,sHelperPoint.y,0,0);
            }
         }
         else
         {
            _loc11_ = 1.7976931348623157e+308;
            var _loc8_:Number = -1.7976931348623157e+308;
            _loc10_ = 1.7976931348623157e+308;
            var _loc7_:Number = -1.7976931348623157e+308;
            _loc6_ = attrName == "position" ? _posOffset : getAttribute(attrName).offset;
            _loc14_ = vertexID * _vertexSize + _loc6_;
            if(matrix == null)
            {
               _loc9_ = 0;
               while(_loc9_ < numVertices)
               {
                  _rawData.position = _loc14_;
                  _loc12_ = _rawData.readFloat();
                  _loc13_ = _rawData.readFloat();
                  _loc14_ += _vertexSize;
                  if(_loc11_ > _loc12_)
                  {
                     _loc11_ = _loc12_;
                  }
                  if(_loc8_ < _loc12_)
                  {
                     _loc8_ = _loc12_;
                  }
                  if(_loc10_ > _loc13_)
                  {
                     _loc10_ = _loc13_;
                  }
                  if(_loc7_ < _loc13_)
                  {
                     _loc7_ = _loc13_;
                  }
                  _loc9_++;
               }
            }
            else
            {
               _loc9_ = 0;
               while(_loc9_ < numVertices)
               {
                  _rawData.position = _loc14_;
                  _loc12_ = _rawData.readFloat();
                  _loc13_ = _rawData.readFloat();
                  _loc14_ += _vertexSize;
                  MatrixUtil.transformCoords(matrix,_loc12_,_loc13_,sHelperPoint);
                  if(_loc11_ > sHelperPoint.x)
                  {
                     _loc11_ = sHelperPoint.x;
                  }
                  if(_loc8_ < sHelperPoint.x)
                  {
                     _loc8_ = sHelperPoint.x;
                  }
                  if(_loc10_ > sHelperPoint.y)
                  {
                     _loc10_ = sHelperPoint.y;
                  }
                  if(_loc7_ < sHelperPoint.y)
                  {
                     _loc7_ = sHelperPoint.y;
                  }
                  _loc9_++;
               }
            }
            out.setTo(_loc11_,_loc10_,_loc8_ - _loc11_,_loc7_ - _loc10_);
         }
         return out;
      }
      
      public function getBoundsProjected(attrName:String, matrix:Matrix3D, camPos:Vector3D, vertexID:int = 0, numVertices:int = -1, out:Rectangle = null) : Rectangle
      {
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc7_:int = 0;
         var _loc15_:int = 0;
         var _loc14_:Number = NaN;
         var _loc10_:int = 0;
         var _loc13_:Number = NaN;
         if(out == null)
         {
            out = new Rectangle();
         }
         if(camPos == null)
         {
            throw new ArgumentError("camPos must not be null");
         }
         if(numVertices < 0 || vertexID + numVertices > _numVertices)
         {
            numVertices = _numVertices - vertexID;
         }
         if(numVertices == 0)
         {
            if(matrix)
            {
               MatrixUtil.transformCoords3D(matrix,0,0,0,sHelperPoint3D);
            }
            else
            {
               sHelperPoint3D.setTo(0,0,0);
            }
            MathUtil.intersectLineWithXYPlane(camPos,sHelperPoint3D,sHelperPoint);
            out.setTo(sHelperPoint.x,sHelperPoint.y,0,0);
         }
         else
         {
            _loc12_ = 1.7976931348623157e+308;
            var _loc9_:Number = -1.7976931348623157e+308;
            _loc11_ = 1.7976931348623157e+308;
            var _loc8_:Number = -1.7976931348623157e+308;
            _loc7_ = attrName == "position" ? _posOffset : getAttribute(attrName).offset;
            _loc15_ = vertexID * _vertexSize + _loc7_;
            _loc10_ = 0;
            while(_loc10_ < numVertices)
            {
               _rawData.position = _loc15_;
               _loc13_ = _rawData.readFloat();
               _loc14_ = _rawData.readFloat();
               _loc15_ += _vertexSize;
               if(matrix)
               {
                  MatrixUtil.transformCoords3D(matrix,_loc13_,_loc14_,0,sHelperPoint3D);
               }
               else
               {
                  sHelperPoint3D.setTo(_loc13_,_loc14_,0);
               }
               MathUtil.intersectLineWithXYPlane(camPos,sHelperPoint3D,sHelperPoint);
               if(_loc12_ > sHelperPoint.x)
               {
                  _loc12_ = sHelperPoint.x;
               }
               if(_loc9_ < sHelperPoint.x)
               {
                  _loc9_ = sHelperPoint.x;
               }
               if(_loc11_ > sHelperPoint.y)
               {
                  _loc11_ = sHelperPoint.y;
               }
               if(_loc8_ < sHelperPoint.y)
               {
                  _loc8_ = sHelperPoint.y;
               }
               _loc10_++;
            }
            out.setTo(_loc12_,_loc11_,_loc9_ - _loc12_,_loc8_ - _loc11_);
         }
         return out;
      }
      
      public function get premultipliedAlpha() : Boolean
      {
         return _premultipliedAlpha;
      }
      
      public function set premultipliedAlpha(value:Boolean) : void
      {
         setPremultipliedAlpha(value,false);
      }
      
      public function setPremultipliedAlpha(value:Boolean, updateData:Boolean) : void
      {
         var _loc6_:int = 0;
         var _loc8_:VertexDataAttribute = null;
         var _loc4_:int = 0;
         var _loc3_:uint = 0;
         var _loc5_:uint = 0;
         var _loc7_:int = 0;
         if(updateData && value != _premultipliedAlpha)
         {
            _rawData.endian = "bigEndian";
            _loc6_ = 0;
            while(_loc6_ < _numAttributes)
            {
               _loc8_ = _attributes[_loc6_];
               if(_loc8_.isColor)
               {
                  _loc4_ = _loc8_.offset;
                  _loc7_ = 0;
                  while(_loc7_ < _numVertices)
                  {
                     _rawData.position = _loc4_;
                     _loc3_ = _rawData.readUnsignedInt();
                     _loc5_ = value ? premultiplyAlpha(_loc3_) : unmultiplyAlpha(_loc3_);
                     _rawData.position = _loc4_;
                     _rawData.writeUnsignedInt(_loc5_);
                     _loc4_ += _vertexSize;
                     _loc7_++;
                  }
               }
               _loc6_++;
            }
            _rawData.endian = "littleEndian";
         }
         _premultipliedAlpha = value;
      }
      
      public function updateTinted(attrName:String = "color") : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:int = attrName == "color" ? _colOffset : getAttribute(attrName).offset;
         _tinted = false;
         _loc3_ = 0;
         while(_loc3_ < _numVertices)
         {
            _rawData.position = _loc2_;
            if(_rawData.readUnsignedInt() != 4294967295)
            {
               _tinted = true;
               break;
            }
            _loc2_ += _vertexSize;
            _loc3_++;
         }
         return _tinted;
      }
      
      public function transformPoints(attrName:String, matrix:Matrix, vertexID:int = 0, numVertices:int = -1) : void
      {
         var _loc8_:Number = NaN;
         var _loc7_:Number = NaN;
         if(numVertices < 0 || vertexID + numVertices > _numVertices)
         {
            numVertices = _numVertices - vertexID;
         }
         var _loc5_:int = attrName == "position" ? _posOffset : getAttribute(attrName).offset;
         var _loc6_:int = vertexID * _vertexSize + _loc5_;
         var _loc9_:int = _loc6_ + numVertices * _vertexSize;
         while(_loc6_ < _loc9_)
         {
            _rawData.position = _loc6_;
            _loc7_ = _rawData.readFloat();
            _loc8_ = _rawData.readFloat();
            _rawData.position = _loc6_;
            _rawData.writeFloat(matrix.a * _loc7_ + matrix.c * _loc8_ + matrix.tx);
            _rawData.writeFloat(matrix.d * _loc8_ + matrix.b * _loc7_ + matrix.ty);
            _loc6_ += _vertexSize;
         }
      }
      
      public function translatePoints(attrName:String, deltaX:Number, deltaY:Number, vertexID:int = 0, numVertices:int = -1) : void
      {
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         if(numVertices < 0 || vertexID + numVertices > _numVertices)
         {
            numVertices = _numVertices - vertexID;
         }
         var _loc6_:int = attrName == "position" ? _posOffset : getAttribute(attrName).offset;
         var _loc7_:int = vertexID * _vertexSize + _loc6_;
         var _loc10_:int = _loc7_ + numVertices * _vertexSize;
         while(_loc7_ < _loc10_)
         {
            _rawData.position = _loc7_;
            _loc8_ = _rawData.readFloat();
            _loc9_ = _rawData.readFloat();
            _rawData.position = _loc7_;
            _rawData.writeFloat(_loc8_ + deltaX);
            _rawData.writeFloat(_loc9_ + deltaY);
            _loc7_ += _vertexSize;
         }
      }
      
      public function scaleAlphas(attrName:String, factor:Number, vertexID:int = 0, numVertices:int = -1) : void
      {
         var _loc9_:int = 0;
         var _loc8_:Number = NaN;
         var _loc5_:uint = 0;
         var _loc10_:int = 0;
         if(factor == 1)
         {
            return;
         }
         if(numVertices < 0 || vertexID + numVertices > _numVertices)
         {
            numVertices = _numVertices - vertexID;
         }
         _tinted = true;
         _rawData.endian = "bigEndian";
         var _loc6_:int = attrName == "color" ? _colOffset : getAttribute(attrName).offset;
         var _loc7_:int = vertexID * _vertexSize + _loc6_;
         _loc9_ = 0;
         while(_loc9_ < numVertices)
         {
            _loc10_ = _loc7_ + 3;
            _loc8_ = _rawData[_loc10_] / 255 * factor;
            if(_loc8_ > 1)
            {
               _loc8_ = 1;
            }
            else if(_loc8_ < 0)
            {
               _loc8_ = 0;
            }
            if(_loc8_ == 1 || !_premultipliedAlpha)
            {
               _rawData[_loc10_] = int(_loc8_ * 255);
            }
            else
            {
               _rawData.position = _loc7_;
               _loc5_ = unmultiplyAlpha(_rawData.readUnsignedInt());
               _loc5_ = uint(_loc5_ & 0xFFFFFF00 | int(_loc8_ * 255) & 0xFF);
               _loc5_ = premultiplyAlpha(_loc5_);
               _rawData.position = _loc7_;
               _rawData.writeUnsignedInt(_loc5_);
            }
            _loc7_ += _vertexSize;
            _loc9_++;
         }
         _rawData.endian = "littleEndian";
      }
      
      public function colorize(attrName:String = "color", color:uint = 16777215, alpha:Number = 1, vertexID:int = 0, numVertices:int = -1) : void
      {
         if(numVertices < 0 || vertexID + numVertices > _numVertices)
         {
            numVertices = _numVertices - vertexID;
         }
         var _loc7_:int = attrName == "color" ? _colOffset : getAttribute(attrName).offset;
         var _loc8_:int = vertexID * _vertexSize + _loc7_;
         var _loc9_:int = _loc8_ + numVertices * _vertexSize;
         if(alpha > 1)
         {
            alpha = 1;
         }
         else if(alpha < 0)
         {
            alpha = 0;
         }
         var _loc6_:uint = uint(color << 8 & 0xFFFFFF00 | int(alpha * 255) & 0xFF);
         if(_loc6_ == 4294967295 && numVertices == _numVertices)
         {
            _tinted = false;
         }
         else if(_loc6_ != 4294967295)
         {
            _tinted = true;
         }
         if(_premultipliedAlpha && alpha != 1)
         {
            _loc6_ = premultiplyAlpha(_loc6_);
         }
         _rawData.position = vertexID * _vertexSize + _loc7_;
         _rawData.endian = "bigEndian";
         _rawData.writeUnsignedInt(_loc6_);
         while(_loc8_ < _loc9_)
         {
            _rawData.position = _loc8_;
            _rawData.writeUnsignedInt(_loc6_);
            _loc8_ += _vertexSize;
         }
         _rawData.endian = "littleEndian";
      }
      
      public function getFormat(attrName:String) : String
      {
         return getAttribute(attrName).format;
      }
      
      public function getSize(attrName:String) : int
      {
         return getAttribute(attrName).size;
      }
      
      public function getSizeIn32Bits(attrName:String) : int
      {
         return getAttribute(attrName).size / 4;
      }
      
      public function getOffset(attrName:String) : int
      {
         return getAttribute(attrName).offset;
      }
      
      public function getOffsetIn32Bits(attrName:String) : int
      {
         return getAttribute(attrName).offset / 4;
      }
      
      public function hasAttribute(attrName:String) : Boolean
      {
         return getAttribute(attrName) != null;
      }
      
      public function createVertexBuffer(upload:Boolean = false, bufferUsage:String = "staticDraw") : VertexBuffer3D
      {
         var _loc3_:Context3D = Starling.context;
         if(_loc3_ == null)
         {
            throw new MissingContextError();
         }
         if(_numVertices == 0)
         {
            return null;
         }
         var _loc4_:VertexBuffer3D = _loc3_.createVertexBuffer(_numVertices,_vertexSize / 4,bufferUsage);
         if(upload)
         {
            uploadToVertexBuffer(_loc4_);
         }
         return _loc4_;
      }
      
      public function uploadToVertexBuffer(buffer:VertexBuffer3D, vertexID:int = 0, numVertices:int = -1) : void
      {
         if(numVertices < 0 || vertexID + numVertices > _numVertices)
         {
            numVertices = _numVertices - vertexID;
         }
         if(numVertices > 0)
         {
            buffer.uploadFromByteArray(_rawData,0,vertexID,numVertices);
         }
      }
      
      final private function getAttribute(attrName:String) : VertexDataAttribute
      {
         var _loc3_:VertexDataAttribute = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _numAttributes)
         {
            _loc3_ = _attributes[_loc2_];
            if(_loc3_.name == attrName)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function get numVertices() : int
      {
         return _numVertices;
      }
      
      public function set numVertices(value:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:VertexDataAttribute = null;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         if(value > _numVertices)
         {
            _loc2_ = _numVertices * vertexSize;
            _loc3_ = value * _vertexSize;
            if(_rawData.length > _loc2_)
            {
               _rawData.position = _loc2_;
               while(_rawData.bytesAvailable)
               {
                  _rawData.writeUnsignedInt(0);
               }
            }
            if(_rawData.length < _loc3_)
            {
               _rawData.length = _loc3_;
            }
            _loc5_ = 0;
            while(_loc5_ < _numAttributes)
            {
               _loc7_ = _attributes[_loc5_];
               if(_loc7_.isColor)
               {
                  _loc4_ = _numVertices * _vertexSize + _loc7_.offset;
                  _loc6_ = _numVertices;
                  while(_loc6_ < value)
                  {
                     _rawData.position = _loc4_;
                     _rawData.writeUnsignedInt(4294967295);
                     _loc4_ += _vertexSize;
                     _loc6_++;
                  }
               }
               _loc5_++;
            }
         }
         if(value == 0)
         {
            _tinted = false;
         }
         _numVertices = value;
      }
      
      public function get rawData() : ByteArray
      {
         return _rawData;
      }
      
      public function get format() : VertexDataFormat
      {
         return _format;
      }
      
      public function set format(value:VertexDataFormat) : void
      {
         var _loc8_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:VertexDataAttribute = null;
         var _loc5_:VertexDataAttribute = null;
         if(_format == value)
         {
            return;
         }
         var _loc2_:int = _format.vertexSize;
         var _loc9_:int = value.vertexSize;
         var _loc3_:int = value.numAttributes;
         sBytes.length = value.vertexSize * _numVertices;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc7_ = value.attributes[_loc4_];
            _loc5_ = getAttribute(_loc7_.name);
            if(_loc5_)
            {
               _loc6_ = _loc7_.offset;
               _loc8_ = 0;
               while(_loc8_ < _numVertices)
               {
                  sBytes.position = _loc6_;
                  sBytes.writeBytes(_rawData,_loc2_ * _loc8_ + _loc5_.offset,_loc5_.size);
                  _loc6_ += _loc9_;
                  _loc8_++;
               }
            }
            else if(_loc7_.isColor)
            {
               _loc6_ = _loc7_.offset;
               _loc8_ = 0;
               while(_loc8_ < _numVertices)
               {
                  sBytes.position = _loc6_;
                  sBytes.writeUnsignedInt(4294967295);
                  _loc6_ += _loc9_;
                  _loc8_++;
               }
            }
            _loc4_++;
         }
         if(value.vertexSize > _format.vertexSize)
         {
            _rawData.clear();
         }
         _rawData.position = 0;
         _rawData.length = sBytes.length;
         _rawData.writeBytes(sBytes);
         sBytes.length = 0;
         _format = value;
         _attributes = _format.attributes;
         _numAttributes = _attributes.length;
         _vertexSize = _format.vertexSize;
         _posOffset = _format.hasAttribute("position") ? _format.getOffset("position") : 0;
         _colOffset = _format.hasAttribute("color") ? _format.getOffset("color") : 0;
      }
      
      public function get tinted() : Boolean
      {
         return _tinted;
      }
      
      public function set tinted(value:Boolean) : void
      {
         _tinted = value;
      }
      
      public function get formatString() : String
      {
         return _format.formatString;
      }
      
      public function get vertexSize() : int
      {
         return _vertexSize;
      }
      
      public function get vertexSizeIn32Bits() : int
      {
         return _vertexSize / 4;
      }
      
      public function get size() : int
      {
         return _numVertices * _vertexSize;
      }
      
      public function get sizeIn32Bits() : int
      {
         return _numVertices * _vertexSize / 4;
      }
   }
}

