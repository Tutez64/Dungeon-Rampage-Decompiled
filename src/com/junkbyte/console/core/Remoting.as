package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import flash.events.AsyncErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.StatusEvent;
   import flash.net.LocalConnection;
   import flash.net.Socket;
   import flash.system.Security;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class Remoting extends ConsoleCore
   {
      
      public static const NONE:uint = 0;
      
      public static const SENDER:uint = 1;
      
      public static const RECIEVER:uint = 2;
      
      private var _callbacks:Object;
      
      private var _mode:uint;
      
      private var _local:LocalConnection;
      
      private var _socket:Socket;
      
      private var _sendBuffer:ByteArray;
      
      private var _recBuffers:Object;
      
      private var _senders:Dictionary;
      
      private var _lastLogin:String = "";
      
      private var _loggedIn:Boolean;
      
      private var _sendID:String;
      
      private var _lastReciever:String;
      
      public function Remoting(m:Console)
      {
         this._callbacks = new Object();
         this._sendBuffer = new ByteArray();
         this._recBuffers = new Object();
         this._senders = new Dictionary();
         super(m);
         this.registerCallback("login",function(bytes:ByteArray):void
         {
            login(bytes.readUTF());
         });
         this.registerCallback("requestLogin",this.requestLogin);
         this.registerCallback("loginFail",this.loginFail);
         this.registerCallback("loginSuccess",this.loginSuccess);
      }
      
      public function update() : void
      {
         var _loc1_:String = null;
         var _loc2_:ByteArray = null;
         var _loc3_:String = null;
         var _loc4_:ByteArray = null;
         if(this._sendBuffer.length)
         {
            if(Boolean(this._socket) && this._socket.connected)
            {
               this._socket.writeBytes(this._sendBuffer);
               this._sendBuffer = new ByteArray();
            }
            else if(this._local)
            {
               this._sendBuffer.position = 0;
               if(this._sendBuffer.bytesAvailable < 38000)
               {
                  _loc2_ = this._sendBuffer;
                  this._sendBuffer = new ByteArray();
               }
               else
               {
                  _loc2_ = new ByteArray();
                  this._sendBuffer.readBytes(_loc2_,0,Math.min(38000,this._sendBuffer.bytesAvailable));
                  _loc4_ = new ByteArray();
                  this._sendBuffer.readBytes(_loc4_);
                  this._sendBuffer = _loc4_;
               }
               _loc3_ = config.remotingConnectionName + (this.remoting == Remoting.RECIEVER ? SENDER : RECIEVER);
               this._local.send(_loc3_,"synchronize",this._sendID,_loc2_);
            }
            else
            {
               this._sendBuffer = new ByteArray();
            }
         }
         for(_loc1_ in this._recBuffers)
         {
            this.processRecBuffer(_loc1_);
         }
      }
      
      private function processRecBuffer(id:String) : void
      {
         var buffer:ByteArray;
         var pointer:uint = 0;
         var cmd:String = null;
         var arg:ByteArray = null;
         var callbackData:Object = null;
         var blen:uint = 0;
         var recbuffer:ByteArray = null;
         if(!this._senders[id])
         {
            this._senders[id] = true;
            if(this._lastReciever)
            {
               report("Remote switched to new sender [" + id + "] as primary.",-2);
            }
            this._lastReciever = id;
         }
         buffer = this._recBuffers[id];
         try
         {
            pointer = buffer.position = 0;
            while(buffer.bytesAvailable)
            {
               cmd = buffer.readUTF();
               arg = null;
               if(buffer.bytesAvailable == 0)
               {
                  break;
               }
               if(buffer.readBoolean())
               {
                  if(buffer.bytesAvailable == 0)
                  {
                     break;
                  }
                  blen = buffer.readUnsignedInt();
                  if(buffer.bytesAvailable < blen)
                  {
                     break;
                  }
                  arg = new ByteArray();
                  buffer.readBytes(arg,0,blen);
               }
               callbackData = this._callbacks[cmd];
               if(!callbackData.latest || id == this._lastReciever)
               {
                  if(arg)
                  {
                     callbackData.fun(arg);
                  }
                  else
                  {
                     callbackData.fun();
                  }
               }
               pointer = buffer.position;
            }
            if(pointer < buffer.length)
            {
               recbuffer = new ByteArray();
               recbuffer.writeBytes(buffer,pointer);
               this._recBuffers[id] = buffer = recbuffer;
            }
            else
            {
               delete this._recBuffers[id];
            }
         }
         catch(err:Error)
         {
            report("Remoting sync error: " + err,9);
         }
      }
      
      private function synchronize(id:String, obj:Object) : void
      {
         if(!(obj is ByteArray))
         {
            report("Remoting sync error. Recieved non-ByteArray:" + obj,9);
            return;
         }
         var _loc3_:ByteArray = obj as ByteArray;
         var _loc4_:ByteArray = this._recBuffers[id];
         if(_loc4_)
         {
            _loc4_.position = _loc4_.length;
            _loc4_.writeBytes(_loc3_);
         }
         else
         {
            this._recBuffers[id] = _loc3_;
         }
      }
      
      public function send(command:String, arg:ByteArray = null) : Boolean
      {
         if(this._mode == NONE)
         {
            return false;
         }
         this._sendBuffer.position = this._sendBuffer.length;
         this._sendBuffer.writeUTF(command);
         if(arg)
         {
            this._sendBuffer.writeBoolean(true);
            this._sendBuffer.writeUnsignedInt(arg.length);
            this._sendBuffer.writeBytes(arg);
         }
         else
         {
            this._sendBuffer.writeBoolean(false);
         }
         return true;
      }
      
      public function get remoting() : uint
      {
         return this._mode;
      }
      
      public function get canSend() : Boolean
      {
         return this._mode == SENDER && this._loggedIn;
      }
      
      public function set remoting(newMode:uint) : void
      {
         var _loc2_:String = null;
         if(newMode == this._mode)
         {
            return;
         }
         this._sendID = this.generateId();
         if(newMode == SENDER)
         {
            if(!this.startSharedConnection(SENDER))
            {
               report("Could not create remoting client service. You will not be able to control this console with remote.",10);
            }
            this._sendBuffer = new ByteArray();
            this._local.addEventListener(StatusEvent.STATUS,this.onSenderStatus,false,0,true);
            report("<b>Remoting started.</b> " + this.getInfo(),-1);
            this._loggedIn = this.checkLogin("");
            if(this._loggedIn)
            {
               this.sendLoginSuccess();
            }
            else
            {
               this.send("requestLogin");
            }
         }
         else if(newMode == RECIEVER)
         {
            if(this.startSharedConnection(RECIEVER))
            {
               this._sendBuffer = new ByteArray();
               this._local.addEventListener(AsyncErrorEvent.ASYNC_ERROR,this.onRemoteAsyncError,false,0,true);
               this._local.addEventListener(StatusEvent.STATUS,this.onRecieverStatus,false,0,true);
               report("<b>Remote started.</b> " + this.getInfo(),-1);
               _loc2_ = Security.sandboxType;
               if(_loc2_ == Security.LOCAL_WITH_FILE || _loc2_ == Security.LOCAL_WITH_NETWORK)
               {
                  report("Untrusted local sandbox. You may not be able to listen for logs properly.",10);
                  this.printHowToGlobalSetting();
               }
               this.login(this._lastLogin);
            }
            else
            {
               report("Could not create remote service. You might have a console remote already running.",10);
            }
         }
         else
         {
            this.close();
         }
         console.panels.updateMenu();
      }
      
      public function remotingSocket(host:String, port:int = 0) : void
      {
         if(Boolean(this._socket) && this._socket.connected)
         {
            this._socket.close();
            this._socket = null;
         }
         if(Boolean(host) && Boolean(port))
         {
            this.remoting = SENDER;
            report("Connecting to socket " + host + ":" + port);
            this._socket = new Socket();
            this._socket.addEventListener(Event.CLOSE,this.socketCloseHandler);
            this._socket.addEventListener(Event.CONNECT,this.socketConnectHandler);
            this._socket.addEventListener(IOErrorEvent.IO_ERROR,this.socketIOErrorHandler);
            this._socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.socketSecurityErrorHandler);
            this._socket.addEventListener(ProgressEvent.SOCKET_DATA,this.socketDataHandler);
            this._socket.connect(host,port);
         }
      }
      
      private function socketCloseHandler(e:Event) : void
      {
         if(e.currentTarget == this._socket)
         {
            this._socket = null;
         }
      }
      
      private function socketConnectHandler(e:Event) : void
      {
         report("Remoting socket connected.",-1);
         this._sendBuffer = new ByteArray();
         if(this._loggedIn || this.checkLogin(""))
         {
            this.sendLoginSuccess();
         }
         else
         {
            this.send("requestLogin");
         }
      }
      
      private function socketIOErrorHandler(e:Event) : void
      {
         report("Remoting socket error." + e,9);
         this.remotingSocket(null);
      }
      
      private function socketSecurityErrorHandler(e:Event) : void
      {
         report("Remoting security error." + e,9);
         this.remotingSocket(null);
      }
      
      private function socketDataHandler(e:Event) : void
      {
         this.handleSocket(e.currentTarget as Socket);
      }
      
      public function handleSocket(socket:Socket) : void
      {
         if(!this._senders[socket])
         {
            this._senders[socket] = this.generateId();
            this._socket = socket;
         }
         var _loc2_:ByteArray = new ByteArray();
         socket.readBytes(_loc2_);
         this.synchronize(this._senders[socket],_loc2_);
      }
      
      private function onSenderStatus(e:StatusEvent) : void
      {
         if(e.level == "error" && !(this._socket && this._socket.connected))
         {
            this._loggedIn = false;
         }
      }
      
      private function onRecieverStatus(e:StatusEvent) : void
      {
         if(this.remoting == Remoting.RECIEVER && e.level == "error")
         {
            report("Problem communicating to client.",10);
         }
      }
      
      private function onRemotingSecurityError(e:SecurityErrorEvent) : void
      {
         report("Remoting security error.",9);
         this.printHowToGlobalSetting();
      }
      
      private function onRemoteAsyncError(e:AsyncErrorEvent) : void
      {
         report("Problem with remote sync. [<a href=\'event:remote\'>Click here</a>] to restart.",10);
         this.remoting = NONE;
      }
      
      private function getInfo() : String
      {
         return "<p4>channel:" + config.remotingConnectionName + " (" + Security.sandboxType + ")</p4>";
      }
      
      private function printHowToGlobalSetting() : void
      {
         report("Make sure your flash file is \'trusted\' in Global Security Settings.",-2);
         report("Go to Settings Manager [<a href=\'event:settings\'>click here</a>] &gt; \'Global Security Settings Panel\' (on left) &gt; add the location of the local flash (swf) file.",-2);
      }
      
      private function generateId() : String
      {
         return new Date().time + "." + Math.floor(Math.random() * 100000);
      }
      
      private function startSharedConnection(targetmode:uint) : Boolean
      {
         this.close();
         this._mode = targetmode;
         this._local = new LocalConnection();
         this._local.client = {"synchronize":this.synchronize};
         if(config.allowedRemoteDomain)
         {
            this._local.allowDomain(config.allowedRemoteDomain);
            this._local.allowInsecureDomain(config.allowedRemoteDomain);
         }
         this._local.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onRemotingSecurityError,false,0,true);
         try
         {
            this._local.connect(config.remotingConnectionName + this._mode);
         }
         catch(err:Error)
         {
            return false;
         }
         return true;
      }
      
      public function registerCallback(key:String, fun:Function, latestOnly:Boolean = false) : void
      {
         this._callbacks[key] = {
            "fun":fun,
            "latest":latestOnly
         };
      }
      
      private function loginFail() : void
      {
         if(this.remoting != Remoting.RECIEVER)
         {
            return;
         }
         report("Login Failed",10);
         console.panels.mainPanel.requestLogin();
      }
      
      private function sendLoginSuccess() : void
      {
         this._loggedIn = true;
         this.send("loginSuccess");
         dispatchEvent(new Event(Event.CONNECT));
      }
      
      private function loginSuccess() : void
      {
         console.setViewingChannels();
         report("Login Successful",-1);
      }
      
      private function requestLogin() : void
      {
         if(this.remoting != Remoting.RECIEVER)
         {
            return;
         }
         this._sendBuffer = new ByteArray();
         if(this._lastLogin)
         {
            this.login(this._lastLogin);
         }
         else
         {
            console.panels.mainPanel.requestLogin();
         }
      }
      
      public function login(pass:String = "") : void
      {
         var _loc2_:ByteArray = null;
         if(this.remoting == Remoting.RECIEVER)
         {
            this._lastLogin = pass;
            report("Attempting to login...",-1);
            _loc2_ = new ByteArray();
            _loc2_.writeUTF(pass);
            this.send("login",_loc2_);
         }
         else if(this._loggedIn || this.checkLogin(pass))
         {
            this.sendLoginSuccess();
         }
         else
         {
            this.send("loginFail");
         }
      }
      
      private function checkLogin(pass:String) : Boolean
      {
         return config.remotingPassword === null && config.keystrokePassword == pass || config.remotingPassword === "" || config.remotingPassword == pass;
      }
      
      public function close() : void
      {
         if(this._local)
         {
            try
            {
               this._local.close();
            }
            catch(error:Error)
            {
               report("Remote.close: " + error,10);
            }
         }
         this._mode = NONE;
         this._sendBuffer = new ByteArray();
         this._local = null;
      }
   }
}

