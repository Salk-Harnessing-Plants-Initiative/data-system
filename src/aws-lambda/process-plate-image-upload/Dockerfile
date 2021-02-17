# See example at (https://gallery.ecr.aws/lambda/python)
FROM public.ecr.aws/lambda/python:3.8

# Install EPEL so that zbar can be found and installed (https://fedoraproject.org/wiki/EPEL)
# I picked the RHEL/CentOS 7 version by trial and error, simply because RHEL/CentOS 8 doesn't work
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# I have no idea why I have to install this dependency
# As you can see I have reached a very deep layer of dependency hell
# Basically we need urw-base35-fonts-legacy to be able to install GraphicsMagick which in turn we need
# to install zbar
# http://yuminstall.org/how-to-install-urw-base35-fonts-legacy-20170801-10-el7-noarch-on-centos7/
# Honestly this Docker is sitting on a house of cards and it is quite nerve-wracking
# If some day someone has to remake this Lambda from scratch, use any language/etc. as long as you are using zbar
# It's probably wiser to just run this as a service in EC2 so that you can have zbar installed there
RUN yum install wget -y
RUN wget http://mirror.centos.org/centos/7/os/x86_64/Packages/urw-base35-fonts-legacy-20170801-10.el7.noarch.rpm
RUN yum install urw-base35-fonts-legacy-20170801-10.el7.noarch.rpm -y

# Install zbar shared library: the thing we wanted all along!
RUN yum install -y zbar

# Copy requirements.txt
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Install python packages, including pyzbar (Python API to zbar)
RUN pip install -r requirements.txt

# Copy the rest of the function code
COPY . ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "app.lambda_handler" ]