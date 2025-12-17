### Config
NSSDB="${HOME}/.local/share/certificate-nssdb/"
CERTIFICATE_FILE= # TODO: path to .p12 certificate
CERTIFICATE_PASS= # TODO: certificate password

# Setup certificate database
if [ ! -d "${NSSDB}" ]; then
   mkdir -p "${NSSDB}"
   certutil -N -d "${NSSDB}" --empty-password
fi
# Install certificate.
pk12util -i "${CERTIFICATE_FILE}" -d "${NSSDB}" \
         -W "${CERTIFICATE_PASS}"
# Configure okular for using ICPEdu certificates
for OKULAR_CFG_FILE in \
    "${HOME}/.config/okular-generator-popplerrc" \
    "${HOME}/.var/app/org.kde.okular/config/okular-generator-popplerrc"; do
    if [ ! -e "${OKULAR_CFG_FILE}" ]; then
        mkdir -p "$(dirname "${OKULAR_CFG_FILE}")"
        touch "${OKULAR_CFG_FILE}"
    fi
    crudini --set "${OKULAR_CFG_FILE}" Signatures DBCertificatePath "file://${NSSDB}"
    crudini --set "${OKULAR_CFG_FILE}" Signatures SignatureBackend  "NSS"
    crudini --set "${OKULAR_CFG_FILE}" Signatures UseDefaultCertDB  "false"
    crudini --set "${OKULAR_CFG_FILE}" Signatures CheckOCSPServers  "false"
done
