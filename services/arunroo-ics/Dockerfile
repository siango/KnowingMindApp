# Cloud Run container
FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./ 2>/dev/null || :
RUN npm ci || npm install
COPY tsconfig.json ./
COPY src ./src
RUN npm run build
ENV PORT=8080
EXPOSE 8080
CMD ["npm","start"]
