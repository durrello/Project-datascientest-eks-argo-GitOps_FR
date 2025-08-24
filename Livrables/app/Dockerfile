FROM node:19-alpine3.15

WORKDIR /reddit-clone

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 3000
CMD ["npm", "run", "start"] # or "dev" if for dev environment
