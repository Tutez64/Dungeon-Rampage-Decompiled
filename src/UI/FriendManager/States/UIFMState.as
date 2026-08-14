package UI.FriendManager.States
{
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import Town.TownStateMachine;
   import UI.FriendManager.UIFriendManager;
   import flash.display.MovieClip;
   
   public class UIFMState
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mUIFriendManager:UIFriendManager;
      
      protected var mTownStateMachine:TownStateMachine;
      
      public function UIFMState(dbFacade:DBFacade, friendMgr:UIFriendManager, townStateMachine:TownStateMachine)
      {
         super();
         mDBFacade = dbFacade;
         mUIFriendManager = friendMgr;
         mTownStateMachine = townStateMachine;
      }
      
      public function enter() : void
      {
      }
      
      public function exit() : void
      {
      }
      
      public function createButton(btnStr:String, text:String, xPos:int, yPos:int, callbackFunc:Function) : UIButton
      {
         var _loc7_:Class = mTownStateMachine.getTownAsset(btnStr);
         var _loc8_:MovieClip = new _loc7_() as MovieClip;
         var _loc6_:UIButton = new UIButton(mDBFacade,_loc8_);
         _loc6_.releaseCallback = callbackFunc;
         _loc8_.x = xPos;
         _loc8_.y = yPos;
         _loc6_.root.scaleY = _loc6_.root.scaleX = 1.8;
         _loc6_.label.text = text;
         mUIFriendManager.addToUI(_loc6_.root);
         return _loc6_;
      }
   }
}

