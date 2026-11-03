package UI.Hud.StarlingConverted
{
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DistributedObjects.NPCGameObject;
   import Events.GameObjectEvent;
   import Events.HpEvent;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import flash.display.MovieClip;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   
   public class StarlingPetPortrait
   {
      
      private var mFacade:DBFacade;
      
      private var mView:ArtView;
      
      private var mPet:NPCGameObject;
      
      private var mDead:Boolean;
      
      private var mEvents:EventComponent;
      
      private var mWork:LogicalWorkComponent;
      
      private var mTask:Task;
      
      private var mHp:StarlingBar;
      
      private var mCooldown:TimelineView;
      
      private var mIcon:StarlingHudIcon;
      
      private var mPetButton:StarlingButton;
      
      private var mNoneButton:StarlingButton;
      
      private var mTooltip:StarlingTooltip;
      
      private var mNoneTooltip:StarlingTooltip;
      
      private var mClip:MovieClip;
      
      private var mInput:StarlingInput;
      
      private var mChanged:Function;
      
      private var mSeconds:Number;
      
      private var mRespawnPrefix:String;
      
      public function StarlingPetPortrait(facade:DBFacade, view:ArtView, ticker:HudTicker, input:StarlingInput, space:DisplayObject, model:MovieClip, pet:NPCGameObject, changed:Function)
      {
         var _loc10_:MovieClip = null;
         super();
         mFacade = facade;
         mView = view;
         mPet = pet;
         mInput = input;
         mChanged = changed;
         mEvents = new EventComponent(facade);
         mWork = new LogicalWorkComponent(facade,"StarlingPetPortrait");
         mClip = model.pet.tooltip;
         HudArtConverter.stopTree(model.pet);
         mPetButton = new StarlingButton(view,"pet",space);
         mTooltip = new StarlingTooltip(facade,mPetButton.root,space,mClip);
         mPetButton.rollOverCallback = mTooltip.rollOver;
         mPetButton.rollOutCallback = mTooltip.hide;
         input.add(mPetButton,false,true);
         var _loc9_:MovieClip = model.hasOwnProperty("pet_none") ? model.pet_none as MovieClip : null;
         if(_loc9_ != null && view.node("pet_none") != null)
         {
            HudArtConverter.stopTree(_loc9_);
            mNoneButton = new StarlingButton(view,"pet_none",space);
            _loc10_ = _loc9_.tooltip as MovieClip;
            if(_loc10_ != null)
            {
               Locale.setText(_loc10_.title_label,"NO_PET_EQUIPPED_TOOLTIP_TITLE");
               Locale.setText(_loc10_.description_label,"NO_PET_EQUIPPED_TOOLTIP_DESCRIPTION");
               mNoneTooltip = new StarlingTooltip(facade,mNoneButton.root,space,_loc10_);
               mNoneButton.rollOverCallback = mNoneTooltip.rollOver;
               mNoneButton.rollOutCallback = mNoneTooltip.hide;
            }
            input.add(mNoneButton,false,true);
         }
         mHp = new StarlingBar(view.node("pet.hp.hpBar"),null,ticker);
         mCooldown = view.node("pet.cooldown") as TimelineView;
         if(mCooldown != null)
         {
            mCooldown.stop();
            mCooldown.stageRate = false;
         }
         show("pet.hp_death",false);
         show("pet.cooldown",false);
         show("pet",pet != null);
         show("pet_none",pet == null);
         if(pet != null)
         {
            TextUtil.setText(mClip.title_label,GameMasterLocale.getGameMasterSubString("PET_NAME",pet.gmNpc.Constant).toUpperCase());
            TextUtil.setText(mClip.description_label,GameMasterLocale.getGameMasterSubString("PET_DESCRIPTION",pet.gmNpc.Constant));
            mEvents.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE",pet.id),hpChanged);
            mHp.value = pet.maxHitPoints > 0 ? pet.hitPoints / pet.maxHitPoints : 0;
            mIcon = new StarlingHudIcon(facade,ticker,view.node("pet.graphic") as DisplayObjectContainer,changed);
            loadIcon(pet);
         }
         changed();
      }
      
      private function loadIcon(pet:NPCGameObject) : void
      {
         mIcon.load(pet.actorData.gMActor.IconSwfFilepath,pet.actorData.gMActor.IconName,1.1764705882352942);
      }
      
      private function hpChanged(event:HpEvent) : void
      {
         try
         {
            mHp.value = event.maxHp > 0 ? event.hp / event.maxHp : 0;
            mChanged();
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
      }
      
      private function show(path:String, value:Boolean) : void
      {
         var _loc3_:ArtDisplay = mView.node(path) as ArtDisplay;
         if(_loc3_ != null)
         {
            _loc3_.setHudVisibility(value);
         }
      }
      
      public function petDeath() : void
      {
         if(mPet == null)
         {
            return;
         }
         mDead = true;
         mEvents.removeAllListeners();
         mSeconds = mPet.gmNpc.RespawnT;
         if(mSeconds > 0)
         {
            mRespawnPrefix = Locale.getString("PET_RESPAWNS_IN").replace(/[:\s]+$/,"") + ": ";
            loadIcon(mPet);
            show("pet.hp_death",true);
            show("pet.cooldown",true);
            if(mCooldown != null)
            {
               mCooldown.playRate = mCooldown.art.totalFrames * mFacade.gameClock.tickLength / mPet.gmNpc.RespawnT;
               mCooldown.play();
            }
            updateDescription();
            mTask = mWork.doEverySeconds(1,countdown);
         }
         else
         {
            show("pet",false);
         }
         mPet = null;
         mChanged();
      }
      
      private function updateDescription() : void
      {
         TextUtil.setText(mClip.description_label,mRespawnPrefix + mSeconds.toString());
      }
      
      private function countdown(clock:GameClock) : void
      {
         try
         {
            mSeconds = mSeconds - 1;
            updateDescription();
            if(mSeconds <= 0)
            {
               mTask.destroy();
               mTask = null;
            }
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
      }
      
      public function get petNPCGameObject() : NPCGameObject
      {
         return mPet;
      }
      
      public function get isDead() : Boolean
      {
         return mDead;
      }
      
      public function hideTooltip() : void
      {
         mTooltip.hide();
         if(mNoneTooltip != null)
         {
            mNoneTooltip.hide();
         }
      }
      
      public function dispose() : void
      {
         StarlingHud.disposeResource(mTask,"destroy");
         StarlingHud.disposeResource(mWork,"destroy");
         StarlingHud.disposeResource(mEvents,"destroy");
         StarlingHud.disposeResource(mTooltip);
         StarlingHud.disposeResource(mNoneTooltip);
         try
         {
            mInput.remove(mPetButton);
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
         try
         {
            if(mNoneButton != null)
            {
               mInput.remove(mNoneButton);
            }
         }
         catch(noneError:Error)
         {
            StarlingHud.reportError(noneError);
         }
         StarlingHud.disposeResource(mPetButton);
         StarlingHud.disposeResource(mNoneButton);
         StarlingHud.disposeResource(mHp);
         StarlingHud.disposeResource(mIcon);
         StarlingHud.disposeResource(mCooldown,"stop");
         show("pet",false);
         show("pet_none",false);
         mPet = null;
         mChanged();
      }
   }
}

