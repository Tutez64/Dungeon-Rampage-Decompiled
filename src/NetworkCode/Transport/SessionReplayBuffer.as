package NetworkCode.Transport
{
   import flash.utils.ByteArray;
   
   public final class SessionReplayBuffer
   {
      
      public static const CHUNK_BYTES:uint = 4096;
      
      private var mBytes:ByteArray;
      
      private var mAcknowledgedBytes:Number = 0;
      
      private var mForwardedBytes:Number = 0;
      
      private var mHandedBytes:Number = 0;
      
      public function SessionReplayBuffer()
      {
         super();
         mBytes = newBuffer();
      }
      
      private static function newBuffer() : ByteArray
      {
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.endian = "littleEndian";
         return _loc1_;
      }
      
      public function get sentBytes() : Number
      {
         return mAcknowledgedBytes + mBytes.length;
      }
      
      public function get acknowledgedBytes() : Number
      {
         return mAcknowledgedBytes;
      }
      
      public function get forwardedBytes() : Number
      {
         return mForwardedBytes;
      }
      
      public function get handedBytes() : Number
      {
         return mHandedBytes;
      }
      
      public function get unacknowledgedBytes() : Number
      {
         return mBytes.length;
      }
      
      public function get hasPending() : Boolean
      {
         return mForwardedBytes < sentBytes;
      }
      
      public function append(bytes:ByteArray) : Boolean
      {
         mBytes.position = mBytes.length;
         mBytes.writeBytes(bytes,0,bytes.length);
         return mBytes.length <= TransportSettings.sessionOutboundBufferBytes;
      }
      
      public function discardAcknowledged(acknowledged:Number) : void
      {
         if(acknowledged <= mAcknowledgedBytes)
         {
            return;
         }
         var _loc2_:uint = acknowledged - mAcknowledgedBytes;
         var _loc3_:ByteArray = newBuffer();
         if(mBytes.length > _loc2_)
         {
            _loc3_.writeBytes(mBytes,_loc2_,mBytes.length - _loc2_);
         }
         _loc3_.position = 0;
         mBytes = _loc3_;
         mAcknowledgedBytes = acknowledged;
         if(mForwardedBytes < mAcknowledgedBytes)
         {
            mForwardedBytes = mAcknowledgedBytes;
         }
      }
      
      public function rewindTo(forwarded:Number) : void
      {
         mForwardedBytes = forwarded;
      }
      
      public function nextChunk() : ByteArray
      {
         var _loc3_:Number = sentBytes - mForwardedBytes;
         if(_loc3_ <= 0)
         {
            return null;
         }
         var _loc1_:uint = _loc3_ > 4096 ? 4096 : uint(_loc3_);
         if(_loc1_ == 0)
         {
            return null;
         }
         var _loc2_:ByteArray = newBuffer();
         _loc2_.writeBytes(mBytes,uint(mForwardedBytes - mAcknowledgedBytes),_loc1_);
         _loc2_.position = 0;
         mForwardedBytes += _loc1_;
         mHandedBytes = Math.max(mHandedBytes,mForwardedBytes);
         return _loc2_;
      }
      
      public function clear() : void
      {
         mBytes.clear();
      }
   }
}

