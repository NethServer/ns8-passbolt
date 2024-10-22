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

To create the administrator user, execute:
```
runagent -m passbolt1 podman exec -ti passbolt-app /bin/bash /usr/share/php/passbolt/bin/cake passbolt register_user -u jdoe@nethserver.org -f John -l Doe -r admin
```

Make sure to replace:
- `passbolt1`: the instance name
- `jdoe@nethserver.org`: the email address of the admin user
- `John`: the first name of the admin user
- `Doe`: the last name of the admin user


The output will be something like:
```
     ____                  __          ____  
    / __ \____  _____ ____/ /_  ____  / / /_ 
   / /_/ / __ `/ ___/ ___/ __ \/ __ \/ / __/ 
  / ____/ /_/ (__  |__  ) /_/ / /_/ / / /    
 /_/    \__,_/____/____/_.___/\____/_/\__/   

 Open source password manager for teams
-------------------------------------------------------------------------------
User saved successfully.
To start registration follow the link provided in your mailbox or here: 
https://passbolt.gs.nethserver.net/setup/start/b96b40be-b71f-46c7-938d-dffb71d9efc8/293687a9-0203-4830-93de-a6c9b8d016d9
```

Visit the URL provided in the output to complete the registration process.

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
