## kustomize - Cymbal Bank 

This directory contains base and overlay manifests for the CymbalBank app. These manifests are intended for use with kustomize. 

### `base/` 

The `/base` directory contains the base manifests for CymbalBank, including ConfigMaps, Secrets, Deployments, Jobs, and Services. 

### `/overlays/` 

The `overlays/` directory contains two deployment overlays (options) for CymbalBank, `dev/` and `prod/`. These overlays both use the `base` manifests but add special configuration for frontend repliacs, logging, tracing, and metrics export: 

|      | 🔎 **Tracing** | 📊 **Metrics** | 📝 **Log Level** | 🏦 **Frontend Replicas** |
|------|---------|---------|-----------|---------------------|
| 💻 **Dev**  | off     | off     | `debug`   | 1                   |
| 🚀 **Prod** | on      | on      | `info`    | 3                   |


Note that the staging pipeline for the intro-to-krm demo uses the `dev` overlay. 