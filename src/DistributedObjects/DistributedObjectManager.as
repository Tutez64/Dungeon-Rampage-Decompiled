package DistributedObjects
{
   import Facade.DBFacade;
   import GeneratedCode.GeneratedDcSocket;
   import NetworkCode.DcSocket;
   import NetworkCode.Transport.GameEndpoints;
   
   public class DistributedObjectManager
   {
      
      private var mDBfacade:DBFacade;
      
      private var mGeneratedDcSocket:GeneratedDcSocket;
      
      public var mMatchMaker:MatchMaker;
      
      public var mPresenceManager:PresenceManager;
      
      public function DistributedObjectManager(facade:DBFacade)
      {
         super();
         mDBfacade = facade;
      }
      
      public function get socket() : DcSocket
      {
         return mGeneratedDcSocket;
      }
      
      public function Initialize(endpoints:GameEndpoints, experimentalWebSocketReconnects:Boolean, playtoken:String, demographics:String, account:uint, networkid:uint, noderules:uint) : Boolean
      {
         if(mGeneratedDcSocket != null)
         {
            mGeneratedDcSocket.destroy();
         }
         mGeneratedDcSocket = null;
         mGeneratedDcSocket = new GeneratedDcSocket(mDBfacade,endpoints.address,endpoints.port,playtoken,demographics,account);
         mGeneratedDcSocket.pass2Init(networkid,noderules);
         mGeneratedDcSocket.beginConnect(endpoints,experimentalWebSocketReconnects);
         return true;
      }
      
      public function destroy() : void
      {
         if(mGeneratedDcSocket != null)
         {
            mGeneratedDcSocket.destroy();
         }
         mGeneratedDcSocket = null;
      }
      
      public function isAllOk() : Boolean
      {
         return mGeneratedDcSocket != null && mGeneratedDcSocket.connected && mMatchMaker != null;
      }
      
      private function SocketIsLeaving() : void
      {
         if(mGeneratedDcSocket != null)
         {
            mGeneratedDcSocket.destroy();
         }
         mGeneratedDcSocket = null;
      }
      
      public function enterSocketErrorState(errorCode:uint, errorText:String = "") : void
      {
         mDBfacade.mainStateMachine.enterSocketErrorState(errorCode,errorText);
         mDBfacade.mDistributedObjectManager.SocketIsLeaving();
      }
   }
}

