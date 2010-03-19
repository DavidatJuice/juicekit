package flare.vis.data.render
{
	import flare.util.Shapes;
	import flare.vis.data.DataSprite;
	
	import flash.display.Graphics;

	/**
	 * Renderer that draws shapes. The ShapeRender uses a ShapePalette instance
	 * as needed to look up shape drawing routines based on the DataSprite
	 * <code>shape</code> property.
	 * @see flare.vis.palette.ShapePalette
	 */
	public class ShapeRenderer implements IRenderer
	{
		private static var _instance:ShapeRenderer = new ShapeRenderer();
		/** Static ShapeRenderer instance. */
		public static function get instance():ShapeRenderer { return _instance; }
		
		/** The default size value for drawn shapes. This value is multiplied
		 *  by a DataSprite's size property to determine the final size. */
		public var defaultSize:Number;
		
		/**
		 * Creates a new ShapeRenderer 
		 * @param defaultSize the default size (radius) for shapes
		 */
		public function ShapeRenderer(defaultSize:Number=6) {
			this.defaultSize = defaultSize;
		}
		
		/** @inheritDoc */
		public function render(d:DataSprite):void
		{
			var lineAlpha:Number = d.lineAlpha;
			var fillAlpha:Number = d.fillAlpha;
      var lineColor:Number = d.lineColor;
      var fillColor:Number = d.fillColor;
			var size:Number = d.size * defaultSize;
			
			var g:Graphics = d.graphics;
			g.clear();
			if (fillAlpha > 0) g.beginFill(d.fillColor, fillAlpha);
			if (lineAlpha > 0) g.lineStyle(d.lineWidth, d.lineColor, lineAlpha);
		  const lw:Number = d.lineWidth;		 
			
			switch (d.shape) {
				case null:
					break;
				
        case Shapes.TREEMAPBLOCK:
        // This draws a rectangle inside of a rectangle.  
        // This serves as a replacement for Shapes.BLOCK
        // This behaves in an identical fashion to the original flash line border 
        // in that the borders are drawn on the outside of the shape.
        // Shapes are scaled down by the amount of the linewidth area in the 
        // treemap layout to achieve smooth treemap nirvana.
          g.lineStyle(0.0, 0, 0);
          if (lineColor == 0xffffffff) {
            g.beginFill(0xffffff, fillAlpha); 
          } else {
            g.beginFill(lineColor, lineAlpha);  
          }
          g.drawRect(d.u-d.x-d.lineWidth/2, d.v-d.y-d.lineWidth/2, d.w+d.lineWidth, d.h+d.lineWidth);
          // Rectangles with a white (0xffffffff) fill are rendered as transparent in flash graphics.
          // The fill needs to be passed in as an RGB value with a fillAlpha instead of an ARGB value
          if (fillColor == 0xffffffff) {
            g.beginFill(0xffffff, fillAlpha); 
          } else {
            g.beginFill(fillColor, fillAlpha);  
          }
          g.drawRect(d.u-d.x, d.v-d.y, d.w, d.h);
          break;

				case Shapes.BLOCK:
          g.drawRect(d.u-d.x, d.v-d.y, d.w, d.h);
					break;
				case Shapes.POLYGON:
					if (d.points!=null)
						Shapes.drawPolygon(g, d.points);
					break;
				case Shapes.POLYBLOB:
					if (d.points!=null)
						Shapes.drawCardinal(g, d.points,
											d.points.length/2, 0.15, true);
					break;
				case Shapes.VERTICAL_BAR:
				  g.clear();
				  if (lw > 0) {
  	        g.beginFill(d.lineColor, d.lineAlpha);
  	        g.drawRect(-size/2, -d.h, size, d.h);
				  }
	        g.beginFill(d.fillColor, fillAlpha);
	        if (d.h > 0) {
            g.drawRect(-size/2+lw, -d.h+lw, size-lw*2, d.h-lw*2);
	        } 
	        else {
	          // Reversed bars
            g.drawRect(-size/2+lw, -d.h-lw, size-lw*2, d.h+lw*2);
	        }         
					break;
				case Shapes.HORIZONTAL_BAR:		
				  g.clear();
				  if (lw > 0) {
  	        g.beginFill(d.lineColor, d.lineAlpha);
  	        g.drawRect(-d.w, -size/2, d.w, size);
				  }
	        g.beginFill(d.fillColor, fillAlpha);
	        if (d.w > 0) {
	          g.drawRect(-d.w+lw, -size/2+lw, d.w-lw*2, size-lw*2);
	        } 
	        else {
	          // Reversed bars
	          g.drawRect(-d.w-lw, -size/2+lw, d.w+lw*2, size-lw*2);
	        }         
					break;
				case Shapes.WEDGE:
					Shapes.drawWedge(g, d.origin.x-d.x, d.origin.y-d.y,
									 d.h, d.v, d.u, d.u+d.w);
					break;
				default:
					Shapes.getShape(d.shape)(g, size);
			}
			
			if (fillAlpha > 0) g.endFill();
		}
		
	} // end of class ShapeRenderer
}