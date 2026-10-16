# Deploy and Host SkillHub on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/skillhub-registry?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=skillhub-registry)

[SkillHub](https://github.com/iflytek/skillhub) is iFLYTEK's open-source, self-hosted registry for AI agent skills: the `SKILL.md` packages used by Claude Code, Codex, OpenClaw and other agents. Your team publishes skills to it, and every upload is checked by a security scanner before it goes live. Skills are organised in namespaces with roles and review, and versions are kept. Agents install skills with one CLI command. It also speaks the ClawHub registry protocol, so existing ClawHub-style clients can point at it.

## About Hosting SkillHub

This template runs the official `v0.2.22` images as five services:

| Service | What it does |
| --- | --- |
| **SkillHub** | The web app (nginx) on your Railway domain. It proxies `/api` to the server. |
| **server** | The Spring Boot API. Skill packages are stored on its volume. |
| **scanner** | The skill security scanner. Every uploaded package is checked for risky behaviour before release. |
| **Postgres** | Users, namespaces, skills and versions |
| **Redis** | Sessions and the scan queue |

- **Admin account, no default password.** On first boot the server creates the user `admin` with a generated password, `BOOTSTRAP_ADMIN_PASSWORD` on the **server** service. Upstream ships the publicly known `ChangeMe!2026`.
- **Sign-up closed by default.** SkillHub `v0.2.x` lets anyone with the URL create an account, and every new account gets its own namespace to publish into. The web service blocks the sign-up endpoint unless you set `SKILLHUB_ALLOW_SIGNUP=true`. OAuth sign-in works once you configure it.
- **HTTPS-correct.** Session cookies are `Secure`. nginx trusts Railway's forwarded protocol, and the public URL is wired in, so the CLI install commands the UI shows point at your domain.
- **Bounded memory.** The JVM heap is capped with `-Xmx512m`. Without the cap, the JVM sizes its heap from the plan's RAM limit, not from what the registry needs.

## Common Use Cases

- A private skill registry for a company's Claude Code, Codex or Cursor users: publish internal skills once, and install them everywhere with one command
- Scan third-party agent skills for risky behaviour before your team installs them
- Run a public or community skill hub on your own domain, with namespaces per team and an admin review step

## Dependencies for SkillHub Hosting

- Postgres and Redis (included)
- Optional: OAuth apps (GitHub, GitLab, OIDC, Feishu, DingTalk) for single sign-on, SMTP for password resets, and an LLM API key for the scanner's AI analyzer

### Deployment Dependencies

- [SkillHub on GitHub](https://github.com/iflytek/skillhub)
- [SkillHub user guide](https://iflytek.github.io/skillhub/)
- [Template source on GitHub](https://github.com/nomideusz/skillhub-railway)

### Implementation Details

**Sign in.** Open the **SkillHub** service's domain and log in as `admin`, using `BOOTSTRAP_ADMIN_PASSWORD` from the **server** service's Variables tab. Change the password in your profile afterwards. The variable is only read when the account is first created.

**Publish and install from the CLI.** In the web UI, create an API token under your profile. Then:

```bash
npm install -g @astron-team/skillhub
export SKILLHUB_REGISTRY=https://<your-domain>
skillhub login --token sk_...
skillhub publish ./my-skill --namespace global
skillhub search ""
skillhub install my-skill --agent claude-code   # or codex, cursor, ...
```

A skill is a folder with a `SKILL.md` file that has `name` and `description` in its front matter. Each upload is scanned first. A finding of `high` severity or worse blocks the release.

**Let people in.** SkillHub `v0.2.x` has no screen for an admin to create users. Either:

- Set `SKILLHUB_ALLOW_SIGNUP=true` on the **SkillHub** service and redeploy while your team signs up, then set it back to `false`.
- Or set up single sign-on on the **server** service.

Either way, admins can promote or disable users under the admin pages. For GitHub single sign-on, set `OAUTH2_GITHUB_CLIENT_ID` and `OAUTH2_GITHUB_CLIENT_SECRET`, with the callback `https://<your-domain>/login/oauth2/code/github`. GitLab, OIDC, Feishu and DingTalk follow the same pattern; see the upstream `.env.release.example`.

**Smarter scans.** The scanner's default analyzers are rule-based and need no key. To add its LLM analyzer, set `SKILL_SCANNER_LLM_API_KEY`, `SKILL_SCANNER_LLM_MODEL` and optionally `SKILL_SCANNER_LLM_BASE_URL` on **scanner**, then set `SKILLHUB_SCANNER_USE_LLM=true` and `SKILLHUB_SCANNER_LLM_PROVIDER` on **server**.

**Upgrades.** Change the image tag on **server** and **scanner**. On the **SkillHub** service, change the `SKILLHUB_WEB_IMAGE` build argument in your fork's Dockerfile. Database migrations run automatically when the server starts.

**Resources.** Measured on Railway, idle after the first boot:

| Service | RAM |
| --- | --- |
| server | about 750 MB |
| scanner | about 150 MB |
| Postgres | about 120 MB |
| SkillHub web and Redis | about 60 MB together |
| **Total** | **about 1.1 GB** |

The Java server is over the Free plan's 0.5 GB per service and close to the Trial plan's 1 GB, so use the Hobby plan or higher.

## Why Deploy SkillHub on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying SkillHub on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
