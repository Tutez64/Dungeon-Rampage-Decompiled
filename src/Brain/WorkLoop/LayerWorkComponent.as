package Brain.WorkLoop
{
   import Brain.Facade.Facade;
   
   public class LayerWorkComponent extends WorkComponent
   {
      
      public function LayerWorkComponent(dbFacade:Facade, ownerName:String = null)
      {
         super(dbFacade,dbFacade.layerRenderWorkManager,ownerName);
      }
   }
}

