var Sequelize = require('sequelize');

module.exports = {
    load: function(db) {
        return db.define('User', {
            email: { type: Sequelize.STRING, unique: true, allowNull: false },
            fullName: { type: Sequelize.STRING, allowNull: false, unique: false },
            nickName: { type: Sequelize.STRING, allowNull: false, unique: false },
            imageURL: { type: Sequelize.STRING, allowNull: true, unique: false, defaultValue: null }
        });
    }
}