/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  basePath: '/libertyX',
  assetPrefix: '/libertyX',
  trailingSlash: true, // Force trailing slashes to prevent redirect loop
  // output: 'export', // static export disabled for server mode
}

module.exports = nextConfig; 