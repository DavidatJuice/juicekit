/*
 * -*- Mode: Actionscript -*-
 * *************************************************************************
 *
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
 *
 * *************************************************************************
 */



package org.juicekit.util.data {
  import flare.query.Query;
  import flare.query.methods.*;
  import flare.util.Shapes;
  import flare.vis.data.Data;
  import flare.vis.data.DataSprite;
  import flare.vis.data.NodeSprite;
  import flare.vis.data.Tree;

  /**
   * Utilities for generating sample data and Graph structures
   * from data.
   *
   * Derived from flaredemos.
   */

  public class GraphUtil {
    
    public static const TREENODEDIRTY:String = "__treeNodeDirty";
    
    public static function printTree(n:NodeSprite, d:int):void {
      trace(n.name + "\t" + n.u + "\t" + n.v + "\t" + n.w + "\t" + n.h);
      for (var i:uint = 0; i < n.childDegree; ++i) {
        printTree(n.getChildNode(i), d + 1);
      }
    }


    // -- Graph Generators ------------------------------------------------

    /**
     * Builds a completely unconnected (edge-free) graph with the given
     * number of nodes
     * @param n the number of nodes
     * @return a graph with n nodes and no edges
     */
    public static function nodes(n:uint):Data {
      var g:Data = new Data();
      for (var i:uint = 0; i < n; i++) {
        var node:NodeSprite = g.addNode();
        node.data.label = String(i);
      }
      return g;
    }


    /**
     * Builds a "star" graph with one central hub connected to the given
     * number of satellite nodes.
     * @param n the number of points of the star
     * @return a "star" graph with n points, for a total of n+1 nodes
     */
    public static function star(n:uint):Data {
      var g:Data = new Data();

      var r:NodeSprite = g.addNode();
      r.data.label = "0";

      for (var i:uint = 1; i <= n; ++i) {
        var nn:NodeSprite = g.addNode();
        nn.data.label = String(i);
        g.addEdgeFor(r, nn);
      }
      return g;
    }


    /**
     * Returns a clique of given size. A clique is a graph in which every node
     * is a neighbor of every other node.
     * @param n the number of nodes in the graph
     * @return a clique of size n
     */
    public static function clique(n:uint):Data {
      var g:Data = new Data();
      var i:uint, j:uint;

      var nodes:Array = new Array(n);
      for (i = 0; i < n; ++i) {
        nodes[i] = g.addNode();
        nodes[i].data.label = String(i);
      }
      for (i = 0; i < n; ++i) {
        for (j = i; j < n; ++j)
          if (i != j)
            g.addEdgeFor(nodes[i], nodes[j]);
      }
      return g;
    }


    /**
     * Returns a graph structured as an m-by-n grid.
     * @param m the number of rows of the grid
     * @param n the number of columns of the grid
     * @return an m-by-n grid structured graph
     */
    public static function grid(m:uint, n:uint):Data {
      var g:Data = new Data();

      var nodes:Array = new Array(m * n);
      for (var i:uint = 0; i < m * n; ++i) {
        nodes[i] = g.addNode();
        nodes[i].data.label = String(i);

        if (i >= n)
          g.addEdgeFor(nodes[i - n], nodes[i]);
        if (i % n != 0)
          g.addEdgeFor(nodes[i - 1], nodes[i]);
      }
      return g;
    }


    public static function honeycomb(levels:uint):Data {
      var g:Data = new Data();
      var layer1:Array = halfcomb(g, levels);
      var layer2:Array = halfcomb(g, levels);
      for (var i:uint = 0; i < (levels << 1); ++i) {
        var n1:NodeSprite = layer1[i];
        var n2:NodeSprite = layer2[i];
        g.addEdgeFor(n1, n2);
      }
      return g;
    }


    private static function halfcomb(g:Data, levels:uint):Array {
      var top:Array = new Array();
      var layer:Array = new Array();
      var label:uint = 0, i:uint, j:uint;

      for (i = 0; i < levels; ++i) {
        var n:NodeSprite = g.addNode();
        n.data.label = String(label++);
        top.push(n);
      }
      for (i = 0; i < levels; ++i) {
        n = null;
        for (j = 0; j < top.length; ++j) {
          var p:NodeSprite = top[j];
          if (n == null) {
            n = g.addNode();
            n.data.label = String(label++);
            layer.push(n);
          }
          g.addEdgeFor(p, n);
          n = g.addNode();
          n.data.label = String(label++);
          layer.push(n);
          g.addEdgeFor(p, n);
        }
        if (i == levels - 1) {
          return layer;
        }
        top.splice(0, top.length);
        for (j = 0; j < layer.length; ++j) {
          p = layer[j];
          n = g.addNode();
          n.data.label = String(label++);
          top.push(n);
          g.addEdgeFor(p, n);
        }
        layer.splice(0, layer.length);
      }
      // should never happen
      return top;
    }


    /**
     * Returns a balanced tree of the requested breadth and depth.
     * @param breadth the breadth of each level of the tree
     * @param depth the depth of the tree
     * @return a balanced tree
     */
    public static function balancedTree(breadth:uint, depth:uint):Tree {
      var t:Tree = new Tree();
      var r:NodeSprite = t.addRoot();
      r.data.label = "0,0";

      if (depth > 0)
        balancedHelper(t, r, breadth, depth - 1);
      return t;
    }


    private static function balancedHelper(t:Tree, n:NodeSprite,
      breadth:uint, depth:uint):void {
      for (var i:uint = 0; i < breadth; ++i) {
        var c:NodeSprite = t.addChild(n);
        c.data.label = i + "," + c.depth;
        if (depth > 0)
          balancedHelper(t, c, breadth, depth - 1);
      }
    }


    /**
     * Returns a left deep binary tree
     * @param depth the depth of the tree
     * @return the generated tree
     */
    public static function leftDeepTree(depth:uint):Tree {
      var t:Tree = new Tree();
      var r:NodeSprite = t.addRoot();
      r.data.label = "0,0";

      deepHelper(t, r, 2, depth, true);
      return t;
    }


    /**
     * Returns a right deep binary tree
     * @param depth the depth of the tree
     * @return the generated Tree
     */
    public static function rightDeepTree(depth:uint):Tree {
      var t:Tree = new Tree();
      var r:NodeSprite = t.addRoot();
      r.data.label = "0,0";

      deepHelper(t, r, 2, depth, false);
      return t;
    }


    /**
     * Create a diamond tree, with a given branching factor at
     * each level, and depth levels for the two main branches.
     * @param b the number of children of each branch node
     * @param d1 the length of the first (left) branch
     * @param d2 the length of the second (right) branch
     * @return the generated Tree
     */
    public static function diamondTree(b:int, d1:int, d2:int):Tree {

      var tree:Tree = new Tree();
      var n:NodeSprite = tree.addRoot();
      var l:NodeSprite = tree.addChild(n);
      var r:NodeSprite = tree.addChild(n);

      deepHelper(tree, l, b, d1 - 2, true);
      deepHelper(tree, r, b, d1 - 2, false);

      while (l.firstChildNode != null)
        l = l.firstChildNode;
      while (r.lastChildNode != null)
        r = r.lastChildNode;

      deepHelper(tree, l, b, d2 - 1, false);
      deepHelper(tree, r, b, d2 - 1, true);

      return tree;
    }


    private static function deepHelper(t:Tree, n:NodeSprite,
      breadth:int, depth:int, left:Boolean):void {
      var c:NodeSprite = t.addChild(n);
      if (left && depth > 0)
        deepHelper(t, c, breadth, depth - 1, left);

      for (var i:uint = 1; i < breadth; ++i) {
        c = t.addChild(n);
      }

      if (!left && depth > 0)
        deepHelper(t, c, breadth, depth - 1, left);
    }


    private static function aggr(n1:NodeSprite, n2:NodeSprite):NodeSprite {
      // combine values of two nodesprites
      var lookup:Object = {
          'value': function(v1:Object, v2:Object):Object {return (v1 as Number) + (v2 as Number)}
        }
      for (var fld:String in n1.data) {
        var v1:Object = n1.data[fld];
        var v2:Object = n2.data[fld];
        if (lookup.hasOwnProperty(fld)) {
          n1.data[fld] = lookup[fld](v1, v2);
        }
      }
      return n1;
    }


    /**
     * Recursively generate a tree branch for an existing tree
     * 
     * @param tree is the existing tree
     * @param n is the node where to start the tree (usually the root node)
     * @param levels is a list of dimensions to create in the tree
     * @param o is a data row object
     * @return the last generated node
     */
    private static function generateTreeMapBranch(tree:Tree, 
                                                 n:NodeSprite, 
                                                 levels:Array,
                                                 o:Object):NodeSprite {
      var name:String = levels.shift();
      
      for (var i:int = 0; i < n.childDegree; i++) {      	
        if (n.getChildNode(i).data[name] == o[name]) {
          if (levels.length > 0) {
            return generateTreeMapBranch(tree, n.getChildNode(i), levels.slice(), o);
          }
          else {
            //If the node already exists, update its data.
            //This functionality is mostly for use with the matchTree parameter.
            var c:NodeSprite = n.getChildNode(i);
            //c.shape = Shapes.TREEMAPBLOCK;
            c.data = o;
            c.data['name'] = o[name];
            c.props[TREENODEDIRTY] = false;
            return c;
          }
        }
      }
      // If we did not find anything, create a node
      var c:NodeSprite = tree.addChild(n);
      // TreeMap requires the shape attribute of nodes be TREEMAPBLOCK
      c.shape = Shapes.TREEMAPBLOCK;
      c.data = o;
      c.data['name'] = o[name];
      c.props[TREENODEDIRTY] = false;
      if (levels.length > 0) {
        return generateTreeMapBranch(tree, c, levels.slice(), o);
      }
      else {
        return c;
      }
    } 
     
     
    /**
    * <p>Generates a treemap data structure given an array of data objects.</p>
    * 
    * <p>The tree will be generated with the levels specified.</p>
    * 
    * <p>Consider a case if dataArray is:</p>
    * 
    * <pre><code>
    * 	[{state: 'California': year: '2009', people: 200, avg_income: 600},
    *    {state: 'California': year: '2008', people: 200, avg_income: 400}, 
    * 	 {state: 'Oregon': year: '2009', people: 400, avg_income: 200}]
    * </code></pre>
    * 
    * <p><code>treeMap(dataArray, ['state', 'year'], ['people'])</code> will generate 
    * (indentation indicates node tree):</p>
    * 
    * <pre><code>
    * {'name': 'All', 'people': 800}
    *     {'name': 'California', 'people': 400}
    *         {'name': '2009', 'people': 200 }
    *         {'name': '2008', 'people': 200 }
    *     {'name': 'Oregon', 'people': 400 }
    *         {'name': '2009', 'people': 400 }
    * </code></pre>
    * 
    * <p>Metrics will sum by default.<p>
    * 
    * <p>You can perform different calculations on the metrics using flare query
    * expressions.</p>
    * 
    * <pre><code>
    * import flare.query.methods.*
    * treeMap(dataArray, ['state', 'year'], 
    *    ['people', 
    *     {avginc: weightedavg('avg_income', 'people')]
    * 
    * {'name': 'All', 'people': 800, 'avginc': 350}
    *     {'name': 'California', 'people': 300, 'avginc': 500}
    *         {'name': '2009', 'people': 100, 'avginc': 600}
    *         {'name': '2008', 'people': 200, 'avginc': 400}
    *     {'name': 'Oregon', 'people': 400, 'avginc': 200}
    *         {'name': '2009', 'people': 400, 'avginc': 200}
    * </code></pre>
    * 
    * @param dataArray the source array containing objects
    * @param fields an array of treemap levels to generate
    * @param metrics the metrics to create, these can be strings or flare query expressions
    * if strings, the value will be summed across child nodes
    * @param rowFilter an optional filter function that takes a row and returns boolean
    * @returns a Flare Tree structure suitable for assigning to TreeMapControl.data
    */
    public static function treeMap(dataArray:Array, 
                                   levels:Array,
                                   metrics:Array,
                                   rowFilter:Function=null,
                                   matchTree:Tree=null):Tree {
      var c:NodeSprite;
      var i:int;
      var k:String;
      var o:Object;
      var tree:Tree;
      //If matchTree contains a tree, merge the new data into that tree instead of creating a new tree
      if (matchTree) {
         tree = matchTree;
         var rootNode:NodeSprite = tree.root;
         tree.nodes.visit(function(n:DataSprite) {
           n.props[TREENODEDIRTY] = true;
         });
         rootNode.props[TREENODEDIRTY] = false;
      }
      else {
        tree = new Tree();
        var rootNode:NodeSprite = tree.addRoot();
        // All TreeMap nodes must have Shapes.TREEMAPBLOCK
        rootNode.shape = Shapes.TREEMAPBLOCK;
        rootNode.data['name'] = 'All';
      }
      
      var _metrics:Array = [];
      for each (var v:* in metrics) {
        // if an aggregate expression is not present
        // then sum the value
        if (v is String) {
          var d:Object = {};
          d[v] = sum(v);
          _metrics.push(d);
        }
        else {
          _metrics.push(v);
        }
      }
      metrics = _metrics;

      // Calculate data for the root node
      // Grouping by the Literal 1 groups everything
      var rootquery:Query = new Query(metrics, rowFilter, null, ["'1'"]);
      var result:Object = rootquery.eval(dataArray);
      if (result && result.length>0) {
//        for (k in result[0]) {
//          rootNode.data[k] = result[0][k]
//        }        
          rootNode.data = result[0];
          rootNode.data['name'] = 'All';
      } 

      // Perform a discrete summarization for each level of the tree.
      // Summarize with the dimensions for the level of the tree and all
      // higher levels, and all the metrics.      
      for (i=0; i<levels.length; i++) {
        var query:Query;
                
        query = select.apply(null, levels.slice(0,i+1).concat(metrics));
        query = query.groupby.apply(null, levels.slice(0,i+1));
        if (rowFilter != null) {
        	query = query.where(rowFilter)
        }
        
        var resultArray:Array = query.eval(dataArray);
        
        for each (o in resultArray) {
            generateTreeMapBranch(tree, rootNode, levels.slice(0,i+1), o);
        }
      }
      
      if (matchTree) {
         tree.nodes.visit(function(n:DataSprite) {
           if (n.props[TREENODEDIRTY] != null && n.props[TREENODEDIRTY])
              tree.removeNode(n as NodeSprite);
         },
         null,
         true);
      }
      return tree;
    }


    /**
     * Generates a word tree structure from an array of objects.
     *
     * @param arr the source array
     * @param rootword the word to use as the root of the tree
     * @param reverse calculate the wordtree forwards or backwards
     * @param addTerminator add "START" and "END" terminators at the end of phrases
     * @param removeStartEnd remove terminators after generating trees if the terminator is
     * the only child of a node
     * @param coalesceNodes group nodes that contain only a single child
     * @param delimiter what is the delimiter in the phrases, default is ' '
     * @returns the generated tree
     */
    public static function wordTree(arr:Array, rootword:String = "hotels", reverse:Boolean = true, addTerminator:Boolean = false, removeStartEnd:Boolean = true, coalesceNodes:Boolean = true, delimiter:String = ' '):Tree {
      var tree:Tree = new Tree();
      var n:NodeSprite = tree.addRoot();
      var c:NodeSprite;
      var newNode:NodeSprite;
      var i:int;
      var k:String;
      // prevent the root name from displaying in ConcentrateTree
      tree.root.name = '';
      for each (var obj:Object in arr) {
        var p:NodeSprite = tree.root;
        newNode = new NodeSprite();

        var contains_word:Boolean = false;
        var words:Array = obj.label.split(delimiter);
        if (reverse)
          words = words.reverse();
        if (addTerminator) {
          if (reverse) {
            words.push('START');
          } else {
            words.push('END');
          }
        }
        for (i = 0; i < words.length; i++) {
          if (words[i] == rootword) {
            contains_word = true;
            words = words.slice(i);
            break;
          }
        }
        
        if (contains_word) {
          newNode = new NodeSprite();
          for (k in obj) {
            newNode.data[k] = obj[k];
            tree.root.data[k] = obj[k];
          }

          aggr(tree.root, newNode)
          for each (var word:String in words.slice(1)) {
            var found:Boolean = false;
            for (i = 0; i < p.childDegree; i++) {
              c = p.getChildNode(i);
              if (c.data.label == word) {
                c = aggr(c, newNode);
                p = c;
                found = true;
                break;
              }
            }
            if (!found) {
              c = tree.addChild(p);
              for (k in obj) {
                c.data[k] = obj[k];
              }
              c.data.label = word;
              c.name = word;
              p = c;
            }
            if (!p.data.hasOwnProperty('labels')) {
              p.data['labels'] = [];
            }
            p.data['labels'].push(obj.label);
          }
        }
      }

      if (removeStartEnd) {
        tree.root.visitTreeDepthFirst(function(n:NodeSprite):Boolean {
            if (n.parentNode != null && (n.data.label == 'START' || n.data.label == 'END')) {
              var p:NodeSprite = n.parentNode;

              if (p != null && p.childDegree == 1) {
                tree.remove(n);
                return false;
              }
            }
            return false;
          });
      }

      // Join nodes that have only one item
      //
      //          /-B
      //  A -----
      //         \-C----D----E
      //
      //
      //         /-B
      //  A -----
      //         \-C D E
      //
      if (coalesceNodes) {
        tree.root.visitTreeDepthFirst(function(n:NodeSprite):Boolean {
            if (n.parentNode != null && n.data.label != 'START' && n.data.label != 'END') {
              var p:NodeSprite = n.parentNode;

              if (p != null && p.childDegree == 1) {
                if (reverse) {p.name = n.name + ' ' + p.name;}
                else {p.name = p.name + ' ' + n.name;}
                tree.remove(n);
                return false;
              }
            }
            return false;
          });
      }

      return tree;
    }



  }
}
