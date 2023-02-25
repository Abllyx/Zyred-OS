[Powershell]

   Install Command
 - `docker build buildenv -t zyred-OS`

   Build Command
 - `docker run --rm -it -v "${pwd}:/root/env" zyred-OS`

      Build and exit Command
    - `make build-x86_64`
    - `exit`

   Run in Virtual Machine Command
 - `qemu-system-x86_64 -cdrom dist/x86_64/kernel.iso`


   Deleat Command
 - `docker rmi zyred-OS -f`
