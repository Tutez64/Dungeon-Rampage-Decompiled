package Box2D.Dynamics.Contacts
{
   import flash.Boot;
   
   public class b2ContactRegister
   {
      
      public var primary:Boolean;
      
      public var poolCount:int;
      
      public var pool:b2Contact;
      
      public var destroyFcn:*;
      
      public var createFcn:*;
      
      public function b2ContactRegister()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         poolCount = 0;
      }
   }
}

