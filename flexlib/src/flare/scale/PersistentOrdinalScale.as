package flare.scale {
  import flash.utils.Dictionary;


  public class PersistentOrdinalScale extends OrdinalScale {
    /**
     * Stores scales, with one scale per property
     */
    private static var _scaleStore:Object = {};

    private static var _ordinalCount:uint = 0;


    static public function getScale(ordinals:Array = null, flush:Boolean = false, copy:Boolean = true, labelFormat:String = null, property:String = null):PersistentOrdinalScale {
      if (_scaleStore[property] === undefined) 
        _scaleStore[property] = new PersistentOrdinalScale(ordinals, flush, copy, labelFormat);
      return _scaleStore[property];
    }


    public function PersistentOrdinalScale(ordinals:Array = null, flush:Boolean = false, copy:Boolean = true, labelFormat:String = null) {
      super(ordinals, flush, copy, labelFormat);
    }


    override protected function buildLookup():void {
      if (_lookup == null)
        _lookup = new Dictionary();
      for (var i:uint = 0; i < _ordinals.length; ++i) {
        if (_lookup[ordinals[i]] === undefined) {
          _lookup[ordinals[i]] = _ordinalCount;
          _ordinalCount++;
        }
      }
    }
    
    private var _spread:uint = 4;
    
    // Describes offsets as percentage of a _spread unit for the persistent ordinal distribution
    private var scatterer:Array = [1, 0.5, 0.25, 0.75, 0.125, 0.625, 0.375, 0.875, 0.0625, 0.5625, 0.1875, 0.6875, 0.3125, 0.8125, 0.4375, 0.9375];
    
    public override function interpolate(value:Object):Number
    {
//      if (_ordinals==null || _ordinals.length==0) return 0.5;
//      
//      if (_flush) {
//        return Number(_lookup[value]) / (_ordinals.length-1);
//      } else {
//        return (0.5 + _lookup[value]) / _ordinals.length;
//      }
      if (_ordinals==null || _ordinals.length==0) return 0.5;
      
      if (Number(_lookup[value]) == 0) return 0.0;
      
      var baseOffset:Number = scatterer[Math.floor((Number(_lookup[value]) - 1)/_spread) % scatterer.length];
      return (baseOffset + (Number(_lookup[value]) - 1) % _spread) / _spread;
    }


    /** @inheritDoc */
    public override function get scaleType():String {
      return ScaleType.PERSISTENT_ORDINAL;
    }

  }

}