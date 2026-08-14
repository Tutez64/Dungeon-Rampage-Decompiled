package Brain.GameObject
{
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import org.as3commons.collections.Map;
   
   public class GameObjectManager
   {
      
      private var mGameObjects:Map = new Map();
      
      protected var mFacade:Facade;
      
      public function GameObjectManager(facade:Facade)
      {
         super();
         mFacade = facade;
      }
      
      public function isIdActive(id:uint) : Boolean
      {
         return mGameObjects.hasKey(id);
      }
      
      public function removeIdReference(uid:UniqueID) : void
      {
         if(mGameObjects.hasKey(uid.id))
         {
            mGameObjects.removeKey(uid.id);
         }
         else
         {
            Logger.error("GameObjectManager:removeIdReference Removing id not existing " + uid);
         }
      }
      
      public function addIdReference(id:uint, go:GameObject) : void
      {
         if(mGameObjects.hasKey(id))
         {
            Logger.error("GameObjectManager:addIdReference Adding Id That Already Exists " + id);
         }
         mGameObjects.add(id,go);
      }
      
      public function getReferenceFromId(id:uint) : GameObject
      {
         return mGameObjects.itemFor(id);
      }
   }
}

