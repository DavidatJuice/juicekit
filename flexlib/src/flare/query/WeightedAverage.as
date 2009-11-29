package flare.query {


  /**
   * Aggregate operator for computing the weighted average of a set of values.
   */
  public class WeightedAverage extends AggregateExpression {
    protected var _sum:Number;
    protected var _weight:Number;

    /** The sub-expression that forms the weighting. */
    protected var _wt:Expression;


    /** The sub-expression to aggregate. */
    public function get weight():Expression {
      return _wt;
    }


    public function set weight(e:*):void {
      _wt = Expression.expr(e);
    }


    /**
     * Creates a new WeightedAverage operator. The weighted average is equal
     * to <code>sum(input expression*weight expression) / sum(weight expression)</code>
     *
     * @param input the sub-expression of which to compute the average
     * @param weight the sub-expression to use to weight the average
     */
    public function WeightedAverage(input:*, weight:*) {
      this.weight = weight;
      super(input);
    }


    /**
     * @inheritDoc
     */
    public override function reset():void {
      _sum = 0;
      _weight = 0;
    }


    /**
     * @inheritDoc
     */
    public override function eval(o:Object = null):* {
      return _sum / _weight;
    }


    /**
     * @inheritDoc
     */
    public override function aggregate(value:Object):void {
      var x:Number = Number(_expr.eval(value));
      var w:Number = Number(_wt.eval(value));
      if (!isNaN(x) && !(isNaN(w))) {
        _sum += x * w;
        _weight += w;
      }
    }

  } // end of class WeightedAverage
}