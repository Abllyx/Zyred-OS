[Powershell]

   Install Command
 - `docker build buildenv -t Zyre-OS`

   Build Command
 - `docker run --rm -it -v "${pwd}:/root/env" Zyre-OS`

      Build and exit Command
    - `make build-x86_64`
    - `exit`

   Run in Virtual Machine Command
 - `qemu-system-x86_64 -cdrom dist/x86_64/kernel.iso`


   Deleat Command
 - `docker rmi Zyre-OS -f`
