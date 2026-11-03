package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedImage;
   import Brain.Starling.SwfConverter.BakedPages;
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import UI.UIChatLog;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Sprite;
   
   internal class StarlingChatPrompt
   {
      
      private static const GUTTER:Number = 2;
      
      internal static const PATH:String = "chatBar";
      
      private var mFacade:DBFacade;
      
      private var mTicker:HudTicker;
      
      private var mInput:StarlingInput;
      
      private var mChat:UIChatLog;
      
      private var mBar:starling.display.Sprite = new starling.display.Sprite();
      
      private var mLabel:starling.display.Sprite = new starling.display.Sprite();
      
      private var mView:ArtView;
      
      private var mButtons:Vector.<StarlingButton> = new Vector.<StarlingButton>(0);
      
      private var mSend:StarlingButton;
      
      private var mLog:StarlingButton;
      
      private var mFlashParts:Vector.<flash.display.DisplayObject> = new Vector.<flash.display.DisplayObject>(0);
      
      private var mFlashShown:Vector.<Boolean> = new Vector.<Boolean>(0);
      
      private var mClip:MovieClip;
      
      private var mModel:Class;
      
      private var mLabelSource:TextField;
      
      private var mBarKey:String;
      
      private var mLabelKey:String;
      
      private var mLabelArt:ArtNode;
      
      private var mRetry:Function;
      
      private var mChanged:Function;
      
      private var mReady:Function;
      
      private var mDisposed:Boolean;
      
      private var mBakeFailed:Boolean;
      
      public function StarlingChatPrompt(facade:DBFacade, ticker:HudTicker, parent:starling.display.DisplayObjectContainer, input:StarlingInput, holder:flash.display.DisplayObjectContainer, clip:MovieClip, model:Class, chat:UIChatLog, prompt:String, color:uint, layout:uint, changed:Function, ready:Function = null)
      {
         var _loc16_:String = null;
         var _loc14_:flash.display.DisplayObject = null;
         super();
         var _loc15_:TextField = clip.getChildByName("textField") as TextField;
         for each(_loc16_ in new <String>["textField","chat_bar","chat_btn","log_btn"])
         {
            if(clip.getChildByName(_loc16_) == null)
            {
               HudArt.fatal("Missing Starling chat bar art: " + _loc16_);
            }
         }
         mFacade = facade;
         mTicker = ticker;
         mInput = input;
         mChat = chat;
         mChanged = changed;
         mClip = clip;
         mModel = model;
         mLabelSource = copyField(_loc15_,prompt,color);
         mBarKey = "starlingChatBar|" + layout;
         mLabelKey = "starlingChatPrompt|" + layout + "|label|" + prompt + "|" + color + "|" + _loc15_.defaultTextFormat.size;
         mBar.touchable = mLabel.touchable = false;
         mBar.transformationMatrix = designMatrix(clip,holder);
         mLabel.transformationMatrix = designMatrix(_loc15_,holder);
         mLabel.visible = false;
         parent.addChild(mBar);
         parent.addChild(mLabel);
         for each(_loc16_ in new <String>["chat_bar","chat_btn","log_btn"])
         {
            _loc14_ = clip.getChildByName(_loc16_);
            mFlashParts.push(_loc14_);
            mFlashShown.push(_loc14_.visible);
            _loc14_.visible = false;
         }
         mRetry = bake;
         if(!bake())
         {
            mTicker.deferBake(mRetry);
         }
         mReady = ready;
      }
      
      private static function bakePart(parent:MovieClip, name:String, key:String, scale:Number) : ArtNode
      {
         var _loc7_:flash.display.DisplayObject = parent.getChildByName(name);
         if(_loc7_ == null)
         {
            HudArt.fatal("Missing Starling chat bar art: " + name);
         }
         var _loc6_:flash.display.Sprite = new flash.display.Sprite();
         _loc7_.visible = true;
         _loc6_.addChild(_loc7_);
         var _loc5_:ArtNode = new ArtNode();
         _loc5_.name = name;
         _loc5_.kind = "static";
         _loc5_.cell = _loc5_.hold(HudArt.bakeContent(key + "|" + name,_loc6_,scale),HudArt.pages);
         return _loc5_;
      }
      
      private static function snap(container:starling.display.Sprite, art:starling.display.DisplayObject) : void
      {
         var _loc3_:Starling = Starling.current;
         var _loc6_:Number = _loc3_.viewPort.width / _loc3_.stage.stageWidth;
         var _loc5_:Rectangle = art.getBounds(_loc3_.stage);
         var _loc4_:Number = container.parent.getTransformationMatrix(_loc3_.stage).a;
         if(_loc6_ <= 0 || _loc4_ <= 0 || _loc5_.isEmpty())
         {
            return;
         }
         container.x += (Math.round(_loc5_.x * _loc6_) / _loc6_ - _loc5_.x) / _loc4_;
         container.y += (Math.round(_loc5_.y * _loc6_) / _loc6_ - _loc5_.y) / _loc4_;
      }
      
      private static function designMatrix(node:flash.display.DisplayObject, holder:flash.display.DisplayObjectContainer) : Matrix
      {
         var _loc4_:Matrix = node.transform.matrix;
         if(node is TextField && deviceText(node as TextField))
         {
            _loc4_.setTo(node.scaleY,0,0,node.scaleY,node.x + 2 * (node.scaleX - node.scaleY),node.y);
         }
         else if(node is TextField)
         {
            _loc4_.tx = node.x;
            _loc4_.ty = node.y;
         }
         if(node == holder)
         {
            return _loc4_;
         }
         var _loc3_:flash.display.DisplayObjectContainer = node.parent;
         while(_loc3_ != null)
         {
            _loc4_.concat(_loc3_.transform.matrix);
            if(_loc3_ == holder)
            {
               return _loc4_;
            }
            _loc3_ = _loc3_.parent;
         }
         throw new Error("Chat prompt art is not under the chat holder");
      }
      
      private static function deviceText(field:TextField) : Boolean
      {
         return !field.embedFonts && field.rotation == 0 && field.scaleY > 0;
      }
      
      private static function copyField(field:TextField, text:String, color:uint) : TextField
      {
         var _loc5_:TextField = new TextField();
         var _loc4_:Rectangle = field.getBounds(field);
         _loc5_.width = deviceText(field) ? _loc4_.width * field.scaleX / field.scaleY : _loc4_.width;
         _loc5_.height = _loc4_.height;
         _loc5_.defaultTextFormat = field.defaultTextFormat;
         _loc5_.embedFonts = field.embedFonts;
         _loc5_.antiAliasType = field.antiAliasType;
         _loc5_.gridFitType = field.gridFitType;
         _loc5_.sharpness = field.sharpness;
         _loc5_.thickness = field.thickness;
         _loc5_.multiline = field.multiline;
         _loc5_.wordWrap = field.wordWrap;
         _loc5_.background = field.background;
         _loc5_.backgroundColor = field.backgroundColor;
         _loc5_.border = field.border;
         _loc5_.borderColor = field.borderColor;
         _loc5_.filters = field.filters;
         _loc5_.selectable = false;
         _loc5_.text = text;
         TextUtil.addOverhangSlack(_loc5_);
         _loc5_.textColor = color;
         return _loc5_;
      }
      
      public function show(value:Boolean) : void
      {
         if(mDisposed || mLabel.visible == value)
         {
            return;
         }
         mLabel.visible = value;
         if(mChanged != null)
         {
            mChanged();
         }
      }
      
      internal function get labelShown() : Boolean
      {
         return !mDisposed && mLabel.visible;
      }
      
      internal function get sendButton() : StarlingButton
      {
         return mSend;
      }
      
      internal function get logButton() : StarlingButton
      {
         return mLog;
      }
      
      internal function node(path:String) : starling.display.DisplayObject
      {
         return path.length == 0 ? mBar : (mView != null ? mView.node(path) : null);
      }
      
      private function bake() : Boolean
      {
         try
         {
            if(mDisposed)
            {
               return true;
            }
            if(Starling.current == null || !Starling.current.contextValid || mBar.stage == null)
            {
               return false;
            }
            if(mView == null)
            {
               buildBar();
            }
            if(mLabelArt == null)
            {
               placeLabel();
            }
            mRetry = null;
            mLabelSource = null;
            if(mChanged != null)
            {
               mChanged();
            }
            return true;
         }
         catch(error:Error)
         {
            if(error is HudFatalError || !mBakeFailed)
            {
               StarlingHud.reportError(error);
            }
            mBakeFailed = true;
            if(!(error is HudFatalError))
            {
               return false;
            }
            var _loc5_:Boolean = true;
         }
         return _loc5_;
      }
      
      private function buildBar() : void
      {
         var _loc12_:MovieClip = null;
         var _loc6_:MovieClip = null;
         var _loc10_:String = null;
         var _loc3_:String = null;
         var _loc5_:int = 0;
         var _loc13_:MovieClip = null;
         var _loc7_:ArtNode = null;
         var _loc11_:Vector.<String> = undefined;
         var _loc4_:Number = BakeScale.forDisplay(mBar);
         var _loc14_:String = mBarKey + "|" + BakedPages.scaleKey(_loc4_);
         var _loc2_:ArtNode = HudArt.content(_loc14_);
         if(_loc2_ == null)
         {
            _loc12_ = new mModel() as MovieClip;
            _loc6_ = _loc12_ != null ? _loc12_.getChildByName("UI_chat") as MovieClip : null;
            if(_loc6_ == null || _loc6_.getChildByName("textField") == null)
            {
               HudArt.fatal("Missing Starling chat bar art: " + mBarKey);
            }
            HudArtConverter.stopTree(_loc12_);
            _loc2_ = new ArtNode();
            _loc2_.name = "UI_chat";
            _loc2_.key = _loc14_;
            try
            {
               _loc2_.children.push(bakePart(_loc6_,"chat_bar",_loc14_,_loc4_));
               for each(_loc10_ in new <String>["chat_btn","log_btn"])
               {
                  _loc13_ = _loc6_.getChildByName(_loc10_) as MovieClip;
                  if(_loc13_ == null || _loc13_.getChildByName("up") == null)
                  {
                     HudArt.fatal("Missing Starling chat button art: " + _loc10_);
                  }
                  _loc7_ = new ArtNode();
                  _loc7_.name = _loc10_;
                  _loc7_.matrix = _loc13_.transform.matrix;
                  _loc2_.children.push(_loc7_);
                  _loc11_ = new Vector.<String>(0);
                  _loc5_ = 0;
                  while(_loc5_ < _loc13_.numChildren)
                  {
                     _loc3_ = _loc13_.getChildAt(_loc5_).name;
                     if(_loc3_ == "up" || _loc3_ == "over" || _loc3_ == "down" || _loc3_ == "label")
                     {
                        _loc11_.push(_loc3_);
                     }
                     _loc5_++;
                  }
                  for each(_loc3_ in _loc11_)
                  {
                     _loc7_.children.push(bakePart(_loc13_,_loc3_,_loc14_ + "|" + _loc10_,_loc4_ * BakeScale.magnitude(_loc7_.matrix)));
                  }
               }
            }
            catch(error:Error)
            {
               _loc2_.release(HudArt.pages);
               throw error;
            }
            HudArt.storeContent(_loc14_,_loc2_);
         }
         var _loc8_:ArtView = ArtView.build(_loc2_,mTicker);
         mBar.addChild(_loc8_.root);
         mView = _loc8_;
         snap(mBar,_loc8_.root);
         var _loc1_:starling.display.DisplayObject = mBar.parent;
         var _loc9_:StarlingButton = new StarlingButton(_loc8_,"chat_bar",_loc1_);
         mInput.add(_loc9_,false);
         mButtons.push(_loc9_);
         mSend = button(_loc8_,"chat_btn",_loc1_,mChat.chatSendButton.releaseCallback);
         mLog = button(_loc8_,"log_btn",_loc1_,mChat.chatLogButton.releaseCallback);
         if(mReady != null)
         {
            mReady();
         }
      }
      
      private function button(view:ArtView, path:String, space:starling.display.DisplayObject, release:Function) : StarlingButton
      {
         var _loc5_:StarlingButton = new StarlingButton(view,path,space);
         _loc5_.releaseCallback = release;
         mInput.add(_loc5_);
         mButtons.push(_loc5_);
         return _loc5_;
      }
      
      private function placeLabel() : void
      {
         var _loc3_:Number = BakeScale.forDisplay(mLabel);
         var _loc4_:String = mLabelKey + "|" + BakedPages.scaleKey(_loc3_);
         var _loc2_:ArtNode = HudArt.content(_loc4_);
         if(_loc2_ == null)
         {
            _loc2_ = new ArtNode();
            _loc2_.cell = _loc2_.hold(HudArt.bakeContent(_loc4_,mLabelSource,_loc3_),HudArt.pages);
            HudArt.storeContent(_loc4_,_loc2_);
         }
         _loc2_.retainView();
         mLabelArt = _loc2_;
         var _loc1_:BakedImage = new BakedImage(_loc2_.cell);
         mLabel.addChild(_loc1_);
         snap(mLabel,_loc1_);
      }
      
      public function dispose() : void
      {
         var _loc1_:StarlingButton = null;
         var _loc2_:int = 0;
         if(mDisposed)
         {
            return;
         }
         mDisposed = true;
         if(mRetry != null && mTicker != null)
         {
            mTicker.cancelBake(mRetry);
         }
         mRetry = null;
         for each(_loc1_ in mButtons)
         {
            if(mInput != null)
            {
               mInput.remove(_loc1_);
            }
            _loc1_.dispose();
         }
         mButtons.length = 0;
         mSend = mLog = null;
         if(mView != null)
         {
            mView.dispose();
         }
         mView = null;
         mBar.removeFromParent(true);
         mLabel.removeFromParent(true);
         if(mLabelArt != null)
         {
            mLabelArt.releaseView();
         }
         mLabelArt = null;
         _loc2_ = 0;
         while(_loc2_ < mFlashParts.length)
         {
            mFlashParts[_loc2_].visible = mFlashShown[_loc2_];
            _loc2_++;
         }
         mFlashParts.length = mFlashShown.length = 0;
         mClip = null;
         mModel = null;
         mLabelSource = null;
         mChanged = mReady = null;
         mTicker = null;
         mInput = null;
         mChat = null;
         mFacade = null;
      }
   }
}

