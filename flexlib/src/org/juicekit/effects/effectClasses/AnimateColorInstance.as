/*
 * Copyright 2007-2010 Juice, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


package org.juicekit.effects.effectClasses {

import mx.effects.effectClasses.AnimatePropertyInstance;

import flare.util.Colors;

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