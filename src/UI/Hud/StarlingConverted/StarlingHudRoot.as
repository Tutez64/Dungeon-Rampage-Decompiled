package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedRoot;
   import starling.core.Starling;
   import starling.rendering.Painter;
   import starling.rendering.RenderState;
   
   internal class StarlingHudRoot extends BakedRoot
   {
      
      private static const sSaved:RenderState = new RenderState();
      
      public function StarlingHudRoot()
      {
         super();
      }
      
      override public function render(painter:Painter) : void
      {
         var _loc2_:uint = painter.stencilReferenceValue;
         sSaved.copyFrom(painter.state);
         try
         {
            super.render(painter);
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
            try
            {
               painter.finishMeshBatch();
            }
            catch(flushError:Error)
            {
               StarlingHud.reportError(flushError);
            }
            painter.state.copyFrom(sSaved);
            if(painter.stencilReferenceValue != _loc2_)
            {
               painter.stencilReferenceValue = _loc2_;
            }
            if(Starling.current != null && Starling.current.contextValid)
            {
               Starling.context.setStencilActions("frontAndBack","equal");
            }
         }
      }
   }
}

