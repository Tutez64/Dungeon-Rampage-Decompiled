package GeneratedCode
{
   import DistributedObjects.DistributedNPCGameObject;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   import flash.geom.Vector3D;
   
   public class DistributedNPCGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:DistributedNPCGameObject;
      
      public const FLID_type:uint = 130;
      
      public const FLID_level:uint = 131;
      
      public const FLID_position:uint = 132;
      
      public const FLID_heading:uint = 133;
      
      public const FLID_scale:uint = 134;
      
      public const FLID_flip:uint = 135;
      
      public const FLID_hitPoints:uint = 136;
      
      public const FLID_weaponDetails:uint = 137;
      
      public const FLID_state:uint = 138;
      
      public const FLID_team:uint = 139;
      
      public const FLID_layer:uint = 140;
      
      public const FLID_remoteTriggerState:uint = 141;
      
      public const FLID_masterId:uint = 142;
      
      public const FLID_ReceiveAttackChoreography:uint = 143;
      
      public const FLID_ReceiveCombatResult:uint = 144;
      
      public const FLID_ReceiveTimelineAction:uint = 145;
      
      public function DistributedNPCGameObjectNetworkComponent(Inst:DistributedNPCGameObject, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : DistributedNPCGameObjectNetworkComponent
      {
         var _loc5_:DistributedNPCGameObject = new DistributedNPCGameObject(gs.facade,doid);
         var _loc4_:DistributedNPCGameObjectNetworkComponent = new DistributedNPCGameObjectNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentDistributedNPCGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 130)
         {
            case 0:
               recv_type(packet);
               break;
            case 1:
               recv_level(packet);
               break;
            case 2:
               recv_position(packet);
               break;
            case 3:
               recv_heading(packet);
               break;
            case 4:
               recv_scale(packet);
               break;
            case 5:
               recv_flip(packet);
               break;
            case 6:
               recv_hitPoints(packet);
               break;
            case 7:
               recv_weaponDetails(packet);
               break;
            case 8:
               recv_state(packet);
               break;
            case 9:
               recv_team(packet);
               break;
            case 10:
               recv_layer(packet);
               break;
            case 11:
               recv_remoteTriggerState(packet);
               break;
            case 12:
               recv_masterId(packet);
               break;
            case 13:
               recv_ReceiveAttackChoreography(packet);
               break;
            case 14:
               recv_ReceiveCombatResult(packet);
               break;
            case 15:
               recv_ReceiveTimelineAction(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_type(packet);
         recv_level(packet);
         recv_position(packet);
         recv_heading(packet);
         recv_scale(packet);
         recv_flip(packet);
         recv_hitPoints(packet);
         recv_weaponDetails(packet);
         recv_state(packet);
         recv_team(packet);
         recv_layer(packet);
         recv_remoteTriggerState(packet);
         recv_masterId(packet);
         recvByIdLoop(packet);
      }
      
      override public function destroy() : void
      {
         the_instance.destroy();
      }
      
      public function recv_type(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.type = _loc2_;
      }
      
      public function recv_level(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedByte();
         the_instance.level = _loc2_;
      }
      
      public function recv_position(packet:DcNetworkPacket) : void
      {
         var v_position:Vector3D = (function(param1:DcNetworkPacket):Vector3D
         {
            var _loc2_:Vector3D = new Vector3D();
            _loc2_.x = param1.readFloat();
            _loc2_.y = param1.readFloat();
            return _loc2_;
         })(packet);
         the_instance.position = v_position;
      }
      
      public function recv_heading(packet:DcNetworkPacket) : void
      {
         var _loc2_:Number = packet.readFloat();
         the_instance.heading = _loc2_;
      }
      
      public function recv_scale(packet:DcNetworkPacket) : void
      {
         var _loc2_:Number = packet.readFloat();
         the_instance.scale = _loc2_;
      }
      
      public function recv_flip(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedByte();
         the_instance.flip = _loc2_;
      }
      
      public function recv_hitPoints(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.hitPoints = _loc2_;
      }
      
      public function recv_weaponDetails(packet:DcNetworkPacket) : void
      {
         var v_weaponDetails:Vector.<WeaponDetails> = (function(param1:DcNetworkPacket):Vector.<WeaponDetails>
         {
            var _loc3_:* = 0;
            var _loc5_:WeaponDetails = null;
            var _loc4_:Vector.<WeaponDetails> = new Vector.<WeaponDetails>();
            var _loc2_:uint = 4;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc5_ = WeaponDetails.readFromPacket(param1);
               _loc4_.push(_loc5_);
               _loc3_++;
            }
            return _loc4_;
         })(packet);
         the_instance.weaponDetails = v_weaponDetails;
      }
      
      public function recv_state(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         the_instance.state = _loc2_;
      }
      
      public function recv_team(packet:DcNetworkPacket) : void
      {
         var _loc2_:int = packet.readByte();
         the_instance.team = _loc2_;
      }
      
      public function recv_layer(packet:DcNetworkPacket) : void
      {
         var _loc2_:int = packet.readByte();
         the_instance.layer = _loc2_;
      }
      
      public function recv_remoteTriggerState(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedByte();
         the_instance.remoteTriggerState = _loc2_;
      }
      
      public function recv_masterId(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.masterId = _loc2_;
      }
      
      public function recv_ReceiveAttackChoreography(packet:DcNetworkPacket) : void
      {
         var _loc2_:AttackChoreography = AttackChoreography.readFromPacket(packet);
         the_instance.ReceiveAttackChoreography(_loc2_);
      }
      
      public function recv_ReceiveCombatResult(packet:DcNetworkPacket) : void
      {
         var _loc2_:CombatResult = CombatResult.readFromPacket(packet);
         the_instance.ReceiveCombatResult(_loc2_);
      }
      
      public function recv_ReceiveTimelineAction(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         the_instance.ReceiveTimelineAction(_loc2_);
      }
   }
}

