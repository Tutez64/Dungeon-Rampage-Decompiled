package NetworkCode.Transport
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.net.SecureSocket;
   import flash.system.MessageChannel;
   import flash.system.Worker;
   import flash.system.WorkerDomain;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class TlsSocketTransport extends EventDispatcher implements IGameTransport
   {
      
      private static const MAX_WORKERS:int = 4;
      
      private static var liveWorkers:int = 0;
      
      private static var reaper:Timer;
      
      private static const WorkerBytes:Class = TlsSocketWorker_swf;
      
      private static const workers:Dictionary = new Dictionary();
      
      private var mHost:String;
      
      private var mPort:int;
      
      private var mEnforceServerCertificate:Boolean;
      
      private var mWorker:Worker;
      
      private var mCommands:MessageChannel;
      
      private var mReplies:MessageChannel;
      
      private var mConnected:Boolean;
      
      private var mFinished:Boolean;
      
      private var mDrainingReplies:Boolean;
      
      public function TlsSocketTransport(host:String, port:int, enforceServerCertificate:Boolean)
      {
         super();
         mHost = host;
         mPort = port;
         mEnforceServerCertificate = enforceServerCertificate;
      }
      
      private static function reapWorkers(event:TimerEvent = null) : void
      {
         var _loc3_:Worker = null;
         var _loc2_:TlsSocketTransport = null;
         for(var _loc4_:Object in workers)
         {
            _loc3_ = _loc4_ as Worker;
            if(_loc3_.state == "terminated")
            {
               _loc2_ = workers[_loc3_] as TlsSocketTransport;
               if(_loc2_ != null)
               {
                  _loc2_.onWorkerState(null);
               }
               if(_loc2_ == null || _loc2_.mFinished)
               {
                  releaseWorker(_loc3_);
               }
            }
         }
      }
      
      private static function releaseWorker(worker:Worker) : void
      {
         if(workers[worker])
         {
            delete workers[worker];
            liveWorkers = liveWorkers - 1;
         }
         if(liveWorkers == 0 && reaper != null)
         {
            reaper.stop();
         }
         var _loc3_:MessageChannel = worker.getSharedProperty("commands") as MessageChannel;
         var _loc2_:MessageChannel = worker.getSharedProperty("replies") as MessageChannel;
         if(_loc3_ != null)
         {
            _loc3_.close();
         }
         if(_loc2_ != null)
         {
            _loc2_.close();
         }
         worker.setSharedProperty("commands",null);
         worker.setSharedProperty("replies",null);
         worker.setSharedProperty("config",null);
      }
      
      private static function element(reply:Array, index:int) : String
      {
         return reply.length > index && reply[index] != null ? String(reply[index]) : "";
      }
      
      public function get name() : String
      {
         return "tlsSocket " + mHost + ":" + mPort;
      }
      
      public function get connected() : Boolean
      {
         return mConnected && !mFinished;
      }
      
      public function get supportsSessions() : Boolean
      {
         return false;
      }
      
      public function sendText(text:String) : void
      {
         throw new Error("TlsSocketTransport carries no text frames; it cannot resume a session.");
      }
      
      public function connect() : void
      {
         var _loc1_:Worker = null;
         if(mWorker != null || mFinished)
         {
            return;
         }
         if(!SecureSocket.isSupported || !Worker.isSupported)
         {
            fail(603,"Secure connections are not supported by this runtime.");
            return;
         }
         reapWorkers();
         if(liveWorkers >= 4)
         {
            fail(602,"Previous connections are still closing; please retry shortly.");
            return;
         }
         try
         {
            mWorker = createWorker();
            mCommands = Worker.current.createMessageChannel(mWorker);
            mReplies = mWorker.createMessageChannel(Worker.current);
            mWorker.setSharedProperty("commands",mCommands);
            mWorker.setSharedProperty("replies",mReplies);
            mWorker.setSharedProperty("config",{
               "host":mHost,
               "port":mPort,
               "enforceCertificate":mEnforceServerCertificate,
               "timeout":TransportSettings.connectTimeoutMilliseconds
            });
            mReplies.addEventListener("channelMessage",onReply);
            mWorker.addEventListener("workerState",onWorkerState);
            workers[mWorker] = this;
            liveWorkers = liveWorkers + 1;
            if(reaper == null)
            {
               reaper = new Timer(100);
               reaper.addEventListener("timer",reapWorkers);
            }
            reaper.start();
            mWorker.start();
         }
         catch(error:Error)
         {
            _loc1_ = mWorker;
            fail(602,error.message);
            if(_loc1_ != null)
            {
               _loc1_.terminate();
               releaseWorker(_loc1_);
            }
         }
      }
      
      public function send(bytes:ByteArray) : void
      {
         if(!connected || bytes == null || bytes.length == 0)
         {
            return;
         }
         try
         {
            mCommands.send(["send",bytes]);
         }
         catch(error:Error)
         {
            fail(602,error.message);
         }
      }
      
      public function close() : void
      {
         if(mFinished)
         {
            return;
         }
         mFinished = true;
         mConnected = false;
         if(mReplies != null)
         {
            mReplies.removeEventListener("channelMessage",onReply);
         }
         if(mWorker != null)
         {
            mWorker.removeEventListener("workerState",onWorkerState);
            if(workers[mWorker])
            {
               workers[mWorker] = true;
            }
            try
            {
               mCommands.send(["close"]);
            }
            catch(error:Error)
            {
               mWorker.terminate();
            }
         }
         mWorker = null;
         mCommands = null;
         mReplies = null;
      }
      
      public function abandon() : void
      {
         close();
      }
      
      protected function createWorker() : Worker
      {
         return WorkerDomain.current.createWorker(new WorkerBytes() as ByteArray,true);
      }
      
      private function onReply(event:Event) : void
      {
         var _loc3_:Array = null;
         var _loc2_:ByteArray = null;
         if(mFinished || mDrainingReplies)
         {
            return;
         }
         mDrainingReplies = true;
         try
         {
            while(!mFinished && mReplies.messageAvailable)
            {
               _loc3_ = mReplies.receive() as Array;
               switch(_loc3_[0])
               {
                  case "connected":
                     mConnected = true;
                     dispatchEvent(GameTransportEvent.connectedEvent());
                     break;
                  case "data":
                     _loc2_ = _loc3_[1] as ByteArray;
                     _loc2_.endian = "littleEndian";
                     _loc2_.position = 0;
                     dispatchEvent(GameTransportEvent.dataEvent(_loc2_));
                     break;
                  case "failed":
                     fail(_loc3_[1],_loc3_[2],element(_loc3_,3),element(_loc3_,4));
                     break;
                  case "closed":
                     close();
                     dispatchEvent(GameTransportEvent.closedEvent(0,"","server"));
               }
            }
         }
         finally
         {
            mDrainingReplies = false;
         }
      }
      
      private function onWorkerState(event:Event) : void
      {
         if(!mFinished && mWorker.state == "terminated")
         {
            onReply(null);
            if(!mFinished && !mDrainingReplies && !mReplies.messageAvailable)
            {
               fail(602,"TLS worker stopped unexpectedly.");
            }
         }
      }
      
      private function fail(code:uint, text:String, certificateStatus:String = "", certificateDetail:String = "") : void
      {
         if(mFinished)
         {
            return;
         }
         close();
         dispatchEvent(GameTransportEvent.failedEvent(code,text,certificateStatus,certificateDetail));
      }
   }
}

