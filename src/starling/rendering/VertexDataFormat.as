package starling.rendering
{
   import flash.display3D.VertexBuffer3D;
   import flash.utils.Dictionary;
   import starling.core.Starling;
   import starling.utils.StringUtil;
   
   public class VertexDataFormat
   {
      
      private static var sFormats:Dictionary = new Dictionary();
      
      private var _format:String;
      
      private var _vertexSize:int;
      
      private var _attributes:Vector.<VertexDataAttribute>;
      
      public function VertexDataFormat()
      {
         super();
         _attributes = new Vector.<VertexDataAttribute>();
      }
      
      public static function fromString(format:String) : VertexDataFormat
      {
         var _loc2_:VertexDataFormat = null;
         var _loc3_:String = null;
         if(format in sFormats)
         {
            return sFormats[format];
         }
         _loc2_ = new VertexDataFormat();
         _loc2_.parseFormat(format);
         _loc3_ = _loc2_._format;
         if(_loc3_ in sFormats)
         {
            _loc2_ = sFormats[_loc3_];
         }
         sFormats[format] = _loc2_;
         sFormats[_loc3_] = _loc2_;
         return _loc2_;
      }
      
      public function extend(format:String) : VertexDataFormat
      {
         return fromString(_format + ", " + format);
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
      
      public function getFormat(attrName:String) : String
      {
         return getAttribute(attrName).format;
      }
      
      public function getName(attrIndex:int) : String
      {
         return _attributes[attrIndex].name;
      }
      
      public function hasAttribute(attrName:String) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(_attributes.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(_attributes[_loc3_].name == attrName)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function setVertexBufferAt(index:int, buffer:VertexBuffer3D, attrName:String) : void
      {
         var _loc4_:VertexDataAttribute = getAttribute(attrName);
         Starling.context.setVertexBufferAt(index,buffer,_loc4_.offset / 4,_loc4_.format);
      }
      
      private function parseFormat(format:String) : void
      {
         var _loc5_:Array = null;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc10_:String = null;
         var _loc7_:Array = null;
         var _loc9_:String = null;
         var _loc2_:String = null;
         var _loc8_:VertexDataAttribute = null;
         if(format != null && format != "")
         {
            _attributes.length = 0;
            _format = "";
            _loc5_ = format.split(",");
            _loc4_ = int(_loc5_.length);
            _loc3_ = 0;
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               _loc10_ = _loc5_[_loc6_];
               _loc7_ = _loc10_.split(":");
               if(_loc7_.length != 2)
               {
                  throw new ArgumentError("Missing colon: " + _loc10_);
               }
               _loc9_ = StringUtil.trim(_loc7_[0]);
               _loc2_ = StringUtil.trim(_loc7_[1]);
               if(_loc9_.length == 0 || _loc2_.length == 0)
               {
                  throw new ArgumentError("Invalid format string: " + _loc10_);
               }
               _loc8_ = new VertexDataAttribute(_loc9_,_loc2_,_loc3_);
               _loc3_ += _loc8_.size;
               _format += (_loc6_ == 0 ? "" : ", ") + _loc8_.name + ":" + _loc8_.format;
               _attributes[_attributes.length] = _loc8_;
               _loc6_++;
            }
            _vertexSize = _loc3_;
         }
         else
         {
            _format = "";
         }
      }
      
      public function toString() : String
      {
         return _format;
      }
      
      internal function getAttribute(attrName:String) : VertexDataAttribute
      {
         var _loc4_:VertexDataAttribute = null;
         var _loc3_:int = 0;
         var _loc2_:int = int(_attributes.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = _attributes[_loc3_];
            if(_loc4_.name == attrName)
            {
               return _loc4_;
            }
            _loc3_++;
         }
         return null;
      }
      
      internal function get attributes() : Vector.<VertexDataAttribute>
      {
         return _attributes;
      }
      
      public function get formatString() : String
      {
         return _format;
      }
      
      public function get vertexSize() : int
      {
         return _vertexSize;
      }
      
      public function get vertexSizeIn32Bits() : int
      {
         return _vertexSize / 4;
      }
      
      public function get numAttributes() : int
      {
         return _attributes.length;
      }
   }
}

