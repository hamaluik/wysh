module.exports.load = function(db) {
    const Group = require('./group').load(db);
    const Item = require('./item').load(db);
    const Purchase = require('./purchase').load(db);
    const User = require('./user').load(db);

    // set up relationships between tables
    User.belongsToMany(Group, { through: 'UserGroup' });
    Group.belongsToMany(User, { through: 'UserGroup' });
    User.hasMany(Item);
    Item.hasMany(Purchase);
    Purchase.belongsTo(User, { as: 'purchaser' });

    return {
        Group: Group,
        Item: Item,
        Purchase: Purchase,
        User: User
    };
}