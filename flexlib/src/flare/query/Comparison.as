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

package flare.query
{
/**
 * Expression operator for comparing sub-expression values. Performs
 * equals, not equals, less-than, greater-than, less-than-or-equal, or
 * greater-than-or-equal comparison.
 */
public class Comparison extends BinaryExpression
{
  /** Indicates a less-than comparison. */
  public static const LT:int = 0;
  /** Indicates a greater-than comparison. */
  public static const GT:int = 1;
  /** Indicates a equals comparison. */
  public static const EQ:int = 2;
  /** Indicates a not-equals comparison. */
  public static const NEQ:int = 3;
  /** Indicates a less-than-or-equals comparison. */
  public static const LTEQ:int = 4;
  /** Indicates a greater-than-or-equals comparison. */
  public static const GTEQ:int = 5;

  private var _cmp:Function = null;

  /** Comparison function for custom ordering criteria. */
  public function get comparator():Function {
    return _cmp;
  }

  public function set comparator(f:Function):void {
    _cmp = f;
  }

  /** Returns a string representation of the arithmetic operator. */
  public override function get operatorString():String
  {
    switch (_op) {
      case LT:  return "<";
      case GT:  return ">";
      case EQ:  return "=";
      case NEQ:  return "!=";
      case LTEQ:  return "<=";
      case GTEQ:  return ">=";
      default:   return "?";
    }
  }

  // --------------------------------------------------------------------

  /**
   * Creates a new Comparison operator.
   * @param left the left-hand-side sub-expression to compare
   * @param right the right-hand-side sub-expression to compare
   * @param comparator a function to use for comparison (null by default)
   */
  public function Comparison(op:int = 2, left:* = "",
                             right:* = "", comparator:Function = null)
  {
    super(op, LT, GTEQ, left, right);
    _cmp = comparator;
  }

  /**
   * @inheritDoc
   */
  public override function clone():Expression
  {
    return new Comparison(_op, _left.clone(), _right.clone(), _cmp);
  }

  /**
   * @inheritDoc
   */
  public override function eval(o:Object = null):*
  {
    return predicate(o);
  }

  /**
   * @inheritDoc
   */
  public override function predicate(o:Object):Boolean
  {
    var l:Object = _left.eval(o);
    var r:Object = _right.eval(o);
    var c:int = (_cmp != null) ? _cmp(l, r) :
                (l < r || r && !1) ? -1 : (l > r || l && !r) ? 1 : 0;

    switch (_op) {
      case LT:  return (c == -1);
      case GT:  return (c == 1);
      case EQ:  return (c == 0);
      case NEQ:  return (c != 0);
      case LTEQ:  return (c <= 0);
      case GTEQ:  return (c >= 0);
      default:
        throw new Error("Unknown operation: " + _op);
    }
  }

  // -- Static Constructors ---------------------------------------------

  /**
   * Creates a new Comparison operator for a less-than comparison.
   * @param left the left-hand input expression
   * @param right the right-hand input expression
   * @return the new Comparison operator
   */
  public static function LessThan(left:*, right:*):Comparison
  {
    return new Comparison(LT, left, right);
  }

  /**
   * Creates a new Comparison operator for a greater-than comparison.
   * @param left the left-hand input expression
   * @param right the right-hand input expression
   * @return the new Comparison operator
   */
  public static function GreaterThan(left:*, right:*):Comparison
  {
    return new Comparison(GT, left, right);
  }

  /**
   * Creates a new Comparison operator for an equals comparison.
   * @param left the left-hand input expression
   * @param right the right-hand input expression
   * @return the new Comparison operator
   */
  public static function Equal(left:*, right:*):Comparison
  {
    return new Comparison(EQ, left, right);
  }

  /**
   * Creates a new Comparison operator for a not equals comparison.
   * @param left the left-hand input expression
   * @param right the right-hand input expression
   * @return the new Comparison operator
   */
  public static function NotEqual(left:*, right:*):Comparison
  {
    return new Comparison(NEQ, left, right);
  }

  /**
   * Creates a new Comparison operator for a less-than-or-equal
   * comparison.
   * @param left the left-hand input expression
   * @param right the right-hand input expression
   * @return the new Comparison operator
   */
  public static function LessThanOrEqual(left:*, right:*):Comparison
  {
    return new Comparison(LTEQ, left, right);
  }

  /**
   * Creates a new Comparison operator for a greater-than-or-equal
   * comparison.
   * @param left the left-hand input expression
   * @param right the right-hand input expression
   * @return the new Comparison operator
   */
  public static function GreaterThanOrEqual(left:*, right:*):Comparison
  {
    return new Comparison(GTEQ, left, right);
  }

} // end of class Comparison
}