*** Settings ***
Library    SSHLibrary

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

Check if passbolt works as expected
    ${rc} =    Execute Command    sleep 10 && curl -H "Host: passbolt.fqdn.test" -fkL https://127.0.0.1/
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if passbolt is removed correctly
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0
