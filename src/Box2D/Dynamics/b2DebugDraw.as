package Box2D.Dynamics
{
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Color;
   import box2dcompat.As3Array;
   import flash.Boot;
   import flash.display.Sprite;
   
   public class b2DebugDraw
   {
      
      public static var e_shapeBit:int = 1;
      
      public static var e_jointBit:int = 2;
      
      public static var e_aabbBit:int = 4;
      
      public static var e_pairBit:int = 8;
      
      public static var e_centerOfMassBit:int = 16;
      
      public static var e_controllerBit:int = 32;
      
      public var m_xformScale:Number;
      
      public var m_sprite:Sprite;
      
      public var m_lineThickness:Number;
      
      public var m_fillAlpha:Number;
      
      public var m_drawScale:Number;
      
      public var m_drawFlags:int;
      
      public var m_alpha:Number;
      
      public function b2DebugDraw()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_drawScale = 1;
         m_lineThickness = 1;
         m_alpha = 1;
         m_fillAlpha = 1;
         m_xformScale = 1;
         m_drawFlags = 0;
      }
      
      public function setXFormScale(xformScale:Number) : void
      {
         SetXFormScale(xformScale);
      }
      
      public function setSprite(sprite:Sprite) : void
      {
         SetSprite(sprite);
      }
      
      public function setLineThickness(lineThickness:Number) : void
      {
         SetLineThickness(lineThickness);
      }
      
      public function setFlags(flags:int) : void
      {
         SetFlags(flags);
      }
      
      public function setFillAlpha(alpha:Number) : void
      {
         SetFillAlpha(alpha);
      }
      
      public function setDrawScale(drawScale:Number) : void
      {
         SetDrawScale(drawScale);
      }
      
      public function setAlpha(alpha:Number) : void
      {
         SetAlpha(alpha);
      }
      
      public function getXFormScale() : Number
      {
         return GetXFormScale();
      }
      
      public function getSprite() : Sprite
      {
         return GetSprite();
      }
      
      public function getLineThickness() : Number
      {
         return GetLineThickness();
      }
      
      public function getFlags() : int
      {
         return GetFlags();
      }
      
      public function getFillAlpha() : Number
      {
         return GetFillAlpha();
      }
      
      public function getDrawScale() : Number
      {
         return GetDrawScale();
      }
      
      public function getAlpha() : Number
      {
         return GetAlpha();
      }
      
      public function drawTransform(xf:b2Transform) : void
      {
         DrawTransform(xf);
      }
      
      public function drawSolidPolygon(vertices:Array, vertexCount:int, color:b2Color) : void
      {
         var _loc6_:int = 0;
         m_sprite.graphics.lineStyle(m_lineThickness,color.get_color(),m_alpha);
         m_sprite.graphics.moveTo(vertices[0].x * m_drawScale,vertices[0].y * m_drawScale);
         m_sprite.graphics.beginFill(color.get_color(),m_fillAlpha);
         var _loc4_:int = 1;
         var _loc5_:int = vertexCount;
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            m_sprite.graphics.lineTo(vertices[_loc6_].x * m_drawScale,vertices[_loc6_].y * m_drawScale);
         }
         m_sprite.graphics.lineTo(vertices[0].x * m_drawScale,vertices[0].y * m_drawScale);
         m_sprite.graphics.endFill();
      }
      
      public function drawSolidCircle(center:b2Vec2, radius:Number, axis:b2Vec2, color:b2Color) : void
      {
         DrawSolidCircle(center,radius,axis,color);
      }
      
      public function drawSegment(p1:b2Vec2, p2:b2Vec2, color:b2Color) : void
      {
         DrawSegment(p1,p2,color);
      }
      
      public function drawPolygon(vertices:Array, vertexCount:int, color:b2Color) : void
      {
         var _loc6_:int = 0;
         m_sprite.graphics.lineStyle(m_lineThickness,color.get_color(),m_alpha);
         m_sprite.graphics.moveTo(vertices[0].x * m_drawScale,vertices[0].y * m_drawScale);
         var _loc4_:int = 1;
         var _loc5_:int = vertexCount;
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            m_sprite.graphics.lineTo(vertices[_loc6_].x * m_drawScale,vertices[_loc6_].y * m_drawScale);
         }
         m_sprite.graphics.lineTo(vertices[0].x * m_drawScale,vertices[0].y * m_drawScale);
      }
      
      public function drawCircle(center:b2Vec2, radius:Number, color:b2Color) : void
      {
         DrawCircle(center,radius,color);
      }
      
      public function clearFlags(flags:int) : void
      {
         ClearFlags(flags);
      }
      
      public function clear() : void
      {
         Clear();
      }
      
      public function appendFlags(flags:int) : void
      {
         AppendFlags(flags);
      }
      
      public function SetXFormScale(xformScale:Number) : void
      {
         m_xformScale = xformScale;
      }
      
      public function SetSprite(sprite:Sprite) : void
      {
         m_sprite = sprite;
      }
      
      public function SetLineThickness(lineThickness:Number) : void
      {
         m_lineThickness = lineThickness;
      }
      
      public function SetFlags(flags:int) : void
      {
         m_drawFlags = flags;
      }
      
      public function SetFillAlpha(alpha:Number) : void
      {
         m_fillAlpha = alpha;
      }
      
      public function SetDrawScale(drawScale:Number) : void
      {
         m_drawScale = drawScale;
      }
      
      public function SetAlpha(alpha:Number) : void
      {
         m_alpha = alpha;
      }
      
      public function GetXFormScale() : Number
      {
         return m_xformScale;
      }
      
      public function GetSprite() : Sprite
      {
         return m_sprite;
      }
      
      public function GetLineThickness() : Number
      {
         return m_lineThickness;
      }
      
      public function GetFlags() : int
      {
         return m_drawFlags;
      }
      
      public function GetFillAlpha() : Number
      {
         return m_fillAlpha;
      }
      
      public function GetDrawScale() : Number
      {
         return m_drawScale;
      }
      
      public function GetAlpha() : Number
      {
         return m_alpha;
      }
      
      public function DrawTransform(xf:b2Transform) : void
      {
         m_sprite.graphics.lineStyle(m_lineThickness,16711680,m_alpha);
         m_sprite.graphics.moveTo(xf.position.x * m_drawScale,xf.position.y * m_drawScale);
         m_sprite.graphics.lineTo((xf.position.x + m_xformScale * xf.R.col1.x) * m_drawScale,(xf.position.y + m_xformScale * xf.R.col1.y) * m_drawScale);
         m_sprite.graphics.lineStyle(m_lineThickness,65280,m_alpha);
         m_sprite.graphics.moveTo(xf.position.x * m_drawScale,xf.position.y * m_drawScale);
         m_sprite.graphics.lineTo((xf.position.x + m_xformScale * xf.R.col2.x) * m_drawScale,(xf.position.y + m_xformScale * xf.R.col2.y) * m_drawScale);
      }
      
      public function DrawSolidPolygon(vertices:*, vertexCount:int, color:b2Color) : void
      {
         drawSolidPolygon(As3Array.of(vertices),vertexCount,color);
      }
      
      public function DrawSolidCircle(center:b2Vec2, radius:Number, axis:b2Vec2, color:b2Color) : void
      {
         m_sprite.graphics.lineStyle(m_lineThickness,color.get_color(),m_alpha);
         m_sprite.graphics.moveTo(0,0);
         m_sprite.graphics.beginFill(color.get_color(),m_fillAlpha);
         m_sprite.graphics.drawCircle(center.x * m_drawScale,center.y * m_drawScale,radius * m_drawScale);
         m_sprite.graphics.endFill();
         m_sprite.graphics.moveTo(center.x * m_drawScale,center.y * m_drawScale);
         m_sprite.graphics.lineTo((center.x + axis.x * radius) * m_drawScale,(center.y + axis.y * radius) * m_drawScale);
      }
      
      public function DrawSegment(p1:b2Vec2, p2:b2Vec2, color:b2Color) : void
      {
         m_sprite.graphics.lineStyle(m_lineThickness,color.get_color(),m_alpha);
         m_sprite.graphics.moveTo(p1.x * m_drawScale,p1.y * m_drawScale);
         m_sprite.graphics.lineTo(p2.x * m_drawScale,p2.y * m_drawScale);
      }
      
      public function DrawPolygon(vertices:*, vertexCount:int, color:b2Color) : void
      {
         drawPolygon(As3Array.of(vertices),vertexCount,color);
      }
      
      public function DrawCircle(center:b2Vec2, radius:Number, color:b2Color) : void
      {
         m_sprite.graphics.lineStyle(m_lineThickness,color.get_color(),m_alpha);
         m_sprite.graphics.drawCircle(center.x * m_drawScale,center.y * m_drawScale,radius * m_drawScale);
      }
      
      public function ClearFlags(flags:int) : void
      {
         m_drawFlags &= ~flags;
      }
      
      public function Clear() : void
      {
         m_sprite.graphics.clear();
      }
      
      public function AppendFlags(flags:int) : void
      {
         m_drawFlags |= flags;
      }
   }
}

