/** @type {import('@remix-run/dev').AppConfig} */
export default {
  ignoredRouteFiles: ["**/.*"],
  serverModuleFormat: "esm",
  future: {
    v2_dev: true,
    v2_errorBoundary: true,
    v2_headers: true,
    v2_meta: true,
    v2_normalizeFormMethod: true,
    v2_routeConvention: true,
  },
  // This is needed for GitHub Pages deployment
  publicPath: "/workout-generator/",
  // This ensures assets are loaded correctly
  assetsBuildDirectory: "dist",
  // This ensures the server build is in the correct location
  serverBuildPath: "dist/server/index.js",
  // Enable static site generation
  server: "./server.js",
  // Add trailing slashes to all routes
  trailingSlash: true,
}; 