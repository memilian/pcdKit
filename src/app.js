
export class App {

  primaryColor = '#838996';
  accentColor = '#289ADD';

  configureRouter(config, router) {
    config.title = 'PcdKit';
    config.map([
      { route: ['', 'home'], name: 'home',      moduleId: 'home',      nav: true, title: 'Home' },
      { route: ['editor'], name: 'editor',      moduleId: 'editor',      nav: true, title: 'visual editor' },
    ]);
    this.router = router;
  }
}