A plethora of non-functional enhancements were made in this release:

- Remove the need for AWK when specifying a custom dictionary.
- Remove the hardcoded dictionary and generate it every build.
- Add tests and CI platforms.
- Make the libobsd wrap pull an exact libobsd version and use checksum
  verification.
- Revamp the installer script to support custom build options and making
  installers for MSYS2 and CLANG64.
- Automate releases.
- Keep a changelog.
- Use FreeBSD's [capsicum](https://www.freebsd.org/cgi/man.cgi?capsicum)
  framework.
- Unify the MSYS2 Github Actions jobs.
