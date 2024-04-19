# Getting started

Add `127.0.0.1 emi.imageau.local api.emi.imageau.local` in `/etc/hosts/` file, then run:

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

https://emi.imageau.local/

# Database administration

http://localhost:8080/?server=db&username=ime&db=ime
