package org.juicekit.flare.query {
  import flare.query.Query;
  
  import flash.events.Event;
  import flash.utils.getTimer;
  
  import mx.collections.ArrayCollection;
  import mx.events.CollectionEvent;
  import mx.utils.NameUtil;


  /**
   *
   * A LiveQuery allows an array of source data to be connected to a
   * summarization such that the result of the summarization is
   * continuously updated if the source data changes.
   *
   * A LiveQuery is defined by three inputs; an ArrayCollection,
   * a Flare Query, and an optional array of filterFunctions. The result
   * of the query can be found in <code>results</code>, a bindable
   * ArrayCollection that is lazily computed.
   *
   */
  [Bindable]
  public dynamic class LiveQuery {
    /**
     * The number of accesses of <code>result</code>
     * for performance and debugging purposes.
     */
    public var resultFetches:int = 0;
    // Number of times the result had to be calculated

    /**
     * The number of times <code>query</code> had to be
     * evaluated, for performance and debugging purposes.
     */
    public var resultCalculations:int = 0;

    /**
     * The number of milliseconds it took to evaluate
     * <code>query</code> during the most recent eval.
     *
     * @default 'NA'
     */
    public var evalTime:String = 'NA';
    
    public var queryName:String = NameUtil.createUniqueName(this);


    /**
     * A flag that stores if <code>result</code> needs to
     * be recalculated.
     */
    private var dirty:Boolean = true;

    private const LIVE_QUERY_RECALC:String = "liveQueryRecalc";


    //----------------------------------
    // result
    //----------------------------------

    /**
     * The result of <code>query</code> evaled against
     * <code>dataProvider.source</code> as an ArrayCollection.
     *
     * <code>result<code> is bindable.
     */
    [Bindable(event='liveQueryRecalc')]
    public function get result():ArrayCollection {
      resultFetches += 1;
      if (dirty) {
        resultCalculations += 1;

        if (dataProvider) {
          if (query) {
            if (filterFunctions) {
              query.where(function(o:Object):Boolean {
                  for each (var fs:*in filterFunctions) {
                    if (!fs.filterFunction(o))
                      return false;
                  }
                  return true;
                });
            }
            var starttime:Number = getTimer();
            var r:Array = query.eval(dataProvider.source);
            evalTime = (getTimer() - starttime).toString() + 'ms';
            trace(queryName + ' ' + evalTime + ' ' + r.length.toString() + ' results');
            // Clear the dirty flag before setting _result.source
            // since setting _result.source might cause more 
            // attempts to fetch result.  
            dirty = false;
            _result.source = r;
          } else {
            dirty = false;
            _result.source = dataProvider.source.slice();
          }
        }
      }

      return _result;
    }
    private var _result:ArrayCollection = new ArrayCollection();


    //----------------------------------
    // dataProvider
    //----------------------------------

    public function set dataProvider(v:ArrayCollection):void {
      if (dataProvider)
        dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, acCollectionChange);
      _dataProvider = v;
      dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, acCollectionChange);
      acCollectionChange(new Event(LIVE_QUERY_RECALC));
      var r:ArrayCollection = result;
    }


    public function get dataProvider():ArrayCollection {
      return _dataProvider;
    }

    private var _dataProvider:ArrayCollection = null;


    /**
     * The source data or the Query has changed.
     * Signal that result has changed and needs recalculation.
     */
    private function acCollectionChange(e:Event):void {
      dirty = true;
      dispatchEvent(new Event(LIVE_QUERY_RECALC));
    }

    //----------------------------------
    // query
    //----------------------------------

    public function set query(q:Query):void {
      _query = q;
      acCollectionChange(new Event(LIVE_QUERY_RECALC));
      var r:ArrayCollection = result;
    }


    public function get query():Query {
      return _query;
    }

    private var _query:Query = null;


    //----------------------------------
    // filter functions
    //----------------------------------

    /**
     *
     * @param v an ArrayCollection of functions with signature
     * <code></code>
     */
    public function set filterFunctions(v:ArrayCollection):void {
      var fs:*;
      if (filterFunctions) {
        for each (fs in filterFunctions) {
          fs.removeEventListener('filterChanged', acCollectionChange);
        }
      }

      _filterFunctions = v;
      for each (fs in filterFunctions) {
        fs.addEventListener('filterChanged', acCollectionChange);
      }
      
      acCollectionChange(new Event(LIVE_QUERY_RECALC));
    }


    public function get filterFunctions():ArrayCollection {
      return _filterFunctions;
    }

    private var _filterFunctions:ArrayCollection;

    /**
     * Constructor
     */
    public function LiveQuery() {

    }

  }
}