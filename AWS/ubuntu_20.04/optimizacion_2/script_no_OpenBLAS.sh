#!/bin/bash
#Virginia region
DEBIAN_FRONTEND=noninteractive
DEB_BUILD_DEPS="build-essential python3-dev python3-pip python3-setuptools software-properties-common libgit2-dev dirmngr libgmp3-dev libmpfr-dev"
DEB_PACKAGES="sudo nano less time git curl wget htop graphviz"
PIP_PACKAGES="numpy scipy matplotlib pandas seaborn sympy cvxpy pytest dask distributed bokeh jupyter-book networkx ortools line_profiler memory_profiler psutil guppy3 cython numba graphviz jedi==0.17.2 awscli"
R_KEY="E298A3A825C0D65DFD57CBB651716619E084DAB9"
R_DEB_BUILD_DEPS="focal-cran40 r-base libssl-dev libxml2-dev libcurl4-openssl-dev"
USER=ubuntu
JUPYTERLAB_VERSION=3.0.0
LANG=C.UTF-8
LC_ALL=C.UTF-8
R_SITE_LIBRARY="/usr/local/lib/R/site-library"
R_PACKAGES="\"repr IRdisplay evaluate crayon pbdZMQ devtools uuid digest CVXR tidyverse tictoc microbenchmark\""

apt-get update && export $DEBIAN_FRONTEND && apt-get install -y tzdata

apt-get update && apt-get install -y $DEB_BUILD_DEPS $DEB_PACKAGES && pip3 install --upgrade pip

# Install nodejs deps
curl -sL https://deb.nodesource.com/setup_12.x |sudo -E bash - && apt-get install -y nodejs

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $R_KEY && \
add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" && \
apt-get update && \
apt-get install -yt $R_DEB_BUILD_DEPS

#install next packages for ubuntu user

sudo -H --preserve-env -u $USER bash << EOF

#NOTE: Is better to install first PIP_PACKAGES and then JUPYTER
export PATH=/home/$USER/.local/bin:$PATH

pip3 install --user jupyter jupyterlab==$JUPYTERLAB_VERSION

~/.local/bin/jupyter notebook --generate-config && sed -i "s/# c.NotebookApp.password = .*/c.NotebookApp.password = u'sha1:115e429a919f:21911277af52f3e7a8b59380804140d9ef3e2380'/" /home/$USER/.jupyter/jupyter_notebook_config.py

pip3 install --user $PIP_PACKAGES

#c kernel in jupyter

pip3 install --user git+https://github.com/brendan-rius/jupyter-c-kernel.git && python3 /home/$USER/.local/lib/python3.8/site-packages/jupyter_c_kernel/install_c_kernel --prefix=/home/$USER/.local/

#r kernel in jupyter
sudo chmod gou+wrx $R_SITE_LIBRARY
R -e 'install.packages(strsplit($R_PACKAGES, " ")[[1]], lib="/usr/local/lib/R/site-library/")' && \
R -e 'devtools::install_github("IRkernel/IRkernel")' && \
R -e 'IRkernel::installspec()' #or:R -e 'IRkernel::installspec(user=FALSE)'

#julia kernel in jupyter

sudo mkdir /usr/local/julia-1.6.0
cd
wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.0-linux-x86_64.tar.gz
tar zxvf julia-1.6.0-linux-x86_64.tar.gz

sudo cp -r julia-1.6.0/* /usr/local/julia-1.6.0/ 

/usr/local/julia-1.6.0/bin/julia -e 'using Pkg;Pkg.add("IJulia")' && \
/usr/local/julia-1.6.0/bin/julia -e 'using Pkg;Pkg.add(Pkg.PackageSpec(name="JuMP", rev="master"))' && \
/usr/local/julia-1.6.0/bin/julia -e 'using Pkg;Pkg.add("ECOS");Pkg.add("OSQP");Pkg.add("SCS");Pkg.add("GLPK");Pkg.add("Optim")'

~/.local/bin/jupyter lab --ip=0.0.0.0 --no-browser

EOF
