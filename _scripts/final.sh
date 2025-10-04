#!/usr/bin/env bash

set -oeux pipefail

mkdir -p /rpms /certs
for rpm in $(find /var/cache/rpms -name '*.rpm'); do
  echo "Copying $rpm..."
  cp -a $rpm /rpms
done

sed -i -e 's/args = \["rpmbuild", "-bb"\]/args = \["rpmbuild", "-bb", "--buildroot", "#{build_path}\/BUILD"\]/g' /usr/local/share/gems/gems/fpm-*/lib/fpm/package/rpm.rb
kernel_version=$(rpm -q --qf "%{VERSION}-%{RELEASE}.%{ARCH}\n" kernel-core | head -n 1)
for rpm in $(find /rpms -type f -name \*.rpm); do
    basename=$(basename ${rpm})
    name=${basename%%-${kernel_version}*}
    if [[ "$basename" == *"$kernel_version"* ]]; then
        fpm --verbose -s rpm -t rpm -p ${rpm} -f --name ${name} ${rpm}
    else
        echo "Skipping $basename rebuild as the name does not contain $kernel_version"
    fi
done

install -Dm644 /etc/pki/akmods/certs/public_key.der /certs/eternal-akmods.der

ls -l /rpms
ls -l /certs
