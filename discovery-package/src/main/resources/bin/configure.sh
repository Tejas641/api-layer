#!/bin/sh

################################################################################
# This program and the accompanying materials are made available under the terms of the
# Eclipse Public License v2.0 which accompanies this distribution, and is available at
# https://www.eclipse.org/legal/epl-v20.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Copyright IBM Corporation 2019, 2020
################################################################################

# Source main utils script
. ${ROOT_DIR}/bin/utils/utils.sh
ensure_java_is_on_path

# TODO - do we need 2 zosmf entries?
# Add static definition for zosmf
cat <<EOF >${STATIC_DEF_CONFIG_DIR}/zosmf.ebcidic.yml
# Static definition for z/OSMF
#
# Once configured you can access z/OSMF via the API gateway:
# curl -k -X GET -H "X-CSRF-ZOSMF-HEADER: *" https://${ZOWE_EXPLORER_HOST}:${GATEWAY_PORT}/api/v1/zosmf/info
#
services:
    - serviceId: zosmf
      title: z/OSMF
      description: IBM z/OS Management Facility REST API service
      instanceBaseUrls:
        - https://${ZOSMF_HOST}:${ZOSMF_PORT}/zosmf/
      homePageRelativeUrl:  # Home page is at the same URL
      routedServices:
        - gatewayUrl: api/v1
          serviceRelativeUrl:
      authentication:
          scheme: zosmf
      apiInfo:
        - apiId: com.ibm.zosmf
          gatewayUrl: api/v1
          documentationUrl: https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.izua700/IZUHPINFO_RESTServices.htm
      customMetadata:
          apiml:
              enableUrlEncodedCharacters: true

    - serviceId: ibmzosmf
      title: IBM z/OSMF
      description: 'IBM z/OS Management Facility REST API service. Once configured you can access z/OSMF via the API gateway: https://${ZOWE_EXPLORER_HOST}:${GATEWAY_PORT}/api/v1/ibmzosmf/zosmf/info'
      catalogUiTileId: zosmf
      instanceBaseUrls:
        - https://${ZOSMF_HOST}:${ZOSMF_PORT}/
      homePageRelativeUrl:  # Home page is at the same URL
      routedServices:
        - gatewayUrl: api/v1
          serviceRelativeUrl:
      authentication:
          scheme: zosmf
      apiInfo:
        - apiId: com.ibm.zosmf
          gatewayUrl: api/v1
          documentationUrl: https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.izua700/IZUHPINFO_RESTServices.htm
          swaggerUrl: https://${ZOSMF_HOST}:${ZOSMF_PORT}/zosmf/api/docs
      customMetadata:
          apiml:
              enableUrlEncodedCharacters: true
catalogUiTiles:
    zosmf:
        title: z/OSMF services
        description: IBM z/OS Management Facility REST services
EOF
iconv -f IBM-1047 -t IBM-850 ${STATIC_DEF_CONFIG_DIR}/zosmf.ebcidic.yml > $STATIC_DEF_CONFIG_DIR/zosmf.yml
rm ${STATIC_DEF_CONFIG_DIR}/zosmf.ebcidic.yml
chmod 770 $STATIC_DEF_CONFIG_DIR/zosmf.yml