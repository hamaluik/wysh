const util = require('util');

var Unauthorized = function(message) {
    Error.call(this, message);
    this.name = 'Unauthorized';
    this.message = message;
}
util.inherits(Unauthorized, Error);

var UserNotFound = function(id) {
    var message = 'User [' + id + '] wasn\'t found!';
    Error.call(this, message);
    this.name = 'UserNotFound';
    this.message = message;
}
util.inherits(UserNotFound, Error);

module.exports = {
    Unauthorized: Unauthorized,
    UserNotFound: UserNotFound
}