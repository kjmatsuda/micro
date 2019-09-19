const wiring = require('./wiring');
// TODO ここでserviceをrequireしたときに最後に()をつけるのはなぜ？
const service = require('./service')();

wiring(service);
