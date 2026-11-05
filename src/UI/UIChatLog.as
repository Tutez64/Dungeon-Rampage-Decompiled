package UI
{
   import Account.PlayerSpecialStatus;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.Event.EventComponent;
   import Brain.Event.EventListeners;
   import Brain.Logger.Logger;
   import Brain.Render.Tweens.TweenHandle;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UIInputText;
   import Brain.UI.UISlider;
   import Brain.Utils.TextUtil;
   import DistributedObjects.HeroGameObjectOwner;
   import Events.ChatEvent;
   import Events.ChatLogEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import com.amanitadesign.steam.SteamEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class UIChatLog
   {
      
      private static var JOINED_DUNGEON_COLOR:uint = 16063002;
      
      private static var LEFT_DUNGEON_COLOR:uint = 16063002;
      
      private static var FRIEND_STATUS_ONLINE_COLOR:uint = 16764232;
      
      private static var FRIEND_STATUS_OFFLINE_COLOR:uint = 16764232;
      
      private static var NAME_CHAT_COLOR:uint = 16764232;
      
      public static var JOINED_DUNGEON_TYPE:String = "JOINED_DUNGEON";
      
      public static var LEFT_DUNGEON_TYPE:String = "LEFT_DUNGEON";
      
      public static var FRIEND_STATUS_ONLINE_TYPE:String = "FRIEND_STATUS_ONLINE";
      
      public static var FRIEND_STATUS_OFFLINE_TYPE:String = "FRIEND_STATUS_OFFLINE";
      
      public static var CHAT_TYPE:String = "CHAT";
      
      private static var MAX_CHATS:uint = 50;
      
      private static const CHAT_FADE_DURATION:Number = 0.3;
      
      private static const MAX_CHAT_CHARS:uint = 169;
      
      private static var mChatLogXOffset:uint = 0;
      
      private static var mChatLogYOffset:uint = 0;
      
      private static var mChats:Vector.<ChatTextFieldHelper>;
      
      private static var sChatsVersion:int = 0;
      
      private var mDBFacade:DBFacade;
      
      private var mChatLog:TextField;
      
      private var mSlider:UISlider;
      
      private var mEventComponent:EventComponent;
      
      private var mChatLogContainer:MovieClip;
      
      private var mFadeTween:TweenHandle;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mAutoShowChatLog:Boolean;
      
      private var mUserToggled:Boolean;
      
      private var mToggledOpen:Boolean = false;
      
      private var mPlayerSetSlider:Boolean = false;
      
      private var mChatLogButton:UIButton;
      
      private var mChatInputText:UIInputText;
      
      private var mChatSendButton:UIButton;
      
      private var mChatLogShowing:Boolean;
      
      private var mChatPromptVisible:Boolean = true;
      
      private var mStarlingPrompt:Function;
      
      private var mHeroOwner:HeroGameObjectOwner;
      
      private var mEnabledChatEnterEvent:Boolean = true;
      
      private var mMenuHadEnter:Boolean;
      
      private var mRenderedVersion:int = -1;
      
      private var mRenderedLength:int = -1;
      
      private var mDefaultFormat:TextFormat;
      
      private var mPreviousHeight:Number = 1;
      
      public function UIChatLog(dbFacade:DBFacade, chatLogContainer:MovieClip, chatTextField:MovieClip, chatLogButton:MovieClip, sendChatButton:MovieClip)
      {
         super();
         mDBFacade = dbFacade;
         if(mChats == null)
         {
            mChats = new Vector.<ChatTextFieldHelper>();
         }
         mPlayerSetSlider = false;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIChatLog");
         mEventComponent = new EventComponent(mDBFacade);
         setupButtons(chatTextField,chatLogButton,sendChatButton);
         setupLog(chatLogContainer);
         mAutoShowChatLog = mDBFacade.dbConfigManager.getConfigBoolean("AUTO_SHOW_CHAT_LOG",true);
         constructAndRenderNewChat();
         enable();
      }
      
      private static function growToFloor(field:TextField, sizeModifier:Number) : void
      {
         var _loc3_:TextFormat = field.defaultTextFormat;
         var _loc5_:Number = Number(_loc3_.size);
         _loc3_.size = Math.round(_loc5_ * TextUtil.scaleToFloor(_loc5_,sizeModifier));
         field.defaultTextFormat = _loc3_;
         if(field.multiline)
         {
            return;
         }
         var _loc4_:Number = field.height * Number(_loc3_.size) / _loc5_;
         field.y -= (_loc4_ - field.height) / 2;
         field.height = _loc4_;
      }
      
      public static function growLogUp(chatLogContainer:MovieClip, scale:Number) : void
      {
         var _loc7_:int = 0;
         var _loc4_:DisplayObject = null;
         var _loc5_:TextField = chatLogContainer.chatLog;
         var _loc3_:MovieClip = chatLogContainer.slider;
         var _loc6_:Number = 0;
         _loc7_ = 0;
         while(_loc7_ < chatLogContainer.numChildren)
         {
            _loc4_ = chatLogContainer.getChildAt(_loc7_);
            if(!(_loc4_ == _loc5_ || _loc4_ == _loc3_))
            {
               if(!_loc6_)
               {
                  _loc6_ = _loc4_.height * (scale - 1);
               }
               stretchUp(_loc4_,_loc6_);
            }
            _loc7_++;
         }
         stretchUp(_loc5_,_loc6_);
         _loc3_.y -= _loc6_;
         _loc3_.back.height += _loc6_ / _loc3_.scaleY;
      }
      
      private static function stretchUp(object:DisplayObject, extra:Number) : void
      {
         var _loc3_:Number = object.getBounds(object.parent).bottom;
         object.height += extra;
         object.y += _loc3_ - object.getBounds(object.parent).bottom;
      }
      
      public function set heroOwner(hero:HeroGameObjectOwner) : void
      {
         mHeroOwner = hero;
      }
      
      public function enable() : void
      {
         this.disable();
         mEventComponent.addListener("CHAT_LOG_EVENT",chatEventHandler);
         EventListeners.add(mChatInputText.root,"focusIn",onChatTextFieldFocus);
         EventListeners.add(mChatInputText.root,"focusOut",onChatTextFieldLoseFocus);
         EventListeners.add(mDBFacade.stageRef,"keyDown",checkKeyEvent);
         EventListeners.add(mDBFacade.stageRef,"keyDown",noteEnterOwner,false,1);
         EventListeners.add(mDBFacade.mSteamworks,SteamEvent.STEAM_RESPONSE,onSteamResponse);
      }
      
      public function disable() : void
      {
         mEventComponent.removeListener("CHAT_LOG_EVENT");
         EventListeners.remove(mChatInputText.root,"focusIn",onChatTextFieldFocus);
         EventListeners.remove(mChatInputText.root,"focusOut",onChatTextFieldLoseFocus);
         EventListeners.remove(mDBFacade.stageRef,"keyDown",checkKeyEvent);
         EventListeners.remove(mDBFacade.stageRef,"keyDown",noteEnterOwner);
         EventListeners.remove(mDBFacade.mSteamworks,SteamEvent.STEAM_RESPONSE,onSteamResponse);
      }
      
      private function onSteamResponse(event:SteamEvent) : void
      {
         if(event.req_type != 35 && event.req_type != 34)
         {
            return;
         }
         if(mChatInputText == null || mDBFacade == null)
         {
            return;
         }
         if(mDBFacade.stageRef.focus != mChatInputText.textField)
         {
            return;
         }
         mToggledOpen = false;
         mChatInputText.releaseKeyboardFocus();
         hideChatLog();
         mDBFacade.inputManager.clear();
      }
      
      private function onChatTextFieldFocus(event:FocusEvent) : void
      {
         if(mHeroOwner)
         {
            mHeroOwner.showPlayerIsTyping(true);
         }
         chatTextFieldFocus();
      }
      
      private function onChatTextFieldLoseFocus(event:FocusEvent) : void
      {
         if(mHeroOwner)
         {
            mHeroOwner.showPlayerIsTyping(false);
         }
         chatTextFieldLostFocus();
      }
      
      private function setupButtons(chatTextField:MovieClip, chatLogButton:MovieClip, sendChatButton:MovieClip) : void
      {
         mChatInputText = new UIInputText(mDBFacade,chatTextField);
         mChatInputText.defaultText = Locale.getString("DEFAULT_CHAT_PROMPT");
         mChatInputText.enterCallback = sendChat;
         mChatInputText.cancelCallback = leaveChatInput;
         mChatInputText.focusOutCallback = function():void
         {
            if(mChatInputText.text == "")
            {
               resetChatPrompt();
            }
         };
         mChatInputText.textField.maxChars = 169;
         mChatLogButton = new UIButton(mDBFacade,chatLogButton);
         mChatLogButton.releaseCallback = toggleChatLog;
         mChatSendButton = new UIButton(mDBFacade,sendChatButton);
         mChatSendButton.releaseCallback = function():void
         {
            if(mChatInputText.text == "")
            {
               focusChatInput();
               return;
            }
            sendChat(mChatInputText.text);
         };
      }
      
      private function sendChat(value:String) : void
      {
         mChatInputText.clear();
         mDBFacade.regainFocus();
         mDBFacade.inputManager.clear();
         if(value)
         {
            mEventComponent.dispatchEvent(new ChatEvent("ChatEvent_OUTGOING_CHAT_UPDATE",0,value));
         }
         else
         {
            resetChatPrompt();
         }
      }
      
      private function resetChatPrompt() : void
      {
         if(mStarlingPrompt != null)
         {
            mChatInputText.defaultText = "";
            updateStarlingPrompt();
            return;
         }
         mChatInputText.defaultText = mChatPromptVisible ? Locale.getString("DEFAULT_CHAT_PROMPT") : "";
      }
      
      public function set starlingPrompt(value:Function) : void
      {
         mStarlingPrompt = value;
         mChatInputText.focusInCallback = value != null ? updateStarlingPrompt : null;
         if(mChatInputText.showingDefaultText)
         {
            resetChatPrompt();
         }
      }
      
      public function get promptColor() : uint
      {
         return mChatInputText.defaultTextColor;
      }
      
      private function updateStarlingPrompt() : void
      {
         if(mStarlingPrompt != null)
         {
            mStarlingPrompt(mChatPromptVisible && mChatInputText.showingDefaultText && mDBFacade.stageRef.focus != mChatInputText.textField);
         }
      }
      
      public function setChatPromptVisible(inVisible:Boolean) : void
      {
         mChatPromptVisible = inVisible;
         if(mChatInputText.text == "")
         {
            resetChatPrompt();
         }
      }
      
      public function set textSizeModifier(value:Number) : void
      {
         growToFloor(mChatLog,value);
         growToFloor(mChatInputText.textField,value);
         mDefaultFormat = null;
         constructAndRenderNewChat();
         if(mChatInputText.showingDefaultText)
         {
            resetChatPrompt();
         }
      }
      
      public function toggleChatLog() : void
      {
         if(mChatLogShowing)
         {
            mToggledOpen = false;
            hideChatLog();
         }
         else
         {
            mToggledOpen = true;
            showChatLog();
         }
      }
      
      private function chatTextFieldFocus() : void
      {
         if(mAutoShowChatLog)
         {
            showChatLog();
         }
         if(mDBFacade.steamInputManager.usesSteamOnScreenKeyboard)
         {
            mDBFacade.steamInputManager.showFloatingGamepadTextInputForField(mChatInputText.textField);
         }
      }
      
      private function chatTextFieldLostFocus() : void
      {
         if(mAutoShowChatLog && !mToggledOpen)
         {
            hideChatLog();
         }
      }
      
      private function checkKeyEvent(event:KeyboardEvent) : void
      {
         if(!Logger.isConsoleVisible())
         {
            if(event.keyCode == 13 && mEnabledChatEnterEvent && !mMenuHadEnter)
            {
               focusChatInput();
            }
         }
      }
      
      private function noteEnterOwner(event:KeyboardEvent) : void
      {
         if(event.keyCode == 13)
         {
            mMenuHadEnter = isMenuOpen();
         }
      }
      
      public function focusChatInput() : void
      {
         mDBFacade.stageRef.focus = mChatInputText.textField;
      }
      
      public function isMenuOpen() : Boolean
      {
         return mDBFacade.menuNavigationController != null && mDBFacade.menuNavigationController.layerDepth > 0;
      }
      
      public function mayOpenChatFromAction() : Boolean
      {
         return !isMenuOpen() && !(mMenuHadEnter && mDBFacade.inputManager.released(13));
      }
      
      private function leaveChatInput() : void
      {
         mDBFacade.regainFocus();
         mDBFacade.inputManager.clear();
         if(mChatInputText.text == "")
         {
            resetChatPrompt();
         }
      }
      
      public function tryToggleChatLog() : void
      {
         if(mDBFacade.mainStateMachine.currentStateName == "RunState")
         {
            toggleChatLog();
         }
      }
      
      private function setupLog(chatLogContainer:MovieClip) : void
      {
         mChatLogContainer = chatLogContainer;
         mChatLog = mChatLogContainer.chatLog;
         mSlider = new UISlider(mDBFacade,mChatLogContainer.slider,1);
         mSlider.minimum = 100;
         mSlider.maximum = 0;
         mSlider.tick = 2;
         mSlider.value = 0;
         mSlider.updateCallback = sliderCallback;
         init();
      }
      
      private function sliderCallback(pos:Number) : void
      {
         mPlayerSetSlider = true;
         setChatLogPosition(pos);
      }
      
      private function init() : void
      {
         mChatLogContainer.y += mChatLogYOffset;
         mChatLogContainer.x += mChatLogXOffset;
         mChatLog.text = "";
         mChatLogContainer.visible = false;
         mSlider.visible = false;
      }
      
      private function chatEventHandler(event:ChatLogEvent) : void
      {
         var _loc2_:uint = 0;
         switch(event.chatLogType)
         {
            case JOINED_DUNGEON_TYPE:
               _loc2_ = JOINED_DUNGEON_COLOR;
               break;
            case LEFT_DUNGEON_TYPE:
               _loc2_ = LEFT_DUNGEON_COLOR;
               break;
            case FRIEND_STATUS_ONLINE_TYPE:
               _loc2_ = FRIEND_STATUS_ONLINE_COLOR;
               break;
            case FRIEND_STATUS_OFFLINE_TYPE:
               _loc2_ = FRIEND_STATUS_OFFLINE_COLOR;
         }
         addChatLog(event.chat,_loc2_,event.playerName);
      }
      
      private function addChatLog(chat:String, color:uint, playerName:String = "") : void
      {
         var _loc10_:ChatTextFieldHelper = null;
         if(!mChatLog)
         {
            return;
         }
         var _loc9_:ChatTextFieldHelper = new ChatTextFieldHelper();
         if(chat.indexOf("\r\n") >= 0)
         {
            chat = chat.split("\r\n").join("\n");
         }
         chat += "\n";
         var _loc5_:uint = uint(mChatLog.length);
         var _loc7_:int = sChatsVersion++;
         _loc9_.chatText = chat;
         _loc9_.color = color;
         _loc9_.playerName = playerName;
         _loc9_.colorStartIndex = _loc5_;
         _loc9_.colorEndIndex = _loc5_ + chat.length;
         mChats.push(_loc9_);
         var _loc6_:uint = 0;
         if(mChats.length > MAX_CHATS)
         {
            _loc10_ = mChats.shift();
            _loc6_ = _loc10_.colorEndIndex - _loc10_.colorStartIndex;
            for each(var _loc4_:ChatTextFieldHelper in mChats)
            {
               _loc4_.colorEndIndex -= _loc6_;
               _loc4_.colorStartIndex -= _loc6_;
            }
         }
         if(mRenderedVersion != _loc7_ || mChatLog.length != mRenderedLength)
         {
            constructAndRenderNewChat();
            return;
         }
         if(_loc6_ > 0)
         {
            mChatLog.replaceText(0,_loc6_,"");
         }
         var _loc8_:int = mChatLog.length;
         mChatLog.appendText(chat);
         if(!mDefaultFormat)
         {
            mDefaultFormat = mChatLog.defaultTextFormat;
         }
         mChatLog.setTextFormat(mDefaultFormat,_loc8_,mChatLog.length);
         formatChat(_loc9_);
         mRenderedVersion = sChatsVersion;
         mRenderedLength = mChatLog.length;
         checkToShowSlider();
         adjustSlider();
      }
      
      private function constructAndRenderNewChat() : void
      {
         mChatLog.text = "";
         var _loc1_:uint = 0;
         for each(var _loc2_:ChatTextFieldHelper in mChats)
         {
            mChatLog.text = mChatLog.text.concat(_loc2_.chatText);
            _loc2_.colorStartIndex = _loc1_;
            _loc1_ += _loc2_.chatText.length;
            _loc2_.colorEndIndex = _loc1_;
         }
         for each(_loc2_ in mChats)
         {
            formatChat(_loc2_);
         }
         mRenderedVersion = sChatsVersion;
         mRenderedLength = mChatLog.length;
         checkToShowSlider();
         adjustSlider();
      }
      
      private function formatChat(chat:ChatTextFieldHelper) : void
      {
         var _loc2_:TextFormat = null;
         var _loc3_:uint = chat.colorStartIndex;
         if(chat.playerName != "")
         {
            _loc2_ = new TextFormat();
            _loc2_.color = PlayerSpecialStatus.getSpecialTextColor(chat.playerName,NAME_CHAT_COLOR);
            mChatLog.setTextFormat(_loc2_,_loc3_,_loc3_ + chat.playerName.length + 1);
            _loc3_ += chat.playerName.length + 1;
         }
         if(chat.color == 0)
         {
            return;
         }
         _loc2_ = new TextFormat();
         _loc2_.color = chat.color;
         mChatLog.setTextFormat(_loc2_,_loc3_,chat.colorEndIndex);
      }
      
      private function adjustSlider() : void
      {
         var _loc1_:Boolean = false;
         if(mSlider.value == mSlider.minimum)
         {
            _loc1_ = true;
         }
         if(_loc1_ || !mPlayerSetSlider)
         {
            mSlider.value = mSlider.minimum;
         }
         else
         {
            mSlider.value = mPreviousHeight / mChatLog.textHeight * mSlider.value;
         }
         mPreviousHeight = mChatLog.textHeight;
         setChatLogPosition(mSlider.value);
      }
      
      private function setChatLogPosition(pos:Number) : void
      {
         var _loc2_:Number = Math.round((mChatLog.maxScrollV + 1) * pos / 100);
         mChatLog.scrollV = _loc2_;
      }
      
      public function isShowing() : Boolean
      {
         return mChatLogContainer.visible;
      }
      
      public function hideChatLog() : void
      {
         if(!mChatLogShowing)
         {
            return;
         }
         mChatLogShowing = false;
         if(mFadeTween && mDBFacade.mTween.getCurrentProgress(mFadeTween) != 1)
         {
            mDBFacade.mTween.completeTween(mFadeTween);
         }
         mChatLogContainer.alpha = 1;
         mFadeTween = mDBFacade.mTween.tweenMaxTo(mChatLogContainer,0.3,{
            "alpha":0,
            "onComplete":function():void
            {
               mChatLogContainer.visible = false;
            }
         });
         mSlider.visible = false;
      }
      
      public function showChatLog() : void
      {
         if(mChatLogShowing)
         {
            return;
         }
         mChatLogShowing = true;
         if(mFadeTween && mDBFacade.mTween.getCurrentProgress(mFadeTween) != 1)
         {
            mDBFacade.mTween.completeTween(mFadeTween);
         }
         mChatLogContainer.visible = true;
         mChatLogContainer.alpha = 0;
         mFadeTween = mDBFacade.mTween.tweenMaxTo(mChatLogContainer,0.3,{"alpha":1});
         constructAndRenderNewChat();
         checkToShowSlider();
      }
      
      private function checkToShowSlider() : void
      {
         if(mChatLog.maxScrollV > 1)
         {
            mSlider.visible = true;
         }
      }
      
      public function destroy() : void
      {
         if(mFadeTween && mDBFacade.mTween.getCurrentProgress(mFadeTween) != 1)
         {
            mDBFacade.mTween.completeTween(mFadeTween);
         }
         disable();
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         if(mSceneGraphComponent)
         {
            mSceneGraphComponent.destroy();
            mSceneGraphComponent = null;
         }
         if(mEventComponent)
         {
            mEventComponent.removeAllListeners();
            mEventComponent.destroy();
         }
         if(mSlider)
         {
            mSlider.destroy();
         }
         mSlider = null;
         if(mChatLogButton)
         {
            mChatLogButton.destroy();
         }
         mChatLogButton = null;
         if(mChatSendButton)
         {
            mChatSendButton.destroy();
         }
         mChatSendButton = null;
         mStarlingPrompt = null;
         if(mChatInputText)
         {
            mChatInputText.destroy();
         }
         mChatInputText = null;
         mHeroOwner = null;
         mFadeTween = null;
         mEventComponent = null;
         mDBFacade = null;
         mChatLog = null;
         mChatLogContainer = null;
      }
      
      public function set enabledChatEnterEvent(inBoolean:Boolean) : void
      {
         mEnabledChatEnterEvent = inBoolean;
      }
      
      public function get enabledChatEnterEvent() : Boolean
      {
         return mEnabledChatEnterEvent;
      }
      
      public function get chatLogButton() : UIButton
      {
         return mChatLogButton;
      }
      
      public function get chatSendButton() : UIButton
      {
         return mChatSendButton;
      }
   }
}

class ChatTextFieldHelper
{
   
   public var chatText:String;
   
   public var color:uint;
   
   public var colorStartIndex:uint;
   
   public var colorEndIndex:uint;
   
   public var playerName:String;
   
   public function ChatTextFieldHelper()
   {
      super();
   }
}
