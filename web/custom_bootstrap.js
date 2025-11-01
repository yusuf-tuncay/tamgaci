window.addEventListener('load', function () {
  if (!window._flutter || !window._flutter.loader) {
    console.error('Flutter loader not available');
    return;
  }

  window._flutter.loader.load({
    serviceWorkerSettings: null,
    config: {
      renderer: 'canvaskit',
      assetBase: '/',
      canvasKitBaseUrl: 'canvaskit/'
    },
    onEntrypointLoaded: async function (engineInitializer) {
      try {
        console.log('Engine initializer ready');
        const appRunner = await engineInitializer.initializeEngine({
          multiViewEnabled: true,
          useView: true
        });
        console.log('Engine initialized');
        const flutterApp = await appRunner.runApp();
        console.log('App runner invoked');
        const host = document.getElementById('flutter-host') || document.body;
        if (flutterApp && typeof flutterApp.addView === 'function') {
          try {
            flutterApp.addView({ hostElement: host });
            console.log('View attached to host');
            // Render kontrolü için timeout
            setTimeout(() => {
              const canvas = document.querySelector('canvas');
              const sceneHost = document.querySelector('flt-scene-host');
              if (!canvas || !sceneHost) {
                console.error('Canvas/SceneHost not created after attach. Canvas:', !!canvas, 'SceneHost:', !!sceneHost);
              } else {
                console.log('Canvas and SceneHost created successfully');
              }
            }, 2000);
          } catch (e) {
            console.error('Error attaching view:', e);
          }
        } else {
          console.warn('flutterApp.addView is not available', flutterApp);
        }
      } catch (e) {
        console.error('Flutter init failed:', e);
      }
    }
  });
});
