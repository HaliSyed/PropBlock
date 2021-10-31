const express = require("express");
const helmet = require("helmet");
const cors = require("cors");
const authService = require("./pinata/auth");

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/upload', function (req, res) {
    authService.pinFile().then(
        (response) => res.json({ response })
    );
})

app.listen(3000);