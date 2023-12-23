import https from 'https'

const options = {
  timeout: 2000,
  host: "localhost",
  protocol: 'https:',
  port: process.env.PORT || 443,
  path: "/health" // must be the same as HEALTHCHECK in Dockerfile
};

const request = https.request(options, res => {
  console.info("STATUS: " + res.statusCode);
  process.exitCode = res.statusCode === 200 ? 0 : 1;
  process.exit()
})

request.on("error", function(err) {
  console.error("ERROR", err)
  process.exit(1)
})

request.end()
