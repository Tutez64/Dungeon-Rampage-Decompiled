package NetworkCode.Transport
{
   import Brain.Logger.Logger;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   
   public class SessionTransport extends EventDispatcher implements IGameTransport
   {
      
      public static const STATE_IDLE:String = "idle";
      
      public static const STATE_HANDSHAKING:String = "handshaking";
      
      public static const STATE_OPEN:String = "open";
      
      public static const STATE_WAITING:String = "waiting";
      
      public static const STATE_RESUMING:String = "resuming";
      
      public static const STATE_FINISHED:String = "finished";
      
      public static const REPLAY_BUFFER_FULL:String = "client replay buffer full";
      
      public static const BAD_CONTROL_MESSAGE:String = "bad control message from the bridge";
      
      private static const DROP_KIND_SOCKET:String = "socket";
      
      private static const DROP_KIND_SILENCE:String = "silence";
      
      private static const FINAL_ATTEMPT_SPREAD:Number = 0.05;
      
      private static const MAX_DEAD_END_ATTEMPTS:int = 3;
      
      private static const DEAD_END_FLOOR_MILLISECONDS:int = 10000;
      
      private static const SILENCE_TICK_MILLISECONDS:int = 1000;
      
      private static const BACKOFF_MILLISECONDS:Array = [1000,2000,4000,8000,10000];
      
      private static const JITTER_FRACTIONS:Array = [0,0,0.1,0.25,0.25];
      
      private var mBaseUrl:String;
      
      private var mInnerFactory:Function;
      
      private var mInnerName:String;
      
      private var mInner:IGameTransport;
      
      private var mState:String = "idle";
      
      private var mToken:String;
      
      private var mPod:int = 0;
      
      private var mBridgeGraceMilliseconds:Number = 0;
      
      private var mReceivedBytes:Number = 0;
      
      private var mAckedBytes:Number = 0;
      
      private var mLastInboundMilliseconds:int = 0;
      
      private var mReplay:SessionReplayBuffer;
      
      private var mAckTimer:Timer;
      
      private var mSilenceTimer:Timer;
      
      private var mAttemptTimer:Timer;
      
      private var mBackoffTimer:Timer;
      
      private var mInsideConnect:Boolean = false;
      
      private var mSuppressed:Boolean = false;
      
      private var mDropAtMilliseconds:int = 0;
      
      private var mDropKind:String;
      
      private var mResumeAttempts:int = 0;
      
      private var mDeadEndAttempts:int = 0;
      
      private var mFinalAttemptScheduled:Boolean = false;
      
      private var mReconnectStartedAtMilliseconds:int = 0;
      
      private var mAttemptConnected:Boolean = false;
      
      private var mLastCode:int = 0;
      
      private var mLastReason:String = "";
      
      private var mGoneReason:String;
      
      private var mCredentialSource:Function;
      
      private var mWarnedAboutCredential:Boolean = false;
      
      public function SessionTransport(baseUrl:String, innerFactory:Function, firstInner:IGameTransport, credentialSource:Function = null)
      {
         super();
         mBaseUrl = baseUrl;
         mCredentialSource = credentialSource;
         mInnerFactory = innerFactory;
         mInner = firstInner;
         mInnerName = firstInner != null ? firstInner.name : baseUrl;
         mReplay = new SessionReplayBuffer();
      }
      
      public static function resumeUrlFor(baseUrl:String, pod:int) : String
      {
         var _loc3_:String = baseUrl;
         while(_loc3_.length > 0 && _loc3_.charAt(_loc3_.length - 1) == "/")
         {
            _loc3_ = _loc3_.substr(0,_loc3_.length - 1);
         }
         return _loc3_ + "/" + pod;
      }
      
      private static function shorten(text:String) : String
      {
         if(text == null)
         {
            return "null";
         }
         return text.length <= 200 ? text : text.substr(0,200) + "... (" + text.length + " chars)";
      }
      
      private static function restart(timer:Timer, delay:Number, repeatCount:int, handler:Function) : Timer
      {
         if(timer == null)
         {
            timer = new Timer(delay,repeatCount);
            timer.addEventListener("timer",handler);
         }
         timer.reset();
         timer.delay = delay;
         timer.start();
         return timer;
      }
      
      private static function stopIfAny(timer:Timer) : void
      {
         if(timer != null)
         {
            timer.stop();
         }
      }
      
      public static function backoffMilliseconds(attempt:int) : int
      {
         var _loc3_:int = attempt - 1;
         if(_loc3_ < 0)
         {
            _loc3_ = 0;
         }
         if(_loc3_ >= BACKOFF_MILLISECONDS.length)
         {
            _loc3_ = BACKOFF_MILLISECONDS.length - 1;
         }
         var _loc2_:Number = Number(BACKOFF_MILLISECONDS[_loc3_]);
         _loc2_ += _loc2_ * Number(JITTER_FRACTIONS[_loc3_]) * Math.random();
         return int(_loc2_);
      }
      
      public static function finalAttemptMilliseconds(remaining:int, grace:int) : int
      {
         var _loc3_:Number = remaining - grace * 0.05 * Math.random();
         return _loc3_ < 0 ? 0 : int(_loc3_);
      }
      
      public function get name() : String
      {
         return mInnerName + " (session)";
      }
      
      public function get connected() : Boolean
      {
         return mState == "open" || mState == "waiting" || mState == "resuming";
      }
      
      public function get supportsSessions() : Boolean
      {
         return true;
      }
      
      public function get resumeEnabled() : Boolean
      {
         return mInnerFactory != null;
      }
      
      public function get state() : String
      {
         return mState;
      }
      
      public function get sessionToken() : String
      {
         return mToken;
      }
      
      public function get podOrdinal() : int
      {
         return mPod;
      }
      
      public function get receivedBytes() : Number
      {
         return mReceivedBytes;
      }
      
      public function get sentBytes() : Number
      {
         return mReplay.sentBytes;
      }
      
      public function get unacknowledgedBytes() : Number
      {
         return mReplay.unacknowledgedBytes;
      }
      
      public function get resumeAttempts() : int
      {
         return mResumeAttempts;
      }
      
      public function get helloMessage() : String
      {
         return SessionProtocol.helloMessageFor(currentCredential());
      }
      
      public function connect() : void
      {
         if(mState != "idle")
         {
            return;
         }
         if(mInner == null)
         {
            finishWithFailure(602,"No transport to open the session on.");
            return;
         }
         mState = "handshaking";
         attachInner(mInner);
         mInsideConnect = true;
         try
         {
            mInner.connect();
         }
         catch(error:Error)
         {
            finishWithFailure(602,error.message);
            return;
         }
         finally
         {
            mInsideConnect = false;
         }
         if(mState == "handshaking")
         {
            armAttemptWatchdog();
         }
      }
      
      private function attachInner(transport:IGameTransport) : void
      {
         mInner = transport;
         mInner.addEventListener("gameTransportConnected",onInnerConnected);
         mInner.addEventListener("gameTransportData",onInnerData);
         mInner.addEventListener("gameTransportText",onInnerText);
         mInner.addEventListener("gameTransportClosed",onInnerClosed);
         mInner.addEventListener("gameTransportFailed",onInnerFailed);
      }
      
      private function detachInner(cleanly:Boolean) : void
      {
         if(mInner == null)
         {
            return;
         }
         var _loc2_:IGameTransport = mInner;
         mInner = null;
         _loc2_.removeEventListener("gameTransportConnected",onInnerConnected);
         _loc2_.removeEventListener("gameTransportData",onInnerData);
         _loc2_.removeEventListener("gameTransportText",onInnerText);
         _loc2_.removeEventListener("gameTransportClosed",onInnerClosed);
         _loc2_.removeEventListener("gameTransportFailed",onInnerFailed);
         try
         {
            if(cleanly)
            {
               _loc2_.close();
            }
            else
            {
               _loc2_.abandon();
            }
         }
         catch(error:Error)
         {
         }
      }
      
      private function onInnerConnected(event:GameTransportEvent) : void
      {
         markInbound();
         var _loc2_:SessionCredential = currentCredential();
         warnAboutOmittedCredentialFields(_loc2_);
         if(mState == "handshaking")
         {
            sendControl(SessionProtocol.helloMessageFor(_loc2_));
            return;
         }
         if(mState == "resuming")
         {
            mAttemptConnected = true;
            sendControl(SessionProtocol.resumeMessageFor(mToken,mReceivedBytes,mDropKind,_loc2_));
         }
      }
      
      private function onHello(message:Object) : void
      {
         if(mState != "handshaking")
         {
            Logger.warnch("WS","SessionTransport got a hello reply in state " + mState);
            return;
         }
         var _loc3_:String = message.session == null ? "" : String(message.session);
         if(!SessionProtocol.isPlausibleToken(_loc3_))
         {
            rejectControl("implausible session token");
            return;
         }
         var _loc2_:Number = Number(message.pod);
         if(!SessionProtocol.isPlausiblePod(_loc2_))
         {
            rejectControl("pod ordinal " + _loc2_);
            return;
         }
         mToken = _loc3_;
         mPod = _loc2_;
         var _loc4_:Number = Number(message.grace_ms);
         mBridgeGraceMilliseconds = SessionProtocol.isWholeCount(_loc4_) && _loc4_ > 0 ? _loc4_ : 0;
         cancelAttemptWatchdog();
         mState = "open";
         startSessionTimers();
         Logger.infoch("WS","SessionTransport opened session " + shortToken() + " on pod " + mPod + " (grace " + _loc4_ + "ms advertised, " + graceMilliseconds + "ms in force, bridge buffer " + Number(message.buffer) + " bytes)");
         raise(GameTransportEvent.connectedEvent());
         if(mInsideConnect)
         {
            setTimeout(flushOutbound,0);
            return;
         }
         flushOutbound();
      }
      
      private function currentCredential() : SessionCredential
      {
         if(mCredentialSource == null)
         {
            return null;
         }
         try
         {
            return mCredentialSource() as SessionCredential;
         }
         catch(error:Error)
         {
            warnOnceAboutCredential("SessionTransport could not read its credential: " + error.message + "; sending none.");
         }
         return null;
      }
      
      private function warnAboutOmittedCredentialFields(credential:SessionCredential) : void
      {
         if(credential == null || credential.omittedFields == "")
         {
            return;
         }
         warnOnceAboutCredential("SessionTransport is sending no " + credential.omittedFields + " in its session control messages; the bridge may refuse the connection.");
      }
      
      private function warnOnceAboutCredential(text:String) : void
      {
         if(mWarnedAboutCredential)
         {
            return;
         }
         mWarnedAboutCredential = true;
         Logger.warnch("WS",text);
      }
      
      public function send(bytes:ByteArray) : void
      {
         if(mState == "finished" || bytes == null || bytes.length == 0)
         {
            return;
         }
         if(!mReplay.append(bytes))
         {
            Logger.warnch("WS","SessionTransport client replay buffer full: " + mReplay.unacknowledgedBytes + " bytes unacknowledged, cap " + TransportSettings.sessionOutboundBufferBytes);
            finishWithClose(0,"client replay buffer full","client");
            return;
         }
         flushOutbound();
      }
      
      public function sendText(text:String) : void
      {
         throw new Error("SessionTransport owns the text channel; nothing above it may send control messages.");
      }
      
      private function onInnerData(event:GameTransportEvent) : void
      {
         if(mState != "open")
         {
            rejectControl("data before the handshake completed");
            return;
         }
         if(event.bytes == null || event.bytes.length == 0)
         {
            return;
         }
         markInbound();
         mReceivedBytes += event.bytes.length;
         dispatchEvent(GameTransportEvent.dataEvent(event.bytes));
         maybeSendAck(false);
      }
      
      private function onInnerText(event:GameTransportEvent) : void
      {
         markInbound();
         var _loc2_:Object = SessionProtocol.parseControl(event.text);
         if(_loc2_ == null)
         {
            Logger.warnch("WS","SessionTransport ignoring an unreadable control message: " + shorten(event.text));
            return;
         }
         switch(String(_loc2_.t))
         {
            case "hello":
               onHello(_loc2_);
               break;
            case "resumed":
               onResumed(_loc2_);
               break;
            case "gone":
               onGone(_loc2_);
               break;
            case "ack":
               onAck(_loc2_);
               break;
            default:
               Logger.debugch("WS","SessionTransport ignoring control message " + shorten(event.text));
         }
      }
      
      private function onAck(message:Object) : void
      {
         var _loc2_:Number = Number(message.recv);
         if(!SessionProtocol.isWholeCount(_loc2_) || _loc2_ > mReplay.handedBytes)
         {
            rejectControl("ack " + _loc2_ + " above the " + mReplay.handedBytes + " bytes handed to a socket");
            return;
         }
         mReplay.discardAcknowledged(_loc2_);
      }
      
      private function rejectControl(detail:String) : void
      {
         finishWithClose(0,"bad control message from the bridge: " + detail,"server");
      }
      
      private function sendControl(text:String) : Boolean
      {
         if(mInner == null || !mInner.connected)
         {
            return false;
         }
         var _loc2_:IGameTransport = mInner;
         try
         {
            _loc2_.sendText(text);
            return mInner == _loc2_ && _loc2_.connected;
         }
         catch(error:Error)
         {
            Logger.warnch("WS","SessionTransport could not send a control message: " + error.message);
            var _loc5_:Boolean = false;
         }
         return _loc5_;
      }
      
      private function shortToken() : String
      {
         return mToken == null ? "none" : mToken.substr(0,8);
      }
      
      private function flushOutbound() : void
      {
         var _loc1_:ByteArray = null;
         while(mState == "open" && mInner != null && mInner.connected && mReplay.hasPending)
         {
            _loc1_ = mReplay.nextChunk();
            if(_loc1_ == null)
            {
               Logger.error("SessionTransport cannot make progress flushing at " + mReplay.forwardedBytes + " of " + sentBytes + "; ending the session rather than looping.");
               finishWithClose(0,"client replay buffer full","client");
               return;
            }
            mInner.send(_loc1_);
         }
      }
      
      private function maybeSendAck(force:Boolean) : void
      {
         if(mState != "open" || mInner == null || !mInner.connected)
         {
            return;
         }
         if(mReceivedBytes <= mAckedBytes)
         {
            return;
         }
         if(!force && mReceivedBytes - mAckedBytes < TransportSettings.sessionAckEveryBytes)
         {
            return;
         }
         var _loc2_:Number = mReceivedBytes;
         if(sendControl(SessionProtocol.ackMessage(_loc2_)))
         {
            mAckedBytes = Math.max(mAckedBytes,_loc2_);
         }
      }
      
      private function startSessionTimers() : void
      {
         markInbound();
         var _loc1_:int = Math.max(100,int(TransportSettings.sessionAckEverySeconds * 1000));
         mAckTimer = restart(mAckTimer,_loc1_,0,onAckTimer);
         mSilenceTimer = restart(mSilenceTimer,1000,0,onSilenceTimer);
      }
      
      private function stopSessionTimers() : void
      {
         stopIfAny(mAckTimer);
         stopIfAny(mSilenceTimer);
      }
      
      private function onAckTimer(event:TimerEvent) : void
      {
         maybeSendAck(true);
      }
      
      private function onSilenceTimer(event:TimerEvent) : void
      {
         if(mState != "open")
         {
            return;
         }
         var _loc2_:int = getTimer() - mLastInboundMilliseconds;
         if(_loc2_ < int(TransportSettings.dropDetectSeconds * 1000))
         {
            return;
         }
         var _loc3_:String = "no data from the bridge for " + _loc2_ + "ms";
         if(mInnerFactory == null)
         {
            finishWithClose(0,_loc3_,"server");
            return;
         }
         beginReconnect(0,_loc3_,"silence");
      }
      
      private function markInbound() : void
      {
         mLastInboundMilliseconds = getTimer();
      }
      
      private function onInnerClosed(event:GameTransportEvent) : void
      {
         if(mState == "finished")
         {
            return;
         }
         endOfSocket(event.code,event.reason,GameTransportEvent.closedEvent(event.code,event.reason,event.initiator));
      }
      
      private function onInnerFailed(event:GameTransportEvent) : void
      {
         if(mState == "finished")
         {
            return;
         }
         endOfSocket(0,event.text,GameTransportEvent.failedEvent(event.errorCode,event.text,event.certificateStatus,event.certificateDetail));
      }
      
      private function endOfSocket(code:int, reason:String, passUp:GameTransportEvent) : void
      {
         if(mState == "resuming")
         {
            attemptFailed(code,reason);
            return;
         }
         if(mInnerFactory == null || mToken == null || mState == "handshaking" || code == 1000 || SessionProtocol.isUnrecoverable(code))
         {
            if(SessionProtocol.isUnrecoverable(code))
            {
               if(reason == null || reason == "")
               {
                  passUp = GameTransportEvent.closedEvent(code,SessionProtocol.closeReasonFor(code),passUp.initiator);
               }
               passUp.terminal = true;
            }
            finishWith(passUp);
            return;
         }
         beginReconnect(code,reason,"socket");
      }
      
      private function get reconnectInProgress() : Boolean
      {
         return mState == "waiting" || mState == "resuming";
      }
      
      private function beginReconnect(code:int, reason:String, kind:String) : void
      {
         stopSessionTimers();
         detachInner(false);
         mDropAtMilliseconds = mLastInboundMilliseconds;
         mReconnectStartedAtMilliseconds = getTimer();
         mResumeAttempts = 0;
         mDeadEndAttempts = 0;
         mFinalAttemptScheduled = false;
         mDropKind = kind;
         mLastCode = code;
         mLastReason = reason == null ? "" : reason;
         mState = "waiting";
         Logger.warnch("WS","SessionTransport lost the socket under session " + shortToken() + " (code " + code + " \"" + mLastReason + "\"); resuming");
         raise(GameTransportEvent.reconnectingEvent(code,mLastReason,0));
         if(mState != "waiting")
         {
            return;
         }
         startResumeAttempt();
      }
      
      private function startResumeAttempt() : void
      {
         var _loc1_:IGameTransport = null;
         if(mState != "waiting")
         {
            return;
         }
         if(elapsedSinceDrop() >= graceMilliseconds)
         {
            giveUp();
            return;
         }
         mResumeAttempts = mResumeAttempts + 1;
         mState = "resuming";
         mGoneReason = null;
         mAttemptConnected = false;
         raise(GameTransportEvent.reconnectAttemptEvent(mResumeAttempts,elapsedSinceDrop(),graceMilliseconds));
         if(mState != "resuming")
         {
            return;
         }
         var _loc2_:String = resumeUrlFor(mBaseUrl,mPod);
         try
         {
            _loc1_ = mInnerFactory(_loc2_) as IGameTransport;
         }
         catch(factoryError:Error)
         {
            attemptFailed(0,"could not build a transport for " + _loc2_ + ": " + factoryError.message);
            return;
         }
         if(_loc1_ == null)
         {
            attemptFailed(0,"no transport for " + _loc2_);
            return;
         }
         attachInner(_loc1_);
         armAttemptWatchdog();
         try
         {
            _loc1_.connect();
         }
         catch(connectError:Error)
         {
            attemptFailed(0,connectError.message);
         }
      }
      
      private function attemptFailed(code:int, reason:String) : void
      {
         if(mState != "resuming")
         {
            return;
         }
         if(code != 0)
         {
            mLastCode = code;
         }
         if(mGoneReason != null)
         {
            mLastReason = mGoneReason;
            mGoneReason = null;
         }
         else if(reason != null && reason != "")
         {
            mLastReason = reason;
         }
         else if(SessionProtocol.isUnrecoverable(code))
         {
            mLastReason = SessionProtocol.closeReasonFor(code);
         }
         cancelAttemptWatchdog();
         detachInner(false);
         mState = "waiting";
         if(SessionProtocol.isUnrecoverable(code))
         {
            sessionIsGone();
            return;
         }
         if(code == 4004 || !mAttemptConnected)
         {
            mDeadEndAttempts = mDeadEndAttempts + 1;
         }
         var _loc3_:int = elapsedSinceDrop();
         var _loc5_:int = graceMilliseconds;
         if(_loc3_ >= _loc5_)
         {
            giveUp();
            return;
         }
         if(mDeadEndAttempts >= 3 && elapsedSinceReconnectBegan() >= 10000)
         {
            giveUp();
            return;
         }
         if(mFinalAttemptScheduled)
         {
            giveUp();
            return;
         }
         var _loc4_:int = backoffMilliseconds(mResumeAttempts);
         if(_loc3_ + _loc4_ > _loc5_)
         {
            _loc4_ = finalAttemptMilliseconds(_loc5_ - _loc3_,_loc5_);
            mFinalAttemptScheduled = true;
         }
         Logger.infoch("WS","SessionTransport resume attempt " + mResumeAttempts + " failed (" + mLastCode + " \"" + mLastReason + "\"); retrying in " + _loc4_ + "ms");
         mBackoffTimer = restart(mBackoffTimer,_loc4_,1,onBackoffElapsed);
      }
      
      private function onBackoffElapsed(event:TimerEvent) : void
      {
         startResumeAttempt();
      }
      
      private function armAttemptWatchdog() : void
      {
         var _loc1_:int = int(TransportSettings.connectTimeoutMilliseconds);
         mAttemptTimer = restart(mAttemptTimer,_loc1_,1,onAttemptWatchdog);
      }
      
      private function cancelAttemptWatchdog() : void
      {
         stopIfAny(mAttemptTimer);
      }
      
      private function onAttemptWatchdog(event:TimerEvent) : void
      {
         if(mState == "handshaking")
         {
            finishWithFailure(602,"The session handshake at " + mBaseUrl + " went unanswered.");
            return;
         }
         if(mState == "resuming")
         {
            attemptFailed(0,"the resume went unanswered");
         }
      }
      
      private function onResumed(message:Object) : void
      {
         if(mState != "resuming")
         {
            Logger.warnch("WS","SessionTransport got a resumed reply in state " + mState);
            return;
         }
         var _loc3_:Number = Number(message.recv);
         if(!SessionProtocol.isWholeCount(_loc3_) || _loc3_ < mReplay.acknowledgedBytes || _loc3_ > mReplay.handedBytes)
         {
            rejectControl("resumed recv " + _loc3_ + " outside " + mReplay.acknowledgedBytes + ".." + mReplay.handedBytes);
            return;
         }
         cancelAttemptWatchdog();
         var _loc2_:int = getTimer() - mDropAtMilliseconds;
         var _loc4_:Number = sentBytes - _loc3_;
         mReplay.discardAcknowledged(_loc3_);
         mReplay.rewindTo(_loc3_);
         mAckedBytes = 0;
         mState = "open";
         startSessionTimers();
         Logger.infoch("WS","SessionTransport resumed session " + shortToken() + " after " + _loc2_ + "ms and " + mResumeAttempts + " attempt(s); replaying " + _loc4_ + " bytes, received " + mReceivedBytes);
         raise(GameTransportEvent.resumedEvent(mResumeAttempts,_loc2_));
         flushOutbound();
         maybeSendAck(true);
      }
      
      private function onGone(message:Object) : void
      {
         var _loc2_:String = message.reason == null ? "session gone" : String(message.reason);
         Logger.warnch("WS","SessionTransport session " + shortToken() + " is gone: " + _loc2_);
         if(mState != "resuming")
         {
            return;
         }
         mGoneReason = _loc2_;
      }
      
      private function sessionIsGone() : void
      {
         Logger.warnch("WS","SessionTransport session " + shortToken() + " cannot be resumed after " + elapsedSinceDrop() + "ms and " + mResumeAttempts + " attempt(s): " + mLastCode + " \"" + mLastReason + "\"");
         finishWith(GameTransportEvent.closedEvent(mLastCode,mLastReason,"server"));
      }
      
      private function giveUp() : void
      {
         Logger.warnch("WS","SessionTransport gave up on session " + shortToken() + " after " + elapsedSinceDrop() + "ms and " + mResumeAttempts + " attempt(s): " + mLastCode + " \"" + mLastReason + "\"");
         var _loc1_:GameTransportEvent = GameTransportEvent.closedEvent(mLastCode,mLastReason,"server");
         _loc1_.gaveUp = true;
         finishWith(_loc1_);
      }
      
      private function elapsedSinceDrop() : int
      {
         return getTimer() - mDropAtMilliseconds;
      }
      
      private function elapsedSinceReconnectBegan() : int
      {
         return getTimer() - mReconnectStartedAtMilliseconds;
      }
      
      public function get graceMilliseconds() : int
      {
         var _loc1_:Number = TransportSettings.reconnectGraceSeconds * 1000;
         if(mBridgeGraceMilliseconds > 0 && mBridgeGraceMilliseconds < _loc1_)
         {
            _loc1_ = mBridgeGraceMilliseconds;
         }
         return int(_loc1_);
      }
      
      public function close() : void
      {
         finish(true);
      }
      
      public function abandon() : void
      {
         finish(false);
      }
      
      private function finish(cleanly:Boolean) : void
      {
         mSuppressed = true;
         teardown(cleanly);
      }
      
      private function teardown(cleanly:Boolean) : void
      {
         mState = "finished";
         stopAllTimers();
         detachInner(cleanly);
         mReplay.clear();
      }
      
      private function stopAllTimers() : void
      {
         stopSessionTimers();
         cancelAttemptWatchdog();
         stopIfAny(mBackoffTimer);
      }
      
      private function finishWithFailure(errorCode:uint, text:String) : void
      {
         finishWith(GameTransportEvent.failedEvent(errorCode,text));
      }
      
      private function finishWithClose(code:int, reason:String, initiator:String) : void
      {
         finishWith(GameTransportEvent.closedEvent(code,reason,initiator));
      }
      
      private function finishWith(event:GameTransportEvent) : void
      {
         if(mState == "finished")
         {
            return;
         }
         if(reconnectInProgress)
         {
            event.attempts = mResumeAttempts;
            event.elapsedMilliseconds = elapsedSinceDrop();
         }
         teardown(true);
         raise(event);
      }
      
      private function raise(event:GameTransportEvent, deferred:Boolean = false) : void
      {
         if(mSuppressed)
         {
            return;
         }
         if(mInsideConnect && !deferred)
         {
            setTimeout(raise,0,event,true);
            return;
         }
         dispatchEvent(event);
      }
   }
}

