const log = require('../log');

module.exports.load = function(config, errors, router, db, models, auth) {
    router.get('/groups', auth.check, function(req, res, next) {
        req.user.getGroups()
        .then(function(groups) {
            var ret = [];
            for(var i = 0; i < groups.length; i++) {
                ret.push({
                    id: groups[i].id,
                    name: groups[i].name
                });
            }
            res.json(ret);
        })
        .catch(function(error) {
            log.error('error listing groups', { user: req.user.email });
            return next(error);
        });
    });

    router.post('/groups/new', auth.check, function(req, res, next) {
        db.transaction(function(t) {
            var _group = null;
            log.info('creating new group', { user: req.user.email, group: req.body.name });
            return models.Group.create({
                name: req.body.name
            }, { transaction: t })
            .then(function(group) {
                _group = group;
                return group.addUser(req.user, { transaction: t });
            })
            .then(function(x) {
                return _group;
            });
        })
        .then(function(result) {
            log.info('new group created', { user: req.user.email, group: req.body.name });
            res.json({
                group: models.sanitize.group(result),
                members : [models.sanitize.user(req.user)]
            });
        })
        .catch(function(error) {
            log.error('error creating new group', { user: req.user.email, group: req.body.name });
            return next(error);
        })
    });
}