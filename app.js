const http = require('http');
const server = http.createServer((req, res) => {
    if (req.method === 'POST') {
        // Handle post info...
    }
    else {
      res.end(`
        <!doctype html>
        <html>
        <body>
            <form action="/" method="post">
                <input type="text" name="fname" /><br />
                <input type="number" name="age" /><br />
                <input type="file" name="photo" /><br />
                <button>Save</button>
            </form>
        </body>
        </html>
      `);
    }
});
server.listen(3000);
