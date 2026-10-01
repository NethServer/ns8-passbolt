*** Settings ***
Library    SSHLibrary
Resource    api.resource

*** Variables ***
${ADMIN_USER}    admin
${ADMIN_PASSWORD}    Nethesis,1234
${SCENARIO}    install

*** Keywords ***
Login to cluster-admin
    New Page    https://${NODE_ADDR}/cluster-admin/
    Fill Text    text="Username"    ${ADMIN_USER}
    Click    button >> text="Continue"
    Fill Text    text="Password"    ${ADMIN_PASSWORD}
    Click    button >> text="Log in"
    Wait For Elements State    css=#main-content    visible    timeout=10s

Retry test
    [Arguments]    ${keyword}
    Wait Until Keyword Succeeds    60 seconds    1 second    ${keyword}

Backend URL is reachable
    ${rc} =    Execute Command    curl -f ${backend_url}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Add module
    [Arguments]    ${image}
    ${output}  ${rc} =    Execute Command    add-module ${image} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    RETURN    ${output}

Passbolt SQL
    [Arguments]    ${query}
    # The query goes through stdin, so its quotes cannot clash with the shell wrapper
    ${out} =    Execute Command    echo "${query}" | runagent -m ${module_id} podman exec -i passbolt-db sh -c 'mariadb -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" -N'
    RETURN    ${out}

Server key fingerprint
    ${out} =    Execute Command    runagent -m ${module_id} podman exec -u www-data passbolt-app sh -c "gpg --homedir /var/lib/passbolt/.gnupg --with-colons --show-keys /etc/passbolt/gpg/serverkey.asc | grep ^fpr | head -1 | cut -d: -f10"
    Should Not Be Empty    ${out}
    RETURN    ${out}

Passbolt checks pass
    ${out} =    Execute Command    runagent -m ${module_id} podman exec -u www-data passbolt-app /usr/share/php/passbolt/bin/cake passbolt healthcheck
    # Other checks depend on the test node: no public URL, SMTP or SSL
    FOR    ${check}    IN    The application is able to connect to the database    The database schema is up to date    The server metadata private key is valid
        Should Contain    ${out}    [PASS] ${check}
    END

*** Test Cases ***
Check if passbolt is installed correctly
    # The update scenario starts from the NS8 stable release, then upgrades it below.
    # passbolt is published in NethForge, which a new node has disabled.
    IF    '${SCENARIO}' == 'update'
        Run task    cluster/alter-repository    {"name":"nethforge","status":true}
        ${output} =    Wait Until Keyword Succeeds    5 times    10 seconds    Add module    passbolt
    ELSE
        ${output} =    Add module    ${IMAGE_URL}
    END
    &{output} =    Evaluate    ${output}
    Set Suite Variable    ${module_id}    ${output.module_id}

Check if passbolt can be configured
    ${rc} =    Execute Command    api-cli run module/${module_id}/configure-module --data '{"host": "passbolt.fqdn.test","lets_encrypt": false,"admin_email": "admin@test.local"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Retrieve passbolt backend URL
    # Assuming the test is running on a single node cluster
    ${response} =    Run task     module/traefik1/get-route    {"instance":"${module_id}"}
    Set Suite Variable    ${backend_url}    ${response['url']}

Check if passbolt works as expected
    Retry test    Backend URL is reachable

Verify passbolt frontend title
    ${output} =    Execute Command    curl -s ${backend_url}/auth/login
    Should Contain    ${output}    <title>Passbolt

Check passbolt is healthy
    Passbolt checks pass

Check the administrator and the server key exist
    ${admin} =    Passbolt SQL    SELECT id FROM users WHERE username='admin@test.local'
    Should Not Be Empty    ${admin}    configure-module did not register the administrator
    Set Suite Variable    ${admin_id}    ${admin}
    ${migrations} =    Passbolt SQL    SELECT COUNT(*) FROM phinxlog
    Set Suite Variable    ${migrations_before}    ${migrations}
    ${fpr} =    Server key fingerprint
    Set Suite Variable    ${fingerprint}    ${fpr}

Update passbolt to the image under test
    Skip If    '${SCENARIO}' != 'update'    scenario is ${SCENARIO}, nothing to update
    ${rc} =    Execute Command
    ...    api-cli run update-module --data '{"force":true,"module_url":"${IMAGE_URL}","instances":["${module_id}"]}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check passbolt works after the update
    Skip If    '${SCENARIO}' != 'update'    scenario is ${SCENARIO}, nothing to update
    Retry test    Backend URL is reachable
    Wait Until Keyword Succeeds    30 times    5 seconds    Passbolt checks pass
    ${output} =    Execute Command    curl -s ${backend_url}/auth/login
    Should Contain    ${output}    <title>Passbolt

Check the configuration survives the update
    Skip If    '${SCENARIO}' != 'update'    scenario is ${SCENARIO}, nothing to update
    ${config} =    Run task    module/${module_id}/get-configuration    {}
    Should Be Equal    ${config['host']}    passbolt.fqdn.test
    Should Be Equal    ${config['admin_email']}    admin@test.local
    Should Be True    ${config['admin_created']}

Check the data and the server key survive the update
    Skip If    '${SCENARIO}' != 'update'    scenario is ${SCENARIO}, nothing to update
    ${admin} =    Passbolt SQL    SELECT id FROM users WHERE username='admin@test.local'
    Should Be Equal    ${admin}    ${admin_id}
    ${migrations} =    Passbolt SQL    SELECT COUNT(*) FROM phinxlog
    Should Be True    ${migrations} >= ${migrations_before}    migrations were lost
    # A new server key would make every stored secret unreadable
    ${fpr} =    Server key fingerprint
    Should Be Equal    ${fpr}    ${fingerprint}

Take screenshots
    [Tags]    ui
    Import Library    Browser
    New Browser    chromium    headless=True
    New Context    ignoreHTTPSErrors=True
    Login to cluster-admin
    Go To    https://${NODE_ADDR}/cluster-admin/#/apps/${module_id}
    Wait For Elements State    iframe >>> h2 >> text="Status"    visible    timeout=10s
    Sleep    5s
    Take Screenshot    filename=${OUTPUT DIR}/browser/screenshot/1._Status.png
    Go To    https://${NODE_ADDR}/cluster-admin/#/apps/${module_id}?page=settings
    Wait For Elements State    iframe >>> h2 >> text="Settings"    visible    timeout=10s
    Sleep    5s
    Take Screenshot    filename=${OUTPUT DIR}/browser/screenshot/2._Settings.png
    Close Browser

Check if passbolt is removed correctly
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0
