const path = require("path");
const express = require("express");
const compression = require("compression");
const morgan = require("morgan");
const { createRequestHandler } = require("@remix-run/express");

const BUILD_DIR = path.join(process.cwd(), "public/build");
const PORT = process.env.PORT || 3000;

const app = express();

app.use(compression());
app.use(morgan("tiny"));
app.use(express.static("public", { maxAge: "1h" }));

// Handle all other routes with Remix
app.all(
  "*",
  createRequestHandler({
    build: require(BUILD_DIR),
    mode: process.env.NODE_ENV,
  })
);

app.listen(PORT, () => {
  console.log(`Express server listening on port ${PORT}`);
}); 