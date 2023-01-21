
FROM		alpine:3.17
ARG			PYTHON_DIR='/usr/lib/python3.10/site-packages'
ARG			ANSIBLE_COLLECTIONS_DIR=${PYTHON_DIR}'/ansible_collections'
ARG			TMP_ANSIBLE_COLLECTIONS_DIR='/tmp/ansible_collections'
RUN			apk add --no-cache ansible openssh sshpass rsync \
			&& mkdir -p ${TMP_ANSIBLE_COLLECTIONS_DIR} \
			&& mv ${ANSIBLE_COLLECTIONS_DIR}/ansible \
			      ${TMP_ANSIBLE_COLLECTIONS_DIR}/ansible \
			&& rm -rf ${ANSIBLE_COLLECTIONS_DIR}/* \
			&& mv ${TMP_ANSIBLE_COLLECTIONS_DIR}/ansible \
			      ${ANSIBLE_COLLECTIONS_DIR}/ansible \
			&& rm -rf ${ANSIBLE_COLLECTIONS_DIR}/ansible/*/tests \
			&& rm -rf ${PYTHON_DIR}/ansible_test \
			&& rm -rf /var/cache/apk/* \
			&& rm -rf /tmp/*
ENTRYPOINT	[ "/usr/bin/ansible" ]
