import path from "path";
import express from "express";
import compression from "compression";
import morgan from "morgan";
import { createRequestHandler } from "@remix-run/express";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const BUILD_DIR = path.join(__dirname, "build");
const PORT = process.env.PORT || 3000;

const app = express();

app.use(compression());
app.use(morgan("tiny"));
app.use(express.static("public", { maxAge: "1h" }));

// Handle all other routes with Remix
app.all(
  "*",
  createRequestHandler({
    build: await import(BUILD_DIR),
    mode: process.env.NODE_ENV,
  })
);

app.listen(PORT, () => {
  console.log(`Express server listening on port ${PORT}`);
}); 