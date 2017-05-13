module.exports.load = function(config, errors, router, db, models, auth) {
    //require('./group').load(config, errors, router, db, models, auth);
    require('./items').load(config, errors, router, db, models, auth);
}