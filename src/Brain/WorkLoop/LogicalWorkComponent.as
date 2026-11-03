package Brain.WorkLoop
{
   import Brain.Facade.Facade;
   
   public class LogicalWorkComponent extends WorkComponent
   {
      
      public function LogicalWorkComponent(facade:Facade, ownerName:String = null, category:String = "brain")
      {
         super(facade,facade.logicalWorkManager,ownerName,category);
      }
   }
}

