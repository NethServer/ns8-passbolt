# ns8-passbolt

[Passbolt](https://www.passbolt.com/) Community Edition module: a password manager for teams.

## Install

Instantiate the module with:

    add-module ghcr.io/nethserver/passbolt:latest 1

The output of the command will return the instance name.
Output example:

    {"module_id": "passbolt1", "image_name": "passbolt", "image_url": "ghcr.io/nethserver/passbolt:latest"}

## Configure

Let's assume that the passbolt instance is named `passbolt1`.

Launch `configure-module`, by setting the following parameters:
- `host`: Fully qualified domain name of the passbolt instance
- `lets_encrypt`: Enable or disable Let's Encrypt certificate

Example:

    api-cli run module/passbolt1/configure-module --data '{"host": "passbolt.gs.nethserver.net", "lets_encrypt": false}'

The above command will:

- start and configure the passbolt instance
- redirect from HTTP to HTTPs is enforced

Send a test HTTP request to the passbolt backend service:

    curl https://passbolt.gs.nethserver.net/


### Create admin user

After first configuration, the admin user is created.
Visit the web page provided in the banner to complete the admin registration process.

### Reset passbolt

If the hostname was configured wrong, passbolt needs to be reset. In the following example the app instance passbolt1 is resetted:

```
runagent -m passbolt1
systemctl --user stop passbolt
podman volume rm -a
rm admin_url.env
```

Another method is to reinstall Passbolt.

## Smarthost setting discovery

Some configuration settings, like the smarthost setup, are not part of the
`configure-module` action input: they are discovered by looking at some
Redis keys.  To ensure the module is always up-to-date with the
centralized [smarthost
setup](https://nethserver.github.io/ns8-core/core/smarthost/) every time
passbolt starts, the command `bin/discover-smarthost` runs and refreshes
the `state/smarthost.env` file with fresh values from Redis.

Furthermore if smarthost setup is changed when passbolt is already
running, the event handler `events/smarthost-changed/10reload_services`
restarts the main module service.

See also the `systemd/user/passbolt.service` file.

This setting discovery is just an example to understand how the module is
expected to work: it can be rewritten or discarded completely.

## Uninstall

To uninstall the instance:

    remove-module --no-preserve passbolt1

## Testing

Test the module using the `test-module.sh` script:


    ./test-module.sh <NODE_ADDR> ghcr.io/nethserver/passbolt:latest

The tests are made using [Robot Framework](https://robotframework.org/)

## UI translation

Translated with [Weblate](https://hosted.weblate.org/projects/ns8/).

To setup the translation process:

- add [GitHub Weblate app](https://docs.weblate.org/en/latest/admin/continuous.html#github-setup) to your repository
- add your repository to [hosted.weblate.org]((https://hosted.weblate.org) or ask a NethServer developer to add it to ns8 Weblate project
