package org.juicekit.util.interfaces
{
  
  /**
  * Interface for classes that want a version of themselves placed onto the clipboard.
  * @author Sal Uryasev
  */
  public interface iCSVToClipboard
  {
    /**
    * toClipboard should either return an ArrayCollection or String representation
    * of itself for placement onto the clipboard.
    */
    function CSVtoClipboard():*;
  }
}