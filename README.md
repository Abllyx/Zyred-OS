[Powershell]
    [First]

 - `docker build buildenv -t lyx-os`


    [Normal]

 - `docker run --rm -it -v "${pwd}:/root/env" lyx-os`

    - `make build-x86_64`
    - `exit`

 - `qemu-system-x86_64 -cdrom dist/x86_64/kernel.iso`


    [Remove]

 - `docker rmi lyx-os -f`
