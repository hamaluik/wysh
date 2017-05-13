const jwt = require('jsonwebtoken');
const log = require('../log');
const Promise = require("bluebird");

module.exports.load = function(config, errors, db, models) {
    return {
        check: function(req, res, next) {
            if(req.headers && req.headers.authorization) {
                var parts = req.headers.authorization.split(' ');
                if(parts.length === 2 && parts[0] === "Bearer") {
                    var token = parts[1];
                    try {
                        var decodedToken = jwt.verify(token, 'some super hidden secret');

                        // make sure email exists in the database!
                        db.transaction(function(t) {
                            return models.User.findOne({
                                where: { email: decodedToken.email }
                            }, { transaction: t })
                            .then(function(user) {
                                if(user) {
                                    return new Promise(function(resolve, reject) {
                                        resolve(user);
                                    });
                                }
                                else {
                                    log.info('creating new user', { email: decodedToken.email });
                                    return models.User.create({
                                        email: decodedToken.email,
                                        fullName: 'TODO',
                                        nickName: 'TODO',
                                        imageURL: 'unsplash.it/128'
                                    });
                                }
                            });
                        }).then(function(user) {
                            //log.info('validated user', { email: user.email });
                            req.user = user;
                            next();
                        }).catch(function(error) {
                            log.error('user auth transaction', error);
                        });
                    }
                    catch(error) {
                        return next(new errors.Unauthorized("You aren't authorized to do that!"));
                    }
                }
                else {
                    return next(new errors.Unauthorized('Authorization must be a JWT Bearer!'));
                }
            }
            else {
                return next(new errors.Unauthorized('Authorization is required to access this!'));
            }
        }
    };
}