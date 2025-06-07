## Launch Postgres

* **Note 1**: edit `launch.sh` and change the container IP  (`subjectAltName = IP:<container ip>`) accordingly.
    - edit `/etc/hosts` if necessary to assign `postgres.local` and the name
      for the container IP.
* **Note 2**: launching container in interactive mode, replace `docker -it` with
`docker -d` for using daemon mode.

```bash
POSTGRES_USER="$(whoami)" ./launch.sh
```

## Root Access

Using host user as Postgres Root

```bash
POSTGRES_USER="$(whoami)" ./run.sh
```

## Create New User

**Note**: The certificates for each new user are created in a local folder
named as the same as the user.


```
POSTGRES_USER="newuser" ./create_user.sh
```

## New User Access

**Note**: Use the certs created for the user for login.

```
CERTS=newuser POSTGRES_USER=newuser ./run.sh
```
