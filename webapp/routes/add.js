const { Router } = require('express');
const restifyClients = require('restify-clients');
const { dns } = require('concordant')();
const router = Router();

var clients;

router.get('/', function (req, res) {
    res.render('add', {first: 0, second:0, result: 0});
});

router.post('/calculate', resolve, response);

function resolve (req, res, next) {
    if (clients) {
        next();
        return;
    }
    // DONE このauditserviceのdnsの値はどこから来た?
    // svc.cluster.local は fuge の dns_suffixから来た
    const addservice = `_main._tcp.addservice.micro.svc.cluster.local`;
    const auditservice = `_main._tcp.auditservice.micro.svc.cluster.local`;
    
    dns.resolve(addservice, (err, locs) => {
        if (err) {
            next(err);
            return;
        }
        const {host, port} = locs[0];
        const adder = `${host}:${port}`;
        
        dns.resolve(auditservice, (err, locs) => {
            if (err) {
                next(err);
                return;
            }
            const {host, port} = locs[0];
            const audit = `${host}:${port}`;
            clients = {
                adder: restifyClients.createJSONClient({
                    url: `http://${adder}`
                }),
                audit: restifyClients.createJSONClient({
                    url: `http://${audit}`
                })
            };
            next();
        });
    });
}

function response (req, res, next) {
    const {first, second} = req.body;
    clients.adder.get(
        `/add/${first}/${second}`,
        (err, svcReq, svcRes, data) => {
            if (err) {
                next(err);
                return;
            }
            const { result } = data;
            clients.audit.post('/append', {
                calc: first + '+' + second,
                calcResult: result
            }, (err) => {
                if (err) console.error(err);
            });
            res.render('add', {first, second, result});
        }
    );
}

module.exports = router;

