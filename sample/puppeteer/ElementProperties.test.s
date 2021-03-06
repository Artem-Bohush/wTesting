( function _ElementProperties_test_s_( ) {

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

//

async function domElementProperties( test )
{
  let self = this;
  let routinePath = _.path.join( self.tempDir, test.name );
  let indexHtmlPath = _.path.join( routinePath, 'index.html' );

  _.fileProvider.filesReflect({ reflectMap : { [ self.assetDirPath ] : routinePath } })
  
  //Create browser and new page instance
  let browser = await Puppeteer.launch();
  let page = await browser.newPage();
  
  //Open test page
  let path = 'file:///' + _.path.nativize( indexHtmlPath );
  await page.goto( path, { waitUntil : 'load' } );
  
  //innerText
  var text = await page.$eval( 'p', ( e ) => e.innerText )
  test.identical( text, 'Hello world' );
  
  //outerHtml 
  var html = await page.$eval( 'p', ( e ) => e.outerHTML )
  test.identical( html, '<p>Hello world</p>' );
  
  //Elements position on page
  var element = await page.$( 'p' );
  var location = await element.boundingBox();
  test.gt( location.x, 0 );
  test.gt( location.y, 0 );

  //Close browser
  await browser.close();
  
  return null;
}

// --
// suite
// --

var Self =
{

  name : 'Visual.Puppeteer.ElementProperties',
  
  

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
    domElementProperties
  }

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
