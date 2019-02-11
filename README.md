![SAP HANA Academy](https://yt3.ggpht.com/-BHsLGUIJDb0/AAAAAAAAAAI/AAAAAAAAAVo/6_d1oarRr8g/s100-mo-c-c0xffffffff-rj-k-no/photo.jpg)
# Setup Python Runtime for XSA #

### Tutorial Video ### 
In the video tutorial, we show how you –using SAP HANA, express edition running in Google Cloud, as example — how to prepare the OS environment, how to build Python and create the runtime. A simple test script generates a sample app to validate all is well in the best possible worlds.
[![Setup Python Run Time for XSA](https://img.youtube.com/vi/loi28PvDZVI/0.jpg)](https://www.youtube.com/watch?v=loi28PvDZVI " Setup Python Run Time for XSA")

### Tutorial Video Playlist ### 
The tutorials has been posted to the following playlist:
[SAP HANA XS Advanced(XSA)](https://www.youtube.com/playlist?list=PLkzo92owKnVwL3AWaWVbFVrfErKkMY02a)

### SAP HANA, express edition on GCP ###
We used the SAP HANA, express edition on Google Cloud Platform (server+applications) for this sample code. You can use the following commands to download the sample code to your system. 
```
sudo -i
su - hxeadm
cd $HOME
git clone https://github.com/saphanaacademy/python
cd python
chmod u+x *.sh
./create-python-runtime.sh
./test-python-runtime.sh
```
### Compilers and More ###
The SAP HANA Developer Guide documents the following packages as requirements:
```
# as root
zypper install tk-devel tcl-devel libffi-devel \
 openssl-devel readline-devel sqlite3-devel \
 ncurses-devel xz-devel zlib-devel
```
In addition, you can install the Basis-Devel pattern for the compilers and dependencies. Patterns differ per repository, so should Basis-Devel not be present, try and search for an equivalent. 
```
# as root
zypper search -t pattern 
zypper in -t pattern Basis-Devel
```
### Create Runtime ###
You can download the Python source code from https://www.python.org/downloads/source/. There are many versions available. In the create runtime script, we take the version (e.g. 3.8.0, 3.6.5) as input together with any suffix (e.g. a01, rc1). The SUSE Linux operating system comes with a Python version installed as does SAP HANA, express edition. To avoid any interference with these installation, run "make altinstall" and configure with prefix. 

Note that the path here is a hardcoded HXE. If you are not using the express edition, change the path to the SID. 
```
# create work directories
cd ~ ; mkdir -p builds source Downloads
# download source to Downloads
wget -P ~/Downloads -N https://www.python.org/ftp/python/$1/Python-$1$2.tgz
# extract to source
tar xzvf ~/Downloads/Python-$1$2.tgz -C ~/source
# configure to "install" in builds directory
cd ~/source/Python-$1$2
./configure \
--prefix=/usr/sap/HXE/home/builds/Python-$1$2 \
--exec-prefix=/usr/sap/HXE/home/builds/Python-$1$2 \
--enable-optimizations
# make, install and cleanup
make altinstall clean
# Upload runtime and list
xs create-runtime -p ~/builds/Python-$1$2
xs runtimes
```
### Test Runtime ###
The test script generates the required files for a simple Hello World python script. 
```
cd ~; mkdir -p pyapp; cd pyapp
# create runtime.txt
cat > runtime.txt <<EOF
export python-$1
EOF
# create requirements.txt
cat > requirements.txt <<EOF
Flask==0.12.2
EOF
# create manifest.yaml
cat > manifest.yml << EOF
---
applications:
- name: pyapp
  host: pyapp
  path: .
  command: python server.py
EOF
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
```
To upload the app, we switch to the development space and push (upload) the app to the runtime. For housekeeping, we delete the app first (if present). Note that “development” is one of the spaces available out-of-the-box with SAP HANA, express edition. If you are working on a regular platform edition, you might need to change the name otherwise xs push will default to the ‘SAP’ space (not recommended).
```
# switch to development space, delete any existing pyapp, upload app
xs target -s development
xs delete -f pyapp
xs push
```

For the documentation, see
* [Building from Sources and Deploying the Python Run Time to XS Advanced - SAP HANA Developer Guide for SAP HANA XS Advanced Model](https://help.sap.com/viewer/4505d0bdaf4948449b7f7379d24d0f0d/2.0.03/en-US/681f48593a1a46e595f8bfde1cfe0048.html)
