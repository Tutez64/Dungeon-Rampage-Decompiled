package starling.rendering
{
   import flash.display3D.Context3D;
   import flash.display3D.IndexBuffer3D;
   import flash.errors.EOFError;
   import flash.utils.ByteArray;
   import starling.core.Starling;
   import starling.errors.MissingContextError;
   import starling.utils.StringUtil;
   
   public class IndexData
   {
      
      private static const INDEX_SIZE:int = 2;
      
      private static var sQuadDataNumIndices:uint = 0;
      
      private static var sQuadData:ByteArray = new ByteArray();
      
      private static var sVector:Vector.<uint> = new Vector.<uint>(0);
      
      private static var sTrimData:ByteArray = new ByteArray();
      
      private var _rawData:ByteArray;
      
      private var _numIndices:int;
      
      private var _initialCapacity:int;
      
      private var _useQuadLayout:Boolean;
      
      public function IndexData(initialCapacity:int = 48)
      {
         super();
         _numIndices = 0;
         _initialCapacity = initialCapacity;
         _useQuadLayout = true;
      }
      
      private static function getBasicQuadIndexAt(indexID:int) : int
      {
         var _loc3_:int = 0;
         var _loc2_:int = indexID / 6;
         var _loc4_:int = indexID - _loc2_ * 6;
         if(_loc4_ == 0)
         {
            _loc3_ = 0;
         }
         else if(_loc4_ == 1 || _loc4_ == 3)
         {
            _loc3_ = 1;
         }
         else if(_loc4_ == 2 || _loc4_ == 5)
         {
            _loc3_ = 2;
         }
         else
         {
            _loc3_ = 3;
         }
         return _loc2_ * 4 + _loc3_;
      }
      
      public function clear() : void
      {
         if(_rawData)
         {
            _rawData.clear();
         }
         _numIndices = 0;
         _useQuadLayout = true;
      }
      
      public function clone() : IndexData
      {
         var _loc1_:IndexData = new IndexData(_numIndices);
         if(!_useQuadLayout)
         {
            _loc1_.switchToGenericData();
            _loc1_._rawData.writeBytes(_rawData);
         }
         _loc1_._numIndices = _numIndices;
         return _loc1_;
      }
      
      public function copyTo(target:IndexData, targetIndexID:int = 0, offset:int = 0, indexID:int = 0, numIndices:int = -1) : void
      {
         var _loc6_:ByteArray = null;
         var _loc15_:ByteArray = null;
         var _loc16_:Boolean = false;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc13_:int = 0;
         var _loc12_:int = 0;
         var _loc11_:uint = 0;
         var _loc10_:uint = 0;
         var _loc14_:uint = 0;
         if(numIndices < 0 || indexID + numIndices > _numIndices)
         {
            numIndices = _numIndices - indexID;
         }
         var _loc8_:int = targetIndexID + numIndices;
         if(target._numIndices < _loc8_)
         {
            target._numIndices = _loc8_;
            if(sQuadDataNumIndices < _loc8_)
            {
               ensureQuadDataCapacity(_loc8_);
            }
         }
         if(_useQuadLayout)
         {
            if(target._useQuadLayout)
            {
               _loc16_ = true;
               _loc7_ = targetIndexID - indexID;
               _loc9_ = _loc7_ / 6;
               _loc13_ = offset / 4;
               if(_loc9_ == _loc13_ && (offset & 3) == 0 && _loc9_ * 6 == _loc7_)
               {
                  _loc16_ = true;
               }
               else if(numIndices > 2)
               {
                  _loc16_ = false;
               }
               else
               {
                  _loc12_ = 0;
                  while(_loc12_ < numIndices)
                  {
                     if(_loc16_)
                     {
                        _loc16_ = getBasicQuadIndexAt(indexID + _loc12_) + offset == getBasicQuadIndexAt(targetIndexID + _loc12_);
                     }
                     _loc12_++;
                  }
               }
               if(_loc16_)
               {
                  return;
               }
               target.switchToGenericData();
            }
            _loc15_ = sQuadData;
            _loc6_ = target._rawData;
            if((offset & 3) == 0)
            {
               indexID += 6 * offset / 4;
               offset = 0;
               ensureQuadDataCapacity(indexID + numIndices);
            }
         }
         else
         {
            if(target._useQuadLayout)
            {
               target.switchToGenericData();
            }
            _loc15_ = _rawData;
            _loc6_ = target._rawData;
         }
         _loc6_.position = targetIndexID * 2;
         if(offset == 0)
         {
            _loc6_.writeBytes(_loc15_,indexID * 2,numIndices * 2);
         }
         else
         {
            _loc15_.position = indexID * 2;
            while(numIndices > 1)
            {
               _loc11_ = _loc15_.readUnsignedInt();
               _loc10_ = ((_loc11_ & 0xFFFF0000) >> 16) + offset;
               _loc14_ = (_loc11_ & 0xFFFF) + offset;
               _loc6_.writeUnsignedInt(_loc10_ << 16 | _loc14_);
               numIndices -= 2;
            }
            if(numIndices)
            {
               _loc6_.writeShort(_loc15_.readUnsignedShort() + offset);
            }
         }
      }
      
      public function setIndex(indexID:int, index:uint) : void
      {
         if(_numIndices < indexID + 1)
         {
            numIndices = indexID + 1;
         }
         if(_useQuadLayout)
         {
            if(getBasicQuadIndexAt(indexID) == index)
            {
               return;
            }
            switchToGenericData();
         }
         _rawData.position = indexID * 2;
         _rawData.writeShort(index);
      }
      
      public function getIndex(indexID:int) : int
      {
         if(_useQuadLayout)
         {
            if(indexID < _numIndices)
            {
               return getBasicQuadIndexAt(indexID);
            }
            throw new EOFError();
         }
         _rawData.position = indexID * 2;
         return _rawData.readUnsignedShort();
      }
      
      public function offsetIndices(offset:int, indexID:int = 0, numIndices:int = -1) : void
      {
         var _loc5_:int = 0;
         if(numIndices < 0 || indexID + numIndices > _numIndices)
         {
            numIndices = _numIndices - indexID;
         }
         var _loc4_:int = indexID + numIndices;
         _loc5_ = indexID;
         while(_loc5_ < _loc4_)
         {
            setIndex(_loc5_,getIndex(_loc5_) + offset);
            _loc5_++;
         }
      }
      
      public function addTriangle(a:uint, b:uint, c:uint) : void
      {
         var _loc5_:Boolean = false;
         var _loc4_:Boolean = false;
         if(_useQuadLayout)
         {
            if(a == getBasicQuadIndexAt(_numIndices))
            {
               _loc5_ = (_numIndices & 1) != 0;
               _loc4_ = !_loc5_;
               if(_loc4_ && b == a + 1 && c == b + 1 || _loc5_ && c == a + 1 && b == c + 1)
               {
                  _numIndices += 3;
                  ensureQuadDataCapacity(_numIndices);
                  return;
               }
            }
            switchToGenericData();
         }
         _rawData.position = _numIndices * 2;
         _rawData.writeShort(a);
         _rawData.writeShort(b);
         _rawData.writeShort(c);
         _numIndices += 3;
      }
      
      public function addQuad(a:uint, b:uint, c:uint, d:uint) : void
      {
         if(_useQuadLayout)
         {
            if(a == getBasicQuadIndexAt(_numIndices) && b == a + 1 && c == b + 1 && d == c + 1)
            {
               _numIndices += 6;
               ensureQuadDataCapacity(_numIndices);
               return;
            }
            switchToGenericData();
         }
         _rawData.position = _numIndices * 2;
         _rawData.writeShort(a);
         _rawData.writeShort(b);
         _rawData.writeShort(c);
         _rawData.writeShort(b);
         _rawData.writeShort(d);
         _rawData.writeShort(c);
         _numIndices += 6;
      }
      
      public function toVector(out:Vector.<uint> = null) : Vector.<uint>
      {
         var _loc2_:int = 0;
         if(out == null)
         {
            out = new Vector.<uint>(_numIndices);
         }
         else
         {
            out.length = _numIndices;
         }
         var _loc3_:ByteArray = _useQuadLayout ? sQuadData : _rawData;
         _loc3_.position = 0;
         _loc2_ = 0;
         while(_loc2_ < _numIndices)
         {
            out[_loc2_] = _loc3_.readUnsignedShort();
            _loc2_++;
         }
         return out;
      }
      
      public function toString() : String
      {
         var _loc1_:String = StringUtil.format("[IndexData numIndices={0} indices=\"{1}\"]",_numIndices,toVector(sVector).join());
         sVector.length = 0;
         return _loc1_;
      }
      
      private function switchToGenericData() : void
      {
         if(_useQuadLayout)
         {
            _useQuadLayout = false;
            if(_rawData == null)
            {
               _rawData = new ByteArray();
               _rawData.endian = "littleEndian";
               _rawData.length = _initialCapacity * 2;
               _rawData.length = _numIndices * 2;
            }
            if(_numIndices)
            {
               _rawData.writeBytes(sQuadData,0,_numIndices * 2);
            }
         }
      }
      
      private function ensureQuadDataCapacity(numIndices:int) : void
      {
         var _loc2_:int = 0;
         if(sQuadDataNumIndices >= numIndices)
         {
            return;
         }
         var _loc4_:int = sQuadDataNumIndices / 6;
         var _loc3_:int = Math.ceil(numIndices / 6);
         sQuadData.endian = "littleEndian";
         sQuadData.position = sQuadData.length;
         sQuadDataNumIndices = _loc3_ * 6;
         _loc2_ = _loc4_;
         while(_loc2_ < _loc3_)
         {
            sQuadData.writeShort(4 * _loc2_);
            sQuadData.writeShort(4 * _loc2_ + 1);
            sQuadData.writeShort(4 * _loc2_ + 2);
            sQuadData.writeShort(4 * _loc2_ + 1);
            sQuadData.writeShort(4 * _loc2_ + 3);
            sQuadData.writeShort(4 * _loc2_ + 2);
            _loc2_++;
         }
      }
      
      public function createIndexBuffer(upload:Boolean = false, bufferUsage:String = "staticDraw") : IndexBuffer3D
      {
         var _loc3_:Context3D = Starling.context;
         if(_loc3_ == null)
         {
            throw new MissingContextError();
         }
         if(_numIndices == 0)
         {
            return null;
         }
         var _loc4_:IndexBuffer3D = _loc3_.createIndexBuffer(_numIndices,bufferUsage);
         if(upload)
         {
            uploadToIndexBuffer(_loc4_);
         }
         return _loc4_;
      }
      
      public function uploadToIndexBuffer(buffer:IndexBuffer3D, indexID:int = 0, numIndices:int = -1) : void
      {
         if(numIndices < 0 || indexID + numIndices > _numIndices)
         {
            numIndices = _numIndices - indexID;
         }
         if(numIndices > 0)
         {
            buffer.uploadFromByteArray(rawData,0,indexID,numIndices);
         }
      }
      
      public function trim() : void
      {
         if(_useQuadLayout)
         {
            return;
         }
         sTrimData.length = _rawData.length;
         sTrimData.position = 0;
         sTrimData.writeBytes(_rawData);
         _rawData.clear();
         _rawData.length = sTrimData.length;
         _rawData.writeBytes(sTrimData);
         sTrimData.clear();
      }
      
      public function get numIndices() : int
      {
         return _numIndices;
      }
      
      public function set numIndices(value:int) : void
      {
         if(value != _numIndices)
         {
            if(_useQuadLayout)
            {
               ensureQuadDataCapacity(value);
            }
            else
            {
               _rawData.length = value * 2;
            }
            if(value == 0)
            {
               _useQuadLayout = true;
            }
            _numIndices = value;
         }
      }
      
      public function get numTriangles() : int
      {
         return _numIndices / 3;
      }
      
      public function set numTriangles(value:int) : void
      {
         numIndices = value * 3;
      }
      
      public function get numQuads() : int
      {
         return _numIndices / 6;
      }
      
      public function set numQuads(value:int) : void
      {
         numIndices = value * 6;
      }
      
      public function get indexSizeInBytes() : int
      {
         return 2;
      }
      
      public function get useQuadLayout() : Boolean
      {
         return _useQuadLayout;
      }
      
      public function set useQuadLayout(value:Boolean) : void
      {
         if(value != _useQuadLayout)
         {
            if(value)
            {
               ensureQuadDataCapacity(_numIndices);
               _rawData.length = 0;
               _useQuadLayout = true;
            }
            else
            {
               switchToGenericData();
            }
         }
      }
      
      public function get rawData() : ByteArray
      {
         if(_useQuadLayout)
         {
            return sQuadData;
         }
         return _rawData;
      }
   }
}

