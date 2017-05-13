var Sequelize = require('sequelize');

module.exports = {
    load: function(db) {
        return db.define('Item', {
            name: { type: Sequelize.STRING, allowNull: false, unique: false	 },
            cost: { type: Sequelize.FLOAT, allowNull: true, unique: false },
            url: { type: Sequelize.STRING, allowNull: true, unique: false },
            store: { type: Sequelize.STRING, allowNull: true, unique: false },
            description: { type: Sequelize.TEXT, allowNull: true, unique: false},
            recurring: { type: Sequelize.BOOLEAN, allowNull: false, unique: false, defaultValue: false },
            imageURL: { type: Sequelize.STRING, allowNull: true, unique: false }
        });
    },
    sanitize: function(item) {
        return {
            id: item.id,
            name: item.name,
            cost: item.cost,
            url: item.url,
            store: item.store,
            description: item.description,
            recurring: item.recurring,
            imageURL: item.imageURL
        };
    }
}