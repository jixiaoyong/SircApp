import { defineConfig } from 'vite';
import { resolve } from 'path';
import { viteSingleFile } from 'vite-plugin-singlefile';

export default defineConfig({
  root: 'src',
  base: './',
  plugins: [viteSingleFile()],
  build: {
    outDir: resolve(__dirname, 'dist/companion'),
    emptyOutDir: true,
  },
  server: {
    port: 5173,
    host: true,
  },
});
