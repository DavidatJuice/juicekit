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

package org.juicekit.effects
{

import mx.effects.AnimateProperty;
import mx.effects.IEffectInstance;

import org.juicekit.effects.effectClasses.AnimateColorInstance;

/**
 *
 */
public class AnimateColor extends AnimateProperty
{

  /**
   * Constructor
   *
   * @param target The Object to animate with this effect.
   */
  public function AnimateColor(target:Object = null)
  {
    super(target);

    instanceClass = AnimateColorInstance;
  }


  /**
   * Interpolation mode can be 'rgb' or 'hsv'
   */
  public var interpolationMode:String = 'rgb';

  /**
   * @private
   */
  override protected function initInstance(instance:IEffectInstance):void
  {
    super.initInstance(instance);

    var animateColorInstance:AnimateColorInstance = AnimateColorInstance(instance);

    animateColorInstance.fromValue = fromValue;
    animateColorInstance.toValue = toValue;
    animateColorInstance.property = property;
    animateColorInstance.isStyle = isStyle;
    animateColorInstance.roundValue = roundValue;
    animateColorInstance.easingFunction = easingFunction;
    animateColorInstance.interpolationMode = interpolationMode
  }

} // end class	
} // end package