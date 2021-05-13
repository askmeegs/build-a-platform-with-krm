
## Part F - Continuous Deployment  

![screenshot](screenshots/prod-cd.jpg)

Back in Part 2, you set up the Continuous Deployment pipeline for cymbal-bank. This pipeline was simple: it looks at new commits to the `main` branch of `cymbalbank-app-config`, and runs `kubectl apply -k` on the `prod` overlay, deploying those manifests to the `cymbal-prod` cluster. 

When you first initialized that pipeline, you used the `demo` overlay (with pre-built images) manually pushed to the config repo to trigger the build, which deployed those pre-built images to the `cymbal-prod` cluster. Now, instead, your CI pipeline is the one that injected the new image tags and committed to the config repo. This better illustrates GitOps best practices, where automation handles the production manifests rather than a human - this reduces the possibility for errors and helps secure the software supply chain overall. (In practice, you might only allow a specific Git "bot" to push the config repo - for these demos, you're using your personal token in CI, so all the commits will show up as "you," including those commits from Cloud Build.)

Also note that this CD pipeline is very simple, just one "kubectl apply" command. In reality, you'd likely have a progressive deploy to production - such as a Kubernetes rolling update or a Canary Deployment using a service mesh or similar tool. By slowly rolling out the new containers into the production GKE environment, and monitoring whether requests are successul, you can safeguard against a production outage or performance degradations. 

Let's watch your frontend banner feature land in production using the CD pipeline. 

 1. Watch Cloud Build - CD - Prod. 

Navigate back to Cloud Build and ensure that the build ran successfully. 

 2. View the new frontend banner running in production. 

```
kubectx cymbal-staging; kubectl get svc frontend -n frontend
```

🎉 **Congrats**! You just developed a new CymbalBank feature, tested it in a live Kubernetes environment, and deployed it into production. All without editing a single YAML file. 

## Learn More 

- [Kustomize Documentation](https://kustomize.io/)
- [Examples - Kustomize](https://github.com/kubernetes-sigs/kustomize/tree/master/examples)
- [Kubernetes Docs - Mangaging Kubernetes Objects - Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
- [Kustomize Tutorial](https://kubectl.docs.kubernetes.io/guides/config_management/components/)
- [Cloud Code Documentation](https://cloud.google.com/code/docs/vscode/setting-up-an-existing-app#setting_up_configuration_for_applications_that_already_have_skaffoldyaml)
- [Google Cloud - GitOps-style continuous delivery with Cloud Build](https://cloud.google.com/kubernetes-engine/docs/tutorials/gitops-cloud-build)