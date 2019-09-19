module.exports = service

function service () {
    function add (args, cb) {
        const {first, second} = args
        const result = (parseInt(first, 10) + parseInt(second, 10))
        console.log('%s+%s=%s', first, second, result)
        cb(null, {result: result.toString()})
    }
    return { add }
}
