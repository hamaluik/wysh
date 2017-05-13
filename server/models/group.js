var Sequelize = require('sequelize');

module.exports = {
    load: function(db) {
        return db.define('Group', {
            name: { type: Sequelize.STRING, unique: true, allowNull: false }
        });
    }
}