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
    git

WORKDIR /opt/app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

ENV NODE_ENV=production
RUN npm run build

EXPOSE 1337

RUN mkdir -p /opt/app/.tmp /opt/app/public/uploads \
    && chown -R node:node /opt/app
USER node

CMD ["npm", "start"]
