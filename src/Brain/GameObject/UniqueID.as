package Brain.GameObject
{
   import Brain.Facade.Facade;
   
   public class UniqueID
   {
      
      private var mId:uint = 0;
      
      public function UniqueID(facade:Facade, val:uint, go:GameObject)
      {
         super();
         mId = val;
         facade.gameObjectManager.addIdReference(val,go);
      }
      
      public function get id() : uint
      {
         return mId;
      }
      
      public function destroy(facade:Facade) : void
      {
         facade.gameObjectManager.removeIdReference(this);
         mId = 0;
      }
   }
}

