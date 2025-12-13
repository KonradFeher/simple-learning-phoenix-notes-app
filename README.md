# Collab Notes Web App
### A project using DevOps tooling
---

#### Requirements to run locally

- git
- docker, docker compose
- Your user should be part of the `docker` (`sudo usermod -aG docker $USER && newgrp docker`), to avoid having to sudo

#### Usage

- `git clone https://github.com/KonradFeher/simple-learning-phoenix-notes-app`
- `cd simple-learning-phoenix-notes-app`
- `make up` (This should get you up and running, more commands available in Makefile)

- Access the site in your browser:
  - Notes app: http://localhost:8888
  
---

#### Accessible at

##### (local dev)
```
    Web app: localhost:8888
    Postgres DB: localhost:5432
```

##### (deployed, prod)
```
    Web app: notes.devops.157451.xyz
    Grafana: grafana.devops.157451.xyz (admin, admin)
    Prometheus: prometheus.devops.157451.xyz
```
[Grafana dashboard](https://grafana.devops.157451.xyz/d/adxsbv2/main-dashboard-update)

> Note: in production, all ports are proxied via Caddy and TLS-enabled domains.
> This should be accessible if my tiny shared CPU VPS holds out. (prone to crashing, not usable as of yet, lacking a mailer)

---

#### About the application

A web application built in **Elixir/Phoenix** for note-taking and basic CRUD functionality.  

Features:

- Create, read, update, and delete notes.
- User authentication with email/password and "remember me".
- Option to collaborate with other users on notes.
- Metrics exported via **PromEx** and available in **Prometheus**.
- Dashboards and visualization in **Grafana**.

---

#### Technologies used  

- Backend: **Elixir**, **Phoenix**, **Ecto**
- Frontend: **TailwindCSS**, **esbuild**, **Phoenix LiveView**  
- Database: PostgreSQL
---

#### DevOps tools used

- **Docker** (for both local dev and production deployments)
- **Git**
- **GitHub Actions**
  - CI
    - Runs tests
    - Runs **Credo** static code analysis
  - CD
    - Deploys application to my Kamatera VPS
- **Terraform** (DNS management via Porkbun)
- **Prometheus**, **Grafana** (for monitoring, in production composition)
- **Caddy** (TLS, reverse proxy)
- **Makefile** (helper commands for local development)

---

