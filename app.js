const express = require("express");
const dotenv = require("dotenv");

dotenv.config();

const app = express();

const APP_VERSION = process.env.APP_VERSION || "local=dev";
const ENVIRONMENT = process.env.ENVIRONMENT || "development";
const DEPLOYED_AT = process.env.DEPLOYED_AT || new Date().toISOString();

app.get("/", (req, res) => {
    res.json({
        status: "UP",
        environment: ENVIRONMENT,
        version: APP_VERSION,
        deployedAt: DEPLOYED_AT
    });
});

app.get("/health", (req, res) => {
    res.status(200).send("OK");
});

app.get("/version", (req, res) => {
    res.send(APP_VERSION);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`App running on port ${PORT}`);
});