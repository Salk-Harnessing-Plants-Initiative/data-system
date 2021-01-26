FROM public.ecr.aws/lambda/python:3.7

# Copy code
COPY . ${LAMBDA_TASK_ROOT}

# Install dependencies
RUN pip install --upgrade requests
RUN pip install pipenv
RUN pipenv install --system --deploy --ignore-pipfile

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD ["lambda_function.lambda_handler" ]