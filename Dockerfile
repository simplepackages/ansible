
ARG			ALPINE_VERSION
FROM		alpine:${ALPINE_VERSION}
ARG			ANSIBLE_VERSION
ARG			PYTHON_DIR='/usr/lib/python3.*/site-packages'
RUN			apk add --no-cache ansible-core=${ANSIBLE_VERSION}-r0 openssh sshpass rsync py3-pip \
			&& rm -rf ${PYTHON_DIR}/ansible_test \
			&& pip install --no-cache-dir --break-system-packages passlib \
			&& apk del py3-pip \
			&& rm -rf /var/cache/apk/* \
			&& rm -rf /root/.cache/pip \
			&& rm -rf /tmp/*
ENTRYPOINT	[ "/usr/bin/ansible" ]
