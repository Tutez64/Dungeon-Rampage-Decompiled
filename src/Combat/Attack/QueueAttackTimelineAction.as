package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Combat.Weapon.WeaponController;
   import Facade.DBFacade;
   
   public class QueueAttackTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "queueAttack";
      
      private var mWeaponController:WeaponController;
      
      private var mAttackToQueue:String;
      
      public function QueueAttackTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, weaponController:WeaponController, actionObj:Object)
      {
         super(actorGameObject,actorView,dbFacade);
         mWeaponController = weaponController;
         mAttackToQueue = actionObj.attackName;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, weaponController:WeaponController, actionObj:Object) : QueueAttackTimelineAction
      {
         if(actorGameObject.isOwner)
         {
            return new QueueAttackTimelineAction(actorGameObject,actorView,dbFacade,weaponController,actionObj);
         }
         return null;
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mWeaponController.queueAttack(mAttackToQueue);
      }
      
      override public function destroy() : void
      {
         mWeaponController = null;
         super.destroy();
      }
   }
}

