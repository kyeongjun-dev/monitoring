FROM node:20.11-alpine

WORKDIR /app
ENV PORT=3000
EXPOSE 3000

COPY ./my-app/ ./

RUN ls
RUN npm install
CMD ["npm", "run", "dev"]