FROM public.ecr.aws/lambda/python:3.8

# Copy function code
COPY . ${LAMBDA_TASK_ROOT}

# Install dependencies
## Install EPEL so that zbar can be found and installed
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
## Install zbar shared library
RUN yum install -y zbar
## Install python packages, including pyzbar
RUN pip install -r requirements.txt

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "app.lambda_handler" ]