const express = require('express');
const app = express();
const db = require('./persistence');
const getItems = require('./routes/getItems');
const addItem = require('./routes/addItem');
const updateItem = require('./routes/updateItem');
const deleteItem = require('./routes/deleteItem');

app.use(express.json());
app.use(express.static(__dirname + '/static'));


// Add metrics endpoint for Prometheus
app.get('/metrics', async (req, res) => {
    res.set('Content-Type', 'text/plain');
    let mysqlStatus = 0;
    let backendStatus = 0;
    let itemCount = 0;
    
    try {
        const items = await db.getItems();
        mysqlStatus = 1;
        backendStatus = 1;
        itemCount = items.length;
    } catch (error) {
        console.error('Service check failed:', error);
        // If MySQL is down, backend is effectively down
        backendStatus = 0;
        mysqlStatus = 0;
    }

    res.send(`
# HELP todo_app_status Indicates if the todo application backend is functioning (1 = up, 0 = down)
# TYPE todo_app_status gauge
todo_app_status ${backendStatus}

# HELP todo_app_uptime_seconds Number of seconds the application has been running
# TYPE todo_app_uptime_seconds counter
todo_app_uptime_seconds ${process.uptime()}

# HELP mysql_up Indicates if MySQL database connection is established (1 = up, 0 = down)
# TYPE mysql_up gauge
mysql_up ${mysqlStatus}

# HELP todo_items_total Current number of items in the todo list
# TYPE todo_items_total gauge
todo_items_total ${itemCount}
`);
});

app.get('/items', getItems);
app.post('/items', addItem);
app.put('/items/:id', updateItem);
app.delete('/items/:id', deleteItem);

db.init().then(() => {
    app.listen(3000, () => console.log('Listening on port 3000'));
}).catch((err) => {
    console.error(err);
    process.exit(1);
});

const gracefulShutdown = () => {
    db.teardown()
        .catch(() => {})
        .then(() => process.exit());
};

process.on('SIGINT', gracefulShutdown);
process.on('SIGTERM', gracefulShutdown);
process.on('SIGUSR2', gracefulShutdown); // Sent by nodemon
