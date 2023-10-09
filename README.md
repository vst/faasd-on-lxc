# faasd on LXC

This repository provides an example procedure to setup [OpenFaaS], in particular
its [faasd], on a [Linux Container] using [cloud-init].

## Quickstart

Enter the Nix shell provisioned by this repository:

```sh
nix-shell
```

Launch a Linux container with our `cloud-init.yaml` file based on the latest
Ubuntu LTS:

```sh
lxc launch ubuntu:22.04 faasd --config=user.user-data="$(cat cloud-init.yaml)"
```

> **Note**
>
> The file `cloud-init.yaml` includes a `ssh_import_id` statement that contains
> key to my GitHub SSH public key. You need to change it.

Watch cloud-init finishing its job:

```sh
lxc exec faasd -- cloud-init status --wait
```

> **Note**
>
> Linux container may reboot if installed/upgraded packages require the
> container to do so. In this case, you may need to run the above command again.

See the IP address of the Linux container:

```sh
lxc list name=faasd --format=json | jq -r ".[0].state.network.eth0.addresses[]|select(.family == \"inet\")|.address"
```

See the `admin` password:

```sh
lxc exec faasd -- cat /var/lib/faasd/secrets/basic-auth-password
```

Export `OPENFAAS_URL`:

```sh
export OPENFAAS_URL="http://$(lxc list name=faasd --format=json | jq -r ".[0].state.network.eth0.addresses[]|select(.family == \"inet\")|.address"):8080"
```

Login via `faas-cli`:

```sh
lxc exec faasd -- cat /var/lib/faasd/secrets/basic-auth-password | faas-cli login --password-stdin
```

List functions currently deployed:

```sh
faas-cli list
```

Deploy `certinfo` function:

```sh
faas-cli store deploy certinfo
```

Invoke `certinfo`:

```sh
curl "${OPENFAAS_URL}/function/certinfo" -d "www.google.com"
```

There is a small convenience Shell function on the Nix shell, namely `faas-curl`:

```sh
faas-curl /function/certinfo -d "www.google.com"
```

## References

- OpenFaaS:
  - [OpenFaaS]
  - [faasd]
  - [Build a Serverless appliance with faasd]
  - [Faasd in LXC]
- Linux Container
  - [Linux Container]
  - [Quick-start tutorial with LXD]
- Cloud-init
  - [cloud-init]
  - [Cloud config examples]

<!-- REFERENCES -->

[OpenFaaS]: https://www.openfaas.com
[faasd]: https://github.com/openfaas/faasd
[Build a Serverless appliance with faasd]: https://blog.alexellis.io/deploy-serverless-faasd-with-cloud-init/
[Faasd in LXC]: https://dukemon.leetserve.com/posts/2020/02/faasd-in-lxc/
[Linux Container]: https://linuxcontainers.org
[Quick-start tutorial with LXD]: https://cloudinit.readthedocs.io/en/latest/tutorial/lxd.html
[cloud-init]: https://cloudinit.readthedocs.io
[Cloud config examples]: https://cloudinit.readthedocs.io/en/latest/reference/examples.html
