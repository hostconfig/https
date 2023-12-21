import https from 'https'
import { IncomingMessage, ServerResponse } from 'node:http'

declare module '@hostconfig/https' {
  const server: https.Server<typeof IncomingMessage, typeof ServerResponse>
}
