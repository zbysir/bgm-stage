FROM node:12-alpine AS builder

COPY . .

RUN npm install
RUN npm run-script build

FROM nginx
COPY --from=builder ./dist/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
