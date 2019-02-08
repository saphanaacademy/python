#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo 'Usage:'
    echo 'test-python-runtime.sh "release"'
    echo 'e.g.: test-python-runtime.sh 3.8.0'
    exit 0
fi
echo
echo 'Creating test app for Python. Open URL in browser.'
echo

cd ~
mkdir -p pyapp; cd pyapp

# create runtime.txt 
cat > runtime.txt <<EOF
export python-$1
EOF

echo [runtime.txt]
cat runtime.txt
echo

# create requirements.txt 
cat > requirements.txt <<EOF
Flask==0.12.2
EOF

echo [requirements.txt]
cat requirements.txt
echo

# create manifest.yaml 
cat > manifest.yml << EOF 
---
applications:
- name: pyapp
  host: pyapp
  path: .
  command: python server.py
EOF

echo [manifest.yml]
cat manifest.yml
echo

# create server.py 
cat > server.py << EOF
import os
from flask import Flask
app = Flask(__name__)
port = int(os.environ.get('PORT', 3000))
@app.route('/')
def hello():
    return "Hello World from Python $1"
if __name__ == '__main__':
    app.run(port=port)
EOF

echo [server.py]
cat server.py
echo

# switch to development space, delete any existing pyapp, upload app
xs target -s development
xs delete -f pyapp
xs push
