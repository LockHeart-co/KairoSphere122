import { defineConfig } from "vite";

export default defineConfig(({ command }) => ({
  base: command === "build" ? "/KairoSphere122-0605e52e/" : "/"
}));
