package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Combat.Weapon.WeaponController;
   import Facade.DBFacade;
   
   public class CoolDownAttackTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "startCooldown";
      
      private var mWeaponController:WeaponController;
      
      public function CoolDownAttackTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, weaponController:WeaponController, actionObj:Object)
      {
         super(actorGameObject,actorView,dbFacade);
         mWeaponController = weaponController;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, weaponController:WeaponController, actionObj:Object) : CoolDownAttackTimelineAction
      {
         if(actorGameObject.isOwner)
         {
            return new CoolDownAttackTimelineAction(actorGameObject,actorView,dbFacade,weaponController,actionObj);
         }
         return null;
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mWeaponController.startCooldown();
      }
      
      override public function destroy() : void
      {
         mWeaponController = null;
         super.destroy();
      }
   }
}

