# Shypple Evaluation

### How to run

Pre-installation checks
1. Validate that docker is installed.
2. Ensure that your `response.json` file is present in the project root.

To run app (run in a terminal):
1. Build docker image `docker-compose build`
2. To run application: `docker-compose run app`

To run tests (run in a terminal):
1. `make test`

### How to use

1. The app will prompt you for:
- Origin port code (e.g., CNSHA)
- Destination port code (e.g., BRSSZ)
- Criteria (`cheapest`, `fastest` or `cheapest-direct`)

2. Enter each value and press Enter.
3. Expect the output of the result.
