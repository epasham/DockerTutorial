

Seccomp is a Linux feature that allows a userspace program to set up syscall filters. These filters specify which system calls are permitted, and what arguments they are permitted to have. It is a very low-level filter that reduces the attack surface area of the kernel. For example, a bug in keyctl() that allows simple calls to that syscall to elevate privileges would not necessarily be usable for privesc in a program which has restricted access to that call.

- https://www.kernel.org/doc/Documentation/prctl/seccomp_filter.txt


AppArmor is a Mandatory Access Control framework that functions as an LSM (Linux Security Module). It is used to whitelist or blacklist a subject's (program's) access to an object (file, path, etc.). AppArmor may be used to allow a program to have read access to /etc/passwd, but not /etc/shadow. The policies can also be used to restrict capabilities, or even limit network access.

- https://sysdig.com/blog/selinux-seccomp-falco-technical-discussion/
