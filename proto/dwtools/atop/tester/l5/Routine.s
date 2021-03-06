(function _Routine_s_() {

'use strict';

//

/**
 * @classdesc Provides interface for creating of test routines. Interface is a collection of routines to create cases, groups of cases, perform different type of checks.
 * @class wTestRoutineDescriptor
 * @param {Object} o Test suite option map. {@link module:Tools/atop/Tester.wTestRoutineDescriptor.TestRoutineFields More about options}
 * @module Tools/atop/Tester
 */

let _global = _global_;
let _ = _global_.wTools;
let debugged = _.process.isDebugged();

let Parent = null;
let Self = function wTestRoutineDescriptor( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'TestRoutine';

// --
// inter
// --

function init( o )
{
  let trd = this;

  trd[ accuracyEffectiveSymbol ] = null;
  _.workpiece.initFields( trd );
  Object.preventExtensions( trd );

  if( o )
  trd.copy( o );

  _.assert( _.routineIs( trd.routine ) );
  _.assert( Object.isPrototypeOf.call( wTestSuite.prototype, trd.suite ) );
  _.assert( Object.isPrototypeOf.call( Self.prototype, trd ) );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert
  (
    _.strDefined( trd.routine.name ),
    `Test routine should have name ${trd.name} test routine of test suite ${trd.suite.decoratedNickName} does not have name`
  );

  let proxy =
  {
    get : function( obj, k )
    {
      if( obj[ k ] !== undefined )
      return obj[ k ];
      return obj.suite[ k ];
    }
  }

  trd = new Proxy( trd, proxy );

  return trd;
}

//

/**
 * @summary Ensures that instance has all required properties defined.
 * @method form
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function form()
{
  let trd = this;
  let routine = trd.routine;
  let name = trd.decoratedAbsoluteName;
  let suite = trd.suite;

  trd._returnCon = null;
  trd._fieldsForm();
  trd._accuracyChange();
  trd._reportBegin();

  _.sure( routine.experimental === undefined || _.boolLike( routine.experimental ), name, 'Expects bool like in field {-experimental-} if defined' );
  _.sure( routine.timeOut === undefined || _.numberIs( routine.timeOut ), name, 'Expects number in field {-timeOut-} if defined' );
  _.sure( routine.routineTimeOut === undefined || _.numberIs( routine.routineTimeOut ), name, 'Expects number in field {-routineTimeOut-} if defined' );
  _.sure( routine.accuracy === undefined || _.numberIs( routine.accuracy ) || _.rangeIs( routine.accuracy ), name, 'Expects number or range in field {-accuracy-} if defined' );
  _.sure( routine.rapidity === undefined || _.numberIs( routine.rapidity ), name, 'Expects number in field {-rapidity-} if defined' );

  _.assert
  (
    _.strDefined( trd.name ),
    `Test routine should have name ${trd.name} test routine of test suite ${trd.suite.decoratedNickName} does not have name`
  );
  _.assert( suite instanceof wTestSuite );
  _.assert( suite.tests[ trd.name ] === routine || suite.tests[ trd.name ] === trd );

  suite.tests[ trd.name ] = trd;

  trd._formed = 1;
  return trd;
}

//

function _fieldsForm()
{
  let trd = this;
  let routine = trd.routine;
  let name = trd.decoratedAbsoluteName;

  for( let f in trd.RoutineFields )
  {
    if( routine[ f ] !== undefined )
    trd[ trd.RoutineFields[ f ] ] = routine[ f ];
  }

  _.sureMapHasOnly
  (
    routine,
    wTester.TestRoutine.RoutineFields,
    name + ' has unknown fields :'
  );

}

// --
// accessor
// --

function _accuracyGet()
{
  let trd = this;
  return trd[ accuracyEffectiveSymbol ];
}

//

function _accuracySet( accuracy )
{
  let trd = this;

  _.assert( accuracy === null || _.numberIs( accuracy ) || _.rangeIs( accuracy ), 'Expects number or range {-accuracy-}' );

  trd[ accuracySymbol ] = accuracy;

  return trd._accuracyChange();
}

//

function _accuracyEffectiveGet()
{
  let trd = this;
  return trd[ accuracyEffectiveSymbol ];
}

//

function _accuracyChange()
{
  let trd = this;
  let result;

  if( !trd.suite )
  return null;

  if( _.numberIs( trd[ accuracySymbol ] ) )
  {
    result = trd[ accuracySymbol ];
  }
  else
  {
    if( _.rangeIs( trd[ accuracySymbol ] ) )
    {
      _.assert( _.rangeIs( trd[ accuracySymbol ] ) );
      if( trd.suite.accuracyExplicitly !== null )
      result = trd.suite.accuracyExplicitly
      else
      result = trd[ accuracySymbol ][ 0 ];
      if( _.rangeIs( result ) )
      result = result[ 0 ];
      result = _.numberClamp( result, trd[ accuracySymbol ] );
    }
    else
    {
      result = trd.suite.accuracy;
      if( _.rangeIs( result ) )
      result = result[ 0 ];
    }
  }

  _.assert( _.numberDefined( result ) );

  trd[ accuracyEffectiveSymbol ] = result;
  return result;
}

//

function _timeOutGet()
{
  let trd = this;
  if( trd[ timeOutSymbol ] !== null )
  return trd[ timeOutSymbol ];
  if( trd.suite.routineTimeOut !== null )
  return trd.suite.routineTimeOut;
  _.assert( 0 );
}

//

function _timeOutSet( timeOut )
{
  let trd = this;
  _.assert( timeOut === null || _.numberIs( timeOut ) );
  trd[ timeOutSymbol ] = timeOut;
  return timeOut;
}

//

function _rapidityGet()
{
  let trd = this;
  if( trd[ rapiditySymbol ] !== null )
  return trd[ rapiditySymbol ];
  _.assert( 0 );
}

//

function _rapiditySet( rapidity )
{
  let trd = this;
  _.assert( _.numberIs( rapidity ) );
  if( rapidity > 9 )
  rapidity = 9;
  if( rapidity < -9 )
  rapidity = -9;
  trd[ rapiditySymbol ] = rapidity;
  return rapidity;
}

//

function _usingSourceCodeGet()
{
  let trd = this;

  if( trd[ usingSourceCodeSymbol ] !== null )
  return trd[ usingSourceCodeSymbol ];

  if( trd.rapidity < 0 && trd.suite.routine !== trd.name )
  return false;

  if( trd.suite.usingSourceCode !== null )
  return trd.suite.usingSourceCode;

  _.assert( 0 );
}

//

function _usingSourceCodeSet( usingSourceCode )
{
  let trd = this;
  _.assert( usingSourceCode === null || _.boolLike( usingSourceCode ) );
  trd[ usingSourceCodeSymbol ] = usingSourceCode;
  return usingSourceCode;
}

// --
// run
// --

function _run()
{
  let trd = this;
  let suite = trd.suite;
  let result;

  trd._runBegin();

  trd._timeLimitCon = new _.Consequence({ tag : '_timeLimitCon' });
  trd._timeLimitErrorCon = _.time.outError( debugged ? Infinity : trd.timeOut + wTester.settings.sanitareTime )
  .tap( ( err, arg ) =>
  {
    trd._timeLimitCon.take( err || null );
    if( err && !trd.reason )
    trd.report.reason = 'timed limit';
  });
  trd._timeLimitErrorCon.tag = '_timeLimitErrorCon';

  /* */

  try
  {
    result = trd.routine.call( suite.context, trd );
    if( result === undefined )
    result = null;
  }
  catch( err )
  {
    result = new _.Consequence().error( _.err( err ) );
  }

  /* */

  result = trd._returnCon = _.Consequence.From( result ); /* xxx : expose split instead */

  if( Config.debug && !result.tag )
  result.tag = trd.name;

  result.andKeep( suite._inroutineCon );

  result = result.orKeepingSplit([ trd._timeLimitErrorCon, wTester._cancelCon ]);

  result.finally( ( err, msg ) => trd._runFinally( err, msg ) );

  return result;
}

//

function _runBegin()
{
  let trd = this;
  let suite = trd.suite;

  _.assert( !!wTester );
  trd._testRoutineBeginTime = _.time.now();

  _.arrayAppendOnceStrictly( wTester.activeRoutines, trd );

  trd._appExitCode = _.process.exitCode( 0 );
  suite._hasConsoleInOutputs = suite.logger.hasOutput( console, { deep : 0, withoutOutputToOriginal : 0 } );

  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( trd._returned === null );

  let msg =
  [
    `Running ${trd.decoratedAbsoluteName} ..`
  ];

  suite.logger.begin({ verbosity : -4 });

  suite.logger.begin({ 'routine' : trd.routine.name });
  suite.logger.logUp( msg.join( '\n' ) );
  suite.logger.end( 'routine' );

  suite.logger.end({ verbosity : -4 });

  _.assert( !suite.currentRoutine );
  suite.currentRoutine = trd;

  let debugWas = Config.debug;
  if( wTester.settings.debug !== null && wTester.settings.debug !== undefined )
  {
    _.assert( _.boolLike( wTester.settings.debug ) ); debugger;
    Config.debug = wTester.settings.debug;
  }

  try
  {
    suite.onRoutineBegin.call( trd.context, trd );
    if( Config.debug !== debugWas )
    Config.debug = debugWas;
    if( trd.eventGive )
    trd.eventGive({ kind : 'routineBegin', testRoutine : trd, context : trd.context });
  }
  catch( err )
  {
    if( Config.debug !== debugWas )
    Config.debug = debugWas;
    trd.exceptionReport({ err : err });
  }

  if( Config.debug !== debugWas )
  Config.debug = debugWas;
}

//

function _runEnd()
{
  let trd = this;
  let suite = trd.suite;

  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( _.strDefined( trd.routine.name ), 'test routine should have name' );
  _.assert( suite.currentRoutine === trd );

  if( !trd._timeLimitErrorCon.resourcesCount() && !trd._timeLimitCon.resourcesCount() )
  trd._timeLimitErrorCon.take( _.dont );

  if( trd._appExitCode && !_.process.exitCode )
  trd._appExitCode = _.process.exitCode( trd._appExitCode );

  let _hasConsoleInOutputs = suite.logger.hasOutput( console, { deep : 0, withoutOutputToOriginal : 0 } );
  if( suite._hasConsoleInOutputs !== _hasConsoleInOutputs && !wTester._canceled )
  {

    debugger;
    let err = _.err( 'Console is missing in logger`s outputs, probably it was removed' + '\n  in' + trd.absoluteName );
    suite.exceptionReport
    ({
      unbarring : 1,
      err : err,
    });

  }

  /* groups stack */

  trd._descriptionChange({ src : '', touching : 0 });
  trd._groupTestEnd();

  if( trd.report.errorsArray.length && !trd.report.reason )
  {
    if( trd.report.errorsArray[ 0 ].reason )
    trd.report.reason = trd.report.errorsArray[ 0 ].reason;
    else
    trd.report.reason = 'throwing error';
  }

  /* last test check */

  if( trd.report.testCheckPasses === 0 && trd.report.testCheckFails === 0 )
  {
    if( !trd.report.reason )
    trd.report.reason = 'passed none test check';
    trd._outcomeReportBoolean
    ({
      outcome : 0,
      msg : 'test routine has passed none test check',
      usingSourceCode : 0,
      usingDescription : 0,
    });
  }
  else if( !trd.report.errorsArray )
  {
    trd._outcomeReportBoolean
    ({
      outcome : 1,
      msg : 'test routine has not thrown an error',
      usingSourceCode : 0,
      usingDescription : 0,
    });
  }

  /* on end */

  trd._reportEnd();
  let ok = trd._reportIsPositive();
  try
  {
    suite.onRoutineEnd.call( trd.context, trd, ok );
    if( trd.eventGive )
    trd.eventGive({ kind : 'routineEnd', testRoutine : trd, context : trd.context });
  }
  catch( err )
  {
    trd.exceptionReport({ err : err });
    ok = false;
  }

  /* */

  suite._testRoutineConsider( ok );

  suite.currentRoutine = null;

  /* */

  suite.logger.begin( 'routine', 'end' );
  suite.logger.begin({ 'connotation' : ok ? 'positive' : 'negative' });
  suite.logger.begin({ verbosity : -3 });

  let timingStr = '';
  if( wTester )
  {
    trd.report.timeSpent = _.time.now() - trd._testRoutineBeginTime;
    timingStr = 'in ' + _.time.spentFormat( trd.report.timeSpent );
  }

  let str = ( ok ? 'Passed' : 'Failed' ) + ( trd.report.reason ? ` ( ${trd.report.reason} )` : '' ) + ` ${trd.absoluteName} ${timingStr}`;

  str = wTester.textColor( str, ok );

  if( !ok )
  suite.logger.begin({ verbosity : -3+suite.negativity });

  suite.logger.logDown( str );

  if( !ok )
  suite.logger.end({ verbosity : -3+suite.negativity });

  suite.logger.end({ 'connotation' : ok ? 'positive' : 'negative' });
  suite.logger.end( 'routine', 'end' );

  suite.logger.end({ verbosity : -3 });

  _.arrayRemoveElementOnceStrictly( wTester.activeRoutines, trd );

  return ok
}

//

function _runFinally( err, arg )
{
  let trd = this;
  let suite = trd.suite;

  _.assert( arguments.length === 2 );
  _.assert( trd._returned === null );

  trd._returned = [ err, arg ];

  if( err )
  {

    trd.exceptionReport
    ({
      err : err,
    });

    trd._runEnd();
    return err;
  }

  trd._runEnd();
  return arg;
}

//

function _runInterruptMaybe( throwing )
{
  let trd = this;
  let logger = trd.logger;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !!wTester.report );

  trd._returnedVerification();

  if( !wTester._canContinue() )
  {
    debugger; xxx
    /* qqq xxx */
    // if( trd._returnCon )
    // trd._returnCon.cancel();
    // let result = wTester.cancel({ global : 0 });
    let result = trd.cancel();
    if( throwing )
    throw result;
    return result;
  }

  let elapsed = _.time.now() - trd._testRoutineBeginTime;
  if( elapsed > trd.timeOut && !debugged )
  {
    logger.log( `Test routine ${trd.absoluteName} timed out, cant continue!` );
    let result = trd.cancel({ err : trd._timeOutError() });
    if( throwing )
    throw result;
    return result;
  }

  return false;
}

//

function _returnedVerification()
{
  let trd = this;
  let suite = trd.suite;
  let logger = trd.logger;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !!wTester.report );

  if( trd._returned )
  {
    let err = _._err({ args : [ `Test routine ${trd.absoluteName} returned, cant continue!` ], reason : 'returned' });
    err = _.errBrief( err );
    suite.exceptionReport
    ({
      unbarring : 1,
      err : err,
    });
    throw err;
  }

}

//

function _runnableGet()
{
  let trd = this;
  let suite = trd.suite;

  _.assert( _.numberIs( wTester.settings.rapidity ) );

  if( suite.routine )
  {
    return _.path.globShortFit( trd.name, suite.routine );
  }

  if( trd.experimental )
  return false;

  if( trd.rapidity < wTester.settings.rapidity )
  return false;

  return true;
}

//

function _timeOutError( err )
{
  let trd = this;

  if( err && err._testRoutine )
  return err;

  err = _._err
  ({
    args : [ err || '' , `\nTest routine ${trd.decoratedAbsoluteName} timed out. TimeOut set to ${trd.timeOut} + ms` ],
    usingSourceCode : 0,
    reason : 'time limit',
  });

  Object.defineProperty( err, '_testRoutine',
  {
    enumerable : false,
    configurable : false,
    writable : false,
    value : trd,
  });

  err = _.errBrief( err );

  return err;
}

//

function cancel( o )
{
  let trd = this;
  let logger = trd.logger;
  o = _.routineOptions( cancel, arguments );

  if( trd._returnCon )
  if( trd._returnCon.resourcesCount() === 0 )
  {
    debugger;
    if( !o.err )
    o.err = _.errBrief( `Test routine ${trd.absoluteName} was canceled!` );
    logger.error( _.errOnce( o.err ) );
    trd._returnCon.error( o.err );
  }

  return wTester.cancel( o );
}

cancel.defaults =
{
  global : 0,
  err : null,
}

// --
// check description
// --

function _descriptionGet()
{
  let trd = this;
  return trd[ descriptionSymbol ];
}

//

function _descriptionSet( src )
{
  let trd = this;
  return trd._descriptionChange({ src });
}

//

function _descriptionChange( o )
{
  let trd = this;

  _.assert( _.mapIs( o ) );
  _.routineOptions( _descriptionChange, o );

  if( o.touching )
  if( wTester.report )
  trd._runInterruptMaybe( 1 );

  trd[ descriptionSymbol ] = o.src;

}

_descriptionChange.defaults =
{
  src : null,
  touching : 9,
}

//

function _descriptionFullGet()
{
  let trd = this;
  let result = '';
  let right = ' > ';
  let left = ' < ';

  result = trd._groupsStack.slice( 0, trd._groupsStack.length-1 ).join( right );
  if( result )
  result += right + trd.case
  else
  result += trd.case
  if( trd.description )
  result += left;

  if( trd.description )
  result += trd.description;

  return result;
}

//

function _descriptionWithNameGet()
{
  let trd = this;
  let description = trd.descriptionFull;
  let name = trd.absoluteName;
  let slash = ' / ';
  return name + slash + description
}

// --
// checks group
// --

function _groupGet()
{
  let trd = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return trd._groupsStack[ trd._groupsStack.length-1 ] || '';
}

//

/**
 * @summary Creates tests group with name `groupName`.
 * @method open
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function groupOpen( groupName )
{
  let trd = this;

  try
  {
    _.assert( arguments.length === 1, 'Expects single argument' );
    _.assert( _.strIs( groupName ), 'Expects string' );
    trd._caseClose();
    trd._groupChange({ group : groupName, open : 1 });

    if( trd._groupsStack.length >= 2 )
    if( trd._groupsStack[ trd._groupsStack.length-1 ] === trd._groupsStack[ trd._groupsStack.length-2 ] )
    {
      debugger;
      let err = trd._groupingErorr( `Attempt to open group "${groupName}". Group with the same name is already opened. Might be you meant to close it?`, 2 );
      err = trd.exceptionReport({ err : err });
      return;
    }

  }
  catch( err )
  {
    trd.exceptionReport
    ({
      err : err,
    });
    return false;
  }

}

//

/**
 * @summary Closes tests group with name `groupName`.
 * @method close
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function groupClose( groupName )
{
  let trd = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  try
  {
    trd._caseClose();
    trd._groupChange({ group : groupName, open : 0 });
  }
  catch( err )
  {
    trd.exceptionReport
    ({
      err : err,
    });
    return false;
  }

  return trd.group;
}

//

function _groupChange( o )
{
  let trd = this;

  _.routineOptions( _groupChange, o );
  _.assert( arguments.length === 1, 'Expects no arguments' );
  _.assert( _.strIs( o.group ) || o.group === null );

  if( o.open )
  open();
  else
  close();

  reset();

  /* */

  function reset()
  {
    trd._groupOpenedWithCase = 0;
    trd._testCheckPassesOfTestCase = 0;
    trd._testCheckFailsOfTestCase = 0;
    trd._descriptionChange({ src : '', touching : 0 });
    // trd._caseClose();
  }

  /* */

  function open()
  {
    let group = trd.group;
    // if( group !== o.group )
    // trd._caseClose();

    _.assert( trd._groupOpenedWithCase === 0 );

    if( !o.group )
    return

    // if( trd._groupsStack[ trd._groupsStack.length-1 ] === o.group )
    // {
    //   debugger;
    //   let err = trd._groupingErorr( `Attempt to open group "${o.group}". Group with the same name is already opened. Might be you meant to close it?`, 4 );
    //   err = trd.exceptionReport({ err : err });
    //   return;
    // }

    trd._groupsStack.push( o.group );

  }

  /* */

  function close()
  {
    // let group = trd.group;
    // if( group !== o.group )
    // if(  )
    // trd._caseClose();
    let group = trd.group;

    if( group !== o.group )
    {
      debugger;
      let err = trd._groupingErorr( `Discrepancy!. Attempt to close not the topmost tests group. \nAttempt to close "${o.group}", but current tests group is "${group}". Might be you want to close it first.`, 4 );
      err = trd.exceptionReport({ err : err });
    }
    else
    {
      trd._groupsStack.pop();
    }

    // if( trd._groupIsCase )
    if( group )
    {
      if( trd._testCheckFailsOfTestCase > 0 || trd._testCheckPassesOfTestCase > 0 )
      trd._testCaseConsider( !trd._testCheckFailsOfTestCase );
    }

    // trd._groupIsCase = 0;
  }

}

_groupChange.defaults =
{
  group : null,
  open : null,
  touching : 9,
  // closingCase : 0,
}

//

function _groupTestEnd()
{
  let trd = this;

  trd._caseClose();

  if( trd._groupsStack.length && !trd._groupError )
  {
    let err = trd._groupingErorr( `Tests group ${trd.group} was not closed`, 4 );
    err = trd.exceptionReport({ err : err, usingSourceCode : 0 });
  }

}

//

function _groupingErorr( msg, level )
{
  let trd = this;

  if( level === undefined || level === null )
  level = 4;

  let err = _._err
  ({
    args : [ msg ],
    level : level,
    reason : 'grouping error',
    usingSourceCode : 0,
  });

  err = _.errBrief( err );

  if( !trd._groupError )
  trd._groupError = err;

  return err;
}

//

function _caseGet()
{
  let trd = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  if( trd._groupOpenedWithCase )
  return trd._groupsStack[ trd._groupsStack.length-1 ] || '';
  else
  return '';
}

//

function _caseSet( src )
{
  let trd = this;
  _.assert( arguments.length === 1 );
  return trd._caseChange({ src });
}

//

function _caseClose()
{
  let trd = this;
  let report = trd.report;

  if( trd._groupOpenedWithCase )
  {
    // trd._groupOpenedWithCase = 0;
    _.assert( _.strIs( trd.group ) );
    trd._groupChange({ group : trd.group, touching : 0, open : 0 });
    _.assert( trd._groupOpenedWithCase === 0 );
  }

}

//

function _caseChange( o )
{
  let trd = this;

  _.routineOptions( _caseChange, o );
  _.assert( _.mapIs( o ) );
  _.assert( arguments.length === 1 );
  _.assert( o.src === null || _.strIs( o.src ), () => `Expects string or null {-o.src-}, but got ${_.strType( o.src )}` );

  // yyy
  if( trd.case )
  {
    trd._groupChange({ group : trd.group, touching : o.touching, open : 0 });
  }

  if( o.src )
  {
    trd._groupChange({ group : o.src, touching : o.touching, open : 1 });
    trd._groupOpenedWithCase = 1;
  }
  else
  {
    // if( trd.case )
    // trd._groupChange({ group : o.src, touching : o.touching, open : 0 });
  }

  return o.src;
}

_caseChange.defaults =
{
  src : null,
  touching : 9,
}

// --
// name
// --

function qualifiedNameGet()
{
  let trd = this;
  return trd.constructor.shortName + '::' + trd.name;
}

//

function decoratedQualifiedNameGet()
{
  let trd = this;
  debugger;
  return wTester.textColor( trd.qualifiedNameGet, 'entity' );
}

//

function absoluteNameGet()
{
  let trd = this;
  let slash = ' / ';
  return trd.suite.qualifiedName + slash + trd.qualifiedName;
}

//

function decoratedAbsoluteNameGet()
{
  let trd = this;
  return wTester.textColor( trd.absoluteName, 'entity' );
}

// --
// ceck
// --

/**
 * @summary Returns information about current test check.
 * @method checkCurrent
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function checkCurrent()
{
  let trd = this;
  let result = Object.create( null );

  _.assert( arguments.length === 0, 'Expects no arguments' );

  result.groupsStack = trd._groupsStack;
  result.description = trd.description;
  result.checkIndex = trd._checkIndex;

  return result;
}

//

/**
 * @summary Returns information about next test check.
 * @method checkCurrent
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function checkNext( description )
{
  let trd = this;

  _.assert( trd instanceof Self );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( !trd._checkIndex )
  trd._checkIndex = 1;
  else
  trd._checkIndex += 1;

  if( description !== undefined )
  trd.description = description;

  return trd.checkCurrent();
}

//

/**
 * @summary Saves information current test check into a inner container.
 * @method checkCurrent
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function checkStore()
{
  let trd = this;
  let result = trd.checkCurrent();

  _.assert( arguments.length === 0, 'Expects no arguments' );

  trd._checksStack.push( result );

  return result;
}

//

/**
 * @descriptionNeeded
 * @param {Object} acheck
 * @method checkRestore
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function checkRestore( acheck )
{
  let trd = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( acheck )
  {
    trd.checkStore();
    if( acheck === trd._checksStack[ trd._checksStack.length-1 ] )
    {
      debugger;
      _.assert( 0, 'not tested' );
      trd._checksStack.pop();
    }
  }
  else
  {
    _.assert( _.arrayIs( trd._checksStack ) && trd._checksStack.length, 'checkRestore : no stored check in stack' );
    acheck = trd._checksStack.pop();
  }

  trd._checkIndex = acheck.checkIndex;
  trd._groupsStack = acheck.groupsStack;
  trd._descriptionChange({ src : acheck.description, touching : 0 });

  return trd;
}

// --
// consider
// --

function _testCheckConsider( outcome )
{
  let trd = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( trd.constructor === Self );

  if( outcome )
  {
    trd.report.testCheckPasses += 1;
    trd._testCheckPassesOfTestCase += 1;
  }
  else
  {
    trd.report.testCheckFails += 1;
    trd._testCheckFailsOfTestCase += 1;
  }

  trd.suite._testCheckConsider( outcome );

  trd.checkNext();

}

//

function _testCaseConsider( outcome )
{
  let trd = this;
  let report = trd.report;

  if( outcome )
  report.testCasePasses += 1;
  else
  report.testCaseFails += 1;

  trd.suite._testCaseConsider( outcome );
}

//

function _exceptionConsider( err )
{
  let trd = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( trd.constructor === Self );

  trd.report.errorsArray.push( err );
  trd.suite._exceptionConsider( err );

}

// --
// report
// --

function _outcomeReport( o )
{
  let trd = this;
  let logger = trd.logger;
  let sourceCode = '';

  _.routineOptions( _outcomeReport, o );
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( o.considering )
  trd._testCheckConsider( o.outcome );

  /* */

  let verbosity = o.outcome ? 0 : trd.negativity;
  sourceCode = sourceCodeGet();

  /* */

  logger.begin({ verbosity : o.verbosity });

  if( o.considering )
  {
    logger.begin({ 'check' : trd.description || trd._checkIndex });
    logger.begin({ 'checkIndex' : trd._checkIndex });
  }

  logger.begin({ verbosity : o.verbosity+verbosity });

  logger.up();
  if( logger.verbosityReserve() > 1 )
  logger.log();
  logger.begin({ 'connotation' : o.outcome ? 'positive' : 'negative' });

  logger.begin({ verbosity : o.verbosity-1+verbosity });

  if( o.details )
  logger.begin( 'details' ).log( o.details ).end( 'details' );

  if( sourceCode )
  logger.begin( 'sourceCode' ).log( sourceCode ).end( 'sourceCode' );

  logger.end({ verbosity : o.verbosity-1+verbosity });

  logger.begin( 'message' ).logDown( o.msg ).end( 'message' );

  logger.end({ 'connotation' : o.outcome ? 'positive' : 'negative' });
  if( logger.verbosityReserve() > 1 )
  logger.log();

  logger.end({ verbosity : o.verbosity+verbosity });

  if( o.considering )
  logger.end( 'check', 'checkIndex' );
  logger.end({ verbosity : o.verbosity });

  if( o.interruptible )
  trd._runInterruptMaybe( 1 );

  /* */

  function sourceCodeGet()
  {
    let code;
    if( trd.usingSourceCode && o.usingSourceCode )
    {
      let _location = o.stack ? _.introspector.location({ stack : o.stack }) : _.introspector.location({ level : 4 });
      let _code = _.introspector.code
      ({
        location : _location,
        selectMode : o.selectMode,
        numberOfLines : 5,
      });
      if( _code )
      code = '\n' + _code + '\n';
      else
      code = '\n' + _location.full;
    }

    if( code )
    code = ' #inputRaw : 1# ' + code + ' #inputRaw : 0# ';

    return code;
  }

}

_outcomeReport.defaults =
{
  outcome : null,
  msg : null,
  details : null,
  stack : null,
  usingSourceCode : 1,
  selectMode : 'end',
  considering : 1,
  verbosity : -4,
  interruptible : 0,
}

//

function _outcomeReportBoolean( o )
{
  let trd = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.routineOptions( _outcomeReportBoolean, o );

  o.msg = trd._reportTextForTestCheck
  ({
    outcome : o.outcome,
    msg : o.msg,
    usingDescription : o.usingDescription,
  });

  trd._outcomeReport
  ({
    outcome : o.outcome,
    msg : o.msg,
    details : '',
    stack : o.stack,
    usingSourceCode : o.usingSourceCode,
    selectMode : o.selectMode,
    interruptible : o.interruptible,
  });

  // if( o.interruptible )
  // trd._runInterruptMaybe( 1 );

}

_outcomeReportBoolean.defaults =
{
  outcome : null,
  msg : null,
  stack : null,
  usingSourceCode : 1,
  usingDescription : 1,
  interruptible : 0,
  selectMode : 'end',
}

//

function _outcomeReportCompare( o )
{
  let trd = this;

  _.assert( trd instanceof Self );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.routineOptionsPreservingUndefines( _outcomeReportCompare, o );

  let nameOfExpected = ( o.outcome ? o.nameOfPositiveExpected : o.nameOfNegativeExpected );
  let details = '';

  /**/

  if( !o.outcome )
  if( o.usingExtraDetails )
  {
    details += _.entityDiffExplanation
    ({
      name1 : '- got',
      name2 : '- expected',
      srcs : [ o.got, o.expected ],
      path : o.path,
      accuracy : o.accuracy,
      strictString : o.strictString,
    });
  }

  let msg = trd._reportTextForTestCheck({ outcome : o.outcome });

  trd._outcomeReport
  ({
    outcome : o.outcome,
    msg : msg,
    details : details,
    interruptible : o.interruptible,
  });

  if( !o.outcome )
  if( trd.debug )
  debugger;

  /**/

  function msgExpectedGot()
  {
    return '' +
    'got :\n' + _.toStr( o.got, { stringWrapper : '\'' } ) + '\n' +
    nameOfExpected + ' :\n' + _.toStr( o.expected, { stringWrapper : '\'' } ) +
    '';
  }

}

_outcomeReportCompare.defaults =
{
  got : null,
  expected : null,
  diff : null,
  nameOfPositiveExpected : 'expected',
  nameOfNegativeExpected : 'expected',
  outcome : null,
  path : null,
  usingExtraDetails : 1,
  interruptible : 0,
  strictString : 1,
  accuracy : null,
}

//

function exceptionReport( o )
{
  let trd = this;
  let msg = '';
  let err;

  _.routineOptions( exceptionReport, o );
  _.assert( arguments.length === 1, 'Expects single argument' );

  try
  {

    let wasBarred;
    if( o.unbarring )
    wasBarred = suite.consoleBar( 0 );

    try
    {
      if( trd.onError )
      trd.onError.call( trd, o );
    }
    catch( err2 )
    {
      logger.log( err2 );
    }

    if( o.considering )
    {
      /* qqq : implement and cover different message if time out */
      /* qqq : implement and cover different message if user terminated the program */
      if( o.err && o.err.reason )
      msg = trd._reportTextForTestCheck({ outcome : null }) + ` ... failed, ${o.err.reason}`;
      else
      msg = trd._reportTextForTestCheck({ outcome : null }) + ' ... failed, throwing error';
    }
    else
    {
      msg = 'Error throwen'
    }

    if( o.sync !== null )
    msg += ( o.sync ? ' synchronously' : ' asynchronously' );

    err = _._err({ args : [ o.err ], level : _.numberIs( o.level ) ? o.level+1 : o.level });

    if( _.errIsAttended( err ) )
    err = _.errBrief( err );
    _.errAttend( err );

    let details = err.toString();

    o.stack = o.stack === null ? o.err.stack : o.stack;

    if( o.considering )
    trd._exceptionConsider( err );

    trd._outcomeReport
    ({
      outcome : o.outcome,
      msg : msg,
      details : details,
      stack : o.stack,
      usingSourceCode : o.usingSourceCode,
      considering : o.considering,
    });

    if( o.unbarring )
    suite.consoleBar( wasBarred );

  }
  catch( err2 )
  {
    debugger;
    console.error( err2 );
    console.error( msg );
  }

  return err;
}

exceptionReport.defaults =
{
  err : null,
  level : null,
  stack : null,
  usingSourceCode : 0,
  considering : 1,
  outcome : 0,
  unbarring : 0,
  sync : null,
}

//

function _reportBegin()
{
  let trd = this;

  _.assert( !trd.report, 'test routine already has report' );

  let report = trd.report = Object.create( null );

  report.reason = null;
  report.outcome = null;
  report.timeSpent = null;
  report.errorsArray = [];
  report.appExitCode = null;

  report.testCheckPasses = 0;
  report.testCheckFails = 0;

  // report.testCheckPassesOfTestCase = 0;
  // report.testCheckFailsOfTestCase = 0;

  report.testCasePasses = 0;
  report.testCaseFails = 0;

  Object.preventExtensions( report );
}

//

function _reportEnd()
{
  let trd = this;
  let report = trd.report;

  if( !report.appExitCode )
  report.appExitCode = _.process.exitCode();

  if( report.appExitCode !== undefined && report.appExitCode !== null && report.appExitCode !== 0 )
  report.outcome = false;

  if( trd.report.testCheckFails !== 0 )
  report.outcome = false;

  if( !( trd.report.testCheckPasses > 0 ) )
  report.outcome = false;

  if( trd.report.errorsArray.length )
  report.outcome = false;

  if( report.outcome === null )
  report.outcome = true;

  return report.outcome;
}

//

function _reportIsPositive()
{
  let trd = this;
  let report = trd.report;

  if( !report )
  return false;

  trd._reportEnd();

  return report.outcome;
}

//

function _reportTextForTestCheck( o )
{
  let trd = this;

  o = _.routineOptions( _reportTextForTestCheck, o );

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( o.outcome === null || _.boolLike( o.outcome ) );
  _.assert( o.msg === null || _.strIs( o.msg ) );
  _.assert( trd instanceof Self );
  _.assert( trd._checkIndex >= 0 );
  _.assert( _.strDefined( trd.routine.name ), 'test routine should have name' );

  // if( trd._returned )
  // debugger;

  let result = 'Test check' + ' ( ' + trd.descriptionWithName + ' # ' + trd._checkIndex + ' )';

  if( o.msg )
  result += ' : ' + o.msg;

  if( o.outcome !== null )
  {
    if( o.outcome )
    result += ' ... ok';
    else
    result += ' ... failed';
  }

  if( o.outcome !== null )
  result = wTester.textColor( result, o.outcome );

  return result;
}

_reportTextForTestCheck.defaults =
{
  outcome : null,
  msg : null,
  usingDescription : 1,
}

// --
// checker
// --

/**
 * @summary Checks if result `outcome` of provided condition is positive.
 * @description Check passes if result if positive, otherwise fails. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * @param {Boolean} outcome Result of some condition.
 * @method is
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function is( outcome )
{
  let trd = this;

  trd._returnedVerification();

  if( !_.boolLike( outcome ) || arguments.length !== 1 )
  {

    trd.exceptionReport
    ({
      err : 'Test check "is" expects single bool argument, but got ' + arguments.length + ' ' + _.strType( outcome ),
      level : 2,
    });

    outcome = false;

  }
  else
  {
    outcome = !!outcome;
    trd._outcomeReportBoolean
    ({
      outcome : outcome,
      msg : 'expected true',
      interruptible : 1,
    });
  }

  return outcome;
}

//

function isNot( outcome )
{
  let trd = this;

  trd._returnedVerification();

  if( !_.boolLike( outcome ) || arguments.length !== 1 )
  {

    trd.exceptionReport
    ({
      err : 'Test check "isNot" expects single bool argument, but got ' + arguments.length + ' ' + _.strType( outcome ),
      level : 2,
    });

    outcome = false;

  }
  else
  {
    outcome = !outcome;
    trd._outcomeReportBoolean
    ({
      outcome : outcome,
      msg : 'expected false',
      interruptible : 1,
    });
  }

  return outcome;
}

// //
//
// /**
//  * @summary Checks if provided argument is not an Error object.
//  * @description Check passes if result if positive, otherwise fails. After check function reports result of test
//  * to the testing system. If test is failed function also outputs additional information.
//  * @param {*} maybeError Entity to check.
//  * @method isNotError
//  * @class wTestRoutineDescriptor
//  * @module Tools/atop/Tester
//  */
//
// function isNotError( maybeError )
// {
//   let trd = this;
//   let outcome = !_.errIs( maybeError );
//
//   if( arguments.length !== 1 )
//   {
//
//     outcome = false;
//
//     trd.exceptionReport
//     ({
//       err : '"isNotError" expects single argument',
//       level : 2,
//     });
//
//   }
//   else
//   {
//     trd._outcomeReportBoolean
//     ({
//       outcome : outcome,
//       msg : 'expected variable is not error',
//       interruptible : 1,
//     });
//   }
//
//   return outcome;
// }

//

/**
 * Checks if test passes a specified condition by deep strict comparsing result of code execution( got )
 * with target( expected ). Uses recursive comparsion for objects, arrays and array-like objects.
 * If entity( got ) is equal to entity( expected ) test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {*} got - Source entity.
 * @param {*} expected - Target entity.
 *
 * @example
 * function someTest( test )
 * {
 *  test.case = 'single zero';
 *  let got = 0;
 *  let expected = 0;
 *  test.identical( got, expected );//returns true
 *
 *  test.case = 'single number';
 *  let got = 2;
 *  let expected = 1;
 *  test.identical( got, expected );//returns false
 * }
 *
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method identical
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function identical( got, expected )
{
  let trd = this;
  let o2, outcome;

  trd._returnedVerification();

  /* */

  try
  {
    o2 = Object.create( null );
    outcome = _.entityIdentical( got, expected, o2 );
  }
  catch( err )
  {
    trd.exceptionReport
    ({
      err : err,
    });
    return false;
  }

  /* */

  if( arguments.length !== 2 )
  {
    outcome = false;

    trd.exceptionReport
    ({
      err : '"identical" expects two arguments',
      level : 2,
    });

    return outcome;
  }

  /* */

  if( !o2.it || o2.it.lastPath === undefined )
  {
    debugger;
    outcome = false;
    trd.exceptionReport
    ({
      err : 'Something wrong with entityIdentical, iterator misses lastPath',
      level : 2,
    });
    return outcome;
  }

  /* */

  trd._outcomeReportCompare
  ({
    outcome : outcome,
    got : got,
    expected : expected,
    path : o2.it.lastPath,
    usingExtraDetails : 1,
    interruptible : 1,
  });

  /* */

  return outcome;
}

//

/**
 * Checks if test doesn't pass a specified condition by deep strict comparsing result of code execution( got )
 * with target( expected ). Uses recursive comparsion for objects, arrays and array-like objects.
 * If entity( got ) is not equal to entity( expected ) test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {*} got - Source entity.
 * @param {*} expected - Target entity.
 *
 * @example
 * function someTest( test )
 * {
 *  test.case = 'single zero';
 *  let got = 0;
 *  let expected = 0;
 *  test.notIdentical( got, expected );//returns false
 *
 *  test.case = 'single number';
 *  let got = 2;
 *  let expected = 1;
 *  test.notIdentical( got, expected );//returns true
 * }
 *
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method notIdentical
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function notIdentical( got, expected )
{
  let trd = this;
  let o2, outcome;

  trd._returnedVerification();

  /* */

  try
  {
    o2 = Object.create( null );
    outcome = !_.entityIdentical( got, expected, o2 );
  }
  catch( err )
  {
    trd.exceptionReport
    ({
      err : err,
    });
    return false;
  }

  /* */

  if( arguments.length !== 2 )
  {
    outcome = false;

    trd.exceptionReport
    ({
      err : '"notIdentical" expects two arguments',
      level : 2,
    });

    return outcome;
  }

  /* */

  if( !o2.it || o2.it.lastPath === undefined )
  {
    outcome = false;

    trd.exceptionReport
    ({
      err : 'Something wrong with entityIdentical, iterator misses lastPath',
      level : 2,
    });

    return outcome;
  }

  /* */

  trd._outcomeReportCompare
  ({
    outcome : outcome,
    got : got,
    expected : expected,
    path : o2.it.lastPath,
    usingExtraDetails : 0,
    interruptible : 1,
  });

  return outcome;
}

//

/**
 * Checks if test passes a specified condition by deep soft comparsing result of code execution( got )
 * with target( expected ). Uses recursive comparsion for objects, arrays and array-like objects. Two entities are equivalent if
 * difference between their values are less or equal to( accuracy ). Example: ( got - expected ) <= ( accuracy ).
 * If entity( got ) is equivalent to entity( expected ) test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {*} got - Source entity.
 * @param {*} expected - Target entity.
 * @param {*} [ accuracy=1e-7 ] - Maximal distance between two values.
 *
 * @example
 * function sometest( test )
 * {
 *  test.case = 'single number';
 *  let got = 0.5;
 *  let expected = 1;
 *  let accuracy = 0.5;
 *  test.equivalent( got, expected, accuracy );//returns true
 *
 *  test.case = 'single number';
 *  let got = 0.5;
 *  let expected = 2;
 *  let accuracy = 0.5;
 *  test.equivalent( got, expected, accuracy );//returns false
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method equivalent
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function equivalent( got, expected, options )
{
  let trd = this;
  let accuracy = trd.accuracyEffective;
  let o2, outcome;

  trd._returnedVerification();

  /* */

  try
  {
    o2 = Object.create( null );
    o2.accuracy = accuracy;
    if( _.mapIs( options ) )
    _.mapExtend( o2, options )
    else if( _.numberIs( options ) )
    o2.accuracy = options;
    else _.assert( options === undefined );
    accuracy = o2.accuracy;
    outcome = _.entityEquivalent( got, expected, o2 );
  }
  catch( err )
  {
    trd.exceptionReport
    ({
      err : err,
    });
    return false;
  }

  /* */

  if( arguments.length !== 2 && arguments.length !== 3 )
  {
    outcome = false;

    trd.exceptionReport
    ({
      err : '"equivalent" expects two arguments',
      level : 2,
    });

    return outcome;
  }

  /* */

  if( !o2.it || o2.it.lastPath === undefined )
  {
    outcome = false;
    trd.exceptionReport
    ({
      err : 'Something wrong with entityIdentical, iterator misses lastPath',
      level : 2,
    });
    return outcome;
  }

  /* */

  trd._outcomeReportCompare
  ({
    outcome : outcome,
    got : got,
    expected : expected,
    path : o2.it.lastPath,
    usingExtraDetails : 1,
    accuracy : accuracy,
    interruptible : 1,
    strictString : 0,
  });

  return outcome;
}

//

/**
 * Checks if test doesn't pass a specified condition by deep soft comparsing result of code execution( got )
 * with target( expected ). Uses recursive comparsion for objects, arrays and array-like objects. Two entities are not equivalent if
 * difference between their values are bigger than ( accuracy ). Example: ( got - expected ) > ( accuracy ).
 * If entity( got ) is not equivalent to entity( expected ) test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {*} got - Source entity.
 * @param {*} expected - Target entity.
 * @param {*} [ accuracy=1e-7 ] - Maximal distance between two values.
 *
 * @example
 * function sometest( test )
 * {
 *  test.case = 'single number';
 *  let got = 0.5;
 *  let expected = 1;
 *  let accuracy = 0.5;
 *  test.equivalent( got, expected, accuracy );//returns true
 *
 *  test.case = 'single number';
 *  let got = 0.5;
 *  let expected = 2;
 *  let accuracy = 0.5;
 *  test.equivalent( got, expected, accuracy );//returns false
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method notEquivalent
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function notEquivalent( got, expected, options )
{
  let trd = this;
  let accuracy = trd.accuracyEffective;
  let o2, outcome;

  trd._returnedVerification();

  /* */

  try
  {
    o2 = Object.create( null );
    o2.accuracy = accuracy;
    if( _.mapIs( options ) )
    _.mapExtend( o2, options )
    else if( _.numberIs( options ) )
    o2.accuracy = options;
    else _.assert( options === undefined );
    accuracy = o2.accuracy;
    outcome = !_.entityEquivalent( got, expected, o2 );
  }
  catch( err )
  {
    trd.exceptionReport
    ({
      err : err,
    });
    return false;
  }

  /* */

  if( arguments.length !== 2 && arguments.length !== 3 )
  {
    outcome = false;

    trd.exceptionReport
    ({
      err : '"notEquivalent" expects two arguments',
      level : 2,
    });

    return outcome;
  }

  /* */

  if( !o2.it || o2.it.lastPath === undefined )
  {
    outcome = false;

    trd.exceptionReport
    ({
      err : 'Something wrong with entityIdentical, iterator misses lastPath',
      level : 2,
    });

    return outcome;
  }

  /* */

  trd._outcomeReportCompare
  ({
    outcome : outcome,
    got : got,
    expected : expected,
    path : o2.it.lastPath,
    usingExtraDetails : 1,
    accuracy : accuracy,
    interruptible : 1,
    strictString : 0,
  });

  return outcome;
}


//

/**
 * Checks if test passes a specified condition by deep contains comparsing result of code execution( got )
 * with target( expected ). Uses recursive comparsion for objects, arrays and array-like objects.
 * If entity( got ) contains keys/values from entity( expected ) or they are indentical test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {*} got - Source entity.
 * @param {*} expected - Target entity.
 *
 * @example
 * function sometest( test )
 * {
 *  test.case = 'array';
 *  let got = [ 0, 1, 2 ];
 *  let expected = [ 0 ];
 *  test.contains( got, expected );//returns true
 *
 *  test.case = 'array';
 *  let got = [ 0, 1, 2 ];
 *  let expected = [ 4 ];
 *  test.contains( got, expected );//returns false
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method contains
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function contains( got, expected )
{
  let trd = this;
  let o2, outcome;

  trd._returnedVerification();

  /* */

  try
  {
    o2 = Object.create( null );
    outcome = _.entityContains( got, expected, o2 );
  }
  catch( err )
  {
    trd.exceptionReport
    ({
      err : err,
    });
    return false;
  }

  /* */

  if( arguments.length !== 2 )
  {
    outcome = false;

    trd.exceptionReport
    ({
      err : '"contains" expects two arguments',
      level : 2,
    });

    return outcome;
  }

  /* */

  if( !o2.it || o2.it.lastPath === undefined )
  {
    outcome = false;

    trd.exceptionReport
    ({
      err : 'Something wrong with entityIdentical, iterator misses lastPath',
      level : 2,
    });

    return outcome;
  }

  /* */

  trd._outcomeReportCompare
  ({
    outcome : outcome,
    got : got,
    expected : expected,
    path : o2.it.lastPath,
    usingExtraDetails : 1,
    interruptible : 1,
    strictString : 0,
  });

  /* */

  return outcome;
}

//

// function setsAreIdentical( got, expected )
// {
//   let trd = this;
//   let o2, outcome;
//
//   /* */
//
//   try
//   {
//     outcome = _.arraySetIdentical( got, expected );
//   }
//   catch( err )
//   {
//     trd.exceptionReport
//     ({
//       err : err,
//     });
//     return false;
//   }
//
//   /* */
//
//   if( arguments.length !== 2 )
//   {
//     outcome = false;
//
//     trd.exceptionReport
//     ({
//       err : '"identical" expects two arguments',
//       level : 2,
//     });
//
//     return outcome;
//   }
//
//   /* */
//
//   trd._outcomeReportCompare
//   ({
//     outcome : outcome,
//     got : got,
//     expected : expected,
//     // path : o2.it.lastPath,
//     usingExtraDetails : 1,
//   });
//
//   /* */
//
//   return outcome;
// }

//

/**
 * Checks if test passes a specified condition by deep contains comparsing result of code execution( got )
 * with target( expected ).
 * If value of( got ) is greater than value of( than ) test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {*} got - First entity.
 * @param {*} than - Second entity.
 *
 * @example
 * function sometest( test )
 * {
 *  test.gt( 1, 2 );//returns false
 *  test.gt( 2, 1 );//returns true
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method gt
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function gt( got, than )
{
  let trd = this;

  trd._returnedVerification();

  if( _.bigIntIs( got ) || _.bigIntIs( than ) )
  {
    got = BigInt( got );
    than = BigInt( than );
  }

  let outcome = got > than;
  let diff = got - than;

  /* */

  if( arguments.length !== 2 )
  {
    outcome = false;

    trd.exceptionReport
    ({
      err : '"gt" expects two arguments',
      level : 2,
    });

    return outcome;
  }

  /* */

  trd._outcomeReportCompare
  ({
    outcome : outcome,
    got : got,
    expected : than,
    nameOfPositiveExpected : 'greater than',
    nameOfNegativeExpected : 'not greater than',
    diff : diff,
    usingExtraDetails : 1,
    interruptible : 1,
  });

  return outcome;
}

//

/**
 * Checks if test passes a specified condition by deep contains comparsing result of code execution( got )
 * with target( expected ).
 * If value of( got ) is greater than or equal to value of( than ) test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {*} got - First entity.
 * @param {*} than - Second entity.
 *
 * @example
 * function sometest( test )
 * {
 *  test.ge( 1, 2 );//returns false
 *  test.ge( 2, 2 );//returns true
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method ge
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function ge( got, than )
{
  let trd = this;

  trd._returnedVerification();

  if( _.bigIntIs( got ) || _.bigIntIs( than ) )
  {
    got = BigInt( got );
    than = BigInt( than );
  }

  let greater = got > than;
  let outcome = got >= than;
  let diff = got - than;

  /* */

  if( arguments.length !== 2 )
  {
    outcome = false;

    trd.exceptionReport
    ({
      err : '"ge" expects two arguments',
      level : 2,
    });

    return outcome;
  }

  /* */

  trd._outcomeReportCompare
  ({
    outcome : outcome,
    got : got,
    expected : than,
    nameOfPositiveExpected : greater ? 'greater than' : 'identical with',
    nameOfNegativeExpected : 'not greater neither identical with',
    diff : diff,
    usingExtraDetails : 1,
    interruptible : 1,
  });

  /* */

  return outcome;
}

//

/**
 * Checks if test passes a specified condition by deep contains comparsing result of code execution( got )
 * with target( expected ).
 * If value of( got ) is less than value of( than ) test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {*} got - First entity.
 * @param {*} than - Second entity.
 *
 * @example
 * function sometest( test )
 * {
 *  test.lt( 1, 2 );//returns true
 *  test.lt( 2, 2 );//returns false
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method lt
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function lt( got, than )
{
  let trd = this;

  trd._returnedVerification();

  if( _.bigIntIs( got ) || _.bigIntIs( than ) )
  {
    got = BigInt( got );
    than = BigInt( than );
  }

  let outcome = got < than;
  let diff = got - than;

  /* */

  if( arguments.length !== 2 )
  {
    outcome = false;

    trd.exceptionReport
    ({
      err : '"lt" expects two arguments',
      level : 2,
    });

    return outcome;
  }

  /* */

  trd._outcomeReportCompare
  ({
    outcome : outcome,
    got : got,
    expected : than,
    nameOfPositiveExpected : 'less than',
    nameOfNegativeExpected : 'not less than',
    diff : diff,
    usingExtraDetails : 1,
    interruptible : 1,
  });

  /* */

  return outcome;
}

//

/**
 * Checks if test passes a specified condition by deep contains comparsing result of code execution( got )
 * with target( expected ).
 * If value of( got ) is less or equal to value of( than ) test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {*} got - First entity.
 * @param {*} than - Second entity.
 *
 * @example
 * function sometest( test )
 * {
 *  test.le( 1, 2 );//returns true
 *  test.le( 2, 2 );//returns true
 *  test.le( 3, 2 );//returns false
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method le
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function le( got, than )
{
  let trd = this;

  trd._returnedVerification();

  if( _.bigIntIs( got ) || _.bigIntIs( than ) )
  {
    got = BigInt( got );
    than = BigInt( than );
  }

  let less = got < than;
  let outcome = got <= than;
  let diff = got - than;

  /* */

  if( arguments.length !== 2 )
  {
    outcome = false;

    trd.exceptionReport
    ({
      err : '"le" expects two arguments',
      level : 2,
    });

    return outcome;
  }

  /* */

  trd._outcomeReportCompare
  ({
    outcome : outcome,
    got : got,
    expected : than,
    nameOfPositiveExpected : less ? 'less than' : 'identical with',
    nameOfNegativeExpected : 'not less neither identical with',
    diff : diff,
    usingExtraDetails : 1,
    interruptible : 1,
  });

  /* */

  return outcome;
}

// --
// shoulding
// --

function _shouldDo( o )
{
  let trd = this;
  let second = 0;
  let reported = 0;
  let good = 1;
  let async = 0;
  let stack = _.introspector.stack([ 2, -1 ]);
  let logger = trd.logger;
  let err, arg;
  let con = new _.Consequence();

  trd._returnedVerification();

  if( !trd.shoulding )
  return con.take( null );

  try
  {
    _.routineOptions( _shouldDo, o );
    _.assert( arguments.length === 1, 'Expects single argument' );
    _.assert( o.args.length === 1 );
    _.assert( _.routineIs( o.args[ 0 ] ) );
  }
  catch( err )
  {
    err = _.errRestack( err, 3 );
    err = _._err
    ({
      args : [ err, '\nIllegal usage of should in', trd.absoluteName ],
    });
    err = trd.exceptionReport
    ({
      err : err,
    });
    debugger;
    con.error( err );
    if( !o.ignoringError && !o.expectingAsyncError && o.expectingSyncError )
    return false;
    else
    return con;
  }

  o.routine = o.args[ 0 ];
  let acheck = trd.checkCurrent();
  trd._inroutineCon.give( 1 );

  /* */

  let result;
  if( _.consequenceIs( o.routine ) )
  {
    result = o.routine;
  }
  else try
  {
    result = o.routine.call( this );
  }
  catch( _err )
  {
    return handleError( _err );
  }

  /* no sync error, but expected */

  if( !o.ignoringError && !o.expectingAsyncError && o.expectingSyncError && !err )
  return handleLackOfSyncError();

  /* */

  if( _.consequenceIs( result ) )
  handleAsyncResult()
  else
  handleSyncResult();

  /* */

  return con;

  /* */

  function handleError( _err )
  {

    err = _err;

    _.errAttend( err );

    if( o.ignoringError )
    {
      begin( 1 );
      trd._outcomeReportBoolean
      ({
        outcome : 1,
        msg : 'error throwen synchronously, ignored',
        stack : stack,
        selectMode : 'center'
      });
      end( 1, err );
      return con;
    }

    trd.exceptionReport
    ({
      err : err,
      sync : 1,
      considering : 0,
      outcome : o.expectingSyncError,
    });

    if( !o.ignoringError )
    {

      begin( o.expectingSyncError );

      if( o.expectingSyncError )
      {

        trd._outcomeReportBoolean
        ({
          outcome : o.expectingSyncError,
          msg : 'error thrown synchronously as expected',
          stack : stack,
          selectMode : 'center',
        });

      }
      else
      {

        trd._outcomeReportBoolean
        ({
          outcome : o.expectingSyncError,
          msg : 'error thrown synchronously, what was not expected',
          stack : stack,
          selectMode : 'center',
        });

      }

      end( o.expectingSyncError, err );

      if( !o.ignoringError && !o.expectingAsyncError && o.expectingSyncError )
      return err;
      else
      return con;
    }

  }

  /* */

  function handleLackOfSyncError()
  {
    begin( 0 );

    let msg = 'Error not thrown synchronously, but expected';

    trd._outcomeReportBoolean
    ({
      outcome : 0,
      msg : msg,
      stack : stack,
      selectMode : 'center',
    });

    end( 0, _.err( msg ) );

    return false;
  }

  /* */

  function handleAsyncResult()
  {

    debugger;
    // let stack = _.introspector.stack([ 3, Infinity ]);
    trd.checkNext();
    async = 1;

    result.give( function( _err, _arg )
    {
      debugger;

      err = _err;
      arg = _arg;

      // if( !o.ignoringError && !reported )
      // // if( err )
      // reportAsync();

      if( !o.ignoringError && !reported )
      if( err && !o.expectingAsyncError )
      reportAsync();
      else if( !err && o.expectingAsyncError )
      reportAsync();

      if( _.errIs( err ) )
      _.errAttend( err );

      /* */

      if( !reported )
      // if( good )
      if( !o.allowingMultipleResources )
      _.time.out( 25, function() /* xxx : refactor that, use time out or test routine */
      {

        if( result.resourcesGet().length )
        if( reported )
        {
          _.assert( !good );
        }
        else
        {

          begin( 0 );
          debugger;

          _.assert( !reported );

          trd._outcomeReportBoolean
          ({
            outcome : 0,
            msg : 'Got more than one message',
            stack : stack,
          });

          end( 0, _.err( msg ) );
        }

        if( !reported )
        reportAsync();

        return null;
      });

    });

    /* */

    if( !o.allowingMultipleResources )
    handleSecondResource();

  }

  /* */

  function handleSecondResource()
  {
    if( reported && !good )
    return;

    result.finally( gotSecondResource );

    let r = result.orKeepingSplit([ trd._timeLimitCon, wTester._cancelCon ]);
    r.finally( ( err, arg ) =>
    {
      if( result.competitorHas( gotSecondResource ) )
      result.competitorsCancel( gotSecondResource );
      if( err )
      throw err;
      return arg;
    });

  }

  /* */

  function gotSecondResource( err, arg )
  {
    if( reported && !good )
    return null;

    begin( 0 );

    second = 1;
    let msg = 'Got more than one message';

    trd._outcomeReportBoolean
    ({
      outcome : 0,
      msg : msg,
      stack : stack,
    });

    end( 0, _.err( msg ) );

    if( err )
    throw err;
    return arg;
  }

  /* */

  function handleSyncResult()
  {

    if( ( o.expectingAsyncError || o.expectingSyncError ) && !err )
    {
      begin( 0 );

      let msg = 'Error not thrown asynchronously, but expected';
      if( o.expectingAsyncError )
      msg = 'Error not thrown, but expected either synchronosuly or asynchronously';

      trd._outcomeReportBoolean
      ({
        outcome : 0,
        msg : msg,
        stack : stack,
        selectMode : 'center',
      });

      end( 0, _.err( msg ) );
    }
    else if( !o.expectingSyncError && !err )
    {
      begin( 1 );

      trd._outcomeReportBoolean
      ({
        outcome : 1,
        msg : 'no error thrown, as expected',
        stack : stack,
        selectMode : 'center',
      });

      end( 1, result );
    }
    else
    {
      debugger;
      _.assert( 0, 'unexpected' );
      trd.checkNext();
    }

  }

  /* */

  function begin( positive )
  {
    if( positive )
    _.assert( !reported );
    good = positive;

    if( reported || async )
    trd.checkRestore( acheck );

    logger.begin({ verbosity : positive ? -5 : -5+trd.negativity });
    logger.begin({ connotation : positive ? 'positive' : 'negative' });
  }

  /* */

  function end( positive, arg )
  {
    _.assert( arguments.length === 2, 'Expects exactly two arguments' );

    logger.end({ verbosity : positive ? -5 : -5+trd.negativity });
    logger.end({ connotation : positive ? 'positive' : 'negative' });

    if( reported )
    debugger;
    if( reported || async )
    trd.checkRestore();

    if( arg === undefined && !async )
    arg = null;

    if( positive )
    con.take( undefined, arg );
    else
    con.take( _.errAttend( arg ), undefined );

    if( !reported )
    trd._inroutineCon.take( null );

    reported = 1;
  }

  /* */

  function reportAsync()
  {

    /* yyy */
    if( trd._returned )
    return;
    if( reported )
    return;

    if( o.ignoringError )
    {
      begin( 1 );

      trd._outcomeReportBoolean
      ({
        outcome : 1,
        msg : 'got single message',
        stack : stack,
        selectMode : 'center'
      });

      end( 1, err ? err : arg );
    }
    else if( err !== undefined )
    {
      begin( o.expectingAsyncError );

      trd.exceptionReport
      ({
        err : err,
        sync : 0,
        considering : 0,
        outcome : o.expectingAsyncError,
      });

      if( o.expectingAsyncError )
      trd._outcomeReportBoolean
      ({
        outcome : o.expectingAsyncError,
        msg : 'error thrown asynchronously as expected',
        stack : stack,
        selectMode : 'center'
      });
      else
      trd._outcomeReportBoolean
      ({
        outcome : o.expectingAsyncError,
        msg : 'error thrown asynchronously, not expected',
        stack : stack,
        selectMode : 'center'
      });

      end( o.expectingAsyncError, err );
    }
    else
    {
      begin( !o.expectingAsyncError );

      let msg = 'error was not thrown asynchronously, but expected';
      if( !o.expectingAsyncError && !o.expectingSyncError && good )
      msg = 'error was not thrown as expected';

      trd._outcomeReportBoolean
      ({
        outcome : !o.expectingAsyncError,
        msg : msg,
        stack : stack,
        selectMode : 'center'
      });

      if( o.expectingAsyncError )
      end( !o.expectingAsyncError, _._err({ args : [ msg ], catchCallsStack : stack }) );
      else
      end( !o.expectingAsyncError, arg );

    }

  }

}

_shouldDo.defaults =
{
  args : null,
  expectingSyncError : 1,
  expectingAsyncError : 1,
  ignoringError : 0,
  allowingMultipleResources : 0,
}

//

/**
 * @summary Error throwing test. Executes provided `routine` and checks if it throws an Error asynchrounously.
 * @description
 * Provided routines should return instance of `wConsequence`. Also routine can accepts `wConsequence` instance as argument.
 * If check is positive then test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {Function|wConsequence} routine `wConsequence` instance or routine that returns it.
 *
 * @example
 * function sometest( test )
 * {
 *  test.shouldThrowErrorAsync( () => _.time.outError( 1000 ) );//returns true
 *  test.shouldThrowErrorAsync( () => _.time.out( 1000 ) );//returns false
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method shouldThrowErrorAsync
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function shouldThrowErrorAsync( routine )
{
  let trd = this;

  return trd._shouldDo
  ({
    args : arguments,
    expectingSyncError : 0,
    expectingAsyncError : 1,
  });

}

//

/**
 * @summary Error throwing test. Executes provided `routine` and checks if it throws an Error synchrounously.
 * @description
 * If check is positive then test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {Function} routine Routine to execute.
 *
 * @example
 * function sometest( test )
 * {
 *  test.shouldThrowErrorSync( () => { throw 1 } );//returns true
 *  test.shouldThrowErrorSync( () => { console.log( 1 ) } );//returns false
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method shouldThrowErrorSync
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function shouldThrowErrorSync( routine )
{
  let trd = this;

  return trd._shouldDo
  ({
    args : arguments,
    expectingSyncError : 1,
    expectingAsyncError : 0,
  });

}

//

/**
 * Error throwing test. Expects one argument( routine ) - function to call or wConsequence instance.
 * If argument is a function runs it and checks if it throws an error. Otherwise if argument is a consequence  checks if it has a error message.
 * If its not a error or consequence contains more then one message test is failed. After check function reports result of test to the testing system.
 * If test is failed function also outputs additional information. Returns wConsequence instance to perform next call in chain.
 *
 * @param {Function|wConsequence} routine - Funtion to call or wConsequence instance.
 *
 * @example
 * function sometest( test )
 * {
 *  test.case = 'shouldThrowErrorSync';
 *  test.shouldThrowErrorSync( function()
 *  {
 *    throw _.err( 'Error' );
 *  });
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @example
 * function sometest( test )
 * {
 *  let consequence = new _.Consequence().take( null );
 *  consequence
 *  .ifNoErrorThen( function( arg )
 *  {
 *    test.case = 'shouldThrowErrorSync';
 *    let con = new _.Consequence( )
 *    .error( _.err() ); //wConsequence instance with error message
 *    return test.shouldThrowErrorSync( con );//test passes
 *  })
 *  .ifNoErrorThen( function( arg )
 *  {
 *    test.case = 'shouldThrowError2';
 *    let con = new _.Consequence( )
 *    .error( _.err() )
 *    .error( _.err() ); //wConsequence instance with two error messages
 *    return test.shouldThrowErrorSync( con ); //test fails
 *  });
 *
 *  return consequence;
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @throws {Exception} If passed argument is not a Routine.
 * @method shouldThrowErrorSync
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function shouldThrowErrorOfAnyKind( routine )
{
  let trd = this;

  return trd._shouldDo
  ({
    args : arguments,
    expectingSyncError : 1,
    expectingAsyncError : 1,
  });

}

//

/**
 * @summary Error throwing test. Executes provided `routine` and checks if doesn't throw an Error synchrounously or asynchrounously.
 * @description
 * If check is positive then test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {Function} routine Routine to execute.
 *
 * @example
 * function sometest( test )
 * {
 *  test.mustNotThrowError( () => { throw 1 } );//returns false
 *  test.mustNotThrowError( () => _.time.out( 1000 ) );//returns true
 *  test.mustNotThrowError( () => _.time.outError( 1000 ) );//returns false
 *  test.mustNotThrowError( () => { console.log( 1 ) } );//returns true
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method mustNotThrowError
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function mustNotThrowError( routine )
{
  let trd = this;

  return trd._shouldDo
  ({
    args : arguments,
    ignoringError : 0,
    expectingSyncError : 0,
    expectingAsyncError : 0,
  });

}

//

/**
 * @summary `wConsequence` messaging test. Executes provided `routine` and checks if returned `wConsequence` gives only one message.
 * @description
 * If check is positive then test is passed successfully. After check function reports result of test
 * to the testing system. If test is failed function also outputs additional information.
 * Returns true if test is done successfully, otherwise false.
 *
 * @param {Function} routine Routine to execute.
 *
 * @example
 * function sometest( test )
 * {
 *  test.returnsSingleResource( () => _.Consequence().take( null ) );//returns true
 *  test.returnsSingleResource( () => _.Consequence().take( null ).take( null ) );//returns false
 * }
 * wTester.test( { name : 'test', tests : { sometest : sometest } } );
 *
 * @throws {Exception} If no arguments provided.
 * @method returnsSingleResource
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

function returnsSingleResource( routine )
{
  let trd = this;

  return trd._shouldDo
  ({
    args : arguments,
    ignoringError : 1,
    expectingSyncError : 0,
    expectingAsyncError : 0,
  });

}

//

function assetFor( a )
{
  let trd = this;
  let context = trd.context;
  let suite = trd.suite;

  if( !_.mapIs( a ) )
  {
    if( _.boolIs( arguments[ 0 ] ) )
    a = { originalAssetPath : arguments[ 0 ] }
    else
    a = { assetName : arguments[ 0 ] }
  }

  _.assert( a.trd === undefined );
  _.assert( a.suite === undefined );
  _.assert( a.routine === undefined );
  _.routineOptions( assetFor, a );

  a.trd = trd;
  a.suite = suite;
  a.routine = trd.routine;
  if( !a.assetName )
  a.assetName = a.routine.name;

  _.sure( arguments.length === 0 || arguments.length === 1 );
  _.sure( _.mapIs( a ) );
  _.sure( _.routineIs( a.routine ) );
  _.sure( _.strDefined( a.assetName ) );
  _.sure( _.strDefined( context.suiteTempPath ) || _.strDefined( a.routinePath ), `Test suite's context should have defined path to suite temp directory {- suiteTempPath -}. But test suite ${suite.name} does not have.` );
  _.sure( context.assetsOriginalSuitePath === null || _.strDefined( context.assetsOriginalSuitePath ), `Test suite's context should have defined path to original asset directory {- assetsOriginalSuitePath -}. But test suite ${suite.name} does not have.` );
  _.sure( context.appJsPath === null || _.strDefined( context.appJsPath ), `Test suite's context should have defined path to default JS file {- appJsPath -}. But test suite ${suite.name} does not have.` );

  Object.setPrototypeOf( a, context );

  if( a.process === null )
  a.process = _testerGlobal_.wTools.process;
  if( a.fileProvider === null )
  {
    a.fileProvider = _.FileProvider.System({ providers : [] });
    _.FileProvider.Git().providerRegisterTo( a.fileProvider );
    _.FileProvider.Npm().providerRegisterTo( a.fileProvider );
    _.FileProvider.Http().providerRegisterTo( a.fileProvider );
    let defaultProvider = _.FileProvider.Default();
    defaultProvider.providerRegisterTo( a.fileProvider );
    a.fileProvider.defaultProvider = defaultProvider;
  }
  if( a.path === null )
  a.path = a.fileProvider.path || _testerGlobal_.wTools.uri;
  if( a.uri === null )
  a.uri = _testerGlobal_.wTools.uri || a.fileProvider.path;
  if( a.ready === null )
  a.ready = _.Consequence().take( null );

  if( _.boolLike( a.originalAssetPath ) && a.originalAssetPath )
  a.originalAssetPath = null
  if( a.originalAssetPath === null && context.assetsOriginalSuitePath )
  a.originalAssetPath = a.path.join( context.assetsOriginalSuitePath, a.assetName );
  if( a.routinePath === null )
  a.routinePath = a.path.join( context.suiteTempPath, a.routine.name );

  if( a.abs === null )
  a.abs = abs_functor( a.routinePath );
  if( a.rel === null )
  a.rel = rel_functor( a.routinePath );
  if( a.originalAbs === null && a.originalAssetPath )
  a.originalAbs = abs_functor( a.originalAssetPath );
  if( a.originalRel === null && a.originalAssetPath )
  a.originalRel = rel_functor( a.originalAssetPath );

  if( a.reflect === null )
  a.reflect = reflect;
  if( a.program === null )
  a.program = program;

  if( a.shell === null )
  a.shell = a.process.starter
  ({
    currentPath : a.routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 1,
    ready : a.ready,
    mode : 'shell',
  })

  if( a.shellNonThrowing === null )
  a.shellNonThrowing = a.process.starter
  ({
    currentPath : a.routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : a.ready,
    mode : 'shell',
  })

  if( a.appStart === null )
  a.appStart = a.process.starter
  ({
    execPath : context.appJsPath || null,
    currentPath : a.routinePath,
    outputCollecting : 1,
    throwingExitCode : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'fork',
  })

  if( a.appStartNonThrowing === null )
  a.appStartNonThrowing = a.process.starter
  ({
    execPath : context.appJsPath || null,
    currentPath : a.routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : a.ready,
    mode : 'fork',
  })

  if( a.anotherStart === null )
  a.anotherStart = a.process.starter
  ({
    currentPath : a.routinePath,
    outputCollecting : 1,
    throwingExitCode : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'fork',
  })

  if( a.anotherStartNonThrowing === null )
  a.anotherStartNonThrowing = a.process.starter
  ({
    currentPath : a.routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : a.ready,
    mode : 'fork',
  })

  if( a.find === null )
  a.find = a.fileProvider.filesFinder
  ({
    withTerminals : 1,
    withDirs : 1,
    withStem : 1,
    allowingMissed : 1,
    maskPreset : 0,
    outputFormat : 'relative',
    filter :
    {
      recursive : 2,
      maskAll :
      {
        excludeAny : [ /(^|\/)\.git($|\/)/, /(^|\/)\+/ ],
      },
      maskTransientAll :
      {
        excludeAny : [ /(^|\/)\.git($|\/)/, /(^|\/)\+/ ],
      },
    },
  });

  if( a.findAll === null )
  a.findAll = a.fileProvider.filesFinder
  ({
    withTerminals : 1,
    withDirs : 1,
    withStem : 1,
    withTransient : 1,
    allowingMissed : 1,
    maskPreset : 0,
    outputFormat : 'relative',
  });

  if( a.originalAssetPath )
  _.sure( a.fileProvider.isDir( a.originalAssetPath ), `Expects directory ${a.originalAssetPath} exists. Make one or change {- assetsOriginalSuitePath -}` );

  // if( !_.mapHasAll( context, a ) )
  // {
  //   let fields = _.mapBut( a, context );
  //   throw _.err( `Context of test suite which use routine \`assetFor\` should have such fields : \n${_.mapKeys( fields ).join( ', ' )}` );
  // }

  program.defaults =
  {
    routine : null,
    locals : null,
  }

  return a;

  /**/

  function abs_functor( routinePath )
  {
    _.assert( _.strIs( routinePath ) );
    _.assert( arguments.length === 1 );
    return function abs( filePath )
    {
      if( arguments.length === 1 && filePath === null )
      return filePath;
      let args = _.longSlice( arguments );
      args.unshift( routinePath );
      return a.uri.s.join.apply( a.uri.s, args );
    }
  }

  /**/

  function rel_functor( routinePath )
  {
    _.assert( _.strIs( routinePath ) );
    _.assert( arguments.length === 1 );
    return function rel( filePath )
    {
      _.assert( arguments.length === 1 );
      if( filePath === null )
      return filePath;
      if( _.arrayIs( filePath ) || _.mapIs( filePath ) )
      {
        return _.filter( filePath, ( filePath ) => rel( filePath ) );
      }
      if( a.uri.isRelative( filePath ) && !a.uri.isRelative( routinePath ) )
      return filePath;
      return a.uri.s.relative.apply( a.uri.s, [ routinePath, filePath ] );
    }
  }

  /* */

  function reflect()
  {
    _.assert( arguments.length === 0 );
    a.fileProvider.filesDelete( a.routinePath );
    if( a.originalAssetPath === false )
    a.fileProvider.dirMake( a.routinePath );
    else
    a.fileProvider.filesReflect({ reflectMap : { [ a.originalAssetPath ] : a.routinePath } });
  }

  /**/

  function program( o )
  {
    let a = this;

    if( !_.mapIs( o ) )
    o = { routine : o }

    _.routineOptions( program, o );

    let o2 = _.program.write
    ({
      routine : o.routine,
      locals : o.locals,
      tempPath : a.abs( '.' ),
    });

    logger.log( _.strLinesNumber( o2.sourceCode ) );

    return o2.programPath;
  }

  /**/

}

assetFor.defaults =
{

  assetName : null,

  process : null,
  fileProvider : null,
  path : null,
  uri : null,
  ready : null,

  originalAssetPath : null,
  originalAbs : null,
  originalRel : null,
  routinePath : null,
  abs : null,
  rel : null,
  reflect : null,
  program : null,
  shell : null,
  shellNonThrowing : null,
  appStart : null,
  appStartNonThrowing : null,
  anotherStart : null,
  anotherStartThrowing : null,
  find : null,
  findAll : null,

}

// --
// let
// --

let descriptionSymbol = Symbol.for( 'description' );
let accuracySymbol = Symbol.for( 'accuracy' );
let accuracyEffectiveSymbol = Symbol.for( 'accuracyEffective' );
let timeOutSymbol = Symbol.for( 'timeOut' );
let rapiditySymbol = Symbol.for( 'rapidity' );
let usingSourceCodeSymbol = Symbol.for( 'usingSourceCode' );

/**
 * @typedef {Object} RoutineFields
 * @property {Boolean} experimental
 * @property {Number} routineTimeOut
 * @property {Number} timeOut
 * @property {Number} accuracy
 * @property {Number} rapidity
 * @property {Boolean} usingSourceCode
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

let RoutineFields =
{
  experimental : 'experimental',
  routineTimeOut : 'timeOut',
  timeOut : 'timeOut',
  accuracy : 'accuracy',
  rapidity : 'rapidity',
  usingSourceCode : 'usingSourceCode',
  description : 'routineDescription', /* qqq : implement separate test routine per each test routine option */
}

/**
 * @typedef {Object} TestRoutineFields
 * @property {String} name
 * @property {String} description
 * @property {Number} accuracy
 * @property {Number} rapidity=3
 * @property {Number} timeOut
 * @property {Boolean} experimental
 * @property {Boolean} usingSourceCode
 * @class wTestRoutineDescriptor
 * @module Tools/atop/Tester
 */

// --
// relations
// --

let Composes =
{
  name : null,
  description : '',
  accuracy : null,
  rapidity : 0,
  timeOut : null,
  experimental : 0,
  usingSourceCode : null,
  routineDescription : null,
}

let Aggregates =
{
}

let Associates =
{
  suite : null,
  routine : null,
}

let Restricts =
{

  _formed : 0,
  _checkIndex : 1,
  _checksStack : _.define.own( [] ),
  _groupOpenedWithCase : 0,
  _testCheckPassesOfTestCase : 0,
  _testCheckFailsOfTestCase : 0,
  _groupError : null,
  _groupsStack : _.define.own( [] ),

  _testRoutineBeginTime : null,
  _returned : null,
  _appExitCode : null,
  _returnCon : null,
  _timeLimitCon : null,
  _timeLimitErrorCon : null,
  report : null,

}

let Statics =
{
  RoutineFields,
  strictEventHandling : 0,
}

let Events =
{
}

let Forbids =
{
  _cancelCon : '_cancelCon',
  _storedStates : '_storedStates',
  _currentRoutineFails : '_currentRoutineFails',
  _currentRoutinePasses : '_currentRoutinePasses',
}

let Accessors =
{

  description : 'description',
  will : 'will',
  case : 'case',
  accuracy : 'accuracy',
  timeOut : 'timeOut',
  rapidity : 'rapidity',
  usingSourceCode : 'usingSourceCode',

  group : { readOnly : 1 },
  descriptionFull : { readOnly : 1 },
  descriptionWithName : { readOnly : 1 },
  accuracyEffective : { readOnly : 1 },
  runnable : { readOnly : 1 },

  qualifiedName : { readOnly : 1 },
  decoratedQualifiedName : { readOnly : 1 },
  absoluteName : { readOnly : 1 },
  decoratedAbsoluteName : { readOnly : 1 },

}

// --
// declare
// --

let Extend =
{

  // inter

  init,
  form,
  _fieldsForm,

  // accessor

  _accuracySet,
  _accuracyGet,
  _accuracyEffectiveGet,
  _accuracyChange,

  _timeOutGet,
  _timeOutSet,

  _rapidityGet,
  _rapiditySet,

  _usingSourceCodeGet,
  _usingSourceCodeSet,

  // run

  _run,
  _runBegin,
  _runEnd,
  _runFinally,

  _runInterruptMaybe,
  _returnedVerification,
  _runnableGet,
  _timeOutError,
  cancel,

  // check description

  _willGet : _descriptionGet,
  _willSet : _descriptionSet,
  _descriptionGet,
  _descriptionSet,
  _descriptionChange,
  _descriptionFullGet,
  _descriptionWithNameGet,

  // checks group

  _groupGet,
  groupOpen,
  groupClose,
  open : groupOpen,
  close : groupClose,
  _groupChange,
  _groupTestEnd,
  _groupingErorr,

  _caseGet,
  _caseSet,
  _caseClose,
  _caseChange,

  // name

  qualifiedNameGet,
  decoratedQualifiedNameGet,
  absoluteNameGet,
  decoratedAbsoluteNameGet,

  // check

  checkCurrent,
  checkNext,
  checkStore,
  checkRestore,

  // consider

  _testCheckConsider,
  _testCaseConsider,
  _exceptionConsider,

  // report

  _outcomeReport,
  _outcomeReportBoolean,
  _outcomeReportCompare,
  exceptionReport,

  _reportBegin,
  _reportEnd,
  _reportIsPositive,
  _reportTextForTestCheck,

  // checker

  is,
  isNot,
  // isNotError, /* qqq xxx : deprecate */

  identical,
  notIdentical,
  equivalent,
  notEquivalent,
  contains,
  // setsAreIdentical, /* qqq xxx : deprecate */

  il : identical,
  ni : notIdentical,
  et : equivalent,
  ne : notEquivalent,

  gt : gt,
  ge : ge,
  lt : lt,
  le : le,

  // shoulding

  _shouldDo,

  shouldThrowErrorSync,
  shouldThrowErrorAsync,
  shouldThrowErrorOfAnyKind,
  mustNotThrowError,
  returnsSingleResource,

  // asset

  assetFor,

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
  extend : Extend,
});

_.Copyable.mixin( Self );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;
wTesterBasic[ Self.shortName ] = Self;

})();
