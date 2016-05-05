#!/usr/bin/zsh

source /home/memilian/.zshaliases
#khamake html5 --server &

BROWSER=chromium

function watchdir () {
  rm "$1"
  cd Sources
  ls -l **/* > ../"$1" 2>&-;
  ls -l * >> ../"$1"
  cd ..
}

watchdir tmp.last
echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
while true; do
  sleep 1

  watchdir tmp.new

  NEW=`cat tmp.new`
  LAST=`cat tmp.last`
  if [ "$NEW" != "$LAST" ]; then
    node /home/memilian/dev/lib/Kha/Tools/khamake/khamake.js html5
    cp -r build/html5-resources/* ../resources
    cp -r build/html5/* ../resources
    watchdir tmp.last
  fi
done

#chromium "http://localhost:8080"
