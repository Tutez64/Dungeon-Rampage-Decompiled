package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.compat.ConsoleLib;
   import com.junkbyte.console.view.MainPanel;
   import com.junkbyte.console.view.PanelsManager;
   import flash.Boot;
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
   import haxe.Exception;
   import haxe.IMap;
   import haxe.ds.StringMap;
   
   public class Remoting extends ConsoleCore
   {
      
      public static var NONE:uint = 0;
      
      public static var SENDER:uint = 1;
      
      public static var RECIEVER:uint = 2;
      
      public var _socket:Socket;
      
      public var _senders:Dictionary;
      
      public var _sendID:String;
      
      public var _sendBuffer:ByteArray;
      
      public var _recBuffers:IMap;
      
      public var _mode:uint;
      
      public var _loggedIn:Boolean;
      
      public var _local:*;
      
      public var _lastReciever:String;
      
      public var _lastLogin:String;
      
      public var _callbacks:IMap;
      
      public function Remoting(m:Console = undefined)
      {
         var _gthis:Remoting;
         if(!Boot.skip_constructor)
         {
            _lastLogin = "";
            _senders = new Dictionary();
            _recBuffers = new StringMap();
            _sendBuffer = new ByteArray();
            _callbacks = new StringMap();
            _gthis = this;
            super(m);
            registerCallback("login",function(bytes:ByteArray):void
            {
               _gthis.login(bytes.readUTF());
            });
            registerCallback("requestLogin",requestLogin);
            registerCallback("loginFail",loginFail);
            registerCallback("loginSuccess",loginSuccess);
         }
      }
      
      public function update() : void
      {
         var _loc1_:* = null as ByteArray;
         var _loc2_:* = null as ByteArray;
         var _loc3_:* = null as String;
         var _loc13_:* = null;
         var _loc14_:int = 0;
         var _loc15_:Boolean = false;
         var _loc16_:* = null as String;
         if(_sendBuffer.length != 0)
         {
            if(_socket != null && _socket.connected)
            {
               _socket.writeBytes(_sendBuffer);
               _sendBuffer = new ByteArray();
            }
            else if(_local != null)
            {
               _sendBuffer.position = 0;
               if(_sendBuffer.bytesAvailable < 38000)
               {
                  _loc1_ = _sendBuffer;
                  _sendBuffer = new ByteArray();
               }
               else
               {
                  _loc1_ = new ByteArray();
                  _sendBuffer.readBytes(_loc1_,0,int(Math.min(38000,_sendBuffer.bytesAvailable)));
                  _loc2_ = new ByteArray();
                  _sendBuffer.readBytes(_loc2_);
                  _sendBuffer = _loc2_;
               }
               _loc3_ = config.remotingConnectionName + Std.string(get_remoting() == 2 ? 1 : 2);
               _local.send(_loc3_,"synchronize",_sendID,_loc1_);
            }
            else
            {
               _sendBuffer = new ByteArray();
            }
         }
         var _loc4_:StringMap = StringMap(_recBuffers);
         var _loc5_:* = _loc4_.h;
         var _loc6_:* = _loc4_.rh;
         var _loc7_:int = 0;
         var _loc8_:Boolean = false;
         var _loc9_:* = _loc5_;
         var _loc10_:int = _loc7_;
         var _loc11_:Boolean = §§hasnext(_loc9_,_loc10_);
         if(!_loc11_ && _loc6_ != null)
         {
            _loc9_ = _loc5_ = _loc6_;
            _loc10_ = _loc7_ = 0;
            _loc6_ = null;
            _loc8_ = true;
            _loc11_ = §§hasnext(_loc9_,_loc10_);
         }
         var _loc12_:int = _loc10_;
         while(true)
         {
            _loc13_ = _loc5_;
            _loc14_ = _loc7_;
            _loc15_ = §§hasnext(_loc13_,_loc14_);
            if(!_loc15_ && _loc6_ != null)
            {
               _loc13_ = _loc5_ = _loc6_;
               _loc14_ = _loc7_ = 0;
               _loc6_ = null;
               _loc8_ = true;
               _loc15_ = §§hasnext(_loc13_,_loc14_);
            }
            _loc12_ = _loc14_;
            if(!_loc15_)
            {
               break;
            }
            _loc3_ = §§nextname(_loc12_,_loc5_);
            _loc7_ = _loc12_;
            if(_loc8_)
            {
               _loc3_ = _loc3_.substr(1);
            }
            _loc16_ = _loc3_;
            processRecBuffer(_loc16_);
         }
      }
      
      public function synchronize(id:String, obj:*) : void
      {
         var _loc6_:* = null as StringMap;
         if(!(obj is ByteArray))
         {
            report("Remoting sync error. Recieved non-ByteArray:" + Std.string(obj),9);
            return;
         }
         var _loc3_:ByteArray = obj;
         var _loc4_:StringMap = StringMap(_recBuffers);
         var _loc5_:ByteArray = id in StringMap.reserved ? ByteArray(_loc4_.getReserved(id)) : _loc4_.h[id];
         if(_loc5_ != null)
         {
            _loc5_.position = _loc5_.length;
            _loc5_.writeBytes(_loc3_);
         }
         else
         {
            _loc6_ = StringMap(_recBuffers);
            if(id in StringMap.reserved)
            {
               _loc6_.setReserved(id,_loc3_);
            }
            else
            {
               _loc6_.h[id] = _loc3_;
            }
         }
      }
      
      public function startSharedConnection(targetmode:uint) : Boolean
      {
         var _loc3_:* = null;
         close();
         _mode = targetmode;
         _local = new LocalConnection();
         _local.client = {"synchronize":synchronize};
         if(config.allowedRemoteDomain != null && config.allowedRemoteDomain != "")
         {
            _local.allowDomain(config.allowedRemoteDomain);
            _local.allowInsecureDomain(config.allowedRemoteDomain);
         }
         _local.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onRemotingSecurityError,false,0,true);
         try
         {
            _local.connect(config.remotingConnectionName + Std.string(_mode));
         }
         catch(_loc_e_:*)
         {
            _loc3_ = _loc_e_;
            null;
            return false;
         }
         return true;
      }
      
      public function socketSecurityErrorHandler(e:Event) : void
      {
         report("Remoting security error." + Std.string(e),9);
         remotingSocket(null);
      }
      
      public function socketIOErrorHandler(e:Event) : void
      {
         report("Remoting socket error." + Std.string(e),9);
         remotingSocket(null);
      }
      
      public function socketDataHandler(e:Event) : void
      {
         handleSocket(Socket(e.currentTarget));
      }
      
      public function socketConnectHandler(e:Event) : void
      {
         report("Remoting socket connected.",-1);
         _sendBuffer = new ByteArray();
         if(_loggedIn || checkLogin(""))
         {
            sendLoginSuccess();
         }
         else
         {
            send("requestLogin");
         }
      }
      
      public function socketCloseHandler(e:Event) : void
      {
         if(e.currentTarget == _socket)
         {
            _socket = null;
         }
      }
      
      public function set_remoting(newMode:uint) : uint
      {
         var _loc2_:* = null as String;
         if(newMode == _mode)
         {
            return newMode;
         }
         _sendID = generateId();
         if(newMode == 1)
         {
            if(!startSharedConnection(1))
            {
               report("Could not create remoting client service. You will not be able to control this console with remote.",10);
            }
            _sendBuffer = new ByteArray();
            _local.addEventListener(StatusEvent.STATUS,onSenderStatus,false,0,true);
            report("<b>Remoting started.</b> " + getInfo(),-1);
            _loggedIn = checkLogin("");
            if(_loggedIn)
            {
               sendLoginSuccess();
            }
            else
            {
               send("requestLogin");
            }
         }
         else if(newMode == 2)
         {
            if(startSharedConnection(2))
            {
               _sendBuffer = new ByteArray();
               _local.addEventListener(AsyncErrorEvent.ASYNC_ERROR,onRemoteAsyncError,false,0,true);
               _local.addEventListener(StatusEvent.STATUS,onRecieverStatus,false,0,true);
               report("<b>Remote started.</b> " + getInfo(),-1);
               _loc2_ = Security.sandboxType;
               if(_loc2_ == Security.LOCAL_WITH_FILE || _loc2_ == Security.LOCAL_WITH_NETWORK)
               {
                  report("Untrusted local sandbox. You may not be able to listen for logs properly.",10);
                  printHowToGlobalSetting();
               }
               login(_lastLogin);
            }
            else
            {
               report("Could not create remote service. You might have a console remote already running.",10);
            }
         }
         else
         {
            close();
         }
         console.get_panels().updateMenu();
         return newMode;
      }
      
      public function set remoting(value:uint) : void
      {
         set_remoting(value);
      }
      
      public function sendLoginSuccess() : void
      {
         _loggedIn = true;
         send("loginSuccess");
         dispatchEvent(new Event(Event.CONNECT));
      }
      
      public function send(command:String, arg:ByteArray = undefined) : Boolean
      {
         if(_mode == 0)
         {
            return false;
         }
         _sendBuffer.position = _sendBuffer.length;
         _sendBuffer.writeUTF(command);
         if(arg != null)
         {
            _sendBuffer.writeBoolean(true);
            _sendBuffer.writeUnsignedInt(arg.length);
            _sendBuffer.writeBytes(arg);
         }
         else
         {
            _sendBuffer.writeBoolean(false);
         }
         return true;
      }
      
      public function requestLogin() : void
      {
         if(get_remoting() != 2)
         {
            return;
         }
         _sendBuffer = new ByteArray();
         if(_lastLogin != null && _lastLogin != "")
         {
            login(_lastLogin);
         }
         else
         {
            console.get_panels().get_mainPanel().requestLogin();
         }
      }
      
      public function remotingSocket(host:String, port:int = 0) : void
      {
         if(_socket != null && _socket.connected)
         {
            _socket.close();
            _socket = null;
         }
         if(host != null && host != "" && port != 0)
         {
            set_remoting(1);
            report("Connecting to socket " + host + ":" + port);
            _socket = new Socket();
            _socket.addEventListener(Event.CLOSE,socketCloseHandler);
            _socket.addEventListener(Event.CONNECT,socketConnectHandler);
            _socket.addEventListener(IOErrorEvent.IO_ERROR,socketIOErrorHandler);
            _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,socketSecurityErrorHandler);
            _socket.addEventListener(ProgressEvent.SOCKET_DATA,socketDataHandler);
            _socket.connect(host,port);
         }
      }
      
      public function registerCallback(key:String, fun:*, latestOnly:Boolean = false) : void
      {
         var _loc4_:* = {
            "fun":fun,
            "latest":latestOnly
         };
         var _loc5_:StringMap = StringMap(_callbacks);
         var _loc6_:* = _loc4_;
         if(key in StringMap.reserved)
         {
            _loc5_.setReserved(key,_loc6_);
         }
         else
         {
            _loc5_.h[key] = _loc6_;
         }
      }
      
      public function processRecBuffer(id:String) : void
      {
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:* = null as String;
         var _loc8_:* = null as ByteArray;
         var _loc9_:* = null as StringMap;
         var _loc10_:* = null;
         var _loc11_:* = null as ByteArray;
         var _loc12_:* = null as Exception;
         if(!ConsoleLib.truthy(_senders[id]))
         {
            _senders[id] = true;
            if(_lastReciever != null)
            {
               report("Remote switched to new sender [" + id + "] as primary.",-2);
            }
            _lastReciever = id;
         }
         var _loc3_:StringMap = StringMap(_recBuffers);
         var _loc4_:ByteArray = id in StringMap.reserved ? ByteArray(_loc3_.getReserved(id)) : _loc3_.h[id];
         try
         {
            _loc5_ = _loc4_.position = 0;
            while(_loc4_.bytesAvailable != 0)
            {
               _loc7_ = _loc4_.readUTF();
               _loc8_ = null;
               if(_loc4_.bytesAvailable == 0)
               {
                  break;
               }
               if(_loc4_.readBoolean())
               {
                  if(_loc4_.bytesAvailable == 0)
                  {
                     break;
                  }
                  _loc6_ = _loc4_.readUnsignedInt();
                  if(_loc4_.bytesAvailable < _loc6_)
                  {
                     break;
                  }
                  _loc8_ = new ByteArray();
                  _loc4_.readBytes(_loc8_,0,_loc6_);
               }
               _loc9_ = StringMap(_callbacks);
               _loc10_ = _loc7_ in StringMap.reserved ? _loc9_.getReserved(_loc7_) : _loc9_.h[_loc7_];
               if(!_loc10_.latest || id == _lastReciever)
               {
                  if(_loc8_ != null)
                  {
                     _loc10_.fun(_loc8_);
                  }
                  else
                  {
                     _loc10_.fun();
                  }
               }
               _loc5_ = _loc4_.position;
            }
            if(_loc5_ < _loc4_.length)
            {
               _loc8_ = new ByteArray();
               _loc8_.writeBytes(_loc4_,_loc5_);
               _loc11_ = _loc4_ = _loc8_;
               _loc9_ = StringMap(_recBuffers);
               if(id in StringMap.reserved)
               {
                  _loc9_.setReserved(id,_loc11_);
               }
               else
               {
                  _loc9_.h[id] = _loc11_;
               }
            }
            else
            {
               StringMap(_recBuffers).remove(id);
            }
         }
         catch(_loc_e_:*)
         {
            _loc10_ = _loc_e_;
            _loc12_ = Exception.caught(_loc10_);
            report("Remoting sync error: " + Std.string(_loc12_),9);
         }
      }
      
      public function printHowToGlobalSetting() : void
      {
         report("Make sure your flash file is \'trusted\' in Global Security Settings.",-2);
         report("Go to Settings Manager [<a href=\'event:settings\'>click here</a>] &gt; \'Global Security Settings Panel\' (on left) &gt; add the location of the local flash (swf) file.",-2);
      }
      
      public function onSenderStatus(e:StatusEvent) : void
      {
         if(e.level == "error" && !(_socket != null && _socket.connected))
         {
            _loggedIn = false;
         }
      }
      
      public function onRemotingSecurityError(e:SecurityErrorEvent) : void
      {
         report("Remoting security error.",9);
         printHowToGlobalSetting();
      }
      
      public function onRemoteAsyncError(e:AsyncErrorEvent) : void
      {
         report("Problem with remote sync. [<a href=\'event:remote\'>Click here</a>] to restart.",10);
         set_remoting(0);
      }
      
      public function onRecieverStatus(e:StatusEvent) : void
      {
         if(get_remoting() == 2 && e.level == "error")
         {
            report("Problem communicating to client.",10);
         }
      }
      
      public function loginSuccess() : void
      {
         if(int([].length) == 0)
         {
            console.setViewingChannels();
         }
         else if(int([].length) == 1)
         {
            console.setViewingChannels([][0]);
         }
         else if(int([].length) == 2)
         {
            console.setViewingChannels([][0],[][1]);
         }
         else if(int([].length) == 3)
         {
            console.setViewingChannels([][0],[][1],[][2]);
         }
         else if(int([].length) == 4)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3]);
         }
         else if(int([].length) == 5)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4]);
         }
         else if(int([].length) == 6)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5]);
         }
         else if(int([].length) == 7)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6]);
         }
         else if(int([].length) == 8)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7]);
         }
         else if(int([].length) == 9)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8]);
         }
         else if(int([].length) == 10)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9]);
         }
         else if(int([].length) == 11)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10]);
         }
         else if(int([].length) == 12)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11]);
         }
         else if(int([].length) == 13)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12]);
         }
         else if(int([].length) == 14)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13]);
         }
         else if(int([].length) == 15)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13],[][14]);
         }
         else if(int([].length) == 16)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13],[][14],[][15]);
         }
         else if(int([].length) == 17)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13],[][14],[][15],[][16]);
         }
         else if(int([].length) == 18)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13],[][14],[][15],[][16],[][17]);
         }
         else if(int([].length) == 19)
         {
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13],[][14],[][15],[][16],[][17],[][18]);
         }
         else
         {
            if(int([].length) != 20)
            {
               throw "Too many rest arguments";
            }
            console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13],[][14],[][15],[][16],[][17],[][18],[][19]);
         }
         report("Login Successful",-1);
      }
      
      public function loginFail() : void
      {
         if(get_remoting() != 2)
         {
            return;
         }
         report("Login Failed",10);
         console.get_panels().get_mainPanel().requestLogin();
      }
      
      public function login(pass:String = undefined) : void
      {
         var _loc2_:* = null as ByteArray;
         if(pass == null)
         {
            pass = "";
         }
         if(get_remoting() == 2)
         {
            _lastLogin = pass;
            report("Attempting to login...",-1);
            _loc2_ = new ByteArray();
            _loc2_.writeUTF(pass);
            send("login",_loc2_);
         }
         else if(_loggedIn || checkLogin(pass))
         {
            sendLoginSuccess();
         }
         else
         {
            send("loginFail");
         }
      }
      
      public function handleSocket(socket:Socket) : void
      {
         if(!ConsoleLib.truthy(_senders[socket]))
         {
            _senders[socket] = generateId();
            _socket = socket;
         }
         var _loc2_:ByteArray = new ByteArray();
         socket.readBytes(_loc2_);
         synchronize(_senders[socket],_loc2_);
      }
      
      public function get_remoting() : uint
      {
         return _mode;
      }
      
      public function get remoting() : uint
      {
         return get_remoting();
      }
      
      public function get_canSend() : Boolean
      {
         if(_mode == 1)
         {
            return _loggedIn;
         }
         return false;
      }
      
      public function get canSend() : Boolean
      {
         return get_canSend();
      }
      
      public function getInfo() : String
      {
         return "<p4>channel:" + config.remotingConnectionName + " (" + Security.sandboxType + ")</p4>";
      }
      
      public function generateId() : String
      {
         return ConsoleLib.now().getTime() + "." + int(Math.floor(Math.random() * 100000));
      }
      
      public function close() : void
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         if(_local != null)
         {
            try
            {
               _local.close();
            }
            catch(_loc_e_:*)
            {
               _loc2_ = _loc_e_;
               null;
               _loc3_ = Exception.caught(_loc2_).unwrap();
               report("Remote.close: " + Std.string(_loc3_),10);
            }
         }
         _mode = 0;
         _sendBuffer = new ByteArray();
         _local = null;
      }
      
      public function checkLogin(pass:String) : Boolean
      {
         if(!(config.remotingPassword == null && config.keystrokePassword == pass || config.remotingPassword == ""))
         {
            return config.remotingPassword == pass;
         }
         return true;
      }
   }
}

