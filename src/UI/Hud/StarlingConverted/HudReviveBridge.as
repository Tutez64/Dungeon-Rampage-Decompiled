package UI.Hud.StarlingConverted
{
   import Actor.StateMachine.ActorReviveState;
   import Collections.IMapIterator;
   import DistributedObjects.HeroGameObject;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   
   public class HudReviveBridge
   {
      
      public function HudReviveBridge()
      {
         super();
      }
      
      public static function refresh(facade:DBFacade, hud:IGameHud, hero:HeroGameObjectOwner) : void
      {
         if(facade.hud != hud || hero == null || hud.ownedHero != hero)
         {
            return;
         }
         refreshActor(hud,hero);
         if(hero.distributedDungeonFloor == null)
         {
            return;
         }
         var _loc4_:IMapIterator = hero.distributedDungeonFloor.remoteHeroes.iterator() as IMapIterator;
         while(_loc4_.hasNext())
         {
            refreshActor(hud,_loc4_.next() as HeroGameObject);
         }
      }
      
      private static function refreshActor(hud:IGameHud, hero:HeroGameObject) : void
      {
         if(hero == null || hero.stateMachine == null)
         {
            return;
         }
         var _loc3_:ActorReviveState = hero.stateMachine.currentState as ActorReviveState;
         if(_loc3_ != null)
         {
            _loc3_.refreshHudControllerIcons();
         }
      }
   }
}

