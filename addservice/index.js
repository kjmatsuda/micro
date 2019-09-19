// test
const wiring = require('./wiring')
// TODO ここでserviceには{ add }が設定されるはず
const service = require('./service')()

wiring(service)
