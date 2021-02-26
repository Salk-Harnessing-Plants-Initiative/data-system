FROM public.ecr.aws/lambda/python:3.7

# Copy requirements
COPY Pipfile ${LAMBDA_TASK_ROOT}
COPY Pipfile.lock ${LAMBDA_TASK_ROOT}

# Install dependencies
RUN pip install pipenv
RUN pipenv install --system --deploy --ignore-pipfile

# Copy code
COPY . ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD ["lambda_function.lambda_handler" ]