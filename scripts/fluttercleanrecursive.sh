#!/bin/sh

# To run, download the script or copy the code to a '.sh' file (for example 'fluttercleanrecursive.sh') and run like any other script:
#   sh ./fluttercleanrecursive.sh
# or
#   sudo sh fluttercleanrecursive.sh

echo "Flutter Clean Recursive (by jeroen-meijer on GitHub Gist)"
echo "Looking for projects... (may take a while)"

find . -name "pubspec.yaml" -exec $SHELL -c '
    echo "Done. Cleaning all projects."
    for i in "$@" ; do
        DIR=$(dirname "${i}")
        echo "Cleaning ${DIR}..."
        (cd "$DIR" && flutter clean >/dev/null 2>&1)
    done
    echo "DONE!"
' {} +