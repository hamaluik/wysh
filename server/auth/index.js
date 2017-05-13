const jwt = require('jsonwebtoken');
const log = require('../log');
const Promise = require("bluebird");

var UnauthorizedError = function(message) {
    Error.call(this, message);
    this.name = 'UnauthorizedError';
    this.message = message;
}
require('util').inherits(UnauthorizedError, Error);

module.exports.load = function(config, db, models) {
    return {
        UnauthorizedError: UnauthorizedError,
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
                        return next(new UnauthorizedError("You aren't authorized to do that!"));
                    }
                }
                else {
                    return next(new UnauthorizedError('Authorization must be a JWT Bearer!'));
                }
            }
            else {
                return next(new UnauthorizedError('Authorization is required to access this!'));
            }
        }
    };
}