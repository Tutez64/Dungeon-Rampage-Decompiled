package UI.Training
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderController;
   import Brain.UI.UIObject;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class UIStatHelper
   {
      
      public static const MAX_PIPS_PER_LINE:int = 25;
      
      private var mDBFacade:DBFacade;
      
      private var mUIRoot:MovieClip;
      
      private var mStatName:String;
      
      private var mStatAmount:uint;
      
      private var mStatBars:Vector.<UIStatProgressBar>;
      
      private var mStatNameText:TextField;
      
      private var mStatIconRenderer:MovieClipRenderController;
      
      private var mStatIcon:MovieClip;
      
      private var mStatIconName:String;
      
      private var mStatIconTooltip:UIStatTooltip;
      
      private var mStatIconTooltipBar:UIObject;
      
      private var mTooltipBar:UIObject;
      
      public function UIStatHelper(dbFacade:DBFacade, tooltipClass:Class, rootClip:MovieClip)
      {
         super();
         mDBFacade = dbFacade;
         mUIRoot = rootClip;
         this.setupUI(tooltipClass);
      }
      
      private function setupUI(tooltipClass:Class) : void
      {
         var _loc2_:int = 0;
         var _loc4_:Array = [mUIRoot.training_meter01,mUIRoot.training_meter02,mUIRoot.training_meter03];
         var _loc3_:Array = [mUIRoot.training_meter01_full,mUIRoot.training_meter02_full,mUIRoot.training_meter03_full];
         mStatBars = new Vector.<UIStatProgressBar>();
         _loc2_ = 0;
         while(_loc2_ < 3)
         {
            mStatBars.push(new UIStatProgressBar(mDBFacade,_loc4_[_loc2_],_loc3_[_loc2_]));
            _loc2_++;
         }
         mStatIconTooltipBar = new UIObject(mDBFacade,mUIRoot.hit);
         mStatIconTooltip = new UIStatTooltip(mDBFacade,tooltipClass);
         mStatIconTooltipBar.tooltip = mStatIconTooltip;
         mStatIconTooltipBar.tooltipPos = new Point(-75,mUIRoot.hit.height * -0.5 + 25);
         mStatNameText = mUIRoot.training_meter_text;
         mTooltipBar = new UIObject(mDBFacade,mUIRoot.barTooltip_hit);
         mUIRoot.barTooltip.text = "0/75";
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         mDBFacade = null;
         mTooltipBar.destroy();
         _loc1_ = 0;
         while(_loc1_ < 3)
         {
            mStatBars[_loc1_].destroy();
            _loc1_++;
         }
         mStatBars = null;
         if(mStatIconRenderer)
         {
            mStatIconRenderer.destroy();
         }
         mStatIconTooltipBar.destroy();
         mStatIconTooltip.destroy();
      }
      
      public function get amount() : uint
      {
         return mStatAmount;
      }
      
      public function set statAmount(val:uint) : void
      {
         mStatAmount = val;
      }
      
      public function get statAmount() : uint
      {
         return mStatAmount;
      }
      
      public function set statName(val:String) : void
      {
         mStatName = val;
      }
      
      public function refresh(swfAsset:SwfAsset) : void
      {
         var _loc2_:Class = null;
         if(mDBFacade.gameMaster.statByConstant.itemFor(mStatName) != null)
         {
            mStatNameText.text = GameMasterLocale.getGameMasterSubString("STATS_NAME",mDBFacade.gameMaster.statByConstant.itemFor(mStatName).Constant).toUpperCase();
            mStatIconName = mDBFacade.gameMaster.statByConstant.itemFor(mStatName).IconName;
            mStatIconTooltip.statItem = mDBFacade.gameMaster.statByConstant.itemFor(mStatName);
         }
         else
         {
            mStatNameText.text = GameMasterLocale.getGameMasterSubString("STATS_NAME",mDBFacade.gameMaster.superStatByConstant.itemFor(mStatName).Constant).toUpperCase();
            mStatIconName = mDBFacade.gameMaster.superStatByConstant.itemFor(mStatName).IconName;
            mStatIconTooltip.superStatItem = mDBFacade.gameMaster.superStatByConstant.itemFor(mStatName);
         }
         if(mStatIcon)
         {
            mUIRoot.icon.removeChild(mStatIcon);
            mStatIconRenderer.destroy();
         }
         _loc2_ = swfAsset.getClass(mStatIconName);
         if(_loc2_ != null)
         {
            mStatIcon = new _loc2_();
            mStatIconRenderer = new MovieClipRenderController(mDBFacade,mStatIcon);
            mStatIconRenderer.play(0,true);
            mUIRoot.icon.addChild(mStatIcon);
         }
      }
      
      public function updateUI() : void
      {
         var _loc5_:int = 0;
         var _loc4_:uint = 25;
         var _loc3_:uint = 50;
         var _loc2_:uint = 75;
         var _loc6_:int = 0;
         if(mStatAmount == _loc2_)
         {
            _loc6_ = 3;
         }
         else if(mStatAmount >= _loc3_)
         {
            _loc6_ = 2;
         }
         else if(mStatAmount >= _loc4_)
         {
            _loc6_ = 1;
         }
         else
         {
            _loc6_ = 0;
         }
         _loc5_ = 0;
         while(_loc5_ < 3)
         {
            mStatBars[_loc5_].completed = false;
            mStatBars[_loc5_].value = 0;
            _loc5_++;
         }
         var _loc1_:int = mStatAmount % 25;
         _loc5_ = 0;
         while(_loc5_ < 3)
         {
            if(_loc5_ < _loc6_)
            {
               mStatBars[_loc5_].completed = true;
            }
            else if(_loc5_ == _loc6_)
            {
               mStatBars[_loc5_].value = _loc1_ / 25 * 0.995;
            }
            _loc5_++;
         }
         mUIRoot.barTooltip.text = mStatAmount.toString() + " / " + (25 * 3).toString();
      }
   }
}

