FROM node:lts as dependencies
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install

FROM node:lts as builder
WORKDIR /app
COPY . .
ARG SUPABASE_URL=${SUPABASE_URL}
ARG SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
RUN echo "NEXT_PUBLIC_SUPABASE_URL=$SUPABASE_URL\nNEXT_PUBLIC_SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" > .env.local
COPY --from=dependencies /app/node_modules ./node_modules
RUN npm run build

FROM node:lts as runner
WORKDIR /app
ENV NODE_ENV production
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/.env.local ./.env.local

EXPOSE 3000
CMD ["npm", "run", "start"]