
export class App {

  primaryColor = '#22aadd';
  accentColor =  '#1199cc';

  configureRouter(config, router) {
    config.title = 'PcdKit';
    config.map([
      { route: ['', 'home'], name: 'home',      moduleId: 'home',      nav: true, title: 'Home' },
      { route: ['editor'], name: 'editor',      moduleId: 'editor',      nav: true, title: 'visual editor' },
    ]);
    this.router = router;
  }
}