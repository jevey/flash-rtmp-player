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
    import flash.display.GradientType;
    
    public class HighlightVideoTrack extends UIComponent{
        
        /**
         * Line 1926 on Slider puts the highlight 
         * 1 px below the Slider&apos;s track
         * */
        override public function get height():Number{
            return 25;
        }
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            this.graphics.clear();
            //super.updateDisplayList(unscaledWidth, unscaledHeight);
            var gr:Graphics = this.graphics;
            //gr.beginFill(0xff9900);
            
            gr.beginGradientFill(GradientType.LINEAR,[0xff9900, 0xff6e00],[1,1],[1,1]);
            
            gr.drawRect(-4,3, unscaledWidth, 7);
            gr.endFill();
        }
    }
    
}