(function _Suite_s_() {

'use strict';

let _global = _global_;
let _ = _global_.wTools;
let debugged = _.process.isDebugged();
// debugged = 0;

//

/**
 * @classdesc Class to define test suite.
 * Test suite is a set of test routines and test data that are used for complete testing of individual parts of the task.
 * @class wTestSuite
 * @param {Object} o Test suite option map. {@link module:Tools/atop/Tester.wTestSuite.TestSuiteFields More about options}
 * @module Tools/atop/Tester
 */

let logger = null;
let Parent = null;
let Self = function wTestSuite( o )
{

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!o );

  let location;

  if( !o.suiteFilePath )
  {
    location = location || _.introspector.location( 1 );
    o.suiteFilePath = location.filePath;
  }

  if( !o.suiteFileLocation )
  {
    location = location || _.introspector.location( 1 );
    o.suiteFileLocation = location.filePathLineCol;
  }

  if( !( this instanceof Self ) )
  if( _.strIs( o ) )
  return Self.instanceByName( o );

  if( !( this instanceof Self ) )
  return new( _.constructorJoin( Self, arguments ) );

  _.assert( !( o instanceof Self ) );

  return Self.prototype.init.apply( this, arguments );
}

Self.shortName = 'TestSuite';

// --
// inter
// --

function init( o )
{
  let suite = this;

  _.workpiece.initFields( suite );

  suite.accuracyExplicitly = null;

  Object.preventExtensions( suite );

  if( _.routineIs( o.inherit ) )
  delete o.inherit;
  let inherits = o.inherit;
  delete o.inherit;

  if( o && o.tests !== undefined )
  suite.tests = o.tests;

  if( o )
  suite.copy( o );

  suite._initialOptions = o;

  _.assert( o === undefined || _.objectIs( o ), 'Expects object {-options-}, but got', _.strType( o ) );

  /* source path */

  if( !_.strIs( suite.suiteFileLocation ) )
  {
    debugger;
    throw _.err( 'Test suite', suite.name, 'Expects a mandatory option ( suiteFileLocation )' );
  }

  /* name */

  if( !( o instanceof Self ) )
  if( !_.strDefined( suite.name ) )
  suite.name = _.introspector.location( suite.suiteFileLocation ).fileNameLineCol;

  if( !( o instanceof Self ) )
  if( !_.strDefined( suite.name ) )
  {
    debugger;
    throw _.err( 'Test suite should have name, but', suite.name );
  }

  /* */

  if( inherits )
  {
    _.assert( _.arrayLike( inherits ) );
    if( inherits.length !== 1 )
    debugger;
    for( let i = 0 ; i < inherits.length ; i++ )
    {
      let inherit = inherits[ i ];
      if( !( inherits[ i ] instanceof Self ) )
      {
        if( Self.InstancesMap[ inherit.name ] )
        {
          let inheritInited = Self.InstancesMap[ inherit.name ];
          _.assert( _.entityContains( inheritInited, _.mapBut( inherit, { inherit : inherit } ) ) );
          inherits[ i ] = inheritInited;
        }
        else
        {
          debugger;
          inherits[ i ] = Self( inherit );
        }
      }
    }
    suite.inherit.apply( suite, inherits );
  }

  /* */

  if( suite.context === null )
  suite.context = Object.create( null );
  _.assert( _.objectIs( suite.context ) );
  // Object.preventExtensions( suite.context );

  return suite;
}

//

function precopy( o )
{
  let suite = this;
  if( o && o.name )
  suite.name = o.name;
}

//

function copy( o )
{
  let suite = this;

  if( ( o instanceof Self ) )
  debugger;

  suite.precopy( o );

  return _.Copyable.prototype.copy.call( suite, o );
}

/* qqq : write external test rouine
the test routine checks that error caused by unknown field in test suite definition thows error with good explanation having name of the suite
*/

//

/**
 * @summary Inherits tests, context and options of provides test suite(s).
 * @param {...Object} arguments Accepts one or several test suites.
 * @method inherit
 * @class wTestSuite
 * @module Tools/atop/Tester
 */

function inherit()
{
  let suite = this;

  for( let a = 0 ; a < arguments.length ; a++ )
  {
    let src = arguments[ a ];

    _.assert( src instanceof Self, () => `Expects test suite to inherit it, but got ${_.strType( src )}` );

    if( src.tests )
    _.mapSupplement( suite.tests, src.tests );

    if( src.context )
    _.mapSupplement( suite.context, src.context );

    let extend = _.mapBut( src._initialOptions, suite._initialOptions );
    delete extend.abstract; /* qqq : add test to check test suite inheritance without explicitly defined in descendant `abstact : 0` works */
    _.mapExtend( suite, extend );
    _.mapExtend( suite._initialOptions, extend );

  }

  return suite;
}

//

function Froms( suites )
{

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.mapIs( suites ) );

  for( let s in suites ) try
  {
    let suite = suites[ s ];
    Self( suite );
  }
  catch( err )
  {
    throw _.errLog( 'Cant make test suite', s, '\n', err );
  }

  return this;
}

// --
// etc
// --

function _accuracySet( accuracy )
{
  let suite = this;

  if( accuracy === null )
  {
    accuracy = _.accuracy;
    suite.accuracyExplicitly = null;
  }
  else
  {
    accuracy = _.make( accuracy );
    suite.accuracyExplicitly = accuracy;
  }

  _.assert( _.numberIs( accuracy ) || _.rangeIs( accuracy ), 'Expects number {-accuracy-}' );
  suite[ accuracySymbol ] = accuracy;

  if( suite._formed )
  suite.routineEach( ( trd ) => trd._accuracyChange() );

  return accuracy;
}

//

function _routineSet( src )
{
  let suite = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( src === null || _.routineIs( src ) || _.strIs( src ) );

  if( _.routineIs( src ) )
  debugger;

  suite[ routineSymbol ] = src;

}

//

function _enabledSet( src )
{
  let suite = this;
  suite[ enabledSymbol ] = src;
  return src;
}

//

function _enabledGet( src )
{
  let suite = this;
  let result = suite[ enabledSymbol ];
  if( _.routineIs( result ) )
  return !!result();
  return !!result;
}

//

function _consoleBar( o )
{
  let suite = this;
  let logger = suite.logger;
  let wasBarred = wTester._barOptions ? wTester._barOptions.on : false;

  try
  {

    _.assert( arguments.length === 1 );
    _.assert( _.boolLike( o.value ) );

    if( o.value )
    {
      logger.begin({ verbosity : -8 });
      logger.log( 'Silencing console' );
      logger.end({ verbosity : -8 });
      if( !_.Logger.ConsoleIsBarred( console ) )
      {
        if( o.preserving )
        {
          wTester._barOptions.on = 1;
          if( !wTester._barOptions.outputPrinter )
          wTester._barOptions.outputPrinter = logger;
        }
        else
        {
          wTester._barOptions = { outputPrinter : logger, on : 1 };
        }
        wTester._barOptions = _.Logger.ConsoleBar( wTester._barOptions );
      }
    }
    else
    {
      if( _.Logger.ConsoleIsBarred( console ) )
      {
        wTester._barOptions.on = 0;
        _.Logger.ConsoleBar( wTester._barOptions );
        if( !o.preserving )
        wTester._barOptions = null;
      }
    }

  }
  catch( err )
  {
    debugger;
    if( err && err.toString )
    console.error( err.toString() + '\n' + err.stack );
    else
    console.error( err );
  }

  return wasBarred;
}

_consoleBar.defaults =
{
  preserving : 1,
  value : null,
}

//

/**
 * @descripton
 * Redirects all console output to logger of the tester. That makes other loggers connected after it unable to
 * receive messages from console, logger of the tester prints messages through original console methods. All this allows to hide/show/style
 * console output if necessary.
 * @param {Boolean} value Controls barring/unbarring of the console.
 * @method consoleBar
 * @class wTestSuite
 * @module Tools/atop/Tester
 */

function consoleBar( value )
{
  let suite = this;
  return suite._consoleBar({ preserving : 0, value });
}

//

function consoleBarPreserving( value )
{
  let suite = this;
  return suite._consoleBar({ preserving : 1, value });
}

// --
// test suite run
// --

/**
 * @summary Executes tests of current suite.
 * @description During execution tester prints useful information about current state of execution:
 * name of test case, description of test case, result of test checks with got and expected values, erors, etc.
 * Level of output can be controled by options.
 * Prints summary at the end of execution.
 * @method run
 * @class wTestSuite
 * @module Tools/atop/Tester
*/

function run()
{
  let suite = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  suite._form();
  return suite._runSoon();
}

//

function _form()
{
  let suite = this;

  if( suite._formed )
  return;

  /* verify */

  _.assert( _.objectIs( suite.tests ) );
  _.assert( suite instanceof Self );
  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( _.strDefined( suite.name ), 'Test suite should has {-name-}"' );
  _.assert( _.objectIs( suite.tests ), 'Test suite should has map with test routines {-tests-}, but "' + suite.name + '" does not have such map' );
  _.assert( !suite._formed );

  /* extend */

  let extend = Object.create( null );

  if( suite.override )
  _.mapExtend( extend, suite.override );

  if( !suite.logger )
  suite.logger = wTester.logger || _global_.logger;

  if( !suite.ignoringTesterOptions )
  {

    if( wTester.settings.verbosity !== null )
    if( extend.verbosity === undefined )
    extend.verbosity = wTester.settings.verbosity-1;

    for( let f in wTester.SettingsOfSuite )
    if( wTester.settings[ f ] !== null )
    if( extend[ f ] === undefined )
    extend[ f ] = wTester.settings[ f ];

  }

  _.mapExtend( suite, extend ); /* xxx */

  /* form test routines */

  for( let testRoutineName in suite.tests )
  {
    let testRoutine = suite.tests[ testRoutineName ];

    _.assert( _.routineIs( testRoutine ) );

    let trd = wTester.TestRoutine
    ({
      name : testRoutineName,
      routine : testRoutine,
      suite : suite,
    });

    trd.form();

    _.assert( suite.tests[ testRoutineName ] === trd )
  }

  /* validate */

  _.assert( suite.concurrent !== null && suite.concurrent !== undefined );
  _.assert( wTester.settings.sanitareTime >= 0 );
  _.assert( _.numberIs( suite.verbosity ) );

  suite._formed = 1;
  return suite;
}

//

function _runSoon()
{
  let suite = this;

  _.assert( suite instanceof Self );
  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( suite._formed );

  if( _.arrayAppendedOnce( wTester.quedSuites, suite ) === -1 )
  return null;

  let con = suite.concurrent ? new _.Consequence().take( null ) : wTester.TestSuite._SuitesReady;

  let result = con
  .finally( () => _.time.ready() )
  .finally( () => suite._runNow() )
  .split()
  ;

  if( Config.debug )
  result.tag = suite.name;

  return result;
}

//

function _runNow()
{
  let suite = this;
  let testRoutines = suite.tests;
  let logger = suite.logger || wTester.logger || _global_.logger;

  _.assert( suite instanceof Self );
  _.assert( arguments.length === 0, 'Expects no arguments' );

  /* */

  let r = _.execStages( testRoutines,
  {
    manual : 1,
    onEachRoutine : handleRoutine,
    onBegin : handleBegin,
    onEnd : handleEnd,
    onRoutine : ( trd ) => trd.routine,
    delay : 10,
  });

  return r;

  /* */

  function handleRoutine( trd, iteration, iterator )
  {
    return suite._testRoutineRun( trd );
  }

  /* */

  function handleBegin()
  {
    return suite._begin();
  }

  /* */

  function handleEnd( err, arg )
  {
    return suite._endSoon( err, arg );
  }

}

//

function _begin()
{
  let suite = this;
  let ready = new _.Consequence().take( null );

  if( wTester.settings.timing )
  suite._testSuiteBeginTime = _.time.now();

  /* test routine */

  /* qqq : cover the case, please */
  if( _.routineIs( suite.routine ) )
  debugger;
  if( _.routineIs( suite.routine ) )
  suite.routine = _.mapKeyWithValue( suite, suite.routine );

  /* report */

  suite.report = null;
  suite._reportBegin();
  suite._appExitCode = _.process.exitCode( 0 );

  /* tracking */

  _.arrayAppendOnceStrictly( wTester.activeSuites, suite );

  _.assert( _.objectIs( suite.context ) );
  Object.preventExtensions( suite.context );

  /* logger */

  let logger = suite.logger;

  /* silencing */

  if( suite.silencing )
  {
    suite.consoleBar( 1 ); /* xxx */
  }

  /* */

  logger.verbosityPush( suite.verbosity );
  logger.begin({ verbosity : -2 });

  let msg =
  [
    'Running test suite ( ' + suite.name + ' ) ..',
  ];

  logger.begin({ 'suite' : suite.name });

  logger.logUp( msg.join( '\n' ) );

  logger.log( 'Located at ' + wTester.textColor( suite.suiteFileLocation, 'path' ) );

  logger.end( 'suite' );

  logger.later( 'suite.content' ).log( '' );

  logger.end({ verbosity : -2 });

  logger.begin({ verbosity : -6 });
  logger.log( _.toStr( suite ) );
  logger.end({ verbosity : -6 });

  logger.begin({ verbosity : -6 + suite.importanceOfDetails });

  /* process watcher */

  if( suite.processWatching )
  {
    suite._processWatcherMap = Object.create( null );
    function subprocessStartEnd( o )
    {
      if( o.sync )
      return;
      _.assert( !suite._processWatcherMap[ o.process.pid ] )
      suite._processWatcherMap[ o.process.pid ] = o;
    }
    function subprocessTerminationEnd( o )
    {
      if( o.sync )
      return;
      _.assert( suite._processWatcherMap[ o.process.pid ] )
      delete suite._processWatcherMap[ o.process.pid ];
    }
    _.process.watcherEnable();
    _.process.on( 'subprocessStartEnd', subprocessStartEnd );
    _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd );
    suite._processWatcher = { subprocessStartEnd, subprocessTerminationEnd };
  }

  /* */

  if( suite.onSuiteBegin )
  {
    try
    {
/*
xxx qqq : cover returned consequence
*/
      ready.then( () => suite.onSuiteBegin.call( suite.context, suite ) || null );
    }
    catch( err )
    {
      debugger;
      err = _.err( err, `\nError in suite.onSuiteBegin of ${suite.qualifiedName}` );
      suite.exceptionReport({ err : err });
      throw err;
    }
  }

  /* */

  // if( _global_.process && suite.takingIntoAccount )
  // {
  //   suite._terminated_joined = _.routineJoin( suite, _terminated );
  //   _global_.process.on( 'exit', suite._terminated_joined );
  // }

  if( _.process && suite.takingIntoAccount )
  {
    suite._terminated_joined = _.routineJoin( suite, _terminated );
    _.process.on( 'exit', suite._terminated_joined );
  }

  ready.finally( ( err, arg ) =>
  {
    if( err )
    {
      err = _.err( err, `\nError in suite.onSuiteBegin of ${suite.qualifiedName}` );
      suite.exceptionReport({ err : err });
      throw err;
    }
    if( !wTester._canContinue() )
    {
      debugger;
      return false;
    }
    return true;
  });

  return ready;
}

//

function _endSoon( err, arg )
{
  let suite = this;
  let logger = suite.logger;

  suite._reportEnd();

  if( suite._reportIsPositive() )
  return _.time.out( wTester.settings.sanitareTime, () => suite._end( err ) );
  else
  return suite._end( err );
}

//

function _end( err )
{
  let suite = this;
  let logger = suite.logger;
  let ready;

  _.assert( arguments.length === 1 );

  /* on suite end */

  if( suite.onSuiteEnd )
  {
    let timeLimitErrorCon = _.time.outError( suite.onSuiteEndTimeOut + wTester.settings.sanitareTime )
    timeLimitErrorCon.tag = '_timeLimitErrorCon'

    try
    {
      ready = _.Consequence.From( suite.onSuiteEnd.call( suite.context, suite ) || null );
    }
    catch( err )
    {
      ready = new _.Consequence().error( err );
    }

    ready = ready.orKeepingSplit([ timeLimitErrorCon, wTester._cancelCon ])

    ready.finally( ( _err, got ) =>
    {
      if( !timeLimitErrorCon.resourcesCount() )
      timeLimitErrorCon.take( _.dont );

      if( _err )
      {
        if( _err.reason === 'time out' )
        _err = _._err
        ({
          args : [ _err || '' , `\nTimeOut set to ${suite.onSuiteEndTimeOut} + ms` ],
          usingSourceCode : 0,
        });

        err = _.err( `Error in suite.onSuiteEnd of ${suite.qualifiedName}\n`, _err );
        suite.exceptionReport({ err : err });
      }

      return null;
    })
  }

  if( !ready )
  ready = new _.Consequence().take( null );

  /* process watcher */

  if( suite.processWatching )
  ready.tap( () =>
  {
    _.process.off( 'subprocessStartEnd', suite._processWatcher.subprocessStartEnd );
    _.process.off( 'subprocessTerminationEnd', suite._processWatcher.subprocessTerminationEnd );
    _.each( suite._processWatcherMap, ( descriptor, pid ) =>
    {
      let err = _.errBrief( 'Test suite', _.strQuote( suite.name ), 'had zombie process with pid:', pid, '\n' );
      if( suite.takingIntoAccount )
      suite.consoleBar( 0 );
      suite.exceptionReport({ err : err });
      _.process.kill({ pid : descriptor.process.pid, withChildren : 1 })
    })
    _.time.out( 1000, () =>
    {
      _.each( suite._processWatcherMap, ( descriptor, pid ) =>
      {
        if( _.process.isAlive( descriptor.process.pid ) )
        {
          let err = _.errBrief( 'Test suite', _.strQuote( suite.name ), 'fails to kill zombie process with pid:', pid, '\n' );
          if( suite.takingIntoAccount )
          suite.consoleBar( 0 );
          suite.exceptionReport({ err : err });
        }
      })
    })
  })

  ready.then( () =>
  {
    /* error */

    if( !err )
    // if( suite.routine !== null && !suite.tests[ suite.routine ] )
    if( suite.routine !== null )
    if( suite.report.testRoutineFails + suite.report.testRoutinePasses === 0 )
    {
      debugger;
      err = _.errBrief( 'Test suite', _.strQuote( suite.name ), 'does not have test routine', _.strQuote( suite.routine ), '\n' );
    }

    if( err )
    {
      try
      {
        if( suite.takingIntoAccount )
        suite.consoleBar( 0 );
        suite.exceptionReport({ err : err });
      }
      catch( err2 )
      {
        debugger;
        console.error( err2 );
        console.error( err.toString() + '\n' + err.stack );
      }
    }

    /* process exit handler */

    if( _.process && suite._terminated_joined && suite.takingIntoAccount )
    {
      if( _.process.hasEventHandler( 'exit', suite._terminated_joined ) )
      _.process.off( 'exit', suite._terminated_joined );
      suite._terminated_joined = null;
    }

    /* report */

    suite._reportEnd();

    let ok = suite._reportIsPositive();

    logger.begin({ verbosity : -2 });

    if( logger._mines[ 'suite.content' ] )
    logger.laterFinit( 'suite.content' );
    else
    logger.log();

    if( logger )
    logger.begin({ 'connotation' : ok ? 'positive' : 'negative' });
    if( logger )
    logger.begin( 'suite', 'end' );

    let msg = suite._reportToStr();

    logger.log( msg );

    let timingStr = '';
    if( wTester.settings.timing )
    {
      suite.report.timeSpent = _.time.now() - suite._testSuiteBeginTime;
      timingStr = ' ... in ' + _.time.spentFormat( suite.report.timeSpent );
    }

    msg = 'Test suite ( ' + suite.name + ' )' + timingStr + ' ... ' + ( ok ? 'ok' : 'failed' );

    msg = wTester.textColor( msg, ok );

    logger.begin({ verbosity : -1 });
    logger.logDown( msg );
    logger.end({ verbosity : -1 });

    logger.begin({ verbosity : -2 });
    logger.log();
    logger.end({ verbosity : -2 });

    logger.end( 'suite', 'end' );
    logger.end({ 'connotation' : ok ? 'positive' : 'negative' });

    logger.end({ verbosity : -2 });
    logger.end({ verbosity : -6 + suite.importanceOfDetails });
    logger.verbosityPop();

    if( suite._appExitCode && !_.process.exitCode() )
    suite._appExitCode = _.process.exitCode( suite._appExitCode );

    /* silencing */

    if( suite.silencing )
    suite.consoleBar( 0 );

    /* */

    if( suite.takingIntoAccount )
    wTester._testSuiteConsider( ok );

    /* tracking */

    _.arrayRemoveElementOnceStrictly( wTester.activeSuites, suite );
    _.arrayRemoveElementOnceStrictly( wTester.quedSuites, suite );

    /* */

    if( !wTester.activeSuites.length && !wTester.quedSuites.length )
    wTester._testingEndSoon();

    return suite;

  })

  return ready;
}

//

function _terminated()
{
  let suite = this;
  let err = _.process ? _.process.exitReason() : null;
  if( !err )
  {
    err = _.errBrief( 'Terminated by user' );
    _.errReason( err, 'terminated by user' );
  }
  wTester.cancel({ err : err, terminatedByUser : 1, global : 1 });
}

//

/**
 * @summary Handler called before execution of each test routine
 * @param {Object} t Instance of {@link module:Tools/atop/Tester.wTestRoutineDescriptor}
 * @method onRoutineBegin
 * @class wTestSuite
 * @module Tools/atop/Tester
*/

function onRoutineBegin( t )
{
}

//

/**
 * @summary Handler called after execution of each test routine
 * @param {Object} t Instance of {@link module:Tools/atop/Tester.wTestRoutineDescriptor}
 * @method onRoutineBegin
 * @class wTestSuite
 * @module Tools/atop/Tester
*/

function onRoutineEnd( t )
{
}

//

/**
 * @summary Handler called before execution of current test suite
 * @param {Object} t Current test suite instance.
 * @method onSuiteBegin
 * @class wTestSuite
 * @module Tools/atop/Tester
*/

function onSuiteBegin( t )
{
}

//

/**
 * @summary Handler called after execution of current test suite
 * @param {Object} t Current test suite instance.
 * @method onSuiteEnd
 * @class wTestSuite
 * @module Tools/atop/Tester
*/

function onSuiteEnd( t )
{
}

// --
// test routine
// --

function _testRoutineRun( trd )
{
  let suite = this;
  let report = suite.report;

  /* */

  if( !wTester._canContinue() )
  return null;

  if( !trd.runnable )
  return null;

  /* */

  _.assert( arguments.length === 1, 'Expects single argument' );

  return suite._routineCon
  .then( () => trd._run() )
  .split();

}

//

/**
 * @summary Calls `onEach` handler for each test routine defined in current suite.
 * @description Function onEach should accept single argument - descriptor of test routine.
 * @param {Function} onEach Function to call for each routine.
 * @method routineEach
 * @class wTestSuite
 * @module Tools/atop/Tester
*/

function routineEach( onEach )
{
  let suite = this;

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( onEach ) );
  _.assert( suite._formed );

  for( let testRoutineName in suite.tests )
  {
    let testRoutine = suite.tests[ testRoutineName ];
    onEach( testRoutine );
  }

  return suite;
}

// --
// report
// --

function _reportBegin()
{
  let suite = this;

  _.assert( !suite.report, 'test suite already has report' );

  let report = suite.report = Object.create( null );

  report.outcome = null;
  report.timeSpent = null;
  report.errorsArray = [];
  report.appExitCode = null;

  report.testCheckPasses = 0;
  report.testCheckFails = 0;

  report.testCasePasses = 0;
  report.testCaseFails = 0;

  report.testRoutinePasses = 0;
  report.testRoutineFails = 0;

  Object.preventExtensions( report );
}

//

function _reportEnd()
{
  let suite = this;
  let report = suite.report;

  if( !report.appExitCode )
  report.appExitCode = _.process.exitCode();

  if( report.appExitCode !== undefined && report.appExitCode !== null && report.appExitCode !== 0 )
  report.outcome = false;

  if( report.testCheckFails !== 0 )
  report.outcome = false;

  if( report.testRoutineFails !== 0 )
  report.outcome = false;

  if( !( report.testCheckPasses > 0 ) )
  report.outcome = false;

  if( report.errorsArray.length )
  report.outcome = false;

  if( report.outcome === null )
  report.outcome = true;

  return report.outcome;
}

//

function _reportToStr()
{
  let suite = this;
  let report = suite.report;
  let msg = '';

  if( report.appExitCode !== undefined && report.appExitCode !== null && report.appExitCode !== 0 )
  msg = 'ExitCode : ' + report.appExitCode + '\n';

  if( report.errorsArray.length )
  msg += 'Thrown ' + ( report.errorsArray.length ) + ' error(s)\n';

  msg += 'Passed test checks ' + ( report.testCheckPasses ) + ' / ' + ( report.testCheckPasses + report.testCheckFails ) + '\n';
  msg += 'Passed test cases ' + ( report.testCasePasses ) + ' / ' + ( report.testCasePasses + report.testCaseFails ) + '\n';
  msg += 'Passed test routines ' + ( report.testRoutinePasses ) + ' / ' + ( report.testRoutinePasses + report.testRoutineFails ) + '';

  return msg;
}

//

function _reportIsPositive()
{
  let suite = this;
  let report = suite.report;

  if( !report )
  return false;

  suite._reportEnd();

  return !!report.outcome;
}

// --
// consider
// --

function _testCheckConsider( outcome )
{
  let suite = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( this.constructor === Self );
  _.assert( suite.takingIntoAccount !== undefined );

  if( outcome )
  {
    if( suite.report )
    suite.report.testCheckPasses += 1;
  }
  else
  {
    if( suite.report )
    suite.report.testCheckFails += 1;
  }

  if( suite.takingIntoAccount )
  wTester._testCheckConsider( outcome );

}

//

function _testCaseConsider( outcome )
{
  let suite = this;
  let report = suite.report;

  if( outcome )
  report.testCasePasses += 1;
  else
  report.testCaseFails += 1;

  if( suite.takingIntoAccount )
  wTester._testCaseConsider( outcome );
}

//

function _testRoutineConsider( outcome )
{
  let suite = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( this.constructor === Self );
  _.assert( suite.takingIntoAccount !== undefined );

  if( outcome )
  {
    if( suite.report )
    suite.report.testRoutinePasses += 1;
  }
  else
  {
    if( suite.report )
    suite.report.testRoutineFails += 1;
  }

  if( suite.takingIntoAccount )
  wTester._testRoutineConsider( outcome );

}

//

function _exceptionConsider( err )
{
  let suite = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( suite.constructor === Self );

  _.arrayAppendOnce( suite.report.errorsArray, err );

  if( suite.takingIntoAccount )
  wTester._exceptionConsider( err );

}

//

/**
 * @summary Says test suite to report the exception and print error message to output.
 * @param {Object} o Options map.
 * @param {String|Error} o.err Exception message or error object.
 * @param {Boolean} [o.considering=true] If true test suite will take care about this error, otherwise it will by only printed by logger .
 * @method exceptionReport
 * @class wTestSuite
 * @module Tools/atop/Tester
*/

function exceptionReport( o )
{
  let suite = this;
  let logger = suite.logger || wTester.logger || _global_.logger;
  let err;

  _.routineOptions( exceptionReport, o );
  _.assert( arguments.length === 1, 'Expects single argument' );

  try
  {

    let wasBarred;
    if( o.unbarring )
    wasBarred = suite.consoleBarPreserving( 0 );

    err = _.err( o.err );

    if( o.considering )
    suite._exceptionConsider( err );

    logger.begin({ verbosity : 9 });
    logger.log( _.errOnce( err ) );
    logger.end({ verbosity : 9 });

    if( o.unbarring )
    suite.consoleBarPreserving( wasBarred );

  }
  catch( err2 )
  {
  }

  return err;
}

exceptionReport.defaults =
{
  err : null,
  considering : 1,
  unbarring : 0,
}

// --
// name
// --

function qualifiedNameGet()
{
  let suite = this;
  return suite.constructor.shortName + '::' + suite.name;
}

//

function decoratedQualifiedNameGet()
{
  let suite = this;
  debugger;
  return wTester.textColor( suite.qualifiedNameGet, 'entity' );
}

//

function absoluteNameGet()
{
  let suite = this;
  let slash = ' / ';
  debugger;
  return suite.qualifiedName;
}

//

function decoratedAbsoluteNameGet()
{
  let suite = this;
  debugger;
  return wTester.textColor( suite.absoluteName, 'entity' );
}

// --
// let
// --

let accuracySymbol = Symbol.for( 'accuracy' );
let routineSymbol = Symbol.for( 'routine' );

/**
 * @typedef {Object} TestSuiteFields
 * @property {String} name
 * @property {Number} verbosity=3
 * @property {Number} importanceOfDetails=0
 * @property {Number} negativity=1
 * @property {Boolean} silencing
 * @property {Boolean} shoulding=1
 * @property {Number} routineTimeOut=10000
 * @property {Boolean} concurrent=0
 * @property {String} routine
 * @property {Array} platforms
 * @property {String} suiteFilePath
 * @property {String} suiteFileLocation
 * @property {Object} tests
 * @property {Boolean} abstract=0
 * @property {Boolean} enabled=1
 * @property {Boolean} takingIntoAccount=1
 * @property {Boolean} usingSourceCode=1
 * @property {Boolean} ignoringTesterOptions=0
 * @property {Number} accuracy=1e-7,
 * @property {String} report
 * @property {Boolean} debug=0
 * @property {Function} onRoutineBegin
 * @property {Function} onRoutineEnd
 * @property {Function} onSuiteBegin
 * @property {Function} onSuiteEnd
 * @class wTestSuite
 * @module Tools/atop/Tester
 */

// --
// relations
// --

let enabledSymbol = Symbol.for( 'enabled' );

let Composes =
{

  name : null,

  verbosity : 3,
  importanceOfDetails : 0,
  negativity : 3,

  silencing : null,
  shoulding : 1,

  routineTimeOut : 5000,
  onSuiteEndTimeOut : 15000,
  concurrent : 0,
  routine : null,
  platforms : null,

  processWatching : 1,

  /* */

  suiteFilePath : null,
  suiteFileLocation : null,
  tests : null,

  abstract : 0,
  enabled : 1,
  takingIntoAccount : 1,
  usingSourceCode : 1,
  ignoringTesterOptions : 0,

  // accuracyRange : null,
  accuracyExplicitly : null,
  accuracy : 1e-7,
  report : null,

  override : _.define.own( {} ),

  _routineCon : _.define.own( new _.Consequence().take( null ) ),
  _inroutineCon : _.define.own( new _.Consequence().take( null ) ),

  onRoutineBegin : onRoutineBegin,
  onRoutineEnd : onRoutineEnd,

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

}

let Aggregates =
{
}

let Associates =
{
  logger : null,
  context : null,
}

let Restricts =
{
  currentRoutine : null,
  _initialOptions : null,
  _terminated_joined : null,
  _hasConsoleInOutputs : 0,
  _testSuiteBeginTime : null,
  _formed : 0,
  _appExitCode : null,
  _processWatcher : null,
  _processWatcherMap : null
}

let Statics =
{
  Froms,
  UsingUniqueNames : _.define.contained({ ini : 1, readOnly : 1 }),
  _SuitesReady : new _.Consequence().take( null ),
}

let Events =
{
  routineBegin : 'routineBegin',
  routineEnd : 'routineEnd',
}

let Forbids =
{
  safe : 'safe',
  options : 'options',
  special : 'special',
  currentRoutineFails : 'currentRoutineFails',
  currentRoutinePasses : 'currentRoutinePasses',
  SettingsOfSuite : 'SettingsOfSuite',
  timing : 'timing',
}

let Accessors =
{

  accuracy : 'accuracy',
  routine : 'routine',
  enabled : 'enabled',

  qualifiedName : { readOnly : 1 },
  decoratedQualifiedName : { readOnly : 1 },
  absoluteName : { readOnly : 1 },
  decoratedAbsoluteName : { readOnly : 1 },

  // logger : { set : function( src )
  // {
  //   if( src && !src.name )
  //   debugger;
  //   this[ Symbol.for( 'logger' ) ] = src;
  // }},

}

// --
// declare
// --

let Proto =
{

  // inter

  init,
  precopy,
  copy,
  inherit,
  Froms,

  // etc

  _accuracySet,
  _routineSet,
  _enabledSet,
  _enabledGet,
  _consoleBar,
  consoleBar,
  consoleBarPreserving,

  // test suite run

  run,
  _form,
  _runSoon,
  _runNow,
  _begin,
  _endSoon,
  _end,
  _terminated,

  onSuiteBegin,
  onSuiteEnd,

  // test routines

  _testRoutineRun,
  routineEach,

  // report

  _reportBegin,
  _reportEnd,
  _reportToStr,
  _reportIsPositive,

  // consider

  _testCheckConsider,
  _testCaseConsider,
  _testRoutineConsider,
  _exceptionConsider,
  exceptionReport,

  // name

  qualifiedNameGet,
  decoratedQualifiedNameGet,
  absoluteNameGet,
  decoratedAbsoluteNameGet,

  // relations

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Events,
  Forbids,
  Accessors,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );
_.Instancing.mixin( Self );
if( _.EventHandler )
_.EventHandler.mixin( Self );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;
wTesterBasic[ Self.shortName ] = Self;
_realGlobal_[ Self.name ] = _global_[ Self.name ] = Self;

})();
