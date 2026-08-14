package Brain.WorkLoop
{
   import Brain.Facade.Facade;
   
   public class LogicalWorkComponent extends WorkComponent
   {
      
      public function LogicalWorkComponent(facade:Facade, ownerName:String = null)
      {
         super(facade,facade.logicalWorkManager,ownerName);
      }
   }
}

