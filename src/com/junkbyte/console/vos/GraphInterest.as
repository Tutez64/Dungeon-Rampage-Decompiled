package com.junkbyte.console.vos
{
   import com.junkbyte.console.core.Executer;
   import flash.utils.ByteArray;
   
   public class GraphInterest
   {
      
      private var _ref:WeakRef;
      
      public var _prop:String;
      
      private var useExec:Boolean;
      
      public var key:String;
      
      public var col:Number;
      
      public var v:Number;
      
      public var avg:Number;
      
      public function GraphInterest(keystr:String = "", color:Number = 0)
      {
         super();
         this.col = color;
         this.key = keystr;
      }
      
      public static function FromBytes(bytes:ByteArray) : GraphInterest
      {
         var _loc2_:GraphInterest = new GraphInterest(bytes.readUTF(),bytes.readUnsignedInt());
         _loc2_.v = bytes.readDouble();
         _loc2_.avg = bytes.readDouble();
         return _loc2_;
      }
      
      public function setObject(object:Object, property:String) : Number
      {
         this._ref = new WeakRef(object);
         this._prop = property;
         this.useExec = this._prop.search(/[^\w\d]/) >= 0;
         this.v = this.getCurrentValue();
         this.avg = this.v;
         return this.v;
      }
      
      public function get obj() : Object
      {
         return this._ref != null ? this._ref.reference : undefined;
      }
      
      public function get prop() : String
      {
         return this._prop;
      }
      
      public function getCurrentValue() : Number
      {
         return this.useExec ? Number(Executer.Exec(this.obj,this._prop)) : Number(this.obj[this._prop]);
      }
      
      public function setValue(val:Number, averaging:uint = 0) : void
      {
         this.v = val;
         if(averaging > 0)
         {
            if(isNaN(this.avg))
            {
               this.avg = this.v;
            }
            else
            {
               this.avg += (this.v - this.avg) / averaging;
            }
         }
      }
      
      public function toBytes(bytes:ByteArray) : void
      {
         bytes.writeUTF(this.key);
         bytes.writeUnsignedInt(this.col);
         bytes.writeDouble(this.v);
         bytes.writeDouble(this.avg);
      }
   }
}

