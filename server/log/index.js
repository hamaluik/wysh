const chalk = require('chalk');

var log = function(level, message, data) {
    var currentDate = '[' + new Date().toUTCString() + ']';
    if(level === 'T') {
        console.log(currentDate, chalk.gray(message));
    }
    else if(level === 'I') {
        console.log(currentDate, chalk.cyan(message), data);
    }
    else if(level === 'W') {
        console.log(currentDate, chalk.yellow(message), data);
    }
    else if(level === 'E') {
        console.log(currentDate, chalk.red(message), data);
    }
    else {
        console.log(currentDate, message, data);
    }
}

module.exports = {
    trace: function(message) {
        log('T', message);
    },
    info: function(message, data) {
        log('I', message, data);
    },
    warn: function(message, data) {
        log('W', message, data);
    },
    error: function(message, data) {
        log('E', message, data);
    }
}