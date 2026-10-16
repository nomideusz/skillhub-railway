ARG SKILLHUB_WEB_IMAGE=ghcr.io/iflytek/skillhub-web:v0.2.22
FROM ${SKILLHUB_WEB_IMAGE}
COPY 25-signup.sh /docker-entrypoint.d/25-signup.sh
RUN chmod +x /docker-entrypoint.d/25-signup.sh
