package org.juicekit.util.data {
import flare.query.Query;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;


public class MagicArrayCollection extends ArrayCollection {
  public function MagicArrayCollection() {
    super();
  }

  private var _query:Query = null;
  public function get query():Query {
    return _query;
  }
  public function set query(q:Query):void {
    if (_query != null) _query.removeEventListener('queryUpdated', dispatchQueryEvent);
    _query = q; 
    _query.addEventListener('queryUpdated', dispatchQueryEvent);
    dispatchQueryEvent();
  }
  
  private function dispatchQueryEvent(e:Event=null):void {
    _result = null;
    dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE));
  }
      

  private var _result:Array = null;


  [Inspectable(category="General", arrayType="Object")]
  [Bindable("listChanged")] //superclass will fire this

  /**
   *  The source of data in the ArrayCollection.
   */
  override public function get source():Array {
    if (query != null) {
      if (_result == null) _result = query.eval();
      return _result;
    }
    return null;
  }

  /**
   *  @private
   */
  override public function set source(s:Array):void {
//    throw new Error("Cannot set source on MagicArrayCollection. Use Query instead.");
  }

}
}