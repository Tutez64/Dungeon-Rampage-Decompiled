package UI.EquipPicker
{
   import Account.AvatarInfo;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Events.DBAccountResponseEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMHero;
   import flash.display.MovieClip;
   
   public class StuffWithEquipPicker extends UIObject
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mEventComponent:EventComponent;
      
      private var mHeroSlots:Vector.<HeroElement>;
      
      private var mTotalGMHeroes:uint;
      
      private var mShiftLeft:UIButton;
      
      private var mShiftRight:UIButton;
      
      private var mSetSelectedHeroCallback:Function;
      
      private var mGetSelectedHeroCallback:Function;
      
      private var mSelectedHeroIndex:int = -1;
      
      private var mCurrentStartIndex:uint = 0;
      
      public function StuffWithEquipPicker(dbFacade:DBFacade, root:MovieClip, heroTooltipClass:Class, getSelectedHeroIndexCallback:Function = null, setSelectedHeroIndexCallback:Function = null)
      {
         super(dbFacade,root);
         mDBFacade = dbFacade;
         mEventComponent = new EventComponent(mDBFacade);
         mSetSelectedHeroCallback = setSelectedHeroIndexCallback;
         mGetSelectedHeroCallback = getSelectedHeroIndexCallback;
         mHeroSlots = new Vector.<HeroElement>();
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_0,heroTooltipClass,function():void
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_1,heroTooltipClass,function():void
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_2,heroTooltipClass,function():void
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_3,heroTooltipClass,function():void
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_4,heroTooltipClass,function():void
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_5,heroTooltipClass,function():void
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_6,heroTooltipClass,function():void
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,mRoot.hero_slot_7,heroTooltipClass,function():void
         {
         }));
         mShiftLeft = new UIButton(mDBFacade,mRoot.shift_left);
         mShiftLeft.releaseCallback = shiftLeft;
         mShiftRight = new UIButton(mDBFacade,mRoot.shift_right);
         mShiftRight.releaseCallback = shiftRight;
         mShiftLeft.visible = false;
         mShiftRight.visible = false;
         mTotalGMHeroes = mDBFacade.gameMaster.Heroes.length;
         mRoot.label.text = Locale.getString("INVENTORY_STUFF_DESCRIPTION");
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",function(param1:DBAccountResponseEvent):void
         {
            refresh();
         });
      }
      
      private function populateHeroSlots() : void
      {
         var _loc2_:* = 0;
         var _loc3_:Vector.<GMHero> = mDBFacade.gameMaster.Heroes;
         var _loc1_:uint = mCurrentStartIndex;
         _loc2_ = 0;
         while(_loc2_ < mHeroSlots.length)
         {
            mHeroSlots[_loc2_].clear();
            if(_loc1_ < _loc3_.length && (!_loc3_[_loc1_].Hidden || mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes",false)))
            {
               mHeroSlots[_loc2_].gmHero = _loc3_[_loc1_];
            }
            else
            {
               mHeroSlots[_loc2_].enabled = false;
            }
            _loc1_++;
            _loc2_++;
         }
         updateShiftButtons();
      }
      
      private function updateShiftButtons() : void
      {
         if(mCurrentStartIndex == 0)
         {
            mShiftLeft.enabled = false;
         }
         else
         {
            mShiftLeft.enabled = true;
         }
         var _loc1_:uint = mCurrentStartIndex + mHeroSlots.length;
         if(_loc1_ < mTotalGMHeroes)
         {
            mShiftRight.enabled = true;
         }
         else
         {
            mShiftRight.enabled = false;
         }
      }
      
      private function shiftLeft() : void
      {
         mCurrentStartIndex = mCurrentStartIndex - 1;
         populateHeroSlots();
      }
      
      private function shiftRight() : void
      {
         mCurrentStartIndex = mCurrentStartIndex + 1;
         populateHeroSlots();
      }
      
      override public function destroy() : void
      {
         mEventComponent.destroy();
         mDBFacade = null;
         super.destroy();
      }
      
      public function show() : void
      {
         mRoot.visible = true;
      }
      
      public function hide() : void
      {
         mRoot.visible = false;
      }
      
      public function refresh(resync:Boolean = false) : void
      {
         if(selectedHeroIndex == -1 || resync)
         {
            setActiveAvatarAsCurrentSelection();
         }
         populateHeroSlots();
      }
      
      private function setActiveAvatarAsCurrentSelection() : void
      {
         var _loc2_:Array = null;
         var _loc1_:AvatarInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
         if(_loc1_ == null)
         {
            Logger.warn("No active avatar set on account id: " + mDBFacade.accountId);
            _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.avatars.keysToArray();
            if(_loc2_ == null)
            {
               Logger.error("No avatars found on account id: " + mDBFacade.accountId);
               return;
            }
            _loc1_ = mDBFacade.dbAccountInfo.inventoryInfo.avatars.itemFor(_loc2_[0]) as AvatarInfo;
            if(_loc1_ == null)
            {
               Logger.fatal("Could not get avatar info for key: " + _loc2_[0] + " Unable to get active avatar.");
               return;
            }
         }
         selectedHeroIndex = findHeroIndex(_loc1_.avatarType);
      }
      
      private function get selectedHeroIndex() : int
      {
         if(mGetSelectedHeroCallback != null)
         {
            mSelectedHeroIndex = mGetSelectedHeroCallback();
         }
         return mSelectedHeroIndex;
      }
      
      private function set selectedHeroIndex(val:int) : void
      {
         mSelectedHeroIndex = val;
         if(mSetSelectedHeroCallback != null)
         {
            mSetSelectedHeroCallback(mSelectedHeroIndex);
         }
      }
      
      private function heroClicked(heroElement:HeroElement, owned:Boolean) : void
      {
         var _loc3_:uint = mHeroSlots.indexOf(heroElement) + mCurrentStartIndex;
         if(selectedHeroIndex == _loc3_)
         {
            return;
         }
         selectedHeroIndex = _loc3_;
         determineSelectedElement();
         refresh();
      }
      
      private function determineSelectedElement() : void
      {
         var _loc1_:* = 0;
         _loc1_ = 0;
         while(_loc1_ < mHeroSlots.length)
         {
            if(_loc1_ + mCurrentStartIndex == selectedHeroIndex)
            {
               mHeroSlots[_loc1_].select();
            }
            else
            {
               mHeroSlots[_loc1_].deselect();
            }
            _loc1_++;
         }
      }
      
      private function setCurrentIndexToShowSelectedHero() : void
      {
         if(selectedHeroIndex < mHeroSlots.length)
         {
            mCurrentStartIndex = 0;
            return;
         }
         mCurrentStartIndex = selectedHeroIndex - (mHeroSlots.length - 1);
      }
      
      private function findHeroIndex(avatarId:uint) : uint
      {
         var _loc2_:* = 0;
         var _loc3_:Vector.<GMHero> = mDBFacade.gameMaster.Heroes;
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            if(avatarId == _loc3_[_loc2_].Id)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         Logger.error("Unable to find gmHero for active avatar Id: " + avatarId);
         return 0;
      }
   }
}

