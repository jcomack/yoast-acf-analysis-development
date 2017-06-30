var childProcess = require('child_process');
var chromedriver = require('chromedriver');
var psTree = require('ps-tree');

module.exports = {
    "user"     : "admin",
    "password" : "password",
    before : function(done) {
        this.chromedriverInstance = childProcess.exec('xvfb-run ' + chromedriver.path);
        done();
    },
    after : function(done) {
        if (this.chromedriverInstance != null){
            psTree(this.chromedriverInstance.pid, function (err, children) {
                childProcess.spawn('kill', ['-9'].concat(children.map(function (p) { return p.PID })));
            });
        }
        done();
    },
    beforeEach: function( browser, done ) {
        var page = browser.page.WordPressHelper();
        page.login();
    }
};