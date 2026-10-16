# Where Ansible fits

This capstone uses Amazon EKS + Kubernetes + Helm for application deployment. Ansible is not required for that path: Helm and Kubernetes already manage the application release, replicas, health checks, and rollout status.

Ansible is useful when configuring EC2/VM hosts (for example, installing Docker on an EC2 server) or running operations against conventional servers. We can add a separate Ansible EC2 deployment path later, but it would duplicate the EKS/Helm path for this project.

Do not run an Ansible playbook against AWS until its inventory, credentials, and target hosts are explicitly configured.
