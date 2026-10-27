package StateMachine.MainStateMachine
{
   import Brain.StateMachine.State;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import Facade.Locale;
   import UI.Popup.DBUIOneButtonPopup;
   import flash.desktop.NativeApplication;
   
   public class SocketErrorState extends State
   {
      
      public static const NAME:String = "SocketErrorState";
      
      public static const MAINTENANCE_CODE:uint = 1504;
      
      private var mDBFacade:DBFacade;
      
      public function SocketErrorState(dbFacade:DBFacade, finishedCallback:Function = null)
      {
         mDBFacade = dbFacade;
         super("SocketErrorState",finishedCallback);
      }
      
      override public function enterState() : void
      {
         super.enterState();
      }
      
      override public function exitState() : void
      {
         super.exitState();
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      private function errorDialogResponce() : void
      {
         NativeApplication.nativeApplication.exit();
      }
      
      public function enterReason(errorCode:uint, errorText:String = "") : DBUIOneButtonPopup
      {
         var _loc3_:DBUIOneButtonPopup = null;
         if(errorCode == 60)
         {
            _loc3_ = new DBUIOneButtonPopup(mDBFacade,Locale.getString("SOCKET_CLOSE_60_HEADER"),Locale.getString("SOCKET_CLOSE_60_TEXT"),Locale.getString("EXIT"),errorDialogResponce,false);
         }
         else if(errorCode == 61)
         {
            _loc3_ = new DBUIOneButtonPopup(mDBFacade,Locale.getString("SOCKET_CLOSE_61_HEADER"),Locale.getString("SOCKET_CLOSE_61_TEXT"),Locale.getString("EXIT"),errorDialogResponce,false);
         }
         else if(errorCode == 1504)
         {
            _loc3_ = new DBUIOneButtonPopup(mDBFacade,Locale.getString("SOCKET_CLOSE_61_HEADER"),errorText,Locale.getString("EXIT"),errorDialogResponce,false);
         }
         else
         {
            _loc3_ = new DBUIOneButtonPopup(mDBFacade,Locale.getString("SOCKET_UNEXPECT_CLOSE"),Locale.getError(errorCode) + "\n" + errorText,Locale.getString("CENTER_BUTTON_POPUP_RELOAD_TEXT"),errorDialogResponce,false);
         }
         MemoryTracker.track(_loc3_,"DBUIOneButtonPopup - created in SocketErrorState.enterReason()");
         mDBFacade.enteringSocketError();
         return _loc3_;
      }
   }
}

