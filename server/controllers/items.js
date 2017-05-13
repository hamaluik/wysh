const log = require('../log');

module.exports.load = function(config, errors, router, db, models, auth) {
    router.get('/users/:user_id/items', auth.check, function(req, res, next) {
        log.info('listing user items', { email: req.user.email, targetID: req.params.user_id });
        db.transaction(function(t) {
            return models.User.findOne({
                where: { id: req.params.user_id }
            }, { transaction: t })
            .then(function(user) {
                if(user == null) {
                    throw new errors.UserNotFound(req.params.user_id);
                }
                return user.getItems();
            })
            .then(function(items) {
                var ret = [];
                for(var i = 0; i < items.length; i++) {
                    ret.push(models.sanitize.item(items[i]));
                }
                return ret;
            });
        })
        .then(function(result) {
            res.json(result);
        })
        .catch(function(error) {
            log.error('Error listing user items', {
                email: req.user.email,
                targetID: req.params.user_id
            });
            return next(error);
        });
    });

    router.post('/item', auth.check, function(req, res, next) {
        db.transaction(function(t) {
            var _item = null;
            return models.Item.create({
                name: req.body.name,
                cost: parseFloat(req.body.cost),
                url: req.body.url,
                store: req.body.store,
                description: req.body.description,
                recurring: req.body.recurring === "true",
                imageURL: req.body.imageURL
            }, { transaction: t })
            .then(function(item) {
                _item = item;
                return req.user.addItem(item);
            })
            .then(function(x) {
                return _item;
            });
        })
        .then(function(result) {
            res.json(models.sanitize.item(result));
        })
        .catch(function(error) {
            log.error('Error adding new item', { email: req.user.email });
            return next(error);
        });
    });
};