package org.juicekit.charts {
  import mx.charts.LinearAxis;


  public class LinearAxis extends mx.charts.LinearAxis {
    public function LinearAxis() {
      super();
    }

    /**
     *  @private
     */
    private var _userInterval:Number;

    /**
     *  @private
     *  Storage for the minorInterval property.
     */
    private var _minorInterval:Number;
    /**
     *  @private
     */
    private var _userMinorInterval:Number;
    
    
    public var detail:String = 'normal'; 


    public function calculateMaxAndIntervals(ymax:Number):Object {
      if (ymax > 0) {
        var a:Number = (Math.log(ymax) * Math.LOG10E);
        var b:Number = a % 1;
        var c:Number = Math.floor(a);
        var d:Number = Math.pow(10, c);
        var i:Number = 0;
        var m:Number = 0;
        if (a > 0) {
          m = 10 * d;
          i = m / 5;
          if (b < 0.69898 && b > 0.000001) {
            m = 5 * d;
            i = m / 5;
          }
          if (b < 0.47713 && b > 0.000001) {
            m = 3 * d;
            i = m / 6;
          }
          if (b < 0.30103 && b > 0.000001) {
            m = 2 * d;
            i = m / 4;
          }
        } else {
          b = Math.abs(b);
          m = 2 * d;
          i = m / 4;
          if (b < 0.69897) {
            m = 3 * d;
            i = m / 6;
          }
          if (b < 0.52287) {
            m = 5 * d;
            i = m / 5;
          }
          if (b < 0.30102) {
            m = 1 * d;
            i = m / 5;
          }
        }
        
        if (detail == 'high') i = i/2;
        if (detail == 'low') i = m;
        return { max: m, interval: i };
      } else {
        return { max: ymax, interval: NaN };
      }
    }


    /**
     *  @private
     */
    override protected function adjustMinMax(minValue:Number,
      maxValue:Number):void {
      var interval:Number = _userInterval;

      if (autoAdjust == false &&
        !isNaN(_userInterval) &&
        !isNaN(_userMinorInterval)) {
        return;
      }

      // New calculations to accomodate negative values.
      // Find the nearest power of ten for y_userInterval
      // for line-grid and labelling positions.
      if (maxValue == 0 && minValue == 0)
        maxValue = 100;
      var maxPowerOfTen:Number =
        Math.floor(Math.log(Math.abs(maxValue)) / Math.LN10);
      var minPowerOfTen:Number =
        Math.floor(Math.log(Math.abs(minValue)) / Math.LN10);
      var powerOfTen:Number =
        Math.floor(Math.log(Math.abs(maxValue - minValue)) / Math.LN10)

      var y_userInterval:Number;

      if (isNaN(_userInterval)) {
        y_userInterval = Math.pow(10, powerOfTen);

        if (Math.abs(maxValue - minValue) / y_userInterval < 4) {
          powerOfTen--;
          y_userInterval = y_userInterval * 2 / 10;
        }
      } else {
        y_userInterval = _userInterval;
      }

      // Bug 148745:
      // Using % to decide if y_userInterval divides maxValue evenly
      // is running into floating point errors.
      // For example, 3 % .2 == .2.
      // Multiplication and division don't seem to have the same problems,
      // so instead we divide, round and multiply.
      // If we get back to the same value, it means that either it fit evenly,
      // or the difference was trivial enough to get rounded out
      // by imprecision.

      var y_topBound:Number =
        Math.round(maxValue / y_userInterval) * y_userInterval == maxValue ?
        maxValue :
        (Math.floor(maxValue / y_userInterval) + 1) * y_userInterval;

      var y_lowerBound:Number;

      if (isFinite(minValue))
        y_lowerBound = 0;

      if (minValue < 0 || baseAtZero == false) {
        y_lowerBound =
          Math.floor(minValue / y_userInterval) * y_userInterval;

        if (maxValue < 0 && baseAtZero)
          y_topBound = 0;
      } else {
        y_lowerBound = 0;
      }

      // OK, we've figured out our interval.
      // If the caller wants us to lower it based on layout rules,
      // we have more to do. Otherwise, return here.
      // If the user didn't provide us with an interval,
      // we'll use the one we just generated
      
      var o:Object = calculateMaxAndIntervals(maxValue);
      y_topBound = o.max;
      if (o.interval) {
        y_userInterval = o.interval;
      }      

      if (isNaN(_userInterval))
        computedInterval = y_userInterval;

      if (isNaN(_userMinorInterval))
        _minorInterval = computedInterval / 2;

      // If the user wanted to us to autoadjust the min/max
      // to nice clean values, record the ones we just caluclated.
      // If the user has provided us with specific min/max values,
      // we won't blow that away here.
      if (autoAdjust) {
        if (isNaN(assignedMinimum))
          computedMinimum = y_lowerBound;

        if (isNaN(assignedMaximum))
          computedMaximum = y_topBound;
      }
    }

  }
}