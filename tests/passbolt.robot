*** Settings ***
Library    SSHLibrary
Resource    api.resource

*** Keywords ***
Retry test
    [Arguments]    ${keyword}
    Wait Until Keyword Succeeds    60 seconds    1 second    ${keyword}

Backend URL is reachable
    ${rc} =    Execute Command    curl -f ${backend_url}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

*** Test Cases ***
Check if passbolt is installed correctly
    ${output}  ${rc} =    Execute Command    add-module ${IMAGE_URL} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
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
    ${output} =    Execute Command    curl -s ${backend_url}
    Should Contain    ${output}    <title>Passbolt

Check if passbolt is removed correctly
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0
