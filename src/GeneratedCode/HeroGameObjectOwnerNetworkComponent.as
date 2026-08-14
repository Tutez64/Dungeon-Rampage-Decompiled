package GeneratedCode
{
   import DistributedObjects.HeroGameObjectOwner;
   import NetworkCode.DcNetworkInterface;
   import NetworkCode.DcNetworkPacket;
   import flash.geom.Vector3D;
   
   public class HeroGameObjectOwnerNetworkComponent extends HeroGameObjectNetworkComponent implements DcNetworkInterface
   {
      
      private var the_instance:IHeroGameObjectOwner;
      
      public function HeroGameObjectOwnerNetworkComponent(Inst:HeroGameObjectOwner, gs:GeneratedDcSocket, id:uint)
      {
         super(Inst,gs,id);
         the_instance = Inst;
      }
      
      public static function ownerFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:uint) : HeroGameObjectOwnerNetworkComponent
      {
         var _loc5_:HeroGameObjectOwner = new HeroGameObjectOwner(gs.facade,doid);
         var _loc4_:HeroGameObjectOwnerNetworkComponent = new HeroGameObjectOwnerNetworkComponent(_loc5_,gs,doid);
         _loc4_.generate(packet);
         _loc5_.setNetworkComponentHeroGameObject(_loc4_);
         _loc5_.setOwnerNetworkComponentHeroGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(packet:DcNetworkPacket, fieldid:uint) : void
      {
         switch(int(fieldid) - 168)
         {
            case 0:
               recv_ReportBuffEffect(packet);
               break;
            case 1:
               recv_ReceivedBuffEffect(packet);
               break;
            case 2:
               recv_TooFullForDoober(packet);
               break;
            case 7:
               recv_ProposeSelfRevive_Resp(packet);
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
      
      public function send_position(position:Vector3D) : void
      {
         var _loc2_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,147);
         _loc2_.writeFloat(position.x);
         _loc2_.writeFloat(position.y);
         Send_packet(_loc2_);
      }
      
      public function send_heading(heading:Number) : void
      {
         var _loc2_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,148);
         _loc2_.writeFloat(heading);
         Send_packet(_loc2_);
      }
      
      public function send_ReceiveAttackChoreography(attackChoreography:AttackChoreography) : void
      {
         var _loc2_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,159);
         attackChoreography.writeToPacket(_loc2_);
         Send_packet(_loc2_);
      }
      
      public function recv_ReportBuffEffect(packet:DcNetworkPacket) : void
      {
         var _loc5_:uint = packet.readUnsignedInt();
         var _loc3_:int = packet.readInt();
         var _loc4_:uint = packet.readUnsignedInt();
         var _loc2_:int = packet.readByte();
         the_instance.ReportBuffEffect(_loc5_,_loc3_,_loc4_,_loc2_);
      }
      
      public function recv_ReceivedBuffEffect(packet:DcNetworkPacket) : void
      {
         var _loc3_:int = packet.readInt();
         var _loc4_:uint = packet.readUnsignedInt();
         var _loc2_:int = packet.readByte();
         the_instance.ReceivedBuffEffect(_loc3_,_loc4_,_loc2_);
      }
      
      public function recv_TooFullForDoober(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedByte();
         the_instance.TooFullForDoober(_loc2_);
      }
      
      public function send_ProposeCombatResults(combatResults:Vector.<CombatResult>) : void
      {
         var combatResultsfunc:Function;
         var outpacket:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(outpacket,171);
         combatResultsfunc = function():void
         {
            var _loc2_:* = 0;
            var _loc1_:uint = combatResults.length;
            var _loc3_:DcNetworkPacket = outpacket;
            outpacket = new DcNetworkPacket();
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               combatResults[_loc2_].writeToPacket(outpacket);
               _loc2_++;
            }
            _loc3_.writeShort(outpacket.length);
            _loc3_.writeBytes(outpacket);
            outpacket = _loc3_;
         };
         combatResultsfunc();
         Send_packet(outpacket);
      }
      
      public function send_ProposeAttackChoreography(attackChoreography:AttackChoreography) : void
      {
         var _loc2_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,172);
         attackChoreography.writeToPacket(_loc2_);
         Send_packet(_loc2_);
      }
      
      public function send_ProposeRevive(revivee:uint) : void
      {
         var _loc2_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,173);
         _loc2_.writeUnsignedInt(revivee);
         Send_packet(_loc2_);
      }
      
      public function send_ProposeSelfRevive(isParty:uint) : void
      {
         var _loc2_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,174);
         _loc2_.writeByte(isParty);
         Send_packet(_loc2_);
      }
      
      public function recv_ProposeSelfRevive_Resp(packet:DcNetworkPacket) : void
      {
         var _loc2_:uint = packet.readUnsignedByte();
         var _loc3_:uint = packet.readUnsignedByte();
         the_instance.ProposeSelfRevive_Resp(_loc2_,_loc3_);
      }
      
      public function send_ProposeCreateNPC(npcId:uint, weaponSlot:uint, x:Number, y:Number) : void
      {
         var _loc5_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc5_,177);
         _loc5_.writeUnsignedInt(npcId);
         _loc5_.writeUnsignedInt(weaponSlot);
         _loc5_.writeFloat(x);
         _loc5_.writeFloat(y);
         Send_packet(_loc5_);
      }
      
      public function send_StopChoreography() : void
      {
         var _loc1_:DcNetworkPacket = new DcNetworkPacket();
         Prepare_FieldUpdate(_loc1_,179);
         Send_packet(_loc1_);
      }
   }
}

