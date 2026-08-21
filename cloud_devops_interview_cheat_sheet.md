# Cloud & DevOps Interview Cheat Sheet

> **Purpose:** Fast interview revision for junior / entry-level Cloud, Cloud Operations, DevOps and Cloud Infrastructure roles.
>
> **Strategy:** Memorize the one-liners first. If the interviewer asks **"why?"**, expand using the trade-offs and examples.

---

## 1. Cloud Fundamentals

| Term | Interview answer |
|---|---|
| **Cloud computing** | Using on-demand computing resources such as compute, storage and networking over provider-managed infrastructure, usually with pay-as-you-go pricing. |
| **IaaS** | The provider manages physical infrastructure while you manage resources such as VMs, OS and applications. |
| **PaaS** | The provider manages infrastructure and runtime platform, allowing you to focus primarily on the application. |
| **SaaS** | A complete software application delivered and managed by the provider. |
| **Region** | A geographic location containing cloud infrastructure where workloads can be deployed. |
| **Availability Zone** | An isolated failure domain within a region, designed to reduce the impact of infrastructure failures. |
| **High Availability (HA)** | Designing systems to remain available despite failures by removing single points of failure and using redundancy. |
| **Scalability** | Ability of a system to handle increased workload by adding resources. |
| **Vertical scaling** | Increasing resources of an existing instance, such as CPU or RAM. |
| **Horizontal scaling** | Adding more instances to distribute workload. |
| **Elasticity** | Automatically increasing or decreasing resources according to demand. |
| **Fault tolerance** | Ability to continue operating despite component failures. |
| **Disaster Recovery (DR)** | Processes and architecture used to recover services after a major failure or disaster. |
| **RTO** | Recovery Time Objective: maximum acceptable time to restore service after a failure. |
| **RPO** | Recovery Point Objective: maximum acceptable amount of data loss measured in time. |

---

## 2. Networking

| Term | Interview answer |
|---|---|
| **VPC / VNet** | A logically isolated virtual network in the cloud where resources such as VMs and databases communicate. |
| **Subnet** | A smaller network segment within a VPC/VNet used for organizing and isolating resources. |
| **CIDR** | Notation used to define IP address ranges, such as `10.0.1.0/24`. |
| **Route table** | Defines where network traffic should be sent based on its destination. |
| **Private IP** | An internal IP used for communication within private networks. |
| **Public IP** | An internet-routable IP used to provide public connectivity to a resource. |
| **DNS** | Resolves human-readable names into IP addresses or other records. |
| **Load balancer** | Distributes incoming traffic across healthy backend instances. |
| **Reverse proxy** | Receives client requests and forwards them to backend services. |
| **Firewall** | Controls network traffic according to rules such as source, destination, protocol and port. |
| **NSG / firewall rule** | Controls which network traffic is allowed to reach or leave resources. |
| **WAF** | Web Application Firewall that filters HTTP/HTTPS traffic and protects web applications from attacks. |
| **CDN** | Distributes cacheable content closer to users through edge locations to reduce latency. |
| **NAT** | Allows private resources to initiate outbound communication without requiring public IP addresses. |
| **VPN** | Creates an encrypted connection between networks or users over an untrusted network. |
| **Peering** | Connects private networks so resources can communicate over the provider's network. |
| **Port** | A logical endpoint used to identify a network service, e.g. TCP 22 for SSH and 443 for HTTPS. |
| **TCP** | Connection-oriented transport protocol providing reliable ordered delivery. |
| **HTTP/HTTPS** | Application-layer protocols used for web communication; HTTPS adds TLS encryption. |

### Key distinction

```text
NSG / Firewall → network traffic control
WAF            → web/HTTP attack protection
RBAC / IAM     → identity authorization
```

---

## 3. Linux

| Term | Interview answer |
|---|---|
| **Process** | A running instance of a program managed by the operating system. |
| **PID** | Process ID used to identify a running process. |
| **SSH** | Secure protocol commonly used for remote administration of Linux systems. |
| **systemd** | Common Linux system and service manager. |
| **Environment variable** | A key-value configuration value made available to processes. |
| **File permissions** | Linux permissions controlling read, write and execute access for users/groups/others. |
| **`ps`** | Displays running processes and their information. |
| **`top`** | Interactive view of processes and resource usage. |
| **`df`** | Shows filesystem disk-space usage. |
| **`du`** | Shows disk usage by files/directories. |
| **`ss`** | Displays network sockets and listening ports. |
| **`curl`** | Command-line tool commonly used to make HTTP requests and test endpoints. |
| **`grep`** | Searches text for matching patterns. |
| **`chmod`** | Changes file or directory permissions. |

---

## 4. Git / GitHub

| Term | Interview answer |
|---|---|
| **Git** | Distributed version-control system used to track changes to source code and collaborate. |
| **Repository** | A Git-managed project containing files and their version history. |
| **Commit** | A recorded snapshot of changes in Git. |
| **Branch** | An independent line of development. |
| **Merge** | Combines changes from one branch into another. |
| **Remote** | A reference to a repository hosted elsewhere, such as GitHub. |
| **`.gitignore`** | Specifies files Git should not track, such as secrets, state files or generated artifacts. |
| **GitHub** | Hosted platform for Git repositories, collaboration and automation. |
| **Pull request** | Mechanism for proposing, reviewing and merging changes into a target branch. |
| **Merge conflict** | Occurs when Git cannot automatically reconcile conflicting changes. |

### Terraform + Git

> Terraform state should generally **not** be committed to Git. State can contain sensitive information and represents mutable infrastructure state; use a secure remote backend with appropriate locking and access control.

---

## 5. Terraform / Infrastructure as Code

| Term | Interview answer |
|---|---|
| **Infrastructure as Code** | Managing infrastructure through declarative configuration instead of manually creating resources. |
| **Terraform** | Infrastructure-as-Code tool that declaratively provisions and manages infrastructure across providers. |
| **Provider** | Terraform plugin that lets Terraform interact with a platform/API such as Azure or GCP. |
| **Resource** | A specific infrastructure object managed by Terraform. |
| **Variable** | Input used to parameterize Terraform configurations. |
| **Output** | A value Terraform exposes after deployment. |
| **Module** | Reusable collection of Terraform configuration. |
| **State** | Terraform's record of the infrastructure it manages and its relationship to configuration. |
| **`terraform plan`** | Shows intended infrastructure changes without applying them. |
| **`terraform apply`** | Applies the planned infrastructure changes. |
| **`terraform destroy`** | Removes infrastructure managed by Terraform. |
| **Drift** | Difference between actual infrastructure and what Terraform expects. |
| **Idempotency** | Reapplying the same desired configuration should converge on the same infrastructure state. |

### Terraform failure

> A failed `terraform apply` does **not** automatically mean you should destroy everything. Investigate the error, fix the configuration, run `terraform plan`, review it, then apply again.

---

## 6. Docker / Containers

| Term | Interview answer |
|---|---|
| **Container** | An isolated application process that packages its dependencies while sharing the host kernel. |
| **Image** | An immutable, layered package containing the filesystem and application dependencies used to create containers. |
| **Container vs VM** | A VM runs its own OS/kernel; a container shares the host kernel and is generally lighter. |
| **Dockerfile** | Text file containing instructions for building a Docker image. |
| **`docker build`** | Builds an image from a Dockerfile and build context. |
| **`docker run`** | Creates and starts a container from an image. |
| **`docker exec`** | Executes a command inside a running container. |
| **`docker logs`** | Displays container stdout/stderr logs. |
| **`docker inspect`** | Displays detailed metadata and configuration about Docker objects. |
| **Volume** | Persistent storage that exists independently of a container's writable filesystem. |
| **Bridge network** | Docker network mode commonly used for container-to-container communication. |
| **Port mapping** | Maps a host port to a container port, e.g. `8080:80`. |
| **Container registry** | Centralized repository for storing and distributing container images. |
| **Docker Hub** | Public container registry. |
| **ACR / Artifact Registry** | Cloud-managed container image registries. |

### Container lifecycle

```text
Image
  ↓
Container
  ↓
Main process runs
  ↓
Process exits
  ↓
Container stops
```

> **A container is not a mini-VM.**

---

## 7. Dockerfile

| Instruction | One-liner |
|---|---|
| `FROM` | Specifies the base image. |
| `WORKDIR` | Sets the working directory inside the image/container. |
| `COPY` | Copies files from the build context into the image. |
| `RUN` | Executes a command during image build. |
| `CMD` | Defines the default command/arguments when the container starts. |
| `ENTRYPOINT` | Defines the executable the container is intended to run. |

### CMD vs ENTRYPOINT

> **ENTRYPOINT defines the main executable; CMD provides default arguments or a default command that can generally be overridden.**

---

## 8. CI/CD / DevOps

| Term | Interview answer |
|---|---|
| **CI** | Automatically builds and tests changes whenever code is integrated. |
| **CD** | Automates delivering validated software toward deployment environments. |
| **Pipeline** | Automated sequence of build, test, security and deployment steps. |
| **Artifact** | Output produced by a build, such as a binary, package or container image. |
| **Runner** | Machine/environment that executes CI/CD jobs. |
| **GitHub Actions** | GitHub's automation platform for building CI/CD workflows. |
| **Rolling deployment** | Gradually replaces old application instances with new ones. |
| **Blue/Green deployment** | Maintains two environments and switches traffic from old to new. |
| **Canary deployment** | Releases a new version to a small percentage of users before wider rollout. |
| **Immutable artifact** | A built artifact is promoted through environments without rebuilding it for each environment. |

### CI/CD flow

```text
Git push
   ↓
Build
   ↓
Test
   ↓
Security / validation
   ↓
Package / image
   ↓
Registry / artifact store
   ↓
Deploy
```

---

## 9. CI/CD Authentication

| Term | Interview answer |
|---|---|
| **OIDC** | Allows a workload to establish trusted authentication with another identity system without storing long-lived credentials. |
| **Workload identity** | Identity mechanism allowing applications/automation workloads to authenticate as themselves rather than using personal credentials. |
| **Secret** | Sensitive value such as a password, API key or credential that must be protected. |
| **GitHub Secret** | Securely stored GitHub value that can be provided to workflows without hardcoding it in source code. |

### Why OIDC?

> OIDC allows workflows to authenticate using short-lived/federated identity rather than storing long-lived cloud credentials, reducing credential exposure and rotation requirements.

---

## 10. Kubernetes

| Term | Interview answer |
|---|---|
| **Kubernetes** | Container orchestration platform that manages containerized workloads and maintains their desired state. |
| **Cluster** | Kubernetes environment consisting of the control plane and worker infrastructure. |
| **Node** | Machine that runs Kubernetes workloads. |
| **Pod** | Smallest deployable Kubernetes unit, containing one or more containers sharing networking and storage context. |
| **Deployment** | Kubernetes object that manages stateless application Pods and their desired replica count. |
| **ReplicaSet** | Ensures the desired number of Pod replicas exist; usually managed by a Deployment. |
| **Service** | Provides a stable network endpoint for accessing a set of Pods. |
| **ClusterIP** | Service type providing internal cluster connectivity. |
| **NodePort** | Exposes a service through a port on each node. |
| **LoadBalancer** | Service type that can provision/expose an external load balancer through a cloud provider. |
| **Ingress** | Defines HTTP/HTTPS routing from external clients to Kubernetes services. |
| **ConfigMap** | Stores non-sensitive configuration data. |
| **Secret** | Stores sensitive configuration data such as credentials. |
| **PVC** | PersistentVolumeClaim used by workloads to request persistent storage. |
| **`kubectl`** | Command-line tool used to interact with Kubernetes clusters. |
| **Desired state** | The state the user declares Kubernetes should maintain. |
| **Reconciliation** | Kubernetes continuously works to make actual state match desired state. |

### Controller model

```text
Deployment
    ↓
ReplicaSet
    ↓
Pods
    ↓
Containers
```

If a Pod dies:

```text
Pod dies
  ↓
Actual state ≠ desired state
  ↓
Controller reconciles
  ↓
Replacement Pod
```

---

## 11. Kubernetes Troubleshooting

| Term | Interview answer |
|---|---|
| **CrashLoopBackOff** | Container repeatedly starts and crashes/exits; Kubernetes progressively delays restart attempts. |
| **ImagePullBackOff** | Kubernetes cannot successfully pull the required container image and backs off before retrying. |
| **`kubectl logs`** | Displays logs from a container in a Pod. |
| **`kubectl logs --previous`** | Shows logs from the previous crashed container instance. |
| **`kubectl describe pod`** | Displays detailed Pod information and events useful for troubleshooting. |
| **Liveness probe** | Determines whether a container should be restarted. |
| **Readiness probe** | Determines whether a Pod should receive traffic. |

### Critical distinction

```text
CrashLoopBackOff
→ Image started
→ Application crashes

ImagePullBackOff
→ Image couldn't be obtained
→ Application never starts
```

---

## 12. Identity & Security

| Term | Interview answer |
|---|---|
| **Authentication** | Verifies who an identity is. |
| **Authorization** | Determines what an authenticated identity is allowed to do. |
| **IAM / RBAC** | Mechanisms for assigning permissions to identities through roles and policies. |
| **Least privilege** | Give an identity only the permissions it actually requires, at the narrowest practical scope. |
| **Managed Identity** | Cloud-managed identity that lets workloads authenticate to supported services without storing credentials in the application. |
| **Service account** | Identity representing an application/workload rather than a human user. |
| **Role** | Collection of permissions that can be assigned to an identity. |
| **Scope** | Level/resource at which a permission is assigned. |
| **Secret manager** | Service designed to securely store and retrieve sensitive credentials and secrets. |
| **Encryption at rest** | Protects stored data using encryption. |
| **Encryption in transit** | Protects data while it travels between systems, commonly using TLS. |
| **Defense in depth** | Uses multiple independent security controls so failure of one doesn't expose the entire system. |
| **Attack surface** | Collection of entry points that could potentially be exploited by an attacker. |

### Never get this distinction wrong

```text
Authentication  → Who are you?
Authorization   → What can you do?
RBAC / IAM     → How permissions are assigned
Least privilege → How much permission should you have?
```

---

## 13. Secrets / Key Management

| Term | Interview answer |
|---|---|
| **Key Vault / Secret Manager** | Centralized service for securely storing and controlling access to secrets, keys and certificates. |
| **Hardcoded secret** | Credential embedded in source/configuration; dangerous because it can leak through repositories, logs, images or deployments. |
| **Secret rotation** | Replacing credentials periodically or when compromise is suspected to reduce exposure. |
| **Key vs secret** | A secret is sensitive data such as a password; a cryptographic key is used for encryption/signing operations. |

### Application secret access

> Use a workload identity or managed identity to authenticate to a secret-management service and grant it only the permission required to read the necessary secret.

---

## 14. Storage

| Term | Interview answer |
|---|---|
| **Object storage** | Stores data as objects and is commonly used for files, backups, media and static content. |
| **Block storage** | Provides block-level storage typically attached to VMs. |
| **File storage** | Provides shared filesystem-style storage accessible by multiple clients. |
| **Persistent storage** | Storage designed to survive the lifecycle of an individual application/container instance. |
| **Ephemeral storage** | Temporary storage whose contents can disappear when the underlying workload is replaced. |

---

## 15. Databases

| Term | Interview answer |
|---|---|
| **Replication** | Maintaining copies of database data on other instances/systems. |
| **Primary/replica** | Primary handles writes while replicas receive replicated data and may serve reads/failover depending on architecture. |
| **Synchronous replication** | Primary waits for the required replica acknowledgement before completing a write; stronger consistency but can introduce latency. |
| **Asynchronous replication** | Primary doesn't wait for remote replication acknowledgement; lower latency but potential replication lag/data loss. |
| **Failover** | Moving service from a failed primary to a healthy secondary. |
| **Caching** | Keeping frequently accessed data closer to the application to reduce latency and backend load. |
| **Cache hit** | Requested data is found in cache. |
| **Cache miss** | Requested data isn't in cache and must be retrieved from the backend. |
| **Database backup** | Recoverable copy of data used primarily for restoring from corruption, deletion or disaster. |

### Critical distinction

```text
Replication → availability / failover
Backup      → recovery / data protection
Caching     → performance
```

---

## 16. Observability

| Term | Interview answer |
|---|---|
| **Observability** | Ability to understand system behavior from outputs such as metrics, logs and traces. |
| **Metric** | Numerical measurement collected over time, such as CPU, latency or request rate. |
| **Log** | Detailed record of an event generated by an application or system. |
| **Trace** | Follows an individual request through multiple components/services. |
| **Dashboard** | Visual representation of metrics and system health information. |
| **Alert** | Notification generated when a defined condition or threshold requires attention. |
| **Telemetry** | Data collected from systems, including metrics, logs and traces. |

### Remember

```text
Metrics → What's happening?
Logs    → What happened?
Traces  → Where did it happen?
```

---

## 17. Cloud Troubleshooting

### Generic troubleshooting framework

```text
1. Define the exact symptom
2. Determine scope / impact
3. Check recent changes
4. Map the request path
5. Check metrics
6. Check logs
7. Check networking
8. Check identity / authorization
9. Check dependencies
10. Form a hypothesis
11. Test the hypothesis
12. Remediate and verify
```

### Don't guess

Bad:

```text
Application slow
      ↓
Increase VM size
```

Better:

```text
Application slow
      ↓
CPU normal
      ↓
Trace request
      ↓
Database latency high
      ↓
Investigate DB
```

---

## 18. HTTP Status Codes

| Code | Meaning |
|---|---|
| **200** | Request succeeded. |
| **301/302** | Redirect. |
| **400** | Client sent an invalid request. |
| **401** | Authentication is required/failed. |
| **403** | Request is understood but access is forbidden. |
| **404** | Requested resource wasn't found. |
| **429** | Too many requests / rate limiting. |
| **500** | Server-side application error. |
| **502** | Gateway/proxy received an invalid response from upstream. |
| **503** | Service currently unavailable. |
| **504** | Gateway/proxy timed out waiting for upstream response. |

### Remember

```text
401 → Authentication problem
403 → Authorization/access problem
```

---

## 19. Architecture

### Single Point of Failure

> A component whose failure can cause the entire service to become unavailable.

### Stateless Application

> Application instances don't rely on local state, making them easier to replace and horizontally scale.

### Load Balancing

> Distributes traffic across healthy instances to improve availability, scalability and sometimes latency.

### Multi-AZ

> Distributes workloads across independent availability zones to reduce the impact of a zone-level failure.

### Multi-Region

> Deploys workloads across geographically separated regions to improve resilience against regional failures and potentially reduce latency for geographically distributed users.

### Active-Active

> Multiple regions/instances actively serve traffic simultaneously.

### Active-Passive

> One environment serves traffic while another is maintained as standby for failover.

### Blue/Green

> Two environments exist simultaneously; traffic is switched from the old environment to the new one.

### CDN

> Serves cacheable content from locations closer to users, reducing latency and origin load.

---

## 20. DevOps Concepts

| Term | Interview answer |
|---|---|
| **DevOps** | Culture and practices that bring development and operations together through automation, collaboration and continuous delivery. |
| **Infrastructure as Code** | Infrastructure managed through version-controlled configuration rather than manual provisioning. |
| **Configuration management** | Automating and maintaining system/application configuration consistently. |
| **Continuous Integration** | Frequently integrating code and automatically validating it through builds/tests. |
| **Continuous Delivery** | Keeping software in a deployable state through automated validation and packaging. |
| **Continuous Deployment** | Automatically deploying validated changes to production. |
| **Artifact** | Immutable output of a build that can be promoted through environments. |
| **GitOps** | Managing infrastructure/application desired state through Git and automated reconciliation. |
| **Environment** | Isolated deployment context such as development, staging or production. |
| **Rollback** | Returning to a previous known-good application/infrastructure version. |
| **Monitoring** | Collecting and presenting system health information. |
| **Alerting** | Automatically notifying operators when actionable conditions occur. |
| **SRE** | Engineering discipline focused on reliability, availability and operational performance. |
| **SLI** | Measured indicator of service performance, such as latency or availability. |
| **SLO** | Target level for an SLI, such as 99.9% availability. |
| **SLA** | Formal service-level commitment, often contractual. |

### SLI / SLO / SLA

```text
SLI → What do we measure?
SLO → What target do we want?
SLA → What commitment do we make?
```

---

## 21. Cloud Cost Optimization

| Term | Interview answer |
|---|---|
| **Right-sizing** | Choosing resource capacity appropriate for actual workload requirements instead of overprovisioning. |
| **Autoscaling** | Automatically adjusting resources based on workload demand. |
| **Reserved/committed capacity** | Discount mechanism for committing to resource usage for a period. |
| **Idle resources** | Resources consuming money without providing useful workload capacity. |
| **Cost allocation/tagging** | Assigning metadata to resources so costs can be attributed to teams, applications or environments. |
| **FinOps** | Discipline combining engineering, finance and business decisions to optimize cloud spending. |

> **Architecture principle:** Don't build the most sophisticated architecture. Build the simplest architecture that satisfies the requirements.

---

## 22. Azure → GCP Translation

**Learn the concept first, provider name second.**

| Generic concept | Azure | GCP |
|---|---|---|
| Cloud identity | Entra ID | IAM |
| Authorization | Azure RBAC | IAM roles |
| VM | Azure VM | Compute Engine |
| Virtual network | VNet | VPC |
| Subnet | Subnet | Subnet |
| Network security | NSG | VPC Firewall Rules |
| Object storage | Blob Storage | Cloud Storage |
| Kubernetes | AKS | GKE |
| Container registry | ACR | Artifact Registry |
| Secret management | Key Vault | Secret Manager |
| Monitoring | Azure Monitor | Cloud Monitoring |
| Logging | Log Analytics | Cloud Logging |
| DNS | Azure DNS | Cloud DNS |
| Load balancing | Azure Load Balancer / Application Gateway | Cloud Load Balancing |
| IaC | Terraform | Terraform |
| CI/CD | GitHub Actions | GitHub Actions / Cloud Build |

---

# 23. The 15 Answers to Know Cold

### 1. What is a container?

> An isolated application process that packages its dependencies while sharing the host kernel.

### 2. Container vs VM?

> A VM runs its own OS/kernel; a container shares the host kernel and is therefore generally lighter.

### 3. What is Terraform?

> An Infrastructure-as-Code tool that declaratively provisions and manages infrastructure.

### 4. What is Terraform state?

> Terraform's record of the infrastructure it manages and its relationship to the configuration.

### 5. What is CI/CD?

> Automated processes for building, testing, validating and delivering software changes.

### 6. What is Kubernetes?

> A container orchestration platform that maintains the desired state of containerized workloads.

### 7. What happens when a Kubernetes Pod dies?

> A controller such as a Deployment detects the difference between desired and actual state and creates a replacement Pod.

### 8. What is RBAC?

> A permission model where roles containing permissions are assigned to identities at defined scopes.

### 9. Authentication vs authorization?

> Authentication establishes who you are; authorization determines what you're allowed to do.

### 10. What is least privilege?

> Giving an identity only the permissions it needs at the narrowest practical scope.

### 11. How should applications handle secrets?

> Store them in a dedicated secret-management service and access them using workload/managed identity rather than hardcoding credentials.

### 12. RTO vs RPO?

> RTO is how quickly service must be restored; RPO is how much data loss is acceptable.

### 13. Metrics vs logs vs traces?

> Metrics show what's happening, logs explain what happened, and traces show where a request spent time across components.

### 14. How do you troubleshoot a cloud incident?

> Define the symptom, establish scope, check changes, locate the failing layer, inspect metrics/logs/network/identity, form a hypothesis and test it.

### 15. How do you design highly available infrastructure?

> Remove single points of failure through redundancy across appropriate failure domains, use health-based traffic distribution and define the design from availability, latency, RTO, RPO and cost requirements.

---

# 24. Interview Mindset

## Don't answer like this

> "Azure has X service that does Y."

## Answer like this

> **Requirement → design choice → trade-off → implementation.**

### Example: Why use two regions?

**Weak:**

> "Because Azure has regions."

**Strong:**

> "Because the application has geographically distributed users and requires resilience against a regional failure. I'd evaluate latency, data residency, RTO/RPO and cost before deciding whether multi-region is justified."

### Example: Why use a standby region?

> "If the RTO allows recovery time rather than continuous active service, an active-passive design can provide regional disaster recovery at lower cost and complexity than active-active. The standby strategy still needs to satisfy the required RTO and the data replication strategy must satisfy the RPO."

### Example: Why not give a VM Owner permissions?

> "Owner violates least privilege and creates a large blast radius if the identity is compromised. I'd grant only the specific roles required, such as image-pull and secret-read permissions, at the narrowest practical scope."

---

# 25. Golden Rules

1. **Understand the requirement before choosing a service.**
2. **Don't confuse authentication with authorization.**
3. **Use least privilege.**
4. **Don't hardcode secrets.**
5. **Don't assume a running VM means the application is healthy.**
6. **Don't assume a healthy backend means the entire request path works.**
7. **Don't destroy infrastructure just because Terraform partially failed.**
8. **Don't treat `CrashLoopBackOff` as the root cause.**
9. **Don't treat replication as a replacement for backups.**
10. **Don't add multi-region architecture without a business requirement.**
11. **Don't add caching without identifying the performance bottleneck.**
12. **Don't scale vertically just because an application is slow.**
13. **Use metrics, logs and traces together.**
14. **Isolate the failing layer before changing things.**
15. **Explain architecture using requirements and trade-offs, not product names.**

---

# Final Mental Model

When given almost any cloud interview scenario, think:

```text
                    BUSINESS REQUIREMENTS
                           |
          +----------------+----------------+
          |                |                |
       Traffic          Availability      Data
       & Users            & SLA          RTO/RPO
          |                |                |
          +----------------+----------------+
                           |
                           v
                      ARCHITECTURE
                           |
       +-------------------+-------------------+
       |                   |                   |
    Network              Compute              Data
       |                   |                   |
       +-------------------+-------------------+
                           |
                    Identity / Security
                           |
                     Observability
                           |
                      HA / DR
                           |
                         Cost
```

> **The goal isn't to know every cloud service. The goal is to understand the problem, choose an appropriate design, explain the trade-offs, and troubleshoot it when it fails.**
