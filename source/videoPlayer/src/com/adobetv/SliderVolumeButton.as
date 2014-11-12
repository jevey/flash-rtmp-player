package com.adobetv{
	import flash.display.GradientType;
	import flash.display.Graphics;
	
	import mx.controls.sliderClasses.SliderThumb;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
    
    public class SliderVolumeButton extends SliderThumb{
        use namespace mx_internal;
        
        /*
        override public function set xPosition(value:Number):void{
            $x = value;
            Slider(owner).drawTrackHighlight();
        }
        */
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            var gr:Graphics = this.graphics;
            
            /*gr.beginFill(0x000000);
            
            gr.drawRect(7,4,9,7);
            */
            //gr.beginFill(0xff9900);
            //////////////////////////////////
            
            gr.beginGradientFill(GradientType.LINEAR,[0xff9900, 0xff6e00],[1,1],[1,1]);
            
            
            gr.drawRect(0,4, 8, 7);
            
            gr.endFill();
            
/*            gr.beginGradientFill(GradientType.LINEAR,[0xff9900, 0xff6e00],[1,1],[1,1]);
            
            
            gr.drawRect(0,4, 4, 3);
            
            gr.endFill();
            gr.beginGradientFill(GradientType.LINEAR,[0x000000, 0x000000],[1,1],[1,1]);
            
            
            gr.drawRect(4,4, 4, 3);
            
            gr.endFill();
            */
        }
        
        override protected function measure():void{
            super.measure();
            measuredWidth = 25;
            measuredHeight = 25;
        }
    }
	
}