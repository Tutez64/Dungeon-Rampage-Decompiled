package Brain.Render
{
   import Brain.Facade.Facade;
   
   public class RendererFactory
   {
      
      protected var mFacade:Facade;
      
      protected var mBackend:IRenderingBackend;
      
      public function RendererFactory(facade:Facade, backend:IRenderingBackend)
      {
         super();
         mFacade = facade;
         mBackend = backend;
      }
      
      public function get backendType() : String
      {
         return mBackend.backendType;
      }
      
      public function get backend() : IRenderingBackend
      {
         return mBackend;
      }
      
      public function destroy() : void
      {
         mBackend = null;
         mFacade = null;
      }
   }
}

