package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   import GameMasterDictionary.GMActor;
   
   public class HideTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "visible";
      
      protected var value:Boolean = false;
      
      protected var persist:Boolean = false;
      
      public function HideTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object)
      {
         super(actorGameObject,actorView,dbFacade);
         value = actionObj.value;
         persist = actionObj.persist === true;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : HideTimelineAction
      {
         return new HideTimelineAction(actorGameObject,actorView,dbFacade,actionObj);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mActorGameObject.cancelPersistentHideWatch();
         mActorGameObject.view.root.visible = value;
      }
      
      override public function stop() : void
      {
         if(isDeadProp())
         {
            return;
         }
         if(persist && mActorGameObject.hitPoints != 0 && mTimeline != null && mTimeline.finishedNaturally)
         {
            mActorGameObject.notePersistentHide();
            return;
         }
         mActorGameObject.cancelPersistentHideWatch();
         mActorGameObject.view.root.visible = true;
      }
      
      private function isDeadProp() : Boolean
      {
         if(mActorGameObject.hitPoints != 0)
         {
            return false;
         }
         if(mActorGameObject.actorData == null || mActorGameObject.actorData.gMActor == null)
         {
            return false;
         }
         return mActorGameObject.actorData.gMActor.CharType == GMActor.CHAR_TYPE_PROP;
      }
   }
}

