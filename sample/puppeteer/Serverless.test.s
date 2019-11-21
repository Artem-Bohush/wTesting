( function _Serverless_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( 'wTools' );
  _.include( 'wTesting' );
  _.include( 'wFiles' );

  var Puppeteer = require( 'puppeteer' );
}

var _global = _global_;
var _ = _global_.wTools;

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

async function loadLocalHtmlFile( test )
{
  let self = this;
  let routinePath = _.path.join( self.tempDir, test.name );
  let indexHtmlPath = _.path.join( routinePath, 'serverless/index.html' );

  _.fileProvider.filesReflect({ reflectMap : { [ self.assetDirPath ] : routinePath } })

  let browser = await Puppeteer.launch({ headless : true });
  let page = await browser.newPage();

  await page.goto( 'file:///D:/work/wTesting/sample/puppeteer/asset/serverless/index.html', { waitUntil : 'load' } );
    
  test.case = 'script and style files are loaded'
  
  var got = await page.evaluate( () => window.scriptLoaded )
  test.identical( got, true );
  
  var got = await page.evaluate( () => 
  {
    let p = document.querySelector( 'p' );
    let styles = window.getComputedStyle( p );
    return styles.getPropertyValue( 'color' )
  })
  test.identical( got, 'rgb(192, 192, 192)' );
  
  await browser.close();

  return null;
}

// --
// suite
// --

var Self =
{

  name : 'Visual.Puppeteer.Serverless',
  
  

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
    loadLocalHtmlFile
  }

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
