#!/bin/sh
# SkillHub v0.2.x has no switch for self-registration, so a public URL is an open
# registry. Block the sign-up endpoint here unless SKILLHUB_ALLOW_SIGNUP=true.
# The file matches the template's `include /etc/nginx/skillhub-base-path*.conf`.
conf=/etc/nginx/skillhub-base-path-signup.conf
if [ "${SKILLHUB_ALLOW_SIGNUP:-false}" = "true" ]; then
  rm -f "$conf"
else
  cat > "$conf" <<'NGINX'
location ~ /api/v1/auth/local/register {
    default_type application/json;
    return 403 '{"code":403,"msg":"Sign-up is disabled on this SkillHub. Ask an admin for an account, or set SKILLHUB_ALLOW_SIGNUP=true on the web service."}';
}
NGINX
fi
