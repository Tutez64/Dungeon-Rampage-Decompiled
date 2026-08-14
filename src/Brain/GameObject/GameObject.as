package Brain.GameObject
{
   import Brain.Facade.Facade;
   import Brain.Utils.MemoryTracker;
   
   public class GameObject
   {
      
      protected var mFacade:Facade;
      
      protected var mId:UniqueID;
      
      protected var mIsInitialized:Boolean = false;
      
      protected var mIsDestroyed:Boolean = false;
      
      public function GameObject(facade:Facade, remoteId:uint = 0)
      {
         super();
         if(remoteId == 0)
         {
            mId = new LocalUniqueID(facade,this);
         }
         else
         {
            mId = new UniqueID(facade,remoteId,this);
         }
         mFacade = facade;
         MemoryTracker.track(this,"GameObject id=" + mId.id + " - created in GameObject()","brain");
      }
      
      public function get isInitialized() : Boolean
      {
         return mIsInitialized;
      }
      
      public function get isDestroyed() : Boolean
      {
         return mIsDestroyed;
      }
      
      public function init() : void
      {
         mIsInitialized = true;
      }
      
      public function getTrueObject() : GameObject
      {
         return this;
      }
      
      public function destroy() : void
      {
         if(!mIsDestroyed)
         {
            mId.destroy(mFacade);
            mId = null;
            mFacade = null;
            mIsDestroyed = true;
         }
      }
      
      public function get id() : uint
      {
         return mId.id;
      }
      
      public function newNetworkChild(child:GameObject) : void
      {
      }
      
      public function InterestClosure() : void
      {
      }
   }
}

