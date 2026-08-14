package GeneratedCode
{
   import DistributedObjects.HeroGameObject;
   import NetworkCode.DcNetworkClass;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   import flash.geom.Vector3D;
   
   public class HeroGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      private var the_instance:HeroGameObject;
      
      public const FLID_type:uint = 146;
      
      public const FLID_position:uint = 147;
      
      public const FLID_heading:uint = 148;
      
      public const FLID_scale:uint = 149;
      
      public const FLID_flip:uint = 150;
      
      public const FLID_hitPoints:uint = 151;
      
      public const FLID_weaponDetails:uint = 152;
      
      public const FLID_consumableDetails:uint = 153;
      
      public const FLID_healthBombsUsed:uint = 154;
      
      public const FLID_partyBombsUsed:uint = 155;
      
      public const FLID_playerID:uint = 156;
      
      public const FLID_state:uint = 157;
      
      public const FLID_team:uint = 158;
      
      public const FLID_ReceiveAttackChoreography:uint = 159;
      
      public const FLID_ReceiveCombatResult:uint = 160;
      
      public const FLID_skinType:uint = 161;
      
      public const FLID_screenName:uint = 162;
      
      public const FLID_manaPoints:uint = 163;
      
      public const FLID_experiencePoints:uint = 164;
      
      public const FLID_slotPoints:uint = 165;
      
      public const FLID_dungeonBusterPoints:uint = 166;
      
      public const FLID_setAFK:uint = 167;
      
      public const FLID_ReportBuffEffect:uint = 168;
      
      public const FLID_ReceivedBuffEffect:uint = 169;
      
      public const FLID_TooFullForDoober:uint = 170;
      
      public const FLID_ProposeCombatResults:uint = 171;
      
      public const FLID_ProposeAttackChoreography:uint = 172;
      
      public const FLID_ProposeRevive:uint = 173;
      
      public const FLID_ProposeSelfRevive:uint = 174;
      
      public const FLID_ProposeSelfRevive_Resp:uint = 175;
      
      public const FLID_PartyBomb:uint = 176;
      
      public const FLID_ProposeCreateNPC:uint = 177;
      
      public const FLID_setStateAndAttackChoreography:uint = 178;
      
      public const FLID_StopChoreography:uint = 179;
      
      public function HeroGameObjectNetworkComponent(Inst:HeroGameObject, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : HeroGameObjectNetworkComponent
      {
         var _loc5_:HeroGameObject = new HeroGameObject(gs.facade,doid);
         var _loc4_:HeroGameObjectNetworkComponent = new HeroGameObjectNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentHeroGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(fieldid)
         {
            case 146:
               recv_type(packet);
               break;
            case 147:
               recv_position(packet);
               break;
            case 148:
               recv_heading(packet);
               break;
            case 149:
               recv_scale(packet);
               break;
            case 150:
               recv_flip(packet);
               break;
            case 151:
               recv_hitPoints(packet);
               break;
            case 152:
               recv_weaponDetails(packet);
               break;
            case 153:
               recv_consumableDetails(packet);
               break;
            case 154:
               recv_healthBombsUsed(packet);
               break;
            case 155:
               recv_partyBombsUsed(packet);
               break;
            case 156:
               recv_playerID(packet);
               break;
            case 157:
               recv_state(packet);
               break;
            case 158:
               recv_team(packet);
               break;
            case 159:
               recv_ReceiveAttackChoreography(packet);
               break;
            case 160:
               recv_ReceiveCombatResult(packet);
               break;
            case 161:
               recv_skinType(packet);
               break;
            case 162:
               recv_screenName(packet);
               break;
            case 163:
               recv_manaPoints(packet);
               break;
            case 164:
               recv_experiencePoints(packet);
               break;
            case 165:
               recv_slotPoints(packet);
               break;
            case 166:
               recv_dungeonBusterPoints(packet);
               break;
            case 167:
               recv_setAFK(packet);
               break;
            case 176:
               recv_PartyBomb(packet);
               break;
            case 178:
               recv_setStateAndAttackChoreography(packet);
               break;
            case 179:
               recv_StopChoreography(packet);
               break;
            default:
               super.recvById(packet,fieldid);
         }
      }
      
      override public function generate(packet:DcNetworkPacket) : void
      {
         recv_type(packet);
         recv_position(packet);
         recv_heading(packet);
         recv_scale(packet);
         recv_flip(packet);
         recv_hitPoints(packet);
         recv_weaponDetails(packet);
         recv_consumableDetails(packet);
         recv_healthBombsUsed(packet);
         recv_partyBombsUsed(packet);
         recv_playerID(packet);
         recv_state(packet);
         recv_team(packet);
         recv_skinType(packet);
         recv_screenName(packet);
         recv_manaPoints(packet);
         recv_experiencePoints(packet);
         recv_slotPoints(packet);
         recv_dungeonBusterPoints(packet);
         recv_setAFK(packet);
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
         var _loc2_:uint = packet.readUnsignedShort();
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
      
      public function recv_consumableDetails(packet:DcNetworkPacket) : void
      {
         var v_consumableDetails:Vector.<ConsumableDetails> = (function(param1:DcNetworkPacket):Vector.<ConsumableDetails>
         {
            var _loc3_:* = 0;
            var _loc5_:ConsumableDetails = null;
            var _loc4_:Vector.<ConsumableDetails> = new Vector.<ConsumableDetails>();
            var _loc2_:uint = 2;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc5_ = ConsumableDetails.readFromPacket(param1);
               _loc4_.push(_loc5_);
               _loc3_++;
            }
            return _loc4_;
         })(packet);
         the_instance.consumableDetails = v_consumableDetails;
      }
      
      public function recv_healthBombsUsed(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedByte();
         the_instance.healthBombsUsed = _loc2_;
      }
      
      public function recv_partyBombsUsed(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedByte();
         the_instance.partyBombsUsed = _loc2_;
      }
      
      public function recv_playerID(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.playerID = _loc2_;
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
      
      public function recv_skinType(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.skinType = _loc2_;
      }
      
      public function recv_screenName(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         the_instance.screenName = _loc2_;
      }
      
      public function recv_manaPoints(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedShort();
         the_instance.manaPoints = _loc2_;
      }
      
      public function recv_experiencePoints(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.experiencePoints = _loc2_;
      }
      
      public function recv_slotPoints(packet:DcNetworkPacket) : void
      {
         var v_slotPoints:Vector.<uint> = (function(param1:DcNetworkPacket):Vector.<uint>
         {
            var _loc3_:* = 0;
            var _loc5_:* = 0;
            var _loc4_:Vector.<uint> = new Vector.<uint>();
            var _loc2_:uint = 4;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc5_ = param1.readUnsignedShort();
               _loc4_.push(_loc5_);
               _loc3_++;
            }
            return _loc4_;
         })(packet);
         the_instance.slotPoints = v_slotPoints;
      }
      
      public function recv_dungeonBusterPoints(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.dungeonBusterPoints = _loc2_;
      }
      
      public function recv_setAFK(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedByte();
         the_instance.setAFK = _loc2_;
      }
      
      public function recv_PartyBomb(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedInt();
         the_instance.PartyBomb(_loc2_);
      }
      
      public function recv_setStateAndAttackChoreography(packet:DcNetworkPacket) : void
      {
         var _loc2_:String = packet.readUTF();
         var _loc3_:AttackChoreography = AttackChoreography.readFromPacket(packet);
         the_instance.setStateAndAttackChoreography(_loc2_,_loc3_);
      }
      
      public function recv_StopChoreography(packet:DcNetworkPacket) : void
      {
         the_instance.StopChoreography();
      }
   }
}

