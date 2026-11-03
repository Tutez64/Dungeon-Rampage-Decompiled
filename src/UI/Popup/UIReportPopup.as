package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.TextUtil;
   import Brain.jsonRPC.JSONRPCService;
   import DBGlobals.DBGlobal;
   import Events.FriendSummaryNewsFeedEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import GeneratedCode.DungeonReport;
   import flash.text.TextFormat;
   
   public class UIReportPopup extends DBUIPopup
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_score_report.swf";
      
      protected static const POPUP_CLASS_NAME:String = "popup_report";
      
      protected var mLeftButton:UIButton;
      
      protected var mLeftCallback:Function;
      
      protected var mLeftButtonLabelText:String;
      
      protected var mRightButton:UIButton;
      
      protected var mRightCallback:Function;
      
      protected var mRightButtonLabelText:String;
      
      protected var check_button_a:UIButton;
      
      protected var check_button_b:UIButton;
      
      protected var check_button_c:UIButton;
      
      protected var check_button_a_value:String = "Behaviour";
      
      protected var check_button_b_value:String = "VerbalAbuse";
      
      protected var check_button_c_value:String = "Cheating";
      
      protected var check_button_label_a:String;
      
      protected var check_button_label_b:String;
      
      protected var check_button_label_c:String;
      
      private var mDungeonReport:Vector.<DungeonReport>;
      
      private var mSuccessCallback:Function;
      
      private var mClosedCallback:Function;
      
      private var mMatchPlayers:Array;
      
      private var mPersonName:String;
      
      protected var mSelectedButtonValuesArray:Array;
      
      public function UIReportPopup(dbFacade:DBFacade, personName:String, personId:uint, matchPlayers:Array, reportedCallback:Function, successCallback:Function, closedCallback:Function = null)
      {
         mSelectedButtonValuesArray = [];
         var titleText:String = Locale.getString("REPORT") + " " + personName + "?";
         var contentText:String = Locale.getString("VICTORY_SCREEN_REPORT_POPUP_MESSAGE_01") + personName + Locale.getString("VICTORY_SCREEN_REPORT_POPUP_MESSAGE_02");
         check_button_label_a = Locale.getString("REPORT_REASON_BEHAVIOUR");
         check_button_label_b = Locale.getString("REPORT_REASON_VERBAL_ABUSE");
         check_button_label_c = Locale.getString("REPORT_REASON_CHEATING");
         mLeftCallback = null;
         mLeftButtonLabelText = Locale.getString("CANCEL");
         mRightCallback = function():void
         {
            reportPlayer(personId,personName);
            reportedCallback();
         };
         mRightButtonLabelText = Locale.getString("REPORT");
         mMatchPlayers = matchPlayers;
         mPersonName = personName;
         mSuccessCallback = successCallback;
         mClosedCallback = closedCallback;
         super(dbFacade,"DUNGEON_SUMMARY_REPORT_PLAYER",titleText,contentText);
      }
      
      public function reportPlayer(personId:uint, personName:String) : void
      {
         var _loc3_:Function = JSONRPCService.getFunction("ReportPlayer",mDBFacade.rpcRoot + "report");
         _loc3_({
            "reportingPlayerId":mDBFacade.dbAccountInfo.id,
            "reportingPlayerName":mDBFacade.dbAccountInfo.name,
            "reportedPlayerId":personId,
            "reportedPlayerName":personName,
            "reportReasons":selectedButtonValues,
            "matchPlayers":mMatchPlayers
         },mSuccessCallback);
      }
      
      override public function destroy() : void
      {
         if(mLeftButton)
         {
            mLeftButton.destroy();
            mLeftButton = null;
         }
         if(mRightButton)
         {
            mRightButton.destroy();
            mRightButton = null;
         }
         mLeftButtonLabelText = null;
         mRightButtonLabelText = null;
         check_button_label_a = null;
         check_button_label_b = null;
         check_button_label_c = null;
         check_button_a_value = null;
         check_button_b_value = null;
         check_button_c_value = null;
         if(check_button_a)
         {
            check_button_a.destroy();
            check_button_a = null;
         }
         if(check_button_b)
         {
            check_button_b.destroy();
            check_button_b = null;
         }
         if(check_button_c)
         {
            check_button_c.destroy();
            check_button_c = null;
         }
         mMatchPlayers = null;
         mPersonName = null;
         mSelectedButtonValuesArray = null;
         mLeftCallback = null;
         mRightCallback = null;
         mSuccessCallback = null;
         mDungeonReport = null;
         var _loc1_:Function = mClosedCallback;
         mClosedCallback = null;
         super.destroy();
         if(_loc1_ != null)
         {
            _loc1_();
         }
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         var tf:TextFormat;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         tf = new TextFormat();
         tf.color = FriendSummaryNewsFeedEvent.FRIEND_NAME_HIGHLIGHT_COLOR;
         super.colorizeMessage(tf,Locale.getString("VICTORY_SCREEN_REPORT_POPUP_MESSAGE_01").length,Locale.getString("VICTORY_SCREEN_REPORT_POPUP_MESSAGE_01").length + mPersonName.length);
         TextUtil.setText(mPopup.check_button_a_label,check_button_label_a);
         check_button_a = new UIButton(mDBFacade,mPopup.check_button_a);
         check_button_a.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         check_button_a.releaseCallback = function():void
         {
            checkButtonCallback(check_button_a,check_button_a_value);
         };
         TextUtil.setText(mPopup.check_button_b_label,check_button_label_b);
         check_button_b = new UIButton(mDBFacade,mPopup.check_button_b);
         check_button_b.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         check_button_b.releaseCallback = function():void
         {
            checkButtonCallback(check_button_b,check_button_b_value);
         };
         TextUtil.setText(mPopup.check_button_c_label,check_button_label_c);
         check_button_c = new UIButton(mDBFacade,mPopup.check_button_c);
         check_button_c.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         check_button_c.releaseCallback = function():void
         {
            checkButtonCallback(check_button_c,check_button_c_value);
         };
         if(mLeftButtonLabelText)
         {
            mPopup.left_button.visible = true;
            mLeftButton = new UIButton(mDBFacade,mPopup.left_button);
            mLeftButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            TextUtil.setText(mLeftButton.label,mLeftButtonLabelText);
            mLeftButton.releaseCallback = function():void
            {
               close(mLeftCallback);
            };
         }
         else
         {
            mPopup.left_button.visible = false;
         }
         if(mRightButtonLabelText)
         {
            mPopup.right_button.visible = true;
            mRightButton = new UIButton(mDBFacade,mPopup.right_button);
            mRightButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            TextUtil.setText(mRightButton.label,mRightButtonLabelText);
            mRightButton.releaseCallback = function():void
            {
               close(mRightCallback);
            };
            mRightButton.enabled = false;
         }
         else
         {
            mPopup.right_button.visible = false;
         }
      }
      
      override protected function setupMenuNavigation() : void
      {
         check_button_a.isAbove(check_button_b);
         check_button_b.isAbove(check_button_c);
         if(mCloseButton)
         {
            mCloseButton.isAbove(check_button_a);
            mCloseButton.isToTheLeftOf(check_button_a);
         }
         var _loc1_:UIButton = mLeftButton ? mLeftButton : mRightButton;
         if(_loc1_)
         {
            check_button_c.isAbove(_loc1_);
         }
         if(mLeftButton && mRightButton)
         {
            mLeftButton.isToTheLeftOf(mRightButton);
            mRightButton.upNavigation = check_button_c;
         }
      }
      
      override protected function getInitialFocusedNavigationObject() : UIObject
      {
         return check_button_a;
      }
      
      private function checkButtonCallback(button:UIButton, buttonValueString:String) : void
      {
         var _loc3_:int = 0;
         if(button.selected)
         {
            button.selected = false;
            _loc3_ = mSelectedButtonValuesArray.indexOf(buttonValueString);
            if(_loc3_ != -1)
            {
               mSelectedButtonValuesArray.splice(_loc3_,1);
            }
         }
         else
         {
            button.selected = true;
            mSelectedButtonValuesArray.push(buttonValueString);
         }
         updateRightButtonState();
      }
      
      private function updateRightButtonState() : void
      {
         mRightButton.enabled = mSelectedButtonValuesArray.length > 0;
      }
      
      override protected function getClassName() : String
      {
         return "popup_report";
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_score_report.swf";
      }
      
      public function get selectedButtonValues() : Array
      {
         return mSelectedButtonValuesArray;
      }
   }
}

