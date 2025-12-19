/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  basePath: '/libertyX',
  assetPrefix: '/libertyX',
  // trailingSlash removed - it was causing issues with API routes and redirects
  // output: 'export', // static export disabled for server mode
}

module.exports = nextConfig; 