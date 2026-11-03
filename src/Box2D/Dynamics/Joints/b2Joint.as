package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   import flash.Boot;
   
   public class b2Joint
   {
      
      public var m_userData:*;
      
      public var m_type:int;
      
      public var m_prev:b2Joint;
      
      public var m_next:b2Joint;
      
      public var m_localCenterB:b2Vec2;
      
      public var m_localCenterA:b2Vec2;
      
      public var m_islandFlag:Boolean;
      
      public var m_invMassB:Number;
      
      public var m_invMassA:Number;
      
      public var m_invIB:Number;
      
      public var m_invIA:Number;
      
      public var m_edgeB:b2JointEdge;
      
      public var m_edgeA:b2JointEdge;
      
      public var m_collideConnected:Boolean;
      
      public var m_bodyB:b2Body;
      
      public var m_bodyA:b2Body;
      
      public function b2Joint(def:b2JointDef = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_edgeA = new b2JointEdge();
         m_edgeB = new b2JointEdge();
         m_localCenterA = new b2Vec2();
         m_localCenterB = new b2Vec2();
         b2Settings.b2Assert(def.bodyA != def.bodyB);
         m_type = def.type;
         m_prev = null;
         m_next = null;
         m_bodyA = def.bodyA;
         m_bodyB = def.bodyB;
         m_collideConnected = def.collideConnected;
         m_islandFlag = false;
         m_userData = def.userData;
      }
      
      public static function create(def:b2JointDef, allocator:*) : b2Joint
      {
         var _loc3_:b2Joint = null;
         switch(def.type)
         {
            case 1:
               _loc3_ = new b2RevoluteJoint(b2RevoluteJointDef(def));
               break;
            case 2:
               _loc3_ = new b2PrismaticJoint(b2PrismaticJointDef(def));
               break;
            case 3:
               _loc3_ = new b2DistanceJoint(b2DistanceJointDef(def));
               break;
            case 4:
               _loc3_ = new b2PulleyJoint(b2PulleyJointDef(def));
               break;
            case 5:
               _loc3_ = new b2MouseJoint(b2MouseJointDef(def));
               break;
            case 6:
               _loc3_ = new b2GearJoint(b2GearJointDef(def));
               break;
            case 7:
               _loc3_ = new b2LineJoint(b2LineJointDef(def));
               break;
            case 8:
               _loc3_ = new b2WeldJoint(b2WeldJointDef(def));
               break;
            case 9:
               _loc3_ = new b2FrictionJoint(b2FrictionJointDef(def));
         }
         return _loc3_;
      }
      
      public static function destroy(joint:b2Joint, allocator:*) : void
      {
      }
      
      public static function Create(def:b2JointDef, allocator:*) : b2Joint
      {
         return b2Joint.create(def,allocator);
      }
      
      public static function Destroy(joint:b2Joint, allocator:*) : void
      {
         b2Joint.destroy(joint,allocator);
      }
      
      public function solveVelocityConstraints(step:b2TimeStep) : void
      {
         SolveVelocityConstraints(step);
      }
      
      public function solvePositionConstraints(baumgarte:Number) : Boolean
      {
         return SolvePositionConstraints(baumgarte);
      }
      
      public function setUserData(data:*) : void
      {
         SetUserData(data);
      }
      
      public function isActive() : Boolean
      {
         return IsActive();
      }
      
      public function initVelocityConstraints(step:b2TimeStep) : void
      {
         InitVelocityConstraints(step);
      }
      
      public function getUserData() : *
      {
         return GetUserData();
      }
      
      public function getType() : int
      {
         return GetType();
      }
      
      public function getReactionTorque(inv_dt:Number) : Number
      {
         return GetReactionTorque(inv_dt);
      }
      
      public function getReactionForce(inv_dt:Number) : b2Vec2
      {
         return GetReactionForce(inv_dt);
      }
      
      public function getNext() : b2Joint
      {
         return GetNext();
      }
      
      public function getBodyB() : b2Body
      {
         return GetBodyB();
      }
      
      public function getBodyA() : b2Body
      {
         return GetBodyA();
      }
      
      public function getAnchorB() : b2Vec2
      {
         return GetAnchorB();
      }
      
      public function getAnchorA() : b2Vec2
      {
         return GetAnchorA();
      }
      
      public function finalizeVelocityConstraints() : void
      {
         FinalizeVelocityConstraints();
      }
      
      public function SolveVelocityConstraints(step:b2TimeStep) : void
      {
      }
      
      public function SolvePositionConstraints(baumgarte:Number) : Boolean
      {
         return false;
      }
      
      public function SetUserData(data:*) : void
      {
         m_userData = data;
      }
      
      public function IsActive() : Boolean
      {
         if((m_bodyA.m_flags & b2Body.e_activeFlag) == b2Body.e_activeFlag)
         {
            return (m_bodyB.m_flags & b2Body.e_activeFlag) == b2Body.e_activeFlag;
         }
         return false;
      }
      
      public function InitVelocityConstraints(step:b2TimeStep) : void
      {
      }
      
      public function GetUserData() : *
      {
         return m_userData;
      }
      
      public function GetType() : int
      {
         return m_type;
      }
      
      public function GetReactionTorque(inv_dt:Number) : Number
      {
         return 0;
      }
      
      public function GetReactionForce(inv_dt:Number) : b2Vec2
      {
         return null;
      }
      
      public function GetNext() : b2Joint
      {
         return m_next;
      }
      
      public function GetBodyB() : b2Body
      {
         return m_bodyB;
      }
      
      public function GetBodyA() : b2Body
      {
         return m_bodyA;
      }
      
      public function GetAnchorB() : b2Vec2
      {
         return null;
      }
      
      public function GetAnchorA() : b2Vec2
      {
         return null;
      }
      
      public function FinalizeVelocityConstraints() : void
      {
      }
   }
}

