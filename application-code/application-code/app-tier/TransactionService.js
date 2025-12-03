const dbConfigPromise = require('./DbConfig');
const mysql = require('mysql');

let con;

// initialize connection asynchronously
(async () => {
    try {
        const dbcreds = await dbConfigPromise;

        con = mysql.createConnection({
            host: dbcreds.DB_HOST,
            user: dbcreds.DB_USER,
            password: dbcreds.DB_PWD,
            database: dbcreds.DB_DATABASE
        });

        con.connect(err => {
            if (err) {
                console.error("❌ Database connection failed:", err);
                process.exit(1);
            }
            console.log("✅ Connected to database!");
        });
    } catch (err) {
        console.error("❌ Failed to load DB config:", err);
        process.exit(1);
    }
})();

function addTransaction(amount,desc){
    var mysql = `INSERT INTO \`transactions\` (\`amount\`, \`description\`) VALUES ('${amount}','${desc}')`;
    con.query(mysql, function(err,result){
        if (err) throw err;
        console.log("Adding to the table should have worked");
    }) 
    return 200;
}

function getAllTransactions(callback){
    var mysql = "SELECT * FROM transactions";
    con.query(mysql, function(err,result){
        if (err) throw err;
        console.log("Getting all transactions...");
        return(callback(result));
    });
}

function findTransactionById(id,callback){
    var mysql = `SELECT * FROM transactions WHERE id = ${id}`;
    con.query(mysql, function(err,result){
        if (err) throw err;
        console.log(`retrieving transactions with id ${id}`);
        return(callback(result));
    }) 
}

function deleteAllTransactions(callback){
    var mysql = "DELETE FROM transactions";
    con.query(mysql, function(err,result){
        if (err) throw err;
        console.log("Deleting all transactions...");
        return(callback(result));
    }) 
}

function deleteTransactionById(id, callback){
    var mysql = `DELETE FROM transactions WHERE id = ${id}`;
    con.query(mysql, function(err,result){
        if (err) throw err;
        console.log(`Deleting transactions with id ${id}`);
        return(callback(result));
    }) 
}


module.exports = {addTransaction ,getAllTransactions, deleteAllTransactions, deleteAllTransactions, findTransactionById, deleteTransactionById};







