package com.junkbyte.console.vos
{
   import com.junkbyte.console.core.Executer;
   import com.junkbyte.console.utils.FlashRegex;
   import flash.Boot;
   import flash.utils.ByteArray;
   
   public class GraphInterest
   {
      
      public var v:Number;
      
      public var useExec:Boolean;
      
      public var key:String;
      
      public var col:int;
      
      public var avg:Number;
      
      public var _ref:WeakRef;
      
      public var _prop:String;
      
      public function GraphInterest(keystr:String = undefined, color:int = 0)
      {
         if(keystr == null)
         {
            keystr = "";
         }
         if(Boot.skip_constructor)
         {
            return;
         }
         avg = Number(Number.NaN);
         v = Number(Number.NaN);
         col = 0;
         key = null;
         useExec = false;
         _prop = null;
         _ref = null;
         col = color;
         key = keystr;
      }
      
      public static function FromBytes(bytes:ByteArray) : GraphInterest
      {
         var _loc2_:GraphInterest = new GraphInterest(bytes.readUTF(),bytes.readUnsignedInt());
         _loc2_.v = bytes.readDouble();
         _loc2_.avg = bytes.readDouble();
         return _loc2_;
      }
      
      public function toBytes(bytes:ByteArray) : void
      {
         bytes.writeUTF(key);
         bytes.writeUnsignedInt(col);
         bytes.writeDouble(v);
         bytes.writeDouble(avg);
      }
      
      public function setValue(val:Number, averaging:uint = 0) : void
      {
         var _loc3_:Number = NaN;
         v = val;
         if(averaging > 0)
         {
            _loc3_ = avg;
            if(_loc3_ != _loc3_)
            {
               avg = v;
            }
            else
            {
               avg += (v - avg) / averaging;
            }
         }
      }
      
      public function setObject(object:*, property:String) : Number
      {
         _ref = new WeakRef(object);
         _prop = property;
         useExec = FlashRegex.search(_prop,new EReg("[^\\w\\d]","")) >= 0;
         v = getCurrentValue();
         return v;
      }
      
      public function get_prop() : String
      {
         return _prop;
      }
      
      public function get prop() : String
      {
         return get_prop();
      }
      
      public function get_obj() : *
      {
         if(_ref != null)
         {
            return _ref.get_reference();
         }
         return null;
      }
      
      public function get obj() : *
      {
         return get_obj();
      }
      
      public function getCurrentValue() : Number
      {
         if(useExec)
         {
            return Executer.Exec(get_obj(),_prop);
         }
         return Number(get_obj()[_prop]);
      }
   }
}

