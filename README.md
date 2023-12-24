# hostconfig/https
Welcome to hostconfig/https.

A mini express TLS-enabled https server, with out-of-the-box support for static HTML and API routes.

To start:

```
yarn build && yarn start
```

*or*

```
docker compose up --build
```

The ```app = express()``` object will be served at ```localhost:443``` over an http server.

*NOTE:* The above may require elevated priviliges to run.

## TLS-enabled

Generate a self-signed TLS certificate:

```
yarn gen:ssl
```

You will be asked to create, and *many* times to repeat, a secure passphrase by the openSSL cli. A set of TLS certificates with certificate authority signature will be placed in a new ```.certs``` directory at the project root. If attempting to build in Docker, this directory must be present for the build to succeed (please see troubleshooting for more).

The generated output should resemble the following:

```
.certs
└── CA
    ├── CA.key
    ├── CA.pem
    └── localhost
        ├── localhost.crt
        ├── localhost.csr
        ├── localhost.decrypted.key
        ├── localhost.ext
        └── localhost.key
docs
src
...
```

You may install the provided certificate(s) on your host machine by usual means; the script will also attempt to use the ```nssdb``` library's ```certutil``` script to store a copy in the Mozilla backend storage, also used by browsers such as Chrome (at the time of writing).

For toubleshooting tips, see below.


## Debug mode

Additionally, a debug mode can be activated:

```
yarn dbg
```

## Test mode

Additionally, a test mode can be activated:

```
yarn test
```

See the ```test``` directory for an example.

## Health check

In all three modes, a healthcheck request will be sent periodically to:

```
/health
```

See the ```test``` directory for an example.

## Troubleshooting

Attempting to run Docker before generating the certificates per the instructions will likely cause the Docker build to fail, because the builder attempts to copy the certificates from your local disk (where you can use them further) instead of generating them inside of the Docker environment. A shell script named 'generate.sh' is provided which will create the required certificates in a new ```.certs/``` directory. As long as this is placed at the root of the 'https' sub-module, the Docker build should succeed. Please be vigilante about the useage of self-signed certificates; these are generally only to be used for local development purposes and should not be shared publically.

Every host (operating system) and client (browser, API) can have differing means and capabilities for managing SSL/TLS certificates and other HTTP-related settings.

For Windows and MacOS machines, one can often simply double-click on valid SSL/TLS certificates on disk, and this will launch a native installer with recommended settings based on the content of the certificate. For Linux machines (and Docker containers), the process can vary greatly. As a suggestion to begin with, typically for Ubuntu (22.04) and Alpine Linux operating systems:

- Copy the generated ```localhost.crt``` file into ```/usr/local/share/ca-certificates``` (may require sudo)
- Run ```sudo update-ca-certificates``` and the new key(s) found in the above directory will be added to the store in ```/etc/ssl``` correctly

*Note that the above steps are performed inside the Docker virtual environment as part of the build script, meaning that your Docker environment will already be configured appropriately so long as it finds the required ```.certs/``` directory in the project root directory.*

The server source code in ```src/index.ts``` is already pointing at the location of the script-generated certificates - a Yarn post-build step automatically copies the certificates from the generated location to this required output location; however, this can easily be disturbed by small changes to the project without due diligence. Until a more rigourous solution presents itself, be vigilante about making sure these paths match, if you *do* make changes to the source code. In the case of invalid input being found where the TLS certificate and key are expected, an error is thrown and logged to the server; the server will proceed to run, but will not be accessible since there is no valid TLS cert or key loaded.

If the above is set up correctly, then it should be possible to verify a secure connection using openSSL at this point:

```
openssl s_client -connect localhost:443
```

The above command should issue and return a successful handshake, allow a connection between client and server, pass some data, and then close the connection successfully.

Regarding browser support; this has been tested and is working successfully on latest Chrome, Edge, and Mozilla browsers; the typical TLS certificate installation procedure requires you to go to the usual ```settings > security ``` section(s) of the configuration tab, and choose to manage your SSL/TLS/HTTP-based web security certificates. In almost all cases, one is presented with tabs for different certificate policies - usually, the browser will require you to import the ```localhost.crt``` *and* the ```CA.pem``` files, which might be supported on different tabs; the file-picker for each possible option usually reverts to looking for sensible file types that it expects, so if for example the '.pem' file does not make itself to the file-picker, try importing it under a different tab section - and if asked, choose to trust the certificate for web content.

## Further reading:

- NodeJs TLS/SSL documentation: [https://nodejs.org/docs/latest-v4.x/api/tls.html](https://nodejs.org/docs/latest-v4.x/api/tls.html#tls_tls_ssl)

## Acknowledgments:

The ```generate.sh``` script is taken almost ad-verbatim from this excellent article from Lewel Murithi:

- [https://www.section.io/engineering-education/how-to-get-ssl-https-for-localhost](https://www.section.io/engineering-education/how-to-get-ssl-https-for-localhost/)

Thank you Lewel!

Further tips on the content of the article/script can be found in the NodeJs documentation linked above.

### Thanks for reading!

[Nathan J. Hood](https://github.com/nathanjhood)
