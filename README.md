# Getting started

Add `127.0.0.1 myapp.local api.myapp.local` in `/etc/hosts/` file, then run:

```sh
cp .env.example .env
./scripts/init.sh
```

To (re)start all services, run:

```sh
./restart
```

To stop all services, run:

```sh
./stop
```

# Running commands

```sh
./artisan command
./composer command
./pnpm command
```

# Front

https://myapp.local/

# Database administration

http://localhost:8080/?server=db&username=user&db=myapp
