package Brain.Render
{
   import Brain.Facade.Facade;
   
   public class FlashRendererFactory extends RendererFactory
   {
      
      public function FlashRendererFactory(facade:Facade, backend:IRenderingBackend)
      {
         super(facade,backend);
      }
   }
}

