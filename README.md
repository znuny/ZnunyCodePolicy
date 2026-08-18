<div align="center">
  <a href="https://www.znuny.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://www.znuny.com/assets/znuny-logo.svg">
      <img alt="Znuny" src="https://www.znuny.com/assets/znuny-logo-black.svg" width="300">
    </picture>
  </a>

  ![Build status](https://badge.proxy.znuny.com/ZnunyCodePolicy/dev)
</div>

ZnunyCodePolicy
=================

ZnunyCodePolicy is a general code quality checker that can also make changes to the code.
You can use it to check your code against the Znuny code style guide.

**Installation / Usage**

All important information can be found here [feature.md](https://github.com/znuny/ZnunyCodePolicy/blob/dev/doc/en/feature.md).

**Docker Usage**

Build and run CodePolicy in a container against your current working directory:

```bash
./bin/znuny.CodePolicy.Docker.sh
```

Run against a specific repo and pass arguments through:

```bash
./bin/znuny.CodePolicy.Docker.sh /path/to/repo --all-files
```

Rebuild the image when needed (otherwise the existing local image is reused):

```bash
./bin/znuny.CodePolicy.Docker.sh --rebuild
```

Enjoy!

Your Znuny Team!

[https://www.znuny.com/](https://www.znuny.com/)
