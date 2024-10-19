#!/bin/bash
set -x
touch hello.txt
# rm owt/management_console/cert/certificate.pfx
# cp owt/certificate.pfx owt/management_console/cert/certificate.pfx
# rm owt/portal/cert/certificate.pfx
# cp owt/certificate.pfx owt/portal/cert/certificate.pfx
# rm owt/management_api/cert/certificate.pfx
# cp owt/certificate.pfx owt/management_api/cert/certificate.pfx
# rm owt/apps/current_app/cert/certificate.pfx
# cp owt/certificate.pfx owt/apps/current_app/cert/certificate.pfx
./startowt.sh --rabbit rabbitmq:7990 --mongo mongoadmin:mongopasswd@mongo-db/admin --externalip 172.17.0.1 --network_interface docker0