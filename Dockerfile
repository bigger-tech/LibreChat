# v0.7.3

# Base node image
FROM node:20-alpine AS node

RUN apk --no-cache add curl python3 py3-pip nfs-utils

# Create a virtual environment at /venv
RUN python3 -m venv /venv

# Activate the virtual environment and install botocore
RUN /venv/bin/pip install botocore

# Set environment variables to use the virtual environment for Python and pip
ENV PATH="/venv/bin:$PATH"

RUN mkdir -p /app && chown node:node /app
WORKDIR /app

USER node

COPY --chown=node:node . .
COPY --chown=node:node .env.defaults .env
COPY librechat.yaml librechat.yaml

RUN \
    # Create directories for the volumes to inherit the correct permissions
    mkdir -p /app/client/public/images /app/api/logs ; \
    npm config set fetch-retry-maxtimeout 600000 ; \
    npm config set fetch-retries 5 ; \
    npm config set fetch-retry-mintimeout 15000 ; \
    npm install --no-audit; \
    # React client build
    NODE_OPTIONS="--max-old-space-size=2048" npm run frontend; \
    npm prune --production; \
    npm cache clean --force

RUN mkdir -p /app/client/public/images /app/api/logs

# Node API setup
EXPOSE 3080
ENV HOST=0.0.0.0
CMD ["npm", "run", "backend:prod"]

# Optional: for client with nginx routing
# FROM nginx:stable-alpine AS nginx-client
# WORKDIR /usr/share/nginx/html
# COPY --from=node /app/client/dist /usr/share/nginx/html
# COPY client/nginx.conf /etc/nginx/conf.d/default.conf
# ENTRYPOINT ["nginx", "-g", "daemon off;"]
