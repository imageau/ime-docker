ARG ENV=development

FROM node:21-alpine as base

# Install pnpm
RUN npm install -g pnpm

# Install additional system dependencies if your project requires them
RUN apk add --no-cache curl

WORKDIR /app

EXPOSE 3000
HEALTHCHECK --start-period=1m --interval=30s --timeout=3s --retries=3 \
    CMD curl -f 127.0.0.1:3000 || exit 1

FROM base as development
CMD sh -c "pnpm install && pnpm run dev || trap 'exit 0' SIGTERM; while true; do sleep 3600 & wait $!; done";

FROM base as preview
CMD sh -c "pnpm install && pnpm run build && pnpm run start || trap 'exit 0' SIGTERM; while true; do sleep 3600 & wait $!; done";

FROM base as production

ARG FRONT_PATH=./src/front

# Copy files and install dependencies if in production mode
COPY $FRONT_PATH /app

CMD sh -c "pnpm install && pnpm run build && pnpm run start || trap 'exit 0' SIGTERM; while true; do sleep 3600 & wait $!; done";

# Final stage based on the environment
FROM $ENV as final