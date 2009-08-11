package org.juicekit.visual.controls {
  import flare.util.Strings;
  
  import flash.events.Event;
  
  import mx.core.Application;
  import mx.events.PropertyChangeEvent;
  import mx.styles.CSSStyleDeclaration;
  import mx.styles.StyleManager;
  import mx.utils.ObjectProxy;
  
  import org.juicekit.flare.util.Colors;

  [Event(name="changeFormatters",type="mx.events.PropertyChangeEvent")]

  /**
   * Styler is a singleton class that manages font styling,
   * number formatting and color palettes in JuiceKit applications.
   *
   * JuicekitStyler can be accessed anywhere with <code>Styler.instance</code>.
   *
   * If the Styler is used, six CSS styleNames will be created.
   *
   * <ul>
   *   <li>.jkHeader</li>
   *   <li>.jkBase</li>
   *   <li>.jkNotes</li>
   *   <li>.jkHeaderEmphasis</li>
   *   <li>.jkBaseEmphasis</li>
   *   <li>.jkNotesEmphasis</li>
   * </ul>
   *
   *
   *
   */
  [Bindable]
  public class Styler {
    // Used to enforce the singleton.
    private static var _instance:Styler = new Styler(SingletonLock);

    private const HEADERSCALE:Number = 2.0;
    private const NOTESSCALE:Number = 0.8;

    // The options that will be used to set styles
    private var _baseOptions:Object = {};
    private var _headerOptions:Object = {};
    private var _notesOptions:Object = {};
    private var _emphasisOptions:Object = {};
    private var _baseEmphasisOptions:Object = {};
    private var _headerEmphasisOptions:Object = {};
    private var _notesEmphasisOptions:Object = {};

    // The options that have been set by the user
    private var _rawBaseOptions:Object = {fontFamily: 'Arial', fontSize: 12, color: 0x333333};
    private var _rawHeaderOptions:Object = {};
    private var _rawNotesOptions:Object = {};
    private var _rawEmphasisOptions:Object = { fontWeight: 'bold' };


    public function Styler(lock:Class) {
      formatters.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, function():void {
          dispatchEvent(new Event('changeFormatters'));
        });

      if (lock != SingletonLock) {
        throw new Error("Invalid Singleton access. Use JuicekitStyler.instance");
      }
    }

    [Bindable('instanceChange')]
    public static function get instance():Styler {
      return _instance;
    }

    public var formatters:ObjectProxy = new ObjectProxy({});


    public function setFormatForField(fieldName:String, format:Object):void {
      if (format is String) {
        formatters[fieldName] = function(o:Object):String {
          return Strings.format(format as String, o);
        }
      }
      if (format is Function) {
        formatters[fieldName] = format;
      }
      dispatchEvent(new Event('changeFormatters'));
    }


    [Bindable(event="changeFormatters")]
    public function getFormatForField(fieldName:String):Function {
      if (formatters.hasOwnProperty(fieldName)) {
        return formatters[fieldName];
      } else {
        return function(o:Object):String {
          return o.toString();
        }
      }
    }

    /*--- utility functions ---*/

    /**
     * Combine the key/values in a base option with an overlay object
     *
     * If a key exists in the overlay, it's value will overwrite the
     * value in base.
     *
     * For instance:
     *
     * mergeProperties({x: 1, y: 2}, {x: 2, z: 4}) returns
     * {x:2, y:2, z:4}
     *
     * @param base a base object
     * @param overlay an overlay that will override values in base
     * @returns an Object containing combined base and overlay keys
     */
    private function mergeProperties(base:Object, overlay:Object):Object {
      var k:String;
      var result:Object = {};
      for (k in base) {
        result[k] = base[k];
      }
      for (k in overlay) {
        result[k] = overlay[k];
      }
      return result;
    }


    /**
     * Stores the styles values that were set by setStyle. We want to be
     * able to override styles that were set by JuicekitStyler, but not
     * override styles that were set manually in the application. This 
     * lets us look up styles that we set and use them as 
     * overrideDefaults.
     */	 
    private var styleCache:Object = {}


    /**
     * Set style for a selector.styleProp to newValue. If the selector.styleProp
     * is already set, then do not set the style. overrideDefault lets you override
     * css styles that are already set to the overrideDefault value.
     *
     * @param selector the css selector to change
     * @param styleProp the css style property to change
     * @param newValue the new value to set the css styleProp to
     * @param overrideDefault override this default value if it exists with newValue
     * @returns if the style was set
     */
    public function setStyle(selector:String, styleProp:String, newValue:Object, overrideDefault:Object = null):Boolean {
      var key:String = selector + '.' + styleProp;
      var setStyleResult:Boolean = false;
      if (styleCache.hasOwnProperty(key) && overrideDefault == null) {
        overrideDefault = styleCache[key];
      }

      var styledecl:CSSStyleDeclaration = StyleManager.getStyleDeclaration(selector);
      if (styledecl == null) {
        styledecl = new CSSStyleDeclaration(selector);
        StyleManager.setStyleDeclaration(selector, styledecl, true);
      }

      if (styledecl.getStyle(styleProp) === undefined || (overrideDefault != null && styledecl.getStyle(styleProp) == overrideDefault)) {
        StyleManager.getStyleDeclaration(selector).setStyle(styleProp, newValue)
        styleCache[key] = newValue;
        setStyleResult = true;
      }
      return setStyleResult;
    }
    

    /**
     * Set a series of options.
     *
     * The key/value pairs in the options object are applied
     * to the selector. They are only applied to the selector
     * if the style is not already set.
     *
     * @param selector a css selector
     * @param options an object containing css key/value pairs
     * to set on the selector
     */
    public function setOptions(selector:String, options:Object):void {
      for (var styleProp:String in options) {
        setStyle(selector, styleProp, options[styleProp]);
      }
    }
    
    
    //----------------------------
    // base options
    //----------------------------

    /**
    * Set the base font options
    * 
    * The base font style is propagated to the header and
    * notes font style unless those styles are overridden by 
    * <code>headerOptions</code> and <code>notesOptions</code>.
    * 
    * The default 
    * 
    */
    public function set baseOptions(opts:Object):void {
      // Save all the base options set by the user
      _rawBaseOptions = mergeProperties(_rawBaseOptions, opts);
      // default base options
      var defaults:Object = {fontFamily: 'Arial', fontSize: 12, color: 0x333333}
      _baseOptions = mergeProperties(defaults, _rawBaseOptions);
      // reapply all the styles
      headerOptions = _rawHeaderOptions;
      notesOptions = _rawNotesOptions;
      emphasisOptions = _rawEmphasisOptions;
      applyStyles();
    }

    public function get baseOptions():Object {
      return _baseOptions;
    }


    //----------------------------
    // header options
    //----------------------------

    public function set headerOptions(opts:Object):void {
      // save all the options that have been set by the user
      _rawHeaderOptions = mergeProperties(_rawHeaderOptions, opts);
      // copy the baseOptions to _headerOptions
      _headerOptions = mergeProperties({}, _baseOptions);
      // set the header font size to HEADERSCALE*base font size
      var defaults:Object = { fontSize: _baseOptions.fontSize * HEADERSCALE }
      // apply any overrides in opts
      _headerOptions = mergeProperties(defaults, _rawHeaderOptions);
      applyStyles();
    }

    public function get headerOptions():Object {
      return _headerOptions;
    }


    //----------------------------
    // notes options
    //----------------------------

    public function set notesOptions(opts:Object):void {
      _rawNotesOptions = mergeProperties(_rawNotesOptions, opts);
      var defaults:Object = {
        fontSize: _baseOptions.fontSize * NOTESSCALE,
        color: Colors.adjustContrast(Colors.desaturate(_baseOptions.color, 0.6), -0.3)
      }
      _notesOptions = mergeProperties(defaults, _rawNotesOptions);
      applyStyles();
    }

    public function get notesOptions():Object {
      return _notesOptions;
    }


    //----------------------------
    // emphasis options
    //----------------------------

    public function set emphasisOptions(opts:Object):void {
      _rawEmphasisOptions = mergeProperties(_rawEmphasisOptions, opts);
      var defaults:Object = { fontWeight: 'bold' };

      _baseEmphasisOptions = mergeProperties(_baseOptions, opts);
      _headerEmphasisOptions = mergeProperties(_headerOptions, opts);
      _notesEmphasisOptions = mergeProperties(_notesOptions, opts);
      applyStyles();
    }

    public function get emphasisOptions():Object {
      return _emphasisOptions;
    }


    public function setStyles(baseopts:Object = null, 
                              headeropts:Object = null, 
                              notesopts:Object = null, 
                              emphasisopts:Object = null):void {
      baseOptions = baseopts;
      headerOptions = headeropts;
      notesOptions = notesopts;
      emphasisOptions = emphasisopts;
    }


    public function applyStyles():void {
      // applyStyles needs to be called AFTER application initialization

      // Set the application background to white if it has not been defined			
      if (Application.application.getStyle('backgroundGradientColors') == undefined) {
        Application.application.setStyle('backgroundGradientColors', [0xffffff, 0xffffff]);
      }

      // All Flex apps start with global styles of Tahoma, 10, #0b333c set
      // Override these defaults.
      setStyle('global', 'fontFamily', _baseOptions.fontFamily, 'Tahoma');
      setStyle('global', 'fontSize', _baseOptions.fontSize, 10);
      setStyle('global', 'color', _baseOptions.color, 0x0b333c);

      // TODO: apply styles to specific global selectors here
      // like treemap, datagrid, etc

      setOptions('ComboBox', _baseOptions);
      setOptions('DataGrid', _baseOptions);
      setOptions('Button', _baseOptions);
      setOptions('Label', _baseOptions);
      setOptions('FlareBarChart2', _baseOptions);
      setOptions('.jkBase', _baseOptions);
      setOptions('.jkHeader', _headerOptions);
      setOptions('.jkNotes', _notesOptions);

      setOptions('.jkBaseEmphasis', _baseEmphasisOptions);
      setOptions('.jkHeaderEmphasis', _headerEmphasisOptions);
      setOptions('.jkNotesEmphasis', _notesEmphasisOptions);
    }

  }
}

// A design pattern that ensures that the constructor can only be called from within this class
class SingletonLock {
}