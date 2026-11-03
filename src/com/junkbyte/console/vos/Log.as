package com.junkbyte.console.vos
{
   import com.junkbyte.console.utils.FlashRegex;
   import flash.Boot;
   import flash.utils.ByteArray;
   
   public class Log
   {
      
      public var timeStr:String;
      
      public var time:uint;
      
      public var text:String;
      
      public var repeat:Boolean;
      
      public var priority:int;
      
      public var prev:Log;
      
      public var next:Log;
      
      public var lineStr:String;
      
      public var line:uint;
      
      public var html:Boolean;
      
      public var chStr:String;
      
      public var ch:String;
      
      public function Log(txt:String = undefined, cc:String = undefined, pp:int = 0, repeating:Boolean = false, ishtml:Boolean = false)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         text = txt;
         ch = cc;
         priority = pp;
         repeat = repeating;
         html = ishtml;
      }
      
      public static function FromBytes(bytes:ByteArray) : Log
      {
         var _loc2_:String = bytes.readUTFBytes(bytes.readUnsignedInt());
         var _loc3_:String = bytes.readUTF();
         var _loc4_:int = bytes.readInt();
         var _loc5_:Boolean = bytes.readBoolean();
         return new Log(_loc2_,_loc3_,_loc4_,_loc5_,true);
      }
      
      public function toString() : String
      {
         return "[" + ch + "] " + plainText();
      }
      
      public function toBytes(bytes:ByteArray) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(text);
         bytes.writeUnsignedInt(_loc2_.length);
         bytes.writeBytes(_loc2_);
         bytes.writeUTF(ch);
         bytes.writeInt(priority);
         bytes.writeBoolean(repeat);
      }
      
      public function plainText() : String
      {
         var _loc1_:String = text;
         _loc1_ = FlashRegex.replace(_loc1_,new EReg("<.*?>","g"),"");
         _loc1_ = FlashRegex.replace(_loc1_,new EReg("&lt;","g"),"<");
         return FlashRegex.replace(_loc1_,new EReg("&gt;","g"),">");
      }
      
      public function clone() : Log
      {
         var _loc1_:Log = new Log(text,ch,priority,repeat,html);
         _loc1_.line = line;
         _loc1_.time = time;
         return _loc1_;
      }
   }
}

