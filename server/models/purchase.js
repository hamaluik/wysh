var Sequelize = require('sequelize');

module.exports = {
    load: function(db) {
        return db.define('Purchase', {
            date: { type: Sequelize.DATE, allowNull: false }
        });
    }
}