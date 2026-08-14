package DistributedObjects
{
   import Facade.DBFacade;
   import GeneratedCode.GeneratedDcSocket;
   
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
      
      public function Initialize(host:String, port:int, playtoken:String, demographics:String, account:uint, networkid:uint, noderules:uint) : Boolean
      {
         if(mGeneratedDcSocket != null)
         {
            mGeneratedDcSocket.destroy();
         }
         mGeneratedDcSocket = null;
         mGeneratedDcSocket = new GeneratedDcSocket(mDBfacade,host,port,playtoken,demographics,account);
         mGeneratedDcSocket.pass2Init(networkid,noderules);
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
         var _loc1_:Boolean = mGeneratedDcSocket != null && mGeneratedDcSocket.connected && mMatchMaker != null;
         trace("------------>isAllOk ",_loc1_);
         return _loc1_;
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

