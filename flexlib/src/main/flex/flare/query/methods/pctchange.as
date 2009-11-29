package flare.query.methods
{
	import flare.query.Arithmetic;


  /**
   * Creates a new <code>Arithmetic</code> query operator.
   * 
   * This evaluates <code>(newval-oldval) / oldval</code>
   * 
   * @param newval the new value expression
   * @param oldval the old value expression
   * @return the new query operator
   */
  public function pctchange(newval:*, oldval:*):Arithmetic
	{
		return Arithmetic.Divide(Arithmetic.Subtract(sum(newval), sum(oldval)), sum(oldval));
	}
}