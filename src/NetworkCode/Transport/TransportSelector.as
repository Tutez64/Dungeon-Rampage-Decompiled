package NetworkCode.Transport
{
   public class TransportSelector
   {
      
      public static const KIND_TLS_SOCKET:String = "tlsSocket";
      
      public static const KIND_WSS:String = "wss";
      
      private var mEndpoints:GameEndpoints;
      
      private var mExperimentalWebSocketReconnects:Boolean;
      
      private var mCandidates:Vector.<TransportCandidate>;
      
      private var mCredentialSource:Function;
      
      public function TransportSelector(endpoints:GameEndpoints, experimentalWebSocketReconnects:Boolean, credentialSource:Function = null)
      {
         super();
         mEndpoints = endpoints;
         mExperimentalWebSocketReconnects = experimentalWebSocketReconnects;
         mCredentialSource = credentialSource;
         mCandidates = new Vector.<TransportCandidate>();
         if(endpoints == null)
         {
            return;
         }
         if(!experimentalWebSocketReconnects)
         {
            addTlsSocket();
            addWebSocket();
         }
         else
         {
            addWebSocket();
            addTlsSocket();
         }
      }
      
      public static function createWssTransport(url:String, enforce:Boolean) : IGameTransport
      {
         return new NativeWebSocketTransport(url,enforce);
      }
      
      public function get count() : int
      {
         return mCandidates.length;
      }
      
      public function candidateAt(index:int) : TransportCandidate
      {
         if(index < 0 || index >= mCandidates.length)
         {
            return null;
         }
         return mCandidates[index];
      }
      
      public function describe() : String
      {
         var _loc2_:int = 0;
         if(mCandidates.length == 0)
         {
            return "none: this environment offers no transport this player can dial";
         }
         var _loc1_:Array = [];
         _loc2_ = 0;
         while(_loc2_ < mCandidates.length)
         {
            _loc1_.push(mCandidates[_loc2_].name);
            _loc2_++;
         }
         return _loc1_.join(", ");
      }
      
      public function createTransport(index:int) : IGameTransport
      {
         var enforce:Boolean;
         var candidate:TransportCandidate = candidateAt(index);
         if(candidate == null)
         {
            return null;
         }
         enforce = mEndpoints.enforceServerCertificate;
         switch(candidate.kind)
         {
            case "wss":
               return withSessions(candidate.url,function(param1:String):IGameTransport
               {
                  return createWssTransport(param1,enforce);
               });
            case "tlsSocket":
               return new TlsSocketTransport(candidate.host,candidate.port,enforce);
            default:
               return null;
         }
      }
      
      private function withSessions(url:String, factory:Function) : IGameTransport
      {
         var _loc4_:IGameTransport = factory(url) as IGameTransport;
         if(_loc4_ == null || !_loc4_.supportsSessions)
         {
            return _loc4_;
         }
         var _loc3_:Function = mExperimentalWebSocketReconnects && TransportSettings.sessionsEnabled ? factory : null;
         return new SessionTransport(url,_loc3_,_loc4_,mCredentialSource);
      }
      
      private function addWebSocket() : void
      {
         var _loc1_:String = mEndpoints.wssUrl;
         if(_loc1_ == "")
         {
            return;
         }
         mCandidates.push(new TransportCandidate("wss","",0,_loc1_));
      }
      
      private function addTlsSocket() : void
      {
         if(!mEndpoints.tlsOffered)
         {
            return;
         }
         mCandidates.push(new TransportCandidate("tlsSocket",mEndpoints.address,mEndpoints.port));
      }
   }
}

