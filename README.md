# SQL Server Docker Project

This project provides a Docker setup for running Microsoft SQL Server with an initialization script to set up the database.

## Project Structure

```
sqlserver-docker-project
├── configure-db.sh
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
├── setup.sql
└── README.md

```

## Prerequisites

- Docker installed on your machine.
- Docker Compose installed.
- SA_PASSWORD Environment Variable for the password is set

## Getting Started

Follow these steps to build and run the SQL Server Docker container:

1. **Clone the repository** (if applicable):
   ```
   git clone <repository-url>
   cd sqlserver-docker-project
   ```

2. **Build the Docker image**:
   ```
   docker-compose build
   ```

3. **Run the Docker container**:
   ```
   docker-compose up
   ```

4. **Access SQL Server**:
   You can connect to the SQL Server instance using any SQL client with the following credentials:
   - Server: `localhost`
   - Username: `sa`
   - Password: `YourStrong@Passw0rd` (or the password specified in the SA_PASSWORD Enviroment Variable)

## Initialization Script
The `configure-db.sh` is run by the entrypoint script
to configure the database using the `setup.sql` data.

The `setup.sql` file contains SQL statements to create the necessary tables and insert initial data into the database. Make sure to review and modify it as needed for your application.

## Stopping the Container

To stop the running container, use:
```
docker-compose down -v
```

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
