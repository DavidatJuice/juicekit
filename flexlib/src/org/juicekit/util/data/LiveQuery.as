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
  import flash.events.TimerEvent;
  import flash.utils.Timer;
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
  public class LiveQuery extends EventDispatcher {
    
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

		 import flare.query.methods.*
    [Bindable(event='liveQueryRecalc')]
    public function get result():ArrayCollection {
      resultFetches += 1;
      if (dirty) {
        trace('getting result', queryName);
        resultCalculations += 1;

        if (dataProvider) {
          if (query) {
            var starttime:Number = getTimer();
            var r:Array = query.eval(dataProvider.source);
            evalTime = (getTimer() - starttime).toString() + 'ms';
            trace(queryName + ' ' + evalTime + ' ' + r.length.toString() + ' results');
            // Clear the dirty flag before setting _result.source
            // since setting _result.source might cause more 
            // attempts to fetch result.  
            dirty = false;
            recalcInProgress = false;
            if (_limit > 0) {
              _result.source = r.slice(0, limit);              
            } else {
              _result.source = r;              
            }
          } else {
            dirty = false;
            recalcInProgress = false;
            if (_limit > 0) {
              _result.source = dataProvider.source.slice(0, limit);
            } else {
              _result.source = dataProvider.source.slice();
            }
          }
          dispatchEvent(new Event(QUERY_CALCULATED, true));
        }
      }

      recalcInProgress = false;
      return _result;
    }
    private var _result:ArrayCollection = new ArrayCollection();


    //----------------------------------
    // dataProvider
    //----------------------------------

    public function set dataProvider(v:ArrayCollection):void {
      if (dataProvider) {
        dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, setDirty);
      }
      _dataProvider = v;
      dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, setDirty);
      setDirty();
      var r:ArrayCollection = result;
    }


    public function get dataProvider():ArrayCollection {
      return _dataProvider;
    }

    private var _dataProvider:ArrayCollection = null;


    //----------------------------------
    // query
    //----------------------------------

    public function set query(q:Query):void {
      trace('LiveQuery: set query for', queryName);
      _query = q;
      setDirty();
      //var r:ArrayCollection = result;
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
      setDirty();
    }


    public function get limit():int {
      return _limit;
    }

    private var _limit:int = 0;



    //----------------------------------
    // timer and dirty
    //----------------------------------

    /**
     * Signal that result has changed and needs recalculation.
     */
    public function setDirty(e:Event=null):void {
      dirty = true;
    }


    /**
    * The timer limits LiveQuery recalculations to 
    * once per <code>updateFrequency</code> milliseconds.
    * 
    */ 
    private var timer:Timer;
    
    /**
    * Suppress dirty events while recalc is occurring
    * 
    * TODO: is this too aggressive?
    */
    private var recalcInProgress:Boolean = false;
    
    /**
    * Called each tick of the timer
    */
    private function onTick(event:TimerEvent):void {
      if (dirty && !recalcInProgress) {
        recalcInProgress = true;
        dispatchEvent(new Event(LIVE_QUERY_RECALC));
      }
    }
    
    /**
    * Set whether the LiveQuery recalculates.
    */
    public function set enabled(v:Boolean):void {
      if (v) {
        timer.start();
      } else {
        timer.stop();
      }
    }
    public function get enabled():Boolean {
      return timer.running;
    } 
    
    /**
    * How frequently should this LiveQuery attempt to 
    * recalculate in ms.
    * 
    * <p>The default recalculation period is 100ms.</p>
    * 
    */
    public function set updateFrequency(v:int):void {
      timer.delay = v;
    }

    /**
     * Constructor
     */
    public function LiveQuery() {
      timer = new Timer(100);
      timer.addEventListener(TimerEvent.TIMER, onTick);
      timer.start();      
    }

  }
}