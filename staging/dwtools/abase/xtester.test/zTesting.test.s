( function _zTesting_test_s_( ) {

'use strict';

/*

node builder/include/dwtools/abase/xtester/zTesting.test.s verbosity:6 importanceOfNegative:2 importanceOfDetails:0
node builder/include/dwtools/abase/xtester/zTesting.test.s verbosity:6 importanceOfNegative:2 importanceOfDetails:0

node builder/include/dwtools/abase/z.test/Path.path.test.s verbosity:4 importanceOfNegative:2 importanceOfDetails:0

node builder/Test builder/include/dwtools/abase/oclass/printer
node builder/Test builder/include/dwtools/abase/z.test

builder/include/dwtools/abase/oclass/printer/z.test/Chaining.test.s
builder/include/dwtools/abase/oclass/printer/z.test/Backend.test.ss
builder/include/dwtools/abase/oclass/printer/z.test/Logger.test.s
builder/include/dwtools/abase/oclass/printer/z.test/Other.test.s
builder/include/dwtools/abase/oclass/printer/z.test/Browser.test.s
builder/include/dwtools/abase/xtester/zTesting.test.s
builder/include/dwtools/abase/z.test/ArraySorted.test.s
builder/include/dwtools/abase/z.test/Consequence.test.s
builder/include/dwtools/abase/z.test/EventHandler.test.s
builder/include/dwtools/abase/z.test/String.test.s
builder/include/dwtools/abase/z.test/RegExp.test.s
builder/include/dwtools/abase/z.test/Map.test.s
builder/include/dwtools/abase/z.test/Changes.test.s
builder/include/dwtools/abase/z.test/ExecTools.test.s
builder/include/dwtools/abase/z.test/Path.path.test.s
builder/include/dwtools/abase/z.test/Path.url.test.s
builder/include/dwtools/abase/z.test/ProtoLike.test.s
builder/include/dwtools/abase/z.test/Sample.test.s

-

node builder/include/dwtools/abase/z.test/Path.path.test.s
node builder/include/dwtools/abase/z.test/Path.path.test.s verbosity:4
node builder/include/dwtools/abase/z.test/Path.path.test.s verbosity:4 importanceOfNegative:3
node builder/include/dwtools/abase/z.test/Path.path.test.s verbosity:3 importanceOfNegative:3

-

node builder/include/dwtools/abase/xtester/zTesting.test.s
node builder/include/dwtools/abase/xtester/zTesting.test.s importanceOfDetails:-8
node builder/include/dwtools/abase/xtester/zTesting.test.s importanceOfDetails:-8 verbosity:4
node builder/include/dwtools/abase/xtester/zTesting.test.s importanceOfDetails:-8 verbosity:4 importanceOfNegative:3
node builder/include/dwtools/abase/xtester/zTesting.test.s importanceOfDetails:-8 verbosity:3 importanceOfNegative:3

node builder/Test builder/include/dwtools/abase/xtester/zTesting.test.s
node builder/Test builder/include/dwtools/abase/z.test/Path.path.test.s
node builder/Test builder/include/dwtools/abase/z.test
node builder/Test builder/include/dwtools/abase/z.test verbosity:2

echo $?

*/

if( typeof module !== 'undefined' )
{

  if( typeof wTools === 'undefined' || !wTools.Tester._isFullImplementation )
  require( './cTester.debug.s' );

  var _ = wTools;

}

var _ = wTools;
var notTakingIntoAccount = { logger : wLogger({ output : null }), concurrent : 1, takingIntoAccount : 0 };

//

function CheckCounter()
{
  var self = this;

  self.testRoutine = null;
  self.prevCheckIndex = 1;
  self.prevCheckPasses = 0;
  self.prevCheckFails = 0;
  self.acheck = null;

  self.next = function next()
  {
    self.acheck = self.testRoutine.checkCurrent();
    self.prevCheckIndex = self.acheck._checkIndex;
    self.prevCheckPasses = self.testRoutine.report.testCheckPasses;
    self.prevCheckFails = self.testRoutine.report.testCheckFails;
  }

  Object.preventExtensions( self );

  return self;
}

//

function simplest( test )
{

  test.identical( 0,0 );

  test.identical( test.suite.report.testCheckPasses, 1 );
  test.identical( test.suite.report.testCheckFails, 0 );

}

//

function identical( test )
{
  var testRoutine;

  test.identical( 0,0 );
  // test.identical( 0,1 );

  function r1( t )
  {

    testRoutine = t;

    // console.log( 'testRoutine',testRoutine );
    console.log( 'x' );

    t.identical( 0,0 );
    test.identical( t.suite.report.testCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails, 0 );

    t.identical( 0,false );
    test.identical( t.suite.report.testCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails, 1 );

    t.identical( 0,1 );
    test.identical( t.suite.report.testCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails, 2 );

  }

  var suite = wTestSuite({ tests : { r1 : r1 }, override : notTakingIntoAccount });

  var result = suite.run()
  .doThen( function( err,data )
  {

    var acheck = testRoutine.checkCurrent();
    test.identical( acheck._checkIndex, 5 );
    test.identical( suite.report.testCheckPasses, 2 );
    test.identical( suite.report.testCheckFails, 2 );

    if( err )
    throw err;
  });

  test.identical( undefined,undefined );
  test.equivalent( undefined,undefined );

  return result;
}

// --
// should
// --

function shouldMessageOnlyOnce( test )
{

  var counter = new CheckCounter();

  function r1( t )
  {

    counter.testRoutine = t;
    t.description = 'a';

    t.identical( 0,0 );
    test.description = 'does not throw error';
    debugger;
    var c1 = t.shouldMessageOnlyOnce( function()
    {
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 2 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c1.messagesGet().length, 1 );
      c1.got( function( err,arg )
      {
        debugger;
        test.shouldBe( err === null );
        test.shouldBe( arg === undefined );
      });
    });

    /* */

    t.identical( 0,0 );
    test.description = 'does not throw error, string sync message';
    var c2 = t.shouldMessageOnlyOnce( function()
    {
      return 'msg'
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 2 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c2.messagesGet().length, 1 );
      c2.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( arg === 'msg' );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'throw unexpected error, synchronously';
    var c3 = t.shouldMessageOnlyOnce( function()
    {
      throw _.errAttend( 'error1' );
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 2 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c3.messagesGet().length, 1 );
      c3.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( _.errIs( arg ) );
        test.shouldBe( _.strHas( arg.message,'error1' ) );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'throw unexpected error, asynchronously';
    debugger;
    var c4 = t.shouldMessageOnlyOnce( function()
    {
      return _.timeOut( 250,function()
      {
        throw _.errAttend( 'error1' );
      });
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      debugger;
      test.identical( c4.messagesGet().length, 1 );
      c4.got( function( err,arg )
      {
        debugger;
        test.shouldBe( err === null );
        test.shouldBe( _.errIs( arg ) );
        test.shouldBe( _.strHas( arg.message,'error1' ) );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'single async message, no error';
    var c5 = t.shouldMessageOnlyOnce( function()
    {
      return _.timeOut( 250 );
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c5.messagesGet().length, 1 );
      c5.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( arg === _.timeOut );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'not expected second message';
    var c6 = t.shouldMessageOnlyOnce( function()
    {
      var con = wConsequence();

      _.timeOut( 250, function()
      {
        con.give( 'msg1' );
        con.give( 'msg2' );
      });

      return con;
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c6.messagesGet().length, 1 );
      c6.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( _.strHas( err.message,'got more than one message' ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'not expected second error';
    var c7 = t.shouldMessageOnlyOnce( function()
    {
      var con = wConsequence();

      _.timeOut( 250, function()
      {
        con.error( 'error1' );
        con.error( 'error2' );
      });

      return con;
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c7.messagesGet().length, 1 );
      c7.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( _.strHas( err.message,'got more than one message' ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'consequence with argument';
    var c8 = t.shouldMessageOnlyOnce( wConsequence().give( 'arg' ) );

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c8.messagesGet().length, 1 );
      c8.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( arg === 'arg' );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'consequence with error';
    var c9 = t.shouldMessageOnlyOnce( wConsequence().error( 'error' ) );

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c9.messagesGet().length, 1 );
      c9.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( arg === 'error' );
      });
    });

    /* */

    return _.timeOut( 950 );
  }

  /* */

  var suite = wTestSuite({ tests : { r1 : r1 }, override : notTakingIntoAccount });
  var result = suite.run()
  .doThen( function( err,data )
  {

    counter.acheck = counter.testRoutine.checkCurrent();

    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex, 20 );
    test.identical( suite.report.testCheckPasses, 17 );
    test.identical( suite.report.testCheckFails, 2 );
    test.identical( counter.acheck._checkIndex,suite.report.testCheckPasses+suite.report.testCheckFails+1 );

    if( err )
    throw err;
  });

  return result;
}

shouldMessageOnlyOnce.timeOut = 30000;

//

function mustNotThrowError( test )
{

  var counter = new CheckCounter();

  function r1( t )
  {

    counter.testRoutine = t;
    t.description = 'a';

    t.identical( 0,0 );
    test.description = 'does not throw error';
    debugger;
    var c1 = t.mustNotThrowError( function()
    {
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 2 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c1.messagesGet().length, 1 );
      c1.got( function( err,arg )
      {
        debugger;
        test.shouldBe( err === null );
        test.shouldBe( arg === undefined );
      });
    });

    /* */

    t.identical( 0,0 );
    test.description = 'does not throw error, string sync message';
    var c2 = t.mustNotThrowError( function()
    {
      return 'msg'
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 2 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c2.messagesGet().length, 1 );
      c2.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( arg === 'msg' );
      });
    });

    /* */

    t.identical( 0,0 );

    debugger;
    test.description = 'throw unexpected error, synchronously';
    var c3 = t.mustNotThrowError( function()
    {
      debugger;
      throw _.err( 'test' );
    });
    debugger;

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c3.messagesGet().length, 1 );
      c3.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'throw unexpected error, asynchronously';
    var c4 = t.mustNotThrowError( function()
    {
      return _.timeOut( 250,function()
      {
        throw _.err( 'test' );
      });
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c4.messagesGet().length, 1 );
      c4.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'single async message, no error';
    var c5 = t.mustNotThrowError( function()
    {
      return _.timeOut( 250 );
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c5.messagesGet().length, 1 );
      c5.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( arg === _.timeOut );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'not expected second message';
    var c6 = t.mustNotThrowError( function()
    {
      var con = wConsequence();

      _.timeOut( 250, function()
      {
        con.give( 'msg1' );
        con.give( 'msg2' );
      });

      return con;
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c6.messagesGet().length, 1 );
      c6.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( _.strHas( err.message,'got more than one message' ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'not expected second error';
    var c7 = t.mustNotThrowError( function()
    {
      var con = wConsequence();

      _.timeOut( 250, function()
      {
        con.error( 'error1' );
        con.error( 'error2' );
      });

      return con;
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c7.messagesGet().length, 1 );
      c7.got( function( err,arg )
      {
        test.shouldBe( err === 'error1' );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'consequence with argument';
    var c8 = t.mustNotThrowError( wConsequence().give( 'arg' ) );

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c8.messagesGet().length, 1 );
      c8.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( arg === 'arg' );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'consequence with error';
    var c9 = t.mustNotThrowError( wConsequence().error( 'error' ) );

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c9.messagesGet().length, 1 );
      c9.got( function( err,arg )
      {
        test.shouldBe( err === 'error' );
        test.shouldBe( !arg );
      });
    });

    /* */

    return _.timeOut( 950 );
  }

  /* */

  var suite = wTestSuite({ tests : { r1 : r1 }, override : notTakingIntoAccount });
  var result = suite.run()
  .doThen( function( err,data )
  {

    counter.acheck = counter.testRoutine.checkCurrent();

    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex, 20 );
    test.identical( suite.report.testCheckPasses, 14 );
    test.identical( suite.report.testCheckFails, 5 );
    test.identical( counter.acheck._checkIndex,suite.report.testCheckPasses+suite.report.testCheckFails+1 );

    if( err )
    throw err;
  });

  return result;
}

mustNotThrowError.timeOut = 30000;

//

function shouldThrowErrorSync( test )
{

  var counter = new CheckCounter();

  function r1( t )
  {

    counter.testRoutine = t;
    t.description = 'a';

    t.identical( 0,0 );
    test.description = 'simplest, does not throw error, but expected';
    var c1 = t.shouldThrowErrorSync( function()
    {
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c1.messagesGet().length, 1 );
      c1.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'expected synchronous error';
    debugger;
    var c2 = t.shouldThrowErrorSync( function()
    {
      throw _.err( 'test' );
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 2 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      debugger;
      test.identical( c2.messagesGet().length, 1 );
      c2.got( function( err,arg )
      {
        debugger;
        test.shouldBe( err === null );
        test.shouldBe( _.errIs( arg ) );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'throw unexpected asynchronous error';
    var c3 = t.shouldThrowErrorSync( function()
    {
      return _.timeOut( 250,function()
      {
        throw _.err( 'test' );
      });
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c3.messagesGet().length, 1 );
      c3.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'single message, while synchronous error expected';
    debugger;
    var c4 = t.shouldThrowErrorSync( function()
    {
      return _.timeOut( 250 );
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c4.messagesGet().length, 1 );
      c4.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'not expected second message';
    var c5 = t.shouldThrowErrorSync( function()
    {
      var con = wConsequence();

      _.timeOut( 250, function()
      {
        con.give();
        con.give();
      });

      return con;
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c5.messagesGet().length, 1 );
      c5.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'not expected second error';
    var c6 = t.shouldThrowErrorSync( function()
    {
      var con = wConsequence().error( 'error' );

      _.timeOut( 250, function()
      {
        con.error( 'error' );
      });

      return con;
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c6.messagesGet().length, 1 );
      c6.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'consequence with argument';
    var c7 = t.shouldThrowErrorSync( wConsequence().give( 'arg' ) );

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c7.messagesGet().length, 1 );
      c7.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'consequence with error';
    var c8 = t.shouldThrowErrorSync( wConsequence().error( 'error' ) );

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c8.messagesGet().length, 1 );
      c8.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    return _.timeOut( 950 );
  }

  var suite = wTestSuite({ tests : { r1 : r1 }, override : notTakingIntoAccount });

  var result = suite.run()
  .doThen( function( err,data )
  {

    counter.acheck = counter.testRoutine.checkCurrent();

    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex, 18 );
    test.identical( suite.report.testCheckPasses, 10 );
    test.identical( suite.report.testCheckFails, 7 );
    test.identical( counter.acheck._checkIndex,suite.report.testCheckPasses+suite.report.testCheckFails+1 );

    if( err )
    throw err;
  });

  return result;
}

//

function shouldThrowErrorAsync( test )
{

  var counter = new CheckCounter();

  test.shouldBe( test.logger.outputs.length > 0 );

  function r1( t )
  {

    counter.testRoutine = t;
    t.description = 'a';

    t.identical( 0,0 );
    test.description = 'simplest, does not throw error, but expected';
    debugger;
    var c1 = t.shouldThrowErrorAsync( function()
    {
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c1.messagesGet().length,1 );
      c1.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'throw unexpected synchronous error';
    debugger;
    var c2 = t.shouldThrowErrorAsync( function()
    {
      throw _.err( 'test' );
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c2.messagesGet().length, 1 );
      c2.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'throw expected asynchronous error';
    var c3 = t.shouldThrowErrorAsync( function()
    {
      return _.timeOut( 250,function()
      {
        throw _.err( 'test' );
      });
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c3.messagesGet().length, 1 );
      c3.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( _.errIs( arg ) );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'single message while asynchronous error expected';
    var c4 = t.shouldThrowErrorAsync( function()
    {
      return _.timeOut( 250 );
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 ); /* delayed */
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c4.messagesGet().length, 1 );
      c4.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'expected async string error';
    var c5 = t.shouldThrowErrorAsync( function()
    {
      var con = wConsequence();

      _.timeOut( 250, function()
      {
        con.error( 'error' );
      });

      return con;
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c5.messagesGet().length, 1 );
      c5.got( function( err,arg )
      {
        debugger;
        test.shouldBe( err === null );
        test.shouldBe( arg === 'error' );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'not expected second message';
    var c6 = t.shouldThrowErrorAsync( function()
    {
      var con = wConsequence();

      _.timeOut( 250, function()
      {
        con.give();
        con.give();
      });

      return con;
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 ); /* delayed */
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c6.messagesGet().length, 1 );
      c6.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'not expected second error';
    var c7 = t.shouldThrowErrorAsync( function()
    {
      var con = wConsequence();

      _.timeOut( 250, function()
      {
        con.error( 'error' );
        con.error( 'error' );
      });

      return con;
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 ); /* delayed */
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c7.messagesGet().length, 1 );
      c7.got( function( err,arg )
      {
        debugger;
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( _.strHas( err.message,'got more than one message' ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'consequence with argument';
    var c8 = t.shouldThrowErrorAsync( wConsequence().give( 'arg' ) );

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c8.messagesGet().length, 1 );
      c8.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'consequence with error';
    var c9 = t.shouldThrowErrorAsync( wConsequence().error( 'error' ) );

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c9.messagesGet().length, 1 );
      c9.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( arg === 'error' );
      });
    });

    /* */

    return _.timeOut( 950 );
  }

  /* */

  var suite = wTestSuite({ tests : { r1 : r1 }, override : notTakingIntoAccount });
  var result = suite.run()
  .doThen( function( err,data )
  {

    counter.acheck = counter.testRoutine.checkCurrent();

    test.shouldBe( test.logger.outputs.length > 0 );
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex, 20 );
    test.identical( suite.report.testCheckPasses, 13 );
    test.identical( suite.report.testCheckFails, 6 );
    test.identical( counter.acheck._checkIndex,suite.report.testCheckPasses+suite.report.testCheckFails+1 );

    if( err )
    throw err;

  });

  return result;
}

//

function shouldThrowError( test )
{

  var counter = new CheckCounter();

  function r1( t )
  {

    counter.testRoutine = t;
    t.description = 'a';

    t.identical( 0,0 );
    test.description = 'does not throw error, but expected';
    var c1 = t.shouldThrowError( function()
    {
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c1.messagesGet().length, 1 );
      c1.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'throw expected synchronous error';
    var c2 = t.shouldThrowError( function()
    {
      throw _.err( 'err1' );
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 2 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c2.messagesGet().length, 1 );
      c2.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( _.errIs( arg ) );
        test.shouldBe( _.strHas( arg.messge,'err1' ) );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'throw expected asynchronous error';
    var c3 = t.shouldThrowError( function()
    {
      return _.timeOut( 250,function()
      {
        throw _.err( 'err1' );
      });
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c3.messagesGet().length, 1 );
      c3.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( _.errIs( arg ) );
        test.shouldBe( _.strHas( arg.messge,'err1' ) );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'single message, but error expected';
    debugger;
    var c4 = t.shouldThrowError( function()
    {
      return _.timeOut( 250 );
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c4.messagesGet().length, 1 );
      c4.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'not expected second message';
    var c5 = t.shouldThrowError( function()
    {
      var con = wConsequence();

      _.timeOut( 250, function()
      {
        con.give( 'arg1' );
        con.give( 'arg2' );
      });

      return con;
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 ); /* delayed */
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c5.messagesGet().length, 1 );
      c5.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'not expected second error';
    var c6 = t.shouldThrowError( function()
    {
      var con = wConsequence();

      _.timeOut( 250, function()
      {
        con.error( 'error1' );
        con.error( 'error1' );
      });

      return con;
    });

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 ); /* delayed */
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c6.messagesGet().length, 1 );
      c6.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( _.strHas( err.message,'got more than one message' ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'consequence with argument';
    var c8 = t.shouldThrowError( wConsequence().give( 'arg' ) );

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 1 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c8.messagesGet().length, 1 );
      c8.got( function( err,arg )
      {
        test.shouldBe( _.errIs( err ) );
        test.shouldBe( !arg );
      });
    });

    /* */

    t.identical( 0,0 );

    test.description = 'consequence with error';
    var c9 = t.shouldThrowError( wConsequence().error( 'error' ) );

    counter.acheck = t.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex-counter.prevCheckIndex, 2 );
    test.identical( t.suite.report.testCheckPasses-counter.prevCheckPasses, 1 );
    test.identical( t.suite.report.testCheckFails-counter.prevCheckFails, 0 );
    counter.next();

    _.timeOut( 500,function()
    {
      test.identical( c9.messagesGet().length, 1 );
      c9.got( function( err,arg )
      {
        test.shouldBe( err === null );
        test.shouldBe( arg === 'error' );
      });
    });

    /* */

    return _.timeOut( 950 );
  }

  var suite = wTestSuite({ tests : { r1 : r1 }, override : notTakingIntoAccount });

  var result = suite.run()
  .doThen( function( err,data )
  {

    counter.acheck = counter.testRoutine.checkCurrent();
    test.identical( counter.acheck.description, 'a' );
    test.identical( counter.acheck._checkIndex, 18 );
    test.identical( suite.report.testCheckPasses, 12 );
    test.identical( suite.report.testCheckFails, 5 );
    test.identical( counter.acheck._checkIndex,suite.report.testCheckPasses+suite.report.testCheckFails+1 );

    if( err )
    throw err;
  });

  return result;
}

//

function shouldPassMessage( test )
{
  var counter = new CheckCounter();

  test.description = 'mustNotThrowError must return con with message';

  var con = new wConsequence().give( '123' );
  test.mustNotThrowError( con )
  .ifNoErrorThen( function( arg )
  {
    test.identical( arg, '123' );
  });

  var con = new wConsequence().give( '123' );
  test.shouldMessageOnlyOnce( con )
  .ifNoErrorThen( function( arg )
  {
    test.identical( arg, '123' );
  });

  test.description = 'mustNotThrowError must return con original error';

  var errOriginal = _.err( 'Err' );
  var con = new wConsequence().error( errOriginal );
  test.shouldThrowError( con )
  .doThen( function( err,arg )
  {
    test.identical( err,null );
    test.identical( arg,errOriginal );
    _.errAttend( err );
  });

  return _.timeOut( 500 );
}

shouldPassMessage.timeOut = 15000;

//

function _throwingExperiment( test )
{
  var t = test;

  return;

  /* */

  debugger;
  t.mustNotThrowError( function()
  {
    var con = wConsequence().give();

    _.timeOut( 250, function()
    {
      con.give();
      con.give();
    });

    return con;
  });

  /* */

  debugger;
  t.shouldThrowError( function()
  {
    var con = wConsequence().give();

    _.timeOut( 2000, function()
    {
      con.give();
      con.give();
    });

    return con;
  });

  /* */

  debugger;
  t.shouldThrowError( function()
  {
    return _.timeOut( 250 );
  });

  /* */

  t.description = 'a';

  t.identical( 0,0 );
  t.shouldThrowErrorAsync( function()
  {
  });

  t.identical( 0,0 );

  t.shouldThrowErrorAsync( function()
  {
    throw _.err( 'test' );
  });

  t.identical( 0,0 );

  t.shouldThrowErrorAsync( function()
  {
    return _.timeOut( 250,function()
    {
      throw _.err( 'test' );
    });
  });

  t.identical( 0,0 );

  t.shouldThrowErrorAsync( function()
  {
    return _.timeOut( 250 );
  });

  t.identical( 0,0 );

  t.shouldThrowErrorAsync( function()
  {
    var con = wConsequence().give();

    _.timeOut( 250, function()
    {
      con.give();
      con.give();
    });

    return con;
  });

  t.identical( 0,0 );

  _.timeOut( 2000, function()
  {

    counter.acheck = t.checkCurrent();
    console.log( 'checkIndex',acheck._checkIndex, 13 );
    console.log( 'testCheckPasses',test.suite.report.testCheckPasses, 8 );
    console.log( 'testCheckFails',test.suite.report.testCheckFails, 4 );

  });

  /* */

  test.description = 'simplest, does not throw error,  but expected';
  debugger;
  test.shouldThrowErrorAsync( function()
  {
  });

  /* */

  test.description = 'single message';
  test.mustNotThrowError( function()
  {
    return _.timeOut( 250 );
  });

  /* */

  test.shouldThrowErrorSync( function()
  {
    var con = wConsequence().give();

    _.timeOut( 250, function()
    {
      con.give();
      con.give();
    });

    return con;
  });

  /* */

  debugger;
  test.shouldThrowErrorSync( function()
  {
    return _.timeOut( 250 );
  });
  debugger;

  /* */

  debugger;
  test.mustNotThrowError( function()
  {
  });

  test.identical( 0,0 );

  debugger;
  test.mustNotThrowError( function()
  {
    throw _.err( 'test' );
  });

  test.identical( 0,0 );

  /* */

  test.description = 'if passes dont appears in output/passed test checks/total counter';
  test.mustNotThrowError( function()
  {
  });

  test.identical( 0,0 );

  test.description = 'if not passes then appears in output/total counter';
  test.mustNotThrowError( function()
  {
    return _.timeOut( 1000,function()
    {
      throw _.err( 'test' );
    });
    // throw _.err( 'test' );
  });

  test.identical( 0,0 );

  test.description = 'not expected second message';
  test.mustNotThrowError( function()
  {
    var con = wConsequence().give();

    _.timeOut( 1000, function()
    {
      con.give();
      con.give();
    });

    return con;
  });

}

_throwingExperiment.experimental = 1;

// --
// special
// --

function shouldThrowErrorSimpleSync( test )
{

  test.identical( test._inroutineCon.messagesGet().length,1 );

  var consequence = new wConsequence().give();
  consequence
  .ifNoErrorThen( function()
  {
    return test.shouldThrowErrorSync( function()
    {
      throw _.err( 'shouldThrowErrorSync a' );
    });
  })
  .ifNoErrorThen( function()
  {
    return test.shouldThrowErrorSync( function()
    {
      throw _.err( 'shouldThrowErrorSync b' );
    });
  });

  return consequence;
}

//

function shouldThrowErrorSimpleAsync( test )
{
  var consequence = new wConsequence().give();
  var counter = new CheckCounter();

  counter.testRoutine = test;
  counter.next();

  test.identical( test._inroutineCon.messagesGet().length,1 );

  // debugger;

  consequence
  .doThen( function()
  {
    test.description = 'a';
    var con = _.timeOut( 50,function( err )
    {
      debugger;
      throw _.err( 'async error' );
    });
    debugger;
    return test.shouldThrowErrorAsync( con );
  })
  .doThen( function()
  {
    test.description = 'b';
    var con = _.timeOut( 50,function( err )
    {
      debugger;
      throw _.err( 'async error' );
    });
    debugger;
    return test.shouldThrowErrorAsync( con );
  })
  .doThen( function()
  {
    debugger;

    var acheck = test.checkCurrent();

    test.identical( test.report.testCheckPasses-counter.prevCheckPasses, 3 );
    test.identical( test.report.testCheckFails-counter.prevCheckFails, 0 );

    test.identical( acheck.description, 'b' );
    test.identical( acheck._checkIndex, 4 );

    test.identical( test._inroutineCon.messagesGet().length,0 );

  })
  ;

  return consequence;
}

//

function _chainedShould( test,o )
{

  var method = o.method;
  var counter = new CheckCounter();

  /* */

  function row( t )
  {
    var prefix = method + ' . ' + 'in row' + ' . ';

    counter.testRoutine = t;

    counter.acheck = counter.testRoutine.checkCurrent();
    test.identical( counter.acheck._checkIndex, 1 );
    test.identical( suite.report.testCheckPasses, 0 );
    test.identical( suite.report.testCheckFails, 0 );

    return new wConsequence().give()
    .doThen( function()
    {

      test.description = prefix + 'beginning of the test routine';
      counter.acheck = counter.testRoutine.checkCurrent();
      test.identical( counter.acheck._checkIndex, 1 );
      test.identical( t.suite.report.testCheckPasses, 0 );
      test.identical( t.suite.report.testCheckFails, 0 );

      var con = _.timeOut( 50,function( err )
      {
        test.description = prefix + 'give the first message';
        test.shouldBe( 1 );
        if( o.throwingError === 'async' )
        throw _.err( 'async error' );
        else if( o.throwingError === 'sync' )
        t[ method ]( function(){ throw _.err( 'sync error' ) } );
      });

      if( o.throwingError === 'sync' )
      return con;
      else
      return t[ method ]( con );
    })
    .doThen( function()
    {

      test.description = prefix + 'first ' + method + ' done';
      counter.acheck = counter.testRoutine.checkCurrent();
      test.identical( counter.acheck._checkIndex, 2 );
      test.identical( t.suite.report.testCheckPasses, 1 );
      test.identical( t.suite.report.testCheckFails, 0 );

      var con = _.timeOut( 50,function( err )
      {
        test.description = prefix + 'give the second message';
        test.shouldBe( 1 );
        if( o.throwingError === 'async' )
        throw _.err( 'async error' );
        else if( o.throwingError === 'sync' )
        t[ method ]( function(){ throw _.err( 'sync error' ) } );
      });

      if( o.throwingError === 'sync' )
      return con;
      else
      return t[ method ]( con );
    })
    .doThen( function()
    {

      test.description = prefix + 'second ' + method + ' done';
      counter.acheck = counter.testRoutine.checkCurrent();
      test.identical( counter.acheck._checkIndex, 3 );
      test.identical( t.suite.report.testCheckPasses, 2 );
      test.identical( t.suite.report.testCheckFails, 0 );

    });

  };

  /* */

  function include( t )
  {

    var prefix = method + ' . ' + 'include' + ' . ';
    counter.testRoutine = t;

    function second()
    {
      return _.timeOut( 50,function()
      {

        test.description = prefix + 'first ' + method + ' done';

        test.identical( t.suite.report.testCheckPasses, o.lowerCount ? 4 : 5 );
        test.identical( t.suite.report.testCheckFails, 0 );

        if( o.throwingError === 'sync' )
        t[ method ]( function(){ throw _.err( 'sync error' ) } );

        counter.acheck = counter.testRoutine.checkCurrent();
        test.identical( counter.acheck._checkIndex, o.lowerCount ? 3 : 4 );

        if( o.throwingError === 'async' )
        t[ method ]( _.timeOutError( 50 ) );
        else if( !o.throwingError )
        t[ method ]( _.timeOut( 50 ) );
        else
        t.identical( 1,1 );

        if( o.throwingError === 'async' )
        throw _.err( 'async error' );
      });
    }

    function first()
    {

      var result = _.timeOut( 50,function()
      {

        test.description = prefix + 'first timeout of the included test routine ';

        test.identical( t.suite.report.testCheckPasses, 3 );
        test.identical( t.suite.report.testCheckFails, 0 );

        if( o.throwingError === 'sync' )
        t[ method ]( function(){ throw _.err( 'sync error' ); } );

        counter.acheck = counter.testRoutine.checkCurrent();
        test.identical( counter.acheck._checkIndex, 2 );

        if( o.throwingError === 'sync' )
        {
          // t.identical( 1,1 );
          return second();
        }
        else
        t[ method ]( second );

        if( o.throwingError === 'async' )
        throw _.err( 'async error' );
      });

      return result;
    }

    test.description = prefix + 'beginning of the included test routine ';

    if( o.throwingError === 'sync' )
    return first();
    else
    return t[ method ]( first );
  };

  /* */

  var suite = wTestSuite
  ({
    tests : { row : row, include : include },
    override : notTakingIntoAccount,
    name : _.diagnosticLocation().name + '.' + method + '.' + o.throwingError,
  });

  if( suite.on )
  suite.on( 'routineEnd',function( e )
  {

    // console.log( 'routineEnd',e.testRoutine.routine.name );

    if( e.testRoutine.routine.name === 'row' )
    {
      test.description = 'checking outcomes';
      counter.acheck = counter.testRoutine.checkCurrent();
      test.identical( counter.acheck._checkIndex, 4 );
      test.identical( suite.report.testCheckPasses, 3 );
      test.identical( suite.report.testCheckFails, 0 );
    }

  });

  /* */

  return suite.run()
  .doThen( function( err,data )
  {

    test.description = 'checking outcomes';

    counter.acheck = counter.testRoutine.checkCurrent();
    test.identical( counter.acheck._checkIndex, 5 ); /* 4 */
    test.identical( suite.report.testCheckPasses, 7 ); /* 6 */
    test.identical( suite.report.testCheckFails, 0 );

    if( err )
    throw err;
  });

}

_chainedShould.experimental = 1;

//

function chainedShould( test )
{
  var con = wConsequence().give();

  var iterations =
  [

    {
      method : 'shouldThrowError',
      throwingError : 'sync',
      lowerCount : 1,
    },
    {
      method : 'shouldThrowError',
      throwingError : 'async',
      lowerCount : 1,
    },

    {
      method : 'shouldThrowErrorSync',
      throwingError : 'sync',
      lowerCount : 1,
    },

    {
      method : 'shouldThrowErrorAsync',
      throwingError : 'async',
      lowerCount : 1,
    },

    {
      method : 'mustNotThrowError',
      throwingError : 0,
      lowerCount : 1,
    },

    {
      method : 'shouldMessageOnlyOnce',
      throwingError : 0,
      lowerCount : 1,
    },

  ]

  for( var i = 0 ; i < iterations.length ; i++ )
  con.ifNoErrorThen( _.routineSeal( this, _chainedShould, [ test,iterations[ i ] ] ) );

  return con;
}

chainedShould.timeOut = 30000;

// --
// etc
// --

function asyncExperiment( test )
{
  var con = _.timeOutError( 1000 );

  test.identical( 0,0 );

  con.doThen( function()
  {
  });

  debugger;
  return con;
}

asyncExperiment.experimental = 1;

//

function failExperiment( test )
{

  test.description = 'this test fails';

  test.identical( 0,1 );
  test.identical( 0,1 );

}

failExperiment.experimental = 1;

// --
// proto
// --

var Self =
{

  name : 'TestingOfTesting',
  // verbosity : 7,
  // routine : 'simplest',
  // debug : 1,
  silencing : 1,

  tests :
  {

    simplest : simplest,
    identical : identical,

    // should

    shouldMessageOnlyOnce : shouldMessageOnlyOnce,
    mustNotThrowError : mustNotThrowError,
    shouldThrowErrorSync : shouldThrowErrorSync,
    shouldThrowErrorAsync : shouldThrowErrorAsync,
    shouldThrowError : shouldThrowError,

    shouldPassMessage : shouldPassMessage,
    _throwingExperiment : _throwingExperiment,

    shouldThrowErrorSimpleSync : shouldThrowErrorSimpleSync,
    shouldThrowErrorSimpleAsync : shouldThrowErrorSimpleAsync,

    _chainedShould : _chainedShould,
    chainedShould : chainedShould,

    // etc

    asyncExperiment : asyncExperiment,
    failExperiment : failExperiment,

  },

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

})();