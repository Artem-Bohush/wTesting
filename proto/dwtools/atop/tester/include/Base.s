(function _Base_s_() {

'use strict';

/* !!! try to tokenize the file */

if( typeof module !== 'undefined' )
{

  if( !_global_.wBase || _global_.__GLOBAL_WHICH__ !== 'real' )
  {
    let toolsPath = '../../../../dwtools/Tools.s';
    let _externalTools = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      _externalTools = 1;
      require( 'wTools' );
    }
    if( !_externalTools )
    require( toolsPath );
  }

  let _global = _global_;
  let _ = _global_.wTools;

  _.include( 'wLooker' );
  _.include( 'wSelector' );
  _.include( 'wEqualer' );
  _.include( 'wProcessWatcher' );
  _.include( 'wAppBasic' );
  _.include( 'wRoutineBasic' );
  _.include( 'wCopyable' );
  _.include( 'wInstancing' );
  _.includeFirst( 'wEventHandler', _.optional );
  _.include( 'wLogger' );
  _.include( 'wConsequence' );
  _.include( 'wFiles' );
  _.include( 'wColor' );
  _.include( 'wStringsExtra' );
  _.include( 'wCommandsAggregator' );

  // _.includeFirst( 'wScriptLauncher' );

  _.assert( !_realGlobal_.wTester || !_realGlobal_.wTester._isReal_, 'wTester is already included' );

}

})();
