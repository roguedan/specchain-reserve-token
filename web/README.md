# Specchain marketing site

This directory contains an [Astro](https://astro.build/) project that powers the Specchain Reserve Token marketing site. It uses the [AstroWind](https://astrowind.vercel.app/) design language (Tailwind-based) adapted for a focused single-page layout.

## Getting started

```bash
cd web
npm install
npm run dev
```

The development server runs on <http://localhost:4321>.

## Build

```bash
npm run build
```

The static output is generated in `web/dist/` and is ready to be published on Cloudflare Pages.

## Cloudflare Pages configuration

When creating or updating the Cloudflare Pages project via the dashboard, set the following values:

| Setting | Value |
| --- | --- |
| **Framework preset** | `Astro` (optional) |
| **Build command** | `npm run build` |
| **Root directory** | `web` |
| **Build output directory** | `dist` |

> **Tip:** Once the root directory is set to `web`, all other paths are relative to that folder. Entering `web/dist` in the build output field will cause Cloudflare Pages to look for `web/dist/dist`, which fails the deployment. Leave the `web/` prefix off so Cloudflare can locate the generated `dist/` folder correctly.

This matches the GitHub Actions workflow, so both manual and automated deploys will serve the site from the `web/` workspace.
