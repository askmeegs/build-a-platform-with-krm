FROM gcr.io/k8s-skaffold/skaffold:latest 

# Install wget 
RUN apt-get update && apt-get install -y wget 

# # Upgrade kustomize 
# RUN wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.0.5/kustomize_v4.0.5_linux_amd64.tar.gz 
# RUN tar xf kustomize_v4.0.5_linux_amd64.tar.gz -C /usr/local/bin 

# Install maven 
RUN wget https://www-us.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz -P /tmp
RUN tar xf /tmp/apache-maven-*.tar.gz -C /opt
RUN mv /opt/apache-maven-3.6.3 /opt/maven 

ENV M3_HOME=/opt/maven
ENV MAVEN_HOME=/opt/maven
ENV PATH=/opt/maven/bin:${PATH} 