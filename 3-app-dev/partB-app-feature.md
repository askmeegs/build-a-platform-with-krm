
## Part B - Add an Application Feature 

In this section, we'll make an update to the CymbalBank frontend source code, test it using a local Kubernetes toolchain, then put out a Pull Request to trigger the a multi-part CI/CD workflow.  

![partB](screenshots/dev-test.png)

#### 1. **Update the frontend source code**. 

Add a banner to the login page advertising a new interest rate on all checking accounts. Return to VSCode and open `cymbalbank-app-source/src/frontend/templates/login.html`. Under line 71, add the following code: 

```
          <div class="col-lg-6 offset-lg-3">
            <div class="card">
              <div class="card-body">
                <h5><strong>New!</strong> 0.20% APY on all new checking accounts. <a href="/signup">Sign up today.</a></h5>
              </div>
            </div>
          </div>
```
