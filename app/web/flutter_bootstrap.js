{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    const viewport = document.querySelector('meta[name="viewport"]');
    viewport.setAttribute('content', "width=device-width, initial-scale=1.0, viewport-fit=cover");
    self.window.__flutterState.push(viewport);    
  }
});
