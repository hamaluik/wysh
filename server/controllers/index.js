module.exports.load = function(config, router, db, models, auth) {
    require('./group').load(config, router, db, models, auth);
}