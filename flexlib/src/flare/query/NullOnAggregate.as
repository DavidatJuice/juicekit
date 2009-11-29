package flare.query
{
  /**
   * Aggregate operator for aggregating strings or nonnumberic objects.
   */
  public class NullOnAggregate extends AggregateExpression
  {
    private var _agg:*;
    
    /**
     * Creates a new Aggregate operator.
     * @param input the sub-expression of which to compute the aggregate
     * If only one value is aggregated, that value is the result.
     * If multiple value are passed in, the result is null.
     */
    public function NullOnAggregate(input:*) {
      super(input);
    }
    
    /**
     * @inheritDoc
     */
    public override function reset():void
    {
      _agg = 'notSet';
    }
    
    /**
     * @inheritDoc
     */
    public override function eval(o:Object=null):*
    {
      return _agg;
    }
    
    /**
     * @inheritDoc
     */
    public override function aggregate(value:Object):void
    {
//      var x:Number = Number(_expr.eval(value));
//      if (!isNaN(x)) {
//        _sum += x;
//      }
       if (_agg == 'notSet')
          _agg = _expr.eval(value);
       else
          _agg = null;
    }
    
  } // end of class Sum
}