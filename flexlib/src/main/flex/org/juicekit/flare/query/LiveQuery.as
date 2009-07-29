package org.juicekit.flare.query {
  import flare.query.Query;
  
  import flash.events.Event;
  import flash.utils.getTimer;
  
  import mx.collections.ArrayCollection;
  import mx.events.CollectionEvent;


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
    * Usable for performance tuning. The number of fetches
    * of data from <code>result</code>.
    */
    public var resultFetches:int = 0;
    
    
    /**
    * Usable for performance tuning. The number of times
    * <code>result</code> had to be recalculated.
    */
    public var resultCalculations:int = 0;
    
    
    /**
    * Usable for performance tuning. How many milliseconds
    * did it take to evaluate the <code>query</code>.
    */
    public var evalTime:String = 'NA';

    /**
    * @private 
    * 
    * Does the result need to be recalculated?
    */
    private var dirty:Boolean = true;
    
    
    private const REQUIRE_RECALC:String = 'requireRecalc';


    //---------------------------------
    // Result
    //---------------------------------

    /**
     * The results of the <code>query</code> evaluated against
     * the data in <code>dataProvider</code>. <code>result</code>
     * is evaluated whenver data in <code>dataProvider</code> 
     * changes.
     *
     */
    [Bindable(event=REQUIRE_RECALC)]
    public function get result():ArrayCollection {
      resultFetches += 1;
      if (dirty) {
        resultCalculations += 1;

        if (dataProvider) {
          if (query) {
            if (filterFunctions) {
              query.where(function(o:Object):Boolean {
                  for each (var fs:* in filterFunctions) {
                    if (!fs.filterFunction(o))return false;
                  }
                  return true;
                });
            }
            var starttime:Number = getTimer();
            var r:Array = query.eval(dataProvider.source);
            evalTime = (getTimer() - starttime).toString() + 'ms';
            // Clear the dirty flag before setting _result.source
            // since setting _result.source might cause more 
            // attempts to fetch result.  
            dirty = false;
            _result.source = r;
          } else {
            dirty = false;
            _result = new ArrayCollection(dataProvider.source.slice());
          }
        }
      }

      return _result;
    }

    private var _result:ArrayCollection = new ArrayCollection();


    /**
     * The source data or the Query has changed.
     * Signal that result has changed and needs recalculation.
     */
    private function acCollectionChange(e:Event):void {
      dirty = true;
      dispatchEvent(new Event(REQUIRE_RECALC));
    }


    //---------------------------------
    // Data provider
    //---------------------------------
    
    
    /**
    * Provides source data to the <code>query</code>.
    */
    public function set dataProvider(v:ArrayCollection):void {
      if (dataProvider)
        dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, acCollectionChange);
      _dataProvider = v;
      dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, acCollectionChange);
      acCollectionChange(new Event(REQUIRE_RECALC));
    }


    public function get dataProvider():ArrayCollection {
      return _dataProvider;
    }

    private var _dataProvider:ArrayCollection = null;


    //---------------------------------
    // Query
    //---------------------------------

    /**
    * A Flare Query that determines how the data in 
    * <code>dataProvider</code> will be summarized.
    */
    public function set query(q:Query):void {
      _query = q;
      acCollectionChange(new Event(REQUIRE_RECALC));
    }

    public function get query():Query {
      return _query;
    }

    private var _query:Query = null;



    //---------------------------------
    // Filter functions
    //---------------------------------

    private var _filterFunctions:ArrayCollection;


    public function set filterFunctions(v:ArrayCollection):void {
      var ff:*;
      
      if (filterFunctions) {
        _filterFunctions.removeEventListener(CollectionEvent.COLLECTION_CHANGE, acCollectionChange);
        for each (ff in filterFunctions) {
          ff.removeEventListener('filterChanged', acCollectionChange);
        }
      }

      _filterFunctions = v;
      filterFunctions.addEventListener(CollectionEvent.COLLECTION_CHANGE, acCollectionChange);
      for each (ff in filterFunctions) {
        ff.addEventListener('filterChanged', acCollectionChange);
      }
      acCollectionChange(new Event(REQUIRE_RECALC));
    }


    public function get filterFunctions():ArrayCollection {
      return _filterFunctions;
    }


    /**
    * Constructor
    */
    public function LiveQuery() {
    }

  }
}