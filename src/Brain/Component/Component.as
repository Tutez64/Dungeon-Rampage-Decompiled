package Brain.Component
{
   import Brain.Facade.Facade;
   
   public class Component
   {
      
      protected var mFacade:Facade;
      
      public function Component(facade:Facade)
      {
         super();
         mFacade = facade;
      }
      
      public function destroy() : void
      {
         mFacade = null;
      }
   }
}

