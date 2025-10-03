# FROM node:24.7.0
FROM node:20-alpine

ENV NODE_ENV="development"
ENV WDS_SOCKET_PORT=0

# # Arguments
# ARG VITE_ORDER_API
# ENV VITE_ORDER_API=$VITE_ORDER_API

WORKDIR /client

COPY package*.json ./
COPY tsconfig*.json ./
COPY vite.config.ts ./

RUN npm install

COPY . .

RUN npm run build

EXPOSE 5173
# CMD ["npm", "start"]
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
