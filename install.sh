#!/bin/bash

# exit on fail
set -e

#chromebrew directories
OWNER="skycocker"
REPO="chromebrew"
BRANCH="master"
URL="https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}"
CREW_PREFIX="${CREW_PREFIX:-/usr/local}"
CREW_LIB_PATH="${CREW_PREFIX}/lib/crew/"
CREW_CONFIG_PATH="${CREW_PREFIX}/etc/crew/"
CREW_BREW_DIR="${CREW_PREFIX}/tmp/crew/"
CREW_DEST_DIR="${CREW_BREW_DIR}/dest"
CREW_PACKAGES_PATH="${CREW_LIB_PATH}/packages"

ARCH="$(uname -m)"

if [ "${EUID}" == "0" ]; then
  echo 'Chromebrew should not be installed or run as root.'
  exit 1;
fi

case "${ARCH}" in
"i686"|"x86_64"|"armv7l"|"aarch64")
  LIB_SUFFIX=
  [ "${ARCH}" == "x86_64" ] && LIB_SUFFIX='64'
  ;;
*)
  echo 'Your device is not supported by Chromebrew yet.'
  exit 1;;
esac

# This will allow things to work without sudo
sudo chown -R "$(id -u)":"$(id -g)" "${CREW_PREFIX}"

# prepare directories
for dir in "${CREW_CONFIG_PATH}/meta" "${CREW_DEST_DIR}" "${CREW_PACKAGES_PATH}"; do
  if [ ! -d "${dir}" ]; then
    mkdir -p "${dir}"
  fi
done

# prepare url and sha256
# install only gcc8, ruby, libiconv, git and libssh2 (order matters)
urls=()
sha256s=()
case "${ARCH}" in
"aarch64")
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/gcc8-8.3.0-chromeos-armv7l.tar.xz')
  sha256s+=('fbd8a589befb3d10400af6e4975d02a6940bab4907628f8fc0d6913ea89f70ae')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libressl-3.0.2-2-chromeos-armv7l.tar.xz')
  sha256s+=('3fa0ddc595f4973667126e09db28fe6bb2dd78e7a6a7952967adc88fc15bcbcb')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/ruby-2.7.1-chromeos-armv7l.tar.xz')
  sha256s+=('8808b9bc9b55206781ea706008f405a12083af15839ff69d96434674004baee8')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libiconv-1.16-chromeos-armv7l.tar.xz')
  sha256s+=('daee13f0eef96fb2d65a06d129f702cacbf8c70747d7f0dd2d27a9df977372b7')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/git-2.28.0-chromeos-armv7l.tar.xz')
  sha256s+=('9dc3d4d3f7ec5a59fd84f4c8db738cec07ce0cc2e0587774ea1b65e877056f63')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libssh2-1.9.0-chromeos-armv7l.tar.xz')
  sha256s+=('497e146e4d769aa85b0d547889784d7552e2aadbbaa448df5bbe9515cd94c182')
  ;;
"armv7l")
  if ! type "xz" > /dev/null; then
    urls+=('https://github.com/snailium/chrome-cross/releases/download/v1.8.1/xz-5.2.3-chromeos-armv7l.tar.gz')
    sha256s+=('4dc9f086ee7613ab0145ec0ed5ac804c80c620c92f515cb62bae8d3c508cbfe7')
  fi
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/gcc8-8.3.0-chromeos-armv7l.tar.xz')
  sha256s+=('fbd8a589befb3d10400af6e4975d02a6940bab4907628f8fc0d6913ea89f70ae')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libressl-3.0.2-2-chromeos-armv7l.tar.xz')
  sha256s+=('3fa0ddc595f4973667126e09db28fe6bb2dd78e7a6a7952967adc88fc15bcbcb')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/ruby-2.7.1-chromeos-armv7l.tar.xz')
  sha256s+=('8808b9bc9b55206781ea706008f405a12083af15839ff69d96434674004baee8')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libiconv-1.16-chromeos-armv7l.tar.xz')
  sha256s+=('daee13f0eef96fb2d65a06d129f702cacbf8c70747d7f0dd2d27a9df977372b7')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/git-2.28.0-chromeos-armv7l.tar.xz')
  sha256s+=('9dc3d4d3f7ec5a59fd84f4c8db738cec07ce0cc2e0587774ea1b65e877056f63')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libssh2-1.9.0-chromeos-armv7l.tar.xz')
  sha256s+=('497e146e4d769aa85b0d547889784d7552e2aadbbaa448df5bbe9515cd94c182')
  ;;
"i686")
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/gcc8-8.3.0-chromeos-i686.tar.xz')
  sha256s+=('4d625e92969fde16c1a92601740e22c07331f8056452edf7cf0bf2c1c88aa152')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libressl-3.0.2-2-chromeos-i686.tar.xz')
  sha256s+=('71187f8e35218a94809de75caecb458c356e2800b0366a2833e04071b9fc5dec')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/ruby-2.7.1-chromeos-i686.tar.xz')
  sha256s+=('5544e722fb76733df5fb3734db4bed818668b11fbb01f9484b1c85f78fd442c6')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libiconv-1.16-chromeos-i686.tar.xz')
  sha256s+=('a7afa407d80bc94038711a636f10cf9af7fae7fce5b68220f4d9c51eca44849e')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/git-2.28.0-chromeos-i686.tar.xz')
  sha256s+=('a2cddf407c167a4d309511a22fc15717ddb9bac44f8b7120e2523e475794a906')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libssh2-1.9.0-chromeos-i686.tar.xz')
  sha256s+=('dd2172bf82e3ffc1cfd06463108a36de55ba5e4bc2eb283852b54a737e087fe4')
  ;;
"x86_64")
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/gcc8-8.3.0-chromeos-x86_64.tar.xz')
  sha256s+=('ae8c8c33e4090f7fdbd39b2364754dcfc5f6bdd9a74062fde3eeb6272562f48b')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libressl-3.0.2-2-chromeos-x86_64.tar.xz')
  sha256s+=('ac5d4d2aea9c58a107a1f0e954c7ccbb5e6347292c655ed3f378d92a950499e1')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/ruby-2.7.1-chromeos-x86_64.tar.xz')
  sha256s+=('bcce410dc64861dcb57c7e72e5eedc3df79ca94d6e0d0ee32e0d14d1fd3712c0')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libiconv-1.16-chromeos-x86_64.tar.xz')
  sha256s+=('cc29b28830c4bc496b2ef495e9dd43d96e596f879d02d7176222575bb83b5088')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/git-2.28.0-chromeos-x86_64.tar.xz')
  sha256s+=('5607c0f34c5338f5709f02f6b0703ba4d40da1f7394500812f6c4e3ff9684961')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libssh2-1.9.0-chromeos-x86_64.tar.xz')
  sha256s+=('d02623da747ecc95acdba69a056220ef579b01dae82a0cbfec2aa96c2ea8e914')
  ;;
esac

# functions to maintain packages
function download_check () {
    cd "${CREW_BREW_DIR}"

    #download
    echo "Downloading ${1}..."
    curl --progress-bar -C - -L --ssl "${2}" -o "${3}"

    #verify
    echo "Verifying ${1}..."
    echo "${4}" "${3}" | sha256sum -c -
    case "${?}" in
    0) ;;
    *)
      echo "Verification failed, something may be wrong with the download."
      exit 1;;
    esac
}

function extract_install () {
    # Start with a clean slate
    rm -rf "${CREW_DEST_DIR}"
    mkdir "${CREW_DEST_DIR}"
    cd "${CREW_DEST_DIR}"

    #extract and install
    echo "Extracting ${1} (this may take a while)..."
    tar xpf ../"${2}"
    echo "Installing ${1} (this may take a while)..."
    tar cpf - ./*/* | (cd /; tar xp --keep-directory-symlink -f -)
    mv ./dlist "${CREW_CONFIG_PATH}/meta/${1}.directorylist"
    mv ./filelist "${CREW_CONFIG_PATH}/meta/${1}.filelist"
}

function update_device_json () {
  cd "${CREW_CONFIG_PATH}"

  if grep '"name": "'"${1}"'"' device.json > /dev/null; then
    echo "Updating version number of ${1} in device.json..."
    sed -i device.json -e '/"name": "'"${1}"'"/N;//s/"version": ".*"/"version": "'"${2}"'"/'
  elif grep '^    }$' device.json > /dev/null; then
    echo "Adding new information on ${1} to device.json..."
    sed -i device.json -e '/^    }$/s/$/,\
    {\
      "name": "'"${1}"'",\
      "version": "'"${2}"'"\
    }/'
  else
    echo "Adding new information on ${1} to device.json..."
    sed -i device.json -e '/^  "installed_packages": \[$/s/$/\
    {\
      "name": "'"${1}"'",\
      "version": "'"${2}"'"\
    }/'
  fi
}

# create the device.json file if it doesn't exist
cd "${CREW_CONFIG_PATH}"
if [ ! -f device.json ]; then
  echo "Creating new device.json..."
  echo '{' > device.json
  echo '  "architecture": "'"${ARCH}"'",' >> device.json
  echo '  "installed_packages": [' >> device.json
  echo '  ]' >> device.json
  echo '}' >> device.json
fi

# extract, install and register packages
for i in $(seq 0 $((${#urls[@]} - 1))); do
  url="${urls["${i}"]}"
  sha256="${sha256s["${i}"]}"
  tarfile="$(basename ${url})"
  name="${tarfile%%-*}"   # extract string before first '-'
  rest="${tarfile#*-}"    # extract string after first '-'
  version="$(echo ${rest} | sed -e 's/-chromeos.*$//')"
                        # extract string between first '-' and "-chromeos"

  download_check "${name}" "${url}" "${tarfile}" "${sha256}"
  extract_install "${name}" "${tarfile}"
  update_device_json "${name}" "${version}"
done

# workaround https://github.com/skycocker/chromebrew/issues/3305
sudo ldconfig > /dev/null 2> /dev/null || true

# create symlink to 'crew' in ${CREW_PREFIX}/bin/
rm -f "${CREW_PREFIX}/bin/crew"
ln -s "../lib/crew/crew" "${CREW_PREFIX}/bin/"

# prepare sparse checkout .rb packages directory and do it
cd "${CREW_LIB_PATH}"
rm -rf .git
git init
git remote add -f origin "https://github.com/${OWNER}/${REPO}.git"
git config core.sparsecheckout true
echo packages >> .git/info/sparse-checkout
echo lib >> .git/info/sparse-checkout
echo crew >> .git/info/sparse-checkout
git fetch origin "${BRANCH}"
git reset --hard origin/"${BRANCH}"
crew update

# install a base set of essential packages
yes | crew install buildessential less most

echo
if [[ "${CREW_PREFIX}" != "/usr/local" ]]; then
  echo "Since you have installed Chromebrew in a directory other than '/usr/local',"
  echo "you need to run these commands to complete your installation:"
  echo "echo 'export CREW_PREFIX=${CREW_PREFIX}' >> ~/.bashrc"
  echo "echo 'export PATH=\"\${CREW_PREFIX}/bin:\${CREW_PREFIX}/sbin:\${PATH}\"' >> ~/.bashrc"
  echo "echo 'export LD_LIBRARY_PATH=${CREW_PREFIX}/lib${LIB_SUFFIX}' >> ~/.bashrc"
  echo 'source ~/.bashrc'
  echo
fi
echo "To set the default PAGER environment variable to use less:"
echo "echo \"export PAGER='less'\" >> ~/.bashrc && . ~/.bashrc"
echo
echo "Alternatively, you could use most.  Why settle for less, right?"
echo "echo \"export PAGER='most'\" >> ~/.bashrc && . ~/.bashrc"
echo
echo "Below are some text editor suggestions."
echo
echo "To install 'nano', execute:"
echo "crew install nano"
echo
echo "Or, to get an updated version of 'vim', execute:"
echo "crew install vim"
echo
echo "You may wish to set the EDITOR environment variable for an editor default."
echo
echo "For example, to set 'nano' as the default editor, execute:"
echo "echo \"export EDITOR='nano'\" >> ~/.bashrc && . ~/.bashrc"
echo
echo "To set 'vim' as the default editor, execute:"
echo "echo \"export EDITOR='vim'\" >> ~/.bashrc && . ~/.bashrc"
echo
echo "Chromebrew installed successfully and package lists updated."
