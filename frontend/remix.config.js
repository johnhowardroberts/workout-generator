/** @type {import('@remix-run/dev').AppConfig} */
module.exports = {
  ignoredRouteFiles: ["**/.*"],
  serverModuleFormat: "cjs",
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
  assetsBuildDirectory: "public/build",
  // This ensures the server build is in the correct location
  serverBuildPath: "build/index.js",
}; 