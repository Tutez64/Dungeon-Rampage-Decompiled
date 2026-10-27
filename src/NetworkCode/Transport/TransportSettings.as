package NetworkCode.Transport
{
   import Brain.Utils.ConfigManager;
   
   public class TransportSettings
   {
      
      public static const DEFAULT_DROP_DETECT_SECONDS:Number = 15;
      
      public static const DEFAULT_RECONNECT_GRACE_SECONDS:Number = 60;
      
      public static const DEFAULT_HEARTBEAT_SECONDS:Number = 10;
      
      public static const DEFAULT_CONNECT_TIMEOUT_SECONDS:Number = 10;
      
      public static const DEFAULT_SESSIONS_ENABLED:Boolean = true;
      
      public static const DEFAULT_SESSION_OUTBOUND_BUFFER_BYTES:Number = 262144;
      
      public static const DEFAULT_SESSION_ACK_EVERY_BYTES:Number = 65536;
      
      public static const DEFAULT_SESSION_ACK_EVERY_SECONDS:Number = 5;
      
      public static const KEY_DROP_DETECT:String = "TransportDropDetectSeconds";
      
      public static const KEY_RECONNECT_GRACE:String = "TransportReconnectGraceSeconds";
      
      public static const KEY_HEARTBEAT:String = "TransportHeartbeatSeconds";
      
      public static const KEY_CONNECT_TIMEOUT:String = "TransportConnectTimeoutSeconds";
      
      public static const KEY_SESSIONS_ENABLED:String = "TransportSessionsEnabled";
      
      public static const KEY_SESSION_OUTBOUND_BUFFER:String = "TransportSessionOutboundBufferBytes";
      
      public static const KEY_SESSION_ACK_EVERY_BYTES:String = "TransportSessionAckEveryBytes";
      
      public static const KEY_SESSION_ACK_EVERY_SECONDS:String = "TransportSessionAckEverySeconds";
      
      private static var mDropDetectSeconds:Number = 15;
      
      private static var mReconnectGraceSeconds:Number = 60;
      
      private static var mHeartbeatSeconds:Number = 10;
      
      private static var mConnectTimeoutSeconds:Number = 10;
      
      private static var mSessionsEnabled:Boolean = true;
      
      private static var mSessionOutboundBufferBytes:Number = 262144;
      
      private static var mSessionAckEveryBytes:Number = 65536;
      
      private static var mSessionAckEverySeconds:Number = 5;
      
      public function TransportSettings()
      {
         super();
      }
      
      public static function get dropDetectSeconds() : Number
      {
         return mDropDetectSeconds;
      }
      
      public static function get reconnectGraceSeconds() : Number
      {
         return mReconnectGraceSeconds;
      }
      
      public static function get heartbeatSeconds() : Number
      {
         return mHeartbeatSeconds;
      }
      
      public static function get connectTimeoutSeconds() : Number
      {
         return mConnectTimeoutSeconds;
      }
      
      public static function get connectTimeoutMilliseconds() : uint
      {
         return uint(mConnectTimeoutSeconds * 1000);
      }
      
      public static function get sessionsEnabled() : Boolean
      {
         return mSessionsEnabled;
      }
      
      public static function get sessionOutboundBufferBytes() : Number
      {
         return mSessionOutboundBufferBytes;
      }
      
      public static function get sessionAckEveryBytes() : Number
      {
         return mSessionAckEveryBytes;
      }
      
      public static function get sessionAckEverySeconds() : Number
      {
         return mSessionAckEverySeconds;
      }
      
      public static function overrideForTest(dropDetectSeconds:Number = 0, reconnectGraceSeconds:Number = 0, connectTimeoutSeconds:Number = 0, sessionAckEveryBytes:Number = 0, sessionOutboundBufferBytes:Number = 0, sessionAckEverySeconds:Number = 0) : void
      {
         if(dropDetectSeconds > 0)
         {
            mDropDetectSeconds = dropDetectSeconds;
         }
         if(reconnectGraceSeconds > 0)
         {
            mReconnectGraceSeconds = reconnectGraceSeconds;
         }
         if(connectTimeoutSeconds > 0)
         {
            mConnectTimeoutSeconds = connectTimeoutSeconds;
         }
         if(sessionAckEveryBytes > 0)
         {
            mSessionAckEveryBytes = sessionAckEveryBytes;
         }
         if(sessionOutboundBufferBytes > 0)
         {
            mSessionOutboundBufferBytes = sessionOutboundBufferBytes;
         }
         if(sessionAckEverySeconds > 0)
         {
            mSessionAckEverySeconds = sessionAckEverySeconds;
         }
      }
      
      public static function applyOverrides(config:ConfigManager) : void
      {
         if(config == null)
         {
            return;
         }
         mDropDetectSeconds = positiveOr(config.getConfigNumber("TransportDropDetectSeconds",15),15);
         mReconnectGraceSeconds = positiveOr(config.getConfigNumber("TransportReconnectGraceSeconds",60),60);
         mHeartbeatSeconds = positiveOr(config.getConfigNumber("TransportHeartbeatSeconds",10),10);
         mConnectTimeoutSeconds = positiveOr(config.getConfigNumber("TransportConnectTimeoutSeconds",10),10);
         mSessionsEnabled = config.getConfigBoolean("TransportSessionsEnabled",true);
         mSessionOutboundBufferBytes = positiveOr(config.getConfigNumber("TransportSessionOutboundBufferBytes",262144),262144);
         mSessionAckEveryBytes = positiveOr(config.getConfigNumber("TransportSessionAckEveryBytes",65536),65536);
         mSessionAckEverySeconds = positiveOr(config.getConfigNumber("TransportSessionAckEverySeconds",5),5);
      }
      
      public static function overrideSessionsEnabledForTest(enabled:Boolean) : void
      {
         mSessionsEnabled = enabled;
      }
      
      public static function resetToDefaults() : void
      {
         mDropDetectSeconds = 15;
         mReconnectGraceSeconds = 60;
         mHeartbeatSeconds = 10;
         mConnectTimeoutSeconds = 10;
         mSessionsEnabled = true;
         mSessionOutboundBufferBytes = 262144;
         mSessionAckEveryBytes = 65536;
         mSessionAckEverySeconds = 5;
      }
      
      private static function positiveOr(value:Number, fallback:Number) : Number
      {
         return isNaN(value) || value <= 0 ? fallback : value;
      }
   }
}

