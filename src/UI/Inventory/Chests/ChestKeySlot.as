package UI.Inventory.Chests
{
   import Account.KeyInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderer;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class ChestKeySlot
   {
      
      private var mSlotMC:MovieClip;
      
      private var mIconMC:MovieClip;
      
      private var mUnequippableMC:MovieClip;
      
      private var mUnusableMC:MovieClip;
      
      private var mIconExistsMC:MovieClip;
      
      private var mNumberLabel:TextField;
      
      private var mKeyInfo:KeyInfo;
      
      private var mKeyMC:MovieClip;
      
      private var mRenderer:MovieClipRenderer;
      
      private var mDBFacade:DBFacade;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mFromHeader:Boolean;
      
      public function ChestKeySlot(dbFacade:DBFacade, slotMC:MovieClip, keyInfo:KeyInfo, assetLoadingComponent:AssetLoadingComponent, fromHeader:Boolean = false)
      {
         super();
         mDBFacade = dbFacade;
         mSlotMC = slotMC;
         mKeyInfo = keyInfo;
         mAssetLoadingComponent = assetLoadingComponent;
         mFromHeader = fromHeader;
         setupUI();
      }
      
      public function get keyInfo() : KeyInfo
      {
         return mKeyInfo;
      }
      
      public function setupUI() : void
      {
         setSelected(false);
         mIconMC = mSlotMC.icon;
         mUnequippableMC = mSlotMC.unequippable;
         mUnusableMC = mSlotMC.unusable;
         mIconExistsMC = mSlotMC.icon_exists;
         mNumberLabel = mSlotMC.number_label;
         mNumberLabel.text = mKeyInfo.count.toString();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mKeyInfo.gmKeyOffer.BundleSwfFilepath),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass(mKeyInfo.gmKeyOffer.BundleIcon);
            mKeyMC = new _loc2_();
            mKeyMC.scaleX = mKeyMC.scaleY = 1;
            if(mFromHeader)
            {
               if(mKeyInfo.count == 0)
               {
                  mUnusableMC.addChild(mKeyMC);
               }
               else
               {
                  mIconExistsMC.addChild(mKeyMC);
               }
            }
            else
            {
               mIconMC.addChild(mKeyMC);
            }
            mRenderer = new MovieClipRenderer(mDBFacade,mKeyMC);
         });
      }
      
      public function refresh(newKeyInfo:KeyInfo) : void
      {
         mKeyInfo = newKeyInfo;
         mNumberLabel.text = newKeyInfo.count.toString();
      }
      
      public function setSelected(value:Boolean) : void
      {
         if(mIconMC)
         {
            if(mIconMC.numChildren > 1)
            {
               mIconMC.removeChildAt(1);
            }
            if(mUnusableMC.numChildren > 1)
            {
               mUnusableMC.removeChildAt(1);
            }
            if(mUnequippableMC.numChildren > 1)
            {
               mUnequippableMC.removeChildAt(1);
            }
            if(value)
            {
               mIconMC.addChild(mKeyMC);
            }
            else if(mKeyInfo.count == 0)
            {
               mUnusableMC.addChild(mKeyMC);
            }
            else
            {
               mUnequippableMC.addChild(mKeyMC);
            }
         }
      }
      
      public function destroy() : void
      {
         mRenderer.destroy();
         mRenderer = null;
         mKeyInfo = null;
      }
   }
}

