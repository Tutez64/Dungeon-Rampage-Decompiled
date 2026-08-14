package com.facebook.graph.utils
{
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   
   public class PostRequest
   {
      
      public var boundary:String = "-----";
      
      protected var postData:ByteArray;
      
      public function PostRequest()
      {
         super();
         this.createPostData();
      }
      
      public function createPostData() : void
      {
         this.postData = new ByteArray();
         this.postData.endian = Endian.BIG_ENDIAN;
      }
      
      public function writePostData(name:String, value:String) : void
      {
         var _loc3_:String = null;
         this.writeBoundary();
         this.writeLineBreak();
         _loc3_ = "Content-Disposition: form-data; name=\"" + name + "\"";
         var _loc4_:uint = uint(_loc3_.length);
         var _loc5_:Number = 0;
         while(_loc5_ < _loc4_)
         {
            this.postData.writeByte(_loc3_.charCodeAt(_loc5_));
            _loc5_++;
         }
         this.writeLineBreak();
         this.writeLineBreak();
         this.postData.writeUTFBytes(value);
         this.writeLineBreak();
      }
      
      public function writeFileData(filename:String, fileData:ByteArray, contentType:String) : void
      {
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:uint = 0;
         this.writeBoundary();
         this.writeLineBreak();
         _loc4_ = "Content-Disposition: form-data; name=\"" + filename + "\"; filename=\"" + filename + "\";";
         _loc5_ = _loc4_.length;
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            this.postData.writeByte(_loc4_.charCodeAt(_loc6_));
            _loc6_++;
         }
         this.postData.writeUTFBytes(filename);
         this.writeQuotationMark();
         this.writeLineBreak();
         _loc4_ = contentType || "application/octet-stream";
         _loc5_ = _loc4_.length;
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            this.postData.writeByte(_loc4_.charCodeAt(_loc6_));
            _loc6_++;
         }
         this.writeLineBreak();
         this.writeLineBreak();
         fileData.position = 0;
         this.postData.writeBytes(fileData,0,fileData.length);
         this.writeLineBreak();
      }
      
      public function getPostData() : ByteArray
      {
         this.postData.position = 0;
         return this.postData;
      }
      
      public function close() : void
      {
         this.writeBoundary();
         this.writeDoubleDash();
      }
      
      protected function writeLineBreak() : void
      {
         this.postData.writeShort(3338);
      }
      
      protected function writeQuotationMark() : void
      {
         this.postData.writeByte(34);
      }
      
      protected function writeDoubleDash() : void
      {
         this.postData.writeShort(11565);
      }
      
      protected function writeBoundary() : void
      {
         this.writeDoubleDash();
         var _loc1_:uint = uint(this.boundary.length);
         var _loc2_:uint = 0;
         while(_loc2_ < _loc1_)
         {
            this.postData.writeByte(this.boundary.charCodeAt(_loc2_));
            _loc2_++;
         }
      }
   }
}

