package UI.Hud.StarlingConverted
{
   import Actor.Buffs.BuffGameObject;
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import flash.display.MovieClip;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   
   public class StarlingBuff
   {
      
      private var mBuff:BuffGameObject;
      
      private var mView:ArtView;
      
      private var mButton:StarlingButton;
      
      private var mTooltip:StarlingTooltip;
      
      private var mClip:MovieClip;
      
      private var mIcon:StarlingHudIcon;
      
      private var mCooldown:TimelineView;
      
      private var mInput:StarlingInput;
      
      private var mChanged:Function;
      
      public function StarlingBuff(facade:DBFacade, ticker:HudTicker, input:StarlingInput, parent:DisplayObjectContainer, buff:BuffGameObject, changed:Function)
      {
         var _loc7_:Class = null;
         var _loc8_:MovieClip = null;
         super();
         mBuff = buff;
         mInput = input;
         mChanged = changed;
         try
         {
            mView = ArtView.build(HudArt.art("buff_cooldown_icon"),ticker);
            parent.addChild(mView.root);
            _loc7_ = HudArt.swfClass("buff_cooldown_icon");
            _loc8_ = new _loc7_() as MovieClip;
            HudArtConverter.stopTree(_loc8_);
            mClip = _loc8_.tooltip;
            mButton = new StarlingButton(mView,"",parent);
            mTooltip = new StarlingTooltip(facade,mButton.root,parent,mClip);
            mButton.rollOverCallback = mTooltip.rollOver;
            mButton.rollOutCallback = mTooltip.hide;
            input.add(mButton,false);
            mIcon = new StarlingHudIcon(facade,ticker,mView.node("graphic") as DisplayObjectContainer,changed);
            mIcon.load(buff.buffData.IconSwf,buff.buffData.IconName,0.75,0.75);
            mCooldown = mView.node("cooldown") as TimelineView;
            updateInstance();
         }
         catch(error:Error)
         {
            dispose();
            throw error;
         }
      }
      
      internal function rebuild(facade:DBFacade, ticker:HudTicker, input:StarlingInput, parent:DisplayObjectContainer) : StarlingBuff
      {
         var _loc5_:StarlingBuff = null;
         try
         {
            _loc5_ = new StarlingBuff(facade,ticker,input,parent,mBuff,mChanged);
            _loc5_.root.x = root.x;
            _loc5_.root.y = root.y;
            if(mCooldown != null && _loc5_.mCooldown != null)
            {
               if(mCooldown.isPlaying)
               {
                  _loc5_.mCooldown.play(mCooldown.playHead);
               }
               else
               {
                  _loc5_.mCooldown.gotoAndStop(mCooldown.currentFrame);
               }
            }
            return _loc5_;
         }
         catch(error:Error)
         {
            if(_loc5_ != null)
            {
               _loc5_.dispose();
            }
            throw error;
         }
         finally
         {
            dispose();
         }
         return null;
      }
      
      public function updateInstance() : void
      {
         var _loc2_:String = null;
         if(mBuff.isDestroyed)
         {
            return;
         }
         TextUtil.setText(mClip.title_label,GameMasterLocale.getGameMasterSubString("BUFF_NAME",mBuff.buffData.Constant));
         TextUtil.setText(mClip.description_label,GameMasterLocale.getGameMasterSubString("BUFF_DESCRIPTION",mBuff.buffData.Constant) + mBuff.buffData.getStacksDescription(mBuff.instanceCount));
         var _loc1_:StarlingText = mView.node("quantity") as StarlingText;
         if(_loc1_ != null)
         {
            _loc2_ = mBuff.instanceCount.toString();
            _loc1_.setContent(_loc2_,"glyphs");
         }
         if(mCooldown != null)
         {
            mCooldown.stageRate = false;
            mCooldown.playRate = 4.1 / mBuff.buffData.Duration;
            mCooldown.play();
         }
         mChanged();
      }
      
      public function position(index:int, condensed:Boolean) : void
      {
         mView.root.x = (condensed ? 455 : 424) + 63 * index;
         mView.root.y = condensed ? 865 : 980;
         mChanged();
      }
      
      public function rebindInput(input:StarlingInput) : void
      {
         if(mInput != null)
         {
            mInput.remove(mButton);
         }
         mInput = input;
         input.add(mButton,false);
      }
      
      public function detachInput() : void
      {
         mTooltip.hide();
         if(mInput != null)
         {
            mInput.remove(mButton);
         }
         mInput = null;
      }
      
      public function get root() : DisplayObject
      {
         return mView.root;
      }
      
      internal function get art() : ArtNode
      {
         return mView.artNode("");
      }
      
      public function get buff() : BuffGameObject
      {
         return mBuff;
      }
      
      public function hideTooltip() : void
      {
         mTooltip.hide();
      }
      
      public function dispose() : void
      {
         try
         {
            if(mInput != null)
            {
               mInput.remove(mButton);
            }
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
         mInput = null;
         StarlingHud.disposeResource(mTooltip);
         StarlingHud.disposeResource(mButton);
         StarlingHud.disposeResource(mIcon);
         StarlingHud.disposeResource(mView);
         mTooltip = null;
         mButton = null;
         mIcon = null;
         mView = null;
         mCooldown = null;
         mChanged();
      }
   }
}

