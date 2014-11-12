package com.adobetv{
	import mx.skins.ProgrammaticSkin;
    import mx.core.UIComponent;
    import flash.display.Graphics;
    import flash.geom.Matrix;
	import mx.core.UIComponent;
    import flash.display.Graphics;
    import mx.controls.sliderClasses.SliderThumb;
    import mx.core.mx_internal;
    import mx.controls.sliderClasses.Slider;
    import flash.display.Graphics;
    
	public class SliderVideoTrack extends UIComponent{
        
        override public function get height():Number{
            return 25;
        }
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            /*this.graphics.clear();
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            var gr:Graphics = this.graphics;
            var m:Matrix = new Matrix();
            m.createGradientBox(unscaledWidth, unscaledHeight,Math.PI/2);
            gr.beginGradientFill("linear",[0x3C3C3C, 0xcccccc],[1,1],[0,255],m);
            gr.drawRect(0,0, unscaledWidth, 40);
            gr.endFill();*/
        }
        
        /*
        override public function get measuredHeight():Number{
            return 40;
        }
        */
    }
}