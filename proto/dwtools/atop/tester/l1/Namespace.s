( function _Namespace_s_() {

'use strict';

let _global = _global_;
let _ = _global_.wTools;
let Self = _.test = _.test || Object.create( null );

// --
// UI Testing
// --

function fileDrop( o )
{
  _.assert( arguments.length === 1 );
  _.routineOptions( fileDrop, o );
  _.assert( _.strIs( o.filePath ) || _.arrayIs( o.filePath ) );
  _.assert( _.strIs( o.targetSelector ) )
  _.assert( _.strIs( o.fileInputId ) )
  _.assert( o.library === 'puppeteer' || o.library === 'spectron' );
  _.assert( _.objectIs( o.page ) )

  let ready = new _.Consequence().take( null );
  let filePath = _.path.s.nativize( _.arrayAs( o.filePath ) );

  if( o.library === 'puppeteer' )
  fileDropPuppeteer();
  else if( o.library === 'spectron' )
  fileDropSpectron();

  return ready;

  /* */

  function fileDropPuppeteer()
  {
    ready
    .then( () => o.page.evaluate( fileInputCreate, o.fileInputId, o.targetSelector, filePath ) )
    .then( () => o.page.$(`#${ o.fileInputId }`) )
    .then( ( fileInput ) => fileInput.uploadFile.apply( fileInput, filePath ) )
  }

  function fileDropSpectron()
  {
    ready
    .then( () => o.page.execute( fileInputCreate, o.fileInputId, o.targetSelector ) )
    // .then( () => _.Consequence.And( filePath.map( path => _.Consequence.From( o.page.uploadFile( path ) ) ) ) )
    .then( () => o.page.$(`#${o.fileInputId}`).addValue( filePath.join( '\n' ) ) )
  }

  function fileInputCreate( fileInputId, targetSelector, filePaths )
  { 
    let input = document.createElement( 'input' );
    input.id = fileInputId;
    input.type = 'file';
    input.multiple = 'multiple';
    input.onchange = ( e ) =>
    {  
      let event = new Event( 'drop' );
      if( filePaths )
      filePaths.forEach( ( path, i ) => 
      {
        e.target.files[ i ].path = path;
      })
      Object.assign( event, { dataTransfer: { files: e.target.files } } )
      document.querySelector( targetSelector ).dispatchEvent( event );
    }
    document.body.appendChild( input );
  }
}

fileDrop.defaults =
{
  filePath : null,
  targetSelector : null,
  fileInputId : null,
  page : null,
  library : null
}

//

function eventDispatch( o )
{
  _.assert( arguments.length === 1 );
  _.routineOptions( eventDispatch, o );
  _.assert( _.strIs( o.targetSelector ) )
  _.assert( _.strIs( o.eventType ) )
  _.assert( _.objectIs( o.eventData ) || o.eventData === null )
  _.assert( o.library === 'puppeteer' || o.library === 'spectron' );
  _.assert( _.objectIs( o.page ) )

  if( o.eventData === null )
  o.eventData = {};

  let ready = new _.Consequence().take( null );

  if( o.library === 'puppeteer' )
  eventDispatchPuppeteer();
  else if( o.library === 'spectron' )
  eventDispatchSpectron();

  return ready;

  /* */

  function eventDispatchPuppeteer()
  {
    ready.then( () => o.page.evaluate( _eventDispatch, o.eventType, o.eventData, o.targetSelector ) )
  }

  function eventDispatchSpectron()
  {
    ready.then( () => o.page.execute( _eventDispatch, o.eventType, o.eventData, o.targetSelector ) )
  }

  function _eventDispatch( eventType, eventData, targetSelector )
  {
    let event = new Event( eventType );
    Object.assign( event, eventData )
    document.querySelector( targetSelector ).dispatchEvent( event );
  }
}

eventDispatch.defaults =
{
  targetSelector : null,
  eventType : null,
  eventData : null,
  page : null,
  library : null
}

//

function waitForVisibleInViewport( o ) 
{
  _.assert( arguments.length === 1 );
  _.routineOptions( waitForVisibleInViewport, o );
  _.assert( _.strIs( o.targetSelector ) )
  _.assert( _.numberIs( o.timeOut ) )
  _.assert( o.library === 'puppeteer' || o.library === 'spectron' );
  _.assert( _.objectIs( o.page ) )
  
  let ready = _.time.outError( o.timeOut );
  return _waitForVisibleInViewport();
  
  /* */
  
  async function _waitForVisibleInViewport() 
  { 
    let element = await o.page.$( o.targetSelector );
    if( element ) 
    {
      let isIntersectingViewport;
      if( o.library === 'puppeteer' )
      isIntersectingViewport = await element.isIntersectingViewport();
      else
      isIntersectingViewport = await o.page.isVisibleWithinViewport( o.targetSelector );
      
      if( isIntersectingViewport ) 
      {
        ready.take( _.dont );
        await ready;
        ready.take( isIntersectingViewport );
        return ready;
      }
    }
    if( ready.resourcesCount() )
    return ready;
    return _waitForVisibleInViewport();
  }
}

waitForVisibleInViewport.defaults = 
{
  targetSelector : null,
  timeOut : 5000,
  page : null,
  library : null
}

let Fields =
{
}

let Routines =
{
  fileDrop,
  eventDispatch,
  waitForVisibleInViewport
}

_.mapExtend( Self, Fields );
_.mapExtend( Self, Routines );

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _;

})();
