/*
 * Copyright (c) 2007-2010 Regents of the University of California.
 *   All rights reserved.
 *
 *   Redistribution and use in source and binary forms, with or without
 *   modification, are permitted provided that the following conditions
 *   are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 *
 *   3.  Neither the name of the University nor the names of its contributors
 *   may be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *   ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 *   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 *   OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *   SUCH DAMAGE.
 */

package flare.vis.operator.layout
{
import flare.util.Arrays;
import flare.vis.data.EdgeSprite;
import flare.vis.data.NodeSprite;

import flash.geom.Point;

/**
 * Layout that places tree nodes in an indented outline layout.
 */
public class IndentedTreeLayout extends Layout
{
  private var _bspace:Number = 5;  // the spacing between sibling nodes
  private var _dspace:Number = 50; // the spacing between depth levels
  private var _depths:Array = new Array(20); // TODO make sure array regrows as needed
  private var _maxDepth:int = 0;
  private var _ax:Number, _ay:Number; // for holding anchor co-ordinates

  /** The spacing to use between depth levels (the amount of indent). */
  public function get depthSpacing():Number {
    return _dspace;
  }

  public function set depthSpacing(s:Number):void {
    _dspace = s;
  }

  /** The spacing to use between rows in the layout. */
  public function get breadthSpacing():Number {
    return _bspace;
  }

  public function set breadthSpacing(s:Number):void {
    _bspace = s;
  }

  // --------------------------------------------------------------------

  /**
   * Creates a new IndentedTreeLayout.
   * @param depthSpace the amount of indent between depth levels
   * @param breadthSpace the amount of spacing between rows
   */
  public function IndentedTreeLayout(depthSpace:Number = 50,
                                     breadthSpace:Number = 5)
  {
    _bspace = breadthSpace;
    _dspace = depthSpace;
  }

  /** @inheritDoc */
  protected override function layout():void
  {
    Arrays.fill(_depths, 0);
    _maxDepth = 0;

    var a:Point = layoutAnchor;
    _ax = a.x + layoutBounds.x;
    _ay = a.y + layoutBounds.y;

    var root:NodeSprite = layoutRoot as NodeSprite;
    if (root == null) return; // TODO: throw exception?

    layoutNode(root, 0, 0, true);
  }


  private function layoutNode(node:NodeSprite, height:Number, indent:uint, visible:Boolean):Number
  {
    var x:Number = _ax + indent * _dspace;
    var y:Number = _ay + height;
    var o:Object = _t.$(node);
    node.h = _t.endSize(node, _rect).height;

    // update node
    o.x = x;
    o.y = y;
    o.alpha = visible ? 1.0 : 0.0;

    // update edge
    if (node.parentEdge != null)
    {
      var e:EdgeSprite = node.parentEdge;
      var p:NodeSprite = node.parentNode;
      o = _t.$(e);
      o.alpha = visible ? 1.0 : 0.0;
      if (e.points == null) {
        e.points = [(p.x + node.x) / 2, (p.y + node.y) / 2];
      }
      o.points = [_t.getValue(p, "x"), y];
    }

    if (visible) {
      height += node.h + _bspace;
    }
    if (!node.expanded) {
      visible = false;
    }

    if (node.childDegree > 0) // is not a leaf node
    {
      var c:NodeSprite = node.firstChildNode;
      for (; c != null; c = c.nextNode) {
        height = layoutNode(c, height, indent + 1, visible);
      }
    }
    return height;
  }

} // end of class IndentedTreeLayout
}