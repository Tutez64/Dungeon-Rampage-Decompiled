package Brain.WorkLoop
{
   import Brain.Facade.Facade;
   
   public class PreRenderWorkComponent extends WorkComponent
   {
      
      public function PreRenderWorkComponent(dbFacade:Facade, ownerName:String = null)
      {
         super(dbFacade,dbFacade.preRenderWorkManager,ownerName);
      }
   }
}

