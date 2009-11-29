package flare.query.methods
{
  import flare.query.NullOnAggregate;
  
  /**
   * Creates a new 'sum' <code>Arithmetic</code> query operator.
   * @param expr the input expression
   * @return the new query operator
   */
  public function noa(expr:*):NullOnAggregate
  {
    return new NullOnAggregate(expr);
  }
}