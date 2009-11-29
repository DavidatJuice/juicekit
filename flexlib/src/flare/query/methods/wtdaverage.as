package flare.query.methods
{
	import flare.query.WeightedAverage;


  /**
   * Creates a new <code>WeightedAverage</code> query operator.
   * @param expr the input expression
   * @param weight the expression to weight by
   * @return the new query operator
   */
  public function wtdaverage(expr:*, weight:*):WeightedAverage
	{
		return new WeightedAverage(expr, weight);
	}
}