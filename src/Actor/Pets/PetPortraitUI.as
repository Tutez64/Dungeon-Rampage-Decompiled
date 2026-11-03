package Actor.Pets
{
   import Account.ItemInfo;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Render.MovieClipRenderer;
   import Brain.UI.UIObject;
   import Brain.UI.UIProgressBar;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DBGlobals.DBGlobal;
   import DistributedObjects.NPCGameObject;
   import Events.GameObjectEvent;
   import Events.HpEvent;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import flash.display.MovieClip;
   
   public class PetPortraitUI extends UIObject
   {
      
      private static const PET_PORTRAIT_ICON_SIZE:uint = 80;
      
      private static const PET_NON_RESPAWNING_DEATH_FADE_OUT_TIME:uint = 2;
      
      private static const PET_RESPAWNS_IN:String = "PET_RESPAWNS_IN";
      
      private var mRespawnTask:Task;
      
      private var mDBFacade:DBFacade;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mEventComponent:EventComponent;
      
      private var mPetNPCGameObject:NPCGameObject;
      
      private var mNoPetUI:UIObject;
      
      private var mHpBar:UIProgressBar;
      
      private var mCoolDownRenderer:MovieClipRenderer;
      
      private var mCoolDownClipLength:Number;
      
      private var mIsDead:Boolean = false;
      
      public function PetPortraitUI(dbFacade:DBFacade, root:MovieClip, petPortraitNoneClip:MovieClip, pet:NPCGameObject)
      {
         super(dbFacade,root,0,true);
         mDBFacade = dbFacade;
         if(petPortraitNoneClip)
         {
            mNoPetUI = new UIObject(mDBFacade,petPortraitNoneClip,0,true);
            if(mNoPetUI.tooltip)
            {
               Locale.setText(mNoPetUI.tooltip.title_label,"NO_PET_EQUIPPED_TOOLTIP_TITLE");
               Locale.setText(mNoPetUI.tooltip.description_label,"NO_PET_EQUIPPED_TOOLTIP_DESCRIPTION");
            }
         }
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"PetPortraitUI");
         mEventComponent = new EventComponent(mDBFacade);
         mPetNPCGameObject = pet;
         mRoot.visible = false;
         setupPetUI();
      }
      
      public function get petNPCGameObject() : NPCGameObject
      {
         return mPetNPCGameObject;
      }
      
      private function setupPetUI() : void
      {
         mHpBar = new UIProgressBar(mDBFacade,root.hp.hpBar);
         mRoot.hp_death.visible = false;
         if(mNoPetUI)
         {
            mNoPetUI.visible = false;
         }
         if(mPetNPCGameObject != null)
         {
            TextUtil.setText(mRoot.tooltip.description_label,GameMasterLocale.getGameMasterSubString("PET_DESCRIPTION",mPetNPCGameObject.gmNpc.Constant));
            TextUtil.setText(mRoot.tooltip.title_label,GameMasterLocale.getGameMasterSubString("PET_NAME",mPetNPCGameObject.gmNpc.Constant).toUpperCase());
            mEventComponent.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE",mPetNPCGameObject.id),function(param1:HpEvent):void
            {
               setHp(param1.hp,param1.maxHp);
            });
            setHp(mPetNPCGameObject.hitPoints,mPetNPCGameObject.maxHitPoints);
            ItemInfo.loadItemIcon(mPetNPCGameObject.actorData.gMActor.IconSwfFilepath,mPetNPCGameObject.actorData.gMActor.IconName,root.graphic,mDBFacade,80,DBGlobal.PET_ICON_NATIVE_SIZE);
            if(mNoPetUI)
            {
               mNoPetUI.visible = false;
            }
            mHpBar.visible = true;
            this.visible = true;
         }
         else
         {
            mHpBar.visible = false;
            if(mNoPetUI)
            {
               mNoPetUI.visible = true;
            }
            this.visible = false;
            this.hideTooltip();
         }
         mCoolDownRenderer = new MovieClipRenderer(mDBFacade,root.cooldown);
         mCoolDownRenderer.clip.visible = false;
         mCoolDownClipLength = root.cooldown.totalFrames * mDBFacade.gameClock.tickLength;
      }
      
      private function setHp(current:uint, max:uint) : void
      {
         mHpBar.value = current / max;
      }
      
      public function petDeath() : void
      {
         var _loc1_:Number = NaN;
         mIsDead = true;
         if(mPetNPCGameObject != null)
         {
            mEventComponent.removeListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE",mPetNPCGameObject.id));
            _loc1_ = mPetNPCGameObject.gmNpc.RespawnT;
            if(_loc1_ > 0)
            {
               handleRespawningPetDeath(_loc1_);
            }
         }
         mPetNPCGameObject = null;
      }
      
      private function handleRespawningPetDeath(respawnTimer:Number) : void
      {
         ItemInfo.loadItemIcon(mPetNPCGameObject.actorData.gMActor.IconSwfFilepath,mPetNPCGameObject.actorData.gMActor.IconName,root.graphic,mDBFacade,80,DBGlobal.PET_ICON_NATIVE_SIZE);
         mRoot.hp_death.visible = true;
         TextUtil.setText(root.tooltip.title_label,GameMasterLocale.getGameMasterSubString("PET_NAME",mPetNPCGameObject.gmNpc.Constant).toUpperCase());
         TextUtil.setText(root.tooltip.description_label,Locale.getString("PET_RESPAWNS_IN") + ": " + respawnTimer.toString());
         mCoolDownRenderer.playRate = mCoolDownClipLength / respawnTimer;
         mCoolDownRenderer.clip.visible = true;
         mCoolDownRenderer.play();
         if(mRespawnTask)
         {
            mRespawnTask.destroy();
         }
         mRespawnTask = mLogicalWorkComponent.doEverySeconds(1,function(param1:GameClock):void
         {
            respawnTimer = respawnTimer - 1;
            TextUtil.setText(root.tooltip.description_label,Locale.getString("PET_RESPAWNS_IN") + respawnTimer.toString());
            if(respawnTimer == 0)
            {
               if(mRespawnTask)
               {
                  mRespawnTask.destroy();
               }
               mRespawnTask = null;
            }
         });
      }
      
      public function get npcId() : int
      {
         if(mPetNPCGameObject.gmNpc)
         {
            return mPetNPCGameObject.id;
         }
         return -1;
      }
      
      public function get isDead() : Boolean
      {
         return mIsDead;
      }
      
      override public function destroy() : void
      {
         mLogicalWorkComponent.destroy();
         mDBFacade = null;
         mPetNPCGameObject = null;
         if(mRespawnTask)
         {
            mRespawnTask.destroy();
         }
         mRespawnTask = null;
         if(mNoPetUI)
         {
            mNoPetUI.destroy();
         }
         mNoPetUI = null;
         if(mCoolDownRenderer)
         {
            mCoolDownRenderer.destroy();
         }
         mCoolDownRenderer = null;
         if(mHpBar)
         {
            mHpBar.dontKillMyChildren = true;
            mHpBar.destroy();
         }
         mHpBar = null;
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
         super.destroy();
      }
   }
}

