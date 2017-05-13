const express = require('express');
const sequelize = require('sequelize');
const bodyParser = require('body-parser');
const cors = require('cors');
const log = require('./log');

const config = require('./config');

var app = express();
var db = new sequelize('projectdr', '' ,'', {
    dialect: 'sqlite',
    storage: config.database,
    logging: log.trace
});

var router = express.Router();
router.use(bodyParser.json());
router.use(bodyParser.urlencoded({ extended: true }));
router.use(cors());
app.use('/api/v1', router);

app.use(express.static(config.webclient));

app.use(function(err, req, res, next) {
    if(err && err.name === 'Unauthorized') {
        log.warn('authentication error', {
            ip: req.ip,
            message: err.message
        });
        res.status(401).json({message: err.message});
    }
    else if(err && err.name === 'UserNotFound') {
        log.warn('user not found', {
            message: err.message
        });
        res.status(404).json({message: err.message});
    }
    else {
        log.error('Unhandled error:', err);
        res.status(500).json({});
    }
});

var errors = require('./errors');
var models = require('./models').load(db);
var auth = require('./auth').load(config, errors, db, models);
require('./controllers').load(config, errors, router, db, models, auth);

db.sync().then(function() {
    app.listen(config.port, function() {
        log.info('wysh server started!', {port: config.port});
    });
});