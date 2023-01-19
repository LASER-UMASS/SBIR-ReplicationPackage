# Artifact Setup Requirements

The execution of this artifact requires:

1. A machine with 8 GB RAM, 8 Processors, 130 GB free storage (the exported virtual machine (VM) image size to be downloaded is 50 GB and after importing it needs 80 GB of disk space. You can delete the 50 GB VM image file after importing the image so, in effect you will need 80 GB of storage), and a high-speed active internet connection.

2. [VirtualBox](https://www.virtualbox.org/) manager to load the virtual machine. The VirtualBox version used to create the VM is 6.1. 

The VM uses `Ubuntu 22.04` operating system and has the following software installed that are required to execute the artifact.

- [Java-1.8](https://www.oracle.com/java/technologies/downloads/#java8)
- [R-4.1](https://cran.r-project.org/)
- [Defects4J-2.0](https://github.com/rjust/defects4j/releases/tag/v2.0.0)
- [Indri-5.3](https://sourceforge.net/projects/lemur/files/lemur/indri-5.3/)

The VM also has all the environment variables and dependencies set within the code required for executing the artifact. 

Please see the [README](https://github.com/LASER-UMASS/SBIR-ReplicationPackage/blob/main/artifact_documentation/README.md) file for more details about artifact installation and execution. 
