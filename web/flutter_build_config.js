window._flutter = window._flutter || {};
window._flutter.buildConfig = {
  // Where Flutter should load app assets from
  assetBase: '/',
  // Where CanvasKit files are served from
  canvasKitBaseUrl: 'canvaskit/',
  // Available builds for the loader
  builds: [
    {
      compileTarget: 'dart2js',
      renderer: 'canvaskit',
      mainJsPath: 'main.dart.js'
    }
  ]
};
