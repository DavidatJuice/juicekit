/*
 * Copyright 2007-2009 Juice, Inc.
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

package org.juicekit.util.data {
  import flare.query.Query;
  
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.utils.getTimer;
  
  import mx.collections.ArrayCollection;
  import mx.events.CollectionEvent;
  import mx.utils.NameUtil;

  

  /**
   * Dispatched when data has been loaded.
   *
   * @eventType flash.events.Event
   */
  [Event(name="complete", type="flash.events.Event")]
  

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
  public dynamic class LiveQuery extends EventDispatcher {
    
    public static const QUERY_CALCULATED:String = 'complete';
    
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
            if (_limit > 0) {
              _result.source = r.slice(0, limit);              
            } else {
              _result.source = r;              
            }
          } else {
            dirty = false;
            if (_limit > 0) {
              _result.source = dataProvider.source.slice(0, limit);
            } else {
              _result.source = dataProvider.source.slice();
            }
          }
          dispatchEvent(new Event(QUERY_CALCULATED));
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
    // limit
    //----------------------------------

    /**
    * Restrict the number of results. Zero
    * means return all results
    * 
    * @default 0
    */
    public function set limit(v:int):void {
      _limit = v;
      acCollectionChange(new Event(LIVE_QUERY_RECALC));
    }


    public function get limit():int {
      return _limit;
    }

    private var _limit:int = 0;


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