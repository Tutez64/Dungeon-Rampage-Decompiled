package com.junkbyte.console.vos
{
   import flash.utils.ByteArray;
   
   public class Log
   {
      
      public var line:uint;
      
      public var text:String;
      
      public var ch:String;
      
      public var priority:int;
      
      public var repeat:Boolean;
      
      public var html:Boolean;
      
      public var time:uint;
      
      public var timeStr:String;
      
      public var lineStr:String;
      
      public var chStr:String;
      
      public var next:Log;
      
      public var prev:Log;
      
      public function Log(txt:String, cc:String, pp:int, repeating:Boolean = false, ishtml:Boolean = false)
      {
         super();
         this.text = txt;
         this.ch = cc;
         this.priority = pp;
         this.repeat = repeating;
         this.html = ishtml;
      }
      
      public static function FromBytes(bytes:ByteArray) : Log
      {
         var _loc2_:String = bytes.readUTFBytes(bytes.readUnsignedInt());
         var _loc3_:String = bytes.readUTF();
         var _loc4_:int = bytes.readInt();
         var _loc5_:Boolean = bytes.readBoolean();
         return new Log(_loc2_,_loc3_,_loc4_,_loc5_,true);
      }
      
      public function toBytes(bytes:ByteArray) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(this.text);
         bytes.writeUnsignedInt(_loc2_.length);
         bytes.writeBytes(_loc2_);
         bytes.writeUTF(this.ch);
         bytes.writeInt(this.priority);
         bytes.writeBoolean(this.repeat);
      }
      
      public function plainText() : String
      {
         return this.text.replace(/<.*?>/g,"").replace(/&lt;/g,"<").replace(/&gt;/g,">");
      }
      
      public function toString() : String
      {
         return "[" + this.ch + "] " + this.plainText();
      }
      
      public function clone() : Log
      {
         var _loc1_:Log = new Log(this.text,this.ch,this.priority,this.repeat,this.html);
         _loc1_.line = this.line;
         _loc1_.time = this.time;
         return _loc1_;
      }
   }
}

