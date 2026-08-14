package Collision
{
   import Box2D.Collision.Shapes.b2Shape;
   import DistributedObjects.Floor;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   
   public class HeroReviveSensor extends HeroOwnerSensor
   {
      
      protected var mCallback:Function;
      
      protected var mFinishedCallback:Function;
      
      public function HeroReviveSensor(dbFacade:DBFacade, distributedFloor:Floor, shape:b2Shape, team:uint)
      {
         super(dbFacade,distributedFloor,shape,team);
      }
      
      override public function destroy() : void
      {
         mCallback = null;
         mFinishedCallback = null;
         super.destroy();
      }
      
      override public function enterContact(actorId:uint) : void
      {
         var _loc2_:HeroGameObjectOwner = mDBFacade.gameObjectManager.getReferenceFromId(actorId) as HeroGameObjectOwner;
         if(_loc2_ && _loc2_.heroStateMachine && _loc2_.heroStateMachine.currentStateName != "ActorReviveState")
         {
            mCallback(_loc2_);
         }
      }
      
      override public function exitContact(actorId:uint) : void
      {
         var _loc2_:HeroGameObjectOwner = null;
         if(mDBFacade != null)
         {
            _loc2_ = mDBFacade.gameObjectManager.getReferenceFromId(actorId) as HeroGameObjectOwner;
            if(_loc2_ != null)
            {
               if(mFinishedCallback != null)
               {
                  mFinishedCallback();
               }
            }
         }
      }
      
      public function set callback(value:Function) : void
      {
         mCallback = value;
      }
      
      public function set finishedCallback(value:Function) : void
      {
         mFinishedCallback = value;
      }
   }
}

