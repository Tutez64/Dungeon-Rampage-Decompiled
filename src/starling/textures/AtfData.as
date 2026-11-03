package starling.textures
{
   import flash.utils.ByteArray;
   
   public class AtfData
   {
      
      private var _format:String;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _numTextures:int;
      
      private var _isCubeMap:Boolean;
      
      private var _data:ByteArray;
      
      public function AtfData(data:ByteArray)
      {
         var _loc4_:Boolean = false;
         var _loc2_:int = 0;
         super();
         if(!isAtfData(data))
         {
            throw new ArgumentError("Invalid ATF data");
         }
         if(data[6] == 255)
         {
            data.position = 12;
         }
         else
         {
            data.position = 6;
         }
         var _loc3_:uint = data.readUnsignedByte();
         switch(_loc3_ & 0x7F)
         {
            case 0:
            case 1:
               _format = "bgra";
               break;
            case 2:
            case 3:
            case 12:
               _format = "compressed";
               break;
            case 4:
            case 5:
            case 13:
               _format = "compressedAlpha";
               break;
            default:
               throw new Error("Invalid ATF format");
         }
         _width = Math.pow(2,data.readUnsignedByte());
         _height = Math.pow(2,data.readUnsignedByte());
         _numTextures = data.readUnsignedByte();
         _isCubeMap = (_loc3_ & 0x80) != 0;
         _data = data;
         if(data[5] != 0 && data[6] == 255)
         {
            _loc4_ = (data[5] & 1) == 1;
            _loc2_ = data[5] >> 1 & 0x7F;
            _numTextures = _loc4_ ? 1 : _loc2_;
         }
      }
      
      public static function isAtfData(data:ByteArray) : Boolean
      {
         var _loc2_:String = null;
         if(data.length < 3)
         {
            return false;
         }
         _loc2_ = String.fromCharCode(data[0],data[1],data[2]);
         return _loc2_ == "ATF";
      }
      
      public function get format() : String
      {
         return _format;
      }
      
      public function get width() : int
      {
         return _width;
      }
      
      public function get height() : int
      {
         return _height;
      }
      
      public function get numTextures() : int
      {
         return _numTextures;
      }
      
      public function get isCubeMap() : Boolean
      {
         return _isCubeMap;
      }
      
      public function get data() : ByteArray
      {
         return _data;
      }
   }
}

