// Standart Flutter Web Bootstrap
// HTML renderer kullanarak basit ve stabil başlatma

window.addEventListener('load', function () {
  if (!window._flutter || !window._flutter.loader) {
    console.error('Flutter loader not available');
    return;
  }

  console.log('Starting Flutter web app initialization...');
  
  // Inject environment variables from env.js
  if (window.ENV && window.ENV.FIREBASE_FX_PROXY_URL) {
    console.log('Firebase FX Proxy URL configured:', window.ENV.FIREBASE_FX_PROXY_URL);
  }

  // Standart Flutter loader configuration
  window._flutter.loader.load({
    serviceWorkerSettings: {
      serviceWorkerVersion: null,
    },
    onEntrypointLoaded: async function (engineInitializer) {
      try {
        console.log('Initializing Flutter engine...');
        
        // Standart engine initialization (multiView API kullanma)
        const appRunner = await engineInitializer.initializeEngine({
          hostElement: document.getElementById('flutter-host') || document.body,
        });
        
        console.log('Running Flutter app...');
        await appRunner.runApp();
        
        console.log('Flutter app started successfully');
        
        // Hide splash content after Flutter is ready
        setTimeout(() => {
          const splash = document.getElementById('splash-content');
          if (splash) {
            splash.classList.add('hidden');
            setTimeout(() => splash.remove(), 300);
          }
        }, 500);
        
      } catch (error) {
        console.error('Flutter initialization error:', error);
        console.error('Error stack:', error.stack);
      }
    }
  });
});
