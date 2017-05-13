const log = require('../log');

module.exports.load = function(config, router, db, models, auth) {
    router.get('/groups', auth.check, function(req, res, next) {
        log.info('group req user', {email: req.user.email});
        res.json({message: 'Derp'});
    });
}