# MyFirstGitApp – Full Stack Dockerized Documentation

---

## Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Services](#services)
- [Project Structure](#project-structure)
- [Setup & Prerequisites](#setup--prerequisites)
- [Getting Started](#getting-started)
  - [Environment Variables](#environment-variables)
  - [Docker Compose](#docker-compose)
  - [Frontend (Next.js)](#frontend-nextjs)
  - [Backend (Quarkus)](#backend-quarkus)
  - [Keycloak SSO](#keycloak-sso)
  - [Database (Postgres)](#database-postgres)
- [Authentication Flow](#authentication-flow)
- [Troubleshooting](#troubleshooting)
- [Customizations](#customizations)

---

## Overview

**MyFirstGitApp** is a full-stack application template with:

- Next.js frontend (with `next-auth` and Keycloak SSO integration)
- Quarkus-based Java backend
- Keycloak for authentication and authorization
- PostgreSQL as the relational database
- Docker Compose for orchestration
- Nginx as a reverse proxy in production

---

## Architecture

```
[User] <--> [nginx:80] <--> [frontend:3000] <--> [backend:8080] <--> [postgres:5432]
                   |                            |
                   +----------[keycloak:8089]<--+
```

---

## Services

- **frontend**: Next.js server app with next-auth (runs on port 3000)
- **backend**: Java (Quarkus) application (port 8080)
- **keycloak**: SSO server for authentication (exposed on host at port 8089, internal 8080)
- **postgres**: Relational DB (exposed on host at port 5432)
- **nginx**: Reverse proxy for the frontend (exposed on host at port 80, proxies to frontend:3000)

---

## Project Structure

```
MyFirstGitApp/
│
├── backend/
│   └── backend/           # Quarkus Java Backend
│
├── frontend/              # Next.js Frontend (with next-auth)
│   ├── pages/
│   ├── public/
│   ├── .env.local         # (Create/set for secrets)
│   ├── Dockerfile
│   └── nginx.conf         # Nginx reverse proxy config
│
├── keycloak-import/       # Keycloak realm and config import
├── docker-compose.yml     # Docker Compose stack definition
└── README.md
```

---

## Setup & Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)
- [Docker Compose](https://docs.docker.com/compose/)
- (Optional) [Node.js](https://nodejs.org/) (for direct frontend dev)

---

## Getting Started

### 1. **Environment Variables**

Create a `frontend/.env.local` file (if not using only Compose env vars):

```
KEYCLOAK_CLIENT_ID=myapp-client
KEYCLOAK_CLIENT_SECRET=<your-actual-keycloak-client-secret>
KEYCLOAK_ISSUER=http://keycloak:8080/realms/myapp
NEXTAUTH_SECRET=<your-next-auth-secret>
```

- Get the Keycloak client secret from the Keycloak admin UI.

### 2. **Start the Full Stack with Docker Compose**

From the project root:
```sh
docker-compose down -v          # Stop and clean up old volumes/containers (optional)
docker-compose up --build -d    # Build and start everything in detached mode
```

- Frontend: [http://localhost](http://localhost)
- Backend: [http://localhost:8080](http://localhost:8080)
- Keycloak admin: [http://localhost:8089](http://localhost:8089)
- Postgres: port 5432 on localhost

---

### Frontend (Next.js)

- The app is built in server mode and served on port 3000 in the container.
- Nginx reverse proxies port 80 to port 3000 for production-like URL.
- Uses next-auth with Keycloak for authentication.

### Backend (Quarkus)

- Java Quarkus project.
- Connects to Postgres.
- Exposed at [http://localhost:8080](http://localhost:8080).

### Keycloak SSO

- Pre-configured with a `myapp` realm and the `myapp-client`.
- Default admin user:  
  - Username: `admin`
  - Password: `admin`

### Database (Postgres)

- Persistent volume (`pgdata`).
- Credentials as set in `docker-compose.yml`.

---

## Authentication Flow

1. User opens [http://localhost](http://localhost).
2. Clicks "Login with Keycloak" → redirected to Keycloak.
3. After login, redirected back with a session established (via next-auth).
4. Sign out with the "Sign out" button.

---

## Troubleshooting

- **403 or 500 after Keycloak login:** Check environment variables―client secret, issuer/URL, and Keycloak status.
- **Connection refused to Keycloak:** Ensure service name is `keycloak` and issuer URL is `http://keycloak:8080/realms/myapp` for containers.
- **Files not rebuilding:** Use `docker-compose build --no-cache frontend` to force image rebuild.
- **Port conflicts:** Ensure nothing else is running on host ports 80, 3000, 8080, or 8089.

---

## Customizations

- **Add frontend features:** Edit files in `frontend/pages` or related directories.
- **Extend backend:** Add or modify Quarkus endpoints in `backend/backend/src/main/java/`.
- **Change SSO config:** Edit the content in `keycloak-import/` and replace as needed.
- **Database migrations:** Use standard Postgres tooling or Quarkus migration scripts.

---

## Stopping and Cleaning Up

To stop and remove containers, networks, and volumes:

```sh
docker-compose down -v
```

---

For further development instructions, see the README files in each subdirectory.

---

**If you have questions, issues, or need customization, open an issue or ask the project maintainer.**