/*
 * Copyright (c) 2006 Darron Schall <darron@darronschall.com>
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Adapted for JuiceKit by Chris Gemignani, Juice Inc.
 */


package org.juicekit.effects.effectClasses {

  import mx.effects.effectClasses.AnimatePropertyInstance;

  import org.juicekit.flare.util.Colors;


  public class AnimateColorInstance extends AnimatePropertyInstance {

    /**
     * Constructor
     *
     * @param target The Object to animate with this effect.
     */
    public function AnimateColorInstance(target:Object) {
      super(target);
    }

    public var interpolationMode:String = 'rgb';


    /**
     * @private
     */
    override public function onTweenUpdate(value:Object):void {
      // Catch the situation in which the playheadTime is actually more
      // than duration, which causes incorrect colors to appear at the 
      // end of the animation.
      var playheadTime:int = this.playheadTime;

      if (playheadTime > duration) {
        // Fix the local playhead time to avoid going past the end color
        playheadTime = duration;
      }

      // Calculate the new color value based on the elapased time and the change
      // in color values

      var f:Number = playheadTime / duration;
      if (easingFunction != null)
        f = easingFunction(f, 0.0, 1.0, 1.0);

      var colorValue:uint;
      // TODO: support 'lab' interpolation mode
      switch (interpolationMode) {
        case 'hsv':
          colorValue = Colors.interpolateHsv(fromValue, toValue, f);
          break;
        default:
          colorValue = Colors.interpolate(fromValue, toValue, f);
      }

      // Either set the property directly, or set it as a style
      if (!isStyle) {
        target[property] = colorValue;
      } else {
        target.setStyle(property, colorValue);
      }
    }

  } // end class
} // end package