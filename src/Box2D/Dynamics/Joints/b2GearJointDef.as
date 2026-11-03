package Box2D.Dynamics.Joints
{
   import flash.Boot;
   
   public class b2GearJointDef extends b2JointDef
   {
      
      public var ratio:Number;
      
      public var joint2:b2Joint;
      
      public var joint1:b2Joint;
      
      public function b2GearJointDef()
      {
         if(!Boot.skip_constructor)
         {
            super();
            type = 6;
            joint1 = null;
            joint2 = null;
            ratio = 1;
         }
      }
   }
}

