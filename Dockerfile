FROM node:20-bookworm-slim

WORKDIR /app

COPY package.json package-lock.json .npmrc ./
RUN npm ci

COPY . .

EXPOSE 3000

CMD ["sh", "-c", "npm run sources && npm exec -- evidence dev --host 0.0.0.0"]
