FROM node:20-alpine

RUN apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    python3 \
    vips-dev \
    git \
    su-exec

WORKDIR /opt/app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

ENV NODE_ENV=production
RUN npm run build

EXPOSE 1337

# Seed mount points in the image. A fresh named volume still replaces an
# empty .tmp with a root-owned directory after this layer, so the
# entrypoint chowns the volume as root when needed and then drops to node.
RUN mkdir -p /opt/app/.tmp /opt/app/public/uploads \
    && chown -R node:node /opt/app \
    && chmod 755 /opt/app/docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["npm", "start"]
