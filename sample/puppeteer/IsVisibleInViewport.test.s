( function _IsVisibleInViewport_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( 'wTools' );
  _.include( 'wTesting' );
  _.include( 'wFiles' );

  var Puppeteer = require( 'puppeteer' );
}

var _global = _global_;
var _ = _testerGlobal_.wTools;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;

  self.tempDir = _.path.pathDirTempOpen( _.path.join( __dirname, '../..'  ), 'Tester' );
  self.assetDirPath = _.path.join( __dirname, 'asset' );
}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.tempDir, 'Tester' ) )
  _.path.pathDirTempClose( self.tempDir );
}

// --
// tests
// --

async function isVisibleInViewport( test )
{
  let self = this;
  let routinePath = _.path.join( self.tempDir, test.name );
  let indexHtmlPath = _.path.join( routinePath, 'index.html' );

  _.fileProvider.filesReflect({ reflectMap : { [ self.assetDirPath ] : routinePath } })

  let browser = await Puppeteer.launch({ headless : true });
  let page = await browser.newPage();

  await page.goto( 'file:///' + _.path.nativize( indexHtmlPath ), { waitUntil : 'load' } );
  await _.test.waitForVisibleInViewport
  ({ 
    library : 'puppeteer', 
    page, 
    timeOut : 5000, 
    targetSelector : 'p' 
  });
  var got = await _.test.isVisibleWithinViewport
  ({ 
    library : 'puppeteer', 
    page,
    timeOut : 5000, 
    targetSelector : 'p' 
  });
  test.identical( got, true );
  
  await browser.close();

  return null;
}

// --
// suite
// --

var Self =
{

  name : 'Visual.Puppeteer.IsVisibleInViewport',
  
  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,
  routineTimeOut : 300000,

  context :
  {
    tempDir : null,
    assetDirPath : null,
  },

  tests :
  {
    isVisibleInViewport
  }

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
